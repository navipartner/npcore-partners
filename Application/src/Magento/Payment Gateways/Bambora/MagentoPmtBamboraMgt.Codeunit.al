codeunit 6151472 "NPR Magento Pmt. Bambora Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        _TransportErr: Label 'An error happened while calling the API.\\Error message: %1', Comment = '%1 = last error message';
        _CallingApiErr: Label 'The Bambora API responded with a bad response.\Status code: %1 - %2\Response: %3', Comment = '%1 = HTTP status code, %2 = Reason Phrase, %3 = Response body';

    #region Payment Integration
    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        BamboraSetup: Record "NPR PG Bambora Setup";
        Client: HttpClient;
        RequestTxt: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        BamboraSetup.Get(Request."Payment Gateway Code");
        GetHttpClient(BamboraSetup, Client);

        RequestTxt := '{' + '"amount":' + Format(GetBamboraAmount(Request), 0, 9) + '}';
        Content.WriteFrom(RequestTxt);

        Request.AddBody(RequestTxt);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Success := Client.Post(StrSubstNo('/transactions/%1/capture', Request."Transaction ID"), Content, HttpResponse);
        if (HttpResponse.Content.ReadAs(ResponseTxt)) then;

        Response."Response Success" := (Success and HttpResponse.IsSuccessStatusCode());
        Response.AddResponse(ResponseTxt);

        if (not Success) then
            Error(_TransportErr, GetLastErrorText());

        if (not Response."Response Success") then
            Error(_CallingApiErr, HttpResponse.HttpStatusCode(), HttpResponse.ReasonPhrase(), ResponseTxt);
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        BamboraSetup: Record "NPR PG Bambora Setup";
        Client: HttpClient;
        RequestTxt: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        BamboraSetup.Get(Request."Payment Gateway Code");
        GetHttpClient(BamboraSetup, Client);

        RequestTxt := '{' + '"amount":' + Format(GetBamboraAmount(Request), 0, 9) + '}';
        Content.WriteFrom(RequestTxt);

        Request.AddBody(RequestTxt);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Success := Client.Post(StrSubstNo('/transactions/%1/credit', Request."Transaction ID"), Content, HttpResponse);
        if (HttpResponse.Content.ReadAs(ResponseTxt)) then;

        Response."Response Success" := (Success and HttpResponse.IsSuccessStatusCode());
        Response.AddResponse(ResponseTxt);

        if (not Success) then
            Error(_TransportErr, GetLastErrorText());

        if (not Response."Response Success") then
            Error(_CallingApiErr, HttpResponse.HttpStatusCode(), HttpResponse.ReasonPhrase(), ResponseTxt);
    end;

    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        BamboraSetup: Record "NPR PG Bambora Setup";
        Client: HttpClient;
        RequestTxt: Text;
        Content: HttpContent;
        HttpResponse: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        BamboraSetup.Get(Request."Payment Gateway Code");
        GetHttpClient(BamboraSetup, Client);

        RequestTxt := ''; // cancel operation takes an empty body
        Content.WriteFrom(RequestTxt);

        Request.AddBody(RequestTxt);

        Success := Client.Post(StrSubstNo('/transactions/%1/delete', Request."Transaction ID"), Content, HttpResponse);
        if (HttpResponse.Content.ReadAs(ResponseTxt)) then;

        Response."Response Success" := (Success and HttpResponse.IsSuccessStatusCode());
        Response.AddResponse(ResponseTxt);

        if (not Success) then
            Error(_TransportErr, GetLastErrorText());

        if (not Response."Response Success") then
            Error(_CallingApiErr, HttpResponse.HttpStatusCode(), HttpResponse.ReasonPhrase(), ResponseTxt);
    end;
    #endregion

    #region Aux
    local procedure GetBamboraAmount(Request: Record "NPR PG Payment Request"): Integer
    begin
        exit(Round(Request."Request Amount", 0.01) * 100);
    end;

    [NonDebuggable]
    local procedure GetHttpClient(BamboraSetup: Record "NPR PG Bambora Setup"; var Client: HttpClient)
    var
        AccessTokenNotSetErr: Label 'The access token is not set on Payment Gateway %1. Set this in the "%2" field', Comment = '%1 = payment gateway code, %2 = Api Username field caption';
        SecretTokenNotSetErr: Label 'The secret authentication token is not set on Payment Gateway %1. Set this in the "%2" field', Comment = '%1 = payment gateway code, %2 = Api Password field caption';
        Username: Text;
        SecretToken: Text;
        AuthToken: Text;
        Headers: HttpHeaders;
        Convert: Codeunit "Base64 Convert";
    begin
        if (BamboraSetup."Access Token" = '') then
            Error(AccessTokenNotSetErr, BamboraSetup.Code, BamboraSetup.FieldCaption("Access Token"));

        BamboraSetup.TestField("Merchant ID");

        if (not BamboraSetup.HasSecretToken()) then
            Error(SecretTokenNotSetErr, BamboraSetup.Code, BamboraSetup.FieldCaption("Secret Token Key"));

        SecretToken := BamboraSetup.GetSecretToken();

        if (SecretToken = '') then
            Error(SecretTokenNotSetErr, BamboraSetup.Code, BamboraSetup.FieldCaption("Secret Token Key"));

        Clear(Client);

        Username := BamboraSetup."Access Token" + '@' + BamboraSetup."Merchant ID";
        AuthToken := Convert.ToBase64(Username + ':' + SecretToken);

        Client.SetBaseAddress('https://transaction-v1.api-eu.bambora.com');
        Headers := Client.DefaultRequestHeaders();
        SetHeader(Headers, 'Authorization', 'Basic ' + AuthToken);
        SetHeader(Headers, 'Accept', 'application/json');
    end;

    local procedure SetHeader(var Headers: HttpHeaders; Name: Text; Val: Text)
    begin
        if (Headers.Contains(Name)) then
            Headers.Remove(Name);
        Headers.Add(Name, Val);
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
        PGBamboraSetup: Record "NPR PG Bambora Setup";
    begin
        if (not PGBamboraSetup.Get(PaymentGatewayCode)) then begin
            PGBamboraSetup.Init();
            PGBamboraSetup.Code := PaymentGatewayCode;
            PGBamboraSetup.Insert(true);
            Commit();
        end;

        PGBamboraSetup.SetRecFilter();
        Page.Run(Page::"NPR PG Bambora Setup Card", PGBamboraSetup);
    end;
    #endregion
}