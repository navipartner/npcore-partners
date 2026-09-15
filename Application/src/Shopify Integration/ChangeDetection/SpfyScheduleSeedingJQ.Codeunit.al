codeunit 6151238 "NPR Spfy Schedule Seeding JQ"
{
    Access = Internal;

    procedure ScheduleSeedingJob()
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        Parameters: Record "Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        RunSeedingLbl: Label 'Shopify RowVersion baseline seeding (one-time)';
        CouldNotScheduleErr: Label 'The background seeding could not be scheduled. Make sure task scheduling is available in this environment and try again, or run the seeding in the foreground.';
    begin
        Clear(Parameters);
        Parameters."Object Type to Run" := Parameters."Object Type to Run"::Codeunit;
        Parameters."Object ID to Run" := Codeunit::"NPR Spfy Sync State Seeding";
        Parameters."Earliest Start Date/Time" := JobQueueMgt.NowWithDelayInSeconds(10);
        Parameters.Description := CopyStr(RunSeedingLbl, 1, MaxStrLen(Parameters.Description));
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

    procedure SeedingEntryIsOnHold(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Sync State Seeding");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        exit(not JobQueueEntry.IsEmpty());
    end;
}
