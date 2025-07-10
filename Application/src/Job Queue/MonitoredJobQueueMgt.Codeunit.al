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
        if MonitoredJQEntry.FindFirst() then
            xMonitoredJQEntry := MonitoredJQEntry
        else begin
            Clear(xMonitoredJQEntry);
            MonitoredJQEntry.Init();
            MonitoredJQEntry."Entry No." := 0;
            MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;
            MonitoredJQEntry.Insert();
        end;
        JobQueueEntry.CalcFields(XML);
        MonitoredJQEntry.TransferFields(JobQueueEntry, false);
        // if not IsNullGuid(xMonitoredJQEntry."Job Queue Entry ID") then
        //     if xJobQueueEntry.Get(xMonitoredJQEntry."Job Queue Entry ID") then begin
        //         MonitoredJQEntry."Notif. Profile on Error" := xJobQueueEntry."NPR Notif. Profile on Error";
        //     end;
        if not IsNullGuid(JobQueueEntry.ID) then
            MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;
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
                    if not JobQueueManagement.SkipUpdateNPManagedMonitoredJobs() and JobQueueManagement.IsNPRecurringJob(JobQueueEntry) then
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

    internal procedure LookUpJobQueues(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntries: Page "Job Queue Entries";
        NotProtectedJob: Boolean;
        MonitoredEntryAlreadyExistsErr: Label 'Monitored Job ''%1 %2 %3'' already exists!';
    begin
        JobQueueEntries.LookupMode := true;
        if not (JobQueueEntries.RunModal() = Action::LookupOK) then
            exit;

        JobQueueEntries.GetRecord(JobQueueEntry);

        if not JobQueueManagement.SkipUpdateNPManagedMonitoredJobs() and JobQueueManagement.IsNPRecurringJob(JobQueueEntry) then
            Error(_IsNPJobErr, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", GetObjCaption(JobQueueEntry));

        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        if not MonitoredJQEntry.IsEmpty() then begin
            Error(MonitoredEntryAlreadyExistsErr, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", GetObjCaption(JobQueueEntry));
        end;

        JobQueueManagement.JobQueueIsManagedByApp(JobQueueEntry, NotProtectedJob);
        AssignJobQueueEntryToManagedAndMonitored(NotProtectedJob, true, JobQueueEntry);
        exit(true);
    end;

    local procedure GetObjCaption(JobQueueEntry: Record "Job Queue Entry"): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Get(JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run");
        exit(AllObjWithCaption."Object Caption");
    end;

    internal procedure AssignJobQueueEntryToManagedAndMonitored(NotProtectedJob: Boolean; ManagedByApp: Boolean; JobQueueEntry: Record "Job Queue Entry")
    var
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
    begin
        if NotProtectedJob then begin
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
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
        NotProtectedJob: Boolean;
    begin
        JQRefreshSetup.GetSetup();
        TempJQEntry.Init();
        TempJQEntry.Status := TempJQEntry.Status::"On Hold";
        TempJQEntry.Insert(true);
        if Page.RunModal(Page::"NPR Monitored JQ Entry Card", TempJQEntry) = Action::LookupOK then begin
            JobQueueMgt.JobQueueIsManagedByApp(TempJQEntry, NotProtectedJob);
            if not NotProtectedJob then
                Error(_IsNPJobErr, TempJQEntry."Object Type to Run", TempJQEntry."Object ID to Run", GetObjCaption(TempJQEntry));

            MonitoredJQEntry.Init();
            MonitoredJQEntry."Entry No." := 0;
            MonitoredJQEntry.TransferFields(TempJQEntry);
            MonitoredJQEntry.Insert();

            RefreshJobQueueEntry.RefreshJobQueueEntry(MonitoredJQEntry, NotProtectedJob);
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

    internal procedure IsNPProtectedJob(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        exit(not JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() and JobQueueMgt.IsNPRecurringJob(JobQueueEntry));
    end;

    var
        _IsNPJobErr: Label 'Job Queue Entry ''%1 %2 %3'' is a NaviPartner protected job and cannot be added manually. It will be automatically added to the list of monitored jobs the next time the job queue refresher runs.';
}