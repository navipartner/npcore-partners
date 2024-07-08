codeunit 6151598 "NPR POS Action: Process BeId"
{
    [IntegrationEvent(false, false)]
    internal procedure OnProcessCardData(var POSStore: Record "NPR POS Store"; var POSUnit: Record "NPR POS Unit"; var SalePOS: Record "NPR POS Sale"; var Salesperson: Record "Salesperson/Purchaser"; var HwcResponse: JsonObject; var IsHandled: Boolean; var Result: JsonObject)
    begin
    end;
}