// While an instance is bound, "NPR License Mgt.".IsEnforcementActive() is true. Bind it in a LOCAL variable:
// the binding then ends with the test, also when the test fails. Bind it BEFORE initializing the POS session
// when the test needs the session-start license check (the "NPR POS Session".OnInitialize subscriber).
codeunit 85549 "NPR License Enforcement Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR License Mgt.", OnForceEnforcementForTest, '', false, false)]
    local procedure ForceEnforcement(var Force: Boolean)
    begin
        Force := true;
    end;
}
