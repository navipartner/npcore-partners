#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
codeunit 85627 "NPR Inv. Items Changed JQ Hold"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeInsertRecurringJobQueueEntry, '', false, false)]
    local procedure HoldNewJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SetManualHold(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeModifyUpdatedJobQueueEntry, '', false, false)]
    local procedure HoldUpdatedJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SetManualHold(JobQueueEntry);
    end;

    // Covers the paths that reach EnqueueTask, which the manual hold does not stop.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", OnBeforeJobQueueScheduleTask, '', false, false)]
    local procedure KeepOffScheduler(var JobQueueEntry: Record "Job Queue Entry"; var DoNotScheduleTask: Boolean)
    begin
        if IsItemsChangedJob(JobQueueEntry) then
            DoNotScheduleTask := true;
    end;

    local procedure SetManualHold(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if IsItemsChangedJob(JobQueueEntry) then
            JobQueueEntry."NPR Manually Set On Hold" := true;
    end;

    local procedure IsItemsChangedJob(JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        exit((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
            (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Inv. Items Changed JQ"));
    end;
}
#endif
