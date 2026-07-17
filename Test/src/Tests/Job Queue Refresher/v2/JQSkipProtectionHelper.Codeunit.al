codeunit 85272 "NPR JQ Skip Protection Helper"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeUpdateNPMonitoredJobs, '', false, false)]
    local procedure DisableNPProtection(var Skip: Boolean; var Handled: Boolean)
    begin
        // Mirrors a downstream PTE that turns NP protection off globally via the sanctioned subscriber.
        Skip := true;
    end;
}
