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

    internal procedure RefreshJobQueueEntries()
    var
        JQMonitorEntry: Record "NPR Monitored Job Queue Entry";
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        JQRefreshSetup.GetSetup();
        if JQRefreshSetup."Use External JQ Refresher" then begin
            if (JQRefreshSetup."Default Refresher User Name" <> '') and (JQRefreshSetup."Default Refresher User Name" = UserID) then
                JQMonitorEntry.SetFilter("JQ Runner User Name", '%1|%2', UserID, '')
            else
                JQMonitorEntry.SetRange("JQ Runner User Name", UserID);
        end;

        if JQMonitorEntry.FindSet() then
            repeat
                RefreshOneJobQueueEntry(JQMonitorEntry);
            until JQMonitorEntry.Next() = 0;
    end;

    local procedure RefreshOneJobQueueEntry(JQMonitorEntry: Record "NPR Monitored Job Queue Entry")
    begin
        if Codeunit.Run(Codeunit::"NPR Refresh Job Queue Entry", JQMonitorEntry) then
            exit;
        if JQMonitorEntry.Find() then begin
            JQMonitorEntry.SetErrorMessage(GetLastErrorText());
            JQMonitorEntry."Last Refresh Status" := JQMonitorEntry."Last Refresh Status"::Error;
            JQMonitorEntry.Modify();
            Commit();
        end;
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
#if not (BC17 or BC18 or BC19)
    var
        _IsNPJobErr: Label 'Job Queue Entry ''%1 %2 %3'' is a NaviPartner protected job and cannot be added manually. It will be automatically added to the list of monitored jobs the next time the job queue refresher runs.';
#endif
}