#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
codeunit 85628 "NPR Inv. Items Changed JQ Test"
{
    // [FEATURE] Inventory items changed job: CheckAndNotify announces Item and item change rows inside (mark, boundary], and the job is a monitored, app-managed job queue entry that the refresher recreates when it goes missing

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
        _BoundarySeam: Codeunit "NPR Spfy RowVer Boundary Seam";
        _BoundarySeamBound: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemModifiedInsideWindowNotifiesAndMovesMarkToBoundary()
    var
        ItemRowVersion: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] An Item row between the mark and the boundary is announced once and the mark moves to the boundary.
        // [GIVEN] An item modified at R and the mark at R - 1
        Initialize();
        ItemRowVersion := ChangeItem(_LibraryInventory.CreateItemNo());
        SetMark(ItemRowVersion - 1);

        // [WHEN] The job runs with the boundary at R
        Notified := CheckAndNotifyAt(ItemRowVersion);

        // [THEN] It notifies, the mark is R, and the boundary was read once
        _Assert.IsTrue(Notified, 'An Item row inside (mark, boundary] must be announced.');
        _Assert.AreEqual(ItemRowVersion, GetMark(), 'The mark must move to the boundary.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmptyWindowDoesNotNotifyOrWriteTheMark()
    var
        Mark: BigInteger;
        Boundary: BigInteger;
        TrackerRowVersion: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] No Item row and no item change row between the mark and the boundary: nothing is announced and the tracker row is not written.
        // [GIVEN] The mark at the last used row version, and a boundary above it that covers only the tracker row's own write
        Initialize();
        Mark := Database.LastUsedRowVersion();
        SetMark(Mark);
        Boundary := Database.LastUsedRowVersion();
        _Assert.IsTrue(Boundary > Mark, 'Precondition: the boundary must lie above the mark.');
        TrackerRowVersion := GetTrackerRowVersion();

        // [WHEN] The job runs
        Notified := CheckAndNotifyAt(Boundary);

        // [THEN] It does not notify and leaves the tracker row untouched
        _Assert.IsFalse(Notified, 'An empty window must not be announced.');
        _Assert.AreEqual(Mark, GetMark(), 'An empty window must not move the mark.');
        _Assert.AreEqual(TrackerRowVersion, GetTrackerRowVersion(), 'An empty window must not write the tracker row.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BoundaryAtMarkDoesNotNotify()
    var
        Mark: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] A boundary that is not above the mark announces nothing, even when an Item row lies above the mark.
        // [GIVEN] An item modified at R and the mark at R - 1
        Initialize();
        Mark := ChangeItem(_LibraryInventory.CreateItemNo()) - 1;
        SetMark(Mark);

        // [WHEN] The job runs with the boundary at the mark
        Notified := CheckAndNotifyAt(Mark);

        // [THEN] It does not notify and the mark stays
        _Assert.IsFalse(Notified, 'A boundary at the mark must not be announced.');
        _Assert.AreEqual(Mark, GetMark(), 'A boundary at the mark must not move the mark.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemRowAtTheMarkIsOutsideTheWindow()
    var
        Mark: BigInteger;
        Boundary: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] The window excludes its lower bound: an Item row exactly at the mark was already announced.
        // [GIVEN] An item modified at R, the mark at R, and a boundary above R that covers only the tracker row's own write
        Initialize();
        Mark := ChangeItem(_LibraryInventory.CreateItemNo());
        SetMark(Mark);
        Boundary := Database.LastUsedRowVersion();
        _Assert.IsTrue(Boundary > Mark, 'Precondition: the boundary must lie above the mark.');

        // [WHEN] The job runs
        Notified := CheckAndNotifyAt(Boundary);

        // [THEN] It does not notify and the mark stays
        _Assert.IsFalse(Notified, 'An Item row at the mark must not be announced again.');
        _Assert.AreEqual(Mark, GetMark(), 'An Item row at the mark must not move the mark.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeRowAtTheMarkIsOutsideTheWindow()
    var
        Mark: BigInteger;
        Boundary: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] The window excludes its lower bound: an item change row exactly at the mark was already announced.
        // [GIVEN] An item marked changed at C, the mark at C, and a boundary above C that covers only the tracker row's own write
        Initialize();
        Mark := MarkChanged(_LibraryInventory.CreateItemNo());
        SetMark(Mark);
        Boundary := Database.LastUsedRowVersion();
        _Assert.IsTrue(Boundary > Mark, 'Precondition: the boundary must lie above the mark.');

        // [WHEN] The job runs
        Notified := CheckAndNotifyAt(Boundary);

        // [THEN] It does not notify and the mark stays
        _Assert.IsFalse(Notified, 'An item change row at the mark must not be announced again.');
        _Assert.AreEqual(Mark, GetMark(), 'An item change row at the mark must not move the mark.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeAboveBoundaryIsAnnouncedOnlyAfterTheBoundaryPassesIt()
    var
        ItemX: Code[20];
        ItemY: Code[20];
        Mark: BigInteger;
        RowVersionX: BigInteger;
        RowVersionY: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] The job does not announce rows above the boundary, which may still be uncommitted in production, and does not move the mark past them. When the boundary passes X while Y lies above it, the mark moves to the boundary, not to Y. A later run announces Y once.
        // [GIVEN] The mark below two item modifications X at Rx and Y at Ry
        Initialize();
        ItemX := _LibraryInventory.CreateItemNo();
        ItemY := _LibraryInventory.CreateItemNo();
        Mark := Database.LastUsedRowVersion();
        SetMark(Mark);
        RowVersionX := ChangeItem(ItemX);
        RowVersionY := ChangeItem(ItemY);
        _Assert.IsTrue(RowVersionX - 1 > Mark, 'Precondition: Rx - 1 must lie above the mark.');
        _Assert.IsTrue(RowVersionY > RowVersionX, 'Precondition: Y must be modified after X.');

        // [WHEN] The job runs with the boundary just below Rx
        Notified := CheckAndNotifyAt(RowVersionX - 1);

        // [THEN] It does not notify and the mark stays
        _Assert.IsFalse(Notified, 'Rows above the boundary must not be announced.');
        _Assert.AreEqual(Mark, GetMark(), 'Rows above the boundary must not move the mark.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs with the boundary at Rx, while Y at Ry lies above it
        Notified := CheckAndNotifyAt(RowVersionX);

        // [THEN] It notifies and the mark is Rx, not Ry
        _Assert.IsTrue(Notified, 'A row the boundary has passed must be announced.');
        _Assert.AreEqual(RowVersionX, GetMark(), 'The mark must move to the boundary, not to a newer row above it.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs with the boundary at Ry
        Notified := CheckAndNotifyAt(RowVersionY);

        // [THEN] It notifies and the mark is Ry
        _Assert.IsTrue(Notified, 'Rows the boundary has passed must be announced.');
        _Assert.AreEqual(RowVersionY, GetMark(), 'The mark must move to the boundary.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs again with the same boundary
        Notified := CheckAndNotifyAt(RowVersionY);

        // [THEN] It does not notify again
        _Assert.IsFalse(Notified, 'Announced rows must not be announced again.');
        _Assert.AreEqual(RowVersionY, GetMark(), 'A repeated run must not move the mark.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FirstRunWithoutMarkNotifiesAndStartsTheMarkAtTheBoundary()
    var
        ChangeTracker: Record "NPR Change Tracker";
        Boundary: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] Without a tracker row the job notifies once and creates the mark at the boundary.
        // [GIVEN] No tracker row for Inventory Items Changed
        Initialize();
        if ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item) then
            ChangeTracker.Delete();
        Boundary := Database.LastUsedRowVersion();

        // [WHEN] The job runs
        Notified := CheckAndNotifyAt(Boundary);

        // [THEN] It notifies, the tracker row exists with the mark at the boundary, and the boundary was read once
        _Assert.IsTrue(Notified, 'The first run must notify.');
        _Assert.IsTrue(ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item), 'The first run must create the tracker row.');
        _Assert.AreEqual(Boundary, ChangeTracker."Last Row Version", 'The first run must start the mark at the boundary.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs again with the same boundary
        Notified := CheckAndNotifyAt(Boundary);

        // [THEN] It does not notify again
        _Assert.IsFalse(Notified, 'A second run with the same boundary must not notify.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeRowAloneIsAnnounced()
    var
        ItemNo: Code[20];
        Mark: BigInteger;
        ChangeRowVersion: BigInteger;
        Notified: Boolean;
    begin
        // [SCENARIO] An item change row inside the window is announced although the item's Item row lies at or below the mark.
        // [GIVEN] An item whose Item row is at or below the mark, then marked changed at C
        Initialize();
        ItemNo := _LibraryInventory.CreateItemNo();
        Mark := Database.LastUsedRowVersion();
        SetMark(Mark);
        ChangeRowVersion := MarkChanged(ItemNo);
        _Assert.IsTrue(GetItemRowVersion(ItemNo) <= Mark, 'Precondition: the Item row must lie at or below the mark.');
        _Assert.IsTrue(ChangeRowVersion - 1 > Mark, 'Precondition: C - 1 must lie above the mark.');

        // [WHEN] The job runs with the boundary just below C
        Notified := CheckAndNotifyAt(ChangeRowVersion - 1);

        // [THEN] It does not notify and the mark stays
        _Assert.IsFalse(Notified, 'A change row above the boundary must not be announced.');
        _Assert.AreEqual(Mark, GetMark(), 'A change row above the boundary must not move the mark.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs with the boundary at C
        Notified := CheckAndNotifyAt(ChangeRowVersion);

        // [THEN] It notifies and the mark is C
        _Assert.IsTrue(Notified, 'A change row inside the window must be announced.');
        _Assert.AreEqual(ChangeRowVersion, GetMark(), 'The mark must move to the boundary.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');

        // [WHEN] The job runs again with the same boundary
        Notified := CheckAndNotifyAt(ChangeRowVersion);

        // [THEN] It does not notify again
        _Assert.IsFalse(Notified, 'An announced change row must not be announced again.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'The boundary must be read exactly once per run.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetupJobQueueCreatesExactlyOneMonitoredJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        DeletedJobQueueEntryId: Guid;
    begin
        // [SCENARIO] Setting up the job creates one non-protected, monitored, app-managed entry; repeating it adds nothing, and after the entry is deleted the orphaned monitored row is replaced, not duplicated.
        // [GIVEN] No job queue entry, monitored row or managed-by-app row for the job
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);

        // [WHEN] The job queue is set up
        InvItemsChangedJQ.SetupJobQueue();

        // [THEN] Exactly one entry exists with the job's settings
        _Assert.AreEqual(1, CountJobs(), 'Setting up the job must create exactly one job queue entry.');
        FilterJobs(JobQueueEntry);
        JobQueueEntry.FindFirst();
        _Assert.IsFalse(JobQueueEntry."NPR NP Protected Job", 'The job must not be NP protected, or the refresher never monitors it.');
        _Assert.IsTrue(JobQueueEntry."NPR Auto-Resched. after Error", 'The job must reschedule itself after an error.');
        _Assert.AreEqual(30, JobQueueEntry."NPR Auto-Resched. Delay (sec.)", 'The job must reschedule 30 seconds after an error.');
        _Assert.IsTrue(JobQueueEntry."Recurring Job", 'The job must be recurring.');
        _Assert.AreEqual(1, JobQueueEntry."No. of Minutes between Runs", 'The job must run every minute.');
        _Assert.IsTrue(JobQueueEntry."Job Timeout" = 1 * 60 * 60 * 1000, 'The job must time out after one hour.');

        // [THEN] It is monitored and managed by the app
        _Assert.AreEqual(1, CountMonitoredRows(), 'Setting up the job must create exactly one monitored row.');
        FilterMonitoredRows(MonitoredJQEntry);
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the job queue entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'The job queue entry must have a managed-by-app row.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'The managed-by-app row must be flagged Managed by App.');

        // [WHEN] The job queue is set up again
        InvItemsChangedJQ.SetupJobQueue();

        // [THEN] Still one entry and one monitored row exist
        _Assert.AreEqual(1, CountJobs(), 'Setting up the job again must not add a second job queue entry.');
        _Assert.AreEqual(1, CountMonitoredRows(), 'Setting up the job again must not add a second monitored row.');

        // [GIVEN] The entry is deleted the way support deletes a stuck job, which leaves its monitored row orphaned
        DeletedJobQueueEntryId := JobQueueEntry.ID;
        DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(1, CountMonitoredRows(), 'Precondition: the monitored row must outlive the deleted job queue entry.');

        // [WHEN] The job queue is set up again
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);

        // [THEN] Exactly one monitored row exists and it points at the new entry
        _Assert.AreEqual(1, CountMonitoredRows(), 'The orphaned monitored row must be replaced, not duplicated.');
        FilterJobs(RecreatedJobQueueEntry);
        _Assert.IsTrue(RecreatedJobQueueEntry.FindFirst(), 'Setting up the job must recreate the job queue entry.');
        _Assert.AreNotEqual(DeletedJobQueueEntryId, RecreatedJobQueueEntry.ID, 'The recreated entry must have a new ID.');
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the new job queue entry, not the deleted one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherRegistersTheJobOnce()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
    begin
        // [SCENARIO] The job queue refresher registers the job as one monitored row, and a second refresh does not add another.
        // [GIVEN] No monitored row for the job, and a refresher that runs its subscribers
        Initialize();
        ClearJobQueueState();
        _Assert.AreEqual(0, CountMonitoredRows(), 'Precondition: no monitored row must exist for the job.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Exactly one monitored row exists for the job
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must register the job as exactly one monitored row.');

        // [WHEN] The refresher runs again
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Still one monitored row exists
        _Assert.AreEqual(1, CountMonitoredRows(), 'A second refresh must not add a second monitored row.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherKeepsTheAdminEditedMinutesBetweenRuns()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        EditedEntryNo: BigInteger;
    begin
        // [SCENARIO] An admin's "No. of Minutes between Runs" on the job's monitored row survives a refresher pass, and the refresher then applies it to the job queue entry.
        // [GIVEN] A set-up job whose monitored row an admin changed to run every 15 minutes
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: setting up the job must create its monitored row.');
        _Assert.AreEqual(1, MonitoredJQEntry."No. of Minutes between Runs", 'Precondition: the job must default to one minute, or 15 is not an edit.');
        MonitoredJQEntry."No. of Minutes between Runs" := 15;
        MonitoredJQEntry.Modify();
        EditedEntryNo := MonitoredJQEntry."Entry No.";
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] The same monitored row still runs every 15 minutes and points at the same entry
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must not add a second monitored row.');
        _Assert.IsTrue(MonitoredJQEntry.Get(EditedEntryNo), 'The refresher must keep the edited monitored row.');
        _Assert.AreEqual(15, MonitoredJQEntry."No. of Minutes between Runs", 'The refresher must not reset the admin-edited minutes between runs to the job default.');
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must still point at the same job queue entry.');
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The refresher refreshes the job queue entry from that row
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must update the job queue entry from the monitored row. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] The existing entry now runs every 15 minutes
        _Assert.AreEqual(1, CountJobs(), 'The refresher must keep exactly one job queue entry.');
        _Assert.IsTrue(JobQueueEntry.Find(), 'The refresher must update the existing job queue entry, not replace it.');
        _Assert.AreEqual(15, JobQueueEntry."No. of Minutes between Runs", 'The refresher must apply the admin-edited minutes between runs to the job queue entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateMissingCustomJQsOptsInForTheJob()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntry: Record "Job Queue Entry";
        OtherJobQueueEntry: Record "Job Queue Entry";
    begin
        // [SCENARIO] The refresher may recreate a missing entry of the job, because the job's subscriber opts in.
        // [GIVEN] An unsaved job queue entry for the job, and one for another codeunit that nothing opts in for
        Initialize();
        BuildJobQueueEntryFor(Codeunit::"NPR Inv. Items Changed JQ", JobQueueEntry);
        BuildJobQueueEntryFor(Codeunit::"NPR Inv. Items Changed JQ Test", OtherJobQueueEntry);
        _Assert.IsFalse(JobQueueRefreshSetup.CreateMissingCustomJQs(OtherJobQueueEntry), 'Precondition: the refresher must not recreate missing custom jobs by default, or the assertion below proves nothing.');

        // [WHEN] The refresher asks whether it may recreate the job's missing entry
        // [THEN] It may
        _Assert.IsTrue(JobQueueRefreshSetup.CreateMissingCustomJQs(JobQueueEntry), 'The refresher must be allowed to recreate a missing entry of the job.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherPhase2RecreatesAMissingJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        DeletedJobQueueEntryId: Guid;
    begin
        // [SCENARIO] The refresher recreates the job's entry from its monitored row after the entry was deleted.
        // [GIVEN] A set-up job whose entry is then deleted, leaving a monitored row that points at no entry
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        DeletedJobQueueEntryId := JobQueueEntry.ID;
        DeleteJobQueueEntry(JobQueueEntry);
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: the monitored row must outlive the deleted job queue entry.');
        _Assert.AreEqual(DeletedJobQueueEntryId, MonitoredJQEntry."Job Queue Entry ID", 'Precondition: the monitored row must point at the deleted entry.');
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The refresher refreshes the monitored row
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must recreate the missing job queue entry. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] Exactly one entry exists for the job, held off the scheduler, managed by the app
        _Assert.AreEqual(1, CountJobs(), 'The refresher must recreate exactly one job queue entry.');
        FilterJobs(RecreatedJobQueueEntry);
        RecreatedJobQueueEntry.FindFirst();
        _Assert.AreNotEqual(DeletedJobQueueEntryId, RecreatedJobQueueEntry.ID, 'The recreated entry must have a new ID.');
        _Assert.AreEqual(RecreatedJobQueueEntry.Status::"On Hold", RecreatedJobQueueEntry.Status, 'Precondition of this test: the hold must keep the recreated entry on hold.');
        _Assert.IsTrue(ManagedByApp.Get(RecreatedJobQueueEntry.ID), 'The recreated entry must have a managed-by-app row.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'The recreated entry must be flagged Managed by App.');

        // [THEN] The monitored row points at the recreated entry
        MonitoredJQEntry.Find();
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the recreated entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherRecreatesADeletedJobFromTheAdminEditedMonitoredRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        DeletedJobQueueEntryId: Guid;
        EditedEntryNo: BigInteger;
        NotifProfileCode: Code[20];
    begin
        // [SCENARIO] After support deletes the job's entry, a refresher pass keeps the admin-edited monitored row, and the refresher recreates the entry from that row's settings.
        // [GIVEN] A set-up job whose monitored row an admin changed to 15 minutes with a notification profile, and whose entry is then deleted
        Initialize();
        ClearJobQueueState();
        NotifProfileCode := EnsureNotifProfile();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: setting up the job must create its monitored row.');
        MonitoredJQEntry."No. of Minutes between Runs" := 15;
        MonitoredJQEntry."Notif. Profile on Error" := NotifProfileCode;
        MonitoredJQEntry.Modify();
        EditedEntryNo := MonitoredJQEntry."Entry No.";
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        DeletedJobQueueEntryId := JobQueueEntry.ID;
        DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(0, CountJobs(), 'Precondition: the job queue entry must be gone.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] The edited monitored row is kept unchanged and is the only one
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must not add a second monitored row.');
        _Assert.IsTrue(MonitoredJQEntry.Get(EditedEntryNo), 'The refresher must keep the edited monitored row of a deleted entry, not replace it with a default one.');
        _Assert.AreEqual(15, MonitoredJQEntry."No. of Minutes between Runs", 'The refresher must keep the admin-edited minutes between runs.');
        _Assert.AreEqual(NotifProfileCode, MonitoredJQEntry."Notif. Profile on Error", 'The refresher must keep the admin-set notification profile.');
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The refresher refreshes that monitored row
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must recreate the missing job queue entry. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] Exactly one entry exists, held off the scheduler, carrying the edited settings, and the row points at it
        _Assert.AreEqual(1, CountJobs(), 'The refresher must recreate exactly one job queue entry.');
        FilterJobs(RecreatedJobQueueEntry);
        RecreatedJobQueueEntry.FindFirst();
        _Assert.AreNotEqual(DeletedJobQueueEntryId, RecreatedJobQueueEntry.ID, 'The recreated entry must have a new ID.');
        _Assert.AreEqual(RecreatedJobQueueEntry.Status::"On Hold", RecreatedJobQueueEntry.Status, 'Precondition of this test: the hold must keep the recreated entry on hold.');
        _Assert.AreEqual(15, RecreatedJobQueueEntry."No. of Minutes between Runs", 'The recreated entry must run at the admin-edited interval.');
        _Assert.AreEqual(NotifProfileCode, RecreatedJobQueueEntry."NPR Notif. Profile on Error", 'The recreated entry must carry the admin-set notification profile.');
        MonitoredJQEntry.Find();
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the recreated entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecreateMonitoredJobsLeavesOneRowOfTheLiveEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
    begin
        // [SCENARIO] Recreate Monitored Jobs leaves one monitored row, and that row carries the ID of the live entry. A refresher pass keeps the row.
        // [GIVEN] A set-up job
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] Recreate Monitored Jobs runs
        BindSubscription(JQHold);
        MonitoredJobQueueMgt.RecreateMonitoredJobQueueEntries();
        UnbindSubscription(JQHold);

        // [THEN] One monitored row is left, it carries the ID of the live entry, and the entry is managed by the app
        _Assert.AreEqual(1, CountMonitoredRows(), 'Recreate Monitored Jobs must leave exactly one monitored row.');
        FilterMonitoredRows(MonitoredJQEntry);
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must carry the ID of the live entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'The live entry must have a managed-by-app row.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'The managed-by-app row must be flagged Managed by App.');
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Still one monitored row exists and it carries the ID of the live entry
        _Assert.AreEqual(1, CountMonitoredRows(), 'A refresher pass must not add a second monitored row.');
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'A refresher pass must keep the monitored row of the live entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherRecreatesOneEntryWhenTheEntryIsDeletedAfterRecreateMonitoredJobs()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        KeptEntryNo: BigInteger;
    begin
        // [SCENARIO] Recreate Monitored Jobs leaves one row of the entry. After the entry is deleted, a refresher pass keeps that row, and the refresher recreates exactly one entry from it.
        // [GIVEN] A set-up job, then Recreate Monitored Jobs, which leaves one row of the entry
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        AssertRefreshPreconditions();
        Commit();
        BindSubscription(JQHold);
        MonitoredJobQueueMgt.RecreateMonitoredJobQueueEntries();
        UnbindSubscription(JQHold);
        _Assert.AreEqual(1, CountMonitoredRows(), 'Precondition: Recreate Monitored Jobs must leave exactly one monitored row.');
        FilterMonitoredRows(MonitoredJQEntry);
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'Precondition: the monitored row must carry the ID of the entry.');
        KeptEntryNo := MonitoredJQEntry."Entry No.";

        // [GIVEN] The entry is deleted the way support deletes a stuck job
        DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(0, CountJobs(), 'Precondition: the job queue entry must be gone.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Only the row that carried the entry ID is left
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must keep exactly one monitored row when no row has a live entry.');
        _Assert.IsTrue(MonitoredJQEntry.Get(KeptEntryNo), 'The refresher must keep the monitored row that carried the entry ID.');
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The refresher refreshes that monitored row
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must recreate the missing job queue entry. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] Exactly one entry exists and the row points at it
        _Assert.AreEqual(1, CountJobs(), 'The refresher must recreate exactly one job queue entry.');
        FilterJobs(RecreatedJobQueueEntry);
        RecreatedJobQueueEntry.FindFirst();
        MonitoredJQEntry.Find();
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the recreated entry.');
        Commit();

        // [WHEN] The refresher runs its subscribers again
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Still one monitored row exists
        _Assert.AreEqual(1, CountMonitoredRows(), 'A later refresh must not leave a second monitored row.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecreateMonitoredJobsKeepsTheAdminEditedMinutesBetweenRuns()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
    begin
        // [SCENARIO] Recreate Monitored Jobs keeps the admin-edited "No. of Minutes between Runs" on the job's monitored row. A later refresher pass keeps the job queue entry at that interval.
        // [GIVEN] A set-up job whose monitored row an admin changed to run every 15 minutes, and whose entry the refresher updated from that row
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: setting up the job must create its monitored row.');
        _Assert.AreEqual(1, MonitoredJQEntry."No. of Minutes between Runs", 'Precondition: the job must default to one minute, or 15 is not an edit.');
        MonitoredJQEntry."No. of Minutes between Runs" := 15;
        MonitoredJQEntry.Modify();
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must update the job queue entry from the monitored row. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);
        _Assert.IsTrue(JobQueueEntry.Find(), 'Precondition: the refresher must update the existing job queue entry.');
        _Assert.AreEqual(15, JobQueueEntry."No. of Minutes between Runs", 'Precondition: the job queue entry must run every 15 minutes before Recreate Monitored Jobs runs.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] Recreate Monitored Jobs runs
        BindSubscription(JQHold);
        MonitoredJobQueueMgt.RecreateMonitoredJobQueueEntries();
        UnbindSubscription(JQHold);

        // [THEN] One monitored row is left, it carries the ID of the entry, and it still runs every 15 minutes
        _Assert.AreEqual(1, CountMonitoredRows(), 'Recreate Monitored Jobs must leave exactly one monitored row.');
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must carry the ID of the entry.');
        _Assert.AreEqual(15, MonitoredJQEntry."No. of Minutes between Runs", 'Recreate Monitored Jobs must keep the admin-edited minutes between runs.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers and then refreshes the job queue entry from the monitored row
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);
        MonitoredJQEntry.FindFirst();
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must update the job queue entry from the monitored row. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] The same entry still runs every 15 minutes and one monitored row exists
        _Assert.AreEqual(1, CountJobs(), 'The refresher must keep exactly one job queue entry.');
        _Assert.IsTrue(JobQueueEntry.Find(), 'The refresher must keep the existing job queue entry, not replace it.');
        _Assert.AreEqual(15, JobQueueEntry."No. of Minutes between Runs", 'The job queue entry must keep the admin-edited minutes between runs after Recreate Monitored Jobs.');
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must not add a second monitored row.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherKeepsTheRowThatCarriesTheEntryIdNextToABlankRow()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RecreatedJobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
        BlankEntryNo: BigInteger;
        IdEntryNo: BigInteger;
    begin
        // [SCENARIO] A row carries the deleted entry's ID, and an older blank row lies next to it. A refresher pass keeps only the row with the ID, and the refresher recreates exactly one entry from that row.
        // [GIVEN] A set-up job whose monitored row lost its entry ID, a newer row that carries the entry ID, and the entry then deleted
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: setting up the job must create its monitored row.');
        BlankEntryNo := MonitoredJQEntry."Entry No.";
        Clear(MonitoredJQEntry."Job Queue Entry ID");
        MonitoredJQEntry.Modify();
        MonitoredJobQueueMgt.AddMonitoredJobQueueEntry(JobQueueEntry);
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: a monitored row must carry the entry ID.');
        IdEntryNo := MonitoredJQEntry."Entry No.";
        MonitoredJQEntry.SetRange("Job Queue Entry ID");
        _Assert.AreEqual(2, CountMonitoredRows(), 'Precondition: a blank row and a row that carries the entry ID must exist.');
        _Assert.IsTrue(BlankEntryNo < IdEntryNo, 'Precondition: the blank row must be older than the row that carries the entry ID.');
        DeleteJobQueueEntry(JobQueueEntry);
        _Assert.AreEqual(0, CountJobs(), 'Precondition: the job queue entry must be gone.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] Only the row that carries the entry ID is left
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must keep exactly one monitored row.');
        _Assert.IsTrue(MonitoredJQEntry.Get(IdEntryNo), 'The refresher must keep the monitored row that carries the entry ID, not the blank row.');
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The refresher refreshes that monitored row
        BindSubscription(JQHold);
        if not RefreshJobQueueEntry.Run(MonitoredJQEntry) then begin
            UnbindSubscription(JQHold);
            Error('The refresher must recreate the missing job queue entry. Error: %1', GetLastErrorText());
        end;
        UnbindSubscription(JQHold);

        // [THEN] Exactly one entry exists and the row points at it
        _Assert.AreEqual(1, CountJobs(), 'The refresher must recreate exactly one job queue entry.');
        FilterJobs(RecreatedJobQueueEntry);
        RecreatedJobQueueEntry.FindFirst();
        MonitoredJQEntry.Find();
        _Assert.AreEqual(RecreatedJobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must point at the recreated entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RefresherRegistersTheExistingEntryAfterItsMonitoredRowIsDeleted()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JQHold: Codeunit "NPR Inv. Items Changed JQ Hold";
    begin
        // [SCENARIO] An admin deletes the job's monitored row while its entry still exists. A refresher pass registers that entry again as one monitored, app-managed row.
        // [GIVEN] A set-up job whose monitored row an admin deleted, while its entry still exists
        Initialize();
        ClearJobQueueState();
        BindSubscription(JQHold);
        InvItemsChangedJQ.SetupJobQueue();
        UnbindSubscription(JQHold);
        FilterJobs(JobQueueEntry);
        _Assert.IsTrue(JobQueueEntry.FindFirst(), 'Precondition: setting up the job must create its job queue entry.');
        FilterMonitoredRows(MonitoredJQEntry);
        _Assert.IsTrue(MonitoredJQEntry.FindFirst(), 'Precondition: setting up the job must create its monitored row.');
        MonitoredJQEntry.Delete(true);
        _Assert.AreEqual(0, CountMonitoredRows(), 'Precondition: the monitored row must be gone.');
        _Assert.IsFalse(ManagedByApp.Get(JobQueueEntry.ID), 'Precondition: deleting the monitored row must remove the managed-by-app row of the entry.');
        _Assert.AreEqual(1, CountJobs(), 'Precondition: the job queue entry must still exist.');
        AssertRefreshPreconditions();
        Commit();

        // [WHEN] The refresher runs its subscribers
        BindSubscription(JQHold);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        UnbindSubscription(JQHold);

        // [THEN] One monitored, app-managed row carries the ID of the existing entry
        _Assert.AreEqual(1, CountMonitoredRows(), 'The refresher must register the existing entry as exactly one monitored row.');
        MonitoredJQEntry.FindFirst();
        _Assert.AreEqual(JobQueueEntry.ID, MonitoredJQEntry."Job Queue Entry ID", 'The monitored row must carry the ID of the existing entry.');
        _Assert.IsTrue(ManagedByApp.Get(JobQueueEntry.ID), 'The existing entry must have a managed-by-app row again.');
        _Assert.IsTrue(ManagedByApp."Managed by App", 'The managed-by-app row must be flagged Managed by App.');
        _Assert.AreEqual(1, CountJobs(), 'The refresher must not create a second job queue entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JobRunAnnouncesAndMovesTheMark()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ItemRowVersion: BigInteger;
        Ran: Boolean;
    begin
        // [SCENARIO] A job queue run checks for changes: with a change inside the window it finishes without an error and moves the mark.
        // [GIVEN] An item modified at R, the mark at R - 1, and the boundary fixed at R
        Initialize();
        ItemRowVersion := ChangeItem(_LibraryInventory.CreateItemNo());
        SetMark(ItemRowVersion - 1);
        _BoundarySeam.SetFixedBoundary(ItemRowVersion);
        JobQueueEntry.Init();
        // Codeunit.Run cannot return a value inside a write transaction.
        Commit();

        // [WHEN] The job runs
        Ran := Codeunit.Run(Codeunit::"NPR Inv. Items Changed JQ", JobQueueEntry);

        // [THEN] It finishes without an error and the mark is R
        _Assert.IsTrue(Ran, 'The job must finish without an error.');
        _Assert.AreEqual(ItemRowVersion, GetMark(), 'The job must move the mark to the boundary.');
    end;

    local procedure Initialize()
    begin
        // Without the seam the open test transaction pins the real boundary below every fixture.
        if not _BoundarySeamBound then begin
            BindSubscription(_BoundarySeam);
            _BoundarySeamBound := true;
        end;
        _BoundarySeam.UseLastAllocatedBoundary();
    end;

    local procedure CheckAndNotifyAt(Boundary: BigInteger): Boolean
    var
        InvItemsChangedJQ: Codeunit "NPR Inv. Items Changed JQ";
    begin
        _BoundarySeam.SetFixedBoundary(Boundary);
        _BoundarySeam.ResetBoundaryReadCount();
        exit(InvItemsChangedJQ.CheckAndNotify());
    end;

    local procedure SetMark(Mark: BigInteger)
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        if not ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item) then begin
            ChangeTracker.Init();
            ChangeTracker."Integration Type" := "NPR Integration Type"::"Inventory Items Changed";
            ChangeTracker."Table No." := Database::Item;
            ChangeTracker.Insert();
        end;
        ChangeTracker."Last Row Version" := Mark;
        ChangeTracker.Modify();
    end;

    local procedure GetMark(): BigInteger
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item);
        exit(ChangeTracker."Last Row Version");
    end;

    local procedure GetTrackerRowVersion(): BigInteger
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item);
        exit(ChangeTracker.SystemRowVersion);
    end;

    // The second Get picks up any nested write a subscriber made to the item.
    local procedure ChangeItem(ItemNo: Code[20]): BigInteger
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Description := CopyStr(Format(CreateGuid()), 1, MaxStrLen(Item.Description));
        Item.Modify();
        exit(GetItemRowVersion(ItemNo));
    end;

    local procedure GetItemRowVersion(ItemNo: Code[20]): BigInteger
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        exit(Item.SystemRowVersion);
    end;

    local procedure MarkChanged(ItemNo: Code[20]): BigInteger
    var
        TempItemChange: Record "NPR Inventory Item Change" temporary;
    begin
        _ItemChangeMgt.AddItemNo(TempItemChange, ItemNo);
        _ItemChangeMgt.MarkItemsChanged(TempItemChange);
        exit(_ItemChangeMgt.GetChangeRowVersion(ItemNo));
    end;

    // Monitored rows go first: their OnDelete removes the managed-by-app rows of the entry IDs they point at,
    // and deleting each entry removes its own managed-by-app row.
    local procedure ClearJobQueueState()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        FilterMonitoredRows(MonitoredJQEntry);
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);

        FilterJobs(JobQueueEntry);
        while JobQueueEntry.FindFirst() do
            DeleteJobQueueEntry(JobQueueEntry);
    end;

    // Deletes the entry the way support deletes a stuck job. An In Process entry cannot be deleted.
    local procedure DeleteJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;

    // Not inserted: CreateMissingCustomJQs only reads the record it is given.
    local procedure BuildJobQueueEntryFor(CodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        Clear(JobQueueEntry);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
    end;

    local procedure EnsureNotifProfile(): Code[20]
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
    begin
        if not JQNotifProfile.Get('INVCHG-JQ-TEST') then begin
            JQNotifProfile.Init();
            JQNotifProfile.Code := 'INVCHG-JQ-TEST';
            JQNotifProfile.Insert();
        end;
        exit(JQNotifProfile.Code);
    end;

    // Fails before the refresh commits when RefreshNPRJobQueueList would error on its time zone check or skip the subscribers.
    local procedure AssertRefreshPreconditions()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if not JobQueueRefreshSetup.Get() then
            Clear(JobQueueRefreshSetup);
        _Assert.IsTrue((not JobQueueRefreshSetup."Use External JQ Refresher") or (JobQueueRefreshSetup."Default Job Time Zone" <> ''), 'Precondition: with "Use External JQ Refresher" on, "Default Job Time Zone" must be set, or RefreshNPRJobQueueList errors.');
        _Assert.IsFalse(JobQueueManagement.SkipUpdateNPManagedMonitoredJobs(), 'Precondition: SkipUpdateNPManagedMonitoredJobs must be false, or RefreshNPRJobQueueList skips the OnRefreshNPRJobQueueList subscribers.');
    end;

    local procedure CountMonitoredRows(): Integer
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        FilterMonitoredRows(MonitoredJQEntry);
        exit(MonitoredJQEntry.Count());
    end;

    local procedure FilterMonitoredRows(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Inv. Items Changed JQ");
    end;

    local procedure CountJobs(): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterJobs(JobQueueEntry);
        exit(JobQueueEntry.Count());
    end;

    local procedure FilterJobs(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Inv. Items Changed JQ");
    end;
}
#endif
