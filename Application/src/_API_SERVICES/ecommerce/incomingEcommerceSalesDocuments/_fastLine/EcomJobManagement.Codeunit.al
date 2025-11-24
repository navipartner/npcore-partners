codeunit 6248560 "NPR Ecom Job Management"
{
    Access = Internal;

    internal procedure CreateParameterSting(): text
    var
        ParamScope: Label '=1..100', Locked = true;
    begin
        exit(ParamBucketFilter() + ParamScope);
    end;

    internal procedure ParamBucketFilter(): Text
    Var
        BucketLbl: label 'bucket', Locked = true;
    begin
        exit(BucketLbl);
    end;


    internal procedure OpenJobQueueList()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomCreateVoucherJQ: Codeunit "NPR EcomCreateVoucherJQ";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Setfilter("Object ID to Run", '%1', EcomCreateVoucherJQ.GetCodeunitId());
        Page.Run(0, JobQueueEntry);
    end;

    internal procedure ScheduleJobQueue(CodeunitId: Integer; JobDescription: text)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        if not JobQueueEntry.FindSet() then begin
            JobQueueEntry."Parameter String" := CopyStr(CreateParameterSting(), 1, MaxStrLen(JobQueueEntry."Parameter String"));
            JobQueueEntry.Description := CopyStr(JobDescription, 1, MaxStrLen(JobQueueEntry.Description));
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
            JobQueueEntry."Object ID to Run" := CodeunitId;
            ScheduleJobQueue(JobQueueEntry);
        end else
            repeat
                ScheduleJobQueue(JobQueueEntry);
            until JobQueueEntry.Next() = 0;
    end;

    local procedure ScheduleJobQueue(JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueMgt.SetJobTimeout(7, 0); //shouldn't be less than loop in the specific job queue
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            JobQueueEntry."Object ID to Run",
            JobQueueEntry."Parameter String",
             JobQueueEntry.Description,
             CreateDateTime(Today(), 070000T),
                1,
                '',
                JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);

    end;

    internal procedure DurationLimitReached(StartDateTime: DateTime; DurationLimit: Duration): Boolean
    begin
        exit(CurrentDateTime - StartDateTime >= DurationLimit);
    end;
}