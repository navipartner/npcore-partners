codeunit 6248633 "NPR Add Job Queue To Monitored"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        NotProtectedJob: Boolean;
        JobQueueEntryIsEmpty: Label 'Job Queue Entry record was not found.';
        MonitoredEntryAlreadyExistsErr: Label 'Monitored Job ''%1 %2 %3'' already exists!';
    begin
        if IsNullGuid(Rec.ID) then
            Error(JobQueueEntryIsEmpty);

        MonitoredJQEntry.SetRange("Job Queue Entry ID", Rec.ID);
        if not MonitoredJQEntry.IsEmpty() then
            Error(MonitoredEntryAlreadyExistsErr, Rec."Object Type to Run", Rec."Object ID to Run", JobQueueMgt.GetObjCaption(Rec));

        JobQueueMgt.JobQueueIsManagedByApp(Rec, NotProtectedJob);

        MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(NotProtectedJob, true, Rec);
    end;


}
