#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85468 "NPR Spfy Order Import JQ Tests"
{
    // [FEATURE] Shopify ecommerce order experience (CORE-2178): the OrderImport AND EventDocProcessor job
    //           queue lifecycles - creating and tearing the recurring importer/processor down with the
    //           sales-order-integration (and sales-return-order-integration) master switch AND the feature
    //           flag, registering as a monitored (not NP-protected) job, the refresher gate, the recreation
    //           of a deleted entry, store deletion edge cases, and what the Configure action reports to the
    //           admin.
    //
    // This codeunit is the merger of the previous OrderImport and EventDocProcessor JQ suites. Test cases
    // originally in the OrderImport suite carry the "OrderImport_" prefix; the EventDocProcessor ones carry
    // "EventDocProcessor_". A third group with the "Returns_" prefix covers the sales-return-order union
    // added on top of the CORE-2178 order flow.
    //
    // InitializeJQ() normalises state at the START of every test: TestIsolation = Codeunit rolls back at the
    // end of the codeunit, not between tests, so every write - committed or not - reaches every later test.
    //
    // Tests here must not Commit() unless they restore their own fixture first, otherwise a subsequent
    // TaskScheduler.CreateTask (which is transactional) would outlive the boundary rollback and hand the
    // platform scheduler the importer. The Refresher_MissingEntry tests demonstrate that pattern.

    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        _Assert: Codeunit Assert;
        _LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
        _SavedSetupExisted: Boolean;
        _SavedFeatureExisted: Boolean;
        _SavedStoreExisted: Boolean;
        _SavedSecondStoreExisted: Boolean;
        _SavedIntegrationEnabled: Boolean;
        _SavedFeatureEnabled: Boolean;
        _SavedStoreEnabled: Boolean;
        _SavedStoreSalesOrderIntegration: Boolean;
        _SavedStoreSalesReturnIntegration: Boolean;
        _SavedStoreUrl: Text[250];
        _SavedSecondStoreEnabled: Boolean;
        _SavedSecondStoreSalesOrderIntegration: Boolean;
        _SavedSecondStoreSalesReturnIntegration: Boolean;
        _SavedSecondStoreUrl: Text[250];
        _MessageCount: Integer;
        _LastMessage: Text;
        _JQStoreCodeLbl: Label 'NPRSPFY-JQTEST', Locked = true;
        _JQSecondStoreCodeLbl: Label 'NPRSPFY-JQTEST2', Locked = true;

    #region [OrderImport - Enable]

    [Test]
    procedure OrderImport_Enable_CreatesNonProtectedMonitoredAndManagedJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] With the feature on, integration on, and one store with Sales Order Integration enabled,
        //            configuring the OrderImport job queue must produce an app-managed, monitored,
        //            NON-protected entry - a protected entry is invisible to the refresher.
        InitializeJQ();

        // [Given] Feature and integration on, one store imports sales orders
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The OrderImport job queue is configured through the production entry point
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        // [Then] Exactly one JQ, not NP-protected, monitored and app-managed
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one Shopify OrderImport job queue entry after enabling.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify OrderImport job queue entry.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'The Shopify OrderImport job must not be NP protected - a protected job is never added to the monitored list, so the refresher cannot heal it.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected a monitored job queue entry for the Shopify OrderImport job.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected the monitored row to be findable.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the live job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected a Managed-By-App row for the Shopify OrderImport job.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'Expected the Managed-By-App row to be flagged Managed by App.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_Enable_EntryLeftOnHold_JobStatusIsOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] The hold subscriber stamps Manually Set On Hold and the entry ends up On Hold, so
        //            the platform scheduler never receives it.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify OrderImport job queue entry.');
        _Assert.AreEqual(JobQueueEntry.Status::"On Hold", JobQueueEntry.Status, 'The hold subscriber must leave the JQ On Hold - otherwise a platform task would be scheduled.');
        _Assert.IsTrue(JobQueueEntry."NPR Manually Set On Hold", 'Expected Manually Set On Hold to be stamped by the hold subscriber.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_Enable_ExistingLegacyProtectedEntry_UpdatedInPlaceAndNotProtected()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SeededId: Guid;
    begin
        // [Scenario] A pre-CORE-2178 NP-protected entry is reused and actively de-protected on the update
        //            path of InitRecurringJobQueueEntry, not duplicated.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(SpfyOrderImportJQ.CurrCodeunitId(), SeededJobQueueEntry);
        SeededId := SeededJobQueueEntry.ID;
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the seeded protected entry must start with no monitored row.');

        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the existing entry to be updated in place rather than a second one created.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify OrderImport job queue entry.');
        _Assert.AreEqual(SeededId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'Expected the NP protected flag to be written to false on the existing entry.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected the converted entry to gain a monitored job queue entry.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the converted job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected the converted entry to gain a Managed-By-App row.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_Enable_AfterJobQueueEntryDeleted_LeavesExactlyOneMonitoredRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Re-running setup after a support-deleted JQ must not stack a second monitored row on
        //            top of the orphan - the orphaned monitored row must be purged first.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one monitored row - the orphaned row must be purged rather than duplicated.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), RecreatedJobQueueEntry);
        _Assert.IsTrue(RecreatedJobQueueEntry.FindFirst(), 'Expected the job queue entry to be recreated.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored row after reconfiguring.');
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must point at the live job queue entry, not the deleted GUID.');

        RestoreJQConfig();
    end;

    #endregion

    #region [OrderImport - Disable]

    [Test]
    procedure OrderImport_Disable_RemovesMonitoredAndManagedRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        EnabledJobQueueEntryId: Guid;
    begin
        // [Scenario] Switching Sales Order Integration off must retract the whole registration.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        EnabledJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: a monitored row should exist after enabling.');

        SetJQStore(true, false);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no monitored row once no store has the sales order integration enabled.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled once the master switch went off.');
        _Assert.IsFalse(ManagedByApp.Get(EnabledJobQueueEntryId), 'Expected the Managed-By-App row to be gone once the job was cancelled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_Disable_AfterJobQueueEntryDeleted_LeavesNoMonitoredRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] The resurrection hole. If support deletes the JQ first and the master switch is turned
        //            off second, the orphaned monitored row must not survive - otherwise the refresher would
        //            resurrect the job for a switched-off integration.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        SetJQStore(true, false);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the orphaned monitored row to be purged on disable.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no OrderImport JQ entry to exist after disabling.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_DeleteLastStore_RemovesJobQueueEntryAndMonitoredRow()
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Deleting the last store that imports sales orders tears the job down through OnDelete.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist before deleting the store.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: a monitored row should exist before deleting the store.');

        _Assert.IsTrue(SpfyStore.Get(_JQStoreCodeLbl), 'Precondition: the test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled when the last store importing sales orders was deleted.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no monitored row to survive deletion of the last store importing sales orders.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_DeleteStore_AnotherStoreStillHasOrderIntegration_KeepsJobQueueEntryAndMonitoredRow()
    var
        SpfyStore: Record "NPR Spfy Store";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SurvivingJobQueueEntryId: Guid;
    begin
        // [Scenario] Deleting one of two stores that import sales orders leaves the job running for the survivor.
        //            SetupJobQueuesOnStoreDeletion must exclude only the row being deleted (by SystemId).
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the JQ entry should exist before deleting a store.');
        SurvivingJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: exactly one monitored row should exist before deleting a store.');

        _Assert.IsTrue(SpfyStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the JQ entry to survive while another store still imports sales orders.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to still find the Shopify OrderImport job queue entry.');
        _Assert.AreEqual(SurvivingJobQueueEntryId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one monitored row to survive deletion of a non-last importing store.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored row for the surviving job.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must still point at the live job queue entry.');

        RestoreJQConfig();
    end;

    #endregion

    #region [OrderImport - Refresher gate]

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_AreaEnabled_SkipsValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] With the feature on, integration on, and a store importing sales orders, the refresher
        //            must be allowed to recreate a missing OrderImport entry.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify OrderImport job must be recreatable while a store has Sales Order Integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_AreaDisabled_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Feature and integration on but no store has Sales Order Integration - the subscriber
        //            must stay out.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify OrderImport job must not be recreated while no store has Sales Order Integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_FeatureDisabled_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] With the feature switched off, the subscriber must exit early - a Shopify-specific gate.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify OrderImport job must not be recreated while the ecommerce feature is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_OtherCodeunit_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [Scenario] The subscriber is global - its object id guard has to hold.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(Codeunit::"NPR Job Queue Management", JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must only answer for its own job queue entry, not for any other codeunit.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_SameIdOtherObjectType_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Object ids are only unique per object type, so an object-type guard is required.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildReportJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must only answer for a Codeunit job, not for a report that happens to share its object id.');

        RestoreJQConfig();
    end;

    [Test]
    procedure OrderImport_CreateMissingCustomJQs_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] The subscriber must invalidate the cached setup before reading the master switch.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        SetJQStore(true, true);
        // Prime the cache with integration OFF via the production entry point (RunOrderImportSetupJobQueues
        // reaches SpfyIntegrationMgt and caches through GetRecordOnce).
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();

        // Flip integration back on the way a cross-session write would - cache left stale.
        _LibrarySpfyJQ.SetEnableIntegrationLeavingCacheStale(true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must invalidate the cached setup before reading the master switch, otherwise a stale session cache stops a deleted job from ever being recreated.');

        RestoreJQConfig();
    end;

    #endregion

    #region [OrderImport - Refresher recreation]

    [Test]
    procedure OrderImport_Refresher_MissingEntry_ProductionSubscriberRecreatesEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        MonitoredSnapshot: Record "NPR Monitored Job Queue Entry";
        RecreatedSnapshot: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        DeletedJobQueueEntryId: Guid;
        ImportJobCount: Integer;
        RecreatedEntryFound: Boolean;
        RecreatedIsAppManaged: Boolean;
    begin
        // [Scenario] The refresher recreates a deleted OrderImport entry, authorised by the production subscriber.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        DeletedJobQueueEntryId := JobQueueEntry.ID;

        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: the monitored row should outlive the deleted job queue entry.');
        Commit();

        // [When] The refresher runs - the bound subscriber only holds the recreated entry.
        BindSubscription(LibrarySpfyJQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(LibrarySpfyJQHold);
            RestoreJQConfig();
            Commit();
            Error('The refresher should recreate the missing Shopify OrderImport entry through the production opt-in subscriber. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] Snapshot the outcome BEFORE restoring: an assertion failing before RestoreJQConfig would
        //        leave this test's fixture standing.
        MonitoredJQEntry.Find();
        MonitoredSnapshot := MonitoredJQEntry;
        ImportJobCount := _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId());
        RecreatedEntryFound := RecreatedJobQueueEntry.Get(MonitoredSnapshot."Job Queue Entry ID");
        if RecreatedEntryFound then begin
            RecreatedSnapshot := RecreatedJobQueueEntry;
            if ManagedByApp.Get(MonitoredSnapshot."Job Queue Entry ID") then
                RecreatedIsAppManaged := ManagedByApp."Managed by App";
        end;

        RestoreJQConfig();
        Commit();

        MonitoredSnapshot.TestField("Last Refresh Status", MonitoredSnapshot."Last Refresh Status"::Success);
        _Assert.IsFalse(IsNullGuid(MonitoredSnapshot."Job Queue Entry ID"), 'Expected the monitored row to reference the recreated job queue entry.');
        _Assert.AreNotEqual(DeletedJobQueueEntryId, MonitoredSnapshot."Job Queue Entry ID", 'Expected the recreated entry to carry a new ID, not the deleted one.');
        _Assert.IsTrue(RecreatedEntryFound, 'Expected the recreated job queue entry to be persisted.');
        _Assert.AreEqual(1, ImportJobCount, 'Expected exactly one OrderImport entry after the refresh.');
        _Assert.AreEqual(SpfyOrderImportJQ.CurrCodeunitId(), RecreatedSnapshot."Object ID to Run", 'The monitored row must point at the Shopify OrderImport codeunit.');
        _Assert.IsTrue(RecreatedSnapshot."Recurring Job", 'The recreated entry must still be a recurring job.');
        _Assert.IsTrue(RecreatedIsAppManaged, 'Expected the recreated entry to be flagged Managed by App again.');
        _Assert.IsFalse(RecreatedSnapshot."NPR NP Protected Job", 'The recreated entry must not be NP protected - that is what keeps it monitored and healable.');
        _Assert.IsTrue(RecreatedSnapshot."NPR Manually Set On Hold", 'Precondition of this test: the hold subscriber must have stamped the recreated entry Manually Set On Hold.');
    end;

    #endregion

    #region [OrderImport - Store deletion edge cases]

    [Test]
    procedure OrderImport_DeleteStore_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] SetupJobQueuesOnStoreDeletion reads the master switch through the SingleInstance cache
        //            and must invalidate it first, otherwise a stale cache from an earlier admin action leaves
        //            the job in place for a switched-off integration.
        InitializeJQ();

        // Two importing stores, so the store being deleted is NOT the last one.
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _Assert.IsTrue(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders"), 'Precondition: reading the master switch should populate the session cache while it is on.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist before deleting the store.');

        // Integration switched off cross-session - cache stale.
        _LibrarySpfyJQ.SetEnableIntegrationLeavingCacheStale(false);

        _Assert.IsTrue(SpfyStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OnDelete teardown to re-read the setup, otherwise a stale session cache leaves a monitored job behind for a switched-off integration.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no monitored row to survive the teardown.');

        RestoreJQConfig();
    end;

    #endregion

    #region [OrderImport - Feature disable]

    [Test]
    procedure OrderImport_FeatureDisabled_RemovesMonitoredAndJobQueueRows_NoRefresherError()
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [Scenario] Switching the feature OFF must tear down both the JQ entry and the monitored row, so the
        //            refresher does not error on the next cycle. Exercises the disable branch of
        //            SetupJobQueue via the fixture, matching what SpfyEcommerceOrderExp.HandleJobQueues does
        //            when the feature Validate branch runs.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist after enabling.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: a monitored row should exist after enabling.');

        // [When] The feature is switched off - drives SetupJobQueue(false) directly via the library helper
        //        (equivalent to HandleJobQueues' disable branch).
        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.RunSetupJobQueue(SpfyOrderImportJQ.CurrCodeunitId(), false);

        // [Then] Both the JQ entry and the monitored row are gone.
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled when the feature is disabled.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the monitored row to be purged when the feature is disabled - otherwise the refresher errors on every cycle.');

        // [Then] Running the refresher over the remaining monitored set does not error. Like the production
        //        refresher loop, only rows that still exist are refreshed - the purged row is not passed in.
        //        Run is called without using its return value: that form is prohibited inside the open write
        //        transaction, and a refresher error must fail this test anyway.
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        BindSubscription(LibrarySpfyJQHold);
        if MonitoredJQEntry.FindSet() then
            repeat
                RefreshJobQueueEntry.Run(MonitoredJQEntry);
            until MonitoredJQEntry.Next() = 0;
        UnbindSubscription(LibrarySpfyJQHold);

        RestoreJQConfig();
    end;

    #endregion

    #region [OrderImport - Configure action]

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure OrderImport_Configure_FeatureDisabled_ShowsFeatureDisabledMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Configure action reports the feature-disabled outcome when the feature is off.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyOrderImportJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'feature is disabled') > 0,
            StrSubstNo('The feature-disabled outcome must name the feature; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no JQ entry while the feature is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure OrderImport_Configure_IntegrationDisabled_ShowsIntegrationDisabledMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Configure action reports the integration-disabled outcome when feature is on but
        //            integration is off.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(false);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyOrderImportJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'Enable Shopify integration') > 0,
            StrSubstNo('The integration-disabled outcome must ask the admin to enable integration; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no JQ entry while integration is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure OrderImport_Configure_NoEligibleStore_ShowsNoStoreMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Feature + integration on but no store with Sales Order Integration - Configure reports
        //            the no-eligible-store outcome and does not create a JQ.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyOrderImportJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'Sales Order Integration') > 0,
            StrSubstNo('The no-eligible-store outcome must mention Sales Order Integration; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no JQ entry while no store has Sales Order Integration.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure OrderImport_Configure_JobOnHold_ShowsOnHoldMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [Scenario] Full setup with the hold subscribers bound - the JQ ends up On Hold and Configure
        //            reports the on-hold outcome.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        BindSubscription(LibrarySpfyJQHold);
        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyOrderImportJQ.CurrCodeunitId());
        UnbindSubscription(LibrarySpfyJQHold);

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'on hold') > 0,
            StrSubstNo('The on-hold outcome must say so; got: %1', _LastMessage));
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the JQ entry to be created.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure OrderImport_Configure_IntegrationDisabled_RemovesExistingJobAndMonitoredRow()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] Configure follows the master switch: with an existing JQ entry and monitored row, running it
        //            while the integration is off tears both down instead of only reporting the precondition.
        InitializeJQ();

        // [Given] A configured, monitored OrderImport JQ
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist after enabling.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: a monitored row should exist after enabling.');

        // [When] The integration is switched off and Configure runs
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _MessageCount := 0;
        _LastMessage := '';
        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyOrderImportJQ.CurrCodeunitId());

        // [Then] The integration-disabled outcome is reported and both rows are gone
        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'Enable Shopify integration') > 0,
            StrSubstNo('The integration-disabled outcome must ask the admin to enable integration; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected Configure to remove the JQ entry while integration is switched off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected Configure to remove the monitored row while integration is switched off.');

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Enable]

    [Test]
    procedure EventDocProcessor_Enable_CreatesNonProtectedMonitoredAndManagedJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] With the feature on, integration on, and one store with Sales Order Integration enabled,
        //            configuring the EventDocProcessor job queue must produce an app-managed, monitored,
        //            NON-protected entry - a protected entry is invisible to the refresher.
        InitializeJQ();

        // [Given] Feature and integration on, one store imports sales orders
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The EventDocProcessor job queue is configured through the production entry point
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        // [Then] Exactly one JQ, not NP-protected, monitored and app-managed
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected exactly one Shopify EventDocProcessor job queue entry after enabling.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify EventDocProcessor job queue entry.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'The Shopify EventDocProcessor job must not be NP protected - a protected job is never added to the monitored list, so the refresher cannot heal it.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected a monitored job queue entry for the Shopify EventDocProcessor job.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected the monitored row to be findable.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the live job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected a Managed-By-App row for the Shopify EventDocProcessor job.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'Expected the Managed-By-App row to be flagged Managed by App.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_Enable_EntryLeftOnHold_JobStatusIsOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] The hold subscriber stamps Manually Set On Hold and the entry ends up On Hold, so
        //            the platform scheduler never receives it.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify EventDocProcessor job queue entry.');
        _Assert.AreEqual(JobQueueEntry.Status::"On Hold", JobQueueEntry.Status, 'The hold subscriber must leave the JQ On Hold - otherwise a platform task would be scheduled.');
        _Assert.IsTrue(JobQueueEntry."NPR Manually Set On Hold", 'Expected Manually Set On Hold to be stamped by the hold subscriber.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_Enable_ExistingLegacyProtectedEntry_UpdatedInPlaceAndNotProtected()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        SeededId: Guid;
    begin
        // [Scenario] A pre-CORE-2178 NP-protected entry is reused and actively de-protected on the update
        //            path of InitRecurringJobQueueEntry, not duplicated.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(SpfyEventDocProcessorJQ.CurrCodeunitId(), SeededJobQueueEntry);
        SeededId := SeededJobQueueEntry.ID;
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the seeded protected entry must start with no monitored row.');

        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the existing entry to be updated in place rather than a second one created.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the Shopify EventDocProcessor job queue entry.');
        _Assert.AreEqual(SeededId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'Expected the NP protected flag to be written to false on the existing entry.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected the converted entry to gain a monitored job queue entry.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the converted job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected the converted entry to gain a Managed-By-App row.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_Enable_AfterJobQueueEntryDeleted_LeavesExactlyOneMonitoredRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Re-running setup after a support-deleted JQ must not stack a second monitored row on
        //            top of the orphan - the orphaned monitored row must be purged first.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected exactly one monitored row - the orphaned row must be purged rather than duplicated.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), RecreatedJobQueueEntry);
        _Assert.IsTrue(RecreatedJobQueueEntry.FindFirst(), 'Expected the job queue entry to be recreated.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored row after reconfiguring.');
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must point at the live job queue entry, not the deleted GUID.');

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Disable]

    [Test]
    procedure EventDocProcessor_Disable_RemovesMonitoredAndManagedRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        EnabledJobQueueEntryId: Guid;
    begin
        // [Scenario] Switching Sales Order Integration off must retract the whole registration.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        EnabledJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: a monitored row should exist after enabling.');

        SetJQStore(true, false);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no monitored row once no store has the sales order integration enabled.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled once the master switch went off.');
        _Assert.IsFalse(ManagedByApp.Get(EnabledJobQueueEntryId), 'Expected the Managed-By-App row to be gone once the job was cancelled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_Disable_AfterJobQueueEntryDeleted_LeavesNoMonitoredRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] The resurrection hole. If support deletes the JQ first and the master switch is turned
        //            off second, the orphaned monitored row must not survive - otherwise the refresher would
        //            resurrect the job for a switched-off integration.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        SetJQStore(true, false);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the orphaned monitored row to be purged on disable.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no EventDocProcessor JQ entry to exist after disabling.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_DeleteLastStore_RemovesJobQueueEntryAndMonitoredRow()
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Deleting the last store that imports sales orders tears the job down through OnDelete.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist before deleting the store.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: a monitored row should exist before deleting the store.');

        _Assert.IsTrue(SpfyStore.Get(_JQStoreCodeLbl), 'Precondition: the test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled when the last store importing sales orders was deleted.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no monitored row to survive deletion of the last store importing sales orders.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_DeleteStore_AnotherStoreStillHasOrderIntegration_KeepsJobQueueEntryAndMonitoredRow()
    var
        SpfyStore: Record "NPR Spfy Store";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        SurvivingJobQueueEntryId: Guid;
    begin
        // [Scenario] Deleting one of two stores that import sales orders leaves the job running for the survivor.
        //            SetupJobQueuesOnStoreDeletion must exclude only the row being deleted (by SystemId).
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the JQ entry should exist before deleting a store.');
        SurvivingJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: exactly one monitored row should exist before deleting a store.');

        _Assert.IsTrue(SpfyStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the JQ entry to survive while another store still imports sales orders.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to still find the Shopify EventDocProcessor job queue entry.');
        _Assert.AreEqual(SurvivingJobQueueEntryId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected exactly one monitored row to survive deletion of a non-last importing store.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored row for the surviving job.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must still point at the live job queue entry.');

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Refresher gate]

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_AreaEnabled_SkipsValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] With the feature on, integration on, and a store importing sales orders, the refresher
        //            must be allowed to recreate a missing EventDocProcessor entry.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify EventDocProcessor job must be recreatable while a store has Sales Order Integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_AreaDisabled_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Feature and integration on but no store has Sales Order Integration - the subscriber
        //            must stay out.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify EventDocProcessor job must not be recreated while no store has Sales Order Integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_FeatureDisabled_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] With the feature switched off, the subscriber must exit early - a Shopify-specific gate.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify EventDocProcessor job must not be recreated while the ecommerce feature is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_OtherCodeunit_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [Scenario] The subscriber is global - its object id guard has to hold.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(Codeunit::"NPR Job Queue Management", JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must only answer for its own job queue entry, not for any other codeunit.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_SameIdOtherObjectType_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Object ids are only unique per object type, so an object-type guard is required.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.BuildReportJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must only answer for a Codeunit job, not for a report that happens to share its object id.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_CreateMissingCustomJQs_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] The subscriber must invalidate the cached setup before reading the master switch.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        SetJQStore(true, true);
        // Prime the cache with integration OFF via the production entry point (RunEventDocProcessorSetupJobQueues
        // reaches SpfyIntegrationMgt and caches through GetRecordOnce).
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        // Flip integration back on the way a cross-session write would - cache left stale.
        _LibrarySpfyJQ.SetEnableIntegrationLeavingCacheStale(true);
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);

        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Shopify subscriber must invalidate the cached setup before reading the master switch, otherwise a stale session cache stops a deleted job from ever being recreated.');

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Refresher recreation]

    [Test]
    procedure EventDocProcessor_Refresher_MissingEntry_ProductionSubscriberRecreatesEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        MonitoredSnapshot: Record "NPR Monitored Job Queue Entry";
        RecreatedSnapshot: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        DeletedJobQueueEntryId: Guid;
        ImportJobCount: Integer;
        RecreatedEntryFound: Boolean;
        RecreatedIsAppManaged: Boolean;
    begin
        // [Scenario] The refresher recreates a deleted EventDocProcessor entry, authorised by the production subscriber.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the job queue entry should exist after enabling.');
        DeletedJobQueueEntryId := JobQueueEntry.ID;

        _LibrarySpfyJQ.DeleteJobQueueEntry(JobQueueEntry);
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: the monitored row should outlive the deleted job queue entry.');
        Commit();

        // [When] The refresher runs - the bound subscriber only holds the recreated entry.
        BindSubscription(LibrarySpfyJQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(LibrarySpfyJQHold);
            RestoreJQConfig();
            Commit();
            Error('The refresher should recreate the missing Shopify EventDocProcessor entry through the production opt-in subscriber. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] Snapshot the outcome BEFORE restoring: an assertion failing before RestoreJQConfig would
        //        leave this test's fixture standing.
        MonitoredJQEntry.Find();
        MonitoredSnapshot := MonitoredJQEntry;
        ImportJobCount := _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId());
        RecreatedEntryFound := RecreatedJobQueueEntry.Get(MonitoredSnapshot."Job Queue Entry ID");
        if RecreatedEntryFound then begin
            RecreatedSnapshot := RecreatedJobQueueEntry;
            if ManagedByApp.Get(MonitoredSnapshot."Job Queue Entry ID") then
                RecreatedIsAppManaged := ManagedByApp."Managed by App";
        end;

        RestoreJQConfig();
        Commit();

        MonitoredSnapshot.TestField("Last Refresh Status", MonitoredSnapshot."Last Refresh Status"::Success);
        _Assert.IsFalse(IsNullGuid(MonitoredSnapshot."Job Queue Entry ID"), 'Expected the monitored row to reference the recreated job queue entry.');
        _Assert.AreNotEqual(DeletedJobQueueEntryId, MonitoredSnapshot."Job Queue Entry ID", 'Expected the recreated entry to carry a new ID, not the deleted one.');
        _Assert.IsTrue(RecreatedEntryFound, 'Expected the recreated job queue entry to be persisted.');
        _Assert.AreEqual(1, ImportJobCount, 'Expected exactly one EventDocProcessor entry after the refresh.');
        _Assert.AreEqual(SpfyEventDocProcessorJQ.CurrCodeunitId(), RecreatedSnapshot."Object ID to Run", 'The monitored row must point at the Shopify EventDocProcessor codeunit.');
        _Assert.IsTrue(RecreatedSnapshot."Recurring Job", 'The recreated entry must still be a recurring job.');
        _Assert.IsTrue(RecreatedIsAppManaged, 'Expected the recreated entry to be flagged Managed by App again.');
        _Assert.IsFalse(RecreatedSnapshot."NPR NP Protected Job", 'The recreated entry must not be NP protected - that is what keeps it monitored and healable.');
        _Assert.IsTrue(RecreatedSnapshot."NPR Manually Set On Hold", 'Precondition of this test: the hold subscriber must have stamped the recreated entry Manually Set On Hold.');
    end;

    #endregion

    #region [EventDocProcessor - Store deletion edge cases]

    [Test]
    procedure EventDocProcessor_DeleteStore_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] SetupJobQueuesOnStoreDeletion reads the master switch through the SingleInstance cache
        //            and must invalidate it first, otherwise a stale cache from an earlier admin action leaves
        //            the job in place for a switched-off integration.
        InitializeJQ();

        // Two importing stores, so the store being deleted is NOT the last one.
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.IsTrue(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders"), 'Precondition: reading the master switch should populate the session cache while it is on.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist before deleting the store.');

        // Integration switched off cross-session - cache stale.
        _LibrarySpfyJQ.SetEnableIntegrationLeavingCacheStale(false);

        _Assert.IsTrue(SpfyStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibrarySpfyJQ.DeleteStore(SpfyStore.Code);

        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the OnDelete teardown to re-read the setup, otherwise a stale session cache leaves a monitored job behind for a switched-off integration.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no monitored row to survive the teardown.');

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Feature disable]

    [Test]
    procedure EventDocProcessor_FeatureDisabled_RemovesMonitoredAndJobQueueRows_NoRefresherError()
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [Scenario] Switching the feature OFF must tear down both the JQ entry and the monitored row, so the
        //            refresher does not error on the next cycle. Exercises the disable branch of
        //            SetupJobQueue via the fixture, matching what SpfyEcommerceOrderExp.HandleJobQueues does
        //            when the feature Validate branch runs.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: the JQ entry should exist after enabling.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: a monitored row should exist after enabling.');

        // [When] The feature is switched off - drives SetupJobQueue(false) directly via the library helper
        //        (equivalent to HandleJobQueues' disable branch).
        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.RunSetupJobQueue(SpfyEventDocProcessorJQ.CurrCodeunitId(), false);

        // [Then] Both the JQ entry and the monitored row are gone.
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the JQ entry to be cancelled when the feature is disabled.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the monitored row to be purged when the feature is disabled - otherwise the refresher errors on every cycle.');

        // [Then] Running the refresher over the remaining monitored set does not error. Like the production
        //        refresher loop, only rows that still exist are refreshed - the purged row is not passed in.
        //        Run is called without using its return value: that form is prohibited inside the open write
        //        transaction, and a refresher error must fail this test anyway.
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        BindSubscription(LibrarySpfyJQHold);
        if MonitoredJQEntry.FindSet() then
            repeat
                RefreshJobQueueEntry.Run(MonitoredJQEntry);
            until MonitoredJQEntry.Next() = 0;
        UnbindSubscription(LibrarySpfyJQHold);

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Configure action]

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EventDocProcessor_Configure_FeatureDisabled_ShowsFeatureDisabledMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Configure action reports the feature-disabled outcome when the feature is off.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'feature is disabled') > 0,
            StrSubstNo('The feature-disabled outcome must name the feature; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no JQ entry while the feature is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EventDocProcessor_Configure_IntegrationDisabled_ShowsIntegrationDisabledMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Configure action reports the integration-disabled outcome when feature is on but
        //            integration is off.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(false);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'Enable Shopify integration') > 0,
            StrSubstNo('The integration-disabled outcome must ask the admin to enable integration; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no JQ entry while integration is switched off.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EventDocProcessor_Configure_NoEligibleStore_ShowsNoStoreMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Feature + integration on but no store with Sales Order Integration - Configure reports
        //            the no-eligible-store outcome and does not create a JQ.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _MessageCount := 0;
        _LastMessage := '';

        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'Sales Order Integration') > 0,
            StrSubstNo('The no-eligible-store outcome must mention Sales Order Integration; got: %1', _LastMessage));
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected no JQ entry while no store has Sales Order Integration.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EventDocProcessor_Configure_JobOnHold_ShowsOnHoldMessage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [Scenario] Full setup with the hold subscribers bound - the JQ ends up On Hold and Configure
        //            reports the on-hold outcome.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _MessageCount := 0;
        _LastMessage := '';

        BindSubscription(LibrarySpfyJQHold);
        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());
        UnbindSubscription(LibrarySpfyJQHold);

        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, 'on hold') > 0,
            StrSubstNo('The on-hold outcome must say so; got: %1', _LastMessage));
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the JQ entry to be created.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Returns - Sales-Returns-only tenant enable + refresher gate]

    [Test]
    procedure Returns_EnableReturnsOnly_CreatesBothJQEntries()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] A Sales-Returns-only tenant (Sales Order Integration off, Sales Return Order Integration on)
        //            must still get both the OrderImport and the EventDocProcessor JQs, because the widened
        //            union covers both areas.
        InitializeJQ();

        // [Given] Feature and integration on, one store with returns-only enabled
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, true);

        // [When] Both JQs are configured through their production entry points
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        // [Then] Both codeunits have exactly one JQ entry and one monitored row
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport JQ entry for a Sales-Returns-only tenant.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected a monitored OrderImport row for a Sales-Returns-only tenant.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor JQ entry for a Sales-Returns-only tenant.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected a monitored EventDocProcessor row for a Sales-Returns-only tenant.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Returns_EnableReturnsOnly_RefresherSubscribersSkip()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] Both refresher gates (OrderImport and EventDocProcessor) must recognise a Sales-Returns-only
        //            tenant as first-class and allow the refresher to recreate the missing JQ.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, true);

        // [When/Then] OrderImport gate
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The OrderImport refresher must skip validation for a Sales-Returns-only tenant.');

        // [When/Then] EventDocProcessor gate
        _LibrarySpfyJQ.BuildJobQueueEntryFor(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The EventDocProcessor refresher must skip validation for a Sales-Returns-only tenant.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Returns - EventDocProcessor filter stays Order-only]

    [Test]
    procedure Returns_EventDocProcessor_FilterSkipsReturnDocumentType()
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        InsertedEntryNo: BigInteger;
    begin
        // [SCENARIO] Production ApplyProcessableEventLogFilters must not select a Ready Return-Order log entry:
        //            return order processing is not released yet. Asserting against production (not against a
        //            hand-copied filter) so widening the filter to Return Order fails this test.
        InitializeJQ();
        SetJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, true);

        // [WHEN] a Ready Return-Order entry exists
        InsertedEntryNo := InsertReadyEventLogEntry(_JQStoreCodeLbl, SpfyEventLogEntry."Document Type"::"Return Order");

        // [THEN] production filter skips it (narrowed by primary key to guard against pre-existing tenant rows)
        SpfyEventDocProcessorJQ.ApplyProcessableEventLogFilters(SpfyEventLogEntry, '');
        SpfyEventLogEntry.SetRange("Entry No.", InsertedEntryNo);
        _Assert.IsTrue(SpfyEventLogEntry.IsEmpty(), 'Production filter must not select the Return-Order entry.');

        DeleteEventLogEntry(InsertedEntryNo);
        RestoreJQConfig();
    end;

    [Test]
    procedure Returns_EventDocProcessor_MixedQueueOnlyOrderVisible()
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        OrderEntryNo: BigInteger;
        ReturnEntryNo: BigInteger;
        SelectedCount: Integer;
    begin
        // [SCENARIO] In a mixed Ready queue - one Order, one Return-Order - the production filter selects only the Order.
        InitializeJQ();
        SetJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, true);

        // [WHEN] one Order and one Return-Order entry are Ready in the same bucket
        OrderEntryNo := InsertReadyEventLogEntry(_JQStoreCodeLbl, SpfyEventLogEntry."Document Type"::Order);
        ReturnEntryNo := InsertReadyEventLogEntry(_JQStoreCodeLbl, SpfyEventLogEntry."Document Type"::"Return Order");

        // [THEN] production filter narrows to just those two rows and selects only the Order
        SpfyEventDocProcessorJQ.ApplyProcessableEventLogFilters(SpfyEventLogEntry, '');
        SpfyEventLogEntry.SetFilter("Entry No.", '%1|%2', OrderEntryNo, ReturnEntryNo);
        SelectedCount := SpfyEventLogEntry.Count();
        _Assert.AreEqual(1, SelectedCount, 'Only the Order entry must be selected.');
        _Assert.IsTrue(SpfyEventLogEntry.FindFirst(), 'Expected the Order entry to be selected.');
        _Assert.AreEqual(OrderEntryNo, SpfyEventLogEntry."Entry No.", 'Expected the selected entry to be the Order entry.');

        DeleteEventLogEntry(OrderEntryNo);
        DeleteEventLogEntry(ReturnEntryNo);
        RestoreJQConfig();
    end;

    #endregion

    #region [Returns - Sales-Orders-only tenant unaffected]

    [Test]
    procedure Returns_SalesOrdersOnlyTenant_JQEntriesStillCreated()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] The union must not regress the Sales-Orders-only baseline. A store with orders on and returns
        //            off must still get both JQs set up.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, false);

        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport JQ entry for a Sales-Orders-only tenant to be unchanged by the union.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor JQ entry for a Sales-Orders-only tenant to be unchanged by the union.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Returns - Disable both areas tears down both JQs]

    [Test]
    procedure Returns_DisableAll_TearsDownBothJQEntries()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [Scenario] With both areas enabled on the same store, setup creates both JQ entries. Turning both off and
        //            re-running setup must cancel both JQ entries and purge the monitored rows.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: OrderImport JQ should exist with both areas enabled.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: EventDocProcessor JQ should exist with both areas enabled.');

        // [When] Both areas flipped off on the store and the union-consulting SetupJobQueues runs its disable branch
        SetJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, false);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();

        // [Then] Both JQs and their monitored rows are gone
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport JQ entry to be cancelled when both areas are switched off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport monitored row to be purged when both areas are switched off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor JQ entry to be cancelled when both areas are switched off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor monitored row to be purged when both areas are switched off.');

        RestoreJQConfig();
    end;

    [Test]
    procedure TriggerEntryPoint_LastStoreSwitchedOff_TearsDownBothJQEntries()
    var
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [Scenario] The setup and store field triggers reach the ecommerce JQs through
        //            "NPR Spfy Event Log DocProcessr".SetupJobQueues(). Switching off the last eligible store must
        //            tear both JQs down right there, not only on the next refresher cycle.
        InitializeJQ();

        // [Given] Both JQs configured through the trigger entry point
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        BindSubscription(LibrarySpfyJQHold);
        SpfyEventLogDocProcessr.SetupJobQueues();
        UnbindSubscription(LibrarySpfyJQHold);
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: OrderImport JQ should exist.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: EventDocProcessor JQ should exist.');

        // [When] The only store stops importing sales orders and the trigger entry point runs again
        SetJQStore(true, false);
        BindSubscription(LibrarySpfyJQHold);
        SpfyEventLogDocProcessr.SetupJobQueues();
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] Both JQs and their monitored rows are gone
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport JQ entry to be cancelled when no store is eligible.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the OrderImport monitored row to be purged when no store is eligible.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor JQ entry to be cancelled when no store is eligible.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Expected the EventDocProcessor monitored row to be purged when no store is eligible.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Returns - Store deletion keeps JQs alive on a returns-only survivor]

    [Test]
    procedure Returns_OnStoreDelete_ReturnsOnlyTenant_KeepsBothJQs()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [SCENARIO] SetupJobQueuesOnStoreDeletion must union Sales Orders OR Sales Returns. With a Sales-Orders-only
        //            store AND a Returns-only store enabled, deleting the Sales-Orders one must NOT tear down the
        //            ecom JQs because the Returns-only store is still eligible under the widened gate.
        //            Without the fix, the deletion gate reads only Sales Orders eligibility, sees the surviving
        //            Returns-only store as ineligible, and calls SetupJobQueue(false) on both codeunits.
        InitializeJQ();

        // [Given] Feature + integration + primary Sales-Orders store + second Returns-only store
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, false);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQSecondStoreCodeLbl, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: OrderImport JQ should exist with both stores enabled.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Precondition: EventDocProcessor JQ should exist with both stores enabled.');

        // [When] The Sales-Orders-only store is deleted, leaving only the Returns-only store enabled
        _LibrarySpfyJQ.DeleteStore(_JQStoreCodeLbl);

        // [Then] Both JQ entries and both monitored rows survive because the union gate still sees an eligible store
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Deleting the Sales-Orders store must not tear down the OrderImport JQ while a Returns-only store remains.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Deleting the Sales-Orders store must not tear down the OrderImport monitored row while a Returns-only store remains.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Deleting the Sales-Orders store must not tear down the EventDocProcessor JQ while a Returns-only store remains.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'Deleting the Sales-Orders store must not tear down the EventDocProcessor monitored row while a Returns-only store remains.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Configure - Stale SingleInstance cache reads the current master switch]

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure SpfyJQWithConfirmation_StaleSetupCache_ReadsCurrentMasterSwitch()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
    begin
        // [SCENARIO] SetupSpfyJQWithConfirmation must re-read the SingleInstance Enable-Integration cache before
        //            deciding, so a cross-session enable becomes visible on the very next click.
        //            Without the fix (SetRereadSetup ran AFTER the cached GetRecordOnce read), a second SUT call
        //            still sees the stale false value written by the priming step below.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        SetJQStore(true, true);

        // [Given] Priming: DB = false + cache invalidated; then one SUT call to load false into the SingleInstance cache.
        //         Bracketed with the hold subscribers as a defensive precaution: the SUT only reaches
        //         SetupJobQueue(false) here (Enable = false), but a future refactor of the gate must not silently
        //         push the importer at the platform scheduler from this test.
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _MessageCount := 0;
        _LastMessage := '';
        BindSubscription(LibrarySpfyJQHold);
        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());
        UnbindSubscription(LibrarySpfyJQHold);
        _Assert.IsTrue(StrPos(_LastMessage, 'Enable Shopify integration') > 0, StrSubstNo('Priming step should surface the integration-disabled outcome; got: %1', _LastMessage));

        // [When] DB flipped to true WITHOUT invalidating the cache (simulates a cross-session write)
        _LibrarySpfyJQ.SetEnableIntegrationLeavingCacheStale(true);

        BindSubscription(LibrarySpfyJQHold);
        _MessageCount := 0;
        _LastMessage := '';
        SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(SpfyEventDocProcessorJQ.CurrCodeunitId());
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] SUT re-read the setup and proceeded past the Enable-Integration guard
        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message on the second call.');
        _Assert.IsFalse(StrPos(_LastMessage, 'Enable Shopify integration first') > 0, StrSubstNo('SUT must not repeat the integration-disabled message after a cross-session enable; got: %1', _LastMessage));

        RestoreJQConfig();
    end;

    #endregion

    #region [Configure - Unknown codeunit id raises a programming bug]

    [Test]
    procedure SpfyJQWithConfirmation_UnknownCodeunitId_RaisesProgrammingBug()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        // [SCENARIO] The case in SetupSpfyJQWithConfirmation must reject an unknown JQ codeunit id with a
        //            programming-bug error, not silently emit a success-shaped on-hold message with a blank
        //            job-name substitution.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        asserterror SpfyIntegrationMgt.SetupSpfyJQWithConfirmation(-1);
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'This is a programming bug') > 0, StrSubstNo('Expected a programming-bug error for an unknown JQ codeunit id; got: %1', GetLastErrorText()));

        RestoreJQConfig();
    end;

    #endregion

    #region [EventDocProcessor - Reuse existing parameter string, do not duplicate]

    [Test]
    procedure EventDocProcessor_ManualEntryWithLegacyParamString_NotDuplicated()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        // [SCENARIO] Two variants of an existing entry - one with Parameter String = 'bucket id' (the value the
        //            OnValidate subscriber writes when an admin creates the JQ manually) and one with the canonical
        //            'bucket id=1..100' (produced by CreateParameterString) - must be updated in place, not
        //            duplicated, when SetupJobQueue runs.
        //            Without the fix, InitRecurringJobQueueEntry filters "Parameter String" exactly, misses the
        //            'bucket id' row, and inserts a second entry that clears its bucket filter and processes all
        //            buckets.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [Given] Pre-seed one entry with the legacy 'bucket id' Parameter String (bypasses InitRecurringJobQueueEntry)
        Clear(JobQueueEntry);
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := SpfyEventDocProcessorJQ.CurrCodeunitId();
        JobQueueEntry."Parameter String" := 'bucket id';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);

        // [When] SetupJobQueue is run for the doc-processor
        _LibrarySpfyJQ.RunSetupJobQueue(SpfyEventDocProcessorJQ.CurrCodeunitId(), true);

        // [Then] The pre-seeded row was updated in place, not duplicated
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'The legacy-Parameter-String entry must be updated in place, not duplicated.');

        // Companion: sharded deployment scenario - Parameter String = 'bucket id=51..100' (a shard other than
        // the CreateParameterString default). Without the fix, InitRecurringJobQueueEntry filters "Parameter String"
        // exactly, misses the shard, and inserts a duplicate with 'bucket id=1..100'. With the fix,
        // TryGetExistingBucketParameterString reuses the sharded value and the entry is updated in place.
        _LibrarySpfyJQ.ClearJobQueueState(SpfyEventDocProcessorJQ.CurrCodeunitId());
        Clear(JobQueueEntry);
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := SpfyEventDocProcessorJQ.CurrCodeunitId();
        JobQueueEntry."Parameter String" := 'bucket id=51..100';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);

        _LibrarySpfyJQ.RunSetupJobQueue(SpfyEventDocProcessorJQ.CurrCodeunitId(), true);

        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'The sharded Parameter String entry must be updated in place, not duplicated by a CreateParameterString default.');

        RestoreJQConfig();
    end;

    [Test]
    procedure EventDocProcessor_ManualEntryWithoutBucketParamString_NotDuplicated()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        SeededId: Guid;
    begin
        // [SCENARIO] An existing entry whose Parameter String is not blank and carries no 'bucket id' (edited by an
        //            admin, or imported through a configuration package that skips the Object ID to Run
        //            validation) must be updated in place with its own Parameter String, not duplicated by an
        //            entry with the CreateParameterString default.
        InitializeJQ();

        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [Given] Pre-seed one entry with a Parameter String that has no bucket filter
        Clear(JobQueueEntry);
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := SpfyEventDocProcessorJQ.CurrCodeunitId();
        JobQueueEntry."Parameter String" := 'custom';
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);
        SeededId := JobQueueEntry.ID;

        // [When] SetupJobQueue is run for the doc-processor
        _LibrarySpfyJQ.RunSetupJobQueue(SpfyEventDocProcessorJQ.CurrCodeunitId(), true);

        // [Then] The pre-seeded row was updated in place, keeping its Parameter String
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId()), 'The entry without a bucket filter must be updated in place, not duplicated.');
        _Assert.IsTrue(JobQueueEntry.Get(SeededId), 'Expected the pre-seeded job queue entry to survive, identified by its original ID.');
        _Assert.AreEqual('custom', JobQueueEntry."Parameter String", 'Expected the pre-seeded Parameter String to be kept.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Upgrade - ConvertEcomJQs]

    [Test]
    procedure Upgrade_ConvertsLegacyProtectedOrderImportEntry_ToMonitoredNonProtected()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SeededId: Guid;
    begin
        // [Scenario] The upgrade step converts a legacy NP-protected OrderImport entry to a
        //            non-protected, monitored, app-managed row without changing its ID.
        InitializeJQ();

        // [Given] Feature on and a pre-CORE-2178 NP-protected entry seeded
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(SpfyOrderImportJQ.CurrCodeunitId(), SeededJobQueueEntry);
        SeededId := SeededJobQueueEntry.ID;
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the seeded protected entry must start with no monitored row.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountManagedByAppEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: the seeded protected entry must start with no managed-by-app row.');
        _Assert.IsTrue(SeededJobQueueEntry."NPR NP Protected Job", 'Precondition: the seeded entry must start NP protected.');

        // [When] The upgrade step runs through the bracket helper
        _LibrarySpfyJQ.RunUpgradeStep_ConvertLegacyProtected();

        // [Then] Same entry (same ID), no longer NP protected, one monitored + one managed-by-app row
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the seeded OrderImport JQ entry to survive the upgrade step - the step does not insert JQ rows, only flips the NP-protected flag and adds monitored + managed-by-app rows.');
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Expected to find the converted OrderImport JQ entry.');
        _Assert.AreEqual(SeededId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive under its original ID.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'Expected the NP protected flag to be flipped to false by the upgrade step.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one monitored row for the converted OrderImport entry.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountManagedByAppEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one managed-by-app row flagged Managed by App for the converted OrderImport entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected a Managed-By-App row for the converted OrderImport entry.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'Expected the Managed-By-App row to be flagged Managed by App.');
        // [Then] A manually held entry stays On Hold and manually held
        _Assert.IsTrue(JobQueueEntry.Get(SeededId), 'Expected to re-read the converted OrderImport JQ entry by its original ID.');
        _Assert.AreEqual(JobQueueEntry.Status::"On Hold", JobQueueEntry.Status, 'Expected the manually held OrderImport JQ entry to stay On Hold after the upgrade step.');
        _Assert.IsTrue(JobQueueEntry."NPR Manually Set On Hold", 'Expected the OrderImport JQ entry to stay "NPR Manually Set On Hold" after the upgrade step.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Upgrade_ConvertLegacyProtected_ReadiesEntryNotManuallyHeld()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] The conversion sets a legacy NP-protected OrderImport entry that is not manually held back to
        //            Ready, and the entry gets no platform task while the test library bracket is bound.
        InitializeJQ();

        // [Given] Feature on and a pre-CORE-2178 NP-protected entry seeded Ready and not manually held
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.CreateLegacyProtectedJobNotManuallyHeld(SpfyOrderImportJQ.CurrCodeunitId(), SeededJobQueueEntry);

        // [When] The conversion runs
        _LibrarySpfyJQ.RunUpgradeStep_ConvertLegacyProtected();

        // [Then] The entry is Ready, no longer NP protected, has no platform task and is not manually held
        _Assert.IsTrue(JobQueueEntry.Get(SeededJobQueueEntry.ID), 'Expected the seeded OrderImport JQ entry to still exist under its original ID.');
        _Assert.AreEqual(JobQueueEntry.Status::Ready, JobQueueEntry.Status, 'Expected the conversion to leave the OrderImport JQ entry Ready.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'Expected the NP protected flag to be flipped to false by the upgrade step.');
        _Assert.IsTrue(IsNullGuid(JobQueueEntry."System Task ID"), 'Expected no platform task for the OrderImport JQ entry while the scheduling subscriber is bound.');
        _Assert.IsFalse(JobQueueEntry."NPR Manually Set On Hold", 'Expected the OrderImport JQ entry not to be "NPR Manually Set On Hold".');

        RestoreJQConfig();
    end;

    [Test]
    procedure Upgrade_ConvertLegacyProtected_SkippedWhenFeatureDisabled()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] With the ecom feature off, the conversion leaves a legacy NP-protected OrderImport entry as it is.
        InitializeJQ();

        // [Given] Feature off and a pre-CORE-2178 NP-protected entry seeded
        _LibrarySpfyJQ.SetFeatureEnabled(false);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(SpfyOrderImportJQ.CurrCodeunitId(), SeededJobQueueEntry);

        // [When] The conversion runs
        _LibrarySpfyJQ.RunUpgradeStep_ConvertLegacyProtected();

        // [Then] The entry is still NP protected, with no monitored or Managed By App row
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the seeded OrderImport JQ entry to be the only one when the feature is off.');
        _Assert.IsTrue(JobQueueEntry.Get(SeededJobQueueEntry.ID), 'Expected the seeded OrderImport JQ entry to still exist when the feature is off.');
        _Assert.IsTrue(JobQueueEntry."NPR NP Protected Job", 'Expected the OrderImport JQ entry to stay NP protected when the feature is off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no OrderImport monitored row when the feature is off.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountManagedByAppEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected no OrderImport Managed By App row when the feature is off.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Upgrade_ConvertLegacyProtected_ClearsFlagOnMonitoredRowWithoutJob()
    var
        SeededMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] An NP-protected monitored row whose job queue entry no longer exists loses the protected flag,
        //            so the refresher can recreate the job as a non-protected one.
        InitializeJQ();

        // [Given] Feature on and an NP-protected OrderImport monitored row that points to no job queue entry
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.CreateProtectedMonitoredRow(SpfyOrderImportJQ.CurrCodeunitId(), SeededMonitoredJQEntry);
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Precondition: no OrderImport JQ entry may exist.');

        // [When] The conversion runs
        _LibrarySpfyJQ.RunUpgradeStep_ConvertLegacyProtected();

        // [Then] The row still exists and is no longer NP protected, and no JQ entry was created
        _Assert.IsTrue(MonitoredJQEntry.Get(SeededMonitoredJQEntry."Entry No."), 'Expected the seeded OrderImport monitored row to still exist.');
        _Assert.IsFalse(MonitoredJQEntry."NP Protected Job", 'Expected the conversion to clear "NP Protected Job" on a monitored row without a job queue entry.');
        _Assert.AreEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected the conversion not to create an OrderImport JQ entry.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Upgrade_ConvertLegacyProtected_SkipsNonRecurringEntry()
    var
        RecurringJobQueueEntry: Record "Job Queue Entry";
        OneOffJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        // [Scenario] The conversion only touches recurring entries. A one-off NP-protected entry for the same
        //            codeunit keeps its flag and gets no monitored or Managed By App row.
        InitializeJQ();

        // [Given] Feature on, a recurring and a one-off NP-protected OrderImport entry
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(SpfyOrderImportJQ.CurrCodeunitId(), RecurringJobQueueEntry);
        _LibrarySpfyJQ.CreateLegacyProtectedOneOffJob(SpfyOrderImportJQ.CurrCodeunitId(), OneOffJobQueueEntry);

        // [When] The conversion runs
        _LibrarySpfyJQ.RunUpgradeStep_ConvertLegacyProtected();

        // [Then] Both entries remain, and only the recurring one is monitored
        _Assert.AreEqual(2, _LibrarySpfyJQ.CountJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected both seeded OrderImport JQ entries to remain.');
        _Assert.AreEqual(1, _LibrarySpfyJQ.CountMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId()), 'Expected exactly one OrderImport monitored row.');
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected to find the OrderImport monitored row.');
        _Assert.AreEqual(RecurringJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'Expected the monitored row to point to the recurring OrderImport JQ entry.');
        // [Then] The one-off entry is left as seeded
        _Assert.IsTrue(OneOffJobQueueEntry.Find(), 'Expected the one-off OrderImport JQ entry to still exist.');
        _Assert.IsTrue(OneOffJobQueueEntry."NPR NP Protected Job", 'Expected the one-off OrderImport JQ entry to stay NP protected.');
        _Assert.IsFalse(ManagedByApp.Get(OneOffJobQueueEntry.ID), 'Expected no Managed By App row for the one-off OrderImport JQ entry.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Refresher cycle - preserves admin-edited No. of Minutes between Runs]

    // These refresh tests commit and can cancel Shopify job queue entries in the whole company. Run them on CI or on a sandbox without a live Shopify setup.
    [Test]
    procedure OrderImport_RefresherCycle_PreservesAdminEditedMinutesBetweenRuns()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RefreshedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        RefreshedMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        RefreshedSnapshot: Record "Job Queue Entry";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        EditedJobQueueEntryId: Guid;
        LastMonitoredEntryNo: BigInteger;
        RefreshedEntryFound: Boolean;
        RefreshedMonitoredFound: Boolean;
        RefreshedIsAppManaged: Boolean;
        RefreshedMonitoredMinutes: Integer;
    begin
        // [Scenario] After an admin edits "No. of Minutes between Runs" on the monitored row via the
        //            Monitored JQ Entry card, the OnRefreshNPRJobQueueList publisher chain must not
        //            clobber the monitored row back to the code-default value. Under the pre-CORE-2178
        //            code, the OrderMgt subscriber called SetupJobQueues on every refresh, which fed the
        //            code default through MonitoredJobQueueMgt.AddMonitoredJobQueueEntry's
        //            TransferFields(JobQueueEntry, false), overwriting the admin edit. CORE-2178 makes
        //            that subscriber early-exit while the ecom feature is enabled, so the admin edit
        //            survives.
        InitializeJQ();
        AssertRefreshPreconditions();

        // [Given] Feature and integration on, one importing store, OrderImport JQ configured, and the
        //         admin has edited the minutes-between-runs on the resulting MONITORED row (this is
        //         the value entered on the Monitored JQ Entry card).
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the OrderImport JQ entry should exist after enabling.');
        EditedJobQueueEntryId := JobQueueEntry.ID;
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: the monitored row should exist for the OrderImport JQ entry.');
        _LibrarySpfyJQ.SetMonitoredJQMinutesBetweenRuns(MonitoredJQEntry, 15);
        LastMonitoredEntryNo := _LibrarySpfyJQ.GetLastMonitoredEntryNo();

        // [When] The refresher raises OnRefreshNPRJobQueueList (phase 1 only), which runs every subscriber,
        //        including the OrderMgt one that used to clobber the monitored row, and commits. The bound
        //        hold subscriber keeps any recreated Shopify order entry off the platform scheduler.
        Commit();
        BindSubscription(LibrarySpfyJQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] Snapshot the outcome BEFORE restoring, so an assertion failure does not leak fixture state.
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyOrderImportJQ.CurrCodeunitId(), RefreshedMonitoredJQEntry);
        RefreshedMonitoredFound := RefreshedMonitoredJQEntry.FindFirst();
        if RefreshedMonitoredFound then
            RefreshedMonitoredMinutes := RefreshedMonitoredJQEntry."No. of Minutes between Runs";
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyOrderImportJQ.CurrCodeunitId(), RefreshedJobQueueEntry);
        RefreshedEntryFound := RefreshedJobQueueEntry.FindFirst();
        if RefreshedEntryFound then begin
            RefreshedSnapshot := RefreshedJobQueueEntry;
            if ManagedByApp.Get(RefreshedJobQueueEntry.ID) then
                RefreshedIsAppManaged := ManagedByApp."Managed by App";
        end;

        _LibrarySpfyJQ.DeleteShopifyMonitoredEntriesAfter(LastMonitoredEntryNo);
        RestoreJQConfig();
        Commit();

        // Load-bearing: the monitored row must still carry the admin value. This is what the pre-CORE-2178
        // OnRefreshNPRJobQueueList subscribers would have overwritten via SetupJobQueues.
        _Assert.IsTrue(RefreshedMonitoredFound, 'Expected the OrderImport monitored row to still exist after the refresh cycle.');
        _Assert.AreEqual(15, RefreshedMonitoredMinutes, 'Expected the admin-edited "No. of Minutes between Runs" on the monitored row to survive the OnRefreshNPRJobQueueList cycle - the pre-CORE-2178 subscriber called SetupJobQueues, which rewrote this value to the code default.');
        _Assert.IsTrue(RefreshedEntryFound, 'Expected the OrderImport JQ entry to still exist after the refresh cycle.');
        _Assert.AreEqual(EditedJobQueueEntryId, RefreshedSnapshot.ID, 'Expected the same-ID OrderImport JQ entry to survive the refresh cycle - the refresher must not rebuild it under a new ID.');
        _Assert.IsFalse(RefreshedSnapshot."NPR NP Protected Job", 'Expected the OrderImport JQ entry to still be non-NP-protected after the refresh.');
        _Assert.IsTrue(RefreshedIsAppManaged, 'Expected the OrderImport JQ entry to still be flagged Managed by App after the refresh.');
    end;

    [Test]
    procedure EventDocProcessor_RefresherCycle_PreservesAdminEditedMinutesBetweenRuns()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RefreshedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        RefreshedMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        RefreshedSnapshot: Record "Job Queue Entry";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        EditedJobQueueEntryId: Guid;
        LastMonitoredEntryNo: BigInteger;
        RefreshedEntryFound: Boolean;
        RefreshedMonitoredFound: Boolean;
        RefreshedIsAppManaged: Boolean;
        RefreshedMonitoredMinutes: Integer;
    begin
        // [Scenario] After an admin edits "No. of Minutes between Runs" on the monitored row via the
        //            Monitored JQ Entry card, the OnRefreshNPRJobQueueList publisher chain must not
        //            clobber the monitored row back to the code-default value. Under the pre-CORE-2178
        //            code, the EventDocProcessor subscriber called SetupJobQueues on every refresh,
        //            which fed the code default through MonitoredJobQueueMgt.AddMonitoredJobQueueEntry's
        //            TransferFields(JobQueueEntry, false), overwriting the admin edit. CORE-2178 removes
        //            that subscriber, so the admin edit survives.
        InitializeJQ();
        AssertRefreshPreconditions();

        // [Given] Feature and integration on, one importing store, EventDocProcessor JQ configured, and
        //         the admin has edited the minutes-between-runs on the resulting MONITORED row (this is
        //         the value entered on the Monitored JQ Entry card).
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: the EventDocProcessor JQ entry should exist after enabling.');
        EditedJobQueueEntryId := JobQueueEntry.ID;
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: the monitored row should exist for the EventDocProcessor JQ entry.');
        _LibrarySpfyJQ.SetMonitoredJQMinutesBetweenRuns(MonitoredJQEntry, 15);
        LastMonitoredEntryNo := _LibrarySpfyJQ.GetLastMonitoredEntryNo();

        // [When] The refresher raises OnRefreshNPRJobQueueList (phase 1 only), which runs every subscriber,
        //        including the one that clobbered the monitored row under the pre-CORE-2178 code, and
        //        commits. The bound hold subscriber keeps any recreated Shopify order entry off the platform
        //        scheduler.
        Commit();
        BindSubscription(LibrarySpfyJQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(LibrarySpfyJQHold);

        // [Then] Snapshot the outcome BEFORE restoring, so an assertion failure does not leak fixture state.
        _LibrarySpfyJQ.FilterMonitoredEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), RefreshedMonitoredJQEntry);
        RefreshedMonitoredFound := RefreshedMonitoredJQEntry.FindFirst();
        if RefreshedMonitoredFound then
            RefreshedMonitoredMinutes := RefreshedMonitoredJQEntry."No. of Minutes between Runs";
        _LibrarySpfyJQ.FilterJobQueueEntries(SpfyEventDocProcessorJQ.CurrCodeunitId(), RefreshedJobQueueEntry);
        RefreshedEntryFound := RefreshedJobQueueEntry.FindFirst();
        if RefreshedEntryFound then begin
            RefreshedSnapshot := RefreshedJobQueueEntry;
            if ManagedByApp.Get(RefreshedJobQueueEntry.ID) then
                RefreshedIsAppManaged := ManagedByApp."Managed by App";
        end;

        _LibrarySpfyJQ.DeleteShopifyMonitoredEntriesAfter(LastMonitoredEntryNo);
        RestoreJQConfig();
        Commit();

        // Load-bearing: the monitored row must still carry the admin value. This is what the pre-CORE-2178
        // OnRefreshNPRJobQueueList subscriber would have overwritten via SetupJobQueues.
        _Assert.IsTrue(RefreshedMonitoredFound, 'Expected the EventDocProcessor monitored row to still exist after the refresh cycle.');
        _Assert.AreEqual(15, RefreshedMonitoredMinutes, 'Expected the admin-edited "No. of Minutes between Runs" on the monitored row to survive the OnRefreshNPRJobQueueList cycle - the pre-CORE-2178 subscriber called SetupJobQueues, which rewrote this value to the code default.');
        _Assert.IsTrue(RefreshedEntryFound, 'Expected the EventDocProcessor JQ entry to still exist after the refresh cycle.');
        _Assert.AreEqual(EditedJobQueueEntryId, RefreshedSnapshot.ID, 'Expected the same-ID EventDocProcessor JQ entry to survive the refresh cycle - the refresher must not rebuild it under a new ID.');
        _Assert.IsFalse(RefreshedSnapshot."NPR NP Protected Job", 'Expected the EventDocProcessor JQ entry to still be non-NP-protected after the refresh.');
        _Assert.IsTrue(RefreshedIsAppManaged, 'Expected the EventDocProcessor JQ entry to still be flagged Managed by App after the refresh.');
    end;

    #endregion

    #region [Refresher cycle - removes jobs that should not exist]

    [Test]
    procedure EcomJobs_RefresherCycle_CancelledWhenNoStoreImports()
    var
        SpfyStore: Record "NPR Spfy Store";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        LastMonitoredEntryNo: BigInteger;
        OrderImportJQCount: Integer;
        OrderImportMonitoredCount: Integer;
        EventDocProcessorJQCount: Integer;
        EventDocProcessorMonitoredCount: Integer;
    begin
        // [Scenario] With the ecom feature on, a refresh cancels both ecom jobs once no store imports orders
        //            or returns any more, for example after the store was disabled without its OnValidate.
        InitializeJQ();
        AssertRefreshPreconditions();

        // [Given] Feature and integration on, one store importing orders, both ecom jobs set up
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        _LibrarySpfyJQ.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, false);
        _LibrarySpfyJQ.RunOrderImportSetupJobQueues();
        _LibrarySpfyJQ.RunEventDocProcessorSetupJobQueues();
        _Assert.AreNotEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(GetOrderImportCuId()), 'Precondition: the OrderImport JQ entry should exist after enabling.');
        _Assert.AreNotEqual(0, _LibrarySpfyJQ.CountJobQueueEntries(GetEventDocProcessorCuId()), 'Precondition: the EventDocProcessor JQ entry should exist after enabling.');

        // [Given] The store is disabled by a plain Modify, so no job queue setup runs
        SpfyStore.Get(_JQStoreCodeLbl);
        SpfyStore.Enabled := false;
        SpfyStore.Modify();
        LastMonitoredEntryNo := _LibrarySpfyJQ.GetLastMonitoredEntryNo();

        // [When] The refresher raises OnRefreshNPRJobQueueList (phase 1 only)
        Commit();
        BindSubscription(LibrarySpfyJQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(LibrarySpfyJQHold);

        OrderImportJQCount := _LibrarySpfyJQ.CountJobQueueEntries(GetOrderImportCuId());
        OrderImportMonitoredCount := _LibrarySpfyJQ.CountMonitoredEntries(GetOrderImportCuId());
        EventDocProcessorJQCount := _LibrarySpfyJQ.CountJobQueueEntries(GetEventDocProcessorCuId());
        EventDocProcessorMonitoredCount := _LibrarySpfyJQ.CountMonitoredEntries(GetEventDocProcessorCuId());

        _LibrarySpfyJQ.DeleteShopifyMonitoredEntriesAfter(LastMonitoredEntryNo);
        _LibrarySpfyJQ.ClearJobQueueState(GetOrderImportCuId());
        _LibrarySpfyJQ.ClearJobQueueState(GetEventDocProcessorCuId());
        RestoreJQConfig();
        Commit();

        // [Then] Neither ecom codeunit has a JQ entry or a monitored row
        _Assert.AreEqual(0, OrderImportJQCount, 'Expected the refresh to cancel the OrderImport JQ entry when no store imports orders or returns.');
        _Assert.AreEqual(0, OrderImportMonitoredCount, 'Expected the refresh to remove the OrderImport monitored row when no store imports orders or returns.');
        _Assert.AreEqual(0, EventDocProcessorJQCount, 'Expected the refresh to cancel the EventDocProcessor JQ entry when no store imports orders or returns.');
        _Assert.AreEqual(0, EventDocProcessorMonitoredCount, 'Expected the refresh to remove the EventDocProcessor monitored row when no store imports orders or returns.');
    end;

    [Test]
    procedure LegacyOrderJob_RefresherCycle_RemovedWhenFeatureOn()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        SeededMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        LastMonitoredEntryNo: BigInteger;
        LegacyJQCount: Integer;
        LegacyMonitoredCount: Integer;
    begin
        // [Scenario] With the ecom feature on, a refresh removes a leftover job queue entry and a leftover
        //            orphan monitored row of the legacy "NPR Spfy Order Mgt." import job.
        InitializeJQ();
        AssertRefreshPreconditions();

        // [Given] The integration setup exists, feature on, no eligible store, a leftover legacy job queue entry
        //         held by "NPR Manually Set On Hold", and an orphan legacy monitored row
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _LibrarySpfyJQ.SetFeatureEnabled(true);
        SetJQStore(false, false);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(Codeunit::"NPR Spfy Order Mgt.", SeededJobQueueEntry);
        _LibrarySpfyJQ.CreateProtectedMonitoredRow(Codeunit::"NPR Spfy Order Mgt.", SeededMonitoredJQEntry);
        LastMonitoredEntryNo := _LibrarySpfyJQ.GetLastMonitoredEntryNo();

        // [When] The refresher raises OnRefreshNPRJobQueueList (phase 1 only)
        Commit();
        BindSubscription(LibrarySpfyJQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(LibrarySpfyJQHold);

        LegacyJQCount := _LibrarySpfyJQ.CountJobQueueEntries(Codeunit::"NPR Spfy Order Mgt.");
        LegacyMonitoredCount := _LibrarySpfyJQ.CountMonitoredEntries(Codeunit::"NPR Spfy Order Mgt.");

        _LibrarySpfyJQ.DeleteShopifyMonitoredEntriesAfter(LastMonitoredEntryNo);
        _LibrarySpfyJQ.DeleteMonitoredEntry(SeededMonitoredJQEntry."Entry No.");
        if SeededJobQueueEntry.Get(SeededJobQueueEntry.ID) then
            _LibrarySpfyJQ.DeleteJobQueueEntry(SeededJobQueueEntry);
        _LibrarySpfyJQ.ClearJobQueueState(GetOrderImportCuId());
        _LibrarySpfyJQ.ClearJobQueueState(GetEventDocProcessorCuId());
        RestoreJQConfig();
        Commit();

        // [Then] The legacy import job has neither a JQ entry nor a monitored row
        _Assert.AreEqual(0, LegacyJQCount, 'Expected no "NPR Spfy Order Mgt." JQ entry after the refresh with the ecom feature on.');
        _Assert.AreEqual(0, LegacyMonitoredCount, 'Expected the refresh to remove the orphan "NPR Spfy Order Mgt." monitored row with the ecom feature on.');
    end;

    [Test]
    procedure EcomJobs_RefresherCycle_RemovedWhenFeatureOff()
    var
        OrderImportJobQueueEntry: Record "Job Queue Entry";
        EventDocProcessorJobQueueEntry: Record "Job Queue Entry";
        OrderImportMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        EventDocProcessorMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        LibrarySpfyJQHold: Codeunit "NPR Library - Spfy JQ";
        LastMonitoredEntryNo: BigInteger;
        OrderImportJQCount: Integer;
        OrderImportMonitoredCount: Integer;
        EventDocProcessorJQCount: Integer;
        EventDocProcessorMonitoredCount: Integer;
    begin
        // [Scenario] With the ecom feature off, a refresh removes the ecom jobs and their monitored rows before
        //            it sets up the legacy jobs.
        InitializeJQ();
        AssertRefreshPreconditions();

        // [Given] Integration setup present but disabled, store disabled, feature off, and leftover ecom jobs
        //         plus orphan monitored rows for both ecom codeunits
        _LibrarySpfyJQ.SetEnableIntegration(false);
        _LibrarySpfyJQ.SetFeatureEnabled(false);
        SetJQStore(false, false);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(GetOrderImportCuId(), OrderImportJobQueueEntry);
        _LibrarySpfyJQ.CreateLegacyProtectedJob(GetEventDocProcessorCuId(), EventDocProcessorJobQueueEntry);
        _LibrarySpfyJQ.CreateProtectedMonitoredRow(GetOrderImportCuId(), OrderImportMonitoredJQEntry);
        _LibrarySpfyJQ.CreateProtectedMonitoredRow(GetEventDocProcessorCuId(), EventDocProcessorMonitoredJQEntry);
        LastMonitoredEntryNo := _LibrarySpfyJQ.GetLastMonitoredEntryNo();

        // [When] The refresher raises OnRefreshNPRJobQueueList (phase 1 only)
        Commit();
        BindSubscription(LibrarySpfyJQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(LibrarySpfyJQHold);

        OrderImportJQCount := _LibrarySpfyJQ.CountJobQueueEntries(GetOrderImportCuId());
        OrderImportMonitoredCount := _LibrarySpfyJQ.CountMonitoredEntries(GetOrderImportCuId());
        EventDocProcessorJQCount := _LibrarySpfyJQ.CountJobQueueEntries(GetEventDocProcessorCuId());
        EventDocProcessorMonitoredCount := _LibrarySpfyJQ.CountMonitoredEntries(GetEventDocProcessorCuId());

        _LibrarySpfyJQ.DeleteShopifyMonitoredEntriesAfter(LastMonitoredEntryNo);
        _LibrarySpfyJQ.DeleteMonitoredEntry(OrderImportMonitoredJQEntry."Entry No.");
        _LibrarySpfyJQ.DeleteMonitoredEntry(EventDocProcessorMonitoredJQEntry."Entry No.");
        _LibrarySpfyJQ.ClearJobQueueState(GetOrderImportCuId());
        _LibrarySpfyJQ.ClearJobQueueState(GetEventDocProcessorCuId());
        RestoreJQConfig();
        Commit();

        // [Then] Neither ecom codeunit has a JQ entry or a monitored row
        _Assert.AreEqual(0, OrderImportJQCount, 'Expected the refresh to remove the OrderImport JQ entry with the ecom feature off.');
        _Assert.AreEqual(0, OrderImportMonitoredCount, 'Expected the refresh to remove the OrderImport monitored row with the ecom feature off.');
        _Assert.AreEqual(0, EventDocProcessorJQCount, 'Expected the refresh to remove the EventDocProcessor JQ entry with the ecom feature off.');
        _Assert.AreEqual(0, EventDocProcessorMonitoredCount, 'Expected the refresh to remove the EventDocProcessor monitored row with the ecom feature off.');
    end;

    /// <summary>
    /// Fails before the refresh commits when RefreshNPRJobQueueList would error on its time zone check or skip
    /// the subscribers, so a refresh test never commits fixture state it then cannot clean up.
    /// </summary>
    local procedure AssertRefreshPreconditions()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if not JQRefreshSetup.Get() then
            Clear(JQRefreshSetup);
        _Assert.IsTrue((not JQRefreshSetup."Use External JQ Refresher") or (JQRefreshSetup."Default Job Time Zone" <> ''), 'Precondition: with "Use External JQ Refresher" on, "Default Job Time Zone" must be set, or RefreshNPRJobQueueList errors.');
        _Assert.IsFalse(JobQueueManagement.SkipUpdateNPManagedMonitoredJobs(), 'Precondition: SkipUpdateNPManagedMonitoredJobs must be false, or RefreshNPRJobQueueList skips the OnRefreshNPRJobQueueList subscribers.');
    end;

    #endregion

    #region [Fixture]

    local procedure InitializeJQ()
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        SaveJQConfig();
        // Ensure no other enabled Shopify store on the tenant decides the sales-order-integration master
        // switch instead of this suite's fixture. TestIsolation = Codeunit rolls the writes back at the
        // codeunit boundary. RestoreJQConfig puts back only the two stores this fixture owns.
        _LibrarySpfyJQ.DisableStoresExcept(_JQStoreCodeLbl);
        // Baseline Sales Return Order Integration off on the two fixture stores, so a prior test that flipped
        // it on cannot leak into an OrderImport_/EventDocProcessor_ test whose expectation predates the union.
        if SpfyStore.Get(_JQStoreCodeLbl) then
            _LibrarySpfyJQ.SetSalesReturnIntegration(_JQStoreCodeLbl, false);
        if SpfyStore.Get(_JQSecondStoreCodeLbl) then
            _LibrarySpfyJQ.SetSalesReturnIntegration(_JQSecondStoreCodeLbl, false);
        _LibrarySpfyJQ.ClearJobQueueState(GetOrderImportCuId());
        _LibrarySpfyJQ.ClearJobQueueState(GetEventDocProcessorCuId());
    end;

    local procedure SaveJQConfig()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyStore: Record "NPR Spfy Store";
        Feature: Record "NPR Feature";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        _SavedIntegrationEnabled := false;
        _SavedFeatureEnabled := false;
        _SavedStoreEnabled := false;
        _SavedStoreSalesOrderIntegration := false;
        _SavedStoreSalesReturnIntegration := false;
        _SavedStoreUrl := '';
        _SavedSecondStoreEnabled := false;
        _SavedSecondStoreSalesOrderIntegration := false;
        _SavedSecondStoreSalesReturnIntegration := false;
        _SavedSecondStoreUrl := '';

        _SavedSetupExisted := SpfyIntegrationSetup.Get();
        if _SavedSetupExisted then
            _SavedIntegrationEnabled := SpfyIntegrationSetup."Enable Integration";

        _SavedFeatureExisted := Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        if _SavedFeatureExisted then
            _SavedFeatureEnabled := Feature.Enabled;

        _SavedStoreExisted := SpfyStore.Get(_JQStoreCodeLbl);
        if _SavedStoreExisted then begin
            _SavedStoreEnabled := SpfyStore.Enabled;
            _SavedStoreSalesOrderIntegration := SpfyStore."Sales Order Integration";
            _SavedStoreSalesReturnIntegration := SpfyStore."Sales Return Order Integration";
            _SavedStoreUrl := SpfyStore."Shopify Url";
        end;

        _SavedSecondStoreExisted := SpfyStore.Get(_JQSecondStoreCodeLbl);
        if _SavedSecondStoreExisted then begin
            _SavedSecondStoreEnabled := SpfyStore.Enabled;
            _SavedSecondStoreSalesOrderIntegration := SpfyStore."Sales Order Integration";
            _SavedSecondStoreSalesReturnIntegration := SpfyStore."Sales Return Order Integration";
            _SavedSecondStoreUrl := SpfyStore."Shopify Url";
        end;
    end;

    local procedure RestoreJQConfig()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyStore: Record "NPR Spfy Store";
        Feature: Record "NPR Feature";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        // Puts back Enabled and "Sales Order Integration" on any foreign Shopify store that
        // InitializeJQ's DisableStoresExcept switched off. Runs first so the two fixture-store
        // restores below overwrite whatever this restored for them - the fixture-store snapshots
        // in SaveJQConfig capture the same pre-InitializeJQ state either way.
        _LibrarySpfyJQ.RestoreDisabledStores();

        _LibrarySpfyJQ.ClearJobQueueState(GetOrderImportCuId());
        _LibrarySpfyJQ.ClearJobQueueState(GetEventDocProcessorCuId());

        if SpfyStore.Get(_JQStoreCodeLbl) then
            if _SavedStoreExisted then begin
                SpfyStore.Enabled := _SavedStoreEnabled;
                SpfyStore."Sales Order Integration" := _SavedStoreSalesOrderIntegration;
                SpfyStore."Sales Return Order Integration" := _SavedStoreSalesReturnIntegration;
                SpfyStore."Shopify Url" := _SavedStoreUrl;
                SpfyStore.Modify(false);
            end else
                SpfyStore.Delete(false);

        if SpfyStore.Get(_JQSecondStoreCodeLbl) then
            if _SavedSecondStoreExisted then begin
                SpfyStore.Enabled := _SavedSecondStoreEnabled;
                SpfyStore."Sales Order Integration" := _SavedSecondStoreSalesOrderIntegration;
                SpfyStore."Sales Return Order Integration" := _SavedSecondStoreSalesReturnIntegration;
                SpfyStore."Shopify Url" := _SavedSecondStoreUrl;
                SpfyStore.Modify(false);
            end else
                SpfyStore.Delete(false);

        if SpfyIntegrationSetup.Get() then
            if _SavedSetupExisted then begin
                SpfyIntegrationSetup."Enable Integration" := _SavedIntegrationEnabled;
                SpfyIntegrationSetup.Modify();
            end else
                SpfyIntegrationSetup.Delete();

        if Feature.Get(ShopifyEcommOrderExp.GetFeatureId()) then
            if _SavedFeatureExisted then begin
                Feature.Enabled := _SavedFeatureEnabled;
                Feature.Modify();
            end else
                Feature.Delete();

        SpfyIntegrationMgt.SetRereadSetup();
    end;

    local procedure SetJQStore(StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    begin
        _LibrarySpfyJQ.SetStore(_JQStoreCodeLbl, StoreEnabled, SalesOrderIntegration);
    end;

    local procedure SetSecondJQStore(StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    begin
        _LibrarySpfyJQ.SetStore(_JQSecondStoreCodeLbl, StoreEnabled, SalesOrderIntegration);
    end;

    local procedure GetOrderImportCuId(): Integer
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
    begin
        exit(SpfyOrderImportJQ.CurrCodeunitId());
    end;

    local procedure GetEventDocProcessorCuId(): Integer
    var
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        exit(SpfyEventDocProcessorJQ.CurrCodeunitId());
    end;

    local procedure InsertReadyEventLogEntry(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): BigInteger
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry."Store Code" := StoreCode;
        SpfyEventLogEntry."Document Type" := DocType;
        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Ready;
        SpfyEventLogEntry."Process Retry Count" := 0;
        SpfyEventLogEntry."Not Before Date-Time" := CurrentDateTime() - 1000;
        SpfyEventLogEntry."Bucket Id" := 1;
        SpfyEventLogEntry."Event Date-Time" := CurrentDateTime();
        SpfyEventLogEntry.Insert(true);
        exit(SpfyEventLogEntry."Entry No.");
    end;

    local procedure DeleteEventLogEntry(EntryNo: BigInteger)
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        if SpfyEventLogEntry.Get(EntryNo) then
            SpfyEventLogEntry.Delete(false);
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
        _MessageCount += 1;
        _LastMessage := Msg;
    end;

    #endregion
}
#endif
