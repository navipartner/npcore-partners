codeunit 6059864 "NPR POS Page Stack Check"
{
    //manually bound at the start of the POS page triggers, so it will only return true when polled inside a POS trigger stack

    Access = Internal;
    EventSubscriberInstance = Manual;

    procedure CurrentStackWasStartedByPOSTrigger() Result: Boolean
    begin
        OnCurrentStackWasStartedByPOSTriggerPublisher(Result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Page Stack Check", 'OnCurrentStackWasStartedByPOSTriggerPublisher', '', false, false)]
    local procedure OnCurrentStackWasStartedByPOSTrigger(var Result: Boolean)
    begin
        Result := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCurrentStackWasStartedByPOSTriggerPublisher(var Result: Boolean)
    begin
    end;


}