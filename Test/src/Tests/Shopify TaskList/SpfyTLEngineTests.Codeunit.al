codeunit 85311 "NPR Spfy TL Engine Tests"
{
    // [FEATURE] Shopify Task List - processing engine: eligibility, selection order, waiting, batching, retry ladder, manual processing (real rows, scripted send boundary)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _ReclaimedLbl: Label 'The processing session that claimed this task is no longer active. The task has been released for another attempt.';
        _ReclaimedQuarantinedLbl: Label 'The processing session that claimed this task is no longer active and the task has no attempts left. It has been quarantined.', Locked = true;
        _SourceGoneLbl: Label 'The source record no longer exists. The request is no longer applicable.';
        _WaitingForParentLbl: Label 'Awaiting parent product sync';

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        SetMigrationCompleted();
        ClearRunContext();
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
    end;

    local procedure SetMigrationCompleted()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        // Direct write: the feature gate makes every supported activation path impossible, and the engine refuses to run below Completed.
        ShopifySetup.Get();
        ShopifySetup."Task List Migration Status" := ShopifySetup."Task List Migration Status"::Completed;
        ShopifySetup.Modify(false);
    end;

    local procedure ClearRunContext()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearSendBoundary();
    end;

    local procedure Hours(HourCount: Integer): Duration
    begin
        exit(HourCount * 60 * 60 * 1000);
    end;

    local procedure Minutes(MinuteCount: Integer): Duration
    begin
        exit(MinuteCount * 60 * 1000);
    end;

    local procedure Seconds(SecondCount: Integer): Duration
    begin
        // The smallest offset that survives the datetime rounding of the database: a millisecond offset can round onto the cycle time itself.
        exit(SecondCount * 1000);
    end;

    local procedure CreateSyncedItem(StoreCode: Code[20]; ParentSyncedToShopify: Boolean; var Item: Record Item; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        if ParentSyncedToShopify then
            _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));
    end;

    local procedure EnqueueItemTask(StoreCode: Code[20]; Item: Record Item; TaskType: Enum "NPR Spfy Task Op"; NotBeforeDateTime: DateTime; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, Item.RecordId(), Item."No.", TaskType, 0DT, NotBeforeDateTime, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueVariantTask(StoreCode: Code[20]; ItemVariant: Record "Item Variant"; TaskType: Enum "NPR Spfy Task Op"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemVariant);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, ItemVariant.RecordId(), SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code), TaskType, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueTagTask(StoreCode: Code[20]; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        RecRef: RecordRef;
    begin
        // The tag task carries the tag request table but points its Record ID at the owning store-item link, exactly as the tag scheduler does.
        RecRef.GetTable(TagUpdateRequest);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, SpfyStoreItemLink.RecordId(), SpfyStoreItemLink."Item No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueCostTask(StoreCode: Code[20]; Item: Record Item; AtDateTime: DateTime): BigInteger
    var
        InventoryBuffer: Record "Inventory Buffer";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        // The cost carrier is a synthetic record id over a buffer row that is never persisted; only its item number is real.
        InventoryBuffer."Item No." := Item."No.";
        RecRef.GetTable(InventoryBuffer);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, RecRef.RecordId(), Item."No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure GetTask(EntryNo: BigInteger; var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask.Get(EntryNo);
    end;

    local procedure AssertTask(EntryNo: BigInteger; ExpectedState: Enum "NPR Spfy Task State"; ExpectedAttempts: Integer; FailureMsg: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _Assert.IsTrue(SpfyTask.State = ExpectedState, StrSubstNo('%1: expected state %2 but found %3 with %4 attempt(s)', FailureMsg, ExpectedState, SpfyTask.State, SpfyTask.Attempts));
        _Assert.AreEqual(ExpectedAttempts, SpfyTask.Attempts, StrSubstNo('%1: attempts', FailureMsg));
    end;

    local procedure ResponseText(EntryNo: BigInteger): Text
    var
        SpfyTask: Record "NPR Spfy Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.CalcFields(Response);
        if not SpfyTask.Response.HasValue() then
            exit('');
        SpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    local procedure SetStateRaw(EntryNo: BigInteger; NewState: Enum "NPR Spfy Task State"; NewAttempts: Integer)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.State := NewState;
        SpfyTask.Attempts := NewAttempts;
        SpfyTask.Modify(false);
    end;

    local procedure SetClaimRaw(EntryNo: BigInteger; ServerInstance: Integer; SessionNo: Integer; ClaimedAt: DateTime; NewAttempts: Integer)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.State := SpfyTask.State::"In Flight";
        SpfyTask.Attempts := NewAttempts;
        SpfyTask."Claimed At" := ClaimedAt;
        SpfyTask."Claimed By Server Instance" := ServerInstance;
        SpfyTask."Claimed By Session" := SessionNo;
        SpfyTask.Modify(false);
    end;

    local procedure SetProcessingInterval(StoreCode: Code[20]; IntervalMinutes: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Spfy Task Processor";
        JobQueueEntry."Parameter String" := StoreCode;
        JobQueueEntry."No. of Minutes between Runs" := IntervalMinutes;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert(false);
    end;

    local procedure SetLastCycleAt(StoreCode: Code[20]; AtDateTime: DateTime)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        if not SpfyDataSyncPointer.Get(StoreCode) then begin
            SpfyDataSyncPointer.Init();
            SpfyDataSyncPointer."Shopify Store Code" := StoreCode;
            SpfyDataSyncPointer.Insert(false);
        end;
        SpfyDataSyncPointer."Last Task List Cycle At" := AtDateTime;
        SpfyDataSyncPointer.Modify(false);
    end;

    local procedure InFlightTaskCount(): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange(State, SpfyTask.State::"In Flight");
        exit(SpfyTask.Count());
    end;

    local procedure TaskCountInState(StoreCode: Code[20]; TaskState: Enum "NPR Spfy Task State"): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Store Code", StoreCode);
        SpfyTask.SetRange(State, TaskState);
        exit(SpfyTask.Count());
    end;

    #region Cycle
    [Test]
    procedure CycleProcessesOnlyOwnStore()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreA: Code[20];
        StoreB: Code[20];
        AtDateTime: DateTime;
        TaskA: BigInteger;
        TaskB: BigInteger;
    begin
        // [SCENARIO] A store's processing cycle sends only the tasks of that store and leaves another store's task untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreA, true, ItemA, SpfyStoreItemLink);
        CreateSyncedItem(StoreB, true, ItemB, SpfyStoreItemLink);
        TaskA := EnqueueItemTask(StoreA, ItemA, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        TaskB := EnqueueItemTask(StoreB, ItemB, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [WHEN] Only the first store's cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreA, AtDateTime);

        AssertTask(TaskA, "NPR Spfy Task State"::Completed, 1, 'The task of the store being processed must be sent');
        AssertTask(TaskB, "NPR Spfy Task State"::Pending, 0, 'The task of another store must be left untouched');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'Only the processed store may reach the send boundary');
    end;

    [Test]
    procedure NotBeforeFutureIsSkipped()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A task due after the cycle time is skipped without being sent or spending an attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime + Seconds(1), AtDateTime);

        // [WHEN] The cycle runs one second before the task is due.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A task due after the cycle time must not be sent');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A task that is not due yet must never reach the send boundary');
    end;

    [Test]
    procedure NotBeforePastIsEligible()
    var
        ItemAtBoundary: Record Item;
        ItemPast: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        AtBoundaryTask: BigInteger;
        PastTask: BigInteger;
    begin
        // [SCENARIO] A task due exactly at, or before, the cycle time is sent.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, ItemAtBoundary, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, ItemPast, SpfyStoreItemLink);
        AtBoundaryTask := EnqueueItemTask(StoreCode, ItemAtBoundary, "NPR Spfy Task Op"::Modify, AtDateTime, AtDateTime);
        PastTask := EnqueueItemTask(StoreCode, ItemPast, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(1), AtDateTime);

        // [WHEN] The cycle runs exactly at, and after, the due time.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(AtBoundaryTask, "NPR Spfy Task State"::Completed, 1, 'A task due exactly at the cycle time must be sent');
        AssertTask(PastTask, "NPR Spfy Task State"::Completed, 1, 'A task due before the cycle time must be sent');
    end;

    [Test]
    procedure EarliestScheduledFirstBlankFirst()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        LateTask: BigInteger;
        UndelayedTask: BigInteger;
        EarliestTask: BigInteger;
        MiddleTask: BigInteger;
    begin
        // [SCENARIO] Due tasks are sent with the undelayed one first and the rest in ascending scheduled order.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] Four due tasks created in an order that does not match their schedule.
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        LateTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(1), AtDateTime);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        UndelayedTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        EarliestTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(3), AtDateTime);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        MiddleTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(2), AtDateTime);

        // [WHEN] The cycle sends them.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The undelayed task goes first, then the remainder by ascending schedule.
        _Assert.AreEqual(4, _BndMock.DispatchedRowCount(), 'All four due tasks must be sent');
        _Assert.AreEqual(UndelayedTask, _BndMock.DispatchedEntryNo(1), 'A task with no not-before time must be sent first');
        _Assert.AreEqual(EarliestTask, _BndMock.DispatchedEntryNo(2), 'The earliest scheduled task must follow');
        _Assert.AreEqual(MiddleTask, _BndMock.DispatchedEntryNo(3), 'The middle scheduled task must be third');
        _Assert.AreEqual(LateTask, _BndMock.DispatchedEntryNo(4), 'The latest scheduled task must be last');
    end;

    [Test]
    procedure BudgetStopsBetweenTasks()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTask: BigInteger;
        SecondTask: BigInteger;
        ThirdTask: BigInteger;
    begin
        // [SCENARIO] An exhausted run budget stops the cycle between tasks, leaving every task Pending, unsent and unclaimed.
        Initialize();
        // [GIVEN] A cycle whose 30 minute budget was already spent before the first task is looked at.
        AtDateTime := CurrentDateTime() - Hours(1);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        FirstTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        SecondTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        ThirdTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] It stops between tasks: nothing is sent and no attempt is spent.
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'An exhausted run budget must stop the cycle before any dispatch');
        AssertTask(FirstTask, "NPR Spfy Task State"::Pending, 0, 'The remainder must stay Pending when the budget is gone');
        AssertTask(SecondTask, "NPR Spfy Task State"::Pending, 0, 'The remainder must stay Pending when the budget is gone');
        AssertTask(ThirdTask, "NPR Spfy Task State"::Pending, 0, 'The remainder must stay Pending when the budget is gone');
        _Assert.AreEqual(0, InFlightTaskCount(), 'A budget stop must never leave a task claimed');
    end;

    [Test]
    procedure RetryingTaskKeepsScheduledOrder()
    var
        FreshItem: Record Item;
        RetryingItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FreshTask: BigInteger;
        RetryingTask: BigInteger;
    begin
        // [SCENARIO] A task that has already failed keeps its place in the schedule and is sent before a later scheduled fresh one.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, FreshItem, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, RetryingItem, SpfyStoreItemLink);

        // [GIVEN] A fresh task created first, and an already failed task scheduled earlier.
        FreshTask := EnqueueItemTask(StoreCode, FreshItem, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(1), AtDateTime);
        RetryingTask := EnqueueItemTask(StoreCode, RetryingItem, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(2), AtDateTime);
        SetStateRaw(RetryingTask, "NPR Spfy Task State"::Pending, 2);

        // [WHEN] The cycle sends both.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Spent attempts do not push a task to the back: the schedule decides.
        _Assert.AreEqual(RetryingTask, _BndMock.DispatchedEntryNo(1), 'A retrying task scheduled earlier must be sent before a fresh one');
        _Assert.AreEqual(FreshTask, _BndMock.DispatchedEntryNo(2), 'The later scheduled fresh task must be sent second');
        AssertTask(RetryingTask, "NPR Spfy Task State"::Completed, 3, 'The retried task must complete on its next attempt');
    end;
    #endregion

    #region Waiting
    [Test]
    procedure VariantWithoutParentProductDefersWithoutAttempt()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A variant whose product has never reached Shopify waits without spending an attempt, recording what it waits for and since when.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The cycle reaches a variant whose product has never been sent to Shopify.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The task is deferred, not attempted, and the failed lookup is recorded in the response, not masked away.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A variant without a Shopify product must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred variant must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Reason" <> '', 'The task must record why it is waiting');
        _Assert.AreEqual(_WaitingForParentLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        SpfyTask.CalcFields(Response);
        _Assert.IsTrue(SpfyTask.Response.HasValue(), 'A failed parent lookup must store the full error for Show Response');
        _Assert.AreEqual(AtDateTime, SpfyTask."Waiting Since", 'The task must record when it started waiting');
    end;

    [Test]
    procedure WaitingSendsAfterParentAssigned()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A waiting variant is sent once its product exists in Shopify, and its waiting state is cleared.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForParentLbl, AtDateTime);

        // [GIVEN] The parent product reaches Shopify.
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(5));

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting variant must be sent once its product exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released task must be sent exactly once');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(0DT, SpfyTask."Waiting Since", 'A released task must have its waiting state cleared');
    end;

    [Test]
    procedure TagsWithoutParentDefers()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A tag update whose product has never reached Shopify waits without spending an attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueTagTask(StoreCode, SpfyStoreItemLink, AtDateTime);

        // [WHEN] The cycle reaches a tag update whose product has never been sent to Shopify.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A tag update without a Shopify product must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred tag update must never reach the send boundary');
    end;

    [Test]
    procedure DeleteOpExemptFromParentPrecondition()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A delete is sent even while the parent product is unknown in Shopify.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);

        // [WHEN] A variant delete runs while the product is not known in Shopify.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A delete must not be held back by the parent product precondition');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A delete must reach the send boundary without a parent product');
    end;

    [Test]
    procedure AgedWaitingTaskQuarantinedPastThreshold()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        WaitingSince: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A task that has waited a full day is given up on without spending an attempt, keeps its waiting reason and start, and is left alone by later cycles.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The task must be waiting before it can age');

        // The stored waiting time is the anchor: the database rounds date-times, so the threshold has to be measured from what it actually kept.
        GetTask(TaskEntryNo, SpfyTask);
        WaitingSince := SpfyTask."Waiting Since";

        // [WHEN] It has been waiting one second short of a day, with the engine having cycled all along.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(24) - Seconds(1));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(24) - Seconds(1));
        GetTask(TaskEntryNo, SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A task waiting less than a day must keep waiting');

        // [WHEN] It has been waiting exactly a day.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(24));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(24));
        GetTask(TaskEntryNo, SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 0, 'A task waiting a full day must be given up on without spending an attempt');
        _Assert.AreEqual(WaitingSince, SpfyTask."Waiting Since", 'A quarantined park must keep when it started waiting');
        _Assert.AreEqual(_WaitingForParentLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), _WaitingForParentLbl), 'The quarantine response must carry the lookup error, not the stable label');

        // [WHEN] Further cycles run while it keeps waiting.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(25));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(25));
        GetTask(TaskEntryNo, SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 0, 'Repeated cycles must not disturb a task already given up on');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'An aged waiting task must never be sent');
    end;

    [Test]
    procedure AgedTaskReleasedNotQuarantinedWhenPreconditionMetAtThreshold()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        WaitingSince: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A task whose precondition is met exactly at the aging threshold is sent instead of being given up on.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        WaitingSince := SpfyTask."Waiting Since";

        // [GIVEN] The parent product reaches Shopify just before the task would be given up on.
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));

        // [WHEN] The cycle at the aging threshold runs.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(24));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(24));

        // [THEN] Release wins over the give-up path: the task is sent, never quarantined.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A task whose precondition is met at the threshold must be sent, not quarantined');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released task must be sent exactly once');
    end;

    [Test]
    procedure AgedRecheckLookupFailureIsRecordedInResponse()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An aged waiting task whose one-shot re-check lookup fails is quarantined without spending an attempt, keeping the stable blocker label as its reason and the lookup error in its response.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        // [GIVEN] A task parked a day ago with the benign reason, so only the aged one-shot re-check can change it.
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForParentLbl, AtDateTime - Hours(25));
        // The engine cycled all along; without that the aging clock restarts and nothing can be given up on.
        SetLastCycleAt(StoreCode, AtDateTime);

        // [WHEN] The aging cycle runs and the one-shot live lookup itself fails.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The park is given up on without spending an attempt; the reason stays the stable label and the lookup error lands in the response.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 0, 'An aged waiting task whose re-check lookup fails must be quarantined without spending an attempt');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForParentLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), _WaitingForParentLbl), 'The quarantine response must carry the lookup error, not the stable label');
    end;

    [Test]
    procedure DisabledStoreSkipsWithoutAttemptOrGivingUp()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ItemTask: BigInteger;
        WaitingTask: BigInteger;
    begin
        // [SCENARIO] A disabled store's tasks are left where they are, nothing is sent and the waiting clock is untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        // [GIVEN] A store whose whole Shopify integration is switched off.
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.DisableStore(StoreCode);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        ItemTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        WaitingTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        GetTask(WaitingTask, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForParentLbl, AtDateTime - Hours(25));
        // Without a recorded cycle the store counts as never cycled and the backdated clock would simply restart.
        SetLastCycleAt(StoreCode, AtDateTime);

        // [WHEN] The cycle runs for the disabled store.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Tasks of a disabled store are left alone: no attempt, not given up on.
        AssertTask(ItemTask, "NPR Spfy Task State"::Pending, 0, 'A task of a disabled store must be left Pending');
        AssertTask(WaitingTask, "NPR Spfy Task State"::Waiting, 0, 'A waiting task of a disabled store must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A disabled store must never send');
        // [THEN] The cycle never reached the waiting pass, so the clock is untouched and the gap discounts as downtime instead.
        GetTask(WaitingTask, SpfyTask);
        _Assert.AreEqual(AtDateTime - Hours(25), SpfyTask."Waiting Since", 'A disabled store must leave the waiting clock untouched');
    end;

    [Test]
    procedure IntegrationOrStoreDisabledNeverSendsEvenManually()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ItemTask: BigInteger;
    begin
        // [SCENARIO] Neither a disabled integration nor a disabled store sends a task, manual processing included, and re-enabling the store lets the same task through.
        Initialize();
        AtDateTime := CurrentDateTime();
        // [GIVEN] A fully enabled store with one queued task.
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        ItemTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [WHEN] The whole integration is switched off and the cycle runs.
        _Lib.DisableIntegration();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Nothing is sent and no attempt is spent.
        AssertTask(ItemTask, "NPR Spfy Task State"::Pending, 0, 'A task must not be processed while the whole Shopify integration is disabled');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A disabled integration must never send');

        // [WHEN] The same task is processed MANUALLY with the integration still off.
        GetTask(ItemTask, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, false);

        // [THEN] The manual path is gated too - the shared evaluator carries this guarantee for both callers.
        AssertTask(ItemTask, "NPR Spfy Task State"::Pending, 0, 'Manual processing must not bypass the disabled-integration gate');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A disabled integration must never send, not even manually');

        // [WHEN] The integration is back on but the STORE is disabled, and the task is processed manually.
        _Lib.EnsureIntegrationEnabled();
        _Lib.DisableStore(StoreCode);
        GetTask(ItemTask, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, false);

        // [THEN] Still gated, on the store this time.
        AssertTask(ItemTask, "NPR Spfy Task State"::Pending, 0, 'Manual processing must not bypass the disabled-store gate');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A disabled store must never send, not even manually');

        // [WHEN] The store is re-enabled and the very same task is processed manually again.
        _Lib.EnableStore(StoreCode);
        GetTask(ItemTask, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, false);

        // [THEN] It sends - proving the assertions above were the gate, not a dead fixture.
        AssertTask(ItemTask, "NPR Spfy Task State"::Completed, 1, 'Re-enabling the store must let the queued task through');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The re-enabled task must be dispatched exactly once');
    end;

    [Test]
    procedure PreconditionMetBetweenCheckAndSendIsHarmless()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A precondition met right after a task was deferred leads to exactly one send on the next cycle.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] The cycle defers the variant, and the product is assigned right after that decision.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The first cycle must defer the variant');
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The update is neither lost nor sent twice.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A precondition met after the defer must be sent on the next cycle');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A late precondition must not cause a second send');
    end;

    [Test]
    procedure GivenEngineDowntime_WhenCycleResumes_ThenWaitingAgeDiscountsTheGap()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A parked task survives an engine outage un-aged because the waiting clock discounts the gap.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] A cycle parked the task, then the engine was down for two days.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The task must be waiting before the outage');

        // [WHEN] The first cycle after the outage runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(48));

        // [THEN] The park is not treated as aged: the waiting clock was pushed past the outage.
        GetTask(TaskEntryNo, SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A park must survive an engine outage un-aged');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'An engine outage must not age parked tasks');
        _Assert.IsTrue(SpfyTask."Waiting Since" >= AtDateTime + Hours(48) - Minutes(10), 'The waiting clock must discount the outage');
    end;

    [Test]
    procedure GivenManualParkOnNeverCycledStore_WhenFirstCycleRunsLater_ThenNotAged()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A manually parked task on a store that has never cycled restarts its waiting clock instead of being aged.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] An operator parked the task by hand on a store whose processing cycle has never run,
        // so nothing has ever recorded that the engine was alive.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, false);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'Process Now must park a task whose precondition is unmet');

        // [WHEN] The first cycle for that store runs more than a day later.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(25));

        // [THEN] The wait is not counted against the task: without evidence the engine was running, its clock restarts.
        GetTask(TaskEntryNo, SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A manually parked task must not be aged by a first cycle that proves nothing');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A first cycle on a never-cycled store must not age a parked task');
        _Assert.IsTrue(SpfyTask."Waiting Since" >= AtDateTime + Hours(25) - Minutes(10), 'The waiting clock must restart when no prior cycle is recorded');
    end;

    [Test]
    procedure GivenManualParkDuringOutage_WhenCycleResumes_ThenClockNeverInFuture()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A task parked during an outage keeps a waiting clock that is never pushed past the recovery cycle.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] A store that last cycled at T, and a task an operator parked by hand halfway through a 48h outage.
        SetLastCycleAt(StoreCode, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForParentLbl, AtDateTime + Hours(24));

        // [WHEN] The first cycle after the outage runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(48));

        // [THEN] The whole gap is not added on top of a mid-outage park: the clock stops at the recovery time.
        GetTask(TaskEntryNo, SpfyTask);
        // The tolerance absorbs date-time rounding only; the uncapped shift landed a full day past this.
        _Assert.IsTrue(SpfyTask."Waiting Since" <= AtDateTime + Hours(48) + Seconds(1), 'The waiting clock must never be pushed into the future');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A task parked during an outage must not be aged by the recovery cycle');
    end;

    [Test]
    procedure GivenDowntimeAlreadyDiscounted_WhenTheNextCycleRuns_ThenTheClockIsNotShiftedAgain()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        DiscountedWaitingSince: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An outage a recovery cycle has already discounted is never discounted a second time.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] A recovery cycle that has already discounted a 48h outage.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(48));
        GetTask(TaskEntryNo, SpfyTask);
        DiscountedWaitingSince := SpfyTask."Waiting Since";

        // [WHEN] The very next cycle runs a minute later.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(48) + Minutes(1));

        // [THEN] The same outage is not credited twice: the committed cycle stamp closed it.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(DiscountedWaitingSince, SpfyTask."Waiting Since", 'A discounted outage must never be discounted a second time');
    end;

    [Test]
    procedure GivenStoreScheduledSlowerThanTheGrace_WhenCyclesRunOnSchedule_ThenTasksStillAge()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        WaitingSince: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] On a store scheduled slower than the grace period an on-schedule gap is not downtime, and a parked task still ages out once it has waited a day.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] A store whose processing job runs every 10 minutes, well beyond the fixed 5 minute grace.
        SetProcessingInterval(StoreCode, 10);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The task must be waiting before it can age');
        GetTask(TaskEntryNo, SpfyTask);
        WaitingSince := SpfyTask."Waiting Since";

        // [WHEN] The next cycle runs exactly on schedule.
        SetLastCycleAt(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));

        // [THEN] A gap that is just the configured cadence is not downtime, so the clock is left alone.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(WaitingSince, SpfyTask."Waiting Since", 'A scheduled interval must never be discounted as engine downtime');

        // [WHEN] A day of on-schedule cycles has passed.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(24));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(24) + Minutes(10));

        // [THEN] The task still ages out: a slower schedule must not disable the aging threshold altogether.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 0, 'A task on a slowly scheduled store must still age out once it has waited a day');
    end;

    [Test]
    procedure GivenStoreScheduledSlowerThanTheGrace_WhenARealOutageHappens_ThenItIsStillDiscounted()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A real outage on a slowly scheduled store still discounts the waiting clock and leaves the parked task un-aged.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, false, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] The same slowly scheduled store with a parked task.
        SetProcessingInterval(StoreCode, 10);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The task must be waiting before the outage');

        // [WHEN] The engine is down for two days, far beyond the widened grace.
        SetLastCycleAt(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(48));

        // [THEN] A gap that cannot be explained by the schedule is still treated as downtime.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Since" >= AtDateTime + Hours(48) - Minutes(10), 'A real outage must still discount the waiting clock');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A real outage must not age parked tasks on a slowly scheduled store');
    end;
    #endregion

    #region Vanished
    [Test]
    procedure VanishedSourceCompletesNoLongerApplicable()
    var
        CostItem: Record Item;
        ProductItem: Record Item;
        TagStoreItemLink: Record "NPR Spfy Store-Item Link";
        TagItem: Record Item;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CostTask: BigInteger;
        ProductTask: BigInteger;
        TagTask: BigInteger;
    begin
        // [SCENARIO] A product, cost or tag task whose source record is gone is closed as no longer applicable instead of being sent.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        // Items carry no store link here: an item whose link says it is synchronized cannot be deleted at all.
        _Lib.CreateItem(ProductItem);
        _Lib.CreateItem(CostItem);
        _Lib.CreateItem(TagItem);
        _Lib.CreateItemLink(TagStoreItemLink, TagItem."No.", StoreCode, true, false);
        ProductTask := EnqueueItemTask(StoreCode, ProductItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        CostTask := EnqueueCostTask(StoreCode, CostItem, AtDateTime);
        TagTask := EnqueueTagTask(StoreCode, TagStoreItemLink, AtDateTime);

        // [GIVEN] Every source record is gone before the cycle reaches its task.
        ProductItem.Delete(false);
        CostItem.Delete(false);
        TagStoreItemLink.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Each task is closed as no longer applicable instead of being sent or retried.
        AssertTask(ProductTask, "NPR Spfy Task State"::Completed, 0, 'A product task whose item is gone must be closed');
        AssertTask(CostTask, "NPR Spfy Task State"::Completed, 0, 'A cost task whose item is gone must be closed');
        AssertTask(TagTask, "NPR Spfy Task State"::Completed, 0, 'A tag task whose store-item link is gone must be closed');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(ProductTask), 'The product task must record why it is no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(CostTask), 'The cost task must record why it is no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TagTask), 'The tag task must record why it is no longer applicable');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A vanished source must never reach the send boundary');
    end;

    [Test]
    procedure VanishedSourceDeleteStillDispatches()
    var
        Item: Record Item;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A delete is still sent after its source record is gone rather than being closed as no longer applicable.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Delete, 0DT, AtDateTime);

        // [GIVEN] The item is gone - which is exactly why the delete exists.
        Item.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A delete must still be sent after its source record is gone');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A delete of a gone record must reach the send boundary');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'A delete must not be closed as no longer applicable');
    end;

    [Test]
    procedure GivenCostTaskWhoseItemExists_WhenCycleRuns_ThenItIsDispatchedNotClosed()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A cost task whose item still exists is sent as the cost carrier instead of being closed as no longer applicable.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A cost task whose item is alive and synced, carried by a buffer row that was never persisted.
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));
        TaskEntryNo := EnqueueCostTask(StoreCode, Item, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The cost task is sent rather than closed as no longer applicable.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A cost task whose item exists must be sent');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A cost task whose item exists must reach the send boundary');
        _Assert.AreEqual(Database::"Inventory Buffer", _BndMock.LastDispatchTableNo(), 'The dispatched task must be the cost carrier');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'A cost task whose item exists must not be closed as no longer applicable');
    end;

    [Test]
    procedure GivenCostTaskWithoutProductId_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A cost task for an item whose product has never reached Shopify waits without spending an attempt, records the blocker label as its reason and keeps the failed lookup in its response.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A cost task for an item whose product has never reached Shopify.
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        TaskEntryNo := EnqueueCostTask(StoreCode, Item, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The cost is deferred, not attempted: sent now it would fail on every variant and quarantine.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A cost task without a Shopify product must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred cost task must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Reason" <> '', 'The task must record why it is waiting');
        // The test container has no Shopify endpoint, so the first-dispatch live lookup fails: the stable label stays the reason and the error goes to the response.
        _Assert.AreEqual(_WaitingForParentLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        SpfyTask.CalcFields(Response);
        _Assert.IsTrue(SpfyTask.Response.HasValue(), 'A failed product lookup must store the full error for Show Response');
    end;

    [Test]
    procedure GivenSyncDisabledItemWithoutProductId_WhenCycleRuns_ThenCostDispatchesInsteadOfWaiting()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A cost task of a sync-disabled item is dispatched to the send boundary instead of being parked on a Shopify product lookup.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);

        // [GIVEN] A cost task whose item has no Shopify product and whose store link is sync-disabled.
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        TaskEntryNo := EnqueueCostTask(StoreCode, Item, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The cost task is dispatched instead of parked for a day on a lookup it should never have paid for.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A cost task of a sync-disabled item must be dispatched so the send can fail it fast, not parked on a Shopify lookup');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A cost task of a sync-disabled item must reach the send boundary');
        _Assert.AreEqual(Database::"Inventory Buffer", _BndMock.LastDispatchTableNo(), 'The dispatched task must be the cost carrier');
        GetTask(TaskEntryNo, SpfyTask);
        SpfyTask.CalcFields(Response);
        _Assert.IsFalse(SpfyTask.Response.HasValue(), 'No Shopify lookup may be attempted for a sync-disabled item');
    end;

    [Test]
    procedure GivenWaitingCostTask_WhenProductIdAssigned_ThenNextCycleSends()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A cost task waiting for its Shopify product keeps waiting while the product is missing and is sent on a single fresh attempt once the product id is assigned.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A cost task already parked because its product was not in Shopify.
        TaskEntryNo := EnqueueCostTask(StoreCode, Item, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForParentLbl, AtDateTime);

        // [WHEN] A cycle runs while the product is still missing.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + 60000);

        // [THEN] The cost task keeps waiting.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A cost task whose product is still missing must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A cost task whose product is still missing must never reach the send boundary');

        // [WHEN] The product reaches Shopify and the next cycle runs.
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + 120000);

        // [THEN] The waiting cost task is released and sent on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting cost task must be sent once its product exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released cost task must be sent exactly once');
        _Assert.AreEqual(Database::"Inventory Buffer", _BndMock.LastDispatchTableNo(), 'The dispatched task must be the cost carrier');
    end;
    #endregion

    #region Batch
    [Test]
    procedure BatchGroupedPerTableAndStore()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        OtherItem: Record Item;
        OtherItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreA: Code[20];
        StoreB: Code[20];
        AtDateTime: DateTime;
        ItemTask: BigInteger;
        OtherStoreTask: BigInteger;
        FirstVariantTask: BigInteger;
        SecondVariantTask: BigInteger;
    begin
        // [SCENARIO] Tasks are grouped into one call per source table and store, and another store's task never joins the group.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreA, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        FirstVariantTask := EnqueueVariantTask(StoreA, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        SecondVariantTask := EnqueueVariantTask(StoreA, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        ItemTask := EnqueueItemTask(StoreA, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        CreateSyncedItem(StoreB, true, OtherItem, SpfyStoreItemLink);
        _Lib.CreateItemVariant(OtherItemVariant, OtherItem."No.");
        OtherStoreTask := EnqueueVariantTask(StoreB, OtherItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] One store's cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreA, AtDateTime);

        // [THEN] The two variants of that store travel as one grouped call, separate from the single-record kind.
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'The item task and the variant group must be two separate calls');
        _Assert.AreEqual(Database::"Item Variant", _BndMock.LastDispatchTableNo(), 'The grouped call must carry the variant table');
        _Assert.AreEqual(2, _BndMock.LastDispatchRowCount(), 'Both variants of the store must be grouped into one call');
        AssertTask(ItemTask, "NPR Spfy Task State"::Completed, 1, 'The item task must be sent');
        AssertTask(FirstVariantTask, "NPR Spfy Task State"::Completed, 1, 'The first variant must be sent');
        AssertTask(SecondVariantTask, "NPR Spfy Task State"::Completed, 1, 'The second variant must be sent');
        AssertTask(OtherStoreTask, "NPR Spfy Task State"::Pending, 0, 'A variant of another store must not join the group');
    end;

    [Test]
    procedure BatchDispatchReceivesTemporarySet()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTask: BigInteger;
        SecondTask: BigInteger;
        ThirdTask: BigInteger;
    begin
        // [SCENARIO] A group travels as a temporary work list carrying the real entry numbers in order, and every task of a successful group completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        FirstTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        SecondTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        ThirdTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The cycle dispatches the group.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The send boundary receives a temporary work list carrying the real entry numbers, in entry number order.
        _Assert.IsTrue(_BndMock.LastDispatchWasTemporary(), 'A batch group must be handed over as a temporary record set');
        _Assert.AreEqual(3, _BndMock.LastDispatchRowCount(), 'The work list must carry every task of the group');
        _Assert.AreEqual(FirstTask, _BndMock.DispatchedEntryNo(1), 'The work list must carry the real entry number of the first task');
        _Assert.AreEqual(SecondTask, _BndMock.DispatchedEntryNo(2), 'The work list must carry the real entry number of the second task');
        _Assert.AreEqual(ThirdTask, _BndMock.DispatchedEntryNo(3), 'The work list must carry the real entry number of the third task');
        AssertTask(FirstTask, "NPR Spfy Task State"::Completed, 1, 'Every task of a successful group must complete');
        AssertTask(SecondTask, "NPR Spfy Task State"::Completed, 1, 'Every task of a successful group must complete');
        AssertTask(ThirdTask, "NPR Spfy Task State"::Completed, 1, 'Every task of a successful group must complete');
    end;

    [Test]
    procedure PerEntityFailureFailsOnlyThatTask()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FailingTask: BigInteger;
        VariantIndex: Integer;
        FailureText: Text;
    begin
        // [SCENARIO] A rejection of one entity in a group leaves only that task retryable with the error recorded, while the rest complete.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'Variant SKU is invalid';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);

        // [GIVEN] Fifty variants in one group, of which one is rejected by Shopify.
        for VariantIndex := 1 to 50 do begin
            _Lib.CreateItemVariant(ItemVariant, Item."No.");
            if VariantIndex = 7 then
                FailingTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime)
            else
                EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        end;
        _BndMock.QueueOutcome(FailingTask, false, FailureText);

        // [WHEN] The group is dispatched.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Only the rejected entity fails, and it fails retryably.
        _Assert.AreEqual(49, TaskCountInState(StoreCode, "NPR Spfy Task State"::Completed), 'Every accepted entity of the group must complete');
        _Assert.AreEqual(1, TaskCountInState(StoreCode, "NPR Spfy Task State"::Pending), 'Only the rejected entity must stay unsent');
        AssertTask(FailingTask, "NPR Spfy Task State"::Pending, 1, 'A per-entity rejection must leave that task retryable');
        _Assert.AreEqual(FailureText, ResponseText(FailingTask), 'The rejected task must record the error returned for it');
    end;

    [Test]
    procedure WholeCallFailureFailsAllRetryably()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTask: BigInteger;
        SecondTask: BigInteger;
        ThirdTask: BigInteger;
        FailureText: Text;
    begin
        // [SCENARIO] A failed call leaves every task of the group retryable with the error recorded and the claim released.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'Shopify returned 500 Internal Server Error';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        FirstTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        SecondTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        ThirdTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _BndMock.SetWholeCallFailure(FailureText);

        // [WHEN] The whole call to Shopify fails.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Every task of the group is retryable, and none is left claimed.
        AssertTask(FirstTask, "NPR Spfy Task State"::Pending, 1, 'A failed call must leave every task of the group retryable');
        AssertTask(SecondTask, "NPR Spfy Task State"::Pending, 1, 'A failed call must leave every task of the group retryable');
        AssertTask(ThirdTask, "NPR Spfy Task State"::Pending, 1, 'A failed call must leave every task of the group retryable');
        _Assert.AreEqual(0, InFlightTaskCount(), 'A failed call must never strand a task in flight');
        _Assert.AreEqual(FailureText, ResponseText(SecondTask), 'Every task of the group must record the call error');
        GetTask(FirstTask, SpfyTask);
        _Assert.AreEqual(0DT, SpfyTask."Claimed At", 'A failed task must have its claim released');
    end;

    [Test]
    procedure ThrownDispatchSweepsSameCycle()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        SentTask: BigInteger;
        StrandedTask: BigInteger;
        UntouchedTask: BigInteger;
        FailureText: Text;
    begin
        // [SCENARIO] An interrupted dispatch is swept in the same cycle: a recorded outcome stands, the claimed task returns to Pending with the interruption noted, and a task never reached keeps its attempts.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'The request was interrupted';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        SentTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        StrandedTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        UntouchedTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] The send fails after claiming the second task and without recording its outcome.
        _BndMock.SetThrowMidBatch(2, FailureText);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The claimed-but-unfinished task is recovered in the same cycle, and nothing is stranded.
        _Assert.AreEqual(0, InFlightTaskCount(), 'An interrupted dispatch must never leave a task in flight');
        AssertTask(SentTask, "NPR Spfy Task State"::Completed, 1, 'A task whose outcome was recorded before the interruption must stay completed');
        AssertTask(StrandedTask, "NPR Spfy Task State"::Pending, 1, 'A claimed task without an outcome must be swept back to Pending');
        AssertTask(UntouchedTask, "NPR Spfy Task State"::Pending, 0, 'A task never claimed must keep its attempts');
        _Assert.AreEqual(FailureText, ResponseText(StrandedTask), 'The swept task must record the interruption');
    end;

    [Test]
    procedure DeadSessionClaimReclaimed()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A claim held by a session that no longer exists is released for another attempt, without sending and without spending one.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime + Hours(1), AtDateTime);

        // [GIVEN] The task is claimed by a session that no longer exists.
        SetClaimRaw(TaskEntryNo, 999999, 999999, AtDateTime, 1);

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The claim is released for another attempt without spending one.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A claim held by a dead session must be released');
        _Assert.AreEqual(_ReclaimedLbl, ResponseText(TaskEntryNo), 'A reclaimed task must record why it was released');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'Reclaiming must not send the task');
    end;

    [Test]
    procedure ReclaimAtCapQuarantines()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A dead claim on a task with no attempts left quarantines it and records that its attempts are exhausted.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime + Hours(1), AtDateTime);

        // [GIVEN] A dead claim on a task that has already used its last attempt.
        SetClaimRaw(TaskEntryNo, 999999, 999999, AtDateTime, 3);

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A dead claim on the last attempt must quarantine the task');
        _Assert.AreEqual(_ReclaimedQuarantinedLbl, ResponseText(TaskEntryNo), 'A quarantined reclaim must record that its attempts are exhausted');
    end;

    [Test]
    procedure InsertPlusDeleteNotCollapsed()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        InsertTask: BigInteger;
        DeleteTask: BigInteger;
    begin
        // [SCENARIO] An insert and a delete of the same entity stay separate tasks and both reach the send boundary, in that order.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");

        // [GIVEN] The same variant is created and then removed before either update is sent.
        InsertTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Insert, AtDateTime);
        DeleteTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);
        _Assert.AreNotEqual(InsertTask, DeleteTask, 'An insert and a delete of the same entity must be separate tasks');

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Both reach Shopify: the delete never swallows the insert.
        _Assert.AreEqual(2, _BndMock.LastDispatchRowCount(), 'Both the insert and the delete must be handed to the send boundary');
        _Assert.AreEqual(InsertTask, _BndMock.DispatchedEntryNo(1), 'The insert must be sent before the delete');
        _Assert.AreEqual(DeleteTask, _BndMock.DispatchedEntryNo(2), 'The delete must be sent after the insert');
        AssertTask(InsertTask, "NPR Spfy Task State"::Completed, 1, 'The insert must be sent');
        AssertTask(DeleteTask, "NPR Spfy Task State"::Completed, 1, 'The delete must be sent');
    end;

    [Test]
    procedure BatchOfOneDispatches()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A group of a single task is still dispatched, as a temporary work list of one row.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] A single variant is the whole group.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A group of one must still be dispatched');
        _Assert.IsTrue(_BndMock.LastDispatchWasTemporary(), 'A group of one must still travel as a temporary work list');
        _Assert.AreEqual(1, _BndMock.LastDispatchRowCount(), 'A group of one must carry exactly one row');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A group of one must complete');
    end;

    [Test]
    procedure GivenAReclaimedTask_WhenTheZombieSessionReportsSuccess_ThenTheOutcomeIsDiscarded()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Neither a success nor a failure reported by a session that lost the claim overwrites the work of the session holding it.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The task must be claimable');

        // [GIVEN] Another session re-claimed the task while this one was still in flight.
        SetClaimRaw(TaskEntryNo, 999998, 999998, AtDateTime, 1);

        // [WHEN] The original session hands back a success.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.CompleteSingle(SpfyTask, true, '');

        // [THEN] The claim holder's work is not overwritten.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::"In Flight", 1, 'A zombie session must not complete a task another session re-claimed');

        // [WHEN] The original session hands back a failure instead.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.CompleteSingle(SpfyTask, false, 'zombie failure');

        // [THEN] The failure is discarded too: no attempt is spent and the claim stands.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::"In Flight", 1, 'A zombie session must not fail a task another session re-claimed');
    end;

    [Test]
    procedure GivenAReclaimedBatchTask_WhenTheZombieSessionReportsOutcome_ThenItIsRefused()
    var
        CompletedTask: Record "NPR Spfy Task";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ResponseJson: JsonToken;
    begin
        // [SCENARIO] A batch outcome from a session that no longer holds the claim is refused and leaves the task untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimForBatch(SpfyTask), 'The task must be claimable for a batch');

        // [GIVEN] Another session re-claimed the row.
        SetClaimRaw(TaskEntryNo, 999998, 999998, AtDateTime, 1);

        // [WHEN] The original session hands the batch outcome back.
        ResponseJson.ReadFrom('{"' + Item."No." + '":"ok"}');

        // [THEN] It is refused outright, so the caller can tell the outcome was not recorded.
        _Assert.IsFalse(
            _SpfyTaskQueue.CompleteFromBatch(TaskEntryNo, ResponseJson, true, '', CompletedTask),
            'A batch outcome from a session that no longer holds the claim must be refused');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::"In Flight", 1, 'A refused batch outcome must leave the task untouched');
    end;
    #endregion

    #region Retry
    [Test]
    procedure FailedTaskRetriesNextCycle()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        FailureText: Text;
    begin
        // [SCENARIO] A failed task stays Pending with the error recorded and is attempted again on the next cycle.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'Shopify rejected the update';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, FailureText);

        // [WHEN] The send fails on the first cycle.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A failed task must stay Pending for another attempt');
        _Assert.AreEqual(FailureText, ResponseText(TaskEntryNo), 'A failed task must record the error');

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A failed task must be retried on the next cycle');
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'The retry must reach the send boundary again');
    end;

    [Test]
    procedure ThirdFailureQuarantinesWithAlert()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        FailureText: Text;
    begin
        // [SCENARIO] The third failure quarantines the task with its last error visible, and later cycles never select it again.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'Shopify rejected the update';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, FailureText);

        // [WHEN] The send fails three times.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A task must still be retryable after two failures');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));

        // [THEN] The third failure quarantines it, with the error visible, and later cycles leave it alone.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the task');
        _Assert.AreEqual(FailureText, ResponseText(TaskEntryNo), 'A quarantined task must keep the last error visible');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(30));
        _Assert.AreEqual(3, _BndMock.DispatchCount(), 'A quarantined task must not be selected again');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A quarantined task must stay quarantined');
    end;

    [Test]
    procedure RequeueGrantsFreshAttempts()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A requeued quarantined task is sent again on a fresh attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, 'Shopify rejected the update');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The task must be quarantined before it is requeued');

        // [GIVEN] The cause is resolved and the task is requeued.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.Requeue(SpfyTask);
        _BndMock.QueueOutcome(TaskEntryNo, true, '');

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(30));

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A requeued task must be sent again on a fresh attempt');
    end;

    [Test]
    procedure OneFailureDoesNotBlockOthers()
    var
        FailingItem: Record Item;
        FirstItem: Record Item;
        LastItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FailingTask: BigInteger;
        FirstTask: BigInteger;
        LastTask: BigInteger;
    begin
        // [SCENARIO] A failing task stays retryable while the tasks before and after it in the cycle are still sent.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, FirstItem, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, FailingItem, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, LastItem, SpfyStoreItemLink);
        FirstTask := EnqueueItemTask(StoreCode, FirstItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        FailingTask := EnqueueItemTask(StoreCode, FailingItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        LastTask := EnqueueItemTask(StoreCode, LastItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(FailingTask, false, 'Shopify rejected the update');

        // [WHEN] The middle task of the cycle fails.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        AssertTask(FirstTask, "NPR Spfy Task State"::Completed, 1, 'A task before the failing one must be sent');
        AssertTask(FailingTask, "NPR Spfy Task State"::Pending, 1, 'The failing task must stay retryable');
        AssertTask(LastTask, "NPR Spfy Task State"::Completed, 1, 'A failure must not stop the tasks after it');
        _Assert.AreEqual(3, _BndMock.DispatchCount(), 'Every task of the cycle must be attempted');
    end;

    [Test]
    procedure OutcomesDurableMidRunCrash()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        VariantIndex: Integer;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] Outcomes recorded before a mid-run interruption survive it, the interrupted task is retried on the next cycle and the tasks never reached keep their attempts.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        for VariantIndex := 1 to 10 do begin
            _Lib.CreateItemVariant(ItemVariant, Item."No.");
            TaskEntryNos.Add(EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime));
        end;

        // [GIVEN] The run is interrupted while sending the seventh task.
        _BndMock.SetThrowMidBatch(7, 'The session was interrupted');

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The outcomes recorded before the interruption survive it.
        for VariantIndex := 1 to 6 do
            AssertTask(TaskEntryNos.Get(VariantIndex), "NPR Spfy Task State"::Completed, 1, StrSubstNo('Task %1 was completed before the interruption and must stay completed', VariantIndex));
        AssertTask(TaskEntryNos.Get(7), "NPR Spfy Task State"::Pending, 1, 'The interrupted task must be recovered as retryable');
        for VariantIndex := 8 to 10 do
            AssertTask(TaskEntryNos.Get(VariantIndex), "NPR Spfy Task State"::Pending, 0, StrSubstNo('Task %1 was never reached and must keep its attempts', VariantIndex));

        // [WHEN] The next cycle runs without the interruption.
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));

        for VariantIndex := 1 to 10 do
            if VariantIndex = 7 then
                AssertTask(TaskEntryNos.Get(7), "NPR Spfy Task State"::Completed, 2, 'The interrupted task must complete on a second attempt')
            else
                AssertTask(TaskEntryNos.Get(VariantIndex), "NPR Spfy Task State"::Completed, 1, StrSubstNo('Task %1 must be completed after the recovery cycle, on a single attempt', VariantIndex));
    end;

    [Test]
    procedure QuarantinedEntityNewChangeGetsFreshTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        QuarantinedTask: BigInteger;
        FreshTask: BigInteger;
    begin
        // [SCENARIO] A new change to a quarantined entity gets its own fresh task that is sent, leaving the quarantined one untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        QuarantinedTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(QuarantinedTask, false, 'Shopify rejected the update');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        AssertTask(QuarantinedTask, "NPR Spfy Task State"::Quarantined, 3, 'The task must be quarantined before the entity changes again');

        // [WHEN] The same entity changes again and the next cycle runs.
        FreshTask := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime + Minutes(25));
        _Assert.AreNotEqual(QuarantinedTask, FreshTask, 'A new change must not be absorbed by the quarantined task');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(30));

        AssertTask(FreshTask, "NPR Spfy Task State"::Completed, 1, 'The new change must be sent on its own fresh task');
        AssertTask(QuarantinedTask, "NPR Spfy Task State"::Quarantined, 3, 'The quarantined task must be left untouched');
    end;

    [Test]
    procedure RequeuedAfterSourceDeletedCompletesNoLongerApplicable()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        DispatchesBeforeRequeue: Integer;
    begin
        // [SCENARIO] A requeued task whose source record is gone is closed as no longer applicable instead of being sent.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, 'Shopify rejected the update');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The task must be quarantined before it is requeued');
        DispatchesBeforeRequeue := _BndMock.DispatchCount();

        // [GIVEN] The source record is gone by the time somebody requeues the task.
        Item.Delete(false);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.Requeue(SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A requeued task must be Pending with fresh attempts');

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(30));

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A requeued task whose source is gone must be closed as no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'The closed task must record why it is no longer applicable');
        _Assert.AreEqual(DispatchesBeforeRequeue, _BndMock.DispatchCount(), 'A requeued task whose source is gone must not be sent');
    end;

    [Test]
    procedure ResendEligibleAgainAndSentOnce()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A completed task asked for again becomes eligible with fresh attempts and is sent exactly one more time.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The task must be sent before it can be sent again');

        // [GIVEN] An operator asks for the completed task to be sent again.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.Resend(SpfyTask);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A resent task must be eligible again with fresh attempts');

        // [WHEN] It is processed manually.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask);

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A resent task must complete again');
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'A resend must send the update exactly one more time');
    end;
    #endregion

    #region Manual
    [Test]
    procedure ManualProcessClaimOrSkip()
    var
        ClaimedItem: Record Item;
        PendingItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ClaimedTask: BigInteger;
        PendingTask: BigInteger;
    begin
        // [SCENARIO] Processing now sends an unclaimed task and leaves a task another session already claimed in flight.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, ClaimedItem, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, PendingItem, SpfyStoreItemLink);
        ClaimedTask := EnqueueItemTask(StoreCode, ClaimedItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        PendingTask := EnqueueItemTask(StoreCode, PendingItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [GIVEN] A processing cycle already claimed the first task.
        GetTask(ClaimedTask, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The claim must succeed on a pending task');

        // [WHEN] The operator asks for both to be processed now.
        GetTask(ClaimedTask, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask);
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A task already claimed elsewhere must not be sent again');
        AssertTask(ClaimedTask, "NPR Spfy Task State"::"In Flight", 1, 'A task already claimed elsewhere must be left in flight');

        GetTask(PendingTask, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask);

        AssertTask(PendingTask, "NPR Spfy Task State"::Completed, 1, 'A pending task must be sent when processed manually');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'Only the unclaimed task may reach the send boundary');
    end;

    [Test]
    procedure TwoSessionsCannotDoubleSend()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A task claimed by a live session is neither stolen nor sent a second time, and cannot be claimed again as a single or for a batch.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);
        TaskEntryNo := EnqueueItemTask(StoreCode, Item, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [GIVEN] A live session is already sending the task.
        SetClaimRaw(TaskEntryNo, ServiceInstanceId(), SessionId(), AtDateTime, 1);

        // [WHEN] A second cycle runs over the same store.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The second session neither steals nor re-sends it.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::"In Flight", 1, 'A task claimed by a live session must stay in flight');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A task claimed by another session must not be sent a second time');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsFalse(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'An in-flight task must not be claimable as a single');
        Clear(SpfyTask);
        SpfyTask."Entry No." := TaskEntryNo;
        _Assert.IsFalse(_SpfyTaskQueue.ClaimForBatch(SpfyTask), 'An in-flight task must not be claimable for a batch');
    end;

    [Test]
    procedure HungLiveSessionClaimIsReclaimedBeyondCeiling()
    var
        BlankStampItem: Record Item;
        HungItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        BlankStampTask: BigInteger;
        HungTask: BigInteger;
    begin
        // [SCENARIO] A live session's claim held beyond the reclaim ceiling, or carrying no claim stamp at all, is released for another attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, HungItem, SpfyStoreItemLink);
        CreateSyncedItem(StoreCode, true, BlankStampItem, SpfyStoreItemLink);
        HungTask := EnqueueItemTask(StoreCode, HungItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);
        BlankStampTask := EnqueueItemTask(StoreCode, BlankStampItem, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime);

        // [GIVEN] The claiming session is still alive but has been holding the claim beyond the reclaim ceiling.
        SetClaimRaw(HungTask, ServiceInstanceId(), SessionId(), AtDateTime - (3 * 60 * 60 * 1000), 1);

        // [WHEN] A cycle checks the claim.
        GetTask(HungTask, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ReclaimDeadClaim(SpfyTask, AtDateTime), 'A live-session claim held beyond the ceiling must be reclaimed');

        // [THEN] The claim is released for another attempt.
        AssertTask(HungTask, "NPR Spfy Task State"::Pending, 1, 'A reclaimed hung task must be released for another attempt');
        GetTask(HungTask, SpfyTask);
        _Assert.IsTrue(SpfyTask."Claimed At" = 0DT, 'A reclaimed hung task must have its claim stamp cleared');
        _Assert.AreEqual(0, SpfyTask."Claimed By Session", 'A reclaimed hung task must have its claiming session cleared');

        // [GIVEN] A raw claim by a live session that never got a claim stamp.
        SetClaimRaw(BlankStampTask, ServiceInstanceId(), SessionId(), 0DT, 1);

        // [WHEN] A cycle checks that claim. [THEN] The blank stamp counts as beyond the ceiling.
        GetTask(BlankStampTask, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ReclaimDeadClaim(SpfyTask, AtDateTime), 'A live-session claim without a claim stamp must be reclaimed');
        AssertTask(BlankStampTask, "NPR Spfy Task State"::Pending, 1, 'A reclaimed stampless task must be released for another attempt');
    end;

    [Test]
    procedure ResidualGuardRecreatesLegacyStraggler()
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ActionableNcEntryNo: BigInteger;
        DeadNcEntryNo: BigInteger;
    begin
        // [SCENARIO] A legacy row written after the migration is re-created in the task list and closed, unless its attempts are already exhausted.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItem(StoreCode, true, Item, SpfyStoreItemLink);

        // [GIVEN] Something wrote to the legacy queue after the migration completed.
        ActionableNcEntryNo := SeedLegacyTask(StoreCode, Item, 0);
        DeadNcEntryNo := SeedLegacyTask(StoreCode, Item, 3);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The actionable legacy row is re-created in the new queue and closed in the old one.
        SpfyTask.SetRange("Migrated From NC Entry No.", ActionableNcEntryNo);
        _Assert.IsTrue(SpfyTask.FindFirst(), 'An actionable legacy task must be re-created in the Shopify task list');
        AssertTask(SpfyTask."Entry No.", "NPR Spfy Task State"::Completed, 1, 'The re-created task must be processed by the same cycle');
        NcTask.Get(ActionableNcEntryNo);
        _Assert.IsTrue(NcTask.Processed, 'The legacy row must be closed once it has been re-created');

        // [THEN] A legacy row that already used up its attempts is left alone.
        NcTask.Get(DeadNcEntryNo);
        _Assert.IsFalse(NcTask.Processed, 'A legacy row with no attempts left must be left untouched');
        SpfyTask.SetRange("Migrated From NC Entry No.", DeadNcEntryNo);
        _Assert.IsTrue(SpfyTask.IsEmpty(), 'A legacy row with no attempts left must not be re-created');
    end;

    local procedure SeedLegacyTask(StoreCode: Code[20]; Item: Record Item; ProcessCount: Integer): BigInteger
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(true);
        NcTask.Type := NcTask.Type::Modify;
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := Database::Item;
        NcTask."Record ID" := Item.RecordId();
        NcTask."Record Value" := Item."No.";
        NcTask."Store Code" := StoreCode;
        NcTask."Log Date" := CurrentDateTime();
        NcTask."Process Count" := ProcessCount;
        NcTask.Insert(true);
        exit(NcTask."Entry No.");
    end;
    #endregion
}
