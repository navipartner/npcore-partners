codeunit 6151422 "Magento Pmt. Adyen Mgt."
{
    // MAG2.20/MHA /20190502  CASE 352184 Object created for Adyen Payment Capture/Cancel/Refund
    // MAG2.23/MHA /20190821  CASE 365631 External Order No. is used as Reference


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Quickpay error:\%1';

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', true, true)]
    local procedure OnCapturePayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Invoice Header"]) then
          exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Invoice Header"]) then
          exit;

        Cancel(PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsAdyenRefundLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Cr.Memo Header"]) then
          exit;

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today;
        PaymentLine.Modify(true);
    end;

    procedure "--- Create Request"()
    begin
    end;

    local procedure Capture(PaymentLine: Record "Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet JToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
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
        InitWebRequest(Url,PaymentGateway."Api Username",PaymentGateway."Api Password",HttpWebRequest);

        case PaymentLine."Document Table No." of
          DATABASE::"Sales Header":
            begin
              SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No.");
              CurrencyCode := SalesHeader."Currency Code";
              Reference := SalesHeader."No.";
              //-MAG2.23 [365631]
              if SalesHeader."External Order No." <> '' then
                Reference := SalesHeader."External Order No.";
              //+MAG2.23 [365631]
            end;
          DATABASE::"Sales Invoice Header":
            begin
              SalesInvHeader.Get(PaymentLine."Document No.");
              CurrencyCode := SalesInvHeader."Currency Code";
              Reference := SalesInvHeader."No.";
              //-MAG2.23 [365631]
              if SalesInvHeader."External Order No." <> '' then
                Reference := SalesInvHeader."External Order No.";
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

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'response',0);
        if Response <> '[capture-received]' then
          Error(Response);
    end;

    local procedure Cancel(PaymentLine: Record "Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet JToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
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
        Url := PaymentGateway."Api Url" + '/cancel';
        InitWebRequest(Url,PaymentGateway."Api Username",PaymentGateway."Api Password",HttpWebRequest);

        PaymentLine.TestField("Document Table No.",DATABASE::"Sales Header");
        SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No.");
        CurrencyCode := SalesHeader."Currency Code";
        Reference := SalesHeader."No.";

        if CurrencyCode = '' then begin
          GeneralLedgerSetup.Get;
          CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        Request :=
          '{' +
          '  "originalReference": "' + PaymentLine."No." + '",' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + PaymentGateway."Merchant Name" + '"' +
          '}';

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'response',0);
        if Response <> '[cancel-received]' then
          Error(Response);
    end;

    local procedure Refund(PaymentLine: Record "Magento Payment Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet JToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
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
        InitWebRequest(Url,PaymentGateway."Api Username",PaymentGateway."Api Password",HttpWebRequest);

        case PaymentLine."Document Table No." of
          DATABASE::"Sales Header":
            begin
              SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No.");
              CurrencyCode := SalesHeader."Currency Code";
              Reference := SalesHeader."No.";
              //-MAG2.23 [365631]
              if SalesHeader."External Order No." <> '' then
                Reference := SalesHeader."External Order No.";
              //+MAG2.23 [365631]
            end;
          DATABASE::"Sales Cr.Memo Header":
            begin
              SalesCrMemoHeader.Get(PaymentLine."Document No.");
              CurrencyCode := SalesCrMemoHeader."Currency Code";
              Reference := SalesCrMemoHeader."No.";
              //-MAG2.23 [365631]
              if SalesCrMemoHeader."External Order No." <> '' then
                Reference := SalesCrMemoHeader."External Order No.";
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

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'response',0);
        if Response <> '[refund-received]' then
          Error(Response);
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure InitWebRequest(Url: Text;Username: Text;Password: Text;var HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        Credential: DotNet npNetNetworkCredential;
        Uri: DotNet npNetUri;
    begin
        HttpWebRequest := HttpWebRequest.Create(Uri.Uri(Url));
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'application/json';
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(Username,Password);
        HttpWebRequest.Credentials(Credential);
    end;

    local procedure ConvertToAdyenPayAmount(Amount: Decimal) AdyenAmount: Text
    begin
        AdyenAmount := DelChr(Format(Amount * 100,0,9),'=','.');
        exit(AdyenAmount);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento Pmt. Adyen Mgt.");
    end;

    procedure IsAdyenPaymentLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
          exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    procedure IsAdyenRefundLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
          exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
    end;

    local procedure GetJsonText(JToken: DotNet JToken;JPath: Text;MaxLen: Integer) Value: Text
    var
        JToken2: DotNet JToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit('');

        Value := Format(JToken2);
        if MaxLen > 0 then
          Value := CopyStr(Value,1,MaxLen);
        exit(Value);
    end;

    [TryFunction]
    local procedure ParseJson(Json: Text;var JToken: DotNet JToken)
    begin
        JToken := JToken.Parse(Json);
    end;
}

