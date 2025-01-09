codeunit 6248188 "NPR External POS Sale Events"
{
    Access = Internal;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertPaymentLineFromRestApi(var PaymentLine: Record "NPR External POS Sale Line"; AdditionalEftData: JsonObject)
    begin
    end;
}