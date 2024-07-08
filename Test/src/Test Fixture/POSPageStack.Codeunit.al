codeunit 85156 "NPR POS Page Stack"
{
    //Sets POS Page stack to true when running tests against a POS Session mock so prints are treated the same as in a real POS session.

    SingleInstance = true;

    var
        _IsPOSStack: Boolean;

    procedure SetIsPOSStack(value: Boolean)
    begin
        _IsPOSStack := value;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Page Stack Check", 'OnCurrentStackWasStartedByPOSTriggerPublisher', '', false, false)]
    local procedure OnCurrentStackWasStartedByPOSTrigger(var Result: Boolean)
    begin
        Result := _IsPOSStack;
    end;

}