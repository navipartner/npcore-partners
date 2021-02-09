codeunit 6151422 "NPR Magento Pmt. Adyen Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', true, true)]
    local procedure OnCapturePayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        Cancel(PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsAdyenRefundLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Cr.Memo Header"]) then
            exit;

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today;
        PaymentLine.Modify(true);
    end;

    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        Request: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ErrorMessage: Text;
        Response: Text;
        ResponseJson: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/capture';

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    CurrencyCode := SalesInvHeader."Currency Code";
                    Reference := SalesInvHeader."No.";
                    if SalesInvHeader."NPR External Order No." <> '' then
                        Reference := SalesInvHeader."NPR External Order No.";
                end;
        end;
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get;
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        Request :=
          '{' +
          '  "originalReference": "' + PaymentLine."No." + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(PaymentLine.Amount) + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + PaymentGateway."Merchant Name" + '"' +
          '}';

        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway.GetApiPassword(), HttpWebRequest, Request);
        ResponseJson := SendWebRequest(HttpWebRequest);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        Response := JsonT.AsValue().AsText();
        if Response <> '[capture-received]' then
            Error(Response);
    end;

    local procedure Cancel(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        Request: Text;
        Reference: Text;
        ErrorMessage: Text;
        Response: Text;
        ResponseJson: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/cancel';

        PaymentLine.TestField("Document Table No.", DATABASE::"Sales Header");
        Reference := PaymentLine."Document No.";

        Request :=
          '{' +
          '  "originalReference": "' + PaymentLine."No." + '",' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + PaymentGateway."Merchant Name" + '"' +
          '}';

        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway.GetApiPassword(), HttpWebRequest, Request);
        ResponseJson := SendWebRequest(HttpWebRequest);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        Response := JsonT.AsValue().AsText();
        if Response <> '[cancel-received]' then
            Error(Response);
    end;

    local procedure Refund(PaymentLine: Record "NPR Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        Request: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ErrorMessage: Text;
        Response: Text;
        ResponseJson: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/refund';

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(PaymentLine."Document No.");
                    CurrencyCode := SalesCrMemoHeader."Currency Code";
                    Reference := SalesCrMemoHeader."No.";
                    if SalesCrMemoHeader."NPR External Order No." <> '' then
                        Reference := SalesCrMemoHeader."NPR External Order No.";
                end;
        end;
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get;
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        Request :=
          '{' +
          '  "originalReference": "' + PaymentLine."No." + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(PaymentLine.Amount) + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + PaymentGateway."Merchant Name" + '"' +
          '}';

        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway.GetApiPassword(), HttpWebRequest, Request);
        ResponseJson := SendWebRequest(HttpWebRequest);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        Response := JsonT.AsValue().AsText();
        if Response <> '[refund-received]' then
            Error(Response);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPaymentLine(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPaymentLine(var Rec: Record "NPR Magento Payment Line"; var xRec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
    end;

    local procedure UpsertShopperRef(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        PrevRec: Text;
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Payment Gateway Shopper Ref." = '' then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Header" then
            exit;
        if not SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.") then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;

        if not EFTShopperRecognition.Get(EFTAdyenCloudIntegration.IntegrationType(), PaymentLine."Payment Gateway Shopper Ref.") then begin
            EFTShopperRecognition.Init;
            EFTShopperRecognition."Integration Type" := EFTAdyenCloudIntegration.IntegrationType();
            EFTShopperRecognition."Shopper Reference" := PaymentLine."Payment Gateway Shopper Ref.";
            EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
            EFTShopperRecognition."Entity Key" := SalesHeader."Sell-to Customer No.";
            EFTShopperRecognition.Insert(true);
        end;

        PrevRec := Format(EFTShopperRecognition);

        EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
        EFTShopperRecognition."Entity Key" := SalesHeader."Sell-to Customer No.";

        if PrevRec <> Format(EFTShopperRecognition) then
            EFTShopperRecognition.Modify(true);
    end;

    local procedure InitWebRequest(Url: Text; Username: Text; Password: Text; var HttpWebRequest: HttpRequestMessage; RequestBody: Text)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);
        Content.WriteFrom(RequestBody);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        HeadersReq.Add('Authorization', CreateBasicAuth(Username, Password));

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'POST';
    end;

    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage): Text
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
        exit(Response);
    end;

    local procedure CreateBasicAuth(ApiUsername: Text; ApiPassword: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit('Basic ' + Base64Convert.ToBase64(ApiUsername + ':' + ApiPassword, TextEncoding::UTF8));
    end;

    local procedure ConvertToAdyenPayAmount(Amount: Decimal) AdyenAmount: Text
    begin
        AdyenAmount := DelChr(Format(Amount * 100, 0, 9), '=', '.');
        exit(AdyenAmount);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Pmt. Adyen Mgt.");
    end;

    procedure IsAdyenPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    procedure IsAdyenRefundLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
    end;
}