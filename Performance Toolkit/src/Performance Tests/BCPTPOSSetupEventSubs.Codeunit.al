codeunit 88107 "NPR BCPT POS Setup Event Subs"
{
    EventSubscriberInstance = Manual;

    var
        POSUnit: Record "NPR POS Unit";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Setup", 'OnBeforeSetPOSUnitOnInitalize', '', false, false)]
    local procedure HandleOnBeforeSetPOSUnitOnInitalize(var UserSetup: Record "User Setup"; var POSUnitRec: Record "NPR POS Unit"; var Handled: Boolean)
    begin
        UserSetup."NPR POS Unit No." := POSUnit."No.";
        POSUnitRec := POSUnit;
        Handled := true;
    end;

    internal procedure SetPOSUnit(NewPOSUnit: Record "NPR POS Unit")
    begin
        POSUnit := NewPOSUnit;
    end;
}