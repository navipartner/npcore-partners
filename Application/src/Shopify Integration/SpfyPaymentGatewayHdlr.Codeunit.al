#if not BC17
codeunit 6184821 "NPR Spfy Payment Gateway Hdlr" implements "NPR IPaymentGateway"
{
    Access = Internal;

    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
    begin
        InitNcTaskFromPmtRequest(Request, TempNcTask);
        SpfyCapturePayment.CaptureShopifyPayment(TempNcTask, false);
        SetResponse(TempNcTask, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
    begin
        InitNcTaskFromPmtRequest(Request, TempNcTask);
        SpfyCapturePayment.RefundShopifyPayment(TempNcTask, false);
        SetResponse(TempNcTask, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        NotSupportedMsg: Label 'Cancellation requests are not supported for Shopify payments. Please try to cancel the payment directly with Shopify.';
    begin
        Message(NotSupportedMsg);
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

    local procedure InitNcTaskFromPmtRequest(Request: Record "NPR PG Payment Request"; var NcTask: Record "NPR Nc Task")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if IsNullGuid(Request."Document System Id") or IsNullGuid(Request."Payment Line System Id") then
            Error('');  //usupported request

        Clear(NcTask);
        case Request."Document Table No." of
            Database::"Sales Header":
                begin
                    if not SalesHeader.GetBySystemId(Request."Document System Id") then
                        Error('');  //doc not found
                    NcTask."Record ID" := SalesHeader.RecordId();
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesInvHeader.RecordId();
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesCrMemoHeader.RecordId();
                end;
            else
                Error('');  //usupported request
        end;

        PaymentLine.GetBySystemId(Request."Payment Line System Id");
        NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        NcTask."Table No." := Database::"NPR Magento Payment Line";
        NcTask."Record ID" := PaymentLine.RecordId();
    end;

    local procedure SetResponse(var NcTask: Record "NPR Nc Task"; var Response: Record "NPR PG Payment Response")
    begin
        Response."Response Success" := true;
        Response."Response Body" := NcTask.Response;
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