codeunit 6151217 "NPR Spfy RowVersion Migration"
{
    Access = Internal;
    SingleInstance = true;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        SpfyIntegrationSetup.LockTable();
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyRowVersionFeature.RunsShopifyOnDataLog() then
            exit;
        RunFullMigration(SpfyIntegrationSetup, false);
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
    begin
        MarkSeedingStarted(SpfyIntegrationSetup);
        if RunForeground then
            RunFullMigration(SpfyIntegrationSetup, true)
        else begin
            // Codeunit.Run (not [TryFunction]): a failed partial JQ write rolls back; MarkSeedingStarted already committed.
            if not ScheduleBgMigration.Run() then begin
                SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Failed);
                Error(GetLastErrorText());
            end;
            if MigrationEntryIsOnHold() then
                Message(BackgroundNeedsActivationMsg)
            else
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

    local procedure RunCutover(var SpfyIntegrationSetup: Record "NPR Spfy Integration Setup")
    begin
        // Fresh cutover start time so a concurrent admin's staleness check doesn't misclassify this live run.
        SpfyIntegrationSetup."RowVersion Seeding Started At" := CurrentDateTime();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Migrating);
        EnableFeatureWithBypass();
        DrainBacklog();
        TeardownDataLog();
        MigratePosEntryMark();
        // Ensure the job before marking Completed so a scheduling failure leaves the migration re-runnable.
        EnsureDetectionJobScheduled();
        SetStatus(SpfyIntegrationSetup, SpfyIntegrationSetup."RowVersion Migration Status"::Completed);
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
        SetMigrationInProgress(true);
        EnableOk := SpfyRowVersionFeature.Run();
        SetMigrationInProgress(false);
        if not EnableOk then
            Error(GetLastErrorText());
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
}
