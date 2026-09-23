codeunit 85314 "NPR Spfy TL Ops Tests"
{
    // [FEATURE] Shopify Task List - operator actions, the delete intents they maintain, and task retention
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _NavigatedToStoreCode: Code[20];
        _NotClosedMessage: Text[1024];
        _ClaimDuringConfirmTask: BigInteger;
        _SourceGoneMessages: Integer;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _SourceGoneMessages := 0;
        _NavigatedToStoreCode := '';
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

    local procedure Days(DayCount: Integer): Duration
    begin
        exit(DayCount * 24 * 60 * 60 * 1000);
    end;

    local procedure EnqueueItemTask(StoreCode: Code[20]; Item: Record Item; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, Item.RecordId(), Item."No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueTagTask(StoreCode: Code[20]; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TagUpdateRequest);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, SpfyStoreItemLink.RecordId(), SpfyStoreItemLink."Item No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure CreateTaskInState(StoreCode: Code[20]; NewState: Enum "NPR Spfy Task State"; NewAttempts: Integer; AtDateTime: DateTime) EntryNo: BigInteger
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        EntryNo := EnqueueItemTask(StoreCode, Item, AtDateTime);
        SpfyTask.Get(EntryNo);
        SpfyTask.State := NewState;
        SpfyTask.Attempts := NewAttempts;
        SpfyTask.Modify(false);
    end;

    local procedure CreateDeleteTaskInState(StoreCode: Code[20]; NewState: Enum "NPR Spfy Task State"; AtDateTime: DateTime) EntryNo: BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        EntryNo := CreateTaskInState(StoreCode, NewState, 0, AtDateTime);
        SpfyTask.Get(EntryNo);
        SpfyTask.Type := SpfyTask.Type::Delete;
        SpfyTask.Modify(false);
    end;

    local procedure InsertPendingDeletionLog(StoreCode: Code[20]; ShopifyId: Text[30]): BigInteger
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.Init();
        DeletionLog."Table No." := Database::"NPR Spfy Store-Item Link";
        DeletionLog."Shopify Store Code" := StoreCode;
        DeletionLog."Shopify ID Type" := "NPR Spfy ID Type"::"Entry ID";
        DeletionLog."Shopify ID" := ShopifyId;
        DeletionLog.Status := DeletionLog.Status::Pending;
        DeletionLog.Insert(true);
        exit(DeletionLog."Entry No.");
    end;

    local procedure OpenTaskList(EntryNo: BigInteger; var SpfyTaskList: TestPage "NPR Spfy Task List")
    begin
        SpfyTaskList.OpenView();
        if SpfyTaskList.ShowCompleted.Visible() then
            SpfyTaskList.ShowCompleted.Invoke();
        SpfyTaskList.Filter.SetFilter("Entry No.", Format(EntryNo));
        SpfyTaskList.First();
    end;

    local procedure AssertTask(EntryNo: BigInteger; ExpectedState: Enum "NPR Spfy Task State"; ExpectedAttempts: Integer; FailureMsg: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _Assert.IsTrue(SpfyTask.State = ExpectedState, StrSubstNo('%1: expected state %2 but found %3 with %4 attempt(s)', FailureMsg, ExpectedState, SpfyTask.State, SpfyTask.Attempts));
        _Assert.AreEqual(ExpectedAttempts, SpfyTask.Attempts, StrSubstNo('%1: attempts', FailureMsg));
    end;

    local procedure SeedCompletedAt(StoreCode: Code[20]; NewState: Enum "NPR Spfy Task State"; CompletedAt: DateTime; AtDateTime: DateTime) EntryNo: BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        EntryNo := CreateTaskInState(StoreCode, NewState, 1, AtDateTime);
        SpfyTask.Get(EntryNo);
        SpfyTask."Completed At" := CompletedAt;
        SpfyTask.Modify(false);
    end;

    local procedure TaskExists(EntryNo: BigInteger): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        exit(SpfyTask.Get(EntryNo));
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

    #region Page actions and delete intents
    [Test]
    [HandlerFunctions('NotProcessableMessageHandler')]
    procedure ProcessNowSkipsClaimedTask()
    var
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Process Now sends nothing and leaves a task another session is already sending in flight.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A processing cycle is already sending the task.
        TaskEntryNo := CreateTaskInState(StoreCode, "NPR Spfy Task State"::"In Flight", 1, AtDateTime);

        // [WHEN] The operator asks for it to be processed now.
        OpenTaskList(TaskEntryNo, SpfyTaskList);
        SpfyTaskList.ProcessNow.Invoke();
        SpfyTaskList.Close();

        // [THEN] Nothing is sent and the task is left where it is.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::"In Flight", 1, 'A task being sent right now must be left in flight');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'Process Now must not send a task another session already claimed');
    end;

    [Test]
    [HandlerFunctions('NotRequeueableMessageHandler')]
    procedure RequeueOnlyFailedOrQuarantined()
    var
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FreshTask: BigInteger;
        FailedTask: BigInteger;
        QuarantinedTask: BigInteger;
    begin
        // [SCENARIO] Requeue gives fresh attempts to a failed or quarantined task and leaves a task that never failed alone.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FreshTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 0, AtDateTime);
        FailedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 2, AtDateTime);
        QuarantinedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, 3, AtDateTime);

        // [WHEN] A task that has never failed is requeued.
        OpenTaskList(FreshTask, SpfyTaskList);
        SpfyTaskList.Requeue.Invoke();
        SpfyTaskList.Close();
        AssertTask(FreshTask, "NPR Spfy Task State"::Pending, 0, 'A task that never failed must be left alone by Requeue');

        // [WHEN] A failed task is requeued.
        OpenTaskList(FailedTask, SpfyTaskList);
        SpfyTaskList.Requeue.Invoke();
        SpfyTaskList.Close();
        AssertTask(FailedTask, "NPR Spfy Task State"::Pending, 0, 'A failed task must get fresh attempts from Requeue');

        // [WHEN] A quarantined task is requeued.
        OpenTaskList(QuarantinedTask, SpfyTaskList);
        SpfyTaskList.Requeue.Invoke();
        SpfyTaskList.Close();
        AssertTask(QuarantinedTask, "NPR Spfy Task State"::Pending, 0, 'A quarantined task must become Pending again from Requeue');
    end;

    [Test]
    [HandlerFunctions('NotCompletedMessageHandler,ConfirmYesHandler')]
    procedure ResendOnlyCompleted()
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        PendingTask: BigInteger;
        CompletedTask: BigInteger;
        OriginalDispatchId: Guid;
    begin
        // [SCENARIO] Send Again makes a completed task eligible again with a new dispatch id and leaves an unsent task alone.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        PendingTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 0, AtDateTime);
        CompletedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Completed, 1, AtDateTime);
        SpfyTask.Get(CompletedTask);
        OriginalDispatchId := SpfyTask."Dispatch Id";

        // [WHEN] An unsent task is asked to be sent again.
        OpenTaskList(PendingTask, SpfyTaskList);
        SpfyTaskList.Resend.Invoke();
        SpfyTaskList.Close();
        AssertTask(PendingTask, "NPR Spfy Task State"::Pending, 0, 'An unsent task must be left alone by Send Again');

        // [WHEN] A sent task is asked to be sent again and the operator confirms.
        OpenTaskList(CompletedTask, SpfyTaskList);
        SpfyTaskList.Resend.Invoke();
        SpfyTaskList.Close();

        AssertTask(CompletedTask, "NPR Spfy Task State"::Pending, 0, 'A completed task must become eligible again from Send Again');
        SpfyTask.Get(CompletedTask);
        _Assert.AreNotEqual(OriginalDispatchId, SpfyTask."Dispatch Id", 'A resent task must get a new dispatch id');
    end;

    [Test]
    [HandlerFunctions('NothingToDeleteMessageHandler,ConfirmYesHandler')]
    procedure DeleteBlockedForInFlight()
    var
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        InFlightTask: BigInteger;
        PendingTask: BigInteger;
    begin
        // [SCENARIO] A task being sent right now survives a delete, while an unsent task is deleted once the operator confirms.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        InFlightTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::"In Flight", 1, AtDateTime);
        PendingTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 0, AtDateTime);

        // [WHEN] The operator deletes a task that is being sent right now.
        OpenTaskList(InFlightTask, SpfyTaskList);
        SpfyTaskList.DeleteTasks.Invoke();
        SpfyTaskList.Close();
        _Assert.IsTrue(TaskExists(InFlightTask), 'A task being sent right now must survive a delete');

        // [WHEN] The operator deletes an unsent task and confirms.
        OpenTaskList(PendingTask, SpfyTaskList);
        SpfyTaskList.DeleteTasks.Invoke();
        SpfyTaskList.Close();

        _Assert.IsFalse(TaskExists(PendingTask), 'An unsent task must be deleted on request');
    end;

    [Test]
    [HandlerFunctions('NoneClosableMessageHandler,ConfirmYesHandler')]
    procedure DoNotSendClosesUnsentTasks()
    var
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        InFlightTask: BigInteger;
        WaitingTask: BigInteger;
        QuarantinedTask: BigInteger;
    begin
        // [SCENARIO] Do Not Send closes a waiting or quarantined task with its attempts unchanged and the closer recorded, and refuses a task being sent right now.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        InFlightTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::"In Flight", 1, AtDateTime);
        WaitingTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Waiting, 0, AtDateTime);
        QuarantinedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, 3, AtDateTime);

        // [WHEN] A task being sent right now is closed.
        OpenTaskList(InFlightTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        SpfyTaskList.Close();
        AssertTask(InFlightTask, "NPR Spfy Task State"::"In Flight", 1, 'A task being sent right now must be refused by Do Not Send');

        // [WHEN] A waiting task is closed.
        OpenTaskList(WaitingTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        SpfyTaskList.Close();
        AssertTask(WaitingTask, "NPR Spfy Task State"::Completed, 0, 'A closed waiting task must be Completed with attempts unchanged');
        _Assert.IsTrue(StrPos(ResponseText(WaitingTask), UserId()) > 0, 'The closure reason must record who closed the task');

        // [WHEN] A quarantined task is closed.
        OpenTaskList(QuarantinedTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        SpfyTaskList.Close();
        AssertTask(QuarantinedTask, "NPR Spfy Task State"::Completed, 3, 'A closed quarantined task must be Completed with attempts unchanged');
    end;

    [Test]
    [HandlerFunctions('ClaimDuringConfirmHandler,NotClosedMessageHandler')]
    procedure DoNotSendReportsTheTasksItCouldNotClose()
    var
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A task claimed while the operator is still confirming is left alone and reported back as one the action could not close.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A pending task that the engine claims while the operator is still answering the confirmation.
        _ClaimDuringConfirmTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 0, AtDateTime);
        Clear(_NotClosedMessage);

        // [WHEN] It is closed from the page.
        OpenTaskList(_ClaimDuringConfirmTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        SpfyTaskList.Close();

        // [THEN] The task is left alone and the operator is told the action did less than the confirmation promised,
        // rather than the claimed row simply dropping out of the filter and the action reporting nothing.
        AssertTask(_ClaimDuringConfirmTask, "NPR Spfy Task State"::"In Flight", 1, 'A task claimed in the meantime must be left alone');
        _Assert.IsTrue(StrPos(_NotClosedMessage, '1') > 0, StrSubstNo('The operator must be told one task could not be closed but got: %1', _NotClosedMessage));
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DoNotSendCancelsTheDeleteIntentOfAnAbandonedTask()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        DeleteTask: BigInteger;
        LogEntryNo: BigInteger;
    begin
        // [SCENARIO] Abandoning an unsent delete task cancels its delete intent, which then no longer counts as outstanding.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A drained delete whose Shopify task is still unsent.
        DeleteTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Pending, AtDateTime);
        LogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://abandoned');
        SpfyDeletionLogMgt.MarkProcessed(LogEntryNo, DeleteTask, "NPR Spfy Task Dest Queue"::"Spfy Task");

        // [WHEN] The operator suppresses that task.
        OpenTaskList(DeleteTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        SpfyTaskList.Close();

        // [THEN] The delete intent is cancelled by declaration, not left pointing at a task that will never run.
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'Abandoning the task unsent must cancel the delete intent');
        _Assert.IsFalse(
            SpfyDeletionLogMgt.HasOutstandingDelete(Database::"NPR Spfy Store-Item Link", StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://abandoned'),
            'A cancelled delete intent must no longer count as outstanding');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure DeletingAnUnsentDeleteTaskCancelsTheDeleteIntentButASentOneKeepsIt()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        SentTask: BigInteger;
        SentLogEntryNo: BigInteger;
        UnsentTask: BigInteger;
        UnsentLogEntryNo: BigInteger;
    begin
        // [SCENARIO] Deleting an unsent delete task cancels its delete intent, while a delete that really reached Shopify keeps its processed history.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        UnsentTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, AtDateTime);
        UnsentLogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://unsent');
        SpfyDeletionLogMgt.MarkProcessed(UnsentLogEntryNo, UnsentTask, "NPR Spfy Task Dest Queue"::"Spfy Task");

        SentTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Completed, AtDateTime);
        SentLogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://sent');
        SpfyDeletionLogMgt.MarkProcessed(SentLogEntryNo, SentTask, "NPR Spfy Task Dest Queue"::"Spfy Task");

        // [WHEN] The unsent delete task is deleted outright from the list.
        OpenTaskList(UnsentTask, SpfyTaskList);
        SpfyTaskList.DeleteTasks.Invoke();
        SpfyTaskList.Close();

        // [THEN] Its delete intent dies with it.
        DeletionLog.Get(UnsentLogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'Deleting an unsent delete task must cancel the delete intent');

        // [WHEN] A delete task that already reached Shopify is deleted, as the retention policy would.
        OpenTaskList(SentTask, SpfyTaskList);
        SpfyTaskList.DeleteTasks.Invoke();
        SpfyTaskList.Close();

        // [THEN] The history of a delete that really happened is left intact.
        DeletionLog.Get(SentLogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'A delete that was really sent must keep its Processed history');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ReopeningASuppressedDeleteTaskPutsItsDeleteIntentBackInPlay()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        DeleteTask: BigInteger;
        LogEntryNo: BigInteger;
    begin
        // [SCENARIO] Sending a suppressed delete task again reopens it and puts its delete intent back in play as outstanding.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A delete task the operator suppressed, so its delete intent was cancelled.
        DeleteTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Pending, AtDateTime);
        LogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://reopened');
        SpfyDeletionLogMgt.MarkProcessed(LogEntryNo, DeleteTask, "NPR Spfy Task Dest Queue"::"Spfy Task");
        OpenTaskList(DeleteTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'The suppressed delete intent must start out cancelled');

        // [WHEN] The operator reopens the task with Send Again, as the suppression prompt says they can.
        SpfyTaskList.Resend.Invoke();
        SpfyTaskList.Close();

        // [THEN] The intent is live again, so the reactivation guard can still stop the delete.
        AssertTask(DeleteTask, "NPR Spfy Task State"::Pending, 0, 'Send Again must reopen the suppressed delete task');
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'Reopening the task must put its delete intent back in play');
        _Assert.IsTrue(
            SpfyDeletionLogMgt.HasOutstandingDelete(Database::"NPR Spfy Store-Item Link", StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://reopened'),
            'A reopened delete task must count as an outstanding delete again');
    end;

    [Test]
    procedure AQuarantinedDeleteIntentStillCountsAsOutstanding()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
        Outstanding: Boolean;
    begin
        // [SCENARIO] A delete intent parked in quarantine still counts as outstanding, so reactivating the entity can still stop the delete.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A variant delete intent that ran out of dispatch attempts and was quarantined.
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::"Item Variant", Item."No.", ItemVariant.Code, '', StoreCode, 'gid://variant/quarantined');
        DeletionLog.Get(DeleteEntryNo);
        DeletionLog.Status := DeletionLog.Status::Quarantined;
        DeletionLog.Modify(false);

        // [WHEN] The outstanding check is asked about that Shopify id.
        Outstanding := SpfyDeletionLogMgt.HasOutstandingDelete(Database::"Item Variant", StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://variant/quarantined');

        // [THEN] The intent is reported as one that still needs sending, exactly as a pending one would be.
        _Assert.IsTrue(Outstanding, 'A quarantined delete intent must count as outstanding');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ReopeningADeleteTaskRestoresItsIntentAlongsideAQuarantinedSibling()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        EntitySystemId: Guid;
        DeleteTask: BigInteger;
        LogEntryNo: BigInteger;
        SiblingLogEntryNo: BigInteger;
    begin
        // [SCENARIO] Reopening a suppressed delete task restores its own intent even when a quarantined sibling intent shares the Shopify id.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        EntitySystemId := CreateGuid();

        // [GIVEN] A suppressed delete task whose intent was cancelled, and a second quarantined intent for the same entity and Shopify id.
        DeleteTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Pending, AtDateTime);
        LogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://sibling');
        DeletionLog.Get(LogEntryNo);
        DeletionLog."Entity System Id" := EntitySystemId;
        DeletionLog.Modify(false);
        SpfyDeletionLogMgt.MarkProcessed(LogEntryNo, DeleteTask, "NPR Spfy Task Dest Queue"::"Spfy Task");
        SiblingLogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://sibling');
        DeletionLog.Get(SiblingLogEntryNo);
        DeletionLog."Entity System Id" := EntitySystemId;
        DeletionLog.Status := DeletionLog.Status::Quarantined;
        DeletionLog.Modify(false);
        OpenTaskList(DeleteTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'The suppressed delete intent must start out cancelled');

        // [WHEN] The operator reopens the task with Send Again.
        SpfyTaskList.Resend.Invoke();
        SpfyTaskList.Close();

        // [THEN] The reopened task's own intent is back in play, instead of being left cancelled because a sibling intent is outstanding.
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, StrSubstNo('Reopening the task must restore its own delete intent but the row was %1', DeletionLog.Status));

        // [WHEN] The entity is reactivated in Business Central afterwards.
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"NPR Spfy Store-Item Link", StoreCode, EntitySystemId);

        // [THEN] Both intents are cancelled and the reopened task is closed, so the delete cannot reach Shopify behind the user.
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, StrSubstNo('Reactivating the entity must cancel the reopened delete intent but the row was %1', DeletionLog.Status));
        DeletionLog.Get(SiblingLogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, StrSubstNo('Reactivating the entity must cancel the quarantined sibling intent but the row was %1', DeletionLog.Status));
        AssertTask(DeleteTask, "NPR Spfy Task State"::Completed, 0, 'Reactivating the entity must cancel the reopened delete task');
    end;

    [Test]
    [HandlerFunctions('NotRequeueableMessageHandler,ConfirmYesHandler')]
    procedure ClosedTaskRevivableBySendAgainNotRequeue()
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ClosedTask: BigInteger;
        OriginalDispatchId: Guid;
    begin
        // [SCENARIO] Requeue ignores a closed task while Send Again revives it with a new dispatch id.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        ClosedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, 3, AtDateTime);
        SpfyTask.Get(ClosedTask);
        OriginalDispatchId := SpfyTask."Dispatch Id";

        OpenTaskList(ClosedTask, SpfyTaskList);
        SpfyTaskList.DoNotSend.Invoke();

        // [WHEN] Requeue is tried on the closed task.
        SpfyTaskList.Requeue.Invoke();
        AssertTask(ClosedTask, "NPR Spfy Task State"::Completed, 3, 'Requeue must ignore a closed task');

        // [WHEN] Send Again is used instead.
        SpfyTaskList.Resend.Invoke();
        SpfyTaskList.Close();
        AssertTask(ClosedTask, "NPR Spfy Task State"::Pending, 0, 'Send Again must revive a closed task');
        SpfyTask.Get(ClosedTask);
        _Assert.AreNotEqual(OriginalDispatchId, SpfyTask."Dispatch Id", 'A revived task must get a new dispatch id');
    end;

    [Test]
    [HandlerFunctions('SourceGoneMessageHandler,StoreItemLinksPageHandler')]
    procedure SourceNavigationResolvesRecordId()
    var
        GoneItem: Record Item;
        LiveItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTaskList: TestPage "NPR Spfy Task List";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        LiveTask: BigInteger;
        GoneTask: BigInteger;
    begin
        // [SCENARIO] Opening a task's source record navigates to a record that still exists and reports one that is gone, leaving the task itself alone.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(LiveItem);
        _Lib.CreateItem(GoneItem);
        _Lib.CreateItemLink(SpfyStoreItemLink, LiveItem."No.", StoreCode, true, false);
        LiveTask := EnqueueTagTask(StoreCode, SpfyStoreItemLink, AtDateTime);
        GoneTask := EnqueueItemTask(StoreCode, GoneItem, AtDateTime);
        _Assert.AreNotEqual(LiveTask, GoneTask, 'The two tasks must refer to different source records');

        // [WHEN] The operator opens the source record of a task whose record still exists.
        OpenTaskList(LiveTask, SpfyTaskList);
        SpfyTaskList.OpenSourceRecord.Invoke();
        SpfyTaskList.Close();

        // [THEN] The record id resolves, so the operator is taken to the record instead of being told it is missing.
        _Assert.AreEqual(0, _SourceGoneMessages, 'The source record of a live task must be navigated to, not reported as missing');
        _Assert.AreEqual(StoreCode, _NavigatedToStoreCode, 'The navigation must land on the record the task refers to');

        // [WHEN] The same is asked for a task whose record is gone.
        GoneItem.Delete(false);
        OpenTaskList(GoneTask, SpfyTaskList);
        SpfyTaskList.OpenSourceRecord.Invoke();
        SpfyTaskList.Close();

        _Assert.AreEqual(1, _SourceGoneMessages, 'A task whose source record is gone must report exactly that');
        _Assert.IsTrue(TaskExists(GoneTask), 'A task whose source record is gone must survive the navigation attempt');
    end;
    #endregion

    #region Retention
    [Test]
    procedure RetentionDeletesOnlyOldCompleted()
    var
        RetentionPolicy: Record "NPR Retention Policy";
        RetPolSpfyTask: Codeunit "NPR Ret.Pol.: Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ReferenceDateTime: DateTime;
        ExpirationDateTime: DateTime;
        OldCompletedTask: BigInteger;
        RecentCompletedTask: BigInteger;
        AtBoundaryTask: BigInteger;
        JustExpiredTask: BigInteger;
        OldPendingTask: BigInteger;
        OldWaitingTask: BigInteger;
        OldQuarantinedTask: BigInteger;
    begin
        // [SCENARIO] Retention deletes only completed tasks past the period, keeping the boundary row and anything still unsent.
        Initialize();
        AtDateTime := CurrentDateTime();
        ReferenceDateTime := CreateDateTime(WorkDate(), 120000T);
        ExpirationDateTime := CreateDateTime(CalcDate('<-14D>', DT2Date(ReferenceDateTime)), DT2Time(ReferenceDateTime));
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        OldCompletedTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Completed, ReferenceDateTime - Days(20), AtDateTime);
        RecentCompletedTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Completed, ReferenceDateTime - Days(1), AtDateTime);
        AtBoundaryTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Completed, ExpirationDateTime, AtDateTime);
        JustExpiredTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Completed, ExpirationDateTime - 1000, AtDateTime);
        OldPendingTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Pending, ReferenceDateTime - Days(20), AtDateTime);
        OldWaitingTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Waiting, ReferenceDateTime - Days(20), AtDateTime);
        OldQuarantinedTask := SeedCompletedAt(StoreCode, "NPR Spfy Task State"::Quarantined, ReferenceDateTime - Days(20), AtDateTime);

        // [WHEN] The retention policy for the task list runs.
        RetentionPolicy."Table Id" := Database::"NPR Spfy Task";
        RetentionPolicy."Implementation V2" := "NPR Retention Policy V2"::"NPR Spfy Task";
        RetPolSpfyTask.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        // [THEN] Only completed tasks older than the retention period are gone.
        _Assert.IsFalse(TaskExists(OldCompletedTask), 'A completed task older than the retention period must be deleted');
        _Assert.IsFalse(TaskExists(JustExpiredTask), 'A completed task one second past the retention period must be deleted');
        _Assert.IsTrue(TaskExists(AtBoundaryTask), 'A completed task exactly at the retention limit must be kept');
        _Assert.IsTrue(TaskExists(RecentCompletedTask), 'A recently completed task must be kept');
        _Assert.IsTrue(TaskExists(OldPendingTask), 'An unsent task must never be deleted by the retention policy');
        _Assert.IsTrue(TaskExists(OldWaitingTask), 'A waiting task must never be deleted by the retention policy');
        _Assert.IsTrue(TaskExists(OldQuarantinedTask), 'A recently created quarantined task must be kept by the retention policy');
    end;

    [Test]
    procedure RetentionDeletesOldQuarantinedTasks()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        RetentionPolicy: Record "NPR Retention Policy";
        RetPolSpfyTask: Codeunit "NPR Ret.Pol.: Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ReferenceDateTime: DateTime;
        QuarantinedTask: BigInteger;
        QuarantinedDeleteTask: BigInteger;
        PendingTask: BigInteger;
        WaitingTask: BigInteger;
        LogEntryNo: BigInteger;
    begin
        // [SCENARIO] Retention purges quarantined tasks past the period, leaves their delete intents inert, and spares unsent and waiting tasks.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] Quarantined, unsent and waiting tasks, and a quarantined delete task that still owns a delete intent.
        QuarantinedTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, 3, AtDateTime);
        PendingTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Pending, 0, AtDateTime);
        WaitingTask := CreateTaskInState(StoreCode, "NPR Spfy Task State"::Waiting, 0, AtDateTime);
        QuarantinedDeleteTask := CreateDeleteTaskInState(StoreCode, "NPR Spfy Task State"::Quarantined, AtDateTime);
        LogEntryNo := InsertPendingDeletionLog(StoreCode, 'gid://expired');
        SpfyDeletionLogMgt.MarkProcessed(LogEntryNo, QuarantinedDeleteTask, "NPR Spfy Task Dest Queue"::"Spfy Task");

        // [WHEN] The retention policy runs far enough ahead that every row is past the quarantine period.
        ReferenceDateTime := CreateDateTime(CalcDate('<+14M>', DT2Date(AtDateTime)), DT2Time(AtDateTime));
        RetentionPolicy."Table Id" := Database::"NPR Spfy Task";
        RetentionPolicy."Implementation V2" := "NPR Retention Policy V2"::"NPR Spfy Task";
        RetPolSpfyTask.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        // [THEN] Both quarantined tasks are gone and the tasks that still have work to do are untouched.
        _Assert.IsFalse(TaskExists(QuarantinedTask), 'A quarantined task past the quarantine period must be deleted');
        _Assert.IsFalse(TaskExists(QuarantinedDeleteTask), 'A quarantined delete task past the quarantine period must be deleted');
        _Assert.IsTrue(TaskExists(PendingTask), 'An unsent task must never be deleted by the retention policy');
        _Assert.IsTrue(TaskExists(WaitingTask), 'A waiting task must never be deleted by the retention policy');

        // [THEN] The intent row is left for the deletion log policy, and with its task gone nothing reads it as outstanding.
        DeletionLog.Get(LogEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, StrSubstNo('A purged delete task must leave its intent row for the deletion log policy but the row was %1', DeletionLog.Status));
        _Assert.IsFalse(
            SpfyDeletionLogMgt.HasOutstandingDelete(Database::"NPR Spfy Store-Item Link", StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://expired'),
            'An intent row whose task no longer exists must not read as outstanding');
    end;

    [Test]
    procedure RetentionDefaultPeriodsMatch()
    var
        RetPolSpfyTask: Codeunit "NPR Ret.Pol.: Spfy Task";
        EmptyPeriod: DateFormula;
        ExpectedPeriod: DateFormula;
        ExpectedPeriod2: DateFormula;
    begin
        // [SCENARIO] Completed tasks default to two weeks, quarantined tasks to one year, and no third period is defined.
        Initialize();
        Evaluate(ExpectedPeriod, '<-14D>');
        Evaluate(ExpectedPeriod2, '<-1Y>');

        _Assert.AreEqual(Format(ExpectedPeriod), Format(RetPolSpfyTask.GetDefaultRetentionPeriod("NPR Retention Period Type"::"Period 1")), 'Completed tasks must default to a two week retention period');
        _Assert.AreEqual(Format(ExpectedPeriod2), Format(RetPolSpfyTask.GetDefaultRetentionPeriod("NPR Retention Period Type"::"Period 2")), 'Quarantined tasks must default to a one year retention period');
        _Assert.AreEqual(Format(EmptyPeriod), Format(RetPolSpfyTask.GetDefaultRetentionPeriod("NPR Retention Period Type"::"Period 3")), 'The task list must not define a third retention period');
    end;
    #endregion

    [MessageHandler]
    procedure NotProcessableMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, 'processed manually') > 0, StrSubstNo('The operator must be told the task cannot be processed in its current state: %1', Message));
    end;

    [MessageHandler]
    procedure NotRequeueableMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, 'requeued') > 0, StrSubstNo('The operator must be told which tasks can be requeued: %1', Message));
    end;

    [MessageHandler]
    procedure NotCompletedMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, 'sent again') > 0, StrSubstNo('The operator must be told only a completed task can be sent again: %1', Message));
    end;

    [MessageHandler]
    procedure NoneClosableMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, 'can be closed') > 0, StrSubstNo('The operator must be told which tasks can be closed: %1', Message));
    end;

    [MessageHandler]
    procedure NothingToDeleteMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, 'has to finish first') > 0, StrSubstNo('The operator must be told a task being sent right now has to finish first: %1', Message));
    end;

    [MessageHandler]
    procedure SourceGoneMessageHandler(Message: Text[1024])
    begin
        _SourceGoneMessages += 1;
        _Assert.IsTrue(StrPos(Message, 'no longer exists') > 0, StrSubstNo('The operator must be told the source record is gone: %1', Message));
    end;

    [PageHandler]
    procedure StoreItemLinksPageHandler(var SpfyStoreItemLinks: TestPage "NPR Spfy Store-Item Links")
    begin
        _NavigatedToStoreCode := CopyStr(SpfyStoreItemLinks."Shopify Store Code".Value(), 1, MaxStrLen(_NavigatedToStoreCode));
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _Assert.IsTrue(Question <> '', 'The operator must be asked to confirm before an irreversible action');
        Reply := true;
    end;

    // The confirmation is the only point inside the action where the engine can still get between the page's
    // selection and the loop that acts on it, so it is where the claim is simulated.
    [ConfirmHandler]
    procedure ClaimDuringConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(_ClaimDuringConfirmTask);
        SpfyTask.State := SpfyTask.State::"In Flight";
        SpfyTask.Attempts := 1;
        SpfyTask.Modify(false);
        Reply := true;
    end;

    [MessageHandler]
    procedure NotClosedMessageHandler(Message: Text[1024])
    begin
        _NotClosedMessage := Message;
    end;
}
