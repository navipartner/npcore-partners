codeunit 85245 "NPR JQ Refresher Test Helper"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshserCheckIfCreateMissingCustomJobs, '', false, false)]
    local procedure SetCreateMissingCustomJobsTrue(var Create: Boolean)
    begin
        Create := true;
    end;
}
