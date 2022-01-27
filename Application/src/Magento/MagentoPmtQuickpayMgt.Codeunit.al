codeunit 6151417 "NPR Magento Pmt. Quickpay Mgt."
{
    Access = Internal;
    var
        Text000: Label 'Quickpay error:\%1 - %2  \%3';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsQuickpayPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', false, false)]
    local procedure RefundPaymentSalesCrMemo(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsQuickpayRefundLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Cr.Memo Header" then
            exit;

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today();
        PaymentLine.Modify(true);
    end;

    #region Create Request

    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        JsonBody: JsonObject;
        HttpWebRequest: HttpRequestMessage;
        RequestBodyText: Text;
    begin
        JsonBody.Add("RequestParameter.Id"(), PaymentLine."No.");
        JsonBody.Add("RequestParameter.Amount"(), ConvertToQuickPayAmount(PaymentLine.Amount));
        JsonBody.WriteTo(RequestBodyText);
        SetupHttpWebRequest(HttpWebRequest, CopyStr("RequestMethod.Post"(), 1, 10), PaymentLine, "ServiceName.Capture"(), RequestBodyText);
        SendWebRequest(HttpWebRequest);
    end;

    local procedure Refund(PaymentLine: Record "NPR Magento Payment Line")
    var
        JsonBody: JsonObject;
        HttpWebRequest: HttpRequestMessage;
        RequestBodyText: Text;
    begin
        JsonBody.Add("RequestParameter.Id"(), PaymentLine."No.");
        JsonBody.Add("RequestParameter.Amount"(), ConvertToQuickPayAmount(PaymentLine.Amount));
        JsonBody.WriteTo(RequestBodyText);
        SetupHttpWebRequest(HttpWebRequest, CopyStr("RequestMethod.Post"(), 1, 10), PaymentLine, "ServiceName.Refund"(), RequestBodyText);
        SendWebRequest(HttpWebRequest);
    end;

    #endregion

    #region Aux

    local procedure CreateBasicAuth(ApiUsername: Text; ApiPassword: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit('Basic ' + Base64Convert.ToBase64(ApiUsername + ':' + ApiPassword, TextEncoding::UTF8));
    end;

    local procedure ConvertToQuickPayAmount(Amount: Decimal) QuickpayAmount: Text
    begin
        QuickpayAmount := DelChr(Format(Amount * 100, 0, 9), '=', '.');
        exit(QuickpayAmount);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Pmt. Quickpay Mgt.");
    end;

    procedure IsQuickpayPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    procedure IsQuickpayRefundLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
    end;

    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage)
    var
        Client: HttpClient;
        HttpWebResponse: HttpResponseMessage;
        Response: Text;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        HttpWebResponse.Content.ReadAs(Response);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(Text000, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);
    end;

    local procedure SetupHttpWebRequest(var HttpWebRequest: HttpRequestMessage; RequestMethod: Code[10]; PaymentLine: Record "NPR Magento Payment Line"; RequestService: Text; RequestBody: Text)
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        if PaymentGateway.Get(PaymentLine."Payment Gateway Code") then begin
            Content.WriteFrom(RequestBody);
            HttpWebRequest.GetHeaders(HeadersReq);
            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            Headers.Add('accept-version', 'v10');
            HeadersReq.Add('Authorization', CreateBasicAuth('', PaymentGateway.GetApiPassword()));

            HttpWebRequest.Content(Content);
            HttpWebRequest.SetRequestUri(PaymentGateway."Api Url" + '/' + PaymentLine."No." + '/' + RequestService);
            HttpWebRequest.Method := RequestMethod;
        end;
    end;

    #endregion
# pragma warning disable AA0228
    local procedure "RequestMethod.Post"(): Text
    begin
        exit('POST');
    end;

    local procedure "RequestParameter.Amount"(): Text
    begin
        exit('amount');
    end;

    local procedure "RequestParameter.Id"(): Text
    begin
        exit('id');
    end;

    local procedure "ServiceName.Capture"(): Text
    begin
        exit('capture');
    end;


    local procedure "ServiceName.Refund"(): Text
    begin
        exit('refund');
    end;
# pragma warning disable AA0228

    procedure IsNaviConnectPayment(var SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        exit(PaymentLine.FindFirst());
    end;

    procedure CaptureSalesInvHeader(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if SalesInvoiceHeader."Order No." = '' then
            exit(false);

        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.SetRange("Date Captured", 0D);
        if PaymentLine.FindSet() then
            repeat
                Commit();
                Capture(PaymentLine);
                PaymentLine."Date Captured" := Today();
                PaymentLine.Modify();
                Commit();
            until PaymentLine.Next() = 0;
        exit(true);
    end;
}
