codeunit 85155 "NPR Job Queue Refresher Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _CreateMissingHelper: Codeunit "NPR JQ Refresher Test Helper";
        _TestParameterPrefix: Label 'NPR-JQR-TEST-', Locked = true;

    #region [AddJobQueueToMonitored]

    [Test]
    procedure AddJobQueueToMonitored_HappyPath_InsertsMonitoredAndManagedByApp()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        // [Scenario] Adding a non-protected recurring JQ entry to the monitored list creates both
        //            the monitored row AND the managed-by-app row that marks the JQE as one our app owns
        Initialize();

        // [Given] A fresh, non-protected, recurring JQ entry with a unique parameter string
        CreateRecurringJQEntry(JobQueueEntry, false);

        // [When] The public AddJobQueueToMonitored entry point is invoked for it
        RunAddJobQueueToMonitored(JobQueueEntry);

        // [Then] A monitored row exists for the JQE
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored entry to be inserted for the non-protected JQ entry.');
        MonitoredJQEntry.TestField("Object Type to Run", JobQueueEntry."Object Type to Run");
        MonitoredJQEntry.TestField("Object ID to Run", JobQueueEntry."Object ID to Run");

        // [Then] The Managed-By-App row is also inserted, flagging the JQE as app-managed
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Expected a Managed-By-App row to be inserted for the non-protected JQ entry.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'Expected the new Managed-By-App row to be flagged Managed by App = true.');
    end;

    [Test]
    procedure AddJobQueueToMonitored_DuplicateEntry_FailsAndDoesNotDuplicate()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        AddJQToMonitored: Codeunit "NPR Add Job Queue To Monitored";
    begin
        // [Scenario] Re-adding a JQ entry that is already on the monitored list must fail without inserting a
        //            second row. We assert the state invariant (count of monitored rows for this JQE is still
        //            exactly one) instead of matching English fragments of the production error label, which is
        //            translatable and would silently flip the assertion on a non-en-US language layer.
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);

        // [When] AddJobQueueToMonitored is invoked a second time for the same JQE
        if AddJQToMonitored.Run(JobQueueEntry) then
            Error('Expected the second AddJobQueueToMonitored call to fail because a monitored entry already exists, but it succeeded.');

        // [Then] Exactly one monitored row exists for the JQE — the duplicate call must not have inserted another
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.AreEqual(1, MonitoredJQEntry.Count(),
            'Expected exactly one monitored entry for the JQ entry after the rejected duplicate AddJobQueueToMonitored call.');
    end;

    [Test]
    procedure AddJobQueueToMonitored_NullGuid_FailsWithoutInsertingMonitoredRow()
    var
        EmptyJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        AddJQToMonitored: Codeunit "NPR Add Job Queue To Monitored";
        MonitoredCountBefore: Integer;
    begin
        // [Scenario] Passing a JQ entry record whose ID is a null GUID is rejected before any DB insert.
        //            We assert by row-count delta rather than matching the English error label — that label is
        //            translatable and a StrPos check on it would flip false on any non-en-US language layer.
        Initialize();
        Clear(EmptyJobQueueEntry);
        MonitoredCountBefore := MonitoredJQEntry.Count();

        // [When] AddJobQueueToMonitored is invoked with a null-GUID record
        if AddJQToMonitored.Run(EmptyJobQueueEntry) then
            Error('Expected AddJobQueueToMonitored to fail for a null-GUID JQ entry, but it succeeded.');

        // [Then] No monitored row was inserted — the codeunit errored at its IsNullGuid guard before any DB write
        _Assert.AreEqual(MonitoredCountBefore, MonitoredJQEntry.Count(),
            'Expected the monitored job queue count to be unchanged after a rejected null-GUID AddJobQueueToMonitored call.');
    end;

    [Test]
    procedure AddJobQueueToMonitored_NPProtected_OmitsManagedByAppRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        // [Scenario] Protected jobs (NP-owned, immutable from the GUI) are still added to monitored but the
        //            Managed-By-App row is intentionally skipped — that table tracks customer-managed jobs only
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, true);

        // [When] AddJobQueueToMonitored is invoked for the protected JQE
        RunAddJobQueueToMonitored(JobQueueEntry);

        // [Then] The monitored row is created normally
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Expected a monitored entry to be inserted even for an NP-protected JQ entry.');

        // [Then] But no Managed-By-App row is created (protected guard in AssignJobQueueEntryToManagedAndMonitored)
        _Assert.IsFalse(ManagedByApp.Get(JobQueueEntry.ID), 'Expected no Managed-By-App row to be inserted for an NP-protected JQ entry.');
    end;

    #endregion

    #region [RefreshJobQueueEntry]

    [Test]
    procedure RefreshMonitored_ExistingJQEntry_SetsLastRefreshStatusToSuccess()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
    begin
        // [Scenario] When a monitored row points at a JQE that still exists, the refresher updates it in place
        //            and sets Last Refresh Status = Success
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);
        FindMonitoredEntry(JobQueueEntry.ID, MonitoredJQEntry);
        MonitoredJQEntry."Last Refresh Status" := MonitoredJQEntry."Last Refresh Status"::Error;
        MonitoredJQEntry.Modify();
        Commit();

        // [When] The refresher is invoked for this monitored row
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then
            Error('Refresh should succeed for an existing JQE. Error: %1', GetLastErrorText());

        // [Then] Last Refresh Status is reset to Success and the JQE ID still resolves
        MonitoredJQEntry.Find();
        MonitoredJQEntry.TestField("Last Refresh Status", MonitoredJQEntry."Last Refresh Status"::Success);
        _Assert.IsTrue(JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID"), 'Expected the existing JQ entry to still be resolvable after refresh.');
    end;

    [Test]
    procedure RefreshMonitored_MissingJQE_CreateMissingDisabled_FailsAndLeavesStateUntouched()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ParameterStringProbe: Record "Job Queue Entry";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        OldJobQueueEntryId: Guid;
        MonitoredParameterString: Text[250];
    begin
        // [Scenario] When a monitored row references a JQE that has been deleted AND custom-job re-creation is
        //            disabled (default), the refresher refuses to invent a new JQE. We assert by checking state
        //            invariants — the monitored row still points at the deleted GUID, no replacement JQE was
        //            created — rather than matching English fragments of the production error label (which is
        //            translatable and would flip false on a non-en-US language layer).
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);
        FindMonitoredEntry(JobQueueEntry.ID, MonitoredJQEntry);
        OldJobQueueEntryId := JobQueueEntry.ID;
        MonitoredParameterString := MonitoredJQEntry."Parameter String";

        // [Given] The underlying JQE is deleted, leaving the monitored row pointing at a missing ID
        DeleteJobQueueEntry(JobQueueEntry);

        // [When] The refresher is invoked, with no subscriber opting into create-missing-custom-jobs
        if RefreshJobQueueEntry.Run(MonitoredJQEntry) then
            Error('Refresh should fail when the related JQE is missing and create-missing-custom-jobs is disabled, but it succeeded.');

        // [Then] The monitored row still references the (now-deleted) original JQE GUID — the failed Run rolled
        //         back any change it had staged. No replacement JQE has been inserted with the same parameter
        //         string either, so the refresher really did not get past its safety net.
        MonitoredJQEntry.Find();
        _Assert.AreEqual(OldJobQueueEntryId, MonitoredJQEntry."Job Queue Entry ID",
            'Expected the monitored row to still reference the deleted JQE GUID — a failed refresh must not rewrite the field.');
        _Assert.IsFalse(JobQueueEntry.Get(OldJobQueueEntryId),
            'Expected the original JQE to still be absent after a failed refresh.');
        ParameterStringProbe.SetRange("Parameter String", MonitoredParameterString);
        _Assert.IsTrue(ParameterStringProbe.IsEmpty(),
            'Expected no JQ entry to be created under the monitored row''s parameter string after a failed refresh.');
    end;

    [Test]
    procedure RefreshMonitored_MissingJQE_CreateMissingEnabled_RecreatesAndSucceeds()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        RefreshedJobQueueEntry: Record "Job Queue Entry";
        OldJobQueueEntryId: Guid;
    begin
        // [Scenario] When a PTE subscribes to OnRefreshserCheckIfCreateMissingCustomJobs and opts in, the refresher
        //            DOES recreate a missing custom JQE — verifies the opt-in path covered by setup field's hook
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);
        FindMonitoredEntry(JobQueueEntry.ID, MonitoredJQEntry);
        OldJobQueueEntryId := JobQueueEntry.ID;
        DeleteJobQueueEntry(JobQueueEntry);

        // [When] The refresher runs with the create-missing opt-in subscriber bound
        BindSubscription(_CreateMissingHelper);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(_CreateMissingHelper);
            Error('Refresh with create-missing enabled should succeed for a missing JQE. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(_CreateMissingHelper);

        // [Then] The monitored row is now pointing at a freshly inserted JQ entry (new GUID) and marked Success
        MonitoredJQEntry.Find();
        MonitoredJQEntry.TestField("Last Refresh Status", MonitoredJQEntry."Last Refresh Status"::Success);
        _Assert.IsFalse(IsNullGuid(MonitoredJQEntry."Job Queue Entry ID"), 'Expected the monitored entry to reference a re-created JQ entry after a successful refresh.');
        _Assert.AreNotEqual(OldJobQueueEntryId, MonitoredJQEntry."Job Queue Entry ID", 'Expected the recreated JQ entry to have a new GUID, different from the deleted one.');
        _Assert.IsTrue(RefreshedJobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID"), 'Expected the re-created JQ entry to be persisted in the database.');
    end;

    [Test]
    procedure RefreshMonitored_OneExistingOneMissing_CreateMissingEnabled_BothEndUpRefreshed()
    var
        ExistingJobQueueEntry: Record "Job Queue Entry";
        MissingJobQueueEntry: Record "Job Queue Entry";
        MonitoredExisting: Record "NPR Monitored Job Queue Entry";
        MonitoredMissing: Record "NPR Monitored Job Queue Entry";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        ResolvedJobQueueEntry: Record "Job Queue Entry";
        MissingOldId: Guid;
    begin
        // [Scenario] The headline mixed-state case the user asked for: two monitored entries — one still backed
        //            by a live JQE, one pointing at a deleted JQE — both end up refreshed to Success when the
        //            create-missing-custom-jobs opt-in is active
        Initialize();

        // [Given] Two monitored entries: one with a live JQE, one whose JQE will be deleted
        CreateRecurringJQEntry(ExistingJobQueueEntry, false);
        RunAddJobQueueToMonitored(ExistingJobQueueEntry);
        FindMonitoredEntry(ExistingJobQueueEntry.ID, MonitoredExisting);

        CreateRecurringJQEntry(MissingJobQueueEntry, false);
        RunAddJobQueueToMonitored(MissingJobQueueEntry);
        FindMonitoredEntry(MissingJobQueueEntry.ID, MonitoredMissing);
        MissingOldId := MissingJobQueueEntry.ID;
        DeleteJobQueueEntry(MissingJobQueueEntry);

        // [When] Each monitored row is refreshed under the opt-in
        BindSubscription(_CreateMissingHelper);
        if not RefreshJobQueueEntry.Run(MonitoredExisting) then begin
            UnbindSubscription(_CreateMissingHelper);
            Error('Refresh of the existing-JQE monitored row should not error. Error: %1', GetLastErrorText());
        end;
        if not RefreshJobQueueEntry.Run(MonitoredMissing) then begin
            UnbindSubscription(_CreateMissingHelper);
            Error('Refresh of the missing-JQE monitored row should not error with create-missing enabled. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(_CreateMissingHelper);

        // [Then] Both end up Success
        MonitoredExisting.Find();
        MonitoredExisting.TestField("Last Refresh Status", MonitoredExisting."Last Refresh Status"::Success);
        _Assert.IsTrue(ResolvedJobQueueEntry.Get(MonitoredExisting."Job Queue Entry ID"),
            'Existing-side: monitored row should still resolve to a live JQ entry after refresh.');

        MonitoredMissing.Find();
        MonitoredMissing.TestField("Last Refresh Status", MonitoredMissing."Last Refresh Status"::Success);
        _Assert.AreNotEqual(MissingOldId, MonitoredMissing."Job Queue Entry ID",
            'Missing-side: monitored row should now reference a re-created JQ entry, not the deleted GUID.');
        _Assert.IsTrue(ResolvedJobQueueEntry.Get(MonitoredMissing."Job Queue Entry ID"),
            'Missing-side: the recreated JQ entry should be persisted in the database.');
    end;

    #endregion

    #region [Lifecycle]

    [Test]
    procedure MonitoredJQEntry_OnDelete_AlsoDeletesManagedByAppRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        // [Scenario] The Monitored Job Queue Entry's OnDelete trigger cleans up the corresponding Managed-By-App
        //            row — the two tables are kept in sync to avoid orphaned bookkeeping when a customer removes
        //            an entry from the monitored list
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'Precondition: Managed-By-App row should exist before deleting the monitored row.');

        // [When] The monitored row is deleted (Delete(true) → fires OnDelete trigger)
        FindMonitoredEntry(JobQueueEntry.ID, MonitoredJQEntry);
        MonitoredJQEntry.Delete(true);

        // [Then] The companion Managed-By-App row is gone
        _Assert.IsFalse(ManagedByApp.Get(JobQueueEntry.ID), 'Managed-By-App row should be removed when its monitored entry is deleted.');
    end;

    [Test]
    procedure CancelNpManagedJob_RemovesAssociatedMonitoredEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        // [Scenario] CancelNpManagedJob is the public way to retract a JQ entry our app is managing — it must
        //            both cancel the JQE on the platform side and strip its monitored row, otherwise the next
        //            refresh cycle would silently recreate the very job the caller just cancelled
        Initialize();
        CreateRecurringJQEntry(JobQueueEntry, false);
        RunAddJobQueueToMonitored(JobQueueEntry);
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.IsFalse(MonitoredJQEntry.IsEmpty(), 'Precondition: a monitored entry should exist before CancelNpManagedJob.');

        // [When] The job is cancelled via the public CancelNpManagedJob entry point
        JobQueueMgt.CancelNpManagedJob(JobQueueEntry);

        // [Then] The monitored entry has been removed
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.IsTrue(MonitoredJQEntry.IsEmpty(), 'Monitored entry should be removed after CancelNpManagedJob.');
    end;

    #endregion

    #region [Setup]

    local procedure Initialize()
    begin
        // Why we Commit here, and why every fixture helper that touches the DB commits before returning:
        //
        // The codeunits under test (AddJobQueueToMonitored / RefreshJobQueueEntry) declare TableNo and are
        // invoked via Codeunit.Run. AL semantics forbid calling Codeunit.Run from a procedure that has
        // already updated the database — the platform surfaces this as the generic "An error occurred and
        // the transaction is stopped" message, which is exactly what these tests hit before the fix.
        //
        // Each helper that writes (CreateRecurringJQEntry, DeleteJobQueueEntry, this Initialize, and any
        // inline Modify in a [Test] body) therefore ends with Commit() so the next Codeunit.Run starts on
        // a clean outer transaction. As a consequence, test data persists in the DB across test runs; we
        // compensate by sweeping any rows owned by this codeunit (Parameter String starts with the test
        // prefix) at the top of every Initialize call.
        //
        // Setup state — important: we DO NOT mutate "NPR Job Queue Refresh Setup" here. Our test JQEs use
        // the InitRecurringJobQueueEntry overload with Starting Time = 0T / Ending Time = 0T, so the path
        // through ChangeJobTimeZoneToWebserviceTimezone exits early and never reaches the
        // TestField("Default Job Time Zone") branch that would otherwise demand External-Refresher-off.
        // That keeps the tenant's persisted setup untouched — a committed mutation would have leaked
        // beyond the test suite on any shared dev/CI tenant.
        CleanupTestArtifacts();
        Commit();
    end;

    local procedure CleanupTestArtifacts()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        // Cascade-aware cleanup, scoped strictly to rows we own (Parameter String starts with the test prefix):
        //  - DeleteAll(true) on monitored fires MonitoredJQEntry.OnDelete, which removes the companion
        //    Managed-By-App row keyed by the monitored entry's "Job Queue Entry ID".
        //  - DeleteAll(true) on JQE fires the JobQueueEntry table extension's OnDelete, which also removes
        //    the matching Managed-By-App row.
        //
        // We deliberately do NOT sweep tenant-wide for orphan Managed-By-App rows. A broad sweep would reach
        // outside this fixture's blast radius and silently delete legitimate orphans created by unrelated code
        // (other tests, upgrade codeunits, manual cleanup). The cascading deletes above are enough to keep this
        // fixture's own data from accumulating; anything else is the tenant's problem to resolve.
        MonitoredJQEntry.SetFilter("Parameter String", _TestParameterPrefix + '*');
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);

        JobQueueEntry.SetFilter("Parameter String", _TestParameterPrefix + '*');
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;

    #endregion

    #region [Fixture helpers]

    local procedure CreateRecurringJQEntry(var JobQueueEntry: Record "Job Queue Entry"; NPProtected: Boolean)
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        UniqueParam: Text[250];
    begin
        // Use a unique parameter string per JQE so JQEntryExists during refresh never accidentally matches a
        // pre-existing JQ entry on the host tenant. The shared prefix lets CleanupTestArtifacts find them.
        //
        // Object ID to Run points at the manual-bind helper codeunit rather than this [Test] codeunit itself.
        // On tenants where the platform job-queue scheduler is active (some CI configurations are), a JQE
        // inserted by InitRecurringJobQueueEntry can fire between Insert and the test's Delete/Cancel, re-
        // entering its target codeunit as a non-test execution. The helper has EventSubscriberInstance =
        // Manual and no OnRun trigger, so a scheduler-driven invocation is a true no-op.
        UniqueParam := CopyStr(_TestParameterPrefix + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 250);

        if NPProtected then
            JobQueueMgt.SetProtected(true);

        JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR JQ Refresher Test Helper",
            UniqueParam,
            UniqueParam,
            CurrentDateTime() + 60000,
            60,
            '',
            JobQueueEntry);
        Commit();
    end;

    local procedure RunAddJobQueueToMonitored(var JobQueueEntry: Record "Job Queue Entry")
    var
        AddJQToMonitored: Codeunit "NPR Add Job Queue To Monitored";
    begin
        if not AddJQToMonitored.Run(JobQueueEntry) then
            Error('AddJobQueueToMonitored failed: %1', GetLastErrorText());
    end;

    local procedure DeleteJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        // Delete(true) so the JobQueueEntry table extension's OnDelete cascades to the matching
        // Managed-By-App row. Without the cascade, the missing-JQE refresher tests would leave an
        // orphan Managed-By-App row keyed by the now-deleted GUID, and CleanupTestArtifacts could
        // never walk back to it from the JQE side.
        JobQueueEntry.Delete(true);
        Commit();
    end;

    local procedure FindMonitoredEntry(JobQueueEntryID: Guid; var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        // Clear the filter once we've located the row. If we left it in place, a subsequent Record.Find() in the
        // caller would re-apply the SetRange on "Job Queue Entry ID" — and tests #7/#8 explicitly *change* that
        // field on the monitored row when the refresher recreates a missing JQE. The stale filter then refuses
        // to match the now-modified row, and Find errors with "The Monitored Job does not exist. Entry No.='N'".
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntryID);
        MonitoredJQEntry.FindFirst();
        MonitoredJQEntry.SetRange("Job Queue Entry ID");
    end;

    #endregion
}
