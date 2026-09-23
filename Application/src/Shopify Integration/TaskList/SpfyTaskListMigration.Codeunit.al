codeunit 6151245 "NPR Spfy Task List Migration"
{
    Access = Internal;
    SingleInstance = true;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        EntryRunId: Guid;
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed then
            exit;
        // Only a run holding the lease MigrateAndEnable stamped may cut over; anything else (a platform retry of a
        // superseded run, a hand-made entry) stands down silently. The prerequisite check runs inside the trapped cutover.
        EntryRunId := ParsedRunId(Rec."Parameter String");
        if not OwnsMigrationRun(SpfyIntegrationSetup, EntryRunId) then
            exit;
        SetOverridesConfirmed(ParsedOverridesConfirmed(Rec."Parameter String"));
        SetRunId(EntryRunId);
        Commit();
        RunCutoverIsolated();
    end;

    procedure MigrateAndEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTLSchedBgMigr: Codeunit "NPR Spfy TL Sched Bg Migr";
        OverridesConfirmed: Boolean;
        RunForeground: Boolean;
        StampedRunId: Guid;
        ScheduleErrorText: Text;
        BackgroundStartedMsg: Label 'The Shopify task list migration has been started in the background. It drains the remaining NaviConnect tasks and enables the Shopify task list automatically. The migration details stay on the Shopify Integration Setup page until it has completed; if it fails or stalls, re-run the migration from there.';
        BackgroundNeedsActivationMsg: Label 'The Shopify task list migration job has been created, but your user cannot start scheduled tasks. The migration has NOT started. Ask an administrator to set the job to Ready on the Job Queue Entries page, or run the migration again once you can start scheduled tasks.';
    begin
        SetMigrationInProgress(false);
        SetOverridesConfirmed(false);
        CheckMigrationPrerequisites();
        if not ConfirmCustomSendCodeunitOverrides(OverridesConfirmed) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        AcquireLock(SpfyIntegrationSetup);
        // A platform retry of a failed background run must not fire once a new run owns the lease.
        CancelPendingMigrationEntries();
        MarkMigrationStarted(SpfyIntegrationSetup);
        StampedRunId := SpfyIntegrationSetup."Task List Migration Run ID";
        if RunForeground then begin
            SetOverridesConfirmed(OverridesConfirmed);
            SetRunId(StampedRunId);
            RunCutoverIsolated();
            exit;
        end;
        SpfyTLSchedBgMigr.SetRunParameters(StampedRunId, OverridesConfirmed);
        if not SpfyTLSchedBgMigr.Run() then begin
            ScheduleErrorText := GetLastErrorText();
            // Nothing ran: the entry cleanup and the cleared heartbeat have to outlive the error below, so MarkRunEnded commits both.
            if StillHoldsLease(SpfyIntegrationSetup, StampedRunId) then begin
                CancelPendingMigrationEntries();
                MarkRunEnded(SpfyIntegrationSetup);
            end;
            Error(ScheduleErrorText);
        end;
        if MigrationEntryIsOnHold() then begin
            // The entry is parked and nothing runs, so the heartbeat must not refuse the re-run that cancels it.
            if StillHoldsLease(SpfyIntegrationSetup, StampedRunId) then
                MarkRunEnded(SpfyIntegrationSetup);
            Message(BackgroundNeedsActivationMsg);
        end else
            Message(BackgroundStartedMsg);
    end;

    // Setup lock before any job queue write, as AcquireLock does, and a re-read because the pre-dispatch Commit closed the caller's transaction.
    local procedure StillHoldsLease(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; StampedRunId: Guid): Boolean
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        exit(SpfyIntegrationSetup."Task List Migration Run ID" = StampedRunId);
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

    // The per-store NaviConnect jobs this migration removes are also the Data Log pump, so an environment still
    // detecting on the Data Log would stop enqueueing Shopify updates altogether. The flag must be on AND no Data Log
    // wiring left: flag off with no wiring means nothing detects Shopify changes at all, which the RowVersion migration repairs.
    local procedure CheckMigrationPrerequisites()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        RowVersionDetectionRequiredErr: Label 'The Shopify task list migration requires this environment to detect Shopify changes with RowVersion. Run the "Migrate to RowVersion detection" action on the Shopify Integration Setup page first, then start this migration.';
    begin
        // A run resuming past the legacy hand-over is already beyond the Data Log question this asks.
        if SpfyIntegrationSetup.Get() then
            if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Finalizing then
                exit;
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyIntegrationMgt.RunsShopifyOnDataLog() then
            exit;
        Error(RowVersionDetectionRequiredErr);
    end;

    // A customer's own send codeunit on the legacy queue is deleted by the cutover for good, so the operator has to
    // agree before anything is removed; the replacement is the OnBeforeDispatchShopifyTask subscriber seam.
    local procedure ConfirmCustomSendCodeunitOverrides(var OverridesConfirmed: Boolean): Boolean
    var
        OverrideList: Text;
        OverrideConfirmQst: Label 'These NaviConnect send registrations do not use the standard Shopify send codeunit:\%1\\The migration removes them permanently. A custom send must be re-implemented as a subscriber to the OnBeforeDispatchShopifyTask event of the Shopify task list.\\Do you want to continue?', Comment = '%1 = the list of registrations that differ from the standard mapping';
        OverridesNoGuiErr: Label 'These NaviConnect send registrations do not use the standard Shopify send codeunit:\%1\\The migration removes them permanently and cannot ask for confirmation in this session. Start the migration from the Shopify Integration Setup page.', Comment = '%1 = the list of registrations that differ from the standard mapping';
    begin
        OverridesConfirmed := false;
        OverrideList := CustomSendCodeunitOverrides();
        if OverrideList = '' then
            exit(true);
        if not GuiAllowed() then
            Error(OverridesNoGuiErr, OverrideList);
        if not Confirm(OverrideConfirmQst, false, OverrideList) then
            exit(false);
        OverridesConfirmed := true;
        exit(true);
    end;

    local procedure CustomSendCodeunitOverrides(): Text
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        OverrideListBuilder: TextBuilder;
        ProcessorCode: Code[20];
        OverrideLineLbl: Label '%1 (%2): codeunit %3', Comment = '%1 = table name, %2 = table number, %3 = codeunit id';
    begin
        ProcessorCode := ShopifyTaskProcessorCode();
        if ProcessorCode = '' then
            exit('');
        NcTaskSetup.SetRange("Task Processor Code", ProcessorCode);
        // The table name is a FlowField and the operator decides on this list whether to delete registrations for good.
        NcTaskSetup.SetAutoCalcFields("Table Name");
        if not NcTaskSetup.FindSet() then
            exit('');
        repeat
            if NcTaskSetup."Codeunit ID" <> SpfyScheduleSendTasks.StandardLegacySendCodeunitId(NcTaskSetup."Table No.") then begin
                if OverrideListBuilder.Length() > 0 then
                    OverrideListBuilder.AppendLine();
                OverrideListBuilder.Append(StrSubstNo(OverrideLineLbl, NcTaskSetup."Table Name", NcTaskSetup."Table No.", NcTaskSetup."Codeunit ID"));
            end;
        until NcTaskSetup.Next() = 0;
        exit(OverrideListBuilder.ToText());
    end;

    local procedure CheckCustomSendCodeunitOverridesConfirmed()
    var
        OverrideList: Text;
        OverridesNotConfirmedErr: Label 'The Shopify task list migration cannot remove these custom NaviConnect send registrations because this run did not confirm their removal:\%1\\Start the migration again from the Shopify Integration Setup page and confirm it.', Comment = '%1 = the list of registrations that differ from the standard mapping';
    begin
        if _OverridesConfirmed then
            exit;
        OverrideList := CustomSendCodeunitOverrides();
        if OverrideList = '' then
            exit;
        Error(OverridesNotConfirmedErr, OverrideList);
    end;

    local procedure SetOverridesConfirmed(Confirmed: Boolean)
    begin
        _OverridesConfirmed := Confirmed;
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
        MigrationAlreadyCompletedErr: Label 'The Shopify task list migration has already been completed.';
        MigrationInProgressErr: Label 'A Shopify task list migration is already in progress.';
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Completed is terminal, and a page opened before the run finished still offers the action.
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed then
            Error(MigrationAlreadyCompletedErr);
        // One live run at a time: an ended run cleared its heartbeat, so its re-run is admitted without the staleness wait.
        if SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::Migrating, SpfyIntegrationSetup."Task List Migration Status"::Finalizing]
        then
            if not RunIsStale(SpfyIntegrationSetup) then
                Error(MigrationInProgressErr);
    end;

    // The lease is persisted and committed before dispatch, so the entry that is dispatched can prove it owns the run.
    // No status is stamped here: nothing is running yet, and a refused or parked schedule must leave the state untouched.
    local procedure MarkMigrationStarted(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup."Task List Migration Run ID" := CreateGuid();
        SpfyIntegrationSetup.Modify();
        Commit();
    end;

    // A cleared heartbeat is what admits the next attempt at once; the run id stays behind as the resume token.
    local procedure MarkRunEnded(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        SpfyIntegrationSetup."Task List Migr. Started At" := 0DT;
        SpfyIntegrationSetup.Modify();
        Commit();
    end;

    // The run id makes the lease owned rather than merely taken: a hand-made entry, or a platform retry of a run that
    // has already been superseded, stands down instead of cutting the environment over a second time.
    local procedure OwnsMigrationRun(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; EntryRunId: Guid): Boolean
    begin
        // A null token is what an entry that was never dispatched by a migration run carries: it can neither own nor adopt.
        if IsNullGuid(EntryRunId) then
            exit(false);
        if EntryRunId = SpfyIntegrationSetup."Task List Migration Run ID" then begin
            // The re-armed heartbeat refuses an operator start while this retry runs at Migrating or Finalizing; at Failed only the lease keeps the two apart.
            SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
            SpfyIntegrationSetup.Modify();
            Commit();
            exit(true);
        end;
        // Below Migrating nothing is running, so there is no interrupted run to adopt.
        if not (SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::Migrating, SpfyIntegrationSetup."Task List Migration Status"::Finalizing])
        then
            exit(false);
        if not RunIsStale(SpfyIntegrationSetup) then
            exit(false);
        // Adoption stamps the incumbent entry's own id, never a fresh one: a fresh id would orphan this entry's own retry.
        SpfyIntegrationSetup."Task List Migration Run ID" := EntryRunId;
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify();
        Commit();
        exit(true);
    end;

    internal procedure RunParameterString(RunId: Guid; OverridesConfirmed: Boolean) ParameterString: Text
    begin
        ParameterString := RunIdPrefixTok() + Format(RunId);
        if OverridesConfirmed then
            ParameterString += ';' + OverridesConfirmedTok();
    end;

    local procedure ParsedRunId(ParameterString: Text) RunId: Guid
    var
        TokenPos: Integer;
    begin
        TokenPos := StrPos(ParameterString, RunIdPrefixTok());
        if TokenPos = 0 then
            exit;
        if not Evaluate(RunId, CopyStr(ParameterString, TokenPos + StrLen(RunIdPrefixTok()), 38)) then
            Clear(RunId);
    end;

    local procedure ParsedOverridesConfirmed(ParameterString: Text): Boolean
    begin
        exit(StrPos(ParameterString, OverridesConfirmedTok()) > 0);
    end;

    local procedure RunIdPrefixTok(): Text
    var
        RunIdPrefixLbl: Label 'runid=', Locked = true;
    begin
        exit(RunIdPrefixLbl);
    end;

    local procedure OverridesConfirmedTok(): Text
    var
        OverridesConfirmedLbl: Label 'ovrok=1', Locked = true;
    begin
        exit(OverridesConfirmedLbl);
    end;

    // Stamping Migrating here is what "the cutover is executing" means: both entry points reach the worker through this.
    // A trapped failure before the legacy hand-over transitions to Failed and switches the feature back off; a failure after it
    // stays Finalizing, because the legacy registrations are already gone and only a re-run can finish the cutover.
    internal procedure RunCutoverIsolated()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTask: Record "NPR Spfy Task";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        SpfyTLMigrWorker: Codeunit "NPR Spfy TL Migr Worker";
        RunId: Guid;
        ParkedTaskCount: Integer;
        CutoverErrorText: Text;
        CutoverOk: Boolean;
        FailedBeforeHandoverLbl: Label 'The Shopify task list migration failed before the legacy hand-over; the NaviConnect Shopify processing is being re-activated and the migration must be run again. %2 task(s) currently sit unsent in the new queue, which nothing drains until the migration succeeds. Error: %1', Locked = true;
        StuckFinalizingLbl: Label 'The Shopify task list migration failed after the legacy hand-over; the NaviConnect Shopify processing is already removed and Shopify synchronization is halted until the migration is run again. Error: %1', Locked = true;
        SupersededRunLbl: Label 'The Shopify task list migration failed in a run that another run had already superseded. Error: %1', Locked = true;
    begin
        // The token is consumed here: it belongs to the one run that is about to execute, never to a later direct call.
        RunId := _RunId;
        Clear(_RunId);
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // The lease is re-read under the very lock that stamps Migrating, so a run superseded while the status was still
        // Not Started stands down here instead of cutting the environment over beside the run that took the lease from it.
        if not IsNullGuid(RunId) and (SpfyIntegrationSetup."Task List Migration Run ID" <> RunId) then
            exit;
        // OnRun and AcquireLock already refuse Completed, so this exit is the tokenless direct-call route's own guard.
        if IsNullGuid(RunId) and (SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed) then
            exit;
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::Finalizing then
            SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Migrating);
        // The locked read above opens a write transaction and a resume at Finalizing stamps nothing: Codeunit.Run needs it closed.
        Commit();

        _LegacySendersQuiesced := false;
        _CutoverAuthorized := true;
        CutoverOk := SpfyTLMigrWorker.Run();
        _CutoverAuthorized := false;
        if CutoverOk then begin
            WarnIfTaskProcessorOnHold();
            exit;
        end;
        CutoverErrorText := GetLastErrorText();
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Only the run holding the lease may write: senders a superseded run cancelled are re-created by the job queue refresher.
        if not IsNullGuid(RunId) and (SpfyIntegrationSetup."Task List Migration Run ID" <> RunId) then begin
            EmitCutoverFailureAlert(StrSubstNo(SupersededRunLbl, CutoverErrorText));
            Error(CutoverErrorText);
        end;
        // Both completion paths clear the lease and another run's Failed stamps a new one, so only the tokenless direct call can be the owner here at Completed.
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed then begin
            EmitCutoverFailureAlert(StrSubstNo(SupersededRunLbl, CutoverErrorText));
            Error(CutoverErrorText);
        end;
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Finalizing then begin
            MarkRunEnded(SpfyIntegrationSetup);
            EmitCutoverFailureAlert(StrSubstNo(StuckFinalizingLbl, CutoverErrorText));
            Error(CutoverErrorText);
        end;
        // An operator who stays on NaviConnect has to know how many updates are waiting in the queue nobody drains yet.
        SpfyTask.SetFilter(State, '%1|%2', SpfyTask.State::Pending, SpfyTask.State::Waiting);
        ParkedTaskCount := SpfyTask.Count();
        // Ahead of the compensation: the sender re-creation below can raise on a permission check, and this alert is the only report of the real cause.
        EmitCutoverFailureAlert(StrSubstNo(FailedBeforeHandoverLbl, CutoverErrorText, ParkedTaskCount));
        // The flag stays on across the compensation: the feature codeunit's after-modify cleanup reads it to tell this
        // run's own disable from an operator's, and would otherwise refuse the rollback and abort the status write below.
        SetMigrationInProgress(true);
        CompensateFailedCutover();
        SetMigrationInProgress(false);
        // Ended run: the cleared heartbeat rides the status write, not a second Modify after that write's Commit.
        SpfyIntegrationSetup."Task List Migr. Started At" := 0DT;
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."Task List Migration Status"::Failed);
        // Failed routes sending back to the legacy engine, so senders this run cancelled are re-created - after the
        // status write, which is what re-enables them, and committed, or the error below would roll them away again.
        if _LegacySendersQuiesced then begin
            SpfyScheduleSendTasks.SetupTaskProcessingJobQueues();
            Commit();
        end;
        Error(CutoverErrorText);
    end;

    // A delegated admin cannot start scheduled tasks, so a cutover can complete with the processor parked. A background
    // run has no dialog, so there the setup page's own warning is the cue and this says nothing.
    local procedure WarnIfTaskProcessorOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
        ProcessorNeedsActivationMsg: Label 'The migration has completed, but the Shopify task processing job could not be started and is on hold. Shopify updates are collected but not sent until an administrator sets the job to Ready on the Job Queue Entries page.';
    begin
        if not GuiAllowed() then
            exit;
        // The delegated admin this warning exists for is exactly the user who may not read Job Queue Entry.
        if not JobQueueEntry.ReadPermission() then
            exit;
        if not SpfyTaskJQSetup.AnyTaskProcessorOnHold() then
            exit;
        Message(ProcessorNeedsActivationMsg);
    end;

    local procedure EmitCutoverFailureAlert(AlertText: Text)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.InitScopeAndTransaction('Shopify task list migration failure', 'bc.spfy.task_list.migration_failure');
        Sentry.AddError(AlertText);
        Sentry.FinalizeScope();
    end;

    // Failed must mean the legacy path is running again, and at Migrating only a migration run can have switched the flag on.
    local procedure CompensateFailedCutover()
    var
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
    begin
        if SpfyTaskListFeature.IsFeatureEnabled() then
            SpfyTaskListFeature.SetFeatureEnabled(false);
    end;

    internal procedure RunEnvironmentCutover(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    var
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
    begin
        // Inside the trap: a refusal has to become the Failed transition rather than wedge a consumed job queue entry.
        CheckMigrationPrerequisites();
        // Fresh start time so a concurrent admin's staleness check doesn't misclassify this live run. The status was
        // stamped when the cutover started, and a run resuming past the hand-over must keep Finalizing.
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify();
        Commit();
        EnableFeatureWithBypass();
        HandOverLegacyQueue();
        BeatRunHeartbeat();
        DeregisterLegacyShopifyProcessing();
        BeatRunHeartbeat();
        ReverifyAndResolveStragglers();
        // Ensure the jobs before marking Completed so a scheduling failure leaves the migration re-runnable.
        SpfyTaskJQSetup.SetupTaskProcessingJobQueuesForMigration();
        // The heartbeat writes its own instance of this row during the drain, so ours is stale by now.
        SpfyIntegrationSetup.GetRecordOnce(true);
        // The run id is only a resume token: it stays behind on a failed run and dies with the completed one.
        Clear(SpfyIntegrationSetup."Task List Migration Run ID");
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
        AlertOnDeadRemainder();
        VerifyNoDueLegacyRows();
    end;

    // Per environment only: the legacy code itself stays for the environments that have not migrated yet.
    // The setup's Data Processing Handler ID is deliberately kept - the residual watch and the fresh-environment check resolve it.
    internal procedure DeregisterLegacyShopifyProcessing()
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcTaskSetup: Record "NPR Nc Task Setup";
        ProcessorCode: Code[20];
    begin
        ProcessorCode := ShopifyTaskProcessorCode();
        CheckCustomSendCodeunitOverridesConfirmed();
        // Reaching the deregistration is the point of no return, whether or not there is anything left to remove.
        MarkFinalizing();
        if ProcessorCode = '' then begin
            Commit();
            exit;
        end;
        NcTaskSetup.SetRange("Task Processor Code", ProcessorCode);
        if not NcTaskSetup.IsEmpty() then
            NcTaskSetup.DeleteAll(true);
        // Every subscription of the Shopify handler, not a table list a later release could outgrow.
        DataLogSubscriber.SetRange(Code, ProcessorCode);
        if not DataLogSubscriber.IsEmpty() then
            DataLogSubscriber.DeleteAll(true);
        if NcTaskProcessor.Get(ProcessorCode) then
            NcTaskProcessor.Delete(true);
        // Idempotent re-run of the quiesce cancel: a job created between the drain and here must not outlive the cutover.
        CancelLegacyShopifyJobQueues();
        Commit();
    end;

    // Written on the deregistration's own transaction so the status and the deletions land together.
    local procedure MarkFinalizing()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        OvertakenErr: Label 'Another Shopify task list migration run has taken this environment back to the legacy queue; this run stops before the point of no return.';
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Every legitimate arrival is at Migrating or Finalizing: Failed means another run compensated the environment back to legacy while this one drained.
        if SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Failed then
            Error(OvertakenErr);
        // Completed is terminal: a superseded run must not pull an environment another run already finished back.
        if SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::Finalizing, SpfyIntegrationSetup."Task List Migration Status"::Completed]
        then
            exit;
        SpfyIntegrationSetup."Task List Migration Status" := SpfyIntegrationSetup."Task List Migration Status"::Finalizing;
        SpfyIntegrationSetup.Modify();
    end;

    // The only place legacy rows are moved below Completed (the processor recovers residuals at Completed), and a failure here stays Finalizing and resumes.
    internal procedure ReverifyAndResolveStragglers()
    begin
        if ShopifyTaskProcessorCode() = '' then
            exit;
        RecreateRemainingLegacyRows();
        VerifyNoActionableLegacyRows();
    end;

    local procedure QuiesceLegacySenders()
    var
        TempRunningJobQueueEntry: Record "Job Queue Entry" temporary;
        Deadline: DateTime;
        SendersWereRunning: Boolean;
    begin
        Deadline := CurrentDateTime() + QuiesceTimeout();
        // Set before the first cancel commits, so a quiesce timeout still re-creates what this run cancelled.
        _LegacySendersQuiesced := true;
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
        FilterDueLegacyRows(NcTask);
        if not NcTask.IsEmpty() then
            exit(true);

        FilterPostponedLegacyRows(NcTask);
        exit(not NcTask.IsEmpty());
    end;

    local procedure FilterDueLegacyRows(var NcTask: Record "NPR Nc Task")
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetRange(Postponed, false);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        NcTask.SetFilter("Not Before Date-Time", '%1|..%2', 0DT, CurrentDateTime());
    end;

    local procedure FilterPostponedLegacyRows(var NcTask: Record "NPR Nc Task")
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetRange(Postponed, true);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
    end;

    local procedure RecreateRemainingLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
        RecreatedCount: Integer;
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        NcTask.SetLoadFields("Entry No.");
        if not NcTask.FindSet() then
            exit;
        repeat
            RecreateLegacyRowInNewQueue(NcTask);
            RecreatedCount += 1;
            if (RecreatedCount mod HeartbeatRowInterval()) = 0 then
                BeatRunHeartbeat();
        until NcTask.Next() = 0;
    end;

    local procedure HeartbeatRowInterval(): Integer
    begin
        exit(100);
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

    // Nothing has moved to the new queue yet, so only the rows the drain could actually have processed may block it.
    local procedure VerifyNoDueLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
        NcTaskProcessor: Record "NPR Nc Task Processor";
        DueCount: Integer;
    begin
        // Same precondition as the drain: a resume past the deregistration has no processor left to drain through.
        if not NcTaskProcessor.Get(ShopifyTaskProcessorCode()) then
            exit;
        FilterDueLegacyRows(NcTask);
        DueCount := NcTask.Count();
        FilterPostponedLegacyRows(NcTask);
        DueCount += NcTask.Count();
        if DueCount > 0 then
            RaiseNotDrained(DueCount);
    end;

    local procedure VerifyNoActionableLegacyRows()
    var
        NcTask: Record "NPR Nc Task";
    begin
        FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        if not NcTask.IsEmpty() then
            RaiseNotDrained(NcTask.Count());
    end;

    local procedure RaiseNotDrained(TaskCount: Integer)
    var
        NotDrainedErr: Label 'The Shopify task list migration could not process %1 NaviConnect task(s). The migration has been stopped and must be run again to finish.', Comment = '%1 = number of NaviConnect tasks still awaiting processing';
    begin
        Error(NotDrainedErr, TaskCount);
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

    local procedure SetRunId(RunId: Guid)
    begin
        _RunId := RunId;
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
        if not (SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::Migrating, SpfyIntegrationSetup."Task List Migration Status"::Finalizing])
        then
            exit;
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify();
    end;

    local procedure BeatRunHeartbeat()
    begin
        RefreshRunHeartbeat();
        Commit();
    end;

    // Test seam: no data-seedable failure path survives inside the cutover, and the Failed-status contract needs one.
    [InternalEvent(false)]
    local procedure OnBeforeHandOverLegacyQueue(var FailWithErrorText: Text)
    begin
    end;

    var
        _RunId: Guid;
        _MigrationInProgress: Boolean;
        _CutoverAuthorized: Boolean;
        _LegacySendersQuiesced: Boolean;
        _OverridesConfirmed: Boolean;
}
