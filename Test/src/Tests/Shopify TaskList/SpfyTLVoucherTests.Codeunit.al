codeunit 85443 "NPR Spfy TL Voucher Tests"
{
    // [FEATURE] Shopify Task List - retail vouchers on the queue: dispatch routing, the create/balance pair, archived-voucher coordination, send-time op coercion
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
        _NotEligibleTok: Label 'could not be found or is not eligible', Locked = true;
        _AlreadyArchivedTok: Label 'has already been archived', Locked = true;
        _ArchivedNeverSentTok: Label 'archived but never sent', Locked = true;
        _MissingGiftCardIdTok: Label 'does not have a Shopify gift card ID assigned', Locked = true;
        _OutstandingAmountTok: Label 'outstanding requests to update the Shopify gift card amount', Locked = true;
        _GiftCardIdRequiredTok: Label 'Shopify gift card Id must be specified', Locked = true;
        _GiftCardCreateTok: Label 'giftCardCreate', Locked = true;
        _GiftCardUpdateTok: Label 'giftCardUpdate', Locked = true;
        _UnmappedKindTok: Label 'no send codeunit mapped', Locked = true;
        _WaitingForBalanceUpdatesLbl: Label 'Awaiting outstanding gift card balance updates';
        _WaitingForGiftCardLbl: Label 'Awaiting Shopify gift card creation';

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

    local procedure CreateVoucherStore(): Code[20]
    begin
        exit(_Lib.CreateStore(false, false, false, false, true));
    end;

    local procedure InsertVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; InitiatedInShopify: Boolean)
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry.Amount := 100;
        VoucherEntry."Spfy Initiated in Shopify" := InitiatedInShopify;
        VoucherEntry.Insert(false);
    end;

    local procedure ArchiveVoucher(var ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher"; DeleteLive: Boolean)
    begin
        ArchVoucher.Init();
        ArchVoucher."No." := _Lib.NextCode('AR', MaxStrLen(ArchVoucher."No."));
        ArchVoucher."Arch. No." := Voucher."No.";
        ArchVoucher."Voucher Type" := Voucher."Voucher Type";
        ArchVoucher.Insert(false);
        // Trigger-less so a Shopify id assigned against the live record id survives the archival.
        if DeleteLive then
            Voucher.Delete(false);
    end;

    local procedure EnqueueVoucherTask(StoreCode: Code[20]; RecRef: RecordRef; RecId: RecordId; VoucherNo: Code[20]; Op: Enum "NPR Spfy Task Op"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, RecId, VoucherNo, Op, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure DispatchForReal(EntryNo: BigInteger; var ErrorText: Text): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
    begin
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        SpfyTask.Get(EntryNo);
        exit(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText));
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

    local procedure SetTaskState(EntryNo: BigInteger; NewState: Enum "NPR Spfy Task State")
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.State := NewState;
        SpfyTask.Modify(false);
    end;

    local procedure SetTaskAttempts(EntryNo: BigInteger; AttemptCount: Integer)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.Attempts := AttemptCount;
        SpfyTask.Modify(false);
    end;

    local procedure ParkTaskAsWaiting(EntryNo: BigInteger; WaitingReasonTxt: Text; AtDateTime: DateTime)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _SpfyTaskQueue.SetWaiting(SpfyTask, WaitingReasonTxt, AtDateTime);
    end;

    local procedure TaskCount(TableNo: Integer): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.Count());
    end;

    local procedure FindLastTask(TableNo: Integer; var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.Reset();
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.FindLast());
    end;

    #region Dispatch routing - kind pins
    [Test]
    procedure GivenUnsyncedVoucherEntryDetected_WhenCycleRuns_ThenInsertDispatchesBeforeEntryModify()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        CreateSpfyTask: Record "NPR Spfy Task";
        BalanceSpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A balance entry on a voucher with no gift card enqueues both the create on the voucher and the balance update on the entry, and the cycle hands the create to the send boundary first.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A balance entry on a voucher that has no Shopify gift card yet.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);

        // [WHEN] The change is detected.
        _Lib.DispatchModify(VoucherEntry);

        // [THEN] Two tasks are enqueued: the gift card create on the voucher, the balance update on the entry, both keyed on the voucher no.
        _Assert.AreEqual(1, TaskCount(Database::"NPR NpRv Voucher"), 'A first entry on an unsynced voucher must enqueue the gift card create');
        _Assert.AreEqual(1, TaskCount(Database::"NPR NpRv Voucher Entry"), 'The balance entry must be enqueued as its own task');
        FindLastTask(Database::"NPR NpRv Voucher", CreateSpfyTask);
        FindLastTask(Database::"NPR NpRv Voucher Entry", BalanceSpfyTask);
        _Assert.IsTrue(CreateSpfyTask.Type = CreateSpfyTask.Type::Insert, 'The gift card create must be enqueued as an Insert');
        _Assert.IsTrue(BalanceSpfyTask.Type = BalanceSpfyTask.Type::Modify, 'The balance update must be enqueued as a Modify');
        _Assert.AreEqual(Voucher."No.", CreateSpfyTask."Record Value", 'The gift card create must carry the voucher no.');
        _Assert.AreEqual(Voucher."No.", BalanceSpfyTask."Record Value", 'The balance update must carry the voucher no., not the entry key');
        _Assert.IsTrue(CreateSpfyTask."Entry No." < BalanceSpfyTask."Entry No.", 'The gift card create must be enqueued first');

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The ready scan hands the create to the send boundary before the balance update.
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'Both halves of the pair must reach the send boundary');
        _Assert.AreEqual(Database::"NPR NpRv Voucher", _BndMock.DispatchTableNoAt(1), 'The gift card create must be dispatched first');
        _Assert.AreEqual(Database::"NPR NpRv Voucher Entry", _BndMock.DispatchTableNoAt(2), 'The balance update must be dispatched after the create');
    end;

    [Test]
    procedure GivenFailingPairHalves_WhenCyclesRun_ThenEachQuarantinesIndependentlyAndRequeueRevives()
    var
        Voucher: Record "NPR NpRv Voucher";
        OtherVoucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        OtherVoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CreateTaskEntryNo: BigInteger;
        BalanceTaskEntryNo: BigInteger;
        OtherCreateTaskEntryNo: BigInteger;
        OtherBalanceTaskEntryNo: BigInteger;
        DispatchesBeforeRequeue: Integer;
        FailureText: Text;
    begin
        // [SCENARIO] Either half of a gift card pair quarantines on its own three failures while its partner completes unaffected, and requeueing the quarantined half revives it.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'create failed';
        StoreCode := CreateVoucherStore();

        // [GIVEN] A detected pair whose gift card create fails at Shopify.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        _Lib.DispatchModify(VoucherEntry);
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        CreateTaskEntryNo := SpfyTask."Entry No.";
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        BalanceTaskEntryNo := SpfyTask."Entry No.";
        // Stamped after the pair is enqueued: this test is about retry independence, not about the create-first precondition.
        _Lib.AssignEntryID(Voucher.RecordId(), 'gid://gc/pair');
        _BndMock.QueueOutcome(CreateTaskEntryNo, false, FailureText);

        // [WHEN] Three cycles run.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The create burns an attempt and stays retryable while its partner completes on its own.
        AssertTask(CreateTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A failed gift card create must stay Pending for another attempt');
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The balance half must complete independently of the failing create');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));
        AssertTask(CreateTaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A gift card create must still be retryable after two failures');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));
        AssertTask(CreateTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the gift card create');

        // [GIVEN] A fresh pair whose balance update is the failing half instead.
        FailureText := 'balance update failed';
        _Lib.CreateVoucherFixture(OtherVoucher, StoreCode, false);
        InsertVoucherEntry(OtherVoucherEntry, OtherVoucher, false);
        _Lib.DispatchModify(OtherVoucherEntry);
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        OtherCreateTaskEntryNo := SpfyTask."Entry No.";
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        OtherBalanceTaskEntryNo := SpfyTask."Entry No.";
        _Lib.AssignEntryID(OtherVoucher.RecordId(), 'gid://gc/otherpair');
        _BndMock.QueueOutcome(OtherBalanceTaskEntryNo, false, FailureText);

        // [WHEN] Three more cycles run.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(3));
        AssertTask(OtherBalanceTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A failed balance update must stay Pending rather than wait');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(4));
        AssertTask(OtherBalanceTaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A balance update must still be retryable after two failures');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(5));

        // [THEN] The balance half quarantines on its own and its create partner is unaffected.
        AssertTask(OtherBalanceTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the balance update');
        AssertTask(OtherCreateTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The create half must complete independently of the failing balance update');

        // [WHEN] The quarantined balance update is requeued and Shopify accepts it.
        GetTask(OtherBalanceTaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.Requeue(SpfyTask), 'A quarantined balance update must be requeueable');
        AssertTask(OtherBalanceTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A requeued balance update must be pending again with a fresh attempt budget');
        _BndMock.QueueOutcome(OtherBalanceTaskEntryNo, true, '');
        DispatchesBeforeRequeue := _BndMock.DispatchCount();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(6));

        // [THEN] It is dispatched again and completes.
        _Assert.IsTrue(_BndMock.DispatchCount() > DispatchesBeforeRequeue, 'A requeued balance update must reach the send boundary again');
        AssertTask(OtherBalanceTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A revived balance update must be sent');
    end;

    [Test]
    procedure GivenVoucherTasksWhoseSourceRowsAreGone_WhenCycleRuns_ThenTheyStillDispatch()
    var
        Voucher: Record "NPR NpRv Voucher";
        OtherVoucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CreateTaskEntryNo: BigInteger;
        BalanceTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] The voucher kinds carry no vanished-source rule, so a create whose voucher was archived and a balance update whose entry was deleted are both still handed to the send code.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A gift card create whose live voucher row was archived away after the enqueue.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        RecRef.GetTable(Voucher);
        CreateTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        ArchiveVoucher(ArchVoucher, Voucher, true);

        // [GIVEN] A balance update whose entry row was deleted after the enqueue.
        _Lib.CreateVoucherFixture(OtherVoucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, OtherVoucher, false);
        RecRef.GetTable(VoucherEntry);
        BalanceTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), OtherVoucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        VoucherEntry.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The engine carries no vanished-source rule for the voucher kinds: both are handed to the send code, which owns the outcome.
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'Both voucher tasks must reach the send boundary although their source rows are gone');
        AssertTask(CreateTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A gift card create over an archived-away voucher must still be dispatched');
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A balance update whose entry row is gone must still be dispatched');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(CreateTaskEntryNo), 'A gift card create must not be closed as no longer applicable');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(BalanceTaskEntryNo), 'A balance update must not be closed as no longer applicable');
    end;

    [Test]
    procedure GivenOutstandingEntryTask_WhenCycleRuns_ThenDisableWaitsWithoutAttemptUntilTheEntryClears()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        BalanceTaskEntryNo: BigInteger;
        DisableTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A deactivation queued behind an outstanding balance update parks in Waiting without spending an attempt, and is released and sent on the cycle after the balance update clears.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A deactivation queued behind a balance update that keeps failing, so it stays outstanding.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        ArchiveVoucher(ArchVoucher, Voucher, false);
        RecRef.GetTable(VoucherEntry);
        BalanceTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        RecRef.GetTable(ArchVoucher);
        DisableTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, ArchVoucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        _BndMock.QueueOutcome(BalanceTaskEntryNo, false, 'balance update failed');

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The deactivation is parked rather than spending an attempt on a sequencing deferral.
        AssertTask(DisableTaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A deactivation must wait while a balance update is outstanding');
        GetTask(DisableTaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForBalanceUpdatesLbl, SpfyTask."Waiting Reason", 'The parked deactivation must record the outstanding balance update as its blocker');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'Only the balance update may reach the send boundary while the deactivation waits');

        // [WHEN] Nothing is outstanding any more and the next cycle runs.
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(BalanceTaskEntryNo, 'the balance update is no longer outstanding'), 'The outstanding balance update must be closable');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The deactivation is released and dispatched with a clean attempt budget.
        AssertTask(DisableTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A released deactivation must be dispatched on the next cycle');
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'The released deactivation must reach the send boundary');
        GetTask(DisableTaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'A released deactivation must not keep its waiting reason');
    end;

    [Test]
    procedure GivenOutstandingGiftCardCreate_WhenCycleRuns_ThenBalanceWaitsWithoutAttemptUntilTheCardExists()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CreateTaskEntryNo: BigInteger;
        BalanceTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A balance update whose gift card create is still outstanding parks in Waiting without spending an attempt, and is released and sent once the create clears and the gift card id is stamped.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A detected pair whose gift card create fails, so it stays outstanding and assigns no id.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        _Lib.DispatchModify(VoucherEntry);
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        CreateTaskEntryNo := SpfyTask."Entry No.";
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        BalanceTaskEntryNo := SpfyTask."Entry No.";
        _BndMock.QueueOutcome(CreateTaskEntryNo, false, 'gift card create failed');

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The balance update parks instead of spending an attempt on a card that does not exist yet.
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A balance update must wait while the gift card create is outstanding');
        GetTask(BalanceTaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForGiftCardLbl, SpfyTask."Waiting Reason", 'The parked balance update must record the missing gift card as its blocker');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'Only the gift card create may reach the send boundary while the balance update waits');

        // [WHEN] The create clears and the gift card id is stamped, then the next cycle runs.
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(CreateTaskEntryNo, 'the gift card create is no longer outstanding'), 'The outstanding gift card create must be closable');
        _Lib.AssignEntryID(Voucher.RecordId(), 'gid://gc/released');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The balance update is released and sent on a clean attempt budget.
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A released balance update must be dispatched on the next cycle');
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'The released balance update must reach the send boundary');
        GetTask(BalanceTaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'A released balance update must not keep its waiting reason');
    end;

    [Test]
    procedure GivenQuarantinedGiftCardCreate_WhenFurtherCyclesRun_ThenBalanceKeepsWaitingUntilTheCardExists()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CreateTaskEntryNo: BigInteger;
        BalanceTaskEntryNo: BigInteger;
        DispatchesBeforeFurtherCycle: Integer;
    begin
        // [SCENARIO] A gift card create that has quarantined on three failures is still outstanding, so the balance update keeps waiting through further cycles and is only released once the create is requeued and the gift card id is stamped.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A detected pair whose gift card create always fails, so no gift card id is ever assigned.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        _Lib.DispatchModify(VoucherEntry);
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        CreateTaskEntryNo := SpfyTask."Entry No.";
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        BalanceTaskEntryNo := SpfyTask."Entry No.";
        _BndMock.QueueOutcome(CreateTaskEntryNo, false, 'gift card create failed');

        // [WHEN] Three cycles run, so the create exhausts its attempts.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The create is quarantined and the balance update is still parked on the missing gift card.
        AssertTask(CreateTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the gift card create');
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A balance update must not spend an attempt while the gift card create keeps failing');
        GetTask(BalanceTaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForGiftCardLbl, SpfyTask."Waiting Reason", 'The parked balance update must still record the missing gift card as its blocker');

        // [WHEN] A further cycle runs with the create sitting quarantined.
        DispatchesBeforeFurtherCycle := _BndMock.DispatchCount();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(3));

        // [THEN] A quarantined create is outstanding too, so the balance update is neither released nor sent.
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A quarantined gift card create is still outstanding, so the balance update must keep waiting');
        _Assert.AreEqual(DispatchesBeforeFurtherCycle, _BndMock.DispatchCount(), 'No balance update may reach the send boundary while the gift card create is quarantined');

        // [WHEN] The create is requeued, succeeds and stamps the gift card id, then the next cycle runs.
        GetTask(CreateTaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.Requeue(SpfyTask), 'A quarantined gift card create must be requeueable');
        _BndMock.QueueOutcome(CreateTaskEntryNo, true, '');
        _Lib.AssignEntryID(Voucher.RecordId(), 'gid://gc/requeued');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(4));

        // [THEN] The balance update is released and sent on a clean attempt budget.
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A balance update must be dispatched once the gift card create has cleared');
        GetTask(BalanceTaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'A released balance update must not keep its waiting reason');
    end;
    #endregion

    #region Production boundary
    [Test]
    procedure ProductionBoundaryRoutesAllThreeVoucherTables()
    var
        Voucher: Record "NPR NpRv Voucher";
        GoneVoucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
        EntryRecId: RecordId;
        StoreCode: Code[20];
        MissingVoucherNo: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] The production send boundary routes voucher, voucher entry and archived voucher tasks to a real send codeunit rather than reporting an unmapped kind.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A voucher task whose voucher row was never created.
        Voucher."No." := _Lib.NextCode('VO', MaxStrLen(Voucher."No."));
        RecRef.GetTable(Voucher);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The production boundary is handed that voucher task.
        // [THEN] It fails inside the send codeunit, which proves the dispatch reached it rather than the unmapped branch.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A voucher task whose voucher cannot be resolved must fail inside the send codeunit');
        _Assert.IsTrue(StrPos(ErrorText, _NotEligibleTok) > 0, StrSubstNo('The voucher task must be declined by the send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A voucher task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));

        // [GIVEN] A voucher entry task whose entry row and voucher are both gone.
        _Lib.CreateVoucherFixture(GoneVoucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, GoneVoucher, false);
        EntryRecId := VoucherEntry.RecordId();
        VoucherEntry.Delete(false);
        GoneVoucher.Delete(false);
        RecRef.GetTable(VoucherEntry);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, EntryRecId, GoneVoucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The production boundary is handed that entry task.
        // [THEN] Same shape: declined by the send codeunit, not by the boundary map.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A voucher entry task whose voucher cannot be resolved must fail inside the send codeunit');
        _Assert.IsTrue(StrPos(ErrorText, _NotEligibleTok) > 0, StrSubstNo('The voucher entry task must be declined by the send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A voucher entry task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));

        // [GIVEN] An archived voucher task whose archived row was never created, and no outstanding sibling to postpone it.
        MissingVoucherNo := _Lib.NextCode('VO', MaxStrLen(Voucher."No."));
        ArchVoucher."No." := _Lib.NextCode('AR', MaxStrLen(ArchVoucher."No."));
        RecRef.GetTable(ArchVoucher);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, ArchVoucher.RecordId(), MissingVoucherNo, "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The production boundary is handed that archived voucher task.
        // [THEN] Same shape again: all three voucher kinds are mapped.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'An archived voucher task whose voucher cannot be resolved must fail inside the send codeunit');
        _Assert.IsTrue(StrPos(ErrorText, _NotEligibleTok) > 0, StrSubstNo('The archived voucher task must be declined by the send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('An archived voucher task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
    end;

    [Test]
    procedure GivenShopifyInitiatedIssueEntry_WhenDispatchedForReal_ThenDeclinedAsNotEligible()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A balance update for an issue entry that originated in Shopify is declined by the send-time guard, so a Shopify-native gift card is never echoed back.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A queued balance update for an issue entry that originated in Shopify.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        InsertVoucherEntry(VoucherEntry, Voucher, true);
        RecRef.GetTable(VoucherEntry);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] It is dispatched for real.
        // [THEN] The send-time guard declines it, so a Shopify-native gift card is never echoed back.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A Shopify-originated issue entry must be declined at send time');
        _Assert.IsTrue(StrPos(ErrorText, _NotEligibleTok) > 0, StrSubstNo('The entry must be declined as not eligible, but the boundary reported: %1', ErrorText));
    end;

    [Test]
    procedure GivenPendingEntryTask_WhenArchDisableDispatchesForReal_ThenPostponedErrorAndNothingCancelled()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        BalanceTaskEntryNo: BigInteger;
        DisableTaskEntryNo: BigInteger;
        OtherStoreBalanceTaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A deactivation postpones itself and cancels nothing while a balance update for the same voucher and store is outstanding, and proceeds once only another store holds one.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();
        OtherStoreCode := CreateVoucherStore();

        // [GIVEN] A pending balance update and a deactivation for the same voucher and store.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        ArchiveVoucher(ArchVoucher, Voucher, false);
        RecRef.GetTable(VoucherEntry);
        BalanceTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        RecRef.GetTable(ArchVoucher);
        DisableTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, ArchVoucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The deactivation is dispatched for real.
        // [THEN] It postpones itself and leaves the balance update alone.
        _Assert.IsFalse(DispatchForReal(DisableTaskEntryNo, ErrorText), 'A deactivation must not be sent while a balance update is outstanding');
        _Assert.IsTrue(StrPos(ErrorText, _OutstandingAmountTok) > 0, StrSubstNo('The deactivation must report the postponement, but the boundary reported: %1', ErrorText));
        AssertTask(BalanceTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'The outstanding balance update must be left untouched');
        _Assert.AreEqual('', ResponseText(BalanceTaskEntryNo), 'The outstanding balance update must not be cancelled');

        // [GIVEN] The balance update has been sent, and only another store holds one for the same voucher no.
        SetTaskState(BalanceTaskEntryNo, "NPR Spfy Task State"::Completed);
        RecRef.GetTable(VoucherEntry);
        OtherStoreBalanceTaskEntryNo := EnqueueVoucherTask(OtherStoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The deactivation is dispatched again.
        // [THEN] The outstanding query is scoped to its own store, so nothing postpones it.
        _Assert.IsTrue(DispatchForReal(DisableTaskEntryNo, ErrorText), StrSubstNo('A deactivation must not be postponed by another store''s balance update: %1', ErrorText));
        _Assert.AreEqual(0, StrPos(ErrorText, _OutstandingAmountTok), StrSubstNo('The deactivation must not report a postponement, but the boundary reported: %1', ErrorText));
        AssertTask(OtherStoreBalanceTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'The other store''s balance update must be left untouched');
    end;

    [Test]
    procedure GivenArchivedUnsyncedVoucher_WhenEntryTaskDispatchesForReal_ThenFailsWhileVoucherTaskOutstanding_ElseCompletesUnsent()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        BalanceTaskEntryNo: BigInteger;
        CreateTaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A balance update for an archived voucher that never reached Shopify stays retryable while its gift card create is outstanding, and completes unsent once nothing is left to wait for.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A balance update for an archived voucher that never reached Shopify, while its gift card create is still outstanding.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        ArchiveVoucher(ArchVoucher, Voucher, true);
        RecRef.GetTable(VoucherEntry);
        BalanceTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        RecRef.GetTable(Voucher);
        CreateTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The balance update is dispatched for real.
        // [THEN] It fails on the missing gift card id and stays retryable, because the create may still succeed.
        _Assert.IsFalse(DispatchForReal(BalanceTaskEntryNo, ErrorText), 'A balance update must fail while the gift card create is still outstanding');
        _Assert.IsTrue(StrPos(ErrorText, _MissingGiftCardIdTok) > 0, StrSubstNo('The balance update must report the missing gift card id, but the boundary reported: %1', ErrorText));

        // [WHEN] The gift card create is gone and the balance update is dispatched again.
        _Assert.IsTrue(_SpfyTaskQueue.CancelUnsentTask(CreateTaskEntryNo, 'the create is no longer outstanding'), 'The outstanding gift card create must be closable');

        // [THEN] With nothing left to wait for, the balance update completes unsent.
        _Assert.IsTrue(DispatchForReal(BalanceTaskEntryNo, ErrorText), StrSubstNo('A balance update for a never-synced archived voucher must complete unsent: %1', ErrorText));
        _Assert.IsTrue(StrPos(ResponseText(BalanceTaskEntryNo), _ArchivedNeverSentTok) > 0, StrSubstNo('The balance update must record that the voucher was never sent, but recorded: %1', ResponseText(BalanceTaskEntryNo)));
        _Assert.AreEqual('', DataOutputText(BalanceTaskEntryNo), 'A balance update that completes unsent must not have a request prepared');
    end;

    [Test]
    procedure GivenArchivedUnsyncedVoucher_WhenDisableDispatchesForReal_ThenOutstandingVoucherTasksCompleteUnsent_InFlightLeftAlone()
    var
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        InFlightTaskEntryNo: BigInteger;
        QuarantinedTaskEntryNo: BigInteger;
        PendingTaskEntryNo: BigInteger;
        OtherStoreTaskEntryNo: BigInteger;
        DisableTaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A deactivation of a never-synced archived voucher supersedes every unsent voucher task in its own scope whatever the op type, leaves an in-flight row and another store alone, and clears the stale disabled flag.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();
        OtherStoreCode := CreateVoucherStore();

        // [GIVEN] An archived voucher that never reached Shopify, carrying a stale disabled flag.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        ArchiveVoucher(ArchVoucher, Voucher, true);
        ArchVoucher."Disabled at Shopify" := true;
        ArchVoucher.Modify(false);
        RecRef.GetTable(Voucher);

        // [GIVEN] Voucher tasks for it in every unsent state, plus one for another store.
        InFlightTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        SetTaskState(InFlightTaskEntryNo, "NPR Spfy Task State"::"In Flight");
        QuarantinedTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        SetTaskState(QuarantinedTaskEntryNo, "NPR Spfy Task State"::Quarantined);
        PendingTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        OtherStoreTaskEntryNo := EnqueueVoucherTask(OtherStoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        RecRef.GetTable(ArchVoucher);
        DisableTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, ArchVoucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The deactivation is dispatched for real.
        _Assert.IsTrue(DispatchForReal(DisableTaskEntryNo, ErrorText), StrSubstNo('A deactivation of a never-synced archived voucher must complete unsent: %1', ErrorText));

        // [THEN] Every unsent voucher task in the same scope is superseded, regardless of its op type.
        AssertTask(PendingTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A pending gift card create must be superseded by the deactivation');
        _Assert.IsTrue(StrPos(ResponseText(PendingTaskEntryNo), _ArchivedNeverSentTok) > 0, StrSubstNo('The superseded create must record the reason, but recorded: %1', ResponseText(PendingTaskEntryNo)));
        AssertTask(QuarantinedTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A quarantined voucher Modify must be superseded too: the supersede is not filtered by op type');
        _Assert.IsTrue(StrPos(ResponseText(QuarantinedTaskEntryNo), _ArchivedNeverSentTok) > 0, StrSubstNo('The superseded Modify must record the reason, but recorded: %1', ResponseText(QuarantinedTaskEntryNo)));

        // [THEN] A row whose request may already have reached Shopify is left to finish, and another store's row is out of scope.
        AssertTask(InFlightTaskEntryNo, "NPR Spfy Task State"::"In Flight", 0, 'An in-flight voucher task must be left to finish');
        _Assert.AreEqual('', ResponseText(InFlightTaskEntryNo), 'An in-flight voucher task must not be marked cancelled');
        AssertTask(OtherStoreTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'Another store''s voucher task must be out of scope');
        _Assert.AreEqual('', ResponseText(OtherStoreTaskEntryNo), 'Another store''s voucher task must not be cancelled');

        // [THEN] The deactivation itself completes unsent and the archived row is reconciled to what Shopify holds, which is nothing.
        _Assert.IsTrue(StrPos(ResponseText(DisableTaskEntryNo), _ArchivedNeverSentTok) > 0, StrSubstNo('The deactivation must record that the voucher was never sent, but recorded: %1', ResponseText(DisableTaskEntryNo)));
        ArchVoucher.Get(ArchVoucher."No.");
        _Assert.IsFalse(ArchVoucher."Disabled at Shopify", 'A deactivation that was never sent must clear the archived voucher''s disabled flag');
    end;

    [Test]
    procedure GivenVoucherModifyWithoutId_WhenDispatchedForReal_ThenTypeCoercedToInsertAndCreatePayloadPersisted()
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
        RequestText: Text;
    begin
        // [SCENARIO] A Modify task for a voucher with no gift card id is coerced to a create, and the coercion is persisted with the prepared request.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();
        OtherStoreCode := CreateVoucherStore();

        // [GIVEN] A Modify task for a voucher that has no Shopify gift card yet, enqueued under a store the voucher type does not resolve to.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        RecRef.GetTable(Voucher);
        TaskEntryNo := EnqueueVoucherTask(OtherStoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] It is dispatched for real, so the request preparation runs before the Shopify call fails.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'The dispatch must fail at the Shopify call, after the request was prepared');

        // [THEN] The missing gift card id coerces the op to a create, and the coercion is persisted with the request.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Insert, StrSubstNo('A Modify for a voucher with no gift card id must be coerced to Insert but was %1', SpfyTask.Type));
        _Assert.AreEqual(StoreCode, SpfyTask."Store Code", 'The persisted task must carry the store resolved from the voucher type');
        RequestText := DataOutputText(TaskEntryNo);
        _Assert.IsTrue(StrPos(RequestText, _GiftCardCreateTok) > 0, StrSubstNo('The prepared request must create the gift card, but the request was: %1', RequestText));
        _Assert.AreEqual(0, StrPos(RequestText, _GiftCardUpdateTok), StrSubstNo('The prepared request must not update the gift card, but the request was: %1', RequestText));
    end;

    [Test]
    procedure GivenVoucherInsertWithId_WhenDispatchedForReal_ThenTypeCoercedToModifyAndUpdatePayloadPersisted()
    var
        SyncedVoucher: Record "NPR NpRv Voucher";
        UnsyncedVoucher: Record "NPR NpRv Voucher";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        DeleteTaskEntryNo: BigInteger;
        ErrorText: Text;
        RequestText: Text;
    begin
        // [SCENARIO] An Insert task for a voucher that already has a gift card id is coerced to an update and persisted, while a Delete for a voucher with no id errors instead of being coerced.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] An Insert task for a voucher that already has a Shopify gift card.
        _Lib.CreateVoucherFixture(SyncedVoucher, StoreCode, true);
        RecRef.GetTable(SyncedVoucher);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, SyncedVoucher.RecordId(), SyncedVoucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] It is dispatched for real.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'The dispatch must fail at the Shopify call, after the request was prepared');

        // [THEN] The existing gift card id coerces the op to an update, and the coercion is persisted with the request.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, StrSubstNo('An Insert for a voucher with a gift card id must be coerced to Modify but was %1', SpfyTask.Type));
        RequestText := DataOutputText(TaskEntryNo);
        _Assert.IsTrue(StrPos(RequestText, _GiftCardUpdateTok) > 0, StrSubstNo('The prepared request must update the gift card, but the request was: %1', RequestText));

        // [GIVEN] A Delete task for a voucher that has no Shopify gift card.
        _Lib.CreateVoucherFixture(UnsyncedVoucher, StoreCode, false);
        RecRef.GetTable(UnsyncedVoucher);
        DeleteTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, UnsyncedVoucher.RecordId(), UnsyncedVoucher."No.", "NPR Spfy Task Op"::Delete, AtDateTime);

        // [WHEN] It is dispatched for real.
        // [THEN] A remote delete has nothing to address, so it errors instead of being coerced.
        _Assert.IsFalse(DispatchForReal(DeleteTaskEntryNo, ErrorText), 'A Delete for a voucher with no gift card id must fail');
        _Assert.IsTrue(StrPos(ErrorText, _GiftCardIdRequiredTok) > 0, StrSubstNo('The Delete must report the missing gift card id, but the boundary reported: %1', ErrorText));
    end;

    [Test]
    procedure GivenLiveVoucherArchivedMeanwhile_WhenInsertDispatchesForReal_ThenRecordIdRepointedOnlyWhenArchiveHasId()
    var
        SyncedArchVoucher: Record "NPR NpRv Arch. Voucher";
        UnsyncedArchVoucher: Record "NPR NpRv Arch. Voucher";
        RepointedVoucher: Record "NPR NpRv Voucher";
        UnsyncedVoucher: Record "NPR NpRv Voucher";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        LiveVoucherRecId: RecordId;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        RepointedTaskEntryNo: BigInteger;
        UnsyncedTaskEntryNo: BigInteger;
        ErrorText: Text;
        RequestText: Text;
    begin
        // [SCENARIO] A create whose voucher was archived after the enqueue is re-pointed at the archived row and sent as an update only when that row carries a gift card id, and otherwise completes unsent keeping its enqueued identity.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A gift card create whose voucher was archived after the enqueue, with the gift card id sitting on the archived row.
        _Lib.CreateVoucherFixture(RepointedVoucher, StoreCode, false);
        RecRef.GetTable(RepointedVoucher);
        RepointedTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, RepointedVoucher.RecordId(), RepointedVoucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        ArchiveVoucher(SyncedArchVoucher, RepointedVoucher, true);
        _Lib.AssignEntryID(SyncedArchVoucher.RecordId(), 'gid://gc/arch');

        // [WHEN] It is dispatched for real.
        _Assert.IsFalse(DispatchForReal(RepointedTaskEntryNo, ErrorText), 'The dispatch must fail at the Shopify call, after the request was prepared');

        // [THEN] The task is re-pointed at the archived record and sent as an update, and both are persisted.
        GetTask(RepointedTaskEntryNo, SpfyTask);
        _Assert.AreEqual(SyncedArchVoucher.RecordId(), SpfyTask."Record ID", 'The task must be re-resolved to the archived record');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, StrSubstNo('An Insert whose archived voucher has a gift card id must be coerced to Modify but was %1', SpfyTask.Type));
        RequestText := DataOutputText(RepointedTaskEntryNo);
        _Assert.IsTrue(StrPos(RequestText, _GiftCardUpdateTok) > 0, StrSubstNo('The prepared request must update the gift card, but the request was: %1', RequestText));

        // [GIVEN] The same setup for a voucher whose archived row has no gift card id.
        _Lib.CreateVoucherFixture(UnsyncedVoucher, StoreCode, false);
        LiveVoucherRecId := UnsyncedVoucher.RecordId();
        RecRef.GetTable(UnsyncedVoucher);
        UnsyncedTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, LiveVoucherRecId, UnsyncedVoucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        ArchiveVoucher(UnsyncedArchVoucher, UnsyncedVoucher, true);

        // [WHEN] It is dispatched for real.
        // [THEN] It completes unsent before any re-resolution happens, so the row keeps the identity it was enqueued with.
        _Assert.IsTrue(DispatchForReal(UnsyncedTaskEntryNo, ErrorText), StrSubstNo('A gift card create for an archived voucher with no gift card id must complete unsent: %1', ErrorText));
        _Assert.IsTrue(StrPos(ResponseText(UnsyncedTaskEntryNo), _AlreadyArchivedTok) > 0, StrSubstNo('The create must record that the voucher was already archived, but recorded: %1', ResponseText(UnsyncedTaskEntryNo)));
        GetTask(UnsyncedTaskEntryNo, SpfyTask);
        _Assert.AreEqual(LiveVoucherRecId, SpfyTask."Record ID", 'A create that completes unsent must keep the live voucher record id');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Insert, StrSubstNo('A create that completes unsent must keep its op type but was %1', SpfyTask.Type));
        _Assert.AreEqual('', DataOutputText(UnsyncedTaskEntryNo), 'A create that completes unsent must not have a request prepared');
    end;
    #endregion

    #region Outstanding-sibling facade
    [Test]
    procedure OutstandingTasksExist_FiltersByTableRecordValueAndStore_NeverByType_AndTreatsOnlyCompletedAsDone()
    var
        Voucher: Record "NPR NpRv Voucher";
        OtherVoucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        RecRef: RecordRef;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] The outstanding query counts pending, waiting, quarantined and in-flight rows alike whatever the op type, treats only Completed as done, and ignores rows outside the queried table, record value and store.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();
        OtherStoreCode := CreateVoucherStore();
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        _Lib.CreateVoucherFixture(OtherVoucher, StoreCode, false);
        RecRef.GetTable(Voucher);

        // [GIVEN] A pending voucher task. [THEN] it is outstanding, and completing it is what ends that.
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        _Assert.IsTrue(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A pending voucher task must count as outstanding');
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Completed);
        _Assert.IsFalse(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A completed voucher task must not count as outstanding');

        // [GIVEN] A waiting Modify. [THEN] it counts too: the query is never filtered by op type.
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Waiting);
        _Assert.IsTrue(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A waiting voucher Modify must count as outstanding');
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Completed);

        // [GIVEN] A quarantined Delete. [THEN] it counts too.
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Delete, AtDateTime);
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Quarantined);
        _Assert.IsTrue(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A quarantined voucher Delete must count as outstanding');
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Completed);

        // [GIVEN] An in-flight task. [THEN] it counts too.
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::"In Flight");
        _Assert.IsTrue(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'An in-flight voucher task must count as outstanding');
        SetTaskState(TaskEntryNo, "NPR Spfy Task State"::Completed);

        // [GIVEN] Pending rows outside the queried scope. [THEN] none of them counts.
        EnqueueVoucherTask(OtherStoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        _Assert.IsFalse(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A voucher task in another store must not count as outstanding');
        RecRef.GetTable(OtherVoucher);
        EnqueueVoucherTask(StoreCode, RecRef, OtherVoucher.RecordId(), OtherVoucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        _Assert.IsFalse(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'A voucher task for another voucher must not count as outstanding');
        RecRef.GetTable(VoucherEntry);
        EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        _Assert.IsFalse(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode), 'An entry task must not count as outstanding for the voucher table');
        _Assert.IsTrue(_SpfyTaskQueue.OutstandingTasksExist(Database::"NPR NpRv Voucher Entry", Voucher."No.", StoreCode), 'An entry task must count as outstanding for its own table');
    end;

    [Test]
    procedure CancelOutstandingTasks_CompletesPendingWaitingQuarantinedOnly_WritesReason_SkipsInFlightAndOtherScopes()
    var
        Voucher: Record "NPR NpRv Voucher";
        OtherVoucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        CompletedTaskEntryNo: BigInteger;
        InFlightTaskEntryNo: BigInteger;
        QuarantinedTaskEntryNo: BigInteger;
        WaitingTaskEntryNo: BigInteger;
        PendingTaskEntryNo: BigInteger;
        OtherStoreTaskEntryNo: BigInteger;
        OtherVoucherTaskEntryNo: BigInteger;
        EntryTaskEntryNo: BigInteger;
        CancellationReason: Text;
        PreviousResponse: Text;
    begin
        // [SCENARIO] Cancelling a scope completes every pending, waiting and quarantined row in it with the reason and its claim cleared, while leaving an in-flight row, a sent row and every other scope untouched.
        Initialize();
        AtDateTime := CurrentDateTime();
        CancellationReason := 'superseded by the deactivation';
        PreviousResponse := 'sent before the cancel';
        StoreCode := CreateVoucherStore();
        OtherStoreCode := CreateVoucherStore();
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        _Lib.CreateVoucherFixture(OtherVoucher, StoreCode, false);
        RecRef.GetTable(Voucher);

        // [GIVEN] One voucher task per state, all in the queried scope.
        CompletedTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        _SpfyTaskQueue.CancelUnsentTask(CompletedTaskEntryNo, PreviousResponse);
        InFlightTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        SetTaskState(InFlightTaskEntryNo, "NPR Spfy Task State"::"In Flight");
        QuarantinedTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        SetTaskState(QuarantinedTaskEntryNo, "NPR Spfy Task State"::Quarantined);
        WaitingTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);
        ParkTaskAsWaiting(WaitingTaskEntryNo, 'parked before the cancel', AtDateTime);
        PendingTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);

        // [GIVEN] Pending rows outside the queried scope.
        OtherStoreTaskEntryNo := EnqueueVoucherTask(OtherStoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        RecRef.GetTable(OtherVoucher);
        OtherVoucherTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, OtherVoucher.RecordId(), OtherVoucher."No.", "NPR Spfy Task Op"::Insert, AtDateTime);
        RecRef.GetTable(VoucherEntry);
        EntryTaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, AtDateTime);

        // [WHEN] The scope is cancelled.
        _SpfyTaskQueue.CancelOutstandingTasks(Database::"NPR NpRv Voucher", Voucher."No.", StoreCode, CancellationReason);

        // [THEN] Every unsent row in scope is completed with the reason, whatever its op type or state.
        AssertTask(PendingTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A pending task in scope must be cancelled');
        _Assert.AreEqual(CancellationReason, ResponseText(PendingTaskEntryNo), 'A cancelled pending task must record the reason');
        AssertTask(WaitingTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A waiting task in scope must be cancelled');
        _Assert.AreEqual(CancellationReason, ResponseText(WaitingTaskEntryNo), 'A cancelled waiting task must record the reason');
        AssertTask(QuarantinedTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A quarantined task in scope must be cancelled');
        _Assert.AreEqual(CancellationReason, ResponseText(QuarantinedTaskEntryNo), 'A cancelled quarantined task must record the reason');

        // [THEN] The cancelled rows are stamped as completed with their claim and waiting state cleared.
        GetTask(WaitingTaskEntryNo, SpfyTask);
        _Assert.AreNotEqual(0DT, SpfyTask."Completed At", 'A cancelled task must be stamped as completed');
        _Assert.AreEqual(0DT, SpfyTask."Waiting Since", 'A cancelled task must not stay parked');
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'A cancelled task must not keep its waiting reason');
        _Assert.AreEqual(0DT, SpfyTask."Claimed At", 'A cancelled task must not keep a claim');

        // [THEN] A row whose request may already have reached Shopify is left alone, and a sent row keeps its own response.
        AssertTask(InFlightTaskEntryNo, "NPR Spfy Task State"::"In Flight", 0, 'An in-flight task must be left to finish');
        _Assert.AreEqual('', ResponseText(InFlightTaskEntryNo), 'An in-flight task must not be marked cancelled');
        AssertTask(CompletedTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'An already completed task must be left alone');
        _Assert.AreEqual(PreviousResponse, ResponseText(CompletedTaskEntryNo), 'An already completed task must keep its own response');

        // [THEN] Nothing outside the queried scope is touched.
        AssertTask(OtherStoreTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A task in another store must be out of scope');
        _Assert.AreEqual('', ResponseText(OtherStoreTaskEntryNo), 'A task in another store must not be cancelled');
        AssertTask(OtherVoucherTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A task for another voucher must be out of scope');
        _Assert.AreEqual('', ResponseText(OtherVoucherTaskEntryNo), 'A task for another voucher must not be cancelled');
        AssertTask(EntryTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'An entry task must be out of scope of a voucher-table cancel');
        _Assert.AreEqual('', ResponseText(EntryTaskEntryNo), 'An entry task must not be cancelled by a voucher-table cancel');
    end;
    #endregion

    #region Pair ordering is not an invariant
    [Test]
    procedure GivenTaskListFeatureOnAndUnsyncedEntryPairWithQuarantinedCreate_WhenReDetected_ThenFreshInsertPairsWithReusedModify()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        QuarantinedCreateEntryNo: BigInteger;
        BalanceTaskEntryNo: BigInteger;
        FreshCreateEntryNo: BigInteger;
    begin
        // [SCENARIO] Re-detecting an entry reuses its pending balance update but replaces a quarantined create with a fresh, higher-numbered one, and the reused balance update is dispatched before that fresh create.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A detected pair whose gift card create has quarantined while the balance update is still pending.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        _Lib.DispatchModify(VoucherEntry);
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        QuarantinedCreateEntryNo := SpfyTask."Entry No.";
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        BalanceTaskEntryNo := SpfyTask."Entry No.";
        SetTaskState(QuarantinedCreateEntryNo, "NPR Spfy Task State"::Quarantined);
        SetTaskAttempts(QuarantinedCreateEntryNo, 3);

        // [WHEN] The entry is detected again.
        _Lib.DispatchModify(VoucherEntry);

        // [THEN] The pending balance update is reused while the quarantined create is replaced by a fresh, higher-numbered one.
        _Assert.AreEqual(1, TaskCount(Database::"NPR NpRv Voucher Entry"), 'A re-detected entry must reuse its pending balance update');
        FindLastTask(Database::"NPR NpRv Voucher Entry", SpfyTask);
        _Assert.AreEqual(BalanceTaskEntryNo, SpfyTask."Entry No.", 'The reused balance update must be the original row');
        _Assert.AreEqual(2, TaskCount(Database::"NPR NpRv Voucher"), 'A quarantined create must not be reused');
        FindLastTask(Database::"NPR NpRv Voucher", SpfyTask);
        FreshCreateEntryNo := SpfyTask."Entry No.";
        _Assert.IsTrue(FreshCreateEntryNo > BalanceTaskEntryNo, 'The fresh create must be enqueued after the reused balance update');

        // [WHEN] The next cycle runs. The gift card exists by then, so this test stays about dedup and ordering.
        _Lib.AssignEntryID(Voucher.RecordId(), 'gid://gc/redetected');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The balance update goes first this time: ordering is not the mechanism, the retry is.
        _Assert.AreEqual(2, _BndMock.DispatchCount(), 'Both ready rows must reach the send boundary');
        _Assert.AreEqual(Database::"NPR NpRv Voucher Entry", _BndMock.DispatchTableNoAt(1), 'The reused balance update must be dispatched before the fresh create');
        _Assert.AreEqual(Database::"NPR NpRv Voucher", _BndMock.DispatchTableNoAt(2), 'The fresh create must be dispatched after the reused balance update');
    end;
    #endregion

    #region Voucher sibling Shopify round-trips against the mock GraphQL client (DF14 retrofit)
    [Test]
    procedure GivenUnsyncedVoucherInsert_WhenVoucherSiblingRunsAgainstMock_ThenGiftCardIdFromResponseIsAssigned()
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Task Send Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An unsynced voucher insert creates the gift card and assigns the id Shopify returns.
        Initialize();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A Shopify-integrated voucher with no gift card id and its Insert task.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        RecRef.GetTable(Voucher);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, Voucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [GIVEN] Shopify answers the create with a gift card id.
        MockClient.AddResponse(_GiftCardCreateTok, '{"data":{"giftCardCreate":{"giftCard":{"id":"gid://shopify/GiftCard/7001"},"userErrors":[]}}}');

        // [WHEN] The voucher sibling runs for real.
        GetTask(TaskEntryNo, SpfyTask);
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(SpfyTask);

        // [THEN] The create was sent and the returned gift card id is assigned to the voucher.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_GiftCardCreateTok), 'Exactly one giftCardCreate must be sent');
        _Assert.AreEqual('7001', AssignedGiftCardId(Voucher.RecordId()), 'The gift card id returned by Shopify must be assigned to the voucher');
    end;

    [Test]
    procedure GivenSyncedVoucherEntry_WhenVoucherSiblingRunsAgainstMock_ThenBalanceUpdateSendsWithoutError()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Task Send Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A voucher worth less than the gift card currently holds sends exactly one debit transaction and raises nothing.
        Initialize();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A synced voucher (gift card id assigned) and a balance-update task for one of its entries.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        RecRef.GetTable(VoucherEntry);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, CurrentDateTime());

        // [GIVEN] Shopify reports a balance above the voucher amount (the prep queries the gift card first), so the sibling sends a DEBIT transaction; Shopify confirms it.
        MockClient.AddResponse('GetGiftCard', '{"data":{"giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":40.0,"currencyCode":""},"deactivatedAt":null}}}');
        MockClient.AddResponse('giftCardDebit', '{"data":{"giftCardDebit":{"giftCardDebitTransaction":{"id":"gid://shopify/GiftCardDebitTransaction/1","amount":{"amount":"40","currencyCode":""},"processedAt":"2026-09-01T15:00:00Z","note":"test","giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":"0","currencyCode":""}}},"userErrors":[]}}}');
        MockClient.AddResponse('giftCardCredit', '{"data":{"giftCardCredit":{"giftCardCreditTransaction":{"id":"gid://shopify/GiftCardCreditTransaction/1","amount":{"amount":"40","currencyCode":""},"processedAt":"2026-09-01T15:00:00Z","note":"test","giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":"140","currencyCode":""}}},"userErrors":[]}}}');

        // [WHEN] The voucher sibling runs for real.
        GetTask(TaskEntryNo, SpfyTask);
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(SpfyTask);

        // [THEN] Exactly one balance transaction was sent and the run raised nothing.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardDebit'), 'Exactly one gift card debit transaction must be sent');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('giftCardCredit'), 'A balance above the voucher amount must not send a credit transaction');
    end;

    [Test]
    procedure GivenSyncedVoucherEntryWorthMoreThanShopifyHolds_WhenVoucherSiblingRunsAgainstMock_ThenTheDeltaIsCredited()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Task Send Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A voucher worth more than the gift card currently holds tops the gift card up with a credit transaction for exactly the difference.
        Initialize();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A synced voucher whose remaining amount is 100, and a balance-update task for its entry.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        VoucherEntry."Remaining Amount" := 100;
        VoucherEntry.Modify(false);
        RecRef.GetTable(VoucherEntry);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, VoucherEntry.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Modify, CurrentDateTime());

        // [GIVEN] Shopify reports a balance of 40, below the voucher amount, so the sibling must send a CREDIT transaction; Shopify confirms it.
        MockClient.AddResponse('GetGiftCard', '{"data":{"giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":40.0,"currencyCode":""},"deactivatedAt":null}}}');
        MockClient.AddResponse('giftCardCredit', '{"data":{"giftCardCredit":{"giftCardCreditTransaction":{"id":"gid://shopify/GiftCardCreditTransaction/1","amount":{"amount":"60","currencyCode":""},"processedAt":"2026-09-01T15:00:00Z","note":"test","giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":"100","currencyCode":""}}},"userErrors":[]}}}');

        // [WHEN] The voucher sibling runs for real.
        GetTask(TaskEntryNo, SpfyTask);
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(SpfyTask);

        // [THEN] Exactly one credit transaction was sent, for the difference between the two balances and not for the whole voucher.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('giftCardCredit'), 'Exactly one gift card credit transaction must be sent');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('giftCardDebit'), 'A balance below the voucher amount must not send a debit transaction');
        _Assert.AreNotEqual(
            '', MockClient.GetRequestContaining('giftCardCredit', '"creditAmount":{"amount":"60"'),
            StrSubstNo('The credit must carry the 60 difference but the request was: %1', MockClient.GetRequestContaining('giftCardCredit')));
    end;

    [Test]
    procedure GivenArchivedSyncedVoucherDisable_WhenVoucherSiblingRunsAgainstMock_ThenArchRowStampedDisabledAtShopify()
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        Voucher: Record "NPR NpRv Voucher";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendVoucher: Codeunit "NPR Spfy Task Send Voucher";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        GiftCardDeactivateTok: Label 'giftCardDeactivate', Locked = true;
    begin
        // [SCENARIO] Disabling an archived synced voucher deactivates the gift card and stamps the archive row as disabled at Shopify.
        Initialize();
        StoreCode := CreateVoucherStore();

        // [GIVEN] A synced voucher archived with its gift card id (assigned against the ARCH record — the disable prep resolves the id off the arch row), and its deactivation task.
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        ArchiveVoucher(ArchVoucher, Voucher, true);
        _Lib.AssignEntryID(ArchVoucher.RecordId(), '7001');
        RecRef.GetTable(ArchVoucher);
        TaskEntryNo := EnqueueVoucherTask(StoreCode, RecRef, ArchVoucher.RecordId(), Voucher."No.", "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [GIVEN] Shopify reports the gift card as not yet deactivated (the prep queries it first), then confirms the deactivation with a timestamp.
        MockClient.AddResponse('GetGiftCard', '{"data":{"giftCard":{"id":"gid://shopify/GiftCard/7001","balance":{"amount":100.0,"currencyCode":""},"deactivatedAt":null}}}');
        MockClient.AddResponse(GiftCardDeactivateTok, '{"data":{"giftCardDeactivate":{"giftCard":{"id":"gid://shopify/GiftCard/7001","deactivatedAt":"2026-09-01T10:00:00Z"},"userErrors":[]}}}');

        // [WHEN] The voucher sibling runs for real.
        GetTask(TaskEntryNo, SpfyTask);
        SendVoucher.SetGraphQLClient(MockClient);
        SendVoucher.Run(SpfyTask);

        // [THEN] One giftCardDeactivate was sent and the archived voucher is stamped as disabled at Shopify.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(GiftCardDeactivateTok), 'Exactly one giftCardDeactivate must be sent');
        ArchVoucher.Get(ArchVoucher."No.");
        _Assert.IsTrue(ArchVoucher."Disabled at Shopify", 'The archived voucher must be stamped Disabled at Shopify from the response');
    end;

    local procedure AssignedGiftCardId(BCRecID: RecordId): Text
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(BCRecID, "NPR Spfy ID Type"::"Entry ID"));
    end;
    #endregion
}
