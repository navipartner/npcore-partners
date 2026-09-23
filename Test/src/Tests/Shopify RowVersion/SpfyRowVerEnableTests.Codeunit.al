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
        // Cleared BEFORE the feature is switched off: Modify(false) still raises OnAfterModifyEvent, so the disable
        // write below reaches the new cleanup arm, which refuses on a non-pristine environment. Clearing first means
        // the arm sees an empty environment whatever xRec turns out to carry on a code-driven modify.
        NeutralizeSyncedArtifacts();
        DeleteAllShopifyStores();
        SetShopifyIntegrationFeatureEnabled(true);
        _Lib.SetFeatureEnabled(false);
        ResetMigrationState();
    end;

    [Test]
    procedure GivenAnySyncedArtifact_ThenEnvIsNotFresh_AndBareEnvironmentDoesNotAutoAdopt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Any synced artifact disqualifies an environment from being fresh, and fresh-environment auto-adoption is suspended: an environment that still qualifies as a fresh candidate does not switch RowVersion detection on.
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

        // [THEN] The suspended adoption changes nothing: feature off, migration unstarted, no detection job.
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'A fresh environment must not auto-adopt the feature while adoption is suspended');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::NotStarted,
            StrSubstNo('A declined auto-adopt must leave the migration NotStarted, actual status %1', ShopifySetup."RowVersion Migration Status"));
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(0, JobQueueEntry.Count(), 'A declined auto-adopt must not ensure the detection job');
    end;

    [Test]
    procedure GivenFreshEnvironment_WhenAnIntegrationAreaIsEnabled_ThenShopifyStaysOnDataLog()
    var
        ShopifyStore: Record "NPR Spfy Store";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A fresh environment that enables a Shopify store and an integration area keeps the legacy Data Log path and leaves the migration action reachable.
        Initialize();
        // [GIVEN] A bare environment with the feature off, no Data Log subscribers, and an enabled store that still qualifies as fresh.
        NeutralizeSyncedArtifacts();
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'The environment must start with the feature off');
        _Assert.IsFalse(SpfyDataLogSubscribersExist(), 'The environment must start without Shopify Data Log setup');
        StoreCode := _Lib.CreateStore(false, false, false, false, false);
        ShopifyStore.Get(StoreCode);
        _Assert.IsTrue(SpfyRowVersionFeature.IsFreshRowVersionCandidate(StoreCode), 'The store being enabled must still qualify as a fresh RowVersion candidate');

        // [WHEN] The Items area is switched on for that store.
        ShopifyStore.Validate("Item List Integration", true);
        ShopifyStore.Modify(true);

        // [THEN] The legacy route runs instead of an adoption: the feature stays off and the Data Log setup is created.
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'A fresh environment must no longer adopt RowVersion detection');
        _Assert.IsTrue(SpfyDataLogSubscribersExist(), 'A fresh environment must fall back to the legacy Data Log setup');
        // [THEN] The environment answers the migration action's visibility predicate, so an operator can still start the migration.
        _Assert.IsTrue(SpfyIntegrationMgt.RunsShopifyOnDataLog(), 'The environment must run Shopify on the Data Log, which is what keeps the migration action reachable');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::NotStarted,
            StrSubstNo('An unadopted environment must stay NotStarted, actual status %1', ShopifySetup."RowVersion Migration Status"));
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(0, JobQueueEntry.Count(), 'An unadopted environment must have no change detection job');

        // The area tick committed SPFY subscriber rows, and Initialize() does not clear them for the next test.
        DeleteSpfyDataLogSubscribers();
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
        OpenRowVersionFeature(FeatureMgmt);
        asserterror FeatureMgmt.Enabled.SetValue(true);
        _Assert.ExpectedError('requires running the RowVersion migration');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsFalse(Feature.Enabled, 'The blocked enable must leave the feature disabled');

        // [GIVEN] The feature enabled on an environment that has already run on it (a baseline exists).
        DeleteSpfyDataLogSubscribers();
        _Lib.SetFeatureEnabled(true);
        InsertSyncStateRow();
        Commit();

        // [WHEN] An admin tries to disable it from the page. [THEN] the switch is closed for good.
        OpenRowVersionFeature(FeatureMgmt);
        asserterror FeatureMgmt.Enabled.SetValue(false);
        _Assert.ExpectedError('can no longer be disabled');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsTrue(Feature.Enabled, 'The blocked disable must leave the feature enabled');
    end;

    [Test]
    procedure GivenPristineAdoption_WhenTheFeatureIsDisabledFromThePage_ThenItIsOffTheJobIsGoneAndTheStampIsCleared()
    var
        Feature: Record "NPR Feature";
        JobQueueEntry: Record "Job Queue Entry";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] A RowVersion adoption that nothing has run on yet can be undone from the page, and the undo takes the detection job and the migration stamp with it.
        Initialize();
        // [GIVEN] A pristine environment that adopted RowVersion through the app's own enable.
        SpfyRowVersionFeature.SetFeatureEnabled(true);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'The adoption must leave exactly one detection job to undo');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::Completed,
            StrSubstNo('The adoption must stamp the migration Completed, actual status %1', ShopifySetup."RowVersion Migration Status"));
        // [GIVEN] Seeding residue from an earlier attempt. The pristine enable never writes these three, so without
        // seeding them here the "must be cleared" assertions below could not go red however the cleanup changed.
        ShopifySetup."RowVersion Seeding Started At" := CurrentDateTime();
        ShopifySetup."RowVersion Seeding Compl. At" := CurrentDateTime();
        ShopifySetup."RowVersion Seeding Error Text" := 'residue from an earlier attempt';
        ShopifySetup.Modify(false);
        Commit();

        // [WHEN] An admin unticks the feature on the page. The Modify - and the side effects - run when the page closes, not on SetValue.
        OpenRowVersionFeature(FeatureMgmt);
        FeatureMgmt.Enabled.SetValue(false);
        FeatureMgmt.Close();

        // [THEN] The feature is off again.
        Feature.Get(_Lib.FeatureId());
        _Assert.IsFalse(Feature.Enabled, 'A pristine adoption must be undoable');
        // [THEN] The detection job is gone, so an environment with no Shopify integration stops polling every minute.
        _Assert.AreEqual(0, JobQueueEntry.Count(), 'The disable must remove the detection job');
        // [THEN] The migration stamp the adoption wrote is fully rolled back, so the Setup page offers the migration again.
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::NotStarted,
            StrSubstNo('The disable must reset the migration status, actual status %1', ShopifySetup."RowVersion Migration Status"));
        _Assert.AreEqual(0, ShopifySetup."RowVersion Pld. Ver. Seeded", 'The disable must clear the seeded payload version');
        _Assert.AreEqual(0DT, ShopifySetup."RowVersion Seeding Started At", 'The disable must clear the seeding start stamp');
        _Assert.AreEqual(0DT, ShopifySetup."RowVersion Seeding Compl. At", 'The disable must clear the seeding completion stamp');
        _Assert.AreEqual('', ShopifySetup."RowVersion Seeding Error Text", 'The disable must clear the seeding error text');
    end;

    [Test]
    procedure GivenAStoreAppearsBeforeThePageSaves_WhenTheDisableIsPersisted_ThenItIsRolledBack()
    var
        Feature: Record "NPR Feature";
        JobQueueEntry: Record "Job Queue Entry";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] The page validates the untick on one round trip and saves it on a later one; an environment that stops being pristine in between must not lose its detection.
        Initialize();
        // [GIVEN] A pristine adoption with its detection job.
        SpfyRowVersionFeature.SetFeatureEnabled(true);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'The adoption must leave one detection job for the disable to threaten');
        Commit();

        // [WHEN] An admin unticks the feature, and a store appears before the page persists the change.
        OpenRowVersionFeature(FeatureMgmt);
        FeatureMgmt.Enabled.SetValue(false);
        _Lib.CreateStore(true, false, false, false, false);
        asserterror FeatureMgmt.Close();

        // [THEN] The save is refused, so the whole disable rolls back rather than stranding that store.
        _Assert.ExpectedError('can no longer be disabled');
        Feature.Get(_Lib.FeatureId());
        _Assert.IsTrue(Feature.Enabled, 'The refused save must leave the feature enabled');
        _Assert.AreEqual(1, JobQueueEntry.Count(), 'The refused save must leave the detection job in place');
        ShopifySetup.Get();
        _Assert.IsTrue(
            ShopifySetup."RowVersion Migration Status" = ShopifySetup."RowVersion Migration Status"::Completed,
            StrSubstNo('The refused save must leave the migration stamp intact, actual status %1', ShopifySetup."RowVersion Migration Status"));
    end;

    [Test]
    procedure GivenTaskListAdopted_WhenTheFeatureIsDisabledFromThePage_ThenItIsRefused()
    var
        Feature: Record "NPR Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] The Shopify task list is layered on RowVersion detection, so an environment that adopted it can no longer step back off RowVersion.
        Initialize();
        // [GIVEN] An otherwise pristine environment that has also adopted the task list.
        _Lib.SetFeatureEnabled(true);
        _Lib.SetTaskListFeatureEnabled(true);
        Commit();

        // [WHEN] An admin tries to untick RowVersion. [THEN] the disable is refused.
        OpenRowVersionFeature(FeatureMgmt);
        asserterror FeatureMgmt.Enabled.SetValue(false);
        _Assert.ExpectedError('can no longer be disabled');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsTrue(Feature.Enabled, 'The refused disable must leave the feature enabled');
    end;

    [Test]
    procedure GivenDisabledStoreWithAreas_WhenTheFeatureIsDisabledFromThePage_ThenItIsRefused()
    var
        Feature: Record "NPR Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A disabled store keeps its integration area flags, and re-enabling it never replays the area setup - so a store row at all closes the disable.
        Initialize();
        // [GIVEN] An otherwise pristine environment with one disabled store that still carries the Items area.
        _Lib.SetFeatureEnabled(true);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.DisableStore(StoreCode);
        Commit();

        // [WHEN] An admin tries to untick RowVersion. [THEN] the disable is refused.
        OpenRowVersionFeature(FeatureMgmt);
        asserterror FeatureMgmt.Enabled.SetValue(false);
        _Assert.ExpectedError('can no longer be disabled');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsTrue(Feature.Enabled, 'The refused disable must leave the feature enabled');
    end;

    [Test]
    procedure GivenShopifyFeatureOff_WhenTheFeatureIsEnabledFromThePage_ThenItIsRefused()
    var
        Feature: Record "NPR Feature";
        FeatureMgmt: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] RowVersion detection is a Shopify feature: it cannot be switched on before the Shopify integration itself is, which is what created the unrecoverable state this guard closes.
        Initialize();
        // [GIVEN] A pristine environment with no Data Log wiring and the Shopify Integration feature off.
        SetShopifyIntegrationFeatureEnabled(false);
        Commit();

        // [WHEN] An admin ticks RowVersion on the page. [THEN] the enable is refused.
        OpenRowVersionFeature(FeatureMgmt);
        asserterror FeatureMgmt.Enabled.SetValue(true);
        _Assert.ExpectedError('before enabling');
        FeatureMgmt.Close();
        Feature.Get(_Lib.FeatureId());
        _Assert.IsFalse(Feature.Enabled, 'The refused enable must leave the feature disabled');
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
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
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
        _Assert.IsTrue(SpfyIntegrationMgt.RunsShopifyOnDataLog(), 'The migration must start from a Data Log driven integration');
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
        _Assert.IsFalse(SpfyIntegrationMgt.RunsShopifyOnDataLog(), 'The cutover must tear down the Shopify Data Log setup');
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

    // Mirrors OpenTaskListFeature in the task list suite: every page-driven test opens the same filtered row.
    local procedure OpenRowVersionFeature(var FeatureMgmt: TestPage "NPR Feature Management")
    begin
        FeatureMgmt.OpenEdit();
        FeatureMgmt.Filter.SetFilter(Id, _Lib.FeatureId());
    end;

    local procedure DeleteAllShopifyStores()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Trigger-free: the OnDelete side effects are not what these tests are about, and the disable guard only reads the rows.
        if not ShopifyStore.IsEmpty() then
            ShopifyStore.DeleteAll(false);
    end;

    local procedure SetShopifyIntegrationFeatureEnabled(Enabled: Boolean)
    var
        Feature: Record "NPR Feature";
        ShopifyFeatureIdTok: Label 'Shopify', Locked = true;
    begin
        if not Feature.Get(ShopifyFeatureIdTok) then begin
            Feature.Init();
            Feature.Id := CopyStr(ShopifyFeatureIdTok, 1, MaxStrLen(Feature.Id));
            Feature.Enabled := Enabled;
            Feature.Insert(false);
            exit;
        end;
        if Feature.Enabled = Enabled then
            exit;
        Feature.Enabled := Enabled;
        Feature.Modify(false);
    end;

    // The cheapest artifact that proves the environment has already run on RowVersion: one sync baseline.
    local procedure InsertSyncStateRow()
    var
        SpfySyncState: Record "NPR Spfy Sync State";
    begin
        SpfySyncState.Init();
        SpfySyncState."Table No." := Database::Item;
        SpfySyncState."Entity System Id" := CreateGuid();
        SpfySyncState."Shopify Store Code" := '';
        SpfySyncState.Insert(false);
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
