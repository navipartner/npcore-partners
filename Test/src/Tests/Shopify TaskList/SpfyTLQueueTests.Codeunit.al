codeunit 85310 "NPR Spfy TL Queue Tests"
{
    // [FEATURE] Shopify Task List - queue facade: enqueue/dedup contract, cancel, requeue, resend (real rows)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _DuplicateTaskLbl: Label 'This task is a duplicate of another task (Entry No. %1). The requested update will be handled there.', Locked = true;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        ClearRunContext();
    end;

    local procedure ClearRunContext()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearSendBoundary();
    end;

    local procedure EnqueueItem(StoreCode: Code[20]; Item: Record Item; TaskType: Enum "NPR Spfy Task Op"; LogDateTime: DateTime; NotBeforeDateTime: DateTime; ReuseExistingDelayed: Enum "NPR Spfy Reuse Delayed NC Task"; AtDateTime: DateTime; var SpfyTask: Record "NPR Spfy Task"): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        exit(_SpfyTaskQueue.Enqueue(StoreCode, RecRef, Item.RecordId(), Item."No.", TaskType, LogDateTime, NotBeforeDateTime, ReuseExistingDelayed, AtDateTime, SpfyTask));
    end;

    local procedure EnqueueItemAny(StoreCode: Code[20]; Item: Record Item; TaskType: Enum "NPR Spfy Task Op"; AtDateTime: DateTime; var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        exit(EnqueueItem(StoreCode, Item, TaskType, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask));
    end;

    local procedure TaskCountForItem(ItemNo: Code[20]): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", Database::Item);
        SpfyTask.SetRange("Record Value", ItemNo);
        exit(SpfyTask.Count());
    end;

    local procedure SetState(EntryNo: BigInteger; NewState: Enum "NPR Spfy Task State"; NewAttempts: Integer)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.State := NewState;
        SpfyTask.Attempts := NewAttempts;
        SpfyTask.Modify(false);
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

    local procedure DataOutputText(EntryNo: BigInteger): Text
    var
        SpfyTask: Record "NPR Spfy Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.CalcFields("Data Output");
        if not SpfyTask."Data Output".HasValue() then
            exit('');
        SpfyTask."Data Output".CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    local procedure Hours(HourCount: Integer): Duration
    begin
        exit(HourCount * 60 * 60 * 1000);
    end;

    local procedure Seconds(SecondCount: Integer): Duration
    begin
        exit(SecondCount * 1000);
    end;

    local procedure LookbackAnchor(): DateTime
    begin
        // Half past midnight: the dedup lookback floor is midnight of the previous calendar day, so a 25 h old row lies outside it on any date.
        exit(CreateDateTime(DT2Date(CurrentDateTime()), 003000T));
    end;

    local procedure LookbackFloor(AtDateTime: DateTime): DateTime
    begin
        exit(CreateDateTime(DT2Date(AtDateTime) - 1, 0T));
    end;

    #region Enqueue and dedup
    [Test]
    procedure EnqueueCreatesOnePendingRowPerStore()
    var
        Item: Record Item;
        SpfyTaskA: Record "NPR Spfy Task";
        SpfyTaskB: Record "NPR Spfy Task";
        StoreA: Code[20];
        StoreB: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] Enqueuing one entity for two stores creates one independent Pending row per store carrying identifiers only, with no payload, claim, waiting or completion state.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);

        // [WHEN] The same entity is enqueued for two stores.
        _Assert.IsTrue(EnqueueItemAny(StoreA, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTaskA), 'The first store must create a task');
        _Assert.IsTrue(EnqueueItemAny(StoreB, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTaskB), 'The second store must create its own task');

        // [THEN] One independent Pending row per store, carrying identifiers only.
        _Assert.AreEqual(2, TaskCountForItem(Item."No."), 'One task per store must exist for the entity');
        _Assert.IsTrue(SpfyTaskA."Entry No." <> SpfyTaskB."Entry No.", 'Each store must get its own task row');
        SpfyTaskA.Get(SpfyTaskA."Entry No.");
        _Assert.IsTrue(SpfyTaskA.State = SpfyTaskA.State::Pending, 'A new task must be Pending');
        _Assert.AreEqual(StoreA, SpfyTaskA."Store Code", 'The task must carry the store it was enqueued for');
        _Assert.AreEqual(Database::Item, SpfyTaskA."Table No.", 'The task must carry the source table');
        _Assert.AreEqual(Item."No.", SpfyTaskA."Record Value", 'The task must carry the record value');
        _Assert.AreEqual(Item.RecordId(), SpfyTaskA."Record ID", 'The task must carry the source Record ID');
        _Assert.AreEqual(AtDateTime, SpfyTaskA."Log Date", 'The log date must be the enqueue time passed in');
        _Assert.AreEqual(0, SpfyTaskA.Attempts, 'A new task must have no attempts');
        _Assert.IsFalse(IsNullGuid(SpfyTaskA."Dispatch Id"), 'A new task must get a dispatch id');
        _Assert.AreEqual(0DT, SpfyTaskA."Not Before Date-Time", 'A new undelayed task must have no not-before time');
        _Assert.AreEqual(0DT, SpfyTaskA."Claimed At", 'A new task must not be claimed');
        _Assert.AreEqual(0DT, SpfyTaskA."Waiting Since", 'A new task must not be waiting');
        _Assert.AreEqual(0DT, SpfyTaskA."Completed At", 'A new task must not be completed');
        SpfyTaskA.CalcFields(Response, "Data Output");
        _Assert.IsFalse(SpfyTaskA.Response.HasValue(), 'A new task must carry no response payload');
        _Assert.IsFalse(SpfyTaskA."Data Output".HasValue(), 'A new task must carry no request payload');
    end;

    [Test]
    procedure PendingInsertAbsorbsModify()
    var
        Item: Record Item;
        InsertTask: Record "NPR Spfy Task";
        ModifyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A modify for an entity that still has an unsent insert is absorbed by that insert, which is handed back to the caller.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        _Assert.IsTrue(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Insert, AtDateTime, InsertTask), 'The insert must create a task');

        // [WHEN] A modify arrives for an entity that still has an unsent insert.
        _Assert.IsFalse(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, ModifyTask), 'The modify must be absorbed, not create a task');

        // [THEN] The pending insert still owns the update and is handed back to the caller.
        _Assert.AreEqual(1, TaskCountForItem(Item."No."), 'A pending insert must absorb the modify');
        _Assert.IsTrue(ModifyTask."Entry No." = InsertTask."Entry No.", 'The absorbed call must return the reused task');
        _Assert.IsTrue(ModifyTask.Type = ModifyTask.Type::Insert, 'The reused task must stay an insert');
    end;

    [Test]
    procedure PendingModifyAbsorbsModify()
    var
        Item: Record Item;
        FirstTask: Record "NPR Spfy Task";
        SecondTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] Repeated modifies for the same unsent entity collapse into the one task that is handed back to the caller.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        _Assert.IsTrue(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, FirstTask), 'The first modify must create a task');

        // [WHEN] A second modify arrives for the same unsent entity.
        _Assert.IsFalse(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SecondTask), 'The second modify must be absorbed');

        _Assert.AreEqual(1, TaskCountForItem(Item."No."), 'Repeated modifies must collapse into one task');
        _Assert.IsTrue(SecondTask."Entry No." = FirstTask."Entry No.", 'The absorbed call must return the reused task');
    end;

    [Test]
    procedure DeleteNeverMerges()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A delete and a modify for the same entity never absorb each other and both survive as separate tasks.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(ItemA);
        _Lib.CreateItem(ItemB);

        // [WHEN] A delete follows a pending modify for the same entity.
        EnqueueItemAny(StoreCode, ItemA, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItemAny(StoreCode, ItemA, "NPR Spfy Task Op"::Delete, AtDateTime, SpfyTask), 'A delete must never be absorbed by a pending modify');
        _Assert.AreEqual(2, TaskCountForItem(ItemA."No."), 'The modify and the delete must both survive as separate tasks');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Delete, 'The new task must be the delete');

        // [WHEN] A modify follows a pending delete for the same entity.
        EnqueueItemAny(StoreCode, ItemB, "NPR Spfy Task Op"::Delete, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItemAny(StoreCode, ItemB, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask), 'A modify must never be absorbed by a pending delete');
        _Assert.AreEqual(2, TaskCountForItem(ItemB."No."), 'The delete and the modify must both survive as separate tasks');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, 'The new task must be the modify');
    end;

    [Test]
    procedure ReuseExactMatchesOnlyIdenticalNotBefore()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstStart: DateTime;
        SecondStart: DateTime;
    begin
        // [SCENARIO] Under exact reuse only an identical start time is absorbed, while a different one gets its own task.
        Initialize();
        AtDateTime := CurrentDateTime();
        FirstStart := AtDateTime + Hours(1);
        SecondStart := AtDateTime + Hours(2);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(ItemA);
        _Lib.CreateItem(ItemB);

        // [WHEN] Two updates for the same entity are scheduled for different times.
        EnqueueItem(StoreCode, ItemA, "NPR Spfy Task Op"::Modify, 0DT, FirstStart, "NPR Spfy Reuse Delayed NC Task"::No, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItem(StoreCode, ItemA, "NPR Spfy Task Op"::Modify, 0DT, SecondStart, "NPR Spfy Reuse Delayed NC Task"::No, AtDateTime, SpfyTask), 'A different not-before time must create its own task under exact reuse');
        _Assert.AreEqual(2, TaskCountForItem(ItemA."No."), 'Two distinct start times must produce two tasks');

        // [WHEN] The identical not-before time is requested twice.
        EnqueueItem(StoreCode, ItemB, "NPR Spfy Task Op"::Modify, 0DT, FirstStart, "NPR Spfy Reuse Delayed NC Task"::No, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemB, "NPR Spfy Task Op"::Modify, 0DT, FirstStart, "NPR Spfy Reuse Delayed NC Task"::No, AtDateTime, SpfyTask), 'An identical not-before time must be absorbed under exact reuse');
        _Assert.AreEqual(1, TaskCountForItem(ItemB."No."), 'An identical start time must reuse the existing task');
    end;

    [Test]
    procedure ReuseLaterMergesIntoLaterOrEqual()
    var
        ItemEarlier: Record Item;
        ItemEqual: Record Item;
        ItemLater: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ExistingStart: DateTime;
    begin
        // [SCENARIO] Under later reuse a queued task absorbs a request due at or before its own start time, and a request due after it gets its own task.
        Initialize();
        AtDateTime := CurrentDateTime();
        ExistingStart := AtDateTime + Hours(2);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(ItemEarlier);
        _Lib.CreateItem(ItemEqual);
        _Lib.CreateItem(ItemLater);

        // [WHEN] The new request is due before the queued one.
        EnqueueItem(StoreCode, ItemEarlier, "NPR Spfy Task Op"::Modify, 0DT, ExistingStart, "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemEarlier, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime + Hours(1), "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask), 'A task queued for a later time must absorb an earlier request');
        _Assert.AreEqual(1, TaskCountForItem(ItemEarlier."No."), 'The later-scheduled task must be reused');

        // [WHEN] The new request is due at exactly the queued time.
        EnqueueItem(StoreCode, ItemEqual, "NPR Spfy Task Op"::Modify, 0DT, ExistingStart, "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemEqual, "NPR Spfy Task Op"::Modify, 0DT, ExistingStart, "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask), 'An equal not-before time must be absorbed');
        _Assert.AreEqual(1, TaskCountForItem(ItemEqual."No."), 'An equally scheduled task must be reused');

        // [WHEN] The new request is due after the queued one.
        EnqueueItem(StoreCode, ItemLater, "NPR Spfy Task Op"::Modify, 0DT, ExistingStart, "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItem(StoreCode, ItemLater, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime + Hours(3), "NPR Spfy Reuse Delayed NC Task"::Later, AtDateTime, SpfyTask), 'An earlier-scheduled task must not absorb a later request');
        _Assert.AreEqual(2, TaskCountForItem(ItemLater."No."), 'A request due after the queued task must get its own task');
    end;

    [Test]
    procedure ReuseAnyIgnoresNotBefore()
    var
        ItemA: Record Item;
        ItemB: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] Under any reuse the queued task is reused whatever either start time is.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(ItemA);
        _Lib.CreateItem(ItemB);

        // [WHEN] An immediate request meets a delayed queued task.
        EnqueueItem(StoreCode, ItemA, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime + Hours(2), "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemA, "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask), 'Any-reuse must absorb regardless of the queued not-before time');
        _Assert.AreEqual(1, TaskCountForItem(ItemA."No."), 'Any-reuse must reuse the delayed task');

        // [WHEN] A delayed request meets an immediate queued task.
        EnqueueItem(StoreCode, ItemB, "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemB, "NPR Spfy Task Op"::Modify, 0DT, AtDateTime + Hours(2), "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask), 'Any-reuse must absorb a delayed request into an undelayed task');
        _Assert.AreEqual(1, TaskCountForItem(ItemB."No."), 'Any-reuse must reuse the undelayed task');
    end;

    [Test]
    procedure LookbackOlderThanOneDayCreatesNewTask()
    var
        ItemOld: Record Item;
        ItemAtFloor: Record Item;
        ItemBelowFloor: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A queued task logged exactly at the lookback floor is reused, while one logged before it is left alone and a fresh task is created.
        Initialize();
        AtDateTime := LookbackAnchor();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(ItemOld);
        _Lib.CreateItem(ItemAtFloor);
        _Lib.CreateItem(ItemBelowFloor);

        // [WHEN] The queued task was logged 25 hours ago, outside the one-day lookback.
        EnqueueItem(StoreCode, ItemOld, "NPR Spfy Task Op"::Modify, AtDateTime - Hours(25), 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItem(StoreCode, ItemOld, "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask), 'A task older than the lookback must not be reused');
        _Assert.AreEqual(2, TaskCountForItem(ItemOld."No."), 'A stale task must be left alone and a fresh one created');

        // [WHEN] The queued task was logged exactly at the lookback floor.
        EnqueueItem(StoreCode, ItemAtFloor, "NPR Spfy Task Op"::Modify, LookbackFloor(AtDateTime), 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        _Assert.IsFalse(EnqueueItem(StoreCode, ItemAtFloor, "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask), 'A task logged exactly at the lookback floor must still be reused');
        _Assert.AreEqual(1, TaskCountForItem(ItemAtFloor."No."), 'A task at the lookback floor must be reused');

        // [WHEN] The queued task was logged one second before the lookback floor.
        EnqueueItem(StoreCode, ItemBelowFloor, "NPR Spfy Task Op"::Modify, LookbackFloor(AtDateTime) - Seconds(1), 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        _Assert.IsTrue(EnqueueItem(StoreCode, ItemBelowFloor, "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask), 'A task logged before the lookback floor must not be reused');
        _Assert.AreEqual(2, TaskCountForItem(ItemBelowFloor."No."), 'A task just below the lookback floor must not be reused');
    end;

    [Test]
    procedure WaitingTaskAbsorbsNewRequest()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        WaitingTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A deferred task absorbs a new request for the same entity and stays waiting.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, WaitingTask);
        _SpfyTaskQueue.SetWaiting(WaitingTask, 'Awaiting parent product sync', AtDateTime);
        _Assert.IsTrue(WaitingTask.State = WaitingTask.State::Waiting, 'The task must be waiting before the new request');

        // [WHEN] A new request arrives for an entity whose task is deferred.
        _Assert.IsFalse(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask), 'A waiting task must absorb the new request');
        _Assert.AreEqual(1, TaskCountForItem(Item."No."), 'A waiting task must not be duplicated');
        _Assert.IsTrue(SpfyTask."Entry No." = WaitingTask."Entry No.", 'The absorbed call must return the waiting task');
        SpfyTask.Get(SpfyTask."Entry No.");
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Waiting, 'The reused task must stay waiting');
    end;

    [Test]
    procedure QuarantinedTaskNeverAbsorbs()
    var
        Item: Record Item;
        QuarantinedTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A quarantined task never absorbs a new request: a fresh Pending task is created beside it and it is left untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, QuarantinedTask);
        SetState(QuarantinedTask."Entry No.", "NPR Spfy Task State"::Quarantined, 3);

        // [WHEN] The entity changes again while its previous update is quarantined.
        _Assert.IsTrue(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask), 'A quarantined task must never absorb a new request');
        _Assert.AreEqual(2, TaskCountForItem(Item."No."), 'A fresh task must be created beside the quarantined one');
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'The new task must be Pending');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'The new task must start with no attempts');
        QuarantinedTask.Get(QuarantinedTask."Entry No.");
        _Assert.IsTrue(QuarantinedTask.State = QuarantinedTask.State::Quarantined, 'The quarantined task must be left untouched');
    end;

    [Test]
    procedure InFlightTaskNeverAbsorbs()
    var
        Item: Record Item;
        InFlightTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A task being sent never absorbs a new request: the change gets its own task and the in-flight one is left untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, InFlightTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(InFlightTask), 'The claim must succeed on a pending task');
        _Assert.IsTrue(InFlightTask.State = InFlightTask.State::"In Flight", 'The claimed task must be in flight');

        // [WHEN] The entity changes again while its update is being sent.
        _Assert.IsTrue(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask), 'An in-flight task must never absorb a new request');
        _Assert.AreEqual(2, TaskCountForItem(Item."No."), 'A change during a send must get its own task');
        InFlightTask.Get(InFlightTask."Entry No.");
        _Assert.IsTrue(InFlightTask.State = InFlightTask.State::"In Flight", 'The in-flight task must be left untouched');
    end;
    #endregion

    #region Cancel
    [Test]
    procedure CancelUnsentCompletesWithReason()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        PendingEntryNo: BigInteger;
        WaitingEntryNo: BigInteger;
        QuarantinedEntryNo: BigInteger;
        CancellationReason: Text;
    begin
        // [SCENARIO] A pending, waiting or quarantined task is cancellable and ends Completed with the reason recorded, the completion stamped and its waiting state cleared.
        Initialize();
        AtDateTime := CurrentDateTime();
        CancellationReason := 'The update is no longer needed';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        PendingEntryNo := SpfyTask."Entry No.";
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        WaitingEntryNo := SpfyTask."Entry No.";
        _SpfyTaskQueue.SetWaiting(SpfyTask, 'Awaiting parent product sync', AtDateTime);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        QuarantinedEntryNo := SpfyTask."Entry No.";
        SetState(QuarantinedEntryNo, "NPR Spfy Task State"::Quarantined, 3);

        // [WHEN] Every unsent state is cancelled with a reason.
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(PendingEntryNo, CancellationReason), 'A pending task must be cancellable');
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(WaitingEntryNo, CancellationReason), 'A waiting task must be cancellable');
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(QuarantinedEntryNo, CancellationReason), 'A quarantined task must be cancellable');

        // [THEN] Each is completed with the reason recorded and its waiting state cleared.
        AssertCancelled(PendingEntryNo, CancellationReason, 'pending');
        AssertCancelled(WaitingEntryNo, CancellationReason, 'waiting');
        AssertCancelled(QuarantinedEntryNo, CancellationReason, 'quarantined');
    end;

    local procedure AssertCancelled(EntryNo: BigInteger; CancellationReason: Text; StateName: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Completed, StrSubstNo('A cancelled %1 task must end Completed', StateName));
        _Assert.AreNotEqual(0DT, SpfyTask."Completed At", StrSubstNo('A cancelled %1 task must be stamped as completed', StateName));
        _Assert.AreEqual(CancellationReason, ResponseText(EntryNo), StrSubstNo('A cancelled %1 task must record the cancellation reason', StateName));
        _Assert.AreEqual(0DT, SpfyTask."Waiting Since", StrSubstNo('A cancelled %1 task must have its waiting state cleared', StateName));
    end;

    [Test]
    procedure CancelSentReturnsFalse()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] An already sent task is not cancellable and gets no cancellation reason.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        SetState(SpfyTask."Entry No.", "NPR Spfy Task State"::Completed, 1);

        // [WHEN] An already sent task is cancelled.
        _Assert.IsFalse(_SpfyTaskQueue.CancelUnsentTask(SpfyTask."Entry No.", 'Too late'), 'A sent task must not be cancellable');
        _Assert.AreEqual('', ResponseText(SpfyTask."Entry No."), 'A sent task must not get a cancellation reason');
    end;

    [Test]
    procedure CancelInFlightReturnsFalse()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A task being sent right now is not cancellable and stays in flight.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        _SpfyTaskQueue.ClaimSingle(SpfyTask);

        // [WHEN] A task that is being sent right now is cancelled.
        _Assert.IsFalse(_SpfyTaskQueue.CancelUnsentTask(SpfyTask."Entry No.", 'Too late'), 'An in-flight task must not be cancellable');
        SpfyTask.Get(SpfyTask."Entry No.");
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::"In Flight", 'An in-flight task must stay in flight');
    end;
    #endregion

    #region Requeue and resend
    [Test]
    procedure RequeueResetsAttempts()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        QuarantinedEntryNo: BigInteger;
        FailedEntryNo: BigInteger;
    begin
        // [SCENARIO] Requeuing a quarantined or failed task makes it Pending with fresh attempts and no claim or waiting state.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        QuarantinedEntryNo := SpfyTask."Entry No.";
        SetState(QuarantinedEntryNo, "NPR Spfy Task State"::Quarantined, 3);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        FailedEntryNo := SpfyTask."Entry No.";
        SetState(FailedEntryNo, "NPR Spfy Task State"::Pending, 2);

        // [WHEN] A quarantined and a failed task are requeued.
        SpfyTask.Get(QuarantinedEntryNo);
        _SpfyTaskQueue.Requeue(SpfyTask);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'A requeued quarantined task must become Pending');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'A requeued quarantined task must get fresh attempts');
        _Assert.AreEqual(0DT, SpfyTask."Claimed At", 'A requeued task must have no claim');
        _Assert.AreEqual(0DT, SpfyTask."Waiting Since", 'A requeued task must have no waiting state');

        SpfyTask.Get(FailedEntryNo);
        _SpfyTaskQueue.Requeue(SpfyTask);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'A requeued failed task must stay Pending');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'A requeued failed task must get fresh attempts');
    end;

    [Test]
    procedure ResendRotatesDispatchIdAndResetsAttempts()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        OriginalDispatchId: Guid;
    begin
        // [SCENARIO] Sending a completed task again makes it Pending with fresh attempts, clears its completion stamp and gives it a new dispatch id.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        OriginalDispatchId := SpfyTask."Dispatch Id";
        SetState(SpfyTask."Entry No.", "NPR Spfy Task State"::Completed, 1);
        SpfyTask.Get(SpfyTask."Entry No.");
        SpfyTask."Completed At" := AtDateTime;
        SpfyTask.Modify(false);

        // [WHEN] The completed task is sent again.
        _SpfyTaskQueue.Resend(SpfyTask);

        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'A resent task must become Pending');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'A resent task must get fresh attempts');
        _Assert.AreEqual(0DT, SpfyTask."Completed At", 'A resent task must clear its completion stamp');
        _Assert.AreNotEqual(OriginalDispatchId, SpfyTask."Dispatch Id", 'A resent task must get a new dispatch id');
        _Assert.IsFalse(IsNullGuid(SpfyTask."Dispatch Id"), 'The new dispatch id must not be empty');
    end;

    [Test]
    procedure GivenAStaleCycleTime_WhenATaskIsClaimedAndCompleted_ThenProcessingStampsAreRealAndDurationNonNegative()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        CycleStart: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] A task claimed and completed under a stale cycle time is stamped with real times, so its processing duration can never be negative.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);

        // [GIVEN] A cycle that started ten minutes ago and a claimed task.
        CycleStart := CurrentDateTime() - 10 * 60 * 1000;
        SpfyTaskRunContext.SetCycleTime(CycleStart);
        _Assert.IsTrue(EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, CycleStart, SpfyTask), 'The task must be enqueued');
        _Assert.IsTrue(SpfyTaskQueue.ClaimSingle(SpfyTask), 'The task must be claimable');

        // [WHEN] The dispatch completes.
        SpfyTaskQueue.CompleteSingle(SpfyTask, true, '');

        // [THEN] The processing stamps are real timestamps, not the stale cycle time, and the duration cannot go negative.
        SpfyTask.Get(SpfyTask."Entry No.");
        _Assert.IsTrue(SpfyTask."Last Processing Started at" > CycleStart, 'The processing start must be stamped with real time, not the cycle time');
        _Assert.IsTrue(SpfyTask."Last Processing Completed at" >= SpfyTask."Last Processing Started at", 'The processing end must not precede the start');
        _Assert.IsTrue(SpfyTask."Last Processing Duration" >= 0, 'The processing duration must never be negative');
        _Assert.IsTrue(SpfyTask."Completed At" > CycleStart, 'The completion stamp must be real time, not the cycle time');
        SpfyTaskRunContext.ClearCycleTime();
    end;
    #endregion

    #region Batch outcome hand-back
    [Test]
    procedure CompleteAsDuplicateCollapsesOntoTheSentTask()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        WorkTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ProcessingStartedAt: DateTime;
        DuplicateEntryNo: BigInteger;
        SentEntryNo: BigInteger;
    begin
        // [SCENARIO] A duplicate is closed pointing at the task that carries the update, counting one attempt and keeping the resolved op and the start time of the pass that handled it, and cannot collapse a second time.
        Initialize();
        AtDateTime := CurrentDateTime();
        ProcessingStartedAt := AtDateTime - Seconds(5);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Insert, AtDateTime, SpfyTask);
        DuplicateEntryNo := SpfyTask."Entry No.";
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        SentEntryNo := SpfyTask."Entry No.";

        // [GIVEN] The work list copy the batch builder carries: it resolved the op to Modify and stamped when the pass began.
        WorkTask.Get(DuplicateEntryNo);
        WorkTask.Type := WorkTask.Type::Modify;
        WorkTask."Last Processing Started at" := ProcessingStartedAt;

        // [WHEN] The same entity is already in the batch under another task.
        _Assert.IsTrue(_SpfyTaskQueue.CompleteAsDuplicate(WorkTask, SentEntryNo), 'A pending task must collapse as a duplicate');

        // [THEN] It is closed pointing at the task that carries the update, with exactly one attempt counted.
        SpfyTask.Get(DuplicateEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Completed, StrSubstNo('A collapsed duplicate must end Completed but was %1', SpfyTask.State));
        _Assert.AreEqual(StrSubstNo(_DuplicateTaskLbl, SentEntryNo), ResponseText(DuplicateEntryNo), 'A collapsed duplicate must document which task carries the update');
        _Assert.AreEqual(1, SpfyTask.Attempts, 'A collapsed duplicate must count exactly one attempt');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, 'The op the batch builder resolved must be written back to the collapsed task');
        _Assert.AreEqual(ProcessingStartedAt, SpfyTask."Last Processing Started at", 'The collapsed task must keep the start time of the pass that handled it');
        _Assert.AreNotEqual(0DT, SpfyTask."Completed At", 'A collapsed duplicate must be stamped as completed');
        _Assert.AreNotEqual(0DT, SpfyTask."Last Processing Completed at", 'A collapsed duplicate must be stamped with its processing end');

        // [WHEN] The same task is offered for collapse again.
        _Assert.IsFalse(_SpfyTaskQueue.CompleteAsDuplicate(WorkTask, SentEntryNo), 'A task that is no longer pending must not collapse again');
        SpfyTask.Get(DuplicateEntryNo);
        _Assert.AreEqual(1, SpfyTask.Attempts, 'A refused collapse must not count another attempt');
    end;

    [Test]
    procedure TransferPrestagedOutcomeCarriesTheCompletedOutcome()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        CarrierTask: Record "NPR Spfy Task";
        RealTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ProcessingStartedAt: DateTime;
        TargetEntryNo: BigInteger;
        PrestagedResponse: Text;
    begin
        // [SCENARIO] A prestaged success transfers onto the real row with its response, resolved op, completion stamps and exactly one attempt, and cannot transfer a second time.
        Initialize();
        AtDateTime := CurrentDateTime();
        ProcessingStartedAt := AtDateTime - Seconds(5);
        PrestagedResponse := 'The variant was already sent while the batch was being built';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Insert, AtDateTime, SpfyTask);
        TargetEntryNo := SpfyTask."Entry No.";

        // [GIVEN] A work list row whose outcome was settled before the batch call, carrying the response, the resolved op and the pass start time.
        BuildPrestagedCarrier(StoreCode, AtDateTime, ProcessingStartedAt, PrestagedResponse, "NPR Spfy Task Op"::Modify, CarrierTask);

        // [WHEN] The prestaged success is handed back to the real row.
        _Assert.IsTrue(_SpfyTaskQueue.TransferPrestagedOutcome(TargetEntryNo, CarrierTask, "NPR Spfy Task State"::Completed, RealTask), 'A prestaged outcome must transfer onto a pending task');

        // [THEN] The real row carries the outcome, the resolved op and one counted attempt.
        _Assert.AreEqual(TargetEntryNo, RealTask."Entry No.", 'The transfer must hand back the real row it wrote');
        SpfyTask.Get(TargetEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Completed, StrSubstNo('A prestaged success must end Completed but was %1', SpfyTask.State));
        _Assert.AreEqual(PrestagedResponse, ResponseText(TargetEntryNo), 'The prestaged response must be transferred to the real row');
        _Assert.AreEqual(1, SpfyTask.Attempts, 'A transferred outcome must count exactly one attempt');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, 'The op the batch builder resolved must be written back to the real row');
        _Assert.AreEqual(ProcessingStartedAt, SpfyTask."Last Processing Started at", 'The real row must keep the start time of the pass that handled it');
        _Assert.AreNotEqual(0DT, SpfyTask."Completed At", 'A transferred success must be stamped as completed');
        _Assert.AreNotEqual(0DT, SpfyTask."Last Processing Completed at", 'A transferred outcome must be stamped with its processing end');

        // [WHEN] The same row is offered the outcome again.
        _Assert.IsFalse(_SpfyTaskQueue.TransferPrestagedOutcome(TargetEntryNo, CarrierTask, "NPR Spfy Task State"::Completed, RealTask), 'A task that is no longer pending must not take a second transfer');
        SpfyTask.Get(TargetEntryNo);
        _Assert.AreEqual(1, SpfyTask.Attempts, 'A refused transfer must not count another attempt');
    end;

    [Test]
    procedure TransferPrestagedOutcomeCarriesTheFailedOutcome()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        CarrierTask: Record "NPR Spfy Task";
        RealTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ProcessingStartedAt: DateTime;
        TargetEntryNo: BigInteger;
        PrestagedError: Text;
    begin
        // [SCENARIO] A prestaged failure transfers onto the real row with its error and resolved op, counts one attempt, releases the claim and leaves the task retryable.
        Initialize();
        AtDateTime := CurrentDateTime();
        ProcessingStartedAt := AtDateTime - Seconds(5);
        PrestagedError := 'The variant could not be prepared for the bulk call';
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Insert, AtDateTime, SpfyTask);
        TargetEntryNo := SpfyTask."Entry No.";

        // [GIVEN] A work list row that failed before the batch call, so its prestaged state is not Completed.
        BuildPrestagedCarrier(StoreCode, AtDateTime, ProcessingStartedAt, PrestagedError, "NPR Spfy Task Op"::Modify, CarrierTask);

        // [WHEN] The prestaged failure is handed back to the real row.
        _Assert.IsTrue(_SpfyTaskQueue.TransferPrestagedOutcome(TargetEntryNo, CarrierTask, "NPR Spfy Task State"::Pending, RealTask), 'A prestaged failure must transfer onto a pending task');

        // [THEN] The real row records the error and stays retryable rather than being closed.
        SpfyTask.Get(TargetEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, StrSubstNo('A prestaged failure must leave the task retryable but it was %1', SpfyTask.State));
        _Assert.AreEqual(PrestagedError, ResponseText(TargetEntryNo), 'The prestaged error must be transferred to the real row');
        _Assert.AreEqual(1, SpfyTask.Attempts, 'A transferred failure must count exactly one attempt');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, 'The op the batch builder resolved must be written back even on a failure');
        _Assert.AreEqual(ProcessingStartedAt, SpfyTask."Last Processing Started at", 'The real row must keep the start time of the pass that handled it');
        _Assert.AreEqual(0DT, SpfyTask."Claimed At", 'A transferred failure must release the claim');
        _Assert.AreEqual(0DT, SpfyTask."Completed At", 'A transferred failure must not be stamped as completed');
    end;

    [Test]
    procedure ClaimForBatchPersistsTheWorkRowRequestFragment()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        TempWorkTask: Record "NPR Spfy Task" temporary;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        OStream: OutStream;
    begin
        // [SCENARIO] Claiming a task for a batch persists onto the real row the request fragment its work row carries.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);

        // [GIVEN] A batch work row carrying the request fragment the prepare step staged for the task.
        TempWorkTask := SpfyTask;
        TempWorkTask.Insert();
        TempWorkTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText('{"id":"gid://shopify/ProductVariant/42"}');
        TempWorkTask.Modify();
        TempWorkTask.FindFirst();

        // [WHEN] The batch claims the task.
        _Assert.IsTrue(_SpfyTaskQueue.ClaimForBatch(TempWorkTask), 'The pending task must be claimable');

        // [THEN] The task's own request fragment is persisted on the real row.
        _Assert.IsTrue(StrPos(DataOutputText(SpfyTask."Entry No."), 'gid://shopify/ProductVariant/42') > 0, 'The work row''s request fragment must be persisted on the claimed task');
    end;

    [Test]
    procedure CompleteSingleWithEmptyErrorKeepsTheStoredResponse()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        OStream: OutStream;
    begin
        // [SCENARIO] A failure handed back with an empty error text leaves the task retryable and does not overwrite the response the send stored.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The pending task must be claimable');

        // [GIVEN] A response the send persisted before failing without an error text of its own.
        SpfyTask.Get(SpfyTask."Entry No.");
        SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText('{"ITEM1":"cost outcome map"}');
        SpfyTask.Modify(false);

        // [WHEN] The dispatch is handed back as failed with an empty error text.
        _SpfyTaskQueue.CompleteSingle(SpfyTask, false, '');

        // [THEN] The task is retryable and the stored response survives.
        SpfyTask.Get(SpfyTask."Entry No.");
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'A failed task with attempts left must be retryable');
        _Assert.IsTrue(StrPos(ResponseText(SpfyTask."Entry No."), 'cost outcome map') > 0, 'An empty error text must not overwrite the stored response');
    end;

    [Test]
    procedure EmptyErrorQuarantineKeepsTheStoredResponse()
    var
        Item: Record Item;
        CompletedTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        WorkTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        Attempt: Integer;
        ResponseJson: JsonToken;
    begin
        // [SCENARIO] A task that fails every attempt with a stored response but no error text is quarantined with all attempts counted and the response intact.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        TaskEntryNo := SpfyTask."Entry No.";
        ResponseJson.ReadFrom('{"' + Item."No." + '":"userErrors: the variant could not be updated"}');

        // [WHEN] Every attempt fails with a stored response but no separate error text, until none are left.
        for Attempt := 1 to _SpfyTaskQueue.AttemptCap() do begin
            WorkTask.Get(TaskEntryNo);
            _Assert.IsTrue(_SpfyTaskQueue.ClaimForBatch(WorkTask), 'The failing task must be claimable for every attempt');
            _Assert.IsTrue(_SpfyTaskQueue.CompleteFromBatch(TaskEntryNo, ResponseJson, false, '', CompletedTask), 'The failed attempt must be handed back');
        end;

        // [THEN] The task is quarantined and the stored response survives the empty-error failure path.
        SpfyTask.Get(TaskEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Quarantined, StrSubstNo('A task out of attempts must be quarantined but was %1', SpfyTask.State));
        _Assert.AreEqual(_SpfyTaskQueue.AttemptCap(), SpfyTask.Attempts, 'Every attempt must have been counted');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'userErrors: the variant could not be updated') > 0, StrSubstNo('The stored response must survive an empty-error quarantine but was: %1', ResponseText(TaskEntryNo)));
    end;

    [Test]
    procedure BatchClaimSurvivesADispatchRollback()
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        ForcedRollbackErr: Label 'Forced rollback after the batch claim.', Locked = true;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A batch claim survives a crash of the dispatch that took it, leaving the task in flight with the attempt counted.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Modify, AtDateTime, SpfyTask);
        TaskEntryNo := SpfyTask."Entry No.";
        Commit();

        // [WHEN] A dispatch claims the task for a batch and the send then crashes before the loop-end commit.
        SpfyTask.Get(TaskEntryNo);
        TempSpfyTaskWork := SpfyTask;
        TempSpfyTaskWork.Insert();
        _Assert.IsTrue(_SpfyTaskQueue.ClaimForBatch(TempSpfyTaskWork), 'test harness: the claim itself must succeed');
        asserterror Error(ForcedRollbackErr);

        // [THEN] The claim survives the rollback, so the sweep and the stale-claim reclaim can see it.
        SpfyTask.Get(TaskEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::"In Flight", 'A crashed batch dispatch must leave the committed claim visible');
        _Assert.AreEqual(1, SpfyTask.Attempts, 'The crashed attempt must remain counted');
    end;

    local procedure BuildPrestagedCarrier(StoreCode: Code[20]; AtDateTime: DateTime; ProcessingStartedAt: DateTime; ResponseTxt: Text; ResolvedType: Enum "NPR Spfy Task Op"; var CarrierTask: Record "NPR Spfy Task")
    var
        Item: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        OStream: OutStream;
    begin
        _Lib.CreateItem(Item);
        EnqueueItemAny(StoreCode, Item, "NPR Spfy Task Op"::Insert, AtDateTime, SpfyTask);
        SpfyTask.Get(SpfyTask."Entry No.");
        Clear(SpfyTask.Response);
        SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(ResponseTxt);
        SpfyTask.Modify(false);
        CarrierTask.Get(SpfyTask."Entry No.");
        CarrierTask.Type := ResolvedType;
        CarrierTask."Last Processing Started at" := ProcessingStartedAt;
    end;
    #endregion
}
