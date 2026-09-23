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
        PageDescriptionLbl: Label 'Shopify Task List — a managed switch. Enable it here only on a new environment that already runs Shopify on RowVersion change detection, while nothing has gone through the task list yet; it can still be switched off again for as long as that holds. An environment that already synchronizes Shopify data is migrated instead, with the "Migrate to Shopify Task List" action on the Shopify Integration Setup page; after that migration the switch is one-way.', MaxLength = 2048;
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

    // The single fresh-environment adoption path for both one-way Shopify switches. A fresh environment adopts them
    // together and in order: the task list is never adopted on its own, because the queue it replaces is also what pumps
    // the Data Log an unmigrated detection still runs on. Both freshness tests must agree, so the weaker one alone
    // (RowVersion already enabled) cannot carry the adoption.
    internal procedure MaybeAutoAdoptFreshEnvironment(CurrentStoreCode: Code[20])
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationFeature: Codeunit "NPR Spfy Integration Feature";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
    begin
        if not AutoAdoptionEnabled() then
            exit;
        if not SpfyIntegrationFeature.IsFeatureEnabled() then
            exit;
        if not SpfyRowVersionFeature.IsFreshRowVersionCandidate(CurrentStoreCode) then
            exit;
        if not IsFreshTaskListCandidate() then
            exit;
        SpfyRowVersionFeature.MaybeAutoAdoptFreshEnvironment(CurrentStoreCode);
        if not SpfyIntegrationSetup.Get() then
            exit;
        if SpfyIntegrationSetup."RowVersion Migration Status" <> SpfyIntegrationSetup."RowVersion Migration Status"::Completed then
            exit;
        if IsFeatureEnabled() then
            exit;
        EnableFeatureChecked();
    end;

    // CORE-2063: auto-adoption suspended for go-live - return true to restore it (fresh environments migrate via the Setup action).
    local procedure AutoAdoptionEnabled(): Boolean
    begin
        exit(false);
    end;

    local procedure MarkMigrationCompletedForNonMigrationEnable()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not IsFeatureEnabled() then
            exit;
        SpfyIntegrationSetup.GetRecordOnce(true);
        // Failed counts as never migrated: the trap switched the feature off, so an enable arriving here is a fresh adoption.
        if not (SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::NotStarted, SpfyIntegrationSetup."Task List Migration Status"::Failed])
        then
            exit;
        SpfyIntegrationSetup."Task List Migration Status" := SpfyIntegrationSetup."Task List Migration Status"::Completed;
        // Completed is terminal for the lease too: a dispatched entry still carrying the old run id must stand down rather than cut over.
        Clear(SpfyIntegrationSetup."Task List Migration Run ID");
        SpfyIntegrationSetup.Modify();
        // No Commit: runs inside the enable's validate/modify chain, so it must ride the ambient transaction.
    end;

    internal procedure IsFreshTaskListCandidate(): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        ShopifyTaskProcessorCode: Code[20];
    begin
        if SpfyIntegrationMgt.HasSyncedShopifyData() then
            exit(false);
        ShopifyTaskProcessorCode := SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(false);
        if ShopifyTaskProcessorCode = '' then
            exit(true);
        NcTask.SetRange("Task Processor Code", ShopifyTaskProcessorCode);
        NcTask.SetRange(Processed, false);
        exit(NcTask.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature"; CurrFieldNo: Integer)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyIntegrationFeature: Codeunit "NPR Spfy Integration Feature";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        ExistingIntegrationErr: Label 'Enabling %1 on an environment that already synchronizes Shopify data requires running the task list migration. Use the "Migrate to Shopify Task List" action on the Shopify Integration Setup page.', Comment = '%1 = feature description';
        RowVersionRequiredErr: Label 'Enabling %1 requires this environment to detect Shopify changes with RowVersion. Enable the %2 feature first.', Comment = '%1 = feature description, %2 = RowVersion feature description';
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
            // Preconditions before the migration message, which names an action on a page the NPRShopify application area hides while the Shopify feature is off.
            if not SpfyIntegrationFeature.IsFeatureEnabled() then
                Error(ShopifyFeatureOffErr, SpfyIntegrationFeature.GetFeatureDescription(), GetFeatureDescription());
            // The same precondition the migration enforces in CheckMigrationPrerequisites: the task list rides on RowVersion detection.
            if not (SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyIntegrationMgt.RunsShopifyOnDataLog()) then
                Error(RowVersionRequiredErr, GetFeatureDescription(), SpfyRowVersionFeature.GetFeatureDescription());
            if not IsFreshTaskListCandidate() and not SpfyTaskListMigration.MigrationInProgress() and not IsInstallUpgradeRestore() then
                Error(ExistingIntegrationErr, GetFeatureDescription());
        end;
    end;

    // One Label, two raisers: the validate guard refuses the tick, and the after-modify guard refuses a disable whose
    // environment stopped being pristine between the two round trips.
    local procedure CannotDisableError()
    var
        CannotDisableErr: Label 'The %1 feature can no longer be disabled: this environment already runs Shopify sends through the task list, and switching it off would strand that work.', Comment = '%1 = feature description';
    begin
        Error(CannotDisableErr, GetFeatureDescription());
    end;

    // A disable is destructive as soon as anything has gone through the task list: the legacy NaviConnect queue no
    // longer carries that work. It is permitted only while the adoption is still untouched. Unlike the RowVersion
    // sibling this does NOT reject on a store row existing: a store's own enable creates the legacy task queues
    // alongside the new ones (SpfyStore.Table.al, field Enabled), so the fallback engine is still wired - only a real
    // migration removes it, and the lease arms below reject that environment.
    local procedure IsPristineAdoption(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyTagUpdateRequest: Record "NPR Spfy Tag Update Request";
        SpfyTask: Record "NPR Spfy Task";
    begin
        // Covers the synced-data classes and the unprocessed legacy NaviConnect backlog.
        if not IsFreshTaskListCandidate() then
            exit(false);
        // Any row at all, processed or not: a task the list has already carried is work the legacy queue never saw.
        if not SpfyTask.IsEmpty() then
            exit(false);
        if not SpfyTagUpdateRequest.IsEmpty() then
            exit(false);
        // Deliberately NOT tested: "Last Task List Cycle At". The processor stamps it on every cycle, including one
        // that sent nothing, so within a minute of a pristine tick it would latch the switch shut again - the very
        // trap this change removes. Work that actually entered the list is already rejected by the arms above.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task Processor");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            exit(false);
        if not SpfyIntegrationSetup.Get() then
            exit(true);
        // A real migration stamps the start and takes a run lease; a pristine tick does neither.
        if SpfyIntegrationSetup."Task List Migr. Started At" <> 0DT then
            exit(false);
        if not IsNullGuid(SpfyIntegrationSetup."Task List Migration Run ID") then
            exit(false);
        exit(SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::NotStarted, SpfyIntegrationSetup."Task List Migration Status"::Completed]);
    end;

    local procedure IsInstallUpgradeRestore(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if GuiAllowed() then
            exit(false);
        if not SpfyIntegrationSetup.Get() then
            exit(false);
        exit(SpfyIntegrationSetup."Task List Migration Status" in
            [SpfyIntegrationSetup."Task List Migration Status"::Migrating, SpfyIntegrationSetup."Task List Migration Status"::Finalizing]);
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
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
    begin
        // During a migration the migration itself owns the completion stamp and the job queue setup.
        if SpfyTaskListMigration.MigrationInProgress() then
            exit;
        MarkMigrationCompletedForNonMigrationEnable();
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();
    end;

    // The validate guard checked the same predicate one page round trip earlier; it is re-checked below because work
    // can arrive in between. Deliberately not called from SetFeatureEnabled: the only code-driven disable is the
    // cutover rollback, which owns its own status handling.
    local procedure RunPostDisableSideEffects()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // The cutover rollback disables the feature itself and owns the stamp it just wrote - never clean up after it.
        if SpfyTaskListMigration.MigrationInProgress() then
            exit;
        // Re-checked, not trusted from the validate guard: a page persists the Modify on a later round trip, so task
        // list work can have arrived in between. Erroring rolls the disable back with it; merely skipping the cleanup
        // would still leave that work stranded on a queue nothing drains.
        if not IsPristineAdoption() then
            CannotDisableError();
        // Per store, unlike the RowVersion sibling's single detection job.
        if ShopifyStore.FindSet() then
            repeat
                SpfyTaskJQSetup.CancelTaskProcessingJobQueue(ShopifyStore.Code);
            until ShopifyStore.Next() = 0;
        // "Task List Migr. Started At" and the run lease are NOT cleared here: IsPristineAdoption already refuses
        // unless both are empty, so clearing them would be a no-op no test could ever turn red.
        if SpfyIntegrationSetup.Get() then
            if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::NotStarted then begin
                SpfyIntegrationSetup."Task List Migration Status" := SpfyIntegrationSetup."Task List Migration Status"::NotStarted;
                SpfyIntegrationSetup.Modify();
            end;
        // Re-arm the legacy senders LAST, after the status reset: SetupTaskProcessingJobQueue cancels instead of
        // creating while TaskListMigrationStarted() is true, and that predicate counts Completed - the very status a
        // pristine tick stamps. Without this a store enabled during the adoption window is left with no sender at all.
        // Mirrors the migration's own rollback (SpfyTaskListMigration, failed cutover).
        SpfyScheduleSendTasks.SetupTaskProcessingJobQueues();
        // No Commit: runs inside the page's modify chain, so it must ride the ambient transaction.
    end;

    // State-checked, not transition-checked: a code-driven enable leaves xRec equal to Rec, so a transition guard
    // never sees the programmatic Shopify enables. The adopt is idempotent and candidacy-gated, so re-running it on a
    // modify that leaves Shopify enabled is a no-op on every environment that is not fresh.
    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnAfterModifyEvent', '', false, false)]
    local procedure AutoAdoptTaskListOnShopifyFeatureEnabled(var Rec: Record "NPR Feature")
    begin
        if Rec.Feature <> Enum::"NPR Feature"::Shopify then
            exit;
        if not Rec.Enabled then
            exit;
        MaybeAutoAdoptFreshEnvironment('');
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
