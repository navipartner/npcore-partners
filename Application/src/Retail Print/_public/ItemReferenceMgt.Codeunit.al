codeunit 6151075 "NPR Item Reference Mgt."
{
    SingleInstance = true;
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDiscontinueBarcode(var POSSale: Record "NPR POS Sale"; var IsHandled: Boolean)
    begin
    end;
}