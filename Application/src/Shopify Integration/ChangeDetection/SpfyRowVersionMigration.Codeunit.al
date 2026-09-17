codeunit 6151217 "NPR Spfy RowVersion Migration"
{
    Access = Internal;
    SingleInstance = true;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        NotViaJobQueueErr: Label 'The RowVersion cutover cannot be started directly. Use the migration action on the Shopify Integration Setup page.';
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Re-entered by RunCutover as its own error-isolation runner: the parameter routes the call and the
        // handshake authorizes it, so a hand-made job queue entry cannot drive the cutover unchecked.
        if Rec."Parameter String" = IsolatedCutoverTok() then begin
            if not _CutoverAuthorized then
                Error(NotViaJobQueueErr);
            // The enable inside runs through Codeunit.Run with a used return value, which requires no open transaction: the locked read above opened one.
            Commit();
            RunCutoverBody(SpfyIntegrationSetup);
            exit;
        end;
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyRowVersionFeature.RunsShopifyOnDataLog() then
            exit;
        // Free pre-filter for a parked entry activated under a live cutover, so it doesn't seed for hours before RunCutover stands it down; Seeding is where a legitimately scheduled entry starts and is never refused.
        if (SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::Migrating) and
            not RunIsStale(SpfyIntegrationSetup)
        then
            exit;
        RunFullMigration(SpfyIntegrationSetup, false);
    end;

    local procedure IsolatedCutoverTok(): Text
    var
        IsolatedCutoverLbl: Label 'spfy-rowversion-cutover', Locked = true;
    begin
        exit(IsolatedCutoverLbl);
    end;

    procedure MigrateAndEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        RunForeground: Boolean;
    begin
        SetMigrationInProgress(false);
        if SeedModePromptNeeded() then
            if not PromptRunMode(RunForeground) then
                exit;
        AcquireLock(SpfyIntegrationSetup);
        ClassifyAndDispatch(SpfyIntegrationSetup, RunForeground);
    end;

    local procedure SeedModePromptNeeded(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyRowVersionFeature.RunsShopifyOnDataLog() then
            exit(false);
        if not SpfyIntegrationSetup.Get() then
            exit(false);
        exit(NeedsSeed(SpfyIntegrationSetup));
    end;

    local procedure PromptRunMode(var RunForeground: Boolean): Boolean
    var
        ModeInstructionLbl: Label 'Migrate this Shopify integration from Data Log to RowVersion detection. This is a one-way change.\\Run in foreground = run now in this session (blocking, with a progress dialog) — fine for a small integration.\Run in background = run as a Job Queue task (recommended for a large integration); it seeds the baselines and then cuts over automatically.';
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

    internal procedure SetMigrationInProgress(InProgress: Boolean)
    begin
        _MigrationInProgress := InProgress;
    end;

    internal procedure MigrationInProgress(): Boolean
    begin
        exit(_MigrationInProgress);
    end;

    local procedure AcquireLock(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        MigrationInProgressErr: Label 'A RowVersion migration is already in progress.';
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Past its own TeardownDataLog a run has only ClassifyAndDispatch's own two steps left, so refusing here would strand a run killed in that window for the whole staleness threshold with nothing able to finish it.
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyRowVersionFeature.RunsShopifyOnDataLog() then
            exit;
        case SpfyIntegrationSetup."RowVersion Migration Status" of
            SpfyIntegrationSetup."RowVersion Migration Status"::Seeding,
            SpfyIntegrationSetup."RowVersion Migration Status"::Migrating:
                if not RunIsStale(SpfyIntegrationSetup) then
                    Error(MigrationInProgressErr);
        end;
    end;

    local procedure ClassifyAndDispatch(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; RunForeground: Boolean)
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyRowVersionFeature.RunsShopifyOnDataLog() then begin
            EnsureDetectionJobScheduled();
            SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Completed);
            exit;
        end;

        if NeedsSeed(SpfyIntegrationSetup) then
            DispatchSeedThenCutover(SpfyIntegrationSetup, RunForeground)
        else
            RunCutover(SpfyIntegrationSetup);
    end;

    local procedure NeedsSeed(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"): Boolean
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        exit(SpfyIntegrationSetup."RowVersion Pld. Ver. Seeded" <> SpfySyncStateMgt.PayloadVersion());
    end;

    local procedure DispatchSeedThenCutover(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; RunForeground: Boolean)
    var
        ScheduleBgMigration: Codeunit "NPR Spfy Sched. Bg Migration";
        BackgroundStartedMsg: Label 'The RowVersion migration has been started in the background. It will seed the baselines and then enable RowVersion detection automatically. Its status is shown on the Shopify Integration Setup page while it runs; start the migration again if it stops before it has finished.';
        BackgroundNeedsActivationMsg: Label 'The RowVersion migration job has been created, but your user cannot start scheduled tasks. Ask an administrator to set the job to Ready on the Job Queue Entries page; the migration will then run in the background.';
        ScheduleErrorText: Text;
    begin
        // Runs under AcquireLock's transaction and ahead of the Seeding stamp, so a platform retry of an earlier run cannot fire beside this one and a failure here commits nothing.
        CancelPendingMigrationEntries();
        MarkSeedingStarted(SpfyIntegrationSetup);
        if RunForeground then
            RunFullMigration(SpfyIntegrationSetup, true)
        else begin
            // Codeunit.Run (not [TryFunction]): a failed partial JQ write rolls back; MarkSeedingStarted already committed.
            if not ScheduleBgMigration.Run() then begin
                // Captured first so nothing downstream can overwrite it.
                ScheduleErrorText := GetLastErrorText();
                // Nothing ran, so the Seeding stamp committed moments ago is retracted or every retry is refused as already in progress.
                SpfyIntegrationSetup."RowVersion Seeding Error Text" :=
                    CopyStr(ScheduleErrorText, 1, MaxStrLen(SpfyIntegrationSetup."RowVersion Seeding Error Text"));
                SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Failed);
                Error('%1', ScheduleErrorText);
            end;
            if MigrationEntryIsOnHold() then begin
                // The entry is parked and nothing runs, so the heartbeat must not refuse the re-run that replaces it.
                SpfyIntegrationSetup."RowVersion Seeding Started At" := 0DT;
                SpfyIntegrationSetup.Modify();
                Commit();
                Message(BackgroundNeedsActivationMsg);
            end else
                Message(BackgroundStartedMsg);
        end;
    end;

    local procedure MigrationEntryIsOnHold(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy RowVersion Migration");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        exit(not JobQueueEntry.IsEmpty());
    end;

    local procedure CancelPendingMigrationEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy RowVersion Migration");
        JobQueueEntry.SetFilter(Status, '<>%1', JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
    end;

    local procedure RunFullMigration(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; ShowProgress: Boolean)
    var
        SpfySyncStateSeeding: Codeunit "NPR Spfy Sync State Seeding";
    begin
        if NeedsSeed(SpfyIntegrationSetup) then begin
            SpfySyncStateSeeding.RunSeedingSweep(ShowProgress);
            SpfyIntegrationSetup.GetRecordOnce(true);
        end;
        RunCutover(SpfyIntegrationSetup);
    end;

    // Codeunit.Run here buys error CAPTURE, not rollback - every step inside RunCutoverBody commits, which is why the
    // alerts below have to name which half-migrated state the run left: the foreground caller still sees the error, the
    // background one leaves it on the job queue entry.
    local procedure RunCutover(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        CutoverErrorText: Text;
        CutoverOk: Boolean;
        DataLogStillWired: Boolean;
        FeatureFlagIsOn: Boolean;
        SwitchedFeatureOff: Boolean;
        CompensatedLbl: Label 'The Shopify RowVersion migration cutover failed before the Data Log was removed; RowVersion detection has been switched back off and the migration must be run again. Error: %1', Locked = true;
        EnableFailedLbl: Label 'The Shopify RowVersion migration cutover failed before RowVersion detection was switched on; nothing was changed and the environment still detects Shopify changes with the Data Log. Error: %1', Locked = true;
        DualCaptureLbl: Label 'The Shopify RowVersion migration cutover failed; the RowVersion feature was left enabled beside the Data Log detection (it was switched on by an earlier run), so Shopify changes are captured twice until the migration is run again. Error: %1', Locked = true;
        NotCompensatedLbl: Label 'The Shopify RowVersion migration cutover failed after the Data Log was removed; the environment now detects Shopify changes with RowVersion only and the migration must be run again to finish. Error: %1', Locked = true;
        SupersededRunLbl: Label 'A superseded Shopify RowVersion migration run failed after another run had already completed the migration; the environment is complete and nothing was changed. Two runs executing the same cutover means admission control did not hold. Error: %1. This is a programming bug.', Locked = true;
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Migrating is stamped nowhere but here, so a live Migrating run is always another one: stand down instead of cutting the environment over twice.
        if (SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::Migrating) and
            not RunIsStale(SpfyIntegrationSetup)
        then
            exit;
        // Fresh cutover start time so a concurrent admin's staleness check doesn't misclassify this live run.
        SpfyIntegrationSetup."RowVersion Seeding Started At" := CurrentDateTime();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Migrating);

        JobQueueEntry."Parameter String" := CopyStr(IsolatedCutoverTok(), 1, MaxStrLen(JobQueueEntry."Parameter String"));
        _FeatureEnabledByThisRun := false;
        _CutoverAuthorized := true;
        CutoverOk := Codeunit.Run(Codeunit::"NPR Spfy RowVersion Migration", JobQueueEntry);
        _CutoverAuthorized := false;
        if CutoverOk then
            exit;
        CutoverErrorText := GetLastErrorText();
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Completed is the only status another run has finished on; every other one still owes this run's compensation.
        if SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::Completed then begin
            // Completed beside torn-down wiring is the post-teardown recovery finishing this run's own remaining bookkeeping - expected, not an admission-control failure. Completed WITH wiring still live is the inconsistent state worth a developer's time.
            if SpfyRowVersionFeature.RunsShopifyOnDataLog() then
                EmitCutoverFailureAlert(StrSubstNo(SupersededRunLbl, CutoverErrorText));
        end else begin
            // Recorded BEFORE the compensation, which has no error isolation: an error in there would otherwise discard the status, the text and every alert below, leaving the row on Migrating with no signal at all.
            // Failed is stamped only from Migrating in this cutover path; the seeding refusal stamps it from Seeding by design.
            if SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::Migrating then begin
                SpfyIntegrationSetup."RowVersion Seeding Error Text" :=
                    CopyStr(CutoverErrorText, 1, MaxStrLen(SpfyIntegrationSetup."RowVersion Seeding Error Text"));
                SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Failed);
            end;
            SwitchedFeatureOff := CompensateFailedCutover();
            // Read after the compensation so the text describes what this run actually left behind.
            DataLogStillWired := SpfyRowVersionFeature.RunsShopifyOnDataLog();
            FeatureFlagIsOn := SpfyRowVersionFeature.IsFeatureEnabled();
            // Persists the compensation's feature-flag write, which has none of its own.
            Commit();
            // What this run actually did picks the text: switched the flag back off, never got it on, left another run's flag on beside live Data Log wiring (dual capture), or nothing left to switch off with the wiring already gone.
            case true of
                SwitchedFeatureOff:
                    EmitCutoverFailureAlert(StrSubstNo(CompensatedLbl, CutoverErrorText));
                not FeatureFlagIsOn:
                    EmitCutoverFailureAlert(StrSubstNo(EnableFailedLbl, CutoverErrorText));
                DataLogStillWired:
                    EmitCutoverFailureAlert(StrSubstNo(DualCaptureLbl, CutoverErrorText));
                else
                    EmitCutoverFailureAlert(StrSubstNo(NotCompensatedLbl, CutoverErrorText));
            end;
        end;
        Error('%1', CutoverErrorText);
    end;

    local procedure RunCutoverBody(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        EnableFeatureWithBypass();
        DrainBacklog();
        TeardownDataLog();
        MigratePosEntryMark();
        // Ensure the job before marking Completed so a scheduling failure leaves the migration re-runnable.
        EnsureDetectionJobScheduled();
        // The heartbeat writes its own instance of this row during the drain, so ours is stale by now.
        SpfyIntegrationSetup.GetRecordOnce(true);
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Completed);
    end;

    // The capture subscribers key on the feature flag alone, so a flag left on beside live Data Log wiring would make
    // both engines capture the same change. Once the wiring is gone the flag is the only detection left and must stay on.
    local procedure CompensateFailedCutover(): Boolean
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        // A loser that found the flag already on must not switch it off under the live run that owns it.
        if not _FeatureEnabledByThisRun then
            exit(false);
        _FeatureEnabledByThisRun := false;
        if not (SpfyRowVersionFeature.IsFeatureEnabled() and SpfyRowVersionFeature.RunsShopifyOnDataLog()) then
            exit(false);
        SpfyRowVersionFeature.SetFeatureEnabled(false);
        exit(true);
    end;

    local procedure EmitCutoverFailureAlert(AlertText: Text)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.InitScopeAndTransaction('Shopify RowVersion migration failure', 'bc.spfy.rowversion.migration_failure');
        Sentry.AddError(AlertText);
        Sentry.FinalizeScope();
    end;

    local procedure EnsureDetectionJobScheduled()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyScheduleDetectionJQ: Codeunit "NPR Spfy Schedule Detection JQ";
    begin
        SpfyChangeTrackerMgt.RegisterEnabledTables();
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();
        Commit();
    end;

    // Codeunit.Run (not [TryFunction]) so DB writes roll back on failure and the bypass flag clears on both outcomes.
    local procedure EnableFeatureWithBypass()
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        EnableOk: Boolean;
    begin
        // Remembered for the failure compensation: only a run that switched the feature on may switch it back off.
        _FeatureEnabledByThisRun := not SpfyRowVersionFeature.IsFeatureEnabled();
        SetMigrationInProgress(true);
        EnableOk := SpfyRowVersionFeature.Run();
        SetMigrationInProgress(false);
        if not EnableOk then
            Error('%1', GetLastErrorText());
        Commit();
    end;

    local procedure DrainBacklog()
    var
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
    begin
        SpfyScheduleSendTasks.DrainShopifyDataLogBacklogNow();
        Commit();
    end;

    local procedure TeardownDataLog()
    var
        SpfyDLogSubscrMgtImpl: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
    begin
        SpfyDLogSubscrMgtImpl.RemoveDataLogSetup("NPR Spfy Integration Area"::Items);
        SpfyDLogSubscrMgtImpl.RemoveDataLogSetup("NPR Spfy Integration Area"::"Inventory Levels");
        SpfyDLogSubscrMgtImpl.RemoveDataLogSetup("NPR Spfy Integration Area"::"Item Prices");
        SpfyDLogSubscrMgtImpl.RemoveDataLogSetup("NPR Spfy Integration Area"::"Retail Vouchers");
        SpfyDLogSubscrMgtImpl.RemoveDataLogSetup("NPR Spfy Integration Area"::"Sales Orders");
        Commit();
    end;

    local procedure MarkSeedingStarted(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        SpfyIntegrationSetup."RowVersion Seeding Started At" := CurrentDateTime();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Seeding);
    end;

    local procedure SetStatus(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"; NewStatus: Option)
    begin
        SpfyIntegrationSetup."RowVersion Migration Status" := NewStatus;
        if SpfyIntegrationSetup."RowVersion Migration Status" <> SpfyIntegrationSetup."RowVersion Migration Status"::Failed then
            Clear(SpfyIntegrationSetup."RowVersion Seeding Error Text");
        SpfyIntegrationSetup.Modify();
        Commit();
    end;

    local procedure RunIsStale(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup"): Boolean
    begin
        if SpfyIntegrationSetup."RowVersion Seeding Started At" = 0DT then
            exit(true);
        exit((CurrentDateTime() - SpfyIntegrationSetup."RowVersion Seeding Started At") > StalenessThresholdMs());
    end;

    local procedure StalenessThresholdMs(): Integer
    begin
        exit(60 * 60 * 1000);
    end;

    internal procedure RefreshRunHeartbeat()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not SpfyIntegrationSetup.Get() then
            exit;
        if not (SpfyIntegrationSetup."RowVersion Migration Status" in
                [SpfyIntegrationSetup."RowVersion Migration Status"::Seeding, SpfyIntegrationSetup."RowVersion Migration Status"::Migrating]) then
            exit;
        SpfyIntegrationSetup."RowVersion Seeding Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify();
    end;

    local procedure MigratePosEntryMark()
    begin
        // Intentional no-op: POS bypasses Data Log via its own per-store sync pointer; nothing to fold onto the tracker.
    end;

    var
        _MigrationInProgress: Boolean;
        _CutoverAuthorized: Boolean;
        _FeatureEnabledByThisRun: Boolean;
}
