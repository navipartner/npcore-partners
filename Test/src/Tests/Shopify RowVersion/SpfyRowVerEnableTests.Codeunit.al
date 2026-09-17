codeunit 85397 "NPR Spfy RowVer Enable Tests"
{
    // [FEATURE] Shopify RowVersion change detection - feature enablement: fresh-env auto-adopt, the migration orchestrator, migration guards, detection-job provisioning, per-area enable routing
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(false);
        ResetMigrationState();
    end;

    [Test]
    procedure GivenAnySyncedArtifact_ThenEnvIsNotFresh_AndBareEnvironmentAutoAdopts()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SyncState: Record "NPR Spfy Sync State";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Any synced artifact disqualifies an environment from being fresh, and a bare environment auto-adopts the feature with the migration marked Completed, the detection job ensured, no seeding and no Data Log setup.
        Initialize();
        NeutralizeSyncedArtifacts();
        _Assert.IsTrue(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'A bare environment must qualify as fresh');

        // [THEN] Each synced-artifact class independently disqualifies the environment (conservative predicate).
        StoreCode := _Lib.CreateStore(false, false, false, false, false);
        _Assert.IsFalse(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'Another enabled store must disqualify freshness');
        _Assert.IsTrue(SpfyRowVersionFeature.IsFreshRowVersionCandidate(StoreCode), 'The store being enabled right now must be excluded from the probe');
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Enabled := false;
        ShopifyStore.Modify(false);

        InsertSpfyDataLogSubscriber(Database::Item);
        _Assert.IsFalse(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'A Shopify Data Log subscription must disqualify freshness');
        DeleteSpfyDataLogSubscribers();

        _Lib.AssignEntryID(ShopifyStore.RecordId(), 'gid://fresh/probe');
        _Assert.IsFalse(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'An assigned Shopify ID must disqualify freshness');
        SpfyAssignedID.DeleteAll(false);

        SpfyStoreItemLink.Init();
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := _Lib.NextCode('IT', 20);
        SpfyStoreItemLink."Shopify Store Code" := StoreCode;
        SpfyStoreItemLink."Synchronization Is Enabled" := true;
        SpfyStoreItemLink.Insert(false);
        _Assert.IsFalse(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'A sync-enabled item link must disqualify freshness');
        SpfyStoreItemLink.Delete(false);

        SpfyStoreCustomerLink.Init();
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := _Lib.NextCode('CU', 20);
        SpfyStoreCustomerLink."Shopify Store Code" := StoreCode;
        SpfyStoreCustomerLink."Synchronization Is Enabled" := true;
        SpfyStoreCustomerLink.Insert(false);
        _Assert.IsFalse(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'A sync-enabled customer link must disqualify freshness');
        SpfyStoreCustomerLink.Delete(false);

        // [WHEN] The environment is bare again and the auto-adopt hook runs.
        _Assert.IsTrue(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'The environment must be fresh again after cleanup');
        SpfyRowVersionFeature.MaybeAutoAdoptFreshEnvironment('');

        // [THEN] The adopt enables the feature and runs the post-enable side effects: migration stamped Completed,
        // detection job ensured, no seeding, no Data Log setup.
        _Assert.IsTrue(SpfyRowVersionFeature.IsFeatureEnabled(), 'A fresh environment must auto-adopt the feature');
        ShopifySetup.Get();
        _Assert.IsTrue(ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::Completed, 'A fresh adopt must mark the migration Completed');
        _Assert.IsTrue(SyncState.IsEmpty(), 'A fresh adopt must not run any baseline seeding');
        _Assert.IsFalse(SpfyDataLogSubscribersExist(), 'A fresh adopt must never create Shopify Data Log setup');
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'A fresh adopt must ensure the detection job');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenDataLogIntegration_ThenManualEnableIsBlocked_AndEnabledFeatureIsOneWay()
    var
        Feature: Record "NPR Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Enabling the feature from the page is blocked while a Data Log integration exists, and an enabled feature can no longer be disabled.
        Initialize();
        // [GIVEN] An existing Data Log integration (SPFY subscriber rows present).
        InsertSpfyDataLogSubscriber(Database::Item);
        Commit();

        // [WHEN] An admin flips the feature on from the page (the guard is CurrFieldNo-gated: UI edits only).
        FeatureMgmt.OpenEdit();
        FeatureMgmt.Filter.SetFilter(Id, _Lib.FeatureId());
        asserterror FeatureMgmt.Enabled.SetValue(true);
        _Assert.ExpectedError('requires running the RowVersion migration');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsFalse(Feature.Enabled, 'The blocked enable must leave the feature disabled');

        // [GIVEN] The feature enabled (post-migration state).
        DeleteSpfyDataLogSubscribers();
        _Lib.SetFeatureEnabled(true);
        Commit();

        // [WHEN] An admin tries to disable it from the page. [THEN] the feature is one-way.
        FeatureMgmt.OpenEdit();
        FeatureMgmt.Filter.SetFilter(Id, _Lib.FeatureId());
        asserterror FeatureMgmt.Enabled.SetValue(false);
        _Assert.ExpectedError('one-way and cannot be disabled');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsTrue(Feature.Enabled, 'The blocked disable must leave the feature enabled');
    end;

    [Test]
    procedure GivenFeatureEnabled_WhenDetectionJobEnsured_ThenExactlyOneProtectedOneMinuteRecurringJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyScheduleDetectionJQ: Codeunit "NPR Spfy Schedule Detection JQ";
    begin
        // [SCENARIO] Ensuring the detection job leaves exactly one NP-protected recurring job running every minute however often it is ensured, and schedules nothing while the feature is off.
        Initialize();
        _Lib.SetFeatureEnabled(true);

        // [WHEN] The provisioning runs twice (initial enable + the login-time self-heal re-ensure).
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();

        // [THEN] Exactly one protected recurring detection job at a 1-minute cadence - never a duplicate.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'Ensure must be idempotent: exactly one detection job');
        JobQueueEntry.FindFirst();
        _Assert.IsTrue(JobQueueEntry."Recurring Job", 'The detection job must be recurring');
        _Assert.AreEqual(1, JobQueueEntry."No. of Minutes between Runs", 'The detection job must run every minute');
        _Assert.IsTrue(JobQueueEntry."NPR NP Protected Job", 'The detection job must be NP-protected');

        // [WHEN] The feature is off. [THEN] the self-heal never schedules anything.
        _Lib.DeleteDetectionJobQueueEntries();
        _Lib.SetFeatureEnabled(false);
        SpfyScheduleDetectionJQ.EnsureChangeDetectionJobScheduled();
        _Assert.AreEqual(0, JobQueueEntry.Count(), 'A disabled feature must not schedule the detection job');
    end;

    [Test]
    procedure GivenAreaEnabledOnStore_ThenRoutedToDataLogOrPollRegistrationByFeatureState()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        StoreCode: Code[20];
        SubscribersBefore: Integer;
    begin
        // [SCENARIO] Enabling an area on a store creates the Data Log setup while the feature is off, and registers the area's poll tables instead once the feature is on.
        Initialize();
        // [GIVEN] Feature OFF and a not-fresh environment (auto-adopt must decline inside the enable site).
        StoreCode := _Lib.CreateStore(false, false, false, false, false);
        ShopifyStore.Get(StoreCode);
        _Lib.AssignEntryID(ShopifyStore.RecordId(), 'gid://notfresh');

        // [WHEN] The Items area is enabled on the store.
        ShopifyStore.Validate("Item List Integration", true);
        ShopifyStore.Modify(true);

        // [THEN] The legacy route runs: Data Log setup created, no poll registration, feature still off.
        _Assert.IsTrue(SpfyDataLogSubscribersExist(), 'Feature off: enabling an area must create the Data Log setup');
        _Assert.IsFalse(_Lib.TrackerExists(Database::Item), 'Feature off: enabling an area must not register poll tables');
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'The non-fresh enable site must not auto-adopt the feature');

        // [GIVEN] Feature ON (post-cutover) and a clean tracker slate.
        _Lib.SetFeatureEnabled(true);
        _Lib.ResetState();
        SubscribersBefore := SpfyDataLogSubscriberCount();

        // [WHEN] The Items area is enabled on another store.
        StoreCode := _Lib.CreateStore(false, false, false, false, false);
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Validate("Item List Integration", true);
        ShopifyStore.Modify(true);

        // [THEN] The poll route runs: area tables registered, no additional Data Log setup.
        _Assert.IsTrue(_Lib.TrackerExists(Database::Item), 'Feature on: enabling an area must register its poll tables');
        _Assert.AreEqual(SubscribersBefore, SpfyDataLogSubscriberCount(), 'Feature on: enabling an area must not touch the Data Log setup');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    [HandlerFunctions('ForegroundRunModeStrMenuHandler,ConfirmYesHandler,SinkMessageHandler')]
    procedure GivenDataLogIntegrationNeedingSeed_WhenMigrationRunsInForeground_ThenSeededCutOverAndDataLogTornDown()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyDLogSubscrMgtImpl: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A never-seeded Data Log Shopify integration migrates in one foreground run: the baselines are seeded, the feature goes live, the Shopify Data Log setup is torn down and exactly one detection job is left behind.
        Initialize();
        // [GIVEN] An existing Data Log driven integration with one synced item and no baselines.
        DeleteSpfyDataLogSubscribers();
        SpfyDLogSubscrMgtImpl.CreateDataLogSetup("NPR Spfy Integration Area"::Items);
        _Assert.IsTrue(SpfyRowVersionFeature.RunsShopifyOnDataLog(), 'The migration must start from a Data Log driven integration');
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Assert.IsFalse(_Lib.HasBaseline(Database::Item, Item.SystemId, StoreCode), 'The migration must start without a baseline for the synced item');
        ShopifySetup.Get();
        _Assert.AreEqual(0, ShopifySetup."RowVersion Pld. Ver. Seeded", 'The migration must start from an unseeded payload version');

        // [WHEN] An admin runs the migration and picks the foreground run mode.
        SpfyRowVersionMigration.MigrateAndEnable();

        // [THEN] The feature is live and the migration is stamped Completed at the seeded payload version.
        _Assert.IsTrue(SpfyRowVersionFeature.IsFeatureEnabled(), 'The migration must leave RowVersion detection enabled');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::Completed,
            StrSubstNo('The migration must end Completed, actual status %1', ShopifySetup."RowVersion Migration Status"));
        _Assert.AreEqual(SpfySyncStateMgt.PayloadVersion(), ShopifySetup."RowVersion Pld. Ver. Seeded", 'The migration must stamp the payload version it seeded');
        // [THEN] The sweep seeded the synced item and the cutover removed the legacy Data Log route.
        _Assert.IsTrue(_Lib.HasBaseline(Database::Item, Item.SystemId, StoreCode), 'The seeding sweep must leave a baseline for the synced item');
        _Assert.IsFalse(SpfyRowVersionFeature.RunsShopifyOnDataLog(), 'The cutover must tear down the Shopify Data Log setup');
        // [THEN] Detection is provisioned exactly once.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'The migration must leave exactly one detection job');
        _Lib.DeleteDetectionJobQueueEntries();

        // The migration's Confirm and Message sites fire only when GuiAllowed() is true.
        _Lib.ConsumeConfirm();
        _Lib.ConsumeMessage();
    end;

    [Test]
    procedure GivenBareEnvironmentWithFeatureOff_WhenTheFeatureRecordIsEnabled_ThenPostEnableSideEffectsRun()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        // [SCENARIO] Enabling the feature through the app's SetFeatureEnabled stamps the migration Completed at the current payload version and ensures the detection job, without any migration run.
        Initialize();
        // [GIVEN] A bare environment, the feature present and disabled, no detection job.
        NeutralizeSyncedArtifacts();
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'The feature must start disabled');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::NotStarted,
            StrSubstNo('The migration must start NotStarted, actual status %1', ShopifySetup."RowVersion Migration Status"));
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(0, JobQueueEntry.Count(), 'No detection job may exist before the enable');

        // [WHEN] The feature is enabled through the app's own SetFeatureEnabled (the code-driven path that owns the post-enable side effects; the fixture bypass is not used).
        SpfyRowVersionFeature.SetFeatureEnabled(true);

        // [THEN] The feature is live.
        _Assert.IsTrue(SpfyRowVersionFeature.IsFeatureEnabled(), 'Enabling the Feature record must enable the feature');
        // [THEN] A non-Data-Log enable needs no migration: it is stamped Completed at the current payload version.
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::Completed,
            StrSubstNo('A non-Data-Log enable must stamp the migration Completed, actual status %1', ShopifySetup."RowVersion Migration Status"));
        _Assert.AreEqual(SpfySyncStateMgt.PayloadVersion(), ShopifySetup."RowVersion Pld. Ver. Seeded", 'A non-Data-Log enable must stamp the current payload version');
        // [THEN] Detection is provisioned exactly once.
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'The enable must ensure exactly one detection job');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    local procedure ResetMigrationState()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        // The setup singleton is shared by every test here; the migration assertions only mean something from an unmigrated start.
        ShopifySetup.Get();
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::NotStarted;
        ShopifySetup."RowVersion Pld. Ver. Seeded" := 0;
        Clear(ShopifySetup."RowVersion Seeding Started At");
        Clear(ShopifySetup."RowVersion Seeding Compl. At");
        Clear(ShopifySetup."RowVersion Seeding Error Text");
        ShopifySetup.Modify(false);
    end;

    local procedure NeutralizeSyncedArtifacts()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // The shared container carries synced leftovers; per-codeunit isolation rolls these writes back.
        ShopifyStore.SetRange(Enabled, true);
        if not ShopifyStore.IsEmpty() then
            ShopifyStore.ModifyAll(Enabled, false, false);
        if not SpfyAssignedID.IsEmpty() then
            SpfyAssignedID.DeleteAll(false);
        SpfyStoreItemLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreItemLink.IsEmpty() then
            SpfyStoreItemLink.ModifyAll("Synchronization Is Enabled", false, false);
        SpfyStoreCustomerLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreCustomerLink.IsEmpty() then
            SpfyStoreCustomerLink.ModifyAll("Synchronization Is Enabled", false, false);
        DeleteSpfyDataLogSubscribers();
    end;

    local procedure InsertSpfyDataLogSubscriber(TableNo: Integer)
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.Init();
        DataLogSubscriber.Code := SpfyIntegrationMgt.DataProcessingHandlerID(true);
        DataLogSubscriber."Table ID" := TableNo;
        DataLogSubscriber."Company Name" := '';
        DataLogSubscriber.Insert(false);
    end;

    local procedure DeleteSpfyDataLogSubscribers()
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.SetRange(Code, SpfyIntegrationMgt.DataProcessingHandlerID(false));
        if not DataLogSubscriber.IsEmpty() then
            DataLogSubscriber.DeleteAll(false);
    end;

    local procedure SpfyDataLogSubscribersExist(): Boolean
    begin
        exit(SpfyDataLogSubscriberCount() > 0);
    end;

    local procedure SpfyDataLogSubscriberCount(): Integer
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.SetRange(Code, SpfyIntegrationMgt.DataProcessingHandlerID(false));
        exit(DataLogSubscriber.Count());
    end;

    [StrMenuHandler]
    procedure ForegroundRunModeStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        _Assert.IsTrue(Instruction.Contains('one-way change'), StrSubstNo('The run-mode prompt must warn that the migration is one-way, actual instruction "%1"', Instruction));
        _Assert.IsTrue(Options.StartsWith('Run in foreground'), StrSubstNo('Option 1 must be the foreground run mode, actual options "%1"', Options));
        Choice := 1;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure SinkMessageHandler(MessageText: Text[1024])
    begin
    end;
}
