codeunit 6184724 "NPR Update JQ OnHold Status"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeSetStatusValue', '', false, false)]
    local procedure SetIfManuallySetOnHold(var JobQueueEntry: Record "Job Queue Entry"; var xJobQueueEntry: Record "Job Queue Entry"; var NewStatus: Option)
    begin
        if NewStatus = JobQueueEntry.Status::"On Hold" then
            JobQueueEntry."NPR Manually Set On Hold" := true;
    end;
}