codeunit 6151395 "NPR Spfy Sched. Bg Migration"
{
    Access = Internal;

    trigger OnRun()
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        Parameters: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        RunMigrationLbl: Label 'Shopify RowVersion migration (seed + cutover, one-time)';
        CouldNotScheduleErr: Label 'The background migration could not be scheduled. Make sure task scheduling is available in this environment and try again, or run the migration in the foreground.';
    begin
        Clear(Parameters);
        Parameters."Object Type to Run" := Parameters."Object Type to Run"::Codeunit;
        Parameters."Object ID to Run" := Codeunit::"NPR Spfy RowVersion Migration";
        Parameters."Earliest Start Date/Time" := JobQueueMgt.NowWithDelayInSeconds(10);
        Parameters.Description := CopyStr(RunMigrationLbl, 1, MaxStrLen(Parameters.Description));
        Parameters."Notify On Success" := false;
        Parameters."NPR NP Protected Job" := true;

        JobQueueMgt.SetProtected(true);
        // Fail if the entry cannot be created, so we don't report success while nothing runs.
        if not JobQueueMgt.InitRecurringJobQueueEntry(Parameters, JobQueueEntry) then
            Error(CouldNotScheduleErr);
        if JobQueueMgt.ActivateJobQueueEntry(JobQueueEntry) then
            exit;
        // A delegated administrator cannot start scheduled tasks; the entry is left on hold and the caller tells the operator.
        if not JobQueueEntry.Get(JobQueueEntry.ID) or JobQueueEntry."NPR Manually Set On Hold" then
            Error(CouldNotScheduleErr);
    end;
}
