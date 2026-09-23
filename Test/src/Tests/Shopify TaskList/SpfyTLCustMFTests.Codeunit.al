codeunit 85388 "NPR Spfy TL Cust&MF Tests"
{
    // [FEATURE] Shopify Task List - customers and entity metafields on the queue: dispatch routing, the metafield-after-owner precondition, vanished sources, source card routing
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _SourceGoneLbl: Label 'The source record no longer exists. The request is no longer applicable.';
        _WaitingForOwnerLbl: Label 'Awaiting Shopify owner entity sync';
        _UnmappedKindTok: Label 'no send codeunit mapped', Locked = true;
        _CustomerCreateTok: Label 'customerCreate', Locked = true;
        _CustomerUpdateTok: Label 'customerUpdate', Locked = true;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        // The binary router keys on the feature while the engine keys on the migration status: the raw enable stamps both.
        _Lib.SetTaskListFeatureEnabled(true);
        ClearRunContext();
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
    end;

    local procedure ClearRunContext()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearSendBoundary();
    end;

    local procedure Minutes(MinuteCount: Integer): Duration
    begin
        exit(MinuteCount * 60 * 1000);
    end;

    local procedure CreateCustomerStore(): Code[20]
    begin
        exit(_Lib.CreateStore(true, false, false, true, false));
    end;

    local procedure CreateCustomerOwnedMetafield(var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; var Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; StoreCode: Code[20])
    begin
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId(), 'owner metafield value');
    end;

    local procedure CreateItemOwnedMetafield(var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; var Item: Record Item; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; StoreCode: Code[20])
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'owner metafield value');
    end;

    local procedure CreateVariantLink(var SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link"; ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    begin
        SpfyStoreItemVariantLink.Init();
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := StoreCode;
        SpfyStoreItemVariantLink."Sync. to this Store" := true;
        SpfyStoreItemVariantLink."Synchronization Is Enabled" := true;
        SpfyStoreItemVariantLink.Insert(false);
    end;

    local procedure StoreRecordId(StoreCode: Code[20]): RecordId
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.Get(StoreCode);
        exit(ShopifyStore.RecordId());
    end;

    local procedure EnqueueCustomerTask(StoreCode: Code[20]; Customer: Record Customer; Op: Enum "NPR Spfy Task Op"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Customer);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, Customer.RecordId(), Customer."No.", Op, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueMetafieldTask(StoreCode: Code[20]; SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; TaskRecordValue: Text; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        // The task is keyed on the OWNER link, never on the metafield row: the send pushes the owner's whole metafield state.
        RecRef.GetTable(SpfyEntityMetafield);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, SpfyEntityMetafield."BC Record ID", TaskRecordValue, "NPR Spfy Task Op"::Modify, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
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

    #region Dispatch routing
    [Test]
    procedure GivenReadyCustomerTask_WhenCycleRuns_ThenSingleRealRowDispatch()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A ready customer task reaches the send boundary once as a single real row rather than a batch, and completes on one attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A ready customer task of a synced customer.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The customer travels alone as the real row, not as a grouped work list.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A customer task must reach the send boundary exactly once');
        _Assert.IsFalse(_BndMock.LastDispatchWasTemporary(), 'A customer is a single-record kind, never a batch');
        _Assert.AreEqual(Database::Customer, _BndMock.LastDispatchTableNo(), 'The call must carry the customer table');
        _Assert.AreEqual(1, _BndMock.LastDispatchRowCount(), 'A single-record call must carry exactly one row');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A ready customer task must be sent');
    end;

    [Test]
    procedure GivenReadyMetafieldTaskWithSyncedOwner_WhenCycleRuns_ThenSingleDispatch()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A metafield task whose owner customer already exists in Shopify reaches the send boundary once as a single real row and completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A metafield whose owner customer already exists in Shopify.
        CreateCustomerOwnedMetafield(SpfyEntityMetafield, Customer, SpfyStoreCustomerLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), 'gid://c/synced');
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Customer."No.", AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The metafield travels alone as the real row and completes.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A metafield task must reach the send boundary exactly once');
        _Assert.IsFalse(_BndMock.LastDispatchWasTemporary(), 'A metafield is a single-record kind, never a batch');
        _Assert.AreEqual(Database::"NPR Spfy Entity Metafield", _BndMock.LastDispatchTableNo(), 'The call must carry the entity metafield table');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A metafield task whose owner is synced must be sent');
    end;
    #endregion

    #region Precondition - metafield after owner
    [Test]
    procedure GivenMetafieldTaskWithUnsyncedItemOwner_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A metafield task whose owner product has no Shopify id waits without spending an attempt or reaching the send boundary, and records the owner as its waiting reason.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A metafield whose owner product has never reached Shopify.
        CreateItemOwnedMetafield(SpfyEntityMetafield, Item, SpfyStoreItemLink, StoreCode);
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Item."No.", AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The metafield is set aside without spending an attempt and the reason names the missing owner.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A metafield whose owner product has no Shopify id must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred metafield must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForOwnerLbl, SpfyTask."Waiting Reason", 'The task must record that it waits for its owner entity');
    end;

    [Test]
    procedure GivenMetafieldTaskWithUnsyncedCustomerOwner_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A metafield task whose owner customer has no Shopify id defers exactly as a product-owned one does: no attempt, no dispatch, and the owner recorded as its waiting reason.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A metafield whose owner customer has never reached Shopify.
        CreateCustomerOwnedMetafield(SpfyEntityMetafield, Customer, SpfyStoreCustomerLink, StoreCode);
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Customer."No.", AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Both owner families defer alike: no attempt, no dispatch, and the owner reason recorded.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A metafield whose owner customer has no Shopify id must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred metafield must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForOwnerLbl, SpfyTask."Waiting Reason", 'The task must record that it waits for its owner entity');
    end;

    [Test]
    procedure GivenWaitingMetafieldTask_WhenOwnerIdAssigned_ThenNextCycleSends()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A waiting metafield task keeps waiting while its owner is unsynced, and is released and sent once on a fresh attempt after the owner gets its Shopify id.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();
        CreateCustomerOwnedMetafield(SpfyEntityMetafield, Customer, SpfyStoreCustomerLink, StoreCode);

        // [GIVEN] A metafield already parked because its owner customer had no Shopify id.
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Customer."No.", AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForOwnerLbl, AtDateTime);

        // [WHEN] A cycle runs while the owner is still unsynced.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The metafield keeps waiting: only a met precondition may release it.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A metafield whose owner is still unsynced must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A metafield whose owner is still unsynced must never reach the send boundary');

        // [WHEN] The owner send stamps the Shopify id and the next cycle runs.
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), 'gid://c/released');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The waiting metafield is released and sent on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting metafield must be sent once its owner exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released metafield must be sent exactly once');
    end;

    [Test]
    procedure GivenMetafieldTaskWithUnknownOwnerTable_WhenCycleRuns_ThenDispatchesWithoutPrecondition()
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A metafield task whose owner table carries no known owner id is dispatched rather than deferred, leaving the outcome to the send code.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A metafield owned by an entity the engine knows no owner id for.
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store", StoreRecordId(StoreCode), 'extension owned value');
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, StoreCode, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] An owner the engine cannot check carries no precondition: it is handed to the send code, which owns the outcome.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A metafield with an unknown owner table must be dispatched rather than deferred');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A metafield with an unknown owner table must reach the send boundary');
    end;
    #endregion

    #region Vanished sources
    [Test]
    procedure GivenDeletedCustomer_WhenCycleRuns_ThenCompletesNoLongerApplicable()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A customer task whose customer is deleted before the cycle reaches it is closed as no longer applicable, without an attempt and without reaching the send boundary.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [GIVEN] The customer is gone before the cycle reaches its task. Its store link goes first: Business Central refuses to delete a customer that is still synced.
        SpfyStoreCustomerLink.Delete(false);
        Customer.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The task is closed as no longer applicable instead of burning attempts.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A customer task whose customer is gone must be closed');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'The customer task must record why it is no longer applicable');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A vanished customer must never reach the send boundary');
    end;

    [Test]
    procedure GivenCustomerDeleteTaskForGoneCustomer_WhenCycleRuns_ThenStillDispatches()
    var
        Customer: Record Customer;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A customer delete task is exempt from the vanished-source check and is dispatched even though the customer no longer exists.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A remote-delete task whose customer row never existed in the first place.
        Customer."No." := _Lib.NextCode('CU', MaxStrLen(Customer."No."));
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Delete, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] A delete is exempt from the vanished-source check: it is sent so Shopify learns of the removal.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A customer delete task must be dispatched even though the customer is gone');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A customer delete task must reach the send boundary');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'A customer delete task must not be closed as no longer applicable');
    end;

    [Test]
    procedure GivenMetafieldTaskWhoseOwnerLinkRowDeleted_WhenCycleRuns_ThenCompletesNoLongerApplicable()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A metafield task whose owner link row is deleted is closed as no longer applicable, without an attempt and without reaching the send boundary.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();
        CreateCustomerOwnedMetafield(SpfyEntityMetafield, Customer, SpfyStoreCustomerLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), 'gid://c/synced');
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Customer."No.", AtDateTime);

        // [GIVEN] The owner link the task is keyed on is gone, while its assigned Shopify id survives.
        SpfyStoreCustomerLink.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] With no owner link there is nothing to push, so the task is closed rather than sent or retried.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A metafield task whose owner link is gone must be closed');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'The metafield task must record why it is no longer applicable');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A metafield whose owner link vanished must never reach the send boundary');
    end;
    #endregion

    #region Retry ladder
    [Test]
    procedure GivenFailingCustomerTask_WhenThreeCyclesRun_ThenQuarantined()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        DispatchesBeforeQuarantine: Integer;
        FailureText: Text;
    begin
        // [SCENARIO] A customer task that fails three times stays Pending for the first two, is quarantined on the third with the last error kept, and is never selected again.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'throttled';
        StoreCode := CreateCustomerStore();
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Modify, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, FailureText);

        // [WHEN] The send fails three times.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A failed customer task must stay Pending for another attempt');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A customer task must still be retryable after two failures');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The third failure quarantines it with the error visible, and later cycles leave it alone.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the customer task');
        _Assert.AreEqual(FailureText, ResponseText(TaskEntryNo), 'A quarantined customer task must keep the last error visible');
        DispatchesBeforeQuarantine := _BndMock.DispatchCount();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(3));
        _Assert.AreEqual(DispatchesBeforeQuarantine, _BndMock.DispatchCount(), 'A quarantined customer task must not be selected again');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A quarantined customer task must stay quarantined');
    end;
    #endregion

    #region Production boundary map
    [Test]
    procedure ProductionBoundaryRoutesCustomerAndMetafieldKinds()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CustomerTaskEntryNo: BigInteger;
        MetafieldTaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] The production send boundary routes both customer and metafield tasks to a real send codeunit rather than reporting an unmapped kind.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A customer task whose store-customer link row no longer exists.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        CustomerTaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Modify, AtDateTime);
        SpfyStoreCustomerLink.Delete(false);
        GetTask(CustomerTaskEntryNo, SpfyTask);

        // [WHEN] The production boundary is handed that customer task.
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();

        // [THEN] It fails inside the send codeunit, which proves the dispatch reached it rather than the unmapped branch.
        _Assert.IsFalse(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText), 'A customer task whose store link is gone must fail inside the send codeunit');
        _Assert.IsTrue(StrPos(ErrorText, _UnmappedKindTok) = 0, StrSubstNo('A customer task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));

        // [GIVEN] A metafield task owned by an entity the send code resolves no owner type for.
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store", StoreRecordId(StoreCode), 'extension owned value');
        MetafieldTaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, StoreCode, AtDateTime);
        GetTask(MetafieldTaskEntryNo, SpfyTask);
        Commit();

        // [WHEN] The production boundary is handed that metafield task.
        // [THEN] The send codeunit completes the call without sending anything, which only its own code path can do.
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText), StrSubstNo('A metafield task must be routed to a send codeunit: %1', ErrorText));
    end;

    [Test]
    procedure GivenInsertCustomerTaskWithExistingShopifyId_WhenDispatchedForReal_ThenRequestCoercedToUpdate()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
        RequestText: Text;
    begin
        // [SCENARIO] An Insert customer task for a customer that already carries a Shopify id prepares an update request, not a create.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] An Insert task for a customer that already exists in Shopify.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), '7000000001');
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Insert, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        Commit();

        // [WHEN] The task is dispatched through the production boundary, so the real request preparation runs.
        _Assert.IsFalse(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText), 'The dispatch must fail at the Shopify call, after the request was prepared');

        // [THEN] The prepared request is an update, not a create: an existing Shopify id coerces the operation.
        RequestText := DataOutputText(TaskEntryNo);
        _Assert.IsTrue(StrPos(RequestText, _CustomerUpdateTok) > 0, StrSubstNo('An Insert task for an existing Shopify customer must be sent as an update, but the request was: %1', RequestText));
        _Assert.AreEqual(0, StrPos(RequestText, _CustomerCreateTok), StrSubstNo('An Insert task for an existing Shopify customer must not be sent as a create, but the request was: %1', RequestText));
    end;
    #endregion

    #region Source record routing
    [Test]
    procedure GivenCustomerTask_WhenResolvingSourceCard_ThenResolverDeclines()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        SourceRecRef: RecordRef;
    begin
        // [SCENARIO] The source-card resolver declines a customer task, because the task already points at the card record instead of a link row.
        Initialize();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A customer task, which is keyed on the customer itself rather than on a link row.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        TaskEntryNo := EnqueueCustomerTask(StoreCode, Customer, "NPR Spfy Task Op"::Modify, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);

        // [WHEN] The source record behind the task is resolved.
        // [THEN] The resolver declines: only link rows need translating, and the task already points at the card record.
        _Assert.IsFalse(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A customer task already points at its card: the resolver must decline so the page fallback routes it');
    end;

    [Test]
    procedure GivenMetafieldTaskWithCustomerOwner_WhenResolvingSourceCard_ThenReturnsCustomerRecord()
    var
        Customer: Record Customer;
        ResolvedCustomer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        SourceRecRef: RecordRef;
    begin
        // [SCENARIO] The source-card resolver turns a customer-owned metafield task into the owning customer record.
        Initialize();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A metafield task, which is keyed on its owner link rather than on a customer.
        CreateCustomerOwnedMetafield(SpfyEntityMetafield, Customer, SpfyStoreCustomerLink, StoreCode);
        TaskEntryNo := EnqueueMetafieldTask(StoreCode, SpfyEntityMetafield, Customer."No.", CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);

        // [WHEN] The source record behind the task is resolved.
        // [THEN] The owner link resolves to the customer itself, with no metafield-specific routing.
        _Assert.IsTrue(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A metafield task owned by a customer link must resolve a source record');
        _Assert.AreEqual(Database::Customer, SourceRecRef.Number(), 'A customer-owned metafield must resolve to the customer table');
        SourceRecRef.SetTable(ResolvedCustomer);
        _Assert.AreEqual(Customer."No.", ResolvedCustomer."No.", 'The resolved customer must be the owner of the metafield');
    end;

    [Test]
    procedure GivenMetafieldTaskWithVariantItemOwner_WhenResolvingSourceCard_ThenReturnsItemVariantRecord()
    var
        Item: Record Item;
        ResolvedItem: Record Item;
        ItemVariant: Record "Item Variant";
        ResolvedItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        VariantMetafield: Record "NPR Spfy Entity Metafield";
        ItemMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        VariantTaskEntryNo: BigInteger;
        ItemTaskEntryNo: BigInteger;
        SourceRecRef: RecordRef;
    begin
        // [SCENARIO] The source-card resolver turns a variant-owned metafield task into the owning item variant and an item-owned one into the item, keyed only on the link type.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] One metafield owned by a variant link and one owned by the item link of the same item.
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        CreateVariantLink(SpfyStoreItemVariantLink, Item."No.", ItemVariant.Code, StoreCode);
        _Lib.CreateMetafield(VariantMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemVariantLink.RecordId(), 'variant value');
        _Lib.CreateMetafield(ItemMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'item value');
        VariantTaskEntryNo := EnqueueMetafieldTask(StoreCode, VariantMetafield, Item."No." + '_' + ItemVariant.Code, AtDateTime);
        ItemTaskEntryNo := EnqueueMetafieldTask(StoreCode, ItemMetafield, Item."No.", AtDateTime);

        // [WHEN] The source record behind the variant-owned task is resolved.
        GetTask(VariantTaskEntryNo, SpfyTask);

        // [THEN] It resolves to the variant, not to its item.
        _Assert.IsTrue(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A metafield task owned by a variant link must resolve a source record');
        _Assert.AreEqual(Database::"Item Variant", SourceRecRef.Number(), 'A variant-owned metafield must resolve to the item variant table');
        SourceRecRef.SetTable(ResolvedItemVariant);
        _Assert.AreEqual(Item."No.", ResolvedItemVariant."Item No.", 'The resolved variant must belong to the owner item');
        _Assert.AreEqual(ItemVariant.Code, ResolvedItemVariant.Code, 'The resolved variant must be the owner variant');

        // [WHEN] The source record behind the item-owned task is resolved.
        GetTask(ItemTaskEntryNo, SpfyTask);

        // [THEN] The same resolver lands on the item instead, keyed only on the link type.
        _Assert.IsTrue(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A metafield task owned by an item link must resolve a source record');
        _Assert.AreEqual(Database::Item, SourceRecRef.Number(), 'An item-owned metafield must resolve to the item table');
        SourceRecRef.SetTable(ResolvedItem);
        _Assert.AreEqual(Item."No.", ResolvedItem."No.", 'The resolved item must be the owner of the metafield');
    end;

    [Test]
    procedure GivenTaskWhoseRecordIdIsNotALinkRow_WhenResolvingSourceCard_ThenReturnsFalse()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        UnroutableMetafield: Record "NPR Spfy Entity Metafield";
        OrphanedMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        UnroutableTaskEntryNo: BigInteger;
        OrphanTaskEntryNo: BigInteger;
        SourceRecRef: RecordRef;
    begin
        // [SCENARIO] The source-card resolver declines both a record id that is not a link row and an orphaned link row whose customer is gone, rather than raising.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A task whose record id is not a link row at all.
        _Lib.CreateMetafield(UnroutableMetafield, Database::"NPR Spfy Store", StoreRecordId(StoreCode), 'extension owned value');
        UnroutableTaskEntryNo := EnqueueMetafieldTask(StoreCode, UnroutableMetafield, StoreCode, AtDateTime);

        // [WHEN] Its source record is resolved.
        GetTask(UnroutableTaskEntryNo, SpfyTask);

        // [THEN] The resolver declines, so the page keeps its own fallback.
        _Assert.IsFalse(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A record id that is not a link row must not resolve a source record');

        // [GIVEN] An orphaned link row whose customer no longer exists. The link is left unsynced, or Business Central refuses to delete the customer at all.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, false, false);
        _Lib.CreateMetafield(OrphanedMetafield, Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId(), 'orphaned owner value');
        OrphanTaskEntryNo := EnqueueMetafieldTask(StoreCode, OrphanedMetafield, Customer."No.", AtDateTime);
        Customer.Delete(false);

        // [WHEN] Its source record is resolved.
        GetTask(OrphanTaskEntryNo, SpfyTask);

        // [THEN] The resolver declines instead of raising at the caller.
        _Assert.IsFalse(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'An orphaned link row must decline rather than raise');
    end;

    [Test]
    procedure GivenCostTask_WhenResolvingSourceCard_ThenReturnsItemRecord()
    var
        InventoryBuffer: Record "Inventory Buffer";
        Item: Record Item;
        ResolvedItem: Record Item;
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        SourceRecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] The source-card resolver turns a cost task into its item, not the never-persisted Inventory Buffer row it is keyed on.
        Initialize();
        StoreCode := CreateCustomerStore();

        // [GIVEN] A cost task, whose record id is a synthetic Inventory Buffer row that is never persisted.
        _Lib.CreateItem(Item);
        InventoryBuffer."Item No." := Item."No.";
        RecRef.GetTable(InventoryBuffer);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, InventoryBuffer.RecordId(), Item."No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, CurrentDateTime(), SpfyTask);
        TaskEntryNo := SpfyTask."Entry No.";

        // [WHEN] Its source record is resolved.
        GetTask(TaskEntryNo, SpfyTask);

        // [THEN] The resolver lands on the item, not on the never-persisted buffer row.
        _Assert.IsTrue(_SpfyTaskQueue.TryGetSourceCardRecord(SpfyTask, SourceRecRef), 'A cost task must resolve to its item');
        _Assert.AreEqual(Database::Item, SourceRecRef.Number(), 'A cost task must resolve to the Item table');
        SourceRecRef.SetTable(ResolvedItem);
        _Assert.AreEqual(Item."No.", ResolvedItem."No.", 'A cost task must resolve to the item it carries');
    end;
    #endregion
}
