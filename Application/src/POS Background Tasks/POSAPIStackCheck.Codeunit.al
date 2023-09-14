codeunit 6151585 "NPR POS API Stack Check"
{
    //manually bound at the start of the POS ws API, so it will only return true when polled inside a POS trigger stack

    Access = Internal;
    EventSubscriberInstance = Manual;

    procedure CurrentStackWasStartedByPOSAPI() Result: Boolean
    begin
        OnCurrentStackWasStartedByPOSAPIPublisher(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS API Stack Check", 'OnCurrentStackWasStartedByPOSAPIPublisher', '', false, false)]
    local procedure OnCurrentStackWasStartedByPOSAPI(var Result: Boolean)
    begin
        Result := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCurrentStackWasStartedByPOSAPIPublisher(var Result: Boolean)
    begin
    end;


}