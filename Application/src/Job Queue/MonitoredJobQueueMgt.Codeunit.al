codeunit 6248395 "NPR Monitored Job Queue Mgt."
{
    Access = Internal;
    EventSubscriberInstance = Manual;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'IsInMonitoredJobUpdate', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", IsInMonitoredJobUpdate, '', false, false)]
#endif
    local procedure SetRunByMonitoredJobRefreshRoutine(var Result: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        Result := true;
    end;

    internal procedure RefreshJobQueueEntries(Deadline: DateTime)
    var
        JQMonitorEntry: Record "NPR Monitored Job Queue Entry";
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        Sentry: Codeunit "NPR Sentry";
        EntriesSpan: Codeunit "NPR Sentry Span";
        EntryNos: List of [BigInteger];
        FailedEntryNos: List of [BigInteger];
        FailedModifiedAt: List of [DateTime];
        EntryNo: BigInteger;
        Refreshed: Integer;
        Failed: Integer;
        NotReached: Integer;
        EntrySpans: Integer;
        NotReachedTxt: Label 'The job queue refresher ran out of time before it reached all monitored jobs.', Locked = true;
    begin
        JQRefreshSetup.GetSetup();
        if JQRefreshSetup."Use External JQ Refresher" then begin
            if (JQRefreshSetup."Default Refresher User Name" <> '') and (JQRefreshSetup."Default Refresher User Name" = UserID) then
                JQMonitorEntry.SetFilter("JQ Runner User Name", '%1|%2', UserID, '')
            else
                JQMonitorEntry.SetRange("JQ Runner User Name", UserID);
        end;

        // Entries that failed last time (e.g. locked by another session) go last, so they cannot use up the time of the others.
        // Among them the one written longest ago goes first: every failed attempt rewrites its entry, so entries the deadline
        // did not reach come before the ones that just failed again.
        JQMonitorEntry.SetLoadFields("Entry No.", "Last Refresh Status", SystemModifiedAt);
        if JQMonitorEntry.FindSet() then
            repeat
                if JQMonitorEntry."Last Refresh Status" = JQMonitorEntry."Last Refresh Status"::Error then
                    AddOldestFirst(FailedEntryNos, FailedModifiedAt, JQMonitorEntry."Entry No.", JQMonitorEntry.SystemModifiedAt)
                else
                    EntryNos.Add(JQMonitorEntry."Entry No.");
            until JQMonitorEntry.Next() = 0;
        EntryNos.AddRange(FailedEntryNos);

        Sentry.StartSpan(EntriesSpan, 'bc.jobqueue.refresher.refresh-entries');
        JQMonitorEntry.SetLoadFields();
        foreach EntryNo in EntryNos do
            if DeadlinePassed(Deadline) then
                NotReached += 1
            else
                if JQMonitorEntry.Get(EntryNo) then
                    if RefreshOneJobQueueEntry(JQMonitorEntry, EntrySpans) then
                        Refreshed += 1
                    else
                        Failed += 1;
        if NotReached > 0 then
            EntriesSpan.Finish(Enum::"NPR Sentry Span Status"::DeadlineExceeded)
        else
            EntriesSpan.Finish(Enum::"NPR Sentry Span Status"::Ok);

        if Sentry.HasActiveTransaction() then begin
            Sentry.AddTransactionTag('jq_refresher.monitored_entries', Format(EntryNos.Count(), 0, 9));
            Sentry.AddTransactionTag('jq_refresher.refreshed_entries', Format(Refreshed, 0, 9));
            Sentry.AddTransactionTag('jq_refresher.failed_entries', Format(Failed, 0, 9));
            Sentry.AddTransactionTag('jq_refresher.not_reached_entries', Format(NotReached, 0, 9));
            if NotReached > 0 then
                Sentry.AddError(NotReachedTxt);
        end;
    end;

    local procedure AddOldestFirst(var EntryNos: List of [BigInteger]; var ModifiedAt: List of [DateTime]; EntryNo: BigInteger; EntryModifiedAt: DateTime)
    var
        Position: Integer;
        i: Integer;
    begin
        Position := ModifiedAt.Count() + 1;
        for i := ModifiedAt.Count() downto 1 do
            if ModifiedAt.Get(i) > EntryModifiedAt then
                Position := i;
        if Position > ModifiedAt.Count() then begin
            EntryNos.Add(EntryNo);
            ModifiedAt.Add(EntryModifiedAt);
        end else begin
            EntryNos.Insert(Position, EntryNo);
            ModifiedAt.Insert(Position, EntryModifiedAt);
        end;
    end;

    local procedure DeadlinePassed(Deadline: DateTime): Boolean
    begin
        if Deadline = 0DT then
            exit(false);
        exit(CurrentDateTime() > Deadline);
    end;

    local procedure RefreshOneJobQueueEntry(JQMonitorEntry: Record "NPR Monitored Job Queue Entry"; var EntrySpans: Integer): Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        EntrySpan: Codeunit "NPR Sentry Span";
        StartedAt: DateTime;
        Refreshed: Boolean;
        ErrorText: Text;
        EntrySpanLbl: Label 'bc.jobqueue.refresher.refresh-entry:%1', Locked = true;
    begin
        StartedAt := CurrentDateTime();
        Refreshed := Codeunit.Run(Codeunit::"NPR Refresh Job Queue Entry", JQMonitorEntry);
        // Only failed and slow entries get a span, and only up to a limit: a transaction that reaches 200 spans is dropped.
        if (not Refreshed or (CurrentDateTime() - StartedAt >= 1000)) and (EntrySpans < 50) then begin
            EntrySpans += 1;
            Sentry.StartSpan(EntrySpan, StrSubstNo(EntrySpanLbl, Format(JQMonitorEntry."Object ID to Run", 0, 9)));
            EntrySpan.SetStartTime(StartedAt);
        end;
        if Refreshed then begin
            EntrySpan.Finish(Enum::"NPR Sentry Span Status"::Ok);
            exit(true);
        end;
        ErrorText := GetLastErrorText();
        AddLastErrorToSentry(JQMonitorEntry."Last Refresh Status" <> JQMonitorEntry."Last Refresh Status"::Error);
        EntrySpan.Finish(Enum::"NPR Sentry Span Status"::InternalError);
        if JQMonitorEntry.Find() then begin
            JQMonitorEntry.SetErrorMessage(ErrorText);
            JQMonitorEntry."Last Refresh Status" := JQMonitorEntry."Last Refresh Status"::Error;
            JQMonitorEntry.Modify();
            Commit();
        end;
    end;

    local procedure AddLastErrorToSentry(FirstFailure: Boolean)
    var
        Sentry: Codeunit "NPR Sentry";
        OwnsTransaction: Boolean;
    begin
        // The legacy refresher and the "Refresh" action on the job queue entries start no transaction, and an error added
        // without one is never sent. This transaction is not sampled, so it is only sent when it carries an error.
        OwnsTransaction := not Sentry.HasActiveTransaction();
        if OwnsTransaction then
            Sentry.InitScopeAndTransaction('Job Queue refresher entry', 'bc.jobqueue.refresher.refresh-entry', 0);
        // A job that could not be refreshed is reported when that starts. One that fails again on every later call is
        // only sent again when it is a programming bug.
        if FirstFailure then
            Sentry.AddLastErrorInEnglish()
        else
            Sentry.AddLastErrorIfProgrammingBug();
        if OwnsTransaction then
            Sentry.FinalizeScope();
    end;

    internal procedure AddMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        xMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NewMonitoredJob: Boolean;
    begin
        SelectLatestVersion();
        if not IsNullGuid(JobQueueEntry.ID) then
            MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID)
        else begin
            MonitoredJQEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run");
            MonitoredJQEntry.SetRange("Object ID to Run", JobQueueEntry."Object ID to Run");
            MonitoredJQEntry.SetRange("Parameter String", JobQueueEntry."Parameter String");
            if Format(JobQueueEntry."Record ID to Process") <> '' then
                MonitoredJQEntry.SetFilter("Record ID to Process", Format(JobQueueEntry."Record ID to Process"));
            MonitoredJQEntry.SetRange("Job Queue Category Code", JobQueueEntry."Job Queue Category Code");
            if MonitoredJQEntry.IsEmpty() then
                MonitoredJQEntry.SetRange("Job Queue Category Code");
        end;
        NewMonitoredJob := not MonitoredJQEntry.FindFirst();
        if not NewMonitoredJob then begin
            if JobQueueMgt.JobQueueIsNPProtected(JobQueueEntry) then
                if JobQueueMgt.IsNprCustomizableJob(JobQueueEntry) then
                    exit;
            xMonitoredJQEntry := MonitoredJQEntry;
        end else begin
            Clear(xMonitoredJQEntry);
            MonitoredJQEntry.Init();
            MonitoredJQEntry."Entry No." := 0;
            MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;
            MonitoredJQEntry.Insert();
        end;
        JobQueueEntry.CalcFields(XML);
        MonitoredJQEntry.TransferFields(JobQueueEntry, false);
        JobQueueMgt.OnBeforeBuildMonitoredFromJobQueueEntry(MonitoredJQEntry, JobQueueEntry);
        if not IsNullGuid(JobQueueEntry.ID) then
            MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;

        if not NewMonitoredJob then begin
            MonitoredJQEntry.Description := xMonitoredJQEntry.Description;
            MonitoredJQEntry."Notif. Profile on Error" := xMonitoredJQEntry."Notif. Profile on Error";
            MonitoredJQEntry."NPR Auto-Resched. after Error" := xMonitoredJQEntry."NPR Auto-Resched. after Error";
            MonitoredJQEntry."NPR Auto-Resched. Delay (sec.)" := xMonitoredJQEntry."NPR Auto-Resched. Delay (sec.)";
        end;
        JobQueueMgt.OnBeforeRenewMonitoredJobQueueEntry(xMonitoredJQEntry, MonitoredJQEntry);
        if Format(xMonitoredJQEntry) <> Format(MonitoredJQEntry) then
            MonitoredJQEntry.Modify(true);
    end;

    internal procedure RemoveMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);
    end;

    internal procedure RecreateMonitoredJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(false);
        JobQueueManagement.RefreshNPRJobQueueList(false);
        if not ManagedByAppJobQueue.IsEmpty() then
            repeat
                if JobQueueEntry.Get(ManagedByAppJobQueue.ID) then begin
                    if JobQueueManagement.JobQueueIsNPProtected(JobQueueEntry) then
                        ManagedByAppJobQueue.Delete()
                    else
                        if ManagedByAppJobQueue."Managed by App" then
                            AddMonitoredJobQueueEntry(JobQueueEntry);
                end;
            until ManagedByAppJobQueue.Next() = 0;
    end;

    internal procedure FindJQEntry(MonitoredJQEntry: Record "NPR Monitored Job Queue Entry"; var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        if JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then
            exit(true);
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run");
        JobQueueEntry.SetRange("Object ID to Run", MonitoredJQEntry."Object ID to Run");
        JobQueueEntry.SetRange("Parameter String", MonitoredJQEntry."Parameter String");
        if Format(MonitoredJQEntry."Record ID to Process") <> '' then
            JobQueueEntry.SetFilter("Record ID to Process", Format(MonitoredJQEntry."Record ID to Process"));
        JobQueueEntry.SetRange("Job Queue Category Code", MonitoredJQEntry."Job Queue Category Code");
        if JobQueueEntry.IsEmpty() then
            JobQueueEntry.SetRange("Job Queue Category Code");

        exit(JobQueueEntry.FindFirst());
    end;

    internal procedure LookUpJobQueues(var JobQueueEntry: Record "Job Queue Entry") Success: Boolean
    var
        AddJQToMonitored: Codeunit "NPR Add Job Queue To Monitored";
#if not (BC17 or BC18 or BC19)
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorContextElement0: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
#endif
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntries: Page "Job Queue Entries";
#if not (BC17 or BC18 or BC19)
        BatchProcessingTxt: Label 'Adding selected job queue entries to monitored list.';
        DefaultErrorMsg: Label 'An error occurred. No further information has been provided.';
        DoneWithErrorsLbl: Label 'Job Queue Entries process completed successfully, however there were some entries that couldn''t be processed.';
        ProcessingMsg: Label 'Processing Job Queue Entry %1 %2 %3.', Comment = '%1 - Object Type to Run. %2 - Object ID to Run. %3 - Object Caption.';
        ErrorMessage: Text;
#endif
        DoneLbl: Label 'Job Queue Entries process completed successfully.';
        CounterSelected: Integer;
        CounterProcessed: Integer;
    begin
        JobQueueEntries.LookupMode := true;
        if not (JobQueueEntries.RunModal() = Action::LookupOK) then
            exit;

        JobQueueEntries.SetSelectionFilter(JobQueueEntry);
        JobQueueEntry.MarkedOnly(true);
        if not JobQueueEntry.FindSet() then
            exit;

#if not (BC17 or BC18 or BC19)
        if ErrorMessageMgt.Activate(ErrorMessageHandler) then
            ErrorMessageMgt.PushContext(ErrorContextElement0, Database::"Job Queue Entry", 0, BatchProcessingTxt);
#endif
        repeat
            CounterSelected += 1;
            if not JobQueueManagement.JobQueueIsNPProtected(JobQueueEntry) then begin
#if not (BC17 or BC18 or BC19)
                ErrorMessageMgt.PushContext(ErrorContextElement, JobQueueEntry.RecordId(), 0, StrSubstNo(ProcessingMsg, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", JobQueueManagement.GetObjCaption(JobQueueEntry)));
#endif
                if AddJQToMonitored.Run(JobQueueEntry) then
                    CounterProcessed += 1
#if (BC17 or BC18 or BC19)
            end;
#else
                else begin
                    ErrorMessage := GetLastErrorText();
                    if ErrorMessage = '' then
                        ErrorMessage := DefaultErrorMsg;
                    ErrorMessageMgt.LogError(JobQueueEntry, ErrorMessage, '');
                    ErrorMessageMgt.PopContext(ErrorContextElement);
                end;
                ClearLastError();
            end else
                ErrorMessageMgt.LogError(JobQueueEntry, StrSubstNo(_IsNPJobErr, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", JobQueueManagement.GetObjCaption(JobQueueEntry)), '');
#endif
        until JobQueueEntry.Next() = 0;

#if (BC17 or BC18 or BC19)
        if CounterProcessed = CounterSelected then begin
#else
        if CounterProcessed <> CounterSelected then begin
            if CounterProcessed > 0 then
                Message(DoneWithErrorsLbl);
            ErrorMessageHandler.InformAboutErrors(Enum::"Error Handling Options"::"Show Error");
            ErrorMessageMgt.PopContext(ErrorContextElement0);
        end else begin
#endif
            Success := true;
            Message(DoneLbl);
        end;
    end;

    internal procedure AssignJobQueueEntryToManagedAndMonitored(ProtectedJob: Boolean; ManagedByApp: Boolean; JobQueueEntry: Record "Job Queue Entry")
    var
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
    begin
        if not ProtectedJob then begin
            if not ManagedByAppJobQueue.Get(JobQueueEntry.ID) then begin
                ManagedByAppJobQueue.Init();
                ManagedByAppJobQueue.ID := JobQueueEntry.ID;
                ManagedByAppJobQueue."Managed by App" := ManagedByApp;
                ManagedByAppJobQueue.Insert();
            end else begin
                ManagedByAppJobQueue."Managed by App" := ManagedByApp;
                ManagedByAppJobQueue.Modify();
            end;
        end;

        AddMonitoredJobQueueEntry(JobQueueEntry);
    end;

    internal procedure ManuallyCreateNewMonitoredJQEntry()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        TempJQEntry: Record "Job Queue Entry" temporary;
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
    begin
        JQRefreshSetup.GetSetup();
        TempJQEntry.Init();
        TempJQEntry.Status := TempJQEntry.Status::"On Hold";
        TempJQEntry.Insert(true);
        if Page.RunModal(Page::"NPR Monitored JQ Entry Card", TempJQEntry) = Action::LookupOK then begin
            MonitoredJQEntry.Init();
            MonitoredJQEntry."Entry No." := 0;
            MonitoredJQEntry.TransferFields(TempJQEntry);
            MonitoredJQEntry.Insert();

            RefreshJobQueueEntry.RefreshJobQueueEntry(MonitoredJQEntry, false);
            MonitoredJQEntry.Modify();
        end;
    end;

    internal procedure ManuallyModifyExistingMonitoredJQEntry(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    var
        TempJQEntry: Record "Job Queue Entry" temporary;
        TempxJQEntry: Record "Job Queue Entry" temporary;
    begin
        TempJQEntry.TransferFields(MonitoredJQEntry, false);
        TempJQEntry.Status := TempJQEntry.Status::"On Hold";
        Clear(TempJQEntry."System Task ID");
        Clear(TempJQEntry.ID);
        TempJQEntry.Insert(false);
        TempxJQEntry := TempJQEntry;
        if Page.RunModal(Page::"NPR Monitored JQ Entry Card", TempJQEntry) = Action::LookupOK then begin
            if Format(TempxJQEntry) <> Format(TempJQEntry) then begin
                MonitoredJQEntry.TransferFields(TempJQEntry);
                MonitoredJQEntry.Modify();
            end;
        end;
    end;

    internal procedure ShowRefreshOverwriteNotification(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        RefreshOverwriteNotification: Notification;
        RefreshOverwritesMsg: Label 'This job is monitored by the Job Queue Refresher. The changes made to this job queue entry will be overwritten when the refresher runs. To keep a change, make it on the monitored job.';
        ShowMonitoredJobLbl: Label 'Show monitored job';
    begin
        if not RefreshJobQueueEntry.WillOverwrite(JobQueueEntry) then
            exit(false);
        RefreshOverwriteNotification.Id := RefreshOverwriteNotificationId();
        RefreshOverwriteNotification.Message := RefreshOverwritesMsg;
        RefreshOverwriteNotification.SetData('JobQueueEntryID', Format(JobQueueEntry.ID));
        RefreshOverwriteNotification.AddAction(ShowMonitoredJobLbl, Codeunit::"NPR Monitored Job Queue Mgt.", 'ShowMonitoredJobFromNotification');
        RefreshOverwriteNotification.Send();
        exit(true);
    end;

    internal procedure RecallRefreshOverwriteNotification()
    var
        RefreshOverwriteNotification: Notification;
    begin
        RefreshOverwriteNotification.Id := RefreshOverwriteNotificationId();
        RefreshOverwriteNotification.Recall();
    end;

    internal procedure ShowMonitoredJobFromNotification(RefreshOverwriteNotification: Notification)
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueEntryID: Guid;
    begin
        if not Evaluate(JobQueueEntryID, RefreshOverwriteNotification.GetData('JobQueueEntryID')) then
            exit;
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntryID);
        Page.Run(Page::"NPR Monitored JQ Entries", MonitoredJQEntry);
    end;

    local procedure RefreshOverwriteNotificationId(): Guid
    var
        NotificationId: Guid;
        NotificationIdTok: Label '5a9c7e21-6f0b-4b6e-9d0a-3c2e8f4b7d15', Locked = true;
    begin
        Evaluate(NotificationId, NotificationIdTok);
        exit(NotificationId);
    end;

    internal procedure CheckJobBeforeAddingToMonitored(JobQueueEntry: Record "Job Queue Entry")
    var
        OnlyRecurringJobsSupportedErr: Label 'Only recurring jobs queue entries can be set up as monitored jobs.';
    begin
        If not JobQueueEntry."Recurring Job" then
            Error(OnlyRecurringJobsSupportedErr);
        if JobCanMoveAcrossDays(JobQueueEntry) then
            ConfirmPossibleShiftBetweenDays();
    end;

    local procedure JobCanMoveAcrossDays(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ReferenceDateTime: DateTime;
        WSUserTimeZoneAdjustedDateTime: DateTime;
    begin
        if JobQueueEntry."Starting Time" = 0T then
            exit;
        if (JobQueueEntry."Run on Mondays" or
            JobQueueEntry."Run on Tuesdays" or
            JobQueueEntry."Run on Wednesdays" or
            JobQueueEntry."Run on Tuesdays" or
            JobQueueEntry."Run on Fridays" or
            JobQueueEntry."Run on Saturdays" or
            JobQueueEntry."Run on Sundays")
           and not
           (JobQueueEntry."Run on Mondays" and
            JobQueueEntry."Run on Tuesdays" and
            JobQueueEntry."Run on Wednesdays" and
            JobQueueEntry."Run on Tuesdays" and
            JobQueueEntry."Run on Fridays" and
            JobQueueEntry."Run on Saturdays" and
            JobQueueEntry."Run on Sundays")
        then begin
            if not (JQRefreshSetup.Get() and JQRefreshSetup."Use External JQ Refresher") then
                exit;
            MonitoredJQEntry."Starting Time" := JobQueueEntry."Starting Time";
            MonitoredJQEntry."Time Zone" := JobQueueEntry."NPR Time Zone";
            ReferenceDateTime := CreateDateTime(Today(), JobQueueEntry."Starting Time");
            WSUserTimeZoneAdjustedDateTime := ReferenceDateTime + MonitoredJQEntry.CalculateTimeOffset(JQRefreshSetup);
            exit(DT2Date(ReferenceDateTime) <> DT2Date(WSUserTimeZoneAdjustedDateTime));
        end;
    end;

    local procedure ConfirmPossibleShiftBetweenDays()
    var
        RunDayShiftQst: Label 'You have configured a "day of the week" limit together with a time period that can move across days when converted to UTC0. Please ensure that the days you have selected match your expectations in the UTC0 time zone as well.\\Do you want to proceed with the current operation?';
    begin
        if not Confirm(RunDayShiftQst, true) then
            Error('');
    end;

    internal procedure DeleteMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
    begin
        if ManagedByAppJobQueue.Get(JobQueueEntry.ID) then
            ManagedByAppJobQueue.Delete();
        RemoveMonitoredJobQueueEntry(JobQueueEntry);

        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;
#if not (BC17 or BC18 or BC19)
    var
        _IsNPJobErr: Label 'Job Queue Entry ''%1 %2 %3'' is a NaviPartner protected job and cannot be added manually. It will be automatically added to the list of monitored jobs the next time the job queue refresher runs.';
#endif
}