codeunit 6014592 "NPR Rep. Get Item Var. Subs."
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Clone Data", 'CheckIfSkipCreateDefaultBarcode', '', false, false)]
    local procedure SkipBarcodeGeneration(var SkipCreateDefaultBarcode: Boolean)
    begin
        SkipCreateDefaultBarcode := true;
    end;
}