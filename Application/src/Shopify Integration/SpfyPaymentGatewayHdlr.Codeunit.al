#if not BC17
codeunit 6184821 "NPR Spfy Payment Gateway Hdlr" implements "NPR IPaymentGateway"
{
    Access = Internal;
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if not SpfyPaymentGateway.Get(PaymentGatewayCode) then begin
            SpfyPaymentGateway.Init();
            SpfyPaymentGateway.Code := PaymentGatewayCode;
            SpfyPaymentGateway.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR Spfy Payment Gateway Card", SpfyPaymentGateway);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemoveShopifyPaymentGatewaySetup(var Rec: Record "NPR Magento Payment Gateway")
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if Rec.IsTemporary() then
            exit;

        if SpfyPaymentGateway.Get(Rec.Code) then
            SpfyPaymentGateway.Delete(true);
    end;
}
#endif