codeunit 6151244 "NPR Spfy Task List Feature" implements "NPR Feature Management"
{
    Access = Internal;

    // Runnable only so the migration can invoke the enable via Codeunit.Run (rollback on failure).
    trigger OnRun()
    var
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        NotViaJobQueueErr: Label 'The %1 feature can only be enabled by the Shopify task list migration.', Comment = '%1 = feature description';
    begin
        // Access = Internal does not stop the Job Queue dispatcher, and the table validate subscriber cannot help
        // here: a code-driven Validate passes CurrFieldNo = 0 and is skipped. So this entry gates itself.
        if not SpfyTaskListMigration.MigrationInProgress() then
            Error(NotViaJobQueueErr, GetFeatureDescription());
        EnableFeatureChecked();
    end;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
        PageDescriptionLbl: Label 'Shopify Task List — a managed, one-way switch. It is NOT enabled directly here: a fresh environment adopts it automatically when the Shopify integration is enabled, and an existing environment is migrated via the "Migrate to Shopify Task List" action on the Shopify Integration Setup page.', MaxLength = 2048;
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := CopyStr(PageDescriptionLbl, 1, MaxStrLen(Feature.Description));
        Feature.Validate(Feature, Enum::"NPR Feature"::"Shopify Task List");
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

    internal procedure MaybeAutoAdoptFreshEnvironment()
    begin
        if IsFeatureEnabled() then
            exit;
        if not IsFreshTaskListCandidate() then
            exit;
        EnableFeatureChecked();
    end;

    local procedure MarkMigrationCompletedForNonMigrationEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not IsFeatureEnabled() then
            exit;
        SpfyIntegrationSetup.GetRecordOnce(true);
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::NotStarted then
            exit;
        SpfyIntegrationSetup."Task List Migration Status" := SpfyIntegrationSetup."Task List Migration Status"::Completed;
        SpfyIntegrationSetup.Modify();
        // No Commit: runs inside the enable's validate/modify chain, so it must ride the ambient transaction.
    end;

    internal procedure IsFreshTaskListCandidate(): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        ShopifyTaskProcessorCode: Code[20];
    begin
        if SpfyRowVersionFeature.HasSyncedShopifyData() then
            exit(false);
        ShopifyTaskProcessorCode := SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(false);
        if ShopifyTaskProcessorCode = '' then
            exit(true);
        NcTask.SetRange("Task Processor Code", ShopifyTaskProcessorCode);
        NcTask.SetRange(Processed, false);
        exit(NcTask.IsEmpty());
    end;

    internal procedure AllPhasesShipped(): Boolean
    begin
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        CannotDisableErr: Label 'The %1 feature is one-way and cannot be disabled once enabled.', Comment = '%1 = feature description';
        FeatureNotYetAvailableErr: Label '%1 ships across several releases and cannot be activated yet.', Comment = '%1 = feature description';
        ExistingIntegrationErr: Label 'Enabling %1 on an environment that already synchronizes Shopify data requires running the task list migration. Use the "Migrate to Shopify Task List" action on the Shopify Integration Setup page.', Comment = '%1 = feature description';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if CurrFieldNo = 0 then
            exit;
        if xRec.Enabled and not Rec.Enabled then
            Error(CannotDisableErr, GetFeatureDescription());
        if Rec.Enabled and not xRec.Enabled then begin
            if not AllPhasesShipped() then
                Error(FeatureNotYetAvailableErr, GetFeatureDescription());
            if not IsFreshTaskListCandidate() and not SpfyTaskListMigration.MigrationInProgress() and not IsInstallUpgradeRestore() then
                Error(ExistingIntegrationErr, GetFeatureDescription());
        end;
    end;

    local procedure IsInstallUpgradeRestore(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if GuiAllowed() then
            exit(false);
        if not SpfyIntegrationSetup.Get() then
            exit(false);
        exit(SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Migrating);
    end;

    // UI-enable path only: xRec carries the real before-image just for page-driven modifies; code-driven enables get the side effects from SetFeatureEnabled.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure NPRFeatureOnAfterModifyEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    begin
        if not AllPhasesShipped() then
            exit;
        if Rec.Id <> GetFeatureId() then
            exit;
        if not (Rec.Enabled and not xRec.Enabled) then
            exit;
        RunPostEnableSideEffects();
    end;

    local procedure RunPostEnableSideEffects()
    var
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
    begin
        // During a migration the migration itself owns the completion stamp and the job queue setup.
        if SpfyTaskListMigration.MigrationInProgress() then
            exit;
        MarkMigrationCompletedForNonMigrationEnable();
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure AutoAdoptTaskListOnShopifyFeatureEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    begin
        if not AllPhasesShipped() then
            exit;
        if Rec.Feature <> Enum::"NPR Feature"::Shopify then
            exit;
        if not (Rec.Enabled and not xRec.Enabled) then
            exit;
        MaybeAutoAdoptFreshEnvironment();
    end;

    local procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'ShopifyTaskList', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    internal procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'Shopify Task List', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;
}
