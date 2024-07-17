codeunit 6150920 "NPR PG Vipps Integration Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        _ProductionBaseUrlTok: Label 'https://api.vipps.no', Locked = true;
        _TestBaseUrlTok: Label 'https://apitest.vipps.no', Locked = true;
        _UnsupportedOptionValueErr: Label 'The provided option value is not valid. This is a programming error, not user error. Please contact system vendor';
        _APIErr: Label 'The Vipps API returned an error\Url: %1\Status Code: %2 - %3\Body: %4', Comment = '%1 = Url, %2 = http status code, %3 = http reason phrase, %4 = response body';
        WrongTableSuppliedErr: Label 'The table supplied (%1) is wrong. Expected table no. in (%2).', Comment = '%1 = actual table no., %2 = expected table no. or range of numbers';
        _TransportErr: Label 'An error happened while calling the API.\\Error message: %1', Comment = '%1 = last error message';

    #region Payment Integration
    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        VippsSetup: Record "NPR PG Vipps Setup";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: Text[100];
    begin
        VippsSetup.Get(Request."Payment Gateway Code");
        InitWebRequest(VippsSetup, Client, Request."Payment Line System Id");
        InitUrlAndTransactionText(VippsSetup, Request, 'cancel', TransactionTxt, Url);

        ContentTxt :=
            '{' +
                '"merchantInfo": {' +
                    '"merchantSerialNumber":"' + VippsSetup."Merchant Serial Number" + '"' +
                '},' +
                '"transaction": {' +
                    '"transactionText":"' + TransactionTxt + '"' +
                '}' +
            '}';

        SendWebRequest(Client, ContentTxt, 'cancel', Url, Request, Response);
    end;

    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        VippsSetup: Record "NPR PG Vipps Setup";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: Text[100];
    begin
        VippsSetup.Get(Request."Payment Gateway Code");
        InitWebRequest(VippsSetup, Client, Request."Payment Line System Id");
        InitUrlAndTransactionText(VippsSetup, Request, 'capture', TransactionTxt, Url);

        ContentTxt :=
            '{' +
                '"merchantInfo": {' +
                    '"merchantSerialNumber":"' + VippsSetup."Merchant Serial Number" + '"' +
                '},' +
                '"transaction": {' +
                    '"amount":' + Format(GetVippsAmount(Request."Request Amount"), 0, 9) + ',' +
                    '"transactionText":"' + TransactionTxt + '"' +
                '}' +
            '}';

        SendWebRequest(Client, ContentTxt, 'capture', Url, Request, Response);
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        VippsSetup: Record "NPR PG Vipps Setup";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: Text[100];
    begin
        VippsSetup.Get(Request."Payment Gateway Code");
        InitWebRequest(VippsSetup, Client, Request."Payment Line System Id");
        InitUrlAndTransactionText(VippsSetup, Request, 'refund', TransactionTxt, Url);

        ContentTxt :=
            '{' +
                '"merchantInfo": {' +
                    '"merchantSerialNumber":"' + VippsSetup."Merchant Serial Number" + '"' +
                '},' +
                '"transaction": {' +
                    '"amount": ' + Format(GetVippsAmount(Request."Request Amount"), 0, 9) + ',' +
                    '"transactionText":"' + TransactionTxt + '"' +
                '}' +
            '}';

        SendWebRequest(Client, ContentTxt, 'refund', Url, Request, Response);
    end;
    #endregion

    #region aux
    local procedure InitWebRequest(VippsSetup: Record "NPR PG Vipps Setup"; Client: HttpClient; PaymentLineSystemId: Guid)
    var
        AccessToken: Text;
        ClientHeaders: HttpHeaders;
    begin
        TryGetAccessToken(VippsSetup, AccessToken);
        ClientHeaders := Client.DefaultRequestHeaders();
        SetHeader(ClientHeaders, 'Authorization', 'Bearer ' + AccessToken);
        SetHeader(ClientHeaders, 'Ocp-Apim-Subscription-Key', VippsSetup.GetOcpApimSubscriptionKey());
        SetHeader(ClientHeaders, 'X-Request-Id', PaymentLineSystemId);
        SetHeader(ClientHeaders, 'Merchant-Serial-Number', VippsSetup."Merchant Serial Number");
        SetHeader(ClientHeaders, 'User-Agent', 'Microsoft-Dynamics-365-Business-Central-NP-Retail');
    end;

    local procedure InitUrlAndTransactionText(VippsSetup: Record "NPR PG Vipps Setup"; Request: Record "NPR PG Payment Request"; RequestService: Text; var TransactionTxt: Text[100]; var Url: Text)
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentCapturedLbl: Label 'Payment for %1 %2', Comment = '%1 = document type, %2 = document no.';
        PaymentRefundLbl: Label 'Payment refund for %1 %2', Comment = '%1 = document type, %2 = document no.';
        UnknownRequestServiceErr: Label 'RequestService type %1 is not supported. Valid options are "cancel","capture" and "refund".', Comment = '%1 = RequestService type', Locked = true;
        InvoiceLbl: Label 'Invoice';
        CreditMemoLbl: Label 'Credit Memo';
        TransactionTextPlaceHolder: Text;
    begin
        case RequestService of
            'cancel':
                TransactionTxt := CopyStr(Request."Request Description", 1, MaxStrLen(TransactionTxt));
            'capture':
                TransactionTextPlaceHolder := PaymentCapturedLbl;
            'refund':
                TransactionTextPlaceHolder := PaymentRefundLbl;
            else
                Error(UnknownRequestServiceErr, RequestService);
        end;

        case Request."Document Table No." of
            Database::"Sales Invoice Header":
                if TransactionTxt = '' then
                    if SalesInvHeader.GetBySystemId(Request."Document System Id") then
                        TransactionTxt := CopyStr(StrSubstNo(TransactionTextPlaceHolder, InvoiceLbl, SalesInvHeader."No."), 1, MaxStrLen(TransactionTxt));
            Database::"Sales Cr.Memo Header":
                if TransactionTxt = '' then
                    if SalesCrMemoHeader.GetBySystemId(Request."Document System Id") then
                        TransactionTxt := CopyStr(StrSubstNo(TransactionTextPlaceHolder, CreditMemoLbl, SalesCrMemoHeader."No."), 1, MaxStrLen(TransactionTxt));
            Database::"Sales Header":
                if TransactionTxt = '' then
                    if SalesHeader.GetBySystemId(Request."Document System Id") then
                        TransactionTxt := CopyStr(StrSubstNo(TransactionTextPlaceHolder, Format(SalesHeader."Document Type"), SalesHeader."No."), 1, MaxStrLen(TransactionTxt));
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Invoice Header"));
        end;

        if TransactionTxt = '' then
            TransactionTxt := CopyStr(Request."Request Description", 1, MaxStrLen(TransactionTxt));

        Url := GetBaseUrl(VippsSetup.Environment) + StrSubstNo('/ecomm/v2/payments/%1/%2', Request."Transaction ID", RequestService);
    end;

    local procedure SendWebRequest(Client: HttpClient; ContentTxt: text; RequestService: text; Url: Text; var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        ResponseTxt: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
        UnknownRequestServiceErr: Label 'RequestService type %1 is not supported. Valid options are "cancel","capture" and "refund".', Comment = '%1 = RequestService type', Locked = true;
    begin
        Request.AddBody(ContentTxt);
        Content.WriteFrom(ContentTxt);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        case RequestService of
            'cancel':
                begin
                    if not Client.Put(Url, Content, ResponseMsg) then
                        Error(_TransportErr, GetLastErrorText());
                end;
            'capture', 'refund':
                begin
                    if not Client.Post(Url, Content, ResponseMsg) then
                        Error(_TransportErr, GetLastErrorText());
                end;
            else
                Error(UnknownRequestServiceErr, RequestService);
        end;

        ResponseMsg.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        // According to API docs only 200 is a valid code for all RequestService types.
        // for cancel: Ref: https://vippsas.github.io/vipps-developer-docs/api/ecom/#tag/Vipps-eCom-API/operation/cancelPaymentRequestUsingPUT
        // for capture: Ref: https://vippsas.github.io/vipps-developer-docs/api/ecom/#tag/Vipps-eCom-API/operation/capturePaymentUsingPOST
        // for refund: Ref: https://vippsas.github.io/vipps-developer-docs/api/ecom/#tag/Vipps-eCom-API/operation/refundPaymentUsingPOST
        if (ResponseMsg.HttpStatusCode() <> 200) then
            Error(_APIErr, Url, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        Response."Response Success" := true;
    end;

    [TryFunction]
    [NonDebuggable]
    procedure TryGetAccessToken(VippsSetup: Record "NPR PG Vipps Setup"; var TokenOut: Text)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        Url: Text;
        ResponseJObject: JsonObject;
        AccessTokenJToken: JsonToken;
    begin
        Clear(TokenOut);

        VippsSetup.TestField("API Client ID");
        VippsSetup.VerifyHasAPIClientSecret();
        VippsSetup.VerifyHasOcpApimSubscriptionKey();

        Headers := Client.DefaultRequestHeaders();
        SetHeader(Headers, 'client_id', VippsSetup."API Client ID");
        SetHeader(Headers, 'client_secret', VippsSetup.GetAPIClientSecret());
        SetHeader(Headers, 'Ocp-Apim-Subscription-Key', VippsSetup.GetOcpApimSubscriptionKey());

        Url := GetBaseUrl(VippsSetup.Environment) + '/accesstoken/get';
        Client.Post(Url, Content, ResponseMsg);

        ResponseMsg.Content.ReadAs(ResponseTxt);

        // According to API docs only 200 is a valid code
        // Ref: https://vippsas.github.io/vipps-developer-docs/api/ecom/#tag/Authorization-Service/operation/fetchAuthorizationTokenUsingPost
        if (ResponseMsg.HttpStatusCode <> 200) then
            Error(_APIErr, Url, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        ResponseJObject.ReadFrom(ResponseTxt);
        ResponseJObject.SelectToken('access_token', AccessTokenJToken);
        TokenOut := AccessTokenJToken.AsValue().AsText();
    end;

    local procedure GetBaseUrl(Environment: Option Test,Production): Text
    begin
        case Environment of
            Environment::Test:
                exit(_TestBaseUrlTok);
            Environment::Production:
                exit(_ProductionBaseUrlTok);
            else
                Error(_UnsupportedOptionValueErr);
        end;
    end;

    local procedure GetVippsAmount(Amount: Decimal): Integer
    begin
        exit(Round(Amount, 0.01) * 100);
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        RefundInternal(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CancelInternal(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        PGVippsSetup: Record "NPR PG Vipps Setup";
    begin
        if (not PGVippsSetup.Get(PaymentGatewayCode)) then begin
            PGVippsSetup.Init();
            PGVippsSetup.Code := PaymentGatewayCode;
            PGVippsSetup.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR PG Vipps Setup Card", PGVippsSetup);
    end;
    #endregion
}