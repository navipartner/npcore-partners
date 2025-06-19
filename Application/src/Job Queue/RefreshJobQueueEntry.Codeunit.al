codeunit 6248478 "NPR Refresh Job Queue Entry"
{
    Access = Internal;
    TableNo = "NPR Monitored Job Queue Entry";

    trigger OnRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JQMonitorEntry: Record "NPR Monitored Job Queue Entry";
        JQMonitorEntry2: Record "NPR Monitored Job Queue Entry";
        xJQMonitorEntry: Record "NPR Monitored Job Queue Entry";
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotProtectedJob: Boolean;
        ProcessMonitoredJob: Boolean;
    begin
        JQMonitorEntry := Rec;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        JQMonitorEntry.ReadIsolation := IsolationLevel::UpdLock;
#else
        JQMonitorEntry.LockTable();
#endif
        JQMonitorEntry.Find();
        xJQMonitorEntry := JQMonitorEntry;
        Clear(JQMonitorEntry."Last Error Message");
        JQRefreshSetup.GetSetup();

        if not IsNullGuid(JQMonitorEntry."Job Queue Entry ID") then
            ProcessMonitoredJob := JobQueueEntry.Get(JQMonitorEntry."Job Queue Entry ID");
        if not ProcessMonitoredJob then begin
            Clear(JQMonitorEntry."Job Queue Entry ID");
            JobQueueEntry.TransferFields(JQMonitorEntry, false);
        end;
        JobQueueMgt.JobQueueIsManagedByApp(JobQueueEntry, NotProtectedJob);
        if not ProcessMonitoredJob then
            ProcessMonitoredJob := not NotProtectedJob or JQRefreshSetup.CreateMissingCustomJQs();
        if ProcessMonitoredJob then begin
            JQMonitorEntry2 := JQMonitorEntry;
            JQMonitorEntry2.ChangeJobTimeZoneToWebserviceTimezone(JQRefreshSetup);
            if not JQRefreshSetup."Use External JQ Refresher" then
                JQMonitorEntry2."JQ Runner User Name" := ''
            else
                if JQMonitorEntry2."JQ Runner User Name" = '' then
                    JQMonitorEntry2."JQ Runner User Name" := JQRefreshSetup."Default Refresher User Name";
            RefreshJobQueueEntry(JQMonitorEntry2, NotProtectedJob);
            JQMonitorEntry."Earliest Start Date/Time" := JQMonitorEntry2."Earliest Start Date/Time";
            JQMonitorEntry."Job Queue Entry ID" := JQMonitorEntry2."Job Queue Entry ID";
            JQMonitorEntry."Last Refresh Status" := JQMonitorEntry."Last Refresh Status"::Success
        end else
            JQMonitorEntry."Last Refresh Status" := JQMonitorEntry."Last Refresh Status"::" ";

        if Format(JQMonitorEntry) <> Format(xJQMonitorEntry) then
            JQMonitorEntry.Modify();
    end;

    internal procedure RefreshJobQueueEntry(var JQMonitorEntry: Record "NPR Monitored Job Queue Entry"; NotProtectedJob: Boolean): Boolean
    var
        Parameters: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        clear(Parameters);
        Parameters.TransferFields(JQMonitorEntry, false);
        Parameters.ID := JQMonitorEntry."Job Queue Entry ID";
        Parameters."User ID" := JQMonitorEntry."JQ Runner User Name";
        if JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry) then begin
            if NotProtectedJob then begin
                if ManagedByApp.Get(JobQueueEntry.ID) then begin
                    if not ManagedByApp."Managed by App" then begin
                        ManagedByApp."Managed by App" := true;
                        ManagedByApp.Modify();
                    end;
                end else begin
                    ManagedByApp.Init();
                    ManagedByApp.ID := JobQueueEntry.ID;
                    ManagedByApp."Managed by App" := true;
                    ManagedByApp.Insert();
                end;
            end;
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            JQMonitorEntry."Earliest Start Date/Time" := JobQueueEntry."Earliest Start Date/Time";
            JQMonitorEntry."Job Queue Entry ID" := JobQueueEntry.ID;
            exit(true);
        end;
    end;
}