codeunit 6151422 "NPR Magento Pmt. Adyen Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        WrongTableSuppliedErr: Label 'The table supplied (%1) is wrong. Expected table no. in (%2).', Comment = '%1 = actual table no., %2 = expected table no. or range of numbers';
        NoReferenceGivenLbl: Label 'No BC reference given';

    #region Payment Integration
    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'capture';

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesInvHeader."Currency Code";
                    Reference := SalesInvHeader."No.";
                    if SalesInvHeader."NPR External Order No." <> '' then
                        Reference := SalesInvHeader."NPR External Order No.";
                end;
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Invoice Header"));
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(Request."Request Amount") + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if (not JsonO.ReadFrom(ResponseJson)) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[capture-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'cancel';

        if (Request."Document Table No." <> Database::"Sales Header") then
            Error(WrongTableSuppliedErr, Request."Document Table No.", Database::"Sales Header");

        Reference := Request."Request Description";
        if (Reference = '') then
            Reference := NoReferenceGivenLbl;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[cancel-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'refund';

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesCrMemoHeader."Currency Code";
                    Reference := SalesCrMemoHeader."No.";
                    if SalesCrMemoHeader."NPR External Order No." <> '' then
                        Reference := SalesCrMemoHeader."NPR External Order No.";
                end;
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Cr.Memo Header"));
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(Request."Request Amount") + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[refund-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    local procedure UpsertShopperRef(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
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
            EFTShopperRecognition.Init();
            EFTShopperRecognition."Integration Type" := CopyStr(EFTAdyenCloudIntegration.IntegrationType(), 1, MaxStrLen(EFTShopperRecognition."Integration Type"));
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
    #endregion

    #region insert modify
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
    #endregion


    #region aux
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

    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage; var Response: Record "NPR PG Payment Response"): Text
    var
        Client: HttpClient;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        HttpWebResponse.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);
        exit(ResponseTxt);
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

    procedure IsAdyenPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PGAdyen: Record "NPR PG Adyen Setup";
        PG: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);
        if not PG.Get(PaymentLine."Payment Gateway Code") then
            exit(false);
        if not PGAdyen.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PG."Integration Type" = PG."Integration Type"::Adyen);
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        RefundInternal(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CancelInternal(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        PGAdyenSetup: Record "NPR PG Adyen Setup";
    begin
        if (not PGAdyenSetup.Get(PaymentGatewayCode)) then begin
            PGAdyenSetup.Init();
            PGAdyenSetup.Code := PaymentGatewayCode;
            PGAdyenSetup.Insert(true);
            Commit();
        end;

        PGAdyenSetup.SetRecFilter();
        Page.Run(Page::"NPR PG Adyen Setup Card", PGAdyenSetup);
    end;
    #endregion
}
