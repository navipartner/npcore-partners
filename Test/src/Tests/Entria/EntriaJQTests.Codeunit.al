#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85390 "NPR Entria JQ Tests"
{
    // [FEATURE] Entria integration: the order import job queue lifecycle - creating and tearing the recurring
    //           importer down with the sales order integration master switch, registering it as a monitored
    //           rather than NP-protected job, the refresher gate and the recreation of a deleted entry, store
    //           deletion edge cases, and what the Configure action reports to the admin.
    //
    // InitializeJQ() normalises state at the START of every test: TestIsolation = Codeunit rolls back at the
    // end of the codeunit, not between tests, so every write - committed or not - reaches every later test.
    // Measured on BC 28 - a committed row is gone by the next run, so the leak is within a run only.
    //
    // Tests here must not Commit(), because TaskScheduler.CreateTask is transactional: uncommitted it goes
    // with the boundary rollback, committed it survives and hands the platform the importer - see the job
    // queue hold subscriber in "NPR Library - Entria". A test that must Commit() first - Codeunit.Run of a
    // codeunit declaring TableNo is refused once this transaction has written - restores and commits its own
    // fixture before asserting, so a failing assertion leaves nothing behind.

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _SavedSetupExisted: Boolean;
        _SavedStoreExisted: Boolean;
        _SavedSecondStoreExisted: Boolean;
        _SavedIntegrationEnabled: Boolean;
        _SavedStoreEnabled: Boolean;
        _SavedStoreSalesOrderIntegration: Boolean;
        _SavedSecondStoreEnabled: Boolean;
        _SavedSecondStoreSalesOrderIntegration: Boolean;
        _ConfirmReply: Boolean;
        _MessageCount: Integer;
        _LastMessage: Text;
        _SavedStoreUrl: Text[250];
        _SavedSecondStoreUrl: Text[250];
        _JQStoreCodeLbl: Label 'NPRENT-JQTEST', Locked = true;
        _JQSecondStoreCodeLbl: Label 'NPRENT-JQTEST2', Locked = true;

    #region [Enable]

    [Test]
    procedure Enable_CreatesNonProtectedMonitoredAndManagedJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        // [Scenario] With the integration on and a store that has Sales Order Integration enabled, configuring
        //            the job queues must produce an app-managed, monitored, NON-protected entry - the job
        //            queue refresher is blind to NP-protected entries.
        InitializeJQ();

        // [Given] The integration is enabled and one store imports sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The job queues are configured through the production entry point
        _LibraryEntria.RunSetupJobQueues();

        // [Then] Exactly one job queue entry exists for the importer, and it is not NP-protected
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Expected exactly one Entria order import job queue entry after enabling.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Expected to find the Entria order import job queue entry.');
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'The Entria order import job must not be NP protected - a protected job is never added to the monitored list, so the refresher cannot heal it.');

        // [Then] It is registered as monitored, and as app-managed
        _Assert.IsTrue(_LibraryEntria.FindOrderImportMonitoredRow(MonitoredJQEntry), 'Expected a monitored job queue entry for the Entria order import job.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the live job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected a Managed-By-App row for the Entria order import job.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'Expected the Managed-By-App row to be flagged Managed by App.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Enable_EntryLeftOnHold_JobIsNotReportedReadyToRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] The Configure action must not report the import as configured when the job queue entry is
        //            not going to run. An entry can be created and registered as monitored and still sit On Hold -
        //            held by an admin, or created by a session that may not schedule tasks - and then no Entria
        //            order is ever imported.
        InitializeJQ();

        // [Given] The integration is enabled and one store imports sales orders, so the master switch is on
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The job queues are configured through the production entry point
        _LibraryEntria.RunSetupJobQueues();

        // [Then] The entry was created and registered, so the setup itself did run
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Expected to find the Entria order import job queue entry.');
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected the entry to be registered as monitored even when it is not started.');

        // [Then] It sits On Hold, and the job is not reported as ready to run
        _Assert.AreEqual(JobQueueEntry.Status::"On Hold", JobQueueEntry.Status, 'Precondition: this test needs the entry left On Hold.');
        _Assert.IsFalse(EntriaOrderImportJQ.IsJobQueueReadyToRun(), 'A job queue entry left On Hold must not be reported as ready to run - the Configure action would then tell the admin the import is configured while nothing runs.');

        // [When] The entry is released to Ready, as an admin would
        //Written directly: SetStatus() would schedule a platform task.
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."NPR Manually Set On Hold" := false;
        JobQueueEntry.Modify();

        // [Then] The job is reported ready to run - the branch a setup-call outcome could never reach
        _Assert.IsTrue(EntriaOrderImportJQ.IsJobQueueReadyToRun(), 'A Ready job queue entry must be reported as ready to run.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Enable_ExistingEntry_UpdatedInPlaceAndNotProtected()
    var
        SeededJobQueueEntry: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        SeededId: Guid;
    begin
        // [Scenario] When an order import entry already exists, configuring the job queues takes the update
        //            path of InitRecurringJobQueueEntry: the entry is reused rather than replaced, and its
        //            NP-protected flag is written to false rather than left as it was found.
        InitializeJQ();

        // [Given] The integration is enabled, and an NP-protected entry already exists with no monitored row
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.CreateLegacyProtectedJob(SeededJobQueueEntry);
        SeededId := SeededJobQueueEntry.ID;
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: the seeded protected entry must start with no monitored row.');

        // [When] The job queues are configured
        _LibraryEntria.RunSetupJobQueues();

        // [Then] The same entry was updated in place - not duplicated, not replaced
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Expected the existing entry to be updated in place rather than a second one created.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Expected to find the Entria order import job queue entry.');
        _Assert.AreEqual(SeededId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');

        // [Then] Its NP-protected flag has been actively cleared, and it is now monitored and app-managed
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'Expected the NP protected flag to be written to false on the existing entry.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportMonitoredRow(MonitoredJQEntry), 'Expected the converted entry to gain a monitored job queue entry.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the converted job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected the converted entry to gain a Managed-By-App row.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Enable_AfterJobQueueEntryDeleted_LeavesExactlyOneMonitoredRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        // [Scenario] Deleting a job queue entry leaves its monitored row orphaned, because the job queue entry
        //            table extension's OnDelete only removes the Managed-By-App row. Re-running setup must not
        //            then stack a second monitored row on top of the orphan - AddMonitoredJobQueueEntry searches
        //            by the new GUID, does not find the orphan, and would otherwise insert alongside it.
        InitializeJQ();

        // [Given] A configured job, whose entry is then deleted the way support deletes a stuck job
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Precondition: the job queue entry should exist after enabling.');
        _LibraryEntria.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        // [When] The job queues are configured again
        _LibraryEntria.RunSetupJobQueues();

        // [Then] There is exactly one monitored row, and it points at the live job queue entry
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected exactly one monitored row - the orphaned row must be purged rather than duplicated.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(RecreatedJobQueueEntry), 'Expected the job queue entry to be recreated.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportMonitoredRow(MonitoredJQEntry), 'Expected a monitored row after reconfiguring.');
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must point at the live job queue entry, not the deleted GUID.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Disable]

    [Test]
    procedure Disable_RemovesMonitoredAndManagedRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        EnabledJobQueueEntryId: Guid;
    begin
        // [Scenario] Switching Sales Order Integration off must retract the whole registration, otherwise the
        //            refresher would keep recreating a job for an integration the customer switched off.
        InitializeJQ();

        // [Given] A configured, monitored job
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Precondition: the job queue entry should exist after enabling.');
        EnabledJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: a monitored row should exist after enabling.');

        // [When] Sales Order Integration is switched off for the store and setup runs again
        SetJQStore(true, false);
        _LibraryEntria.RunSetupJobQueues();

        // [Then] Neither the monitored row nor the Managed-By-App row survives
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected no monitored row once no store has the sales order integration enabled.');
        _Assert.IsFalse(ManagedByApp.Get(EnabledJobQueueEntryId), 'Expected the Managed-By-App row to be gone once the job was cancelled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure Disable_AfterJobQueueEntryDeleted_LeavesNoMonitoredRows()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [Scenario] The resurrection hole. CancelNpManagedJobs exits early when no live entry exists for the
        //            codeunit, and RemoveMonitoredJobQueueEntry can only match on the job queue entry ID - so if
        //            support deletes the entry first and the customer disables the integration second, the
        //            orphaned monitored row survives and the refresher brings the job back for a switched-off
        //            integration. Disabling must clean up by object identity, not only by GUID.
        InitializeJQ();

        // [Given] A configured job whose entry has been deleted, leaving an orphaned monitored row
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Precondition: the job queue entry should exist after enabling.');
        _LibraryEntria.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: the monitored row should outlive the deleted job queue entry.');

        // [When] The integration is switched off while that orphan is in place
        SetJQStore(true, false);
        _LibraryEntria.RunSetupJobQueues();

        // [Then] Nothing is left that the refresher could resurrect the job from
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected the orphaned monitored row to be purged on disable, otherwise the refresher recreates a job for a disabled integration.');
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected no Entria order import job queue entry to exist after disabling.');

        RestoreJQConfig();
    end;

    [Test]
    procedure DeleteLastStore_RemovesJobQueueEntryAndMonitoredRow()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        // [Scenario] Deleting the last store that imports sales orders tears the job down with it. The store's
        //            OnDelete runs before the row is removed, so the store being deleted is still visible to the
        //            master-switch scan and must be excluded from it explicitly.
        InitializeJQ();

        // [Given] A single enabled store importing sales orders, with the job configured
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Precondition: the job queue entry should exist before deleting the store.');
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: a monitored row should exist before deleting the store.');

        // [When] That store is deleted, firing its OnDelete trigger
        _Assert.IsTrue(EntriaStore.Get(_JQStoreCodeLbl), 'Precondition: the test store should exist.');
        _LibraryEntria.DeleteStore(EntriaStore.Code);

        // [Then] Neither the job nor its monitored row is left behind
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected the job queue entry to be cancelled when the last store importing sales orders was deleted.');
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected no monitored row to survive deletion of the last store importing sales orders.');

        RestoreJQConfig();
    end;

    [Test]
    procedure DeleteStore_AnotherStoreStillImports_KeepsJobQueueEntryAndMonitoredRow()
    var
        EntriaStore: Record "NPR Entria Store";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SurvivingJobQueueEntryId: Guid;
    begin
        // [Scenario] Deleting one of two stores that import sales orders leaves the job running for the survivor.
        //            The OnDelete trigger excludes only the row being deleted from the master-switch scan, so the
        //            remaining store still counts and the existing entry is kept rather than torn down and rebuilt.
        InitializeJQ();

        // [Given] Two enabled stores importing sales orders, with the job configured
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Precondition: the job queue entry should exist before deleting a store.');
        SurvivingJobQueueEntryId := JobQueueEntry.ID;
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Precondition: exactly one monitored row should exist before deleting a store.');

        // [When] One of the two stores is deleted, firing its OnDelete trigger
        _Assert.IsTrue(EntriaStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibraryEntria.DeleteStore(EntriaStore.Code);

        // [Then] The job survives, and it is the same entry rather than a torn-down and rebuilt one
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Expected the job queue entry to survive while another store still imports sales orders.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Expected to still find the Entria order import job queue entry.');
        _Assert.AreEqual(SurvivingJobQueueEntryId, JobQueueEntry.ID, 'Expected the pre-existing job queue entry to survive, identified by its original ID.');

        // [Then] So does its monitored row, still pointing at that entry and still not duplicated
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected exactly one monitored row to survive deletion of a store that was not the last one importing sales orders.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportMonitoredRow(MonitoredJQEntry), 'Expected a monitored row for the surviving job.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The surviving monitored row must still point at the live job queue entry.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Refresher gate]

    [Test]
    procedure CreateMissingCustomJQs_SalesOrderIntegrationEnabled_SkipsValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] While a store has Sales Order Integration enabled, the refresher must be allowed to recreate
        //            the Entria order import entry if it has gone missing - otherwise a deleted entry never comes
        //            back and order import stays silently stopped.
        InitializeJQ();

        // [Given] The integration is enabled with a store that imports sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.BuildJobQueueEntryFor(EntriaOrderImportJQ.GetCodeunitId(), JobQueueEntry);

        // [When] The refresher asks whether it may recreate this missing job queue entry
        // [Then] The Entria subscriber opts in
        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Entria order import job must be recreatable while a store has the sales order integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure CreateMissingCustomJQs_SalesOrderIntegrationDisabled_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] With the sales order integration switched off, the refresher must NOT recreate the entry.
        //            The recreated job would not even fail fast: CheckIsEnabled() errors only when the
        //            integration is off or no store is Enabled at all - it never consults "Sales Order
        //            Integration" - so with a store still Enabled it passes its own gate, and the job spends its
        //            six-hour run querying, committing and sleeping once a second with nothing to import.
        InitializeJQ();

        // [Given] The integration is enabled but no store imports sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, false);
        _LibraryEntria.BuildJobQueueEntryFor(EntriaOrderImportJQ.GetCodeunitId(), JobQueueEntry);

        // [When] The refresher asks whether it may recreate this missing job queue entry
        // [Then] The Entria subscriber stays out of it, and nothing else opts in
        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Entria order import job must not be recreated while no store has the sales order integration enabled.');

        RestoreJQConfig();
    end;

    [Test]
    procedure CreateMissingCustomJQs_OtherCodeunit_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [Scenario] The subscriber is global - it sees every job the refresher asks about - so its object id
        //            guard has to hold. It must never authorise recreation of somebody else's job just because
        //            Entria happens to be enabled.
        InitializeJQ();

        // [Given] Entria is fully enabled, but the job in question belongs to another codeunit
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.BuildJobQueueEntryFor(Codeunit::"NPR Entria Tests", JobQueueEntry);

        // [When] The refresher asks about that unrelated job
        // [Then] The Entria subscriber does not answer for it
        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Entria subscriber must only answer for its own job queue entry, not for any other codeunit.');

        RestoreJQConfig();
    end;

    [Test]
    procedure CreateMissingCustomJQs_SameIdOtherObjectType_DoesNotSkipValidation()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] The subscriber guards on object type AND object id. Object ids are only unique per object
        //            type, so a report carrying the same number as the Entria codeunit is a different object
        //            entirely. Without the object-type guard the subscriber would authorise recreation of that
        //            report's job.
        InitializeJQ();

        // [Given] Entria is fully enabled, and a job whose object id matches but whose object type is Report
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.BuildReportJobQueueEntryFor(EntriaOrderImportJQ.GetCodeunitId(), JobQueueEntry);

        // [When] The refresher asks about that report job
        // [Then] The Entria subscriber does not answer for it
        _Assert.IsFalse(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Entria subscriber must only answer for a Codeunit job, not for a report that happens to share its object id.');

        RestoreJQConfig();
    end;

    [Test]
    procedure CreateMissingCustomJQs_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] The refresher session is long lived and iterates every monitored job on the tenant, so by the
        //            time it reaches Entria the SingleInstance "NPR Entria Integration Mgt." may already hold a
        //            cached setup record. The subscriber has to invalidate that cache before reading the master
        //            switch - without SetRereadSetup() it answers from whatever the session cached earlier, and a
        //            job that should be recreated silently is not.
        InitializeJQ();

        // [Given] A store that imports sales orders, and a session whose cached setup says the integration is off.
        //         The cache is populated through RunSetupJobQueues() - a production entry point that a real admin
        //         session reaches by validating an Entria store or setup field - rather than by calling the
        //         predicate directly, so the staleness this test relies on is one production can actually produce.
        SetJQStore(true, true);
        _LibraryEntria.SetEnableIntegration(false);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(), 'Precondition: the master switch should be off, and the setup run above should have cached that.');

        // [Given] The integration is switched back on the way another session would do it - cache left stale
        _LibraryEntria.SetEnableIntegrationLeavingCacheStale(true);
        _LibraryEntria.BuildJobQueueEntryFor(EntriaOrderImportJQ.GetCodeunitId(), JobQueueEntry);

        // [When] The refresher asks whether it may recreate the missing entry
        // [Then] The subscriber re-reads the setup rather than trusting the stale cache
        _Assert.IsTrue(JQRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The Entria subscriber must invalidate the cached setup before reading the master switch, otherwise a stale session cache stops a deleted job from ever being recreated.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Refresher recreation]

    [Test]
    procedure Refresher_MissingEntry_ProductionSubscriberRecreatesEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        MonitoredSnapshot: Record "NPR Monitored Job Queue Entry";
        RecreatedSnapshot: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        LibraryEntriaHold: Codeunit "NPR Library - Entria";
        DeletedJobQueueEntryId: Guid;
        ImportJobCount: Integer;
        RecreatedEntryFound: Boolean;
        RecreatedIsAppManaged: Boolean;
    begin
        // [Scenario] The refresher recreates a deleted order import entry, authorised by the production subscriber.
        InitializeJQ();

        // [Given] The integration is enabled, one store imports sales orders, and the job is configured
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Precondition: the job queue entry should exist after enabling.');
        DeletedJobQueueEntryId := JobQueueEntry.ID;

        // [Given] The entry is deleted the way support deletes a stuck job, leaving the monitored row orphaned
        _LibraryEntria.DeleteJobQueueEntry(JobQueueEntry);
        _Assert.IsTrue(_LibraryEntria.FindOrderImportMonitoredRow(MonitoredJQEntry), 'Precondition: the monitored row should outlive the deleted job queue entry.');
        Commit();

        // [When] The refresher runs - the bound subscriber only holds the entry, it authorises nothing
        BindSubscription(LibraryEntriaHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(LibraryEntriaHold);
            RestoreJQConfig();
            Commit();
            Error('The refresher should recreate the missing Entria order import entry through the production opt-in subscriber. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(LibraryEntriaHold);

        // [Then] Snapshot the outcome first: an assertion failing before RestoreJQConfig would leave this
        //        test's fixture standing for the rest of the run
        MonitoredJQEntry.Find();
        MonitoredSnapshot := MonitoredJQEntry;
        ImportJobCount := _LibraryEntria.CountOrderImportJobs();
        RecreatedEntryFound := RecreatedJobQueueEntry.Get(MonitoredSnapshot."Job Queue Entry ID");
        if RecreatedEntryFound then begin
            RecreatedSnapshot := RecreatedJobQueueEntry;
            if ManagedByApp.Get(MonitoredSnapshot."Job Queue Entry ID") then
                RecreatedIsAppManaged := ManagedByApp."Managed by App";
        end;

        RestoreJQConfig();
        Commit();

        // [Then] The monitored row reports Success and points at a freshly inserted entry
        MonitoredSnapshot.TestField("Last Refresh Status", MonitoredSnapshot."Last Refresh Status"::Success);
        _Assert.IsFalse(IsNullGuid(MonitoredSnapshot."Job Queue Entry ID"), 'Expected the monitored row to reference the recreated job queue entry.');
        _Assert.AreNotEqual(DeletedJobQueueEntryId, MonitoredSnapshot."Job Queue Entry ID", 'Expected the recreated entry to carry a new ID, not the deleted one.');
        _Assert.IsTrue(RecreatedEntryFound, 'Expected the recreated job queue entry to be persisted.');
        _Assert.AreEqual(1, ImportJobCount, 'Expected exactly one order import entry after the refresh.');

        // [Then] The entry the monitored row points at is the importer itself - asserted through the pointer,
        //        because a refresh that wrote another entry's ID there passes every count above
        _Assert.AreEqual(EntriaOrderImportJQ.GetCodeunitId(), RecreatedSnapshot."Object ID to Run", 'The monitored row must point at the Entria order import codeunit.');
        _Assert.AreEqual(EntriaOrderImportJQ.GetJQDescription(), RecreatedSnapshot.Description, 'The recreated entry must keep the order import description.');
        _Assert.IsTrue(RecreatedSnapshot."Recurring Job", 'The recreated entry must still be a recurring job - a one-shot entry imports once and stops.');
        _Assert.IsTrue(RecreatedIsAppManaged, 'Expected the recreated entry to be flagged Managed by App again.');
        _Assert.IsFalse(RecreatedSnapshot."NPR NP Protected Job", 'The recreated entry must not be NP protected - that is what keeps it monitored and healable.');

        // [Then] It came back stamped Manually Set On Hold, which is what kept the platform scheduler out
        _Assert.IsTrue(RecreatedSnapshot."NPR Manually Set On Hold", 'Precondition of this test: the hold subscriber must have stamped the recreated entry Manually Set On Hold.');
    end;

    #endregion

    #region [Store deletion edge cases]

    [Test]
    procedure DeleteStore_CodeContainsFilterWildcard_KeepsJobForTheRemainingStores()
    var
        EntriaStore: Record "NPR Entria Store";
        WildcardStoreCode: Code[20];
    begin
        // [Scenario] Deleting a store must never tear down the import job while another store still imports -
        //            not even when the deleted store's Code contains a character BC filter syntax treats as a
        //            wildcard. Store codes are admin-entered, so 'NPRENT-JQTEST*' is a legal code; excluded as a
        //            filter it would swallow 'NPRENT-JQTEST' too and stop order import silently.
        InitializeJQ();

        // [Given] Two enabled importing stores, where the one to be deleted has a Code that is the other's Code
        //         followed by '*' - so a wildcard reading of the exclusion filter swallows the survivor too
        WildcardStoreCode := _JQStoreCodeLbl + '*';
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        _LibraryEntria.SetStore(WildcardStoreCode, true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Precondition: the job queue entry should exist before deleting the store.');

        // [When] The store whose Code carries the wildcard is deleted, firing its OnDelete trigger
        _Assert.IsTrue(EntriaStore.Get(WildcardStoreCode), 'Precondition: the wildcard-coded test store should exist.');
        _LibraryEntria.DeleteStore(EntriaStore.Code);

        // [Then] The job survives, because the other store still imports sales orders
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Expected the job queue entry to survive: a store Code containing ''*'' must be excluded literally, not as a filter wildcard that also excludes the remaining importing store.');
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected the monitored row to survive alongside the job queue entry.');

        RestoreJQConfig();
    end;

    [Test]
    procedure MasterSwitch_ExcludingSeveralStores_IgnoresOnlyThose()
    var
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        ExcludedStoreCodes: List of [Code[20]];
    begin
        // [Scenario] Excluding stores from the scan must ignore exactly the stores named and no others: with two
        //            stores importing, excluding one leaves the other counting, excluding both leaves none, and a
        //            code that matches no store excludes nothing.
        InitializeJQ();

        // [Given] Two enabled stores import sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);

        // [When] One of them is excluded
        ExcludedStoreCodes.Add(_JQStoreCodeLbl);

        // [Then] The other one still counts
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(ExcludedStoreCodes),
            'Excluding one of two importing stores must still find the other.');

        // [When] Both are excluded - the only case that joins two exclusions into one filter expression
        ExcludedStoreCodes.Add(_JQSecondStoreCodeLbl);

        // [Then] Nothing counts towards the master switch
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(ExcludedStoreCodes),
            'Excluding both importing stores must leave no store counting towards the master switch: the exclusions have to be ANDed, not ORed.');

        // [When] A code that has no store row is excluded
        Clear(ExcludedStoreCodes);
        ExcludedStoreCodes.Add('NO SUCH STORE');

        // [Then] It excludes nothing, rather than erroring or excluding every store
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(ExcludedStoreCodes),
            'An excluded code with no store row must not exclude the stores that do exist.');

        RestoreJQConfig();
    end;

    [Test]
    procedure DeleteStore_StaleSetupCache_StillReadsTheCurrentMasterSwitch()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [Scenario] The store OnDelete teardown reads the master switch through the same SingleInstance cache, so
        //            it has to invalidate it too. An admin session that read the setup while the integration was
        //            enabled, and then deletes a store after the integration was switched off elsewhere, would
        //            otherwise re-assert the job for a switched-off integration - and now that the job is
        //            monitored, the refresher keeps it alive while every run fails in CheckIsEnabled.
        InitializeJQ();

        // [Given] TWO importing stores, so that the store being deleted is NOT the last one. With only one store
        //         the teardown happens whichever value of the master switch is read, and the test cannot tell a
        //         re-read from a stale cache.
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);
        SetSecondJQStore(true, true);
        _LibraryEntria.RunSetupJobQueues();
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(), 'Precondition: reading the master switch should populate the session cache while it is on.');
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Precondition: the job queue entry should exist before deleting the store.');

        // [Given] The integration is switched off the way another session would do it - cache left stale
        _LibraryEntria.SetEnableIntegrationLeavingCacheStale(false);

        // [When] One of the two stores is deleted, firing its OnDelete trigger. A stale cache would report the
        //        integration still on, see the surviving store importing, and KEEP the job.
        _Assert.IsTrue(EntriaStore.Get(_JQSecondStoreCodeLbl), 'Precondition: the second test store should exist.');
        _LibraryEntria.DeleteStore(EntriaStore.Code);

        // [Then] The teardown saw the current master switch, not the cached one
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected the OnDelete teardown to re-read the setup, otherwise a stale session cache leaves a monitored job behind for a switched-off integration.');
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected no monitored row to survive the teardown.');

        RestoreJQConfig();
    end;

    #endregion

    #region [Configure action]

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ConfigureAction_Declined_NothingCreatedAndNothingReported()
    begin
        // [Scenario] Declining the confirmation creates nothing and reports nothing.
        InitializeJQ();

        // [Given] The integration is enabled and one store imports sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The configure action runs and the admin declines the confirmation
        RunConfigureAction(false);

        // [Then] Nothing was created or registered. No MessageHandler is named by this test, so an outcome
        //        message raised despite the decline fails it as an unhandled dialog.
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected no job queue entry after the confirmation was declined.');
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected no monitored registration after the confirmation was declined.');

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ConfigureAction_IntegrationOff_MessageNamesTheEnableIntegrationField()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
    begin
        // [Scenario] With "Enable Integration" off, the outcome names that field, not the Entria Store page.
        InitializeJQ();

        // [Given] The toggle is off while a store in itself imports sales orders, which makes the store-page
        //         message the wrong answer
        _LibraryEntria.SetEnableIntegration(false);
        SetJQStore(true, true);

        // [When] The configure action runs and the admin accepts the confirmation
        RunConfigureAction(true);

        // [Then] No entry was created, and the one outcome message names the "Enable Integration" field
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected no job queue entry while the integration is switched off.');
        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, EntriaSetup.FieldCaption("Enable Integration")) > 0,
            StrSubstNo('The integration-off outcome must name the "%1" field; got: %2', EntriaSetup.FieldCaption("Enable Integration"), _LastMessage));

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ConfigureAction_NoSalesOrderIntegrationStore_MessageIsTheStorePageOne()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] With no store importing sales orders, the outcome is the store-page message.
        InitializeJQ();

        // [Given] The integration is on and the store is enabled, but does not import sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, false);

        // [When] The configure action runs and the admin accepts the confirmation
        RunConfigureAction(true);

        // [Then] No entry was created, and the message is neither the integration-off one nor a job-naming one
        _Assert.AreEqual(0, _LibraryEntria.CountOrderImportJobs(), 'Expected no job queue entry while no store imports sales orders.');
        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsFalse(StrPos(_LastMessage, EntriaSetup.FieldCaption("Enable Integration")) > 0,
            StrSubstNo('The no-store outcome must not send the admin to the "%1" field - the integration is already enabled; got: %2', EntriaSetup.FieldCaption("Enable Integration"), _LastMessage));
        _Assert.IsFalse(StrPos(_LastMessage, EntriaOrderImportJQ.GetJQDescription()) > 0,
            StrSubstNo('The no-store outcome must not name the "%1" job - nothing was created; got: %2', EntriaOrderImportJQ.GetJQDescription(), _LastMessage));

        // [Then] And it is positively the store-page instruction, not a third message carrying neither token.
        //        The page name is English inside the label, so this only holds on the en-US layer the containers run.
        _Assert.IsTrue(StrPos(_LastMessage, EntriaStore.TableCaption()) > 0,
            StrSubstNo('The no-store outcome must send the admin to the "%1" page; got: %2', EntriaStore.TableCaption(), _LastMessage));

        RestoreJQConfig();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ConfigureAction_MasterSwitchOn_EntryHeld_MessageReportsNotReady()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImportJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        // [Scenario] An entry created but left On Hold is reported as not ready, not as configured.
        InitializeJQ();

        // [Given] The integration is enabled and one store imports sales orders
        _LibraryEntria.SetEnableIntegration(true);
        SetJQStore(true, true);

        // [When] The configure action runs and the admin accepts the confirmation
        RunConfigureAction(true);

        // [Then] The entry exists, is registered as monitored, and sits On Hold
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportJobs(), 'Expected the job queue entry to be created.');
        _Assert.IsTrue(_LibraryEntria.FindOrderImportJob(JobQueueEntry), 'Expected to find the order import job queue entry.');
        _Assert.AreEqual(JobQueueEntry.Status::"On Hold", JobQueueEntry.Status, 'Precondition: this test needs the entry left On Hold.');
        _Assert.AreEqual(1, _LibraryEntria.CountOrderImportMonitoredRows(), 'Expected the entry to be registered as monitored.');

        // [Then] The message names the job AND reports it as not ready. The two outcomes share the job
        //        description, so only the wording separates them - en-US layer only
        _Assert.AreEqual(1, _MessageCount, 'Expected exactly one outcome message.');
        _Assert.IsTrue(StrPos(_LastMessage, EntriaOrderImportJQ.GetJQDescription()) > 0,
            StrSubstNo('The not-ready outcome must name the "%1" job; got: %2', EntriaOrderImportJQ.GetJQDescription(), _LastMessage));
        _Assert.IsTrue(StrPos(_LastMessage, 'not ready to run') > 0,
            StrSubstNo('Expected the not-ready outcome, not the configured one; got: %1', _LastMessage));

        RestoreJQConfig();
    end;

    #endregion

    #region [Fixture]

    local procedure InitializeJQ()
    begin
        SaveJQConfig();
        //Any other enabled store would decide the sales-order-integration master switch instead of this suite's
        //fixture and make the disable-side assertions meaningless. Safe to do tenant-wide because the runners
        //declare TestIsolation = Codeunit, which rolls the writes back at the codeunit boundary even where a test
        //has committed - measured on BC 28 with a committed marker row, gone in the next run. Within the run it
        //is one-way: RestoreJQConfig puts back only the two stores this fixture owns, so a third-party store
        //disabled here stays disabled until the boundary.
        //The second test store is deliberately NOT spared. A test that needs it creates it after InitializeJQ()
        //has already run, so sparing it would buy nothing - and would turn a mid-test failure into a
        //cascade, because a leaked second store left Enabled would decide the master switch for every later test
        //in this codeunit instead of the fixture's own store.
        _LibraryEntria.DisableStoresExcept(_JQStoreCodeLbl);
        _LibraryEntria.ClearOrderImportJobQueueState();
    end;

    local procedure SaveJQConfig()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        EntriaStore: Record "NPR Entria Store";
    begin
        _SavedIntegrationEnabled := false;
        _SavedStoreEnabled := false;
        _SavedStoreSalesOrderIntegration := false;
        _SavedStoreUrl := '';
        _SavedSecondStoreEnabled := false;
        _SavedSecondStoreSalesOrderIntegration := false;
        _SavedSecondStoreUrl := '';

        _SavedSetupExisted := EntriaSetup.Get();
        if _SavedSetupExisted then
            _SavedIntegrationEnabled := EntriaSetup."Enable Integration";

        //Only the fields this fixture writes are captured, so restoring cannot clobber anything else on a store
        //that happens to already exist on the tenant under the test code.
        _SavedStoreExisted := EntriaStore.Get(_JQStoreCodeLbl);
        if _SavedStoreExisted then begin
            _SavedStoreEnabled := EntriaStore.Enabled;
            _SavedStoreSalesOrderIntegration := EntriaStore."Sales Order Integration";
            _SavedStoreUrl := EntriaStore."Entria Url";
        end;

        _SavedSecondStoreExisted := EntriaStore.Get(_JQSecondStoreCodeLbl);
        if _SavedSecondStoreExisted then begin
            _SavedSecondStoreEnabled := EntriaStore.Enabled;
            _SavedSecondStoreSalesOrderIntegration := EntriaStore."Sales Order Integration";
            _SavedSecondStoreUrl := EntriaStore."Entria Url";
        end;
    end;

    local procedure RestoreJQConfig()
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        _LibraryEntria.ClearOrderImportJobQueueState();

        if EntriaStore.Get(_JQStoreCodeLbl) then
            if _SavedStoreExisted then begin
                EntriaStore.Enabled := _SavedStoreEnabled;
                EntriaStore."Sales Order Integration" := _SavedStoreSalesOrderIntegration;
                EntriaStore."Entria Url" := _SavedStoreUrl;
                EntriaStore.Modify();
            end else
                //Delete without the trigger: OnDelete tears down dimensions, the API key and the job queues,
                //none of which this fixture should be exercising as a side effect.
                EntriaStore.Delete();

        if EntriaStore.Get(_JQSecondStoreCodeLbl) then
            if _SavedSecondStoreExisted then begin
                EntriaStore.Enabled := _SavedSecondStoreEnabled;
                EntriaStore."Sales Order Integration" := _SavedSecondStoreSalesOrderIntegration;
                EntriaStore."Entria Url" := _SavedSecondStoreUrl;
                EntriaStore.Modify();
            end else
                EntriaStore.Delete();

        if EntriaSetup.Get() then
            if _SavedSetupExisted then begin
                EntriaSetup."Enable Integration" := _SavedIntegrationEnabled;
                EntriaSetup.Modify();
            end else
                EntriaSetup.Delete();

        EntriaIntegrationMgt.SetRereadSetup();
    end;

    local procedure SetJQStore(StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    begin
        _LibraryEntria.SetStore(_JQStoreCodeLbl, StoreEnabled, SalesOrderIntegration);
    end;

    local procedure SetSecondJQStore(StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    begin
        //Created on demand rather than in InitializeJQ, so only a test that needs a second store pays for it.
        _LibraryEntria.SetStore(_JQSecondStoreCodeLbl, StoreEnabled, SalesOrderIntegration);
    end;

    local procedure RunConfigureAction(ConfirmReply: Boolean)
    var
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        LibraryEntriaHold: Codeunit "NPR Library - Entria";
    begin
        _ConfirmReply := ConfirmReply;
        _MessageCount := 0;
        _LastMessage := '';
        //Bracketing the hold subscriber, as "NPR Library - Entria".RunSetupJobQueues() does for the raw setup
        //call: the action reaches StartJobQueueEntry, and only the Manually-Set-On-Hold stamp keeps a tenant
        //whose scheduler is active from being handed the six-hour import loop.
        BindSubscription(LibraryEntriaHold);
        EntriaIntegrationMgt.SetupJobQueuesWithConfirmation();
        UnbindSubscription(LibraryEntriaHold);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := _ConfirmReply;
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
