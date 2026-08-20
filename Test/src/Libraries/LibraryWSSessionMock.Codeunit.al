codeunit 85384 "NPR Library - WS Session Mock"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Time Zone Mgt.", 'OnAfterIsWebserviceSession', '', false, false)]
    local procedure OnAfterIsWebserviceSession(var IsWebserviceSession: Boolean)
    begin
        IsWebserviceSession := true;
    end;
}
