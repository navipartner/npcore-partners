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
        PageDescriptionLbl: Label 'Shopify RowVersion Change Detection — a managed, one-way switch. Enable it here only on a new environment, while no Shopify integration area has been switched on yet; detection then starts immediately and there is nothing to migrate. Once any integration area is on, this environment detects Shopify changes with the Data Log and must be moved across with the "Migrate to RowVersion detection" action on the Shopify Integration Setup page, which also removes the Data Log wiring.', MaxLength = 2048;
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
    begin
        ShopifyStore.SetRange(Enabled, true);
        ShopifyStore.SetFilter(Code, '<>%1', CurrentStoreCode);
        if not ShopifyStore.IsEmpty() then
            exit(false);
        exit(not HasSyncedShopifyData());
    end;

    internal procedure RunsShopifyOnDataLog(): Boolean
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyHandlerId: Code[20];
    begin
        SpfyHandlerId := SpfyIntegrationMgt.DataProcessingHandlerID(false);
        if SpfyHandlerId = '' then
            exit(false);
        DataLogSubscriber.SetRange(Code, SpfyHandlerId);
        exit(not DataLogSubscriber.IsEmpty());
    end;

    internal procedure HasSyncedShopifyData(): Boolean
    var
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if RunsShopifyOnDataLog() then
            exit(true);
        if not SpfyAssignedID.IsEmpty() then
            exit(true);
        SpfyStoreItemLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreItemLink.IsEmpty() then
            exit(true);
        SpfyStoreCustomerLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreCustomerLink.IsEmpty() then
            exit(true);
        exit(false);
    end;

    // Uses RunsShopifyOnDataLog (not HasSyncedShopifyData) so a RowVersion-adopted env's install/upgrade re-enable isn't blocked.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        CannotDisableErr: Label 'The %1 feature is one-way and cannot be disabled once enabled.', Comment = '%1 = feature description';
        ExistingIntegrationErr: Label 'Enabling %1 here is only possible before this environment has any Shopify Data Log wiring, which switching on an integration area creates. This environment still has that wiring, so it requires running the RowVersion migration instead. Use the "Migrate to RowVersion detection" action on the Shopify Integration Setup page.', Comment = '%1 = feature description';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if CurrFieldNo = 0 then
            exit;
        if xRec.Enabled and not Rec.Enabled then
            Error(CannotDisableErr, GetFeatureDescription());
        if Rec.Enabled and not xRec.Enabled then
            if RunsShopifyOnDataLog() and not SpfyRowVersionMigration.MigrationInProgress() and not IsInstallUpgradeRestore() then
                Error(ExistingIntegrationErr, GetFeatureDescription());
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

    // UI-enable path only: xRec carries the real before-image just for page-driven modifies; code-driven enables get the side effects from SetFeatureEnabled.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure NPRFeatureOnAfterModifyEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if not (Rec.Enabled and not xRec.Enabled) then
            exit;
        RunPostEnableSideEffects();
    end;

    local procedure RunPostEnableSideEffects()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        SpfyScheduleDetectionJQ: Codeunit "NPR Spfy Schedule Detection JQ";
    begin
        SpfyChangeTrackerMgt.RegisterEnabledTables();
        // Reseed marks to current max only during the cutover; on an install/upgrade restore it would skip pending changes → lost sends.
        if SpfyRowVersionMigration.MigrationInProgress() then
            ChangeTrackerMgt.ReseedAllMarksToCurrentMax("NPR Integration Type"::Shopify);
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();
        if not RunsShopifyOnDataLog() then
            MarkMigrationCompletedForNonDataLogEnable();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure AutoAdoptRowVersionOnShopifyFeatureEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    begin
        if Rec.Feature <> Enum::"NPR Feature"::Shopify then
            exit;
        if not (Rec.Enabled and not xRec.Enabled) then
            exit;
        MaybeAutoAdoptFreshEnvironment('');
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
