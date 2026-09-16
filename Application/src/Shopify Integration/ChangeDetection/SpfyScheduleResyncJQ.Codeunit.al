codeunit 6151267 "NPR Spfy Schedule Resync JQ"
{
    Access = Internal;
    TableNo = "NPR Spfy Resync Run";

    trigger OnRun()
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        Parameters: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        RunResyncLbl: Label 'Shopify re-sync run (one-time)';
        CouldNotScheduleErr: Label 'The background re-sync could not be scheduled because task scheduling is not available in this environment. Run the re-sync in the foreground instead.';
    begin
        Clear(Parameters);
        Parameters."Object Type to Run" := Parameters."Object Type to Run"::Codeunit;
        Parameters."Object ID to Run" := Codeunit::"NPR Spfy Resync Worker";
        Parameters."Earliest Start Date/Time" := JobQueueMgt.NowWithDelayInSeconds(10);
        Parameters.Description := CopyStr(RunResyncLbl, 1, MaxStrLen(Parameters.Description));
        Parameters."Notify On Success" := false;
        Parameters."NPR NP Protected Job" := true;
        // Stamped so the worker executes exactly this run row — never FindLast.
        Parameters."Record ID to Process" := Rec.RecordId();

        JobQueueMgt.SetProtected(true);
        // Both false returns must error (never silent success); LaunchRun fails the run and releases the marker.
        if not JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry) then
            Error(CouldNotScheduleErr);
        if not JobQueueMgt.ActivateJobQueueEntry(JobQueueEntry) then
            Error(CouldNotScheduleErr);
    end;
}
