codeunit 6151418 "NPR Magento Pmt. Dibs Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsDibsPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
    end;

    procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        HttpWebRequest: HttpRequestMessage;
        CaptureString: Text;
        MD5Key: Text;
    begin
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        if not SalesInvoiceHeader.Get(PaymentLine."Document No.") then
            exit;

        CaptureString += AppendText('merchant', PaymentGateway."Merchant ID");
        CaptureString += AppendText('orderid', SalesInvoiceHeader."External Document No.");
        CaptureString += AppendText('transact', PaymentLine."No.");
        CaptureString += AppendText('amount', ConvertToDIBSAmount(PaymentLine.Amount));
        MD5Key := CalcMD5Key(CaptureString, PaymentGateway);
        CaptureString += AppendText('md5key', MD5Key);
        CaptureString += AppendText('splitpay', 'true');
        CaptureString += AppendText('close', 'false');

        SetupWebRequest(PaymentGateway."Api Url", HttpWebRequest, PaymentLine, "RequestMethod.Post", CaptureString);
        SendWebRequest(HttpWebRequest);
    end;

    procedure AppendText("Key": Text; Value: Text): Text
    var
        Text000: Label '%1=%2&';
    begin
        exit(StrSubstNo(Text000, Key, Value));
    end;

    procedure CalcMD5Key(CaptureString: Text; PaymentGateway: Record "NPR Magento Payment Gateway"): Text
    var
        Crypto: Codeunit "Cryptography Management";
    begin
        exit(Crypto.GenerateHash(PaymentGateway.GetApiPassword() + Crypto.GenerateHash(PaymentGateway."Api Username" + CaptureString, 0), 0));
    end;

    local procedure ConvertToDIBSAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount * 100));
    end;

    local procedure GetErrorMessage(ErrorMgs: Text) ErrorMessage: Text
    begin
        Message(ErrorMgs);
    end;

    procedure IsDibsPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CODEUNIT::"NPR Magento Pmt. Dibs Mgt.");
    end;

    local procedure SetupWebRequest(ApiUrl: Text; var HttpWebRequest: HttpRequestMessage; PaymentLine: Record "NPR Magento Payment Line"; RequestMethod: Code[10]; RequestBody: Text)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        Content.GetHeaders(Headers);
        Content.WriteFrom(RequestBody);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');

        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(ApiUrl);
        HttpWebRequest.Method := RequestMethod;
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
            Error(StrSubstNo('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response));
    end;

    local procedure "RequestMethod.Post"(): Text
    begin
        exit('POST');
    end;
}