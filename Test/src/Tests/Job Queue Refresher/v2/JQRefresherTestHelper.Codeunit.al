codeunit 85245 "NPR JQ Refresher Test Helper"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshserCheckIfCreateMissingCustomJobs', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshserCheckIfCreateMissingCustomJobs, '', false, false)]
#endif
    local procedure SetCreateMissingCustomJobsTrue(var Create: Boolean)
    begin
        Create := true;
    end;
}
