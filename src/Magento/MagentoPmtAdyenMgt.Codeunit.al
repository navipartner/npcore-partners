codeunit 6151422 "NPR Magento Pmt. Adyen Mgt."
{
    // MAG2.20/MHA /20190502  CASE 352184 Object created for Adyen Payment Capture/Cancel/Refund
    // MAG2.23/MHA /20190821  CASE 365631 External Order No. is used as Reference
    // MAG2.24/MHA /20191118  CASE 377930 Added Shopper Reference functions


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Quickpay error:\%1';

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        Cancel(PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', true, true)]
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

    procedure "--- Create Request"()
    begin
    end;

    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        JToken: DotNet JToken;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
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
        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway."Api Password", HttpWebRequest);

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    //-MAG2.23 [365631]
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                    //+MAG2.23 [365631]
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    CurrencyCode := SalesInvHeader."Currency Code";
                    Reference := SalesInvHeader."No.";
                    //-MAG2.23 [365631]
                    if SalesInvHeader."NPR External Order No." <> '' then
                        Reference := SalesInvHeader."NPR External Order No.";
                    //+MAG2.23 [365631]
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

        if not NpXmlDomMgt.SendWebRequestText(Request, HttpWebRequest, HttpWebResponse, WebException) then begin
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson, JToken) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'response', 0);
        if Response <> '[capture-received]' then
            Error(Response);
    end;

    local procedure Cancel(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        JToken: DotNet JToken;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
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
        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway."Api Password", HttpWebRequest);

        PaymentLine.TestField("Document Table No.", DATABASE::"Sales Header");
        //-MAG2.24 [377930]
        Reference := PaymentLine."Document No.";
        //+MAG2.24 [377930]

        Request :=
          '{' +
          '  "originalReference": "' + PaymentLine."No." + '",' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + PaymentGateway."Merchant Name" + '"' +
          '}';

        if not NpXmlDomMgt.SendWebRequestText(Request, HttpWebRequest, HttpWebResponse, WebException) then begin
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson, JToken) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'response', 0);
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
        JToken: DotNet JToken;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
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
        InitWebRequest(Url, PaymentGateway."Api Username", PaymentGateway."Api Password", HttpWebRequest);

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    //-MAG2.23 [365631]
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                    //+MAG2.23 [365631]
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(PaymentLine."Document No.");
                    CurrencyCode := SalesCrMemoHeader."Currency Code";
                    Reference := SalesCrMemoHeader."No.";
                    //-MAG2.23 [365631]
                    if SalesCrMemoHeader."NPR External Order No." <> '' then
                        Reference := SalesCrMemoHeader."NPR External Order No.";
                    //+MAG2.23 [365631]
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

        if not NpXmlDomMgt.SendWebRequestText(Request, HttpWebRequest, HttpWebResponse, WebException) then begin
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson, JToken) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'response', 0);
        if Response <> '[refund-received]' then
            Error(Response);
    end;

    local procedure "--- Shopper Reference"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6151409, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPaymentLine(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        //-MAG2.24 [377930]
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
        //+MAG2.24 [377930]
    end;

    [EventSubscriber(ObjectType::Table, 6151409, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPaymentLine(var Rec: Record "NPR Magento Payment Line"; var xRec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        //-MAG2.24 [377930]
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
        //+MAG2.24 [377930]
    end;

    local procedure UpsertShopperRef(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integ.";
        PrevRec: Text;
    begin
        //-MAG2.24 [377930]
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
        //+MAG2.24 [377930]
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure InitWebRequest(Url: Text; Username: Text; Password: Text; var HttpWebRequest: DotNet NPRNetHttpWebRequest)
    var
        Credential: DotNet NPRNetNetworkCredential;
        Uri: DotNet NPRNetUri;
    begin
        HttpWebRequest := HttpWebRequest.Create(Uri.Uri(Url));
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(Username, Password);
        HttpWebRequest.Credentials(Credential);
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

    local procedure GetJsonText(JToken: DotNet JToken; JPath: Text; MaxLen: Integer) Value: Text
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
            exit('');

        Value := Format(JToken2);
        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);
        exit(Value);
    end;

    [TryFunction]
    local procedure ParseJson(Json: Text; var JToken: DotNet JToken)
    begin
        JToken := JToken.Parse(Json);
    end;
}

