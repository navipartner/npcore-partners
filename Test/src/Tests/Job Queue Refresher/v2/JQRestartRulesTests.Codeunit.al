codeunit 85566 "NPR JQ Restart Rules Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _RefreshOverwriteWarnings: Integer;
        _TestParameterPrefix: Label 'NPR-JQR-RST-', Locked = true;
        _TestTransactionTok: Label 'NPR-JQR-RST refresh transaction', Locked = true;

    [Test]
    procedure NeedsRestart_ScheduledJobs_OnlyWhenTheTaskIsMissing()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        TaskId: Guid;
    begin
        TaskId := CreateParkedTask();

        AssertNeedsRestart(TempJobQueueEntry.Status::Ready, TaskId, false, 'a Ready job with its task');
        AssertNeedsRestart(TempJobQueueEntry.Status::Ready, CreateGuid(), true, 'a Ready job whose task is gone');
        AssertNeedsRestart(TempJobQueueEntry.Status::Waiting, TaskId, false, 'a Waiting job with its task');
        AssertNeedsRestart(TempJobQueueEntry.Status::Waiting, CreateGuid(), true, 'a Waiting job whose task is gone');
        AssertNeedsRestart(TempJobQueueEntry.Status::"On Hold with Inactivity Timeout", TaskId, false, 'an inactive job with its task');
        AssertNeedsRestart(TempJobQueueEntry.Status::"On Hold with Inactivity Timeout", CreateGuid(), true, 'an inactive job whose task is gone');

        TaskScheduler.CancelTask(TaskId);
        TempJobQueueEntry.Status := TempJobQueueEntry.Status::Ready;
        TempJobQueueEntry."System Task ID" := TaskId;
        _Assert.IsTrue(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A job whose task was cancelled needs a restart.');
    end;

    [Test]
    procedure NeedsRestart_InProcess_OnlyWhenTheTaskIsGone()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        TaskId: Guid;
    begin
        TaskId := CreateParkedTask();
        TempJobQueueEntry.Status := TempJobQueueEntry.Status::"In Process";

        TempJobQueueEntry."System Task ID" := TaskId;
        _Assert.IsFalse(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A running job must never be restarted.');

        // A failed "Run Now" leaves the entry In Process without a task, in a user session that may stay open.
        TempJobQueueEntry."System Task ID" := CreateGuid();
        TempJobQueueEntry."User Service Instance ID" := ServiceInstanceId();
        TempJobQueueEntry."User Session ID" := SessionId();
        _Assert.IsTrue(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'An In Process job whose task is gone needs a restart.');

        TaskScheduler.CancelTask(TaskId);
    end;

    [Test]
    procedure NeedsRestart_StatusesWithoutTaskCheck()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        TempJobQueueEntry.Status := TempJobQueueEntry.Status::"On Hold";
        TempJobQueueEntry."NPR Manually Set On Hold" := true;
        _Assert.IsFalse(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A job a user set On Hold must stay On Hold.');

        TempJobQueueEntry."NPR Manually Set On Hold" := false;
        _Assert.IsTrue(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A job put On Hold by the system needs a restart.');

        TempJobQueueEntry.Status := TempJobQueueEntry.Status::Error;
        _Assert.IsTrue(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A failed job needs a restart.');

        TempJobQueueEntry.Status := TempJobQueueEntry.Status::Finished;
        _Assert.IsTrue(JobQueueMgt.NeedsRestart(TempJobQueueEntry), 'A finished recurring job needs a restart.');
    end;

    [Test]
    procedure RestartWanted_HealthyJobAwayFromTheRequestedStart_RestartedOnlyForOtherCallers()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBefore: DateTime;
    begin
        NotBefore := CurrentDateTime();
        TempJobQueueEntry.Status := TempJobQueueEntry.Status::Ready;
        TempJobQueueEntry."System Task ID" := CreateParkedTask();
        TempJobQueueEntry."Earliest Start Date/Time" := NotBefore + 3600000;

        JobQueueMgt.SetRestoringFromMonitored(false);
        _Assert.IsTrue(JobQueueMgt.RestartWanted(TempJobQueueEntry, NotBefore), 'Other callers must still move a job to the start time they ask for.');
        JobQueueMgt.SetRestoringFromMonitored(true);
        _Assert.IsFalse(JobQueueMgt.RestartWanted(TempJobQueueEntry, NotBefore), 'The refresher must leave a healthy scheduled job alone.');

        TaskScheduler.CancelTask(TempJobQueueEntry."System Task ID");
    end;

    [Test]
    procedure InitRecurringJobQueueEntry_RunningJob_RefresherLeavesItAloneUntilTheRunHasEnded()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Parameters: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        TaskId: Guid;
        DescriptionBefore: Text;
    begin
        CreateRecurringJob(JobQueueEntry);
        TaskId := CreateParkedTask();
        JobQueueEntry.Status := JobQueueEntry.Status::"In Process";
        JobQueueEntry."System Task ID" := TaskId;
        JobQueueEntry.Modify();
        DescriptionBefore := JobQueueEntry.Description;

        Parameters := JobQueueEntry;
        Parameters.Description := 'Changed by the definition';
        JobQueueMgt.SetRestoringFromMonitored(true);
        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        JobQueueEntry.Find();
        _Assert.AreEqual(DescriptionBefore, JobQueueEntry.Description, 'The refresher must not rewrite the entry of a running job.');
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::"In Process");
        JobQueueEntry.TestField("System Task ID", TaskId);
        _Assert.IsTrue(JobQueueMgt.DefinitionUpdatePostponed(), 'The refresher must know that the update is still to come.');

        // The run has ended and the job waits for its next start.
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Modify();
        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        JobQueueEntry.Find();
        _Assert.AreEqual(Parameters.Description, JobQueueEntry.Description, 'The first refresh after the run must write the changed definition.');
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::"On Hold");
        _Assert.IsFalse(JobQueueMgt.DefinitionUpdatePostponed(), 'Nothing is postponed once the definition is written.');
        TaskScheduler.CancelTask(TaskId);
    end;

    [Test]
    procedure InitRecurringJobQueueEntry_RunningJob_OtherCallersChangeItRightAway()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Parameters: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        TaskId: Guid;
    begin
        CreateRecurringJob(JobQueueEntry);
        TaskId := CreateParkedTask();
        JobQueueEntry.Status := JobQueueEntry.Status::"In Process";
        JobQueueEntry."System Task ID" := TaskId;
        JobQueueEntry.Modify();

        Parameters := JobQueueEntry;
        Parameters.Description := 'Changed by a setup page';
        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        // Setup code writes what it gets back into the monitored job, so its change must not be held back.
        JobQueueEntry.Find();
        _Assert.AreEqual(Parameters.Description, JobQueueEntry.Description, 'Callers other than the refresher must still change a running job.');
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::"On Hold");
        TaskScheduler.CancelTask(TaskId);
    end;

    [Test]
    procedure InitRecurringJobQueueEntry_InProcessEntryWhoseTaskIsGone_GetsTheChangedDefinition()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Parameters: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        CreateRecurringJob(JobQueueEntry);
        JobQueueEntry.Status := JobQueueEntry.Status::"In Process";
        JobQueueEntry."System Task ID" := CreateGuid();
        JobQueueEntry.Modify();

        Parameters := JobQueueEntry;
        Parameters.Description := 'Changed by the definition';
        JobQueueMgt.SetRestoringFromMonitored(true);
        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        JobQueueEntry.Find();
        _Assert.AreEqual(Parameters.Description, JobQueueEntry.Description, 'An entry left In Process by a run that no longer exists is not a running job.');
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::"On Hold");
    end;

    [Test]
    procedure RefreshJobQueueEntries_ChangedEntries_ScheduledJobIsRestoredAndRunningJobWhenItsRunHasEnded()
    var
        JobQueueEntry: array[2] of Record "Job Queue Entry";
        MonitoredJQEntry: array[2] of Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        TaskId: array[2] of Guid;
        i: Integer;
    begin
        Initialize();
        for i := 1 to 2 do begin
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
            TaskId[i] := CreateParkedTask();
            JobQueueEntry[i].Find();
            JobQueueEntry[i]."System Task ID" := TaskId[i];
            JobQueueEntry[i]."Maximum No. of Attempts to Run" := MonitoredJQEntry[i]."Maximum No. of Attempts to Run" + 3;
        end;
        JobQueueEntry[1].Status := JobQueueEntry[1].Status::Ready;
        JobQueueEntry[2].Status := JobQueueEntry[2].Status::"In Process";
        for i := 1 to 2 do
            JobQueueEntry[i].Modify();
        Commit();

        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);

        JobQueueEntry[1].Find();
        _Assert.AreEqual(MonitoredJQEntry[1]."Maximum No. of Attempts to Run", JobQueueEntry[1]."Maximum No. of Attempts to Run", 'A changed job queue entry must get its monitored definition back.');
        // The test runner cannot create tasks, so the restart that follows the update in production does not happen here.
        JobQueueEntry[1].TestField(Status, JobQueueEntry[1].Status::"On Hold");

        JobQueueEntry[2].Find();
        _Assert.AreEqual(MonitoredJQEntry[2]."Maximum No. of Attempts to Run" + 3, JobQueueEntry[2]."Maximum No. of Attempts to Run", 'The entry of a running job must be left as it is.');
        JobQueueEntry[2].TestField(Status, JobQueueEntry[2].Status::"In Process");
        JobQueueEntry[2].TestField("System Task ID", TaskId[2]);
        MonitoredJQEntry[2].Find();
        MonitoredJQEntry[2].TestField("Last Refresh Status", MonitoredJQEntry[2]."Last Refresh Status"::Success);
        _Assert.AreNotEqual('', MonitoredJQEntry[2].GetErrorMessage(false), 'The monitored job must say that its job queue entry was not updated yet.');

        // The run has ended and the job waits for its next start.
        JobQueueEntry[2].Status := JobQueueEntry[2].Status::Ready;
        JobQueueEntry[2].Modify();
        Commit();

        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);

        JobQueueEntry[2].Find();
        _Assert.AreEqual(MonitoredJQEntry[2]."Maximum No. of Attempts to Run", JobQueueEntry[2]."Maximum No. of Attempts to Run", 'The first refresh after the run must write the monitored definition.');
        JobQueueEntry[2].TestField(Status, JobQueueEntry[2].Status::"On Hold");
        MonitoredJQEntry[2].Find();
        _Assert.AreEqual('', MonitoredJQEntry[2].GetErrorMessage(false), 'The note must be gone once the definition is written.');

        for i := 1 to 2 do
            TaskScheduler.CancelTask(TaskId[i]);
        Initialize();
    end;

    [Test]
    procedure WillOverwrite_OnlyWhenAMonitoredJobDiffersAndTheRefresherIsEnabled()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        Unchanged: Boolean;
        StartMoved: Boolean;
        Changed: Boolean;
        ChangedWithoutRefresher: Boolean;
        ChangedWithoutMonitoredJob: Boolean;
    begin
        Initialize();
        SwitchRefresherOn(SavedJQRefreshSetup);
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        JobQueueEntry.Find();

        Unchanged := RefreshJobQueueEntry.WillOverwrite(JobQueueEntry);
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime() + 3600000;
        StartMoved := RefreshJobQueueEntry.WillOverwrite(JobQueueEntry);
        JobQueueEntry."Maximum No. of Attempts to Run" += 3;
        Changed := RefreshJobQueueEntry.WillOverwrite(JobQueueEntry);

        JQRefreshSetup.Get();
        JQRefreshSetup.Enabled := false;
        JQRefreshSetup.Modify();
        ChangedWithoutRefresher := RefreshJobQueueEntry.WillOverwrite(JobQueueEntry);
        JQRefreshSetup.Enabled := true;
        JQRefreshSetup.Modify();
        MonitoredJQEntry.Delete();
        ChangedWithoutMonitoredJob := RefreshJobQueueEntry.WillOverwrite(JobQueueEntry);

        RestoreRefresherSetup(SavedJQRefreshSetup);
        Initialize();

        _Assert.IsFalse(Unchanged, 'An entry that equals its monitored job is not overwritten.');
        _Assert.IsFalse(StartMoved, 'A start time moved by hand is kept by the refresher.');
        _Assert.IsTrue(Changed, 'An entry that differs from its monitored job is overwritten by the next refresh.');
        _Assert.IsFalse(ChangedWithoutRefresher, 'Nothing is overwritten while the refresher is switched off.');
        _Assert.IsFalse(ChangedWithoutMonitoredJob, 'Nothing is overwritten without a monitored job.');
    end;

    [Test]
    [HandlerFunctions('CountRefreshOverwriteWarnings')]
    procedure JobQueueEntryCard_MonitoredJobChangedByHand_WarnsThatTheRefresherOverwritesTheChange()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueEntryCard: TestPage "Job Queue Entry Card";
        WarningsOnOpen: Integer;
        WarningsAfterChange: Integer;
    begin
        Initialize();
        SwitchRefresherOn(SavedJQRefreshSetup);
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        _RefreshOverwriteWarnings := 0;

        JobQueueEntryCard.OpenEdit();
        JobQueueEntryCard.GoToRecord(JobQueueEntry);
        WarningsOnOpen := _RefreshOverwriteWarnings;
        JobQueueEntryCard."Expiration Date/Time".SetValue(CurrentDateTime() + 86400000);
        JobQueueEntryCard.Close();
        WarningsAfterChange := _RefreshOverwriteWarnings;

        RestoreRefresherSetup(SavedJQRefreshSetup);
        Initialize();

        _Assert.AreEqual(0, WarningsOnOpen, 'A monitored job that equals its monitored job must open without the warning.');
        _Assert.IsTrue(WarningsAfterChange > 0, 'Changing a field of a monitored job by hand must warn that the refresher overwrites it.');
    end;

    [SendNotificationHandler]
    procedure CountRefreshOverwriteWarnings(var SentNotification: Notification): Boolean
    begin
        if SentNotification.Message().Contains('Job Queue Refresher') then
            _RefreshOverwriteWarnings += 1;
    end;

    [Test]
    procedure InitRecurringJobQueueEntry_NotifyOnSuccessSwitchedOnByAReportRun_IsNotADefinitionChange()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Parameters: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        CreateRecurringJob(JobQueueEntry);
        Parameters := JobQueueEntry;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."Notify On Success" := true;
        JobQueueEntry.Modify();

        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        JobQueueEntry.Find();
        JobQueueEntry.TestField(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.TestField("Notify On Success", true);
    end;

    [Test]
    procedure InitRecurringJobQueueEntry_RestoringFromMonitored_UpdatesAndRestoresTheLockTimeout()
    var
        JobQueueEntry: Record "Job Queue Entry";
        Parameters: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        LockTimeoutBefore: Integer;
    begin
        CreateRecurringJob(JobQueueEntry);
        Parameters := JobQueueEntry;
        Parameters.Description := 'Changed by the definition';
        LockTimeoutBefore := LockTimeoutDuration();

        JobQueueMgt.SetRestoringFromMonitored(true);
        JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry);

        JobQueueEntry.Find();
        _Assert.AreEqual(Parameters.Description, JobQueueEntry.Description, 'The definition change must be applied when the entry is not locked.');
        _Assert.AreEqual(LockTimeoutBefore, LockTimeoutDuration(), 'The session lock timeout must be restored after the short lock wait.');
    end;

    [Test]
    procedure RefreshJobQueueEntries_LockAttemptFails_RestoresTheLockTimeout()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        LockTimeoutBefore: Integer;
    begin
        Initialize();
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        MonitoredJQEntry.Description := 'Changed by the definition';
        MonitoredJQEntry.Modify();
        Commit();
        LockTimeoutBefore := LockTimeoutDuration();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        RefreshOrderRecorder.DeleteJobBeforeItIsLocked();
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);

        MonitoredJQEntry.Find();
        MonitoredJQEntry.TestField("Last Refresh Status", MonitoredJQEntry."Last Refresh Status"::Error);
        _Assert.AreEqual(LockTimeoutBefore, LockTimeoutDuration(), 'A failed lock wait must not leave the short lock timeout on the session.');
        // From BC28 the base RefreshLocked lets a missing entry through to the update; the refresher's own lock wait stops before it.
        _Assert.AreEqual(1, RefreshOrderRecorder.GetDefinitionUpdates(), 'The refresher must stop at its own lock wait, before the entry is updated.');
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_FailingEntry_IsMarkedAsErrorAndTheOthersAreRefreshed()
    var
        JobQueueEntry: array[3] of Record "Job Queue Entry";
        MonitoredJQEntry: array[3] of Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        i: Integer;
    begin
        Initialize();
        for i := 1 to 3 do
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
        Commit();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        RefreshOrderRecorder.FailRefreshOf(MonitoredJQEntry[2]."Parameter String", 'Simulated refresh failure');
        SentryCapture.Start();
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);
        SentryCapture.Stop();

        _Assert.AreEqual(3, RefreshOrderRecorder.GetRecorded().Count(), 'A failing entry must not stop the refresh of the others.');
        _Assert.IsTrue(SentryCapture.Contains('Simulated refresh failure'), 'A job that could not be refreshed must be reported to Sentry.');
        for i := 1 to 3 do
            MonitoredJQEntry[i].Find();
        MonitoredJQEntry[1].TestField("Last Refresh Status", MonitoredJQEntry[1]."Last Refresh Status"::Success);
        MonitoredJQEntry[2].TestField("Last Refresh Status", MonitoredJQEntry[2]."Last Refresh Status"::Error);
        MonitoredJQEntry[3].TestField("Last Refresh Status", MonitoredJQEntry[3]."Last Refresh Status"::Success);
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_ProgrammingBugWithoutATransaction_IsSentToSentry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        FailureText: Text;
    begin
        // The legacy refresher and the "Refresh" action on the job queue entries start no Sentry transaction.
        Initialize();
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        Commit();
        FailureText := 'Simulated refresh failure. This is a programming bug';

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        RefreshOrderRecorder.FailRefreshOf(MonitoredJQEntry."Parameter String", FailureText);
        SentryCapture.Start();
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);
        SentryCapture.Stop();

        _Assert.IsTrue(SentryCapture.Contains(FailureText), 'A programming bug must reach Sentry also when the caller started no transaction.');

        SentryCapture.Start();
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);
        SentryCapture.Stop();

        _Assert.IsTrue(SentryCapture.Contains(FailureText), 'A programming bug must reach Sentry on every call, not only when the job starts to fail.');
        MonitoredJQEntry.Find();
        _Assert.AreEqual(FailureText, MonitoredJQEntry.GetErrorMessage(false), 'The monitored entry must keep the error of its failed refresh.');
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_SendsItsTransactionToSentryOnlyWhenSomethingWentWrong()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        SentWhenAllWasFine: Boolean;
        SentWhenEntriesWereNotReached: Boolean;
    begin
        Initialize();
        SwitchRefresherOn(SavedJQRefreshSetup);
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        Commit();

        SentWhenAllWasFine := RefreshSendsItsTransaction(0DT);
        SentWhenEntriesWereNotReached := RefreshSendsItsTransaction(CurrentDateTime() - 1000);

        RestoreRefresherSetup(SavedJQRefreshSetup);
        Initialize();
        _Assert.IsFalse(SentWhenAllWasFine, 'A refresh in which nothing went wrong must send nothing to Sentry.');
        _Assert.IsTrue(SentWhenEntriesWereNotReached, 'A refresh that ran out of time must send its transaction to Sentry.');
    end;

    [Test]
    procedure RefreshJobQueueEntries_JobCannotBeRefreshed_SendsItsTransactionToSentryWhenThatStarts()
    var
        JobQueueEntry: array[2] of Record "Job Queue Entry";
        MonitoredJQEntry: array[2] of Record "NPR Monitored Job Queue Entry";
        SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        SentWhenTheJobFailed: Boolean;
        SentWhenItFailedAgain: Boolean;
        i: Integer;
    begin
        Initialize();
        SwitchRefresherOn(SavedJQRefreshSetup);
        for i := 1 to 2 do
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
        Commit();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        RefreshOrderRecorder.FailRefreshOf(MonitoredJQEntry[2]."Parameter String", 'Simulated refresh failure');
        BindSubscription(RefreshOrderRecorder);
        SentWhenTheJobFailed := RefreshSendsItsTransaction(0DT);
        SentWhenItFailedAgain := RefreshSendsItsTransaction(0DT);
        UnbindSubscription(RefreshOrderRecorder);

        RestoreRefresherSetup(SavedJQRefreshSetup);
        Initialize();
        _Assert.IsTrue(SentWhenTheJobFailed, 'A job that could not be refreshed must be reported to Sentry with the transaction of the call.');
        _Assert.IsFalse(SentWhenItFailedAgain, 'A job that fails again on the next call must not be reported every time.');
    end;

    [Test]
    procedure RefreshJobQueueEntries_EntriesThatFailedLastTimeGoLast()
    var
        JobQueueEntry: array[3] of Record "Job Queue Entry";
        MonitoredJQEntry: array[3] of Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        Recorded: List of [Text];
        i: Integer;
    begin
        Initialize();
        for i := 1 to 3 do
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
        MonitoredJQEntry[1]."Last Refresh Status" := MonitoredJQEntry[1]."Last Refresh Status"::Error;
        MonitoredJQEntry[1].Modify();
        Commit();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);

        Recorded := RefreshOrderRecorder.GetRecorded();
        _Assert.AreEqual(3, Recorded.Count(), 'Every monitored entry must be refreshed.');
        _Assert.AreEqual(MonitoredJQEntry[2]."Parameter String", Recorded.Get(1), 'Entries that did not fail come first.');
        _Assert.AreEqual(MonitoredJQEntry[3]."Parameter String", Recorded.Get(2), 'Entries that did not fail come first.');
        _Assert.AreEqual(MonitoredJQEntry[1]."Parameter String", Recorded.Get(3), 'The entry that failed last time comes last.');
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_FailedEntries_LongestUntouchedGoesFirst()
    var
        JobQueueEntry: array[3] of Record "Job Queue Entry";
        MonitoredJQEntry: array[3] of Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        Recorded: List of [Text];
        i: Integer;
    begin
        Initialize();
        for i := 1 to 3 do
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
        // Entry 3 was written longest ago, like an entry the deadline did not reach; entry 2 just failed again.
        MarkFailed(MonitoredJQEntry[3]);
        Sleep(50);
        MarkFailed(MonitoredJQEntry[1]);
        Sleep(50);
        MarkFailed(MonitoredJQEntry[2]);
        Commit();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(0DT);
        UnbindSubscription(RefreshOrderRecorder);

        Recorded := RefreshOrderRecorder.GetRecorded();
        _Assert.AreEqual(3, Recorded.Count(), 'Every failed entry must be refreshed.');
        _Assert.AreEqual(MonitoredJQEntry[3]."Parameter String", Recorded.Get(1), 'The failed entry written longest ago comes first.');
        _Assert.AreEqual(MonitoredJQEntry[1]."Parameter String", Recorded.Get(2), 'Failed entries come in the order they were last written.');
        _Assert.AreEqual(MonitoredJQEntry[2]."Parameter String", Recorded.Get(3), 'The entry that just failed again comes last.');
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_DeadlinePassed_StartsNoEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
    begin
        Initialize();
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        Commit();

        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(CurrentDateTime() - 1000);
        UnbindSubscription(RefreshOrderRecorder);

        _Assert.AreEqual(0, RefreshOrderRecorder.GetRecorded().Count(), 'No entry may be started after the deadline.');
        Initialize();
    end;

    [Test]
    procedure RefreshJobQueueEntries_DeadlinePassesDuringTheRun_StartsNoFurtherEntry()
    var
        JobQueueEntry: array[2] of Record "Job Queue Entry";
        MonitoredJQEntry: array[2] of Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        Recorded: List of [Text];
        OnlyTestEntries: Boolean;
        i: Integer;
    begin
        Initialize();
        for i := 1 to 2 do
            CreateMonitoredJob(JobQueueEntry[i], MonitoredJQEntry[i]);
        Commit();

        OnlyTestEntries := OnlyTestEntriesAreMonitored();
        RefreshOrderRecorder.SetParameterPrefix(_TestParameterPrefix);
        RefreshOrderRecorder.SlowDownRefreshOf(MonitoredJQEntry[1]."Parameter String", 1500);
        BindSubscription(RefreshOrderRecorder);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(CurrentDateTime() + 1000);
        UnbindSubscription(RefreshOrderRecorder);

        Recorded := RefreshOrderRecorder.GetRecorded();
        // Monitored jobs that already exist in the company can use up the time before the first test entry is reached.
        if OnlyTestEntries then begin
            _Assert.AreEqual(1, Recorded.Count(), 'Only the entry started before the deadline may be refreshed.');
            _Assert.AreEqual(MonitoredJQEntry[1]."Parameter String", Recorded.Get(1), 'The first entry must be refreshed before the deadline.');
        end else
            _Assert.IsTrue(Recorded.Count() < 2, 'No entry may be started once the deadline passed during the run.');
        Initialize();
    end;

    [Test]
    procedure MonitoredJobsRenewalIsDue_FortyMinutesAfterTheLastRenewalOfAnyRunnerUser()
    var
        TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        SaveRefreshLog(TempJobQueueRefreshLog);
        _Assert.IsTrue(JobQueueMgt.MonitoredJobsRenewalIsDue(), 'Without any renewal the monitored jobs must be renewed.');

        SetRenewedAt(UserId(), CurrentDateTime() - 39 * 60000);
        _Assert.IsFalse(JobQueueMgt.MonitoredJobsRenewalIsDue(), 'Calls within 40 minutes of the last renewal must not renew them again.');

        SetRenewedAt(UserId(), CurrentDateTime() - 41 * 60000);
        SetRenewedAt(_TestParameterPrefix + 'OTHER', CurrentDateTime() - 10 * 60000);
        _Assert.IsFalse(JobQueueMgt.MonitoredJobsRenewalIsDue(), 'A renewal by another runner user within the last 40 minutes counts too.');

        SetRenewedAt(_TestParameterPrefix + 'OTHER', CurrentDateTime() - 41 * 60000);
        _Assert.IsTrue(JobQueueMgt.MonitoredJobsRenewalIsDue(), 'More than 40 minutes after the last renewal they must be renewed again.');

        RestoreRefreshLog(TempJobQueueRefreshLog);
    end;

    [Test]
    procedure RefreshNPRJobQueueList_ExternalRefresherCall_RenewsTheMonitoredJobsOncePerHour()
    var
        TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        ExpectedRenewals: Integer;
    begin
        SaveRefreshLog(TempJobQueueRefreshLog);
        SetRenewedAt(UserId(), 0DT);
        Commit();
        // A PTE can switch the renewal of NP protected jobs off.
        if not JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() then
            ExpectedRenewals := 1;

        BindSubscription(RefreshOrderRecorder);
        JobQueueMgt.RefreshNPRJobQueueList(false, true);
        JobQueueMgt.RefreshNPRJobQueueList(false, true);
        UnbindSubscription(RefreshOrderRecorder);

        _Assert.AreEqual(ExpectedRenewals, RefreshOrderRecorder.GetRenewals(), 'The external refresher must renew the monitored jobs once per hour.');
        RestoreRefreshLog(TempJobQueueRefreshLog);
    end;

    [Test]
    procedure RefreshNPRJobQueueList_ExternalRefresherCallWithoutTimeZone_FailsWithoutStampingTheRenewal()
    var
        TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary;
        JobQueueRefreshLog: Record "NPR Job Queue Refresh Log";
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        UseExternalRefresher: Boolean;
        DefaultJobTimeZone: Text[180];
        RenewedAt: DateTime;
    begin
        // A PTE can switch the renewal of NP protected jobs off, and then there is nothing to check.
        if JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() then
            exit;
        SaveRefreshLog(TempJobQueueRefreshLog);
        SetRenewedAt(UserId(), 0DT);
        JQRefreshSetup.GetSetup();
        UseExternalRefresher := JQRefreshSetup."Use External JQ Refresher";
        DefaultJobTimeZone := JQRefreshSetup."Default Job Time Zone";
        JQRefreshSetup."Use External JQ Refresher" := true;
        JQRefreshSetup."Default Job Time Zone" := '';
        JQRefreshSetup.Modify();
        Commit();

        asserterror JobQueueMgt.RefreshNPRJobQueueList(false, true);

        JobQueueRefreshLog.Get(UserId());
        RenewedAt := JobQueueRefreshLog."Monitored Jobs Renewed At";
        JQRefreshSetup.Get();
        JQRefreshSetup."Use External JQ Refresher" := UseExternalRefresher;
        JQRefreshSetup."Default Job Time Zone" := DefaultJobTimeZone;
        JQRefreshSetup.Modify();
        RestoreRefreshLog(TempJobQueueRefreshLog);
        // A stamp left behind would let the next calls of the hour skip the check and hide the missing setup.
        _Assert.AreEqual(0DT, RenewedAt, 'A call that fails the setup check must not stamp the renewal.');
    end;

    [Test]
    procedure RefreshJobQueues_FailedCall_SendsItsTransactionToSentryAndFails()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        ExternalJQRefresherWS: Codeunit "NPR External JQ Refresher WS";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        UseExternalRefresher: Boolean;
        RefresherEnabled: Boolean;
        DefaultJobTimeZone: Text[180];
        ErrorText: Text;
    begin
        // A PTE can switch the renewal of NP protected jobs off, and then the setup check that fails here is skipped.
        if JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() then
            exit;
        JQRefreshSetup.GetSetup();
        UseExternalRefresher := JQRefreshSetup."Use External JQ Refresher";
        RefresherEnabled := JQRefreshSetup.Enabled;
        DefaultJobTimeZone := JQRefreshSetup."Default Job Time Zone";
        JQRefreshSetup."Use External JQ Refresher" := true;
        JQRefreshSetup.Enabled := true;
        JQRefreshSetup."Default Job Time Zone" := '';
        JQRefreshSetup.Modify();
        Commit();

        SentryCapture.Start();
        asserterror ExternalJQRefresherWS.RefreshJobQueues();
        ErrorText := GetLastErrorText();
        SentryCapture.Stop();
        // Restored before the checks, so a failing check cannot leave the external refresher on for the tests that follow.
        JQRefreshSetup.Get();
        JQRefreshSetup."Use External JQ Refresher" := UseExternalRefresher;
        JQRefreshSetup.Enabled := RefresherEnabled;
        JQRefreshSetup."Default Job Time Zone" := DefaultJobTimeZone;
        JQRefreshSetup.Modify();
        Commit();

        _Assert.IsTrue(ErrorText.Contains(JQRefreshSetup.FieldCaption("Default Job Time Zone")), 'The caller must still get the error of the failed call.');
        _Assert.IsTrue(SentryCapture.Contains('External JQ Refresher: RefreshJobQueues'), 'A failed call must still send its transaction to Sentry.');
    end;

    [Test]
    procedure RefreshJobQueues_SuccessfulCall_SendsNothingToSentry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary;
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        ExternalJQRefresherWS: Codeunit "NPR External JQ Refresher WS";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Sent: Boolean;
    begin
        Initialize();
        SaveRefreshLog(TempJobQueueRefreshLog);
        SwitchRefresherOn(SavedJQRefreshSetup);
        JQRefreshSetup.Get();
        if JQRefreshSetup."Default Job Time Zone" = '' then begin
            JQRefreshSetup."Default Job Time Zone" := 'UTC';
            JQRefreshSetup.Modify();
        end;
        CreateMonitoredJob(JobQueueEntry, MonitoredJQEntry);
        Commit();

        SentryCapture.Start();
        ExternalJQRefresherWS.RefreshJobQueues();
        SentryCapture.Stop();
        Sent := SentryCapture.Contains('External JQ Refresher: RefreshJobQueues');

        JQRefreshSetup.Get();
        JQRefreshSetup."Default Job Time Zone" := SavedJQRefreshSetup."Default Job Time Zone";
        JQRefreshSetup.Modify();
        RestoreRefresherSetup(SavedJQRefreshSetup);
        RestoreRefreshLog(TempJobQueueRefreshLog);
        Initialize();
        // Every company and runner user calls the refresher each hour; only a call with a problem is worth a Sentry event.
        _Assert.IsFalse(Sent, 'A call in which nothing went wrong must send nothing to Sentry.');
    end;

    [Test]
    procedure RefreshNPRJobQueueList_OtherCallers_RenewWithoutUsingTheHourlyRenewal()
    var
        TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary;
        JobQueueRefreshLog: Record "NPR Job Queue Refresh Log";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RefreshOrderRecorder: Codeunit "NPR JQ Refresh Order Recorder";
        RenewedAt: DateTime;
        ExpectedRenewals: Integer;
    begin
        SaveRefreshLog(TempJobQueueRefreshLog);
        // A fresh stamp, so the hourly check would say "not due" if it were applied to these callers too.
        SetRenewedAt(UserId(), CurrentDateTime() - 5 * 60000);
        JobQueueRefreshLog.Get(UserId());
        RenewedAt := JobQueueRefreshLog."Monitored Jobs Renewed At";
        Commit();
        // A PTE can switch the renewal of NP protected jobs off.
        if not JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() then
            ExpectedRenewals := 1;

        BindSubscription(RefreshOrderRecorder);
        JobQueueMgt.RefreshNPRJobQueueList(false);
        UnbindSubscription(RefreshOrderRecorder);

        _Assert.AreEqual(ExpectedRenewals, RefreshOrderRecorder.GetRenewals(), 'Callers other than the external refresher must always renew the monitored jobs.');
        JobQueueRefreshLog.Get(UserId());
        JobQueueRefreshLog.TestField("Monitored Jobs Renewed At", RenewedAt);
        RestoreRefreshLog(TempJobQueueRefreshLog);
    end;

    local procedure AssertNeedsRestart(Status: Option; TaskId: Guid; Expected: Boolean; Situation: Text)
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        TempJobQueueEntry.Status := Status;
        TempJobQueueEntry."System Task ID" := TaskId;
        _Assert.AreEqual(Expected, JobQueueMgt.NeedsRestart(TempJobQueueEntry), StrSubstNo('Restart decision for %1.', Situation));
    end;

    local procedure CreateParkedTask(): Guid
    begin
        // Not ready and far in the future, so the task scheduler never runs it.
        exit(TaskScheduler.CreateTask(Codeunit::"NPR JQ Refresher Test Helper", 0, false, CompanyName(), CurrentDateTime() + 86400000));
    end;

    local procedure CreateRecurringJob(var JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        ParameterString: Text[250];
    begin
        ParameterString := CopyStr(_TestParameterPrefix + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 250);
        JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR JQ Refresher Test Helper", ParameterString, ParameterString,
            CurrentDateTime() + 60000, 60, '', JobQueueEntry);
    end;

    local procedure CreateMonitoredJob(var JobQueueEntry: Record "Job Queue Entry"; var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        CreateRecurringJob(JobQueueEntry);
        MonitoredJobQueueMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        MonitoredJQEntry.FindFirst();
        MonitoredJQEntry.SetRange("Job Queue Entry ID");
        MonitoredJQEntry."JQ Runner User Name" := CopyStr(UserId(), 1, MaxStrLen(MonitoredJQEntry."JQ Runner User Name"));
        MonitoredJQEntry.Modify();
    end;

    local procedure MarkFailed(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        MonitoredJQEntry.Find();
        MonitoredJQEntry.SetErrorMessage('Simulated earlier failure');
        MonitoredJQEntry."Last Refresh Status" := MonitoredJQEntry."Last Refresh Status"::Error;
        MonitoredJQEntry.Modify();
    end;

    local procedure SetRenewedAt(RunnerUserName: Text; RenewedAt: DateTime)
    var
        JobQueueRefreshLog: Record "NPR Job Queue Refresh Log";
    begin
        JobQueueRefreshLog."JQ Runner User Name" := CopyStr(RunnerUserName, 1, MaxStrLen(JobQueueRefreshLog."JQ Runner User Name"));
        if not JobQueueRefreshLog.Find() then
            JobQueueRefreshLog.Insert();
        JobQueueRefreshLog."Monitored Jobs Renewed At" := RenewedAt;
        JobQueueRefreshLog.Modify();
    end;

    local procedure RefreshSendsItsTransaction(Deadline: DateTime): Boolean
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        Sentry: Codeunit "NPR Sentry";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
    begin
        SentryCapture.Start();
        Sentry.InitScopeAndTransaction(_TestTransactionTok, 'test', 0);
        MonitoredJobQueueMgt.RefreshJobQueueEntries(Deadline);
        Sentry.FinalizeScope();
        SentryCapture.Stop();
        exit(SentryCapture.Contains(_TestTransactionTok));
    end;

    local procedure SwitchRefresherOn(var SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup")
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        // External refresher without a default runner user: a refresh then only handles the jobs of the current user,
        // which are the test jobs.
        JQRefreshSetup.GetSetup();
        SavedJQRefreshSetup := JQRefreshSetup;
        JQRefreshSetup.Enabled := true;
        JQRefreshSetup."Use External JQ Refresher" := true;
        JQRefreshSetup."Default Refresher User Name" := '';
        JQRefreshSetup.Modify();
    end;

    local procedure RestoreRefresherSetup(SavedJQRefreshSetup: Record "NPR Job Queue Refresh Setup")
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        JQRefreshSetup.Get();
        JQRefreshSetup.Enabled := SavedJQRefreshSetup.Enabled;
        JQRefreshSetup."Use External JQ Refresher" := SavedJQRefreshSetup."Use External JQ Refresher";
        JQRefreshSetup."Default Refresher User Name" := SavedJQRefreshSetup."Default Refresher User Name";
        JQRefreshSetup.Modify();
        Commit();
    end;

    local procedure OnlyTestEntriesAreMonitored(): Boolean
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        TestEntries: Integer;
    begin
        MonitoredJQEntry.SetFilter("Parameter String", _TestParameterPrefix + '*');
        TestEntries := MonitoredJQEntry.Count();
        MonitoredJQEntry.SetRange("Parameter String");
        exit(MonitoredJQEntry.Count() = TestEntries);
    end;

    local procedure SaveRefreshLog(var TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary)
    var
        JobQueueRefreshLog: Record "NPR Job Queue Refresh Log";
    begin
        if JobQueueRefreshLog.FindSet() then
            repeat
                TempJobQueueRefreshLog := JobQueueRefreshLog;
                TempJobQueueRefreshLog.Insert();
            until JobQueueRefreshLog.Next() = 0;
        JobQueueRefreshLog.ModifyAll("Monitored Jobs Renewed At", 0DT);
    end;

    local procedure RestoreRefreshLog(var TempJobQueueRefreshLog: Record "NPR Job Queue Refresh Log" temporary)
    var
        JobQueueRefreshLog: Record "NPR Job Queue Refresh Log";
    begin
        JobQueueRefreshLog.DeleteAll();
        if TempJobQueueRefreshLog.FindSet() then
            repeat
                JobQueueRefreshLog := TempJobQueueRefreshLog;
                JobQueueRefreshLog.Insert();
            until TempJobQueueRefreshLog.Next() = 0;
        Commit();
    end;

    local procedure Initialize()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetFilter("Parameter String", _TestParameterPrefix + '*');
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);
        JobQueueEntry.SetFilter("Parameter String", _TestParameterPrefix + '*');
        if not JobQueueEntry.IsEmpty() then begin
            // An entry left In Process by a failed test cannot be deleted.
            JobQueueEntry.ModifyAll(Status, JobQueueEntry.Status::"On Hold");
            JobQueueEntry.DeleteAll(true);
        end;
        Commit();
    end;
}
