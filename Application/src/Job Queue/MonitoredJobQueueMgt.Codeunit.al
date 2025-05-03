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

    internal procedure AddMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry"; NpManagedJob: Boolean)
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        xMonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
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
        if not MonitoredJQEntry.FindFirst() then begin
            MonitoredJQEntry.Init();
            MonitoredJQEntry."Entry No." := 0;
            MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;
            MonitoredJQEntry.Insert();
        end;
        xMonitoredJQEntry := MonitoredJQEntry;
        JobQueueEntry.CalcFields(XML);
        MonitoredJQEntry.TransferFields(JobQueueEntry, false);
        MonitoredJQEntry."NP Managed Job" := NpManagedJob;
        MonitoredJQEntry."Job Queue Entry ID" := JobQueueEntry.ID;
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
            MonitoredJQEntry.DeleteAll();
        JobQueueManagement.RefreshNPRJobQueueList(false);
        if not ManagedByAppJobQueue.IsEmpty() then
            repeat
                if JobQueueEntry.Get(ManagedByAppJobQueue.ID) then begin
                    if not JobQueueManagement.SkipUpdateNPManagedMonitoredJobs() and JobQueueManagement.IsNPRecurringJob(JobQueueEntry) then
                        ManagedByAppJobQueue.Delete()
                    else
                        if ManagedByAppJobQueue."Managed by App" then
                            AddMonitoredJobQueueEntry(JobQueueEntry, false);
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
        IsNPJob: Boolean;
        ManagedByApp: Boolean;
        NotMandatoryJob: Boolean;
        IsNPJobErr: Label 'Job Queue Entry ''%1 %2 %3'' can not be added manually.';
        MonitoredEntryAlreadyExistsErr: Label 'Monitored Job Queue Entry ''%1 %2 %3'' already exists!';
    begin
        JobQueueEntries.LookupMode := true;
        if not (JobQueueEntries.RunModal() = Action::LookupOK) then
            exit;

        JobQueueEntries.GetRecord(JobQueueEntry);

        IsNPJob := JobQueueManagement.IsNPRecurringJob(JobQueueEntry);
        if IsNPJob then
            Error(IsNPJobErr, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", GetObjCaption(JobQueueEntry));

        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        if not MonitoredJQEntry.IsEmpty() then begin
            Error(MonitoredEntryAlreadyExistsErr, JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run", GetObjCaption(JobQueueEntry));
        end;

        ManagedByApp := JobQueueManagement.JobQueueIsManagedByApp(JobQueueEntry, NotMandatoryJob);
        AssignJobQueueEntryToManagedAndMonitored(NotMandatoryJob, ManagedByApp, JobQueueEntry);
        exit(true);
    end;

    local procedure GetObjCaption(JobQueueEntry: Record "Job Queue Entry"): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption.Get(JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run");
        exit(AllObjWithCaption."Object Caption");
    end;

    internal procedure AssignJobQueueEntryToManagedAndMonitored(NotMandatoryJob: Boolean; ManagedByApp: Boolean; JobQueueEntry: Record "Job Queue Entry")
    var
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
    begin
        if NotMandatoryJob and not ManagedByAppJobQueue.Get(JobQueueEntry.ID) then begin
            ManagedByAppJobQueue.Init();
            ManagedByAppJobQueue.ID := JobQueueEntry.ID;
            ManagedByAppJobQueue."Managed by App" := ManagedByApp;
            ManagedByAppJobQueue.Insert();
        end;

        AddMonitoredJobQueueEntry(JobQueueEntry, ManagedByApp);
    end;
}