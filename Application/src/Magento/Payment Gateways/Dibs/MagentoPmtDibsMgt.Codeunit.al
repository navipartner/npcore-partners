codeunit 6151418 "NPR Magento Pmt. Dibs Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        NotImplementedErr: Label 'The "%1" function is not implemented for Dibs!', Comment = '%1 = operation type';
        WrongTableSuppliedErr: Label 'The Dibs integration does not support capture on any other table than %1. You supplied the table no. %2 (should have been %3)', Comment = '%1 = sales invoice header table caption, %2 = supplied table no., %3 = sales invoice header table no.';

    #region Payment Integration
    [TryFunction]
    procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DibsSetup: Record "NPR PG Dibs Setup";
        HttpWebRequest: HttpRequestMessage;
        CaptureString: Text;
        MD5Key: Text;
    begin
        DibsSetup.Get(Request."Payment Gateway Code");
        DibsSetup.TestField("Merchant ID");

        if (Request."Document Table No." <> Database::"Sales Invoice Header") then
            Error(WrongTableSuppliedErr, SalesInvoiceHeader.TableCaption(), Request."Document Table No.", Database::"Sales Invoice Header");

        SalesInvoiceHeader.GetBySystemId(Request."Document System Id");

        CaptureString += AppendText('merchant', DibsSetup."Merchant ID");
        CaptureString += AppendText('orderid', SalesInvoiceHeader."External Document No.");
        CaptureString += AppendText('transact', Request."Transaction ID");
        CaptureString += AppendText('amount', ConvertToDIBSAmount(Request."Request Amount"));
        MD5Key := CalcMD5Key(CaptureString, DibsSetup);
        CaptureString += AppendText('md5key', MD5Key);
        CaptureString += AppendText('splitpay', 'true');
        CaptureString += AppendText('close', 'false');

        SetupWebRequest(DibsSetup."Api Url", HttpWebRequest, 'POST', CaptureString);
        Request.AddBody(CaptureString);
        SendWebRequest(HttpWebRequest, Response);
    end;
    #endregion

    #region aux
    procedure AppendText("Key": Text; Value: Text): Text
    var
        KeyValLbl: Label '%1=%2&', Locked = true;
    begin
        exit(StrSubstNo(KeyValLbl, Key, Value));
    end;

    procedure CalcMD5Key(CaptureString: Text; PGDibs: Record "NPR PG Dibs Setup"): Text
    var
        Crypto: Codeunit "Cryptography Management";
    begin
        exit(Crypto.GenerateHash(PGDibs.GetApiPassword() + Crypto.GenerateHash(PGDibs."Api Username" + CaptureString, 0), 0));
    end;

    local procedure ConvertToDIBSAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount * 100));
    end;

    local procedure SetupWebRequest(ApiUrl: Text; var HttpWebRequest: HttpRequestMessage; RequestMethod: Code[10]; RequestBody: Text)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
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

    [TryFunction]
    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage; var Response: Record "NPR PG Payment Response")
    var
        Client: HttpClient;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        Response."Response Success" := HttpWebResponse.IsSuccessStatusCode();
        HttpWebResponse.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        if (not HttpWebResponse.IsSuccessStatusCode()) then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        Error(NotImplementedErr, 'Refund');
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        Error(NotImplementedErr, 'Cancel');
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        PGDibsSetup: Record "NPR PG Dibs Setup";
    begin
        if (not PGDibsSetup.Get(PaymentGatewayCode)) then begin
            PGDibsSetup.Init();
            PGDibsSetup.Code := PaymentGatewayCode;
            PGDibsSetup.Insert(true);
            Commit();
        end;

        PGDibsSetup.SetRecFilter();
        Page.Run(Page::"NPR PG Dibs Setup Card", PGDibsSetup);
    end;
    #endregion
}