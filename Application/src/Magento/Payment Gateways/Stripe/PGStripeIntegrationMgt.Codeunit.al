codeunit 6184578 "NPR PG Stripe Integration Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;
    //Handling payments is done with Payment Intents API as new features are not available with the Charges API.
    var
        BaseUrlTok: Label 'https://api.stripe.com/v1', Locked = true;
        _APIErr: Label 'The Stripe API returned an error\Url: %1\Status Code: %2 - %3\Body: %4', Comment = '%1 = Url, %2 = http status code, %3 = http reason phrase, %4 = response body';
        _TransportErr: Label 'An error happened while calling the API.\\Error message: %1', Comment = '%1 = last error message';

    #region Payment Integration
    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        StripeSetup: Record "NPR PG Stripe Setup";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: text;
    begin
        StripeSetup.Get(Request."Payment Gateway Code");
        InitWebHeader(StripeSetup, Client);
        InitUrlAndTransactionText(Request, 'cancel', TransactionTxt, Url);
        SendWebRequest(Client, ContentTxt, Url, Request, Response);
    end;

    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        StripeSetup: Record "NPR PG Stripe Setup";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: text;
        TypeHelper: Codeunit "Type Helper";
        RequestAmount: text;
    begin
        StripeSetup.Get(Request."Payment Gateway Code");
        InitWebHeader(StripeSetup, Client);
        InitUrlAndTransactionText(Request, 'capture', TransactionTxt, Url);
        RequestAmount := GetStripeAmount(Request."Request Amount");
        ContentTxt := StrSubstNo('amount_to_capture=%1&metadata[description]=%2',
                 TypeHelper.UrlEncode(RequestAmount),
                    TypeHelper.UrlEncode(TransactionTxt));

        SendWebRequest(Client, ContentTxt, Url, Request, Response);
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        StripeSetup: Record "NPR PG Stripe Setup";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        ContentTxt: Text;
        Url: Text;
        TransactionTxt: text;
    begin
        StripeSetup.Get(Request."Payment Gateway Code");
        InitWebHeader(StripeSetup, Client);
        InitUrlAndTransactionText(Request, 'refund', TransactionTxt, Url);
        ContentTxt := StrSubstNo('metadata[description]=%1',
                    TypeHelper.UrlEncode(TransactionTxt));
        SendWebRequest(Client, ContentTxt, Url, Request, Response);
    end;
    #endregion

    #region aux
    local procedure InitWebHeader(StripeSetup: Record "NPR PG Stripe Setup"; var Client: HttpClient)
    var
        [NonDebuggable]
        SecretKey: Text;
        ClientHeaders: HttpHeaders;
    begin
        SecretKey := GetAPISecretKey(StripeSetup);
        ClientHeaders := Client.DefaultRequestHeaders();
        SetHeader(ClientHeaders, 'Authorization', 'Bearer ' + SecretKey);
        SetHeader(ClientHeaders, 'User-Agent', 'Microsoft-Dynamics-365-Business-Central-NP-Retail');
    end;

    local procedure InitUrlAndTransactionText(Request: Record "NPR PG Payment Request"; RequestService: Text; var TransactionTxt: Text; var Url: Text)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        PaymentRefundLbl: Label 'Payment refund for %1 %2', Comment = '%1 = document type, %2 = document no.';
        UnknownRequestServiceErr: Label 'RequestService type %1 is not supported. Valid options are "cancel","capture" and "refund".', Comment = '%1 = RequestService type', Locked = true;
        TransactionTextPlaceHolder: Text;
        InvoiceLbl: Label 'Invoice';
        CreditMemoLbl: Label 'Credit Memo';
        PaymentCapturedLbl: Label 'Payment for %1 %2', Comment = '%1 = document type, %2 = document no.';
        WrongTableSuppliedErr: Label 'The table supplied (%1) is wrong. Expected table no. in (%2).', Comment = '%1 = actual table no., %2 = expected table no. or range of numbers';
    begin
        case RequestService of
            'cancel':
                begin
                    Url := BaseUrlTok + StrSubstNo('/payment_intents/%1/%2', Request."Transaction ID", RequestService);
                end;
            'capture':
                begin
                    Url := BaseUrlTok + StrSubstNo('/payment_intents/%1/%2', Request."Transaction ID", RequestService);
                    TransactionTextPlaceHolder := PaymentCapturedLbl;
                end;
            'refund':
                begin
                    Url := BaseUrlTok + StrSubstNo('/refunds?payment_intent=%1', Request."Transaction ID");
                    TransactionTextPlaceHolder := PaymentRefundLbl;

                end;
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
            TransactionTxt := Request."Request Description";
    end;

    local procedure SendWebRequest(Client: HttpClient; ContentTxt: text; Url: Text; var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        ResponseTxt: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
    begin
        Request.AddBody(ContentTxt);
        Content.WriteFrom(ContentTxt);
        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/x-www-form-urlencoded');

        if not Client.Post(Url, Content, ResponseMsg) then
            Error(_TransportErr, GetLastErrorText());

        ResponseMsg.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        if (ResponseMsg.HttpStatusCode() <> 200) then
            Error(_APIErr, Url, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        Response."Response Success" := true;
    end;

    [NonDebuggable]
    local procedure GetAPISecretKey(StripeSetup: Record "NPR PG Stripe Setup") SecretKey: Text
    var
        UnknownOptionValueErr: Label 'The provided option value is not valid. This is a programming error, not user error. Please contact system vendor';
        BlankSecretErr: label '%1 cannot be blank. Please review the %2.', Comment = '%1=StripeSetup.FieldCaption("Test API Client Secret Key");%2=StripeSetup.TableCaption';
    begin
        case StripeSetup.Environment of
            StripeSetup.Environment::Test:
                begin
                    SecretKey := StripeSetup.GetSecret(StripeSetup.FieldNo("Test API Client Secret Key"));
                    if SecretKey = '' then
                        Error(BlankSecretErr, StripeSetup.FieldCaption("Test API Client Secret Key"), StripeSetup.TableCaption);
                    exit(SecretKey);
                end;
            StripeSetup.Environment::Production:
                begin
                    SecretKey := StripeSetup.GetSecret(StripeSetup.FieldNo("Live API Client Secret Key"));
                    if SecretKey = '' then
                        Error(BlankSecretErr, StripeSetup.FieldCaption("Live API Client Secret Key"), StripeSetup.TableCaption);
                    exit(SecretKey);
                end;
            else
                Error(UnknownOptionValueErr);
        end;
    end;

    local procedure GetStripeAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount * 100, 0, 9));
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;
    #endregion
    internal procedure GetPaymentIntentList(StripeSetup: Record "NPR PG Stripe Setup"): Boolean
    var
        Client: HttpClient;
        Url: Text;
        ResponseMsg: HttpResponseMessage;
        Response: Text;
        JToken: JsonToken;
        MessageToken: JsonToken;
        MessageText: Text;
    begin
        InitWebHeader(StripeSetup, Client);
        Url := BaseUrlTok + StrSubstNo('/payment_intents');
        if not Client.Get(Url, ResponseMsg) then
            Error(_TransportErr, GetLastErrorText());

        if not ResponseMsg.IsSuccessStatusCode then begin
            ResponseMsg.Content().ReadAs(Response);
            JToken.ReadFrom(Response);
            if JToken.SelectToken('error.message', MessageToken) then
                MessageText := MessageToken.AsValue().AsText()
            else
                MessageText := Response;
            Error('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase, MessageText);
        end;

    end;

    internal procedure TestPaymentIntentAPI(var StripeSetup: Record "NPR PG Stripe Setup")
    var
        ConnectionOKLbl: Label 'Connection OK!';
    begin
        GetPaymentIntentList(StripeSetup);
        Message(ConnectionOKLbl);
    end;

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
        PGStripeSetup: Record "NPR PG Stripe Setup";
    begin
        if (not PGStripeSetup.Get(PaymentGatewayCode)) then begin
            PGStripeSetup.Init();
            PGStripeSetup.Code := PaymentGatewayCode;
            PGStripeSetup.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR PG Stripe Setup Card", PGStripeSetup);
    end;
    #endregion


}