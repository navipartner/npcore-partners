codeunit 6060081 "NPR POS Paym. Bin Eject Public"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    procedure OnSelectDefaultPrintTemplate(var TemplateCode: Code[20]; InvokeParameterName: Text; POSPaymentBin: Record "NPR POS Payment Bin"; var IsHandled: Boolean)
    begin
    end;
}