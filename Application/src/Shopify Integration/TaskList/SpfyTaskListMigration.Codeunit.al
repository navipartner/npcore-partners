codeunit 6151245 "NPR Spfy Task List Migration"
{
    Access = Internal;
    SingleInstance = true;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed then
            exit;
        // Access = Internal does not stop the Job Queue dispatcher, so this entry needs the gate check too.
        // It sits after the Completed short-circuit so a queued job on an already-migrated environment exits cleanly.
        CheckFeatureIsAvailable();
        // Only a run holding the lease MigrateAndEnable stamped may cut over; anything else (a retry after Failed, a hand-made entry) must not start one.
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::Migrating then
            exit;
        Commit();
        RunCutoverIsolated();
    end;

    procedure MigrateAndEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTLSchedBgMigr: Codeunit "NPR Spfy TL Sched Bg Migr";
        RunForeground: Boolean;
        BackgroundStartedMsg: Label 'The Shopify task list migration has been started in the background. It drains the remaining NaviConnect tasks and enables the Shopify task list automatically. The migration details stay on the Shopify Integration Setup page until it has completed; if it fails or stalls, re-run the migration from there.';
        BackgroundNeedsActivationMsg: Label 'The Shopify task list migration job has been created, but your user cannot start scheduled tasks. Ask an administrator to set the job to Ready on the Job Queue Entries page; the migration will then run in the background.';
    begin
        SetMigrationInProgress(false);
        CheckFeatureIsAvailable();
        if not PromptRunMode(RunForeground) then
            exit;
        AcquireLock(SpfyIntegrationSetup);
        // A platform retry of a failed background run must not fire once a new run owns the lease.
        CancelPendingMigrationEntries();
        MarkMigrationStarted(SpfyIntegrationSetup);
        if RunForeground then begin
            RunCutoverIsolated();
            exit;
        end;
        if not SpfyTLSchedBgMigr.Run() then begin
            SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Failed);
            Error(GetLastErrorText());
        end;
        if MigrationEntryIsOnHold() then
            Message(BackgroundNeedsActivationMsg)
        else
            Message(BackgroundStartedMsg);
    end;

    local procedure MigrationEntryIsOnHold(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task List Migration");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        exit(not JobQueueEntry.IsEmpty());
    end;

    local procedure CheckFeatureIsAvailable()
    var
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        FeatureNotYetAvailableErr: Label '%1 ships across several releases and cannot be activated yet.', Comment = '%1 = feature description';
    begin
        if not SpfyTaskListFeature.AllPhasesShipped() then
            Error(FeatureNotYetAvailableErr, SpfyTaskListFeature.GetFeatureDescription());
    end;

    local procedure PromptRunMode(var RunForeground: Boolean): Boolean
    var
        ModeInstructionLbl: Label 'Migrate this environment from the NaviConnect task list to the Shopify task list. This is a one-way change that affects every Shopify store in this environment.\\Run in foreground = run now in this session (blocking) — fine for a small backlog of unprocessed tasks.\Run in background = run as a Job Queue task (recommended when there is a large backlog); it drains the remaining tasks and cuts over automatically.';
        ModeOptionsLbl: Label 'Run in foreground,Run in background';
    begin
        case StrMenu(ModeOptionsLbl, 2, ModeInstructionLbl) of
            1:
                RunForeground := true;
            2:
                RunForeground := false;
            else
                exit(false);
        end;
        exit(true);
    end;

    internal procedure AcquireLock(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    var
        MigrationInProgressErr: Label 'A Shopify task list migration is already in progress.';
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Migrating then
            if not RunIsStale(SpfyIntegrationSetup) then
                Error(MigrationInProgressErr);
    end;

    // The lease is persisted and committed before dispatch so a second admin cannot pass AcquireLock while a background run is starting.
    local procedure MarkMigrationStarted(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Migrating);
    end;

    // Any trapped failure of the cutover transitions the status to Failed; only a hard crash can leave it at Migrating.
    internal procedure RunCutoverIsolated()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTLMigrWorker: Codeunit "NPR Spfy TL Migr Worker";
        CutoverErrorText: Text;
        CutoverOk: Boolean;
    begin
        _CutoverAuthorized := true;
        CutoverOk := SpfyTLMigrWorker.Run();
        _CutoverAuthorized := false;
        if CutoverOk then
            exit;
        CutoverErrorText := GetLastErrorText();
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Failed);
        Error(CutoverErrorText);
    end;

    internal procedure RunEnvironmentCutover(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    var
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
    begin
        // Fresh start time so a concurrent admin's staleness check doesn't misclassify this live run.
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Migrating);
        EnableFeatureWithBypass();
        HandOverLegacyQueue();
        // Ensure the jobs before marking Completed so a scheduling failure leaves the migration re-runnable.
        SpfyTaskJQSetup.SetupTaskProcessingJobQueuesForMigration();
        // The heartbeat writes its own instance of this row during the drain, so ours is stale by now.
        SpfyIntegrationSetup.GetRecordOnce(true);
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Completed);
    end;

    // Codeunit.Run (not [TryFunction]) so DB writes roll back on failure and the bypass flag clears on both outcomes.
    local procedure EnableFeatureWithBypass()
    var
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        EnableOk: Boolean;
    begin
        SetMigrationInProgress(true);
        EnableOk := SpfyTaskListFeature.Run();
        SetMigrationInProgress(false);
        if not EnableOk then
            Error(GetLastErrorText());
        Commit();
    end;

    // An empty Shopify handler ID means there is no Shopify NaviConnect processor at all: nothing to quiesce, drain or verify.
    local procedure HandOverLegacyQueue()
    var
        FailWithErrorText: Text;
    begin
        OnBeforeHandOverLegacyQueue(FailWithErrorText);
        if FailWithErrorText <> '' then
            Error(FailWithErrorText);
        if ShopifyTaskProcessorCode() = '' then
            exit;
        QuiesceLegacySenders();
        DrainLegacyQueue();
        RecreateRemainingLegacyRows();
        AlertOnDeadRemainder();
        VerifyNoActionableLegacyRows();
    end;

    local procedure QuiesceLegacySenders()
    var
        TempRunningJobQueueEntry: Record "Job Queue Entry" temporary;
        Deadline: DateTime;
        SendersWereRunning: Boolean;
    begin
        Deadline := CurrentDateTime() + QuiesceTimeout();
        repeat
            CheckQuiesceDeadline(Deadline);
            SendersWereRunning := SnapshotRunningLegacySenders(TempRunningJobQueueEntry);
            CancelLegacyShopifyJobQueues();
            Commit();
            WaitForSnapshottedSenders(TempRunningJobQueueEntry, Deadline);
        until not SendersWereRunning;
    end;

    local procedure CheckQuiesceDeadline(Deadline: DateTime)
    var
        QuiesceTimeoutErr: Label 'The Shopify task list migration timed out after %1 waiting for the running NaviConnect task processing sessions to finish. The migration has been marked as failed and can be run again.', Comment = '%1 = the time the migration waited';
    begin
        if CurrentDateTime() >= Deadline then
            Error(QuiesceTimeoutErr, QuiesceTimeout());
    end;

    // The cancel deletes the Job Queue Entry rows, so the barrier has to watch the sessions those entries were running in.
    local procedure SnapshotRunningLegacySenders(var TempRunningJobQueueEntry: Record "Job Queue Entry" temporary): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        TempRunningJobQueueEntry.Reset();
        if not TempRunningJobQueueEntry.IsEmpty() then
            TempRunningJobQueueEntry.DeleteAll();

        FilterLegacyShopifyJobQueues(JobQueueEntry);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        JobQueueEntry.SetLoadFields(ID, "User Service Instance ID", "User Session ID");
        if not JobQueueEntry.FindSet() then
            exit(false);
        repeat
            TempRunningJobQueueEntry.Init();
            TempRunningJobQueueEntry.ID := JobQueueEntry.ID;
            TempRunningJobQueueEntry."User Service Instance ID" := JobQueueEntry."User Service Instance ID";
            TempRunningJobQueueEntry."User Session ID" := JobQueueEntry."User Session ID";
            TempRunningJobQueueEntry.Insert();
        until JobQueueEntry.Next() = 0;
        exit(true);
    end;

    local procedure WaitForSnapshottedSenders(var TempRunningJobQueueEntry: Record "Job Queue Entry" temporary; Deadline: DateTime)
    begin
        while SnapshottedSenderIsAlive(TempRunningJobQueueEntry) do begin
            CheckQuiesceDeadline(Deadline);
            Sleep(QuiescePollInterval());
            RefreshRunHeartbeat();
            Commit();
        end;
    end;

    local procedure SnapshottedSenderIsAlive(var TempRunningJobQueueEntry: Record "Job Queue Entry" temporary): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if not TempRunningJobQueueEntry.FindSet() then
            exit(false);
        repeat
            if ActiveSession.Get(TempRunningJobQueueEntry."User Service Instance ID", TempRunningJobQueueEntry."User Session ID") then
                exit(true);
        until TempRunningJobQueueEntry.Next() = 0;
        exit(false);
    end;

    local procedure CancelLegacyShopifyJobQueues()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        FilterLegacyShopifyJobQueues(JobQueueEntry);
        if not JobQueueEntry.IsEmpty() then
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
    end;

    local procedure CancelPendingMigrationEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task List Migration");
        JobQueueEntry.SetFilter(Status, '<>%1', JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
    end;

    local procedure FilterLegacyShopifyJobQueues(var JobQueueEntry: Record "Job Queue Entry")
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        FilterPlaceholderTok: Label '@*%1?%2*', Locked = true;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
        JobQueueEntry.SetFilter("Parameter String", StrSubstNo(FilterPlaceholderTok, NcTaskListProcessing.ParamProcessor(), ShopifyTaskProcessorCode()));
    end;

    local procedure DrainLegacyQueue()
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Deadline: DateTime;
        DrainTimeoutErr: Label 'The Shopify task list migration timed out after %1 draining the remaining NaviConnect tasks. The migration has been marked as failed and can be run again.', Comment = '%1 = the time the migration spent draining the queue';
    begin
        if not NcTaskProcessor.Get(ShopifyTaskProcessorCode()) then
            exit;
        Deadline := CurrentDateTime() + QuiesceTimeout();
        repeat
            if CurrentDateTime() >= Deadline then
                Error(DrainTimeoutErr, QuiesceTimeout());
            UnpostponeActionableLegacyRows();
            NcSyncMgt.ProcessTasks(NcTaskProcessor, '', LegacyAttemptCap());
            RefreshRunHeartbeat();
            Commit();
        until not ActionableLegacyRowsPending();
    end;

    // The frozen batch processor leaves failed batch rows postponed, so the rescue has to run in every pass, not just once.
    local procedure UnpostponeActionableLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetRange(Postponed, true);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        if NcTask.IsEmpty() then
            exit;
        NcTask.ModifyAll("Postponed At", 0DT);
        NcTask.ModifyAll(Postponed, false);
        Commit();
    end;

    local procedure ActionableLegacyRowsPending(): Boolean
    var
        NcTask: Record "NPR Nc Task";
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetRange(Postponed, false);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        NcTask.SetFilter("Not Before Date-Time", '%1|..%2', 0DT, CurrentDateTime());
        if not NcTask.IsEmpty() then
            exit(true);

        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetRange(Postponed, true);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        exit(not NcTask.IsEmpty());
    end;

    local procedure RecreateRemainingLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        NcTask.SetLoadFields("Entry No.");
        if not NcTask.FindSet() then
            exit;
        repeat
            RecreateLegacyRowInNewQueue(NcTask);
        until NcTask.Next() = 0;
    end;

    internal procedure RecreateLegacyRowInNewQueue(NcTaskParam: Record "NPR Nc Task") NewTaskEntryNo: BigInteger
    var
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTask2: Record "NPR Spfy Task";
        OStream: OutStream;
        MigratedResponseLbl: Label 'Migrated to Shopify Task List task %1', Comment = '%1 = Shopify task entry number';
    begin
        NcTask.ReadIsolation(IsolationLevel::UpdLock);
        if not NcTask.Get(NcTaskParam."Entry No.") then
            exit(0);
        if NcTask.Processed then
            exit(0);
        // The Shopify task op enum has no Rename counterpart, so such a row must not be mapped by ordinal.
        if NcTask.Type = NcTask.Type::Rename then
            exit(0);

        SpfyTask2.SetCurrentKey("Migrated From NC Entry No.");
        SpfyTask2.SetRange("Migrated From NC Entry No.", NcTask."Entry No.");
        SpfyTask2.SetLoadFields("Entry No.");
        if SpfyTask2.FindFirst() then
            NewTaskEntryNo := SpfyTask2."Entry No."
        else begin
            SpfyTask.Init();
            SpfyTask."Entry No." := 0;
            SpfyTask.Type := Enum::"NPR Spfy Task Op".FromInteger(NcTask.Type);
            SpfyTask."Table No." := NcTask."Table No.";
            SpfyTask."Record ID" := NcTask."Record ID";
            SpfyTask."Record Value" := NcTask."Record Value";
            SpfyTask."Store Code" := NcTask."Store Code";
            SpfyTask."Not Before Date-Time" := NcTask."Not Before Date-Time";
            SpfyTask."Log Date" := NcTask."Log Date";
            SpfyTask.State := SpfyTask.State::Pending;
            SpfyTask."Dispatch Id" := CreateGuid();
            SpfyTask."Migrated From NC Entry No." := NcTask."Entry No.";
            SpfyTask.Insert(true);
            NewTaskEntryNo := SpfyTask."Entry No.";
        end;

        RepointLegacyProvenance(NcTask."Entry No.", NewTaskEntryNo);
        NcTask.Processed := true;
        NcTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(StrSubstNo(MigratedResponseLbl, NewTaskEntryNo));
        NcTask.Modify(true);
        // Per row: a later failure must never roll back the rows already migrated.
        Commit();
    end;

    // The migrated NC row is dead: anything still pointing at it must follow the task into the new queue,
    // or reactivation-cancel and the NC retention cascade hit the wrong row.
    local procedure RepointLegacyProvenance(NcTaskEntryNo: BigInteger; NewTaskEntryNo: BigInteger)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
    begin
        DeletionLog.SetRange("NC Task Entry No.", NcTaskEntryNo);
        if not DeletionLog.IsEmpty() then begin
            DeletionLog.ModifyAll("Spfy Task Entry No.", NewTaskEntryNo);
            DeletionLog.ModifyAll("NC Task Entry No.", 0);
        end;
        TagUpdateRequest.SetRange("Nc Task Entry No.", NcTaskEntryNo);
        if not TagUpdateRequest.IsEmpty() then begin
            TagUpdateRequest.ModifyAll("Spfy Task Entry No.", NewTaskEntryNo);
            TagUpdateRequest.ModifyAll("Nc Task Entry No.", 0);
        end;
    end;

    local procedure AlertOnDeadRemainder()
    var
        NcTask: Record "NPR Nc Task";
        Sentry: Codeunit "NPR Sentry";
        ResidualCount: Integer;
        ResidualAlertLbl: Label 'The Shopify task list migration left %1 NaviConnect task(s) behind because they had already exhausted their processing attempts; the updates they carry will not be sent to Shopify without a re-sync.', Locked = true;
        ResidualMsg: Label '%1 NaviConnect task(s) could not be processed because they had already exhausted their processing attempts. They were left untouched and the updates they carry have not been sent to Shopify. Use a re-sync to recover the affected records.', Comment = '%1 = number of NaviConnect tasks left behind';
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '>=%1', LegacyAttemptCap());
        ResidualCount := NcTask.Count();
        if ResidualCount = 0 then
            exit;
        Sentry.InitScopeAndTransaction('Shopify task list migration residual', 'bc.spfy.task_list.migration_residual');
        Sentry.AddError(StrSubstNo(ResidualAlertLbl, ResidualCount));
        Sentry.FinalizeScope();
        if GuiAllowed() then
            Message(ResidualMsg, ResidualCount);
    end;

    local procedure VerifyNoActionableLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
        NotDrainedErr: Label 'The Shopify task list migration could not process %1 NaviConnect task(s). The migration has been marked as failed and can be run again.', Comment = '%1 = number of NaviConnect tasks still awaiting processing';
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        if not NcTask.IsEmpty() then
            Error(NotDrainedErr, NcTask.Count());
    end;

    internal procedure FilterUnprocessedLegacyRows(var NcTask: Record "NPR Nc Task")
    begin
        NcTask.SetCurrentKey("Task Processor Code", Processed, Postponed, "Store Code", "Not Before Date-Time");
        NcTask.SetRange("Task Processor Code", ShopifyTaskProcessorCode());
        NcTask.SetRange(Processed, false);
        // Parity with the legacy senders, which never process Rename rows: invisible to the drain, the recreate and the verify.
        NcTask.SetFilter(Type, '<>%1', NcTask.Type::Rename);
    end;

    local procedure ShopifyTaskProcessorCode(): Code[20]
    var
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
    begin
        exit(SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(false));
    end;

    local procedure LegacyAttemptCap(): Integer
    begin
        exit(3);
    end;

    local procedure QuiescePollInterval(): Integer
    begin
        exit(10 * 1000);
    end;

    local procedure QuiesceTimeout(): Duration
    begin
        exit(35 * 60 * 1000);
    end;

    local procedure SetMigrationInProgress(InProgress: Boolean)
    begin
        _MigrationInProgress := InProgress;
    end;

    internal procedure MigrationInProgress(): Boolean
    begin
        exit(_MigrationInProgress);
    end;

    // The worker is Codeunit.Run-invoked for error isolation, which also makes it Job Queue dispatchable.
    // This handshake keeps it reachable only from RunCutoverIsolated, independently of the availability gate.
    internal procedure CutoverAuthorized(): Boolean
    begin
        exit(_CutoverAuthorized);
    end;

    local procedure SetStatus(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; NewStatus: Option)
    begin
        SpfyIntegrationSetup."Task List Migration Status" := NewStatus;
        SpfyIntegrationSetup.Modify();
        Commit();
    end;

    local procedure RunIsStale(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"): Boolean
    begin
        if SpfyIntegrationSetup."Task List Migr. Started At" = 0DT then
            exit(true);
        exit((CurrentDateTime() - SpfyIntegrationSetup."Task List Migr. Started At") > StalenessThresholdMs());
    end;

    local procedure StalenessThresholdMs(): Integer
    begin
        exit(60 * 60 * 1000);
    end;

    local procedure RefreshRunHeartbeat()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not SpfyIntegrationSetup.Get() then
            exit;
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::Migrating then
            exit;
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify();
    end;

    // Test seam: no data-seedable failure path survives inside the cutover, and the Failed-status contract needs one.
    [InternalEvent(false)]
    local procedure OnBeforeHandOverLegacyQueue(var FailWithErrorText: Text)
    begin
    end;

    var
        _MigrationInProgress: Boolean;
        _CutoverAuthorized: Boolean;
}
