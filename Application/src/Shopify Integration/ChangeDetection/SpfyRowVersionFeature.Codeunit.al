codeunit 6151216 "NPR Spfy RowVersion Feature" implements "NPR Feature Management"
{
    Access = Internal;

    // Runnable only so the migration can invoke the enable via Codeunit.Run (rollback on failure).
    trigger OnRun()
    begin
        EnableFeatureChecked();
    end;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        PageDescriptionLbl: Label 'Shopify RowVersion Change Detection — a managed switch. Enable it here only on a new environment that has the Shopify Integration feature on and no Shopify integration area switched on yet. It can be switched back off only while nothing has run on it: no Shopify store, the Shopify Task List off, and nothing detected or synchronized. Otherwise use the "Migrate to RowVersion detection" action on the Shopify Integration Setup page.', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := CopyStr(PageDescriptionLbl, 1, MaxStrLen(Feature.Description));
        Feature.Validate(Feature, Enum::"NPR Feature"::"Shopify RowVersion Change Detection");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;
        if Feature.Enabled = NewEnabled then
            exit;
        Feature.Validate(Enabled, NewEnabled);
        Feature.Modify();
        // The OnAfterModify subscriber can't see this transition (xRec = Rec on code-driven modifies) - fire the side effects here, where the old value is known.
        if NewEnabled then
            RunPostEnableSideEffects();
    end;

    internal procedure EnableFeatureChecked()
    begin
        SetFeatureEnabled(true);
    end;

    internal procedure MaybeAutoAdoptFreshEnvironment(CurrentStoreCode: Code[20])
    begin
        if not AutoAdoptionEnabled() then
            exit;
        if IsFeatureEnabled() then
            exit;
        if not IsFreshRowVersionCandidate(CurrentStoreCode) then
            exit;
        EnableFeatureChecked();
    end;

    // CORE-2063: auto-adoption suspended for go-live - return true to restore it (until then a fresh environment enables the feature itself on Feature Management; the Setup action only appears once an integration area is on).
    local procedure AutoAdoptionEnabled(): Boolean
    begin
        exit(false);
    end;

    local procedure MarkMigrationCompletedForNonDataLogEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        if not IsFeatureEnabled() then
            exit;
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyIntegrationSetup."RowVersion Migration Status" <> SpfyIntegrationSetup."RowVersion Migration Status"::NotStarted then
            exit;
        SpfyIntegrationSetup."RowVersion Migration Status" := SpfyIntegrationSetup."RowVersion Migration Status"::Completed;
        SpfyIntegrationSetup."RowVersion Pld. Ver. Seeded" := SpfySyncStateMgt.PayloadVersion();
        SpfyIntegrationSetup.Modify();
        // No Commit: runs inside the enable's validate/modify chain, so it must ride the ambient transaction.
    end;

    internal procedure IsFreshRowVersionCandidate(CurrentStoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyStore.SetRange(Enabled, true);
        ShopifyStore.SetFilter(Code, '<>%1', CurrentStoreCode);
        if not ShopifyStore.IsEmpty() then
            exit(false);
        exit(not SpfyIntegrationMgt.HasSyncedShopifyData());
    end;

    // Uses RunsShopifyOnDataLog (not HasSyncedShopifyData) so a RowVersion-adopted env's install/upgrade re-enable isn't blocked.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyIntegrationFeature: Codeunit "NPR Spfy Integration Feature";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        ExistingIntegrationErr: Label 'Enabling %1 here is only possible before this environment has any Shopify Data Log wiring, which switching on an integration area creates. This environment still has that wiring, so it requires running the RowVersion migration instead. Use the "Migrate to RowVersion detection" action on the Shopify Integration Setup page.', Comment = '%1 = feature description';
        ShopifyFeatureOffErr: Label 'Enable the %1 feature before enabling %2.', Comment = '%1 = Shopify Integration feature description, %2 = feature description';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if CurrFieldNo = 0 then
            exit;
        if xRec.Enabled and not Rec.Enabled then begin
            if not IsPristineAdoption() then
                CannotDisableError();
            exit;
        end;
        if Rec.Enabled and not xRec.Enabled then begin
            // Precondition first: the migration message names an action on the Shopify Integration Setup page, which
            // the NPRShopify application area hides while this feature is off - naming it there would dead-end.
            if not SpfyIntegrationFeature.IsFeatureEnabled() then
                Error(ShopifyFeatureOffErr, SpfyIntegrationFeature.GetFeatureDescription(), GetFeatureDescription());
            if SpfyIntegrationMgt.RunsShopifyOnDataLog() and not SpfyRowVersionMigration.MigrationInProgress() and not IsInstallUpgradeRestore() then
                Error(ExistingIntegrationErr, GetFeatureDescription());
        end;
    end;

    // One Label, two raisers: the validate guard refuses the tick, and the after-modify guard refuses a disable whose
    // environment stopped being pristine between the two round trips. It names the blocking artifact, because the
    // operator otherwise has no way to find out which one it is.
    local procedure CannotDisableError()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        CannotDisableErr: Label 'The %1 feature can no longer be disabled: %2.', Comment = '%1 = feature description, %2 = the reason, a sentence fragment';
        NotEmptyTxt: Label 'this environment is no longer empty - it has a Shopify store, or change detection has already recorded something here';
        SyncedTxt: Label 'this environment already detects Shopify changes with it, and switching it off would leave no change detection at all';
        TaskListOnTxt: Label 'the Shopify Task List is switched on and rides on this detection. Switch the task list off first';
    begin
        if SpfyIntegrationMgt.HasSyncedShopifyData() then
            Error(CannotDisableErr, GetFeatureDescription(), SyncedTxt);
        if SpfyTaskListFeature.IsFeatureEnabled() then
            Error(CannotDisableErr, GetFeatureDescription(), TaskListOnTxt);
        // Store and detection rows share one reason: naming deletion first sent operators to delete a live store that was never the blocker.
        Error(CannotDisableErr, GetFeatureDescription(), NotEmptyTxt);
    end;

    // A disable is destructive as soon as anything has run on RowVersion: the capture subscribers and the poll are then
    // the only detection left, so switching them off would silently stop sending. It is permitted only while the
    // adoption is still untouched. Keeping the predicate that strict is also what keeps RunPostDisableSideEffects down
    // to the detection job and the migration stamp.
    local procedure IsPristineAdoption(): Boolean
    var
        ChangeQuarantine: Record "NPR Change Quarantine";
        ChangeTracker: Record "NPR Change Tracker";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyResyncRun: Record "NPR Spfy Resync Run";
        SpfySyncState: Record "NPR Spfy Sync State";
        SpfyTask: Record "NPR Spfy Task";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
    begin
        if SpfyIntegrationMgt.HasSyncedShopifyData() then
            exit(false);
        // The task list adoption layers on RowVersion detection and is itself one-way; its own freshness test is reused because it already covers the unprocessed legacy NC task backlog.
        if SpfyTaskListFeature.IsFeatureEnabled() then
            exit(false);
        if not SpfyTaskListFeature.IsFreshTaskListCandidate() then
            exit(false);
        // Any store row at all, enabled or not: a disabled store keeps its integration area flags, and re-enabling it runs only the Enabled OnValidate, which never replays SetupIntegrationArea - the Data Log wiring would then never come back.
        if not ShopifyStore.IsEmpty() then
            exit(false);
        if not SpfySyncState.IsEmpty() then
            exit(false);
        if not SpfyDeletionLog.IsEmpty() then
            exit(false);
        if not SpfyTask.IsEmpty() then
            exit(false);
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        if not ChangeTracker.IsEmpty() then
            exit(false);
        ChangeQuarantine.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        if not ChangeQuarantine.IsEmpty() then
            exit(false);
        // Not IsResyncActive: that one deliberately ignores a stale Running row so a crashed run cannot block detection. Here any Running row means a worker may still be live.
        SpfyResyncRun.SetRange(Status, SpfyResyncRun.Status::Running);
        if not SpfyResyncRun.IsEmpty() then
            exit(false);
        // "RowVersion Migration Status" is deliberately not tested: it is derived state, not work, and every status that could mean a live worker is already refused above.
        exit(true);
    end;

    local procedure IsInstallUpgradeRestore(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if GuiAllowed() then
            exit(false);
        if not SpfyIntegrationSetup.Get() then
            exit(false);
        exit(SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::Migrating);
    end;

    // UI paths only: xRec carries the real before-image just for page-driven modifies; code-driven flips get their side effects from SetFeatureEnabled.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure NPRFeatureOnAfterModifyEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if Rec.Enabled and not xRec.Enabled then
            RunPostEnableSideEffects();
        if xRec.Enabled and not Rec.Enabled then
            RunPostDisableSideEffects();
    end;

    local procedure RunPostEnableSideEffects()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        SpfyScheduleDetectionJQ: Codeunit "NPR Spfy Schedule Detection JQ";
    begin
        SpfyChangeTrackerMgt.RegisterEnabledTables();
        // Reseed marks to current max only during the cutover; on an install/upgrade restore it would skip pending changes → lost sends.
        if SpfyRowVersionMigration.MigrationInProgress() then
            ChangeTrackerMgt.ReseedAllMarksToCurrentMax("NPR Integration Type"::Shopify);
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();
        if not SpfyIntegrationMgt.RunsShopifyOnDataLog() then
            MarkMigrationCompletedForNonDataLogEnable();
    end;

    // Reached only through the validate guard, which permits the disable only while the adoption is pristine - so this
    // undoes exactly what the pristine enable did, and nothing else. Deliberately not called from SetFeatureEnabled:
    // the only code-driven disable is the cutover rollback, which owns its own status handling.
    local procedure RunPostDisableSideEffects()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        SpfyScheduleDetectionJQ: Codeunit "NPR Spfy Schedule Detection JQ";
    begin
        // The cutover rollback disables the feature itself and owns the Failed stamp it just wrote - never clean up after it.
        if SpfyRowVersionMigration.MigrationInProgress() then
            exit;
        // Re-checked, not trusted from the validate guard: a page persists the Modify on a later round trip, so the
        // environment can have gained a store - and its only detection path - in between. Erroring rolls the disable
        // back with it; merely skipping the cleanup would still leave that store with no detection at all.
        if not IsPristineAdoption() then
            CannotDisableError();
        SpfyScheduleDetectionJQ.SetupChangeDetectionJobQueue(false);
        if not SpfyIntegrationSetup.Get() then
            exit;
        if SpfyIntegrationSetup."RowVersion Migration Status" = SpfyIntegrationSetup."RowVersion Migration Status"::NotStarted then
            exit;
        SpfyIntegrationSetup."RowVersion Migration Status" := SpfyIntegrationSetup."RowVersion Migration Status"::NotStarted;
        Clear(SpfyIntegrationSetup."RowVersion Pld. Ver. Seeded");
        Clear(SpfyIntegrationSetup."RowVersion Seeding Started At");
        Clear(SpfyIntegrationSetup."RowVersion Seeding Compl. At");
        Clear(SpfyIntegrationSetup."RowVersion Seeding Error Text");
        SpfyIntegrationSetup.Modify();
        // No Commit: runs inside the page's modify chain, so it must ride the ambient transaction.
    end;

    local procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'ShopifyRowVersionChangeDetection', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    internal procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'Shopify RowVersion Change Detection', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;
}
