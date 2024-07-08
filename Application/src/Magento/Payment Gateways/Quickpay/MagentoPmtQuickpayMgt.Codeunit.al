codeunit 6151417 "NPR Magento Pmt. Quickpay Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        FailedToSendRequestErr: Label 'Failed to communicate with QuickPay API.\\Error message: %1', Comment = '%1 = error message';
        BadApiResponseErr: Label 'The QuickPay API responded with a bad error.\Status code: %1 - %2\Body: %3', Comment = '%1 = status code, %2 = reason phrase, %3 = body';
        RequestMethodPostTok: Label 'POST', Locked = true;
        RequestParameterAmountTok: Label 'amount', Locked = true;
        RequestParameterIdTok: Label 'id', Locked = true;
        APIBaseUrlTok: Label 'https://api.quickpay.net', Locked = true;

    #region Payment Integration
    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        JsonBody: JsonObject;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        RequestBodyText: Text;
        ResponseTxt: Text;
    begin
        ClearLastError();

        JsonBody.Add(RequestParameterIdTok, Request."Transaction ID");
        JsonBody.Add(RequestParameterAmountTok, ConvertToQuickPayAmount(Request."Request Amount"));
        JsonBody.WriteTo(RequestBodyText);
        Request.AddBody(JsonBody);

        SetupHttpWebRequest(HttpWebRequest, CopyStr(RequestMethodPostTok, 1, 10), Request, 'capture', RequestBodyText);

        if (not TrySendWebRequest(HttpWebRequest, HttpWebResponse)) then begin
            Response."Response Success" := false;
            Error(FailedToSendRequestErr, GetLastErrorText());
        end;

        HttpWebResponse.Content.ReadAs(ResponseTxt);

        Response."Response Success" := HttpWebResponse.IsSuccessStatusCode();
        Response.AddResponse(ResponseTxt);

        if (not HttpWebResponse.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, HttpWebResponse.HttpStatusCode(), HttpWebResponse.ReasonPhrase(), ResponseTxt);
    end;

    [TryFunction]
    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        JsonBody: JsonObject;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        RequestBodyText: Text;
        ResponseTxt: Text;
    begin
        JsonBody.Add(RequestParameterIdTok, Request."Transaction ID");
        JsonBody.Add(RequestParameterAmountTok, ConvertToQuickPayAmount(Request."Request Amount"));
        JsonBody.WriteTo(RequestBodyText);
        Request.AddBody(JsonBody);

        SetupHttpWebRequest(HttpWebRequest, CopyStr(RequestMethodPostTok, 1, 10), Request, 'refund', RequestBodyText);

        if (not TrySendWebRequest(HttpWebRequest, HttpWebResponse)) then begin
            Response."Response Success" := false;
            Error(FailedToSendRequestErr, GetLastErrorText());
        end;

        HttpWebResponse.Content.ReadAs(ResponseTxt);

        Response."Response Success" := HttpWebResponse.IsSuccessStatusCode();
        Response.AddResponse(ResponseTxt);

        if (not HttpWebResponse.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, HttpWebResponse.HttpStatusCode(), HttpWebResponse.ReasonPhrase(), ResponseTxt);
    end;

    [TryFunction]
    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        SetupHttpWebRequest(HttpWebRequest, CopyStr(RequestMethodPostTok, 1, 10), Request, 'cancel', '');

        if (not TrySendWebRequest(HttpWebRequest, HttpWebResponse)) then begin
            Response."Response Success" := false;
            Error(FailedToSendRequestErr, GetLastErrorText());
        end;

        HttpWebResponse.Content.ReadAs(ResponseTxt);

        Response."Response Success" := HttpWebResponse.IsSuccessStatusCode();
        Response.AddResponse(ResponseTxt);

        if (not HttpWebResponse.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, HttpWebResponse.HttpStatusCode(), HttpWebResponse.ReasonPhrase(), ResponseTxt);
    end;
    #endregion

    #region aux
    /// <summary>
    /// Test the connectivity with the QuickPay API.
    /// <br />
    /// Requires the `ping` API permission.
    /// </summary>
    /// <param name="PaymentGatewayCode">Payment Gateway Code for setup</param>
    /// <param name="ResponseMsg">Response message from QuickPay</param>
    /// <returns>Boolean</returns>
    [TryFunction]
    internal procedure TestConnection(PaymentGatewayCode: Code[20]; var ResponseMsg: Text)
    var
        Setup: Record "NPR PG Quickpay Setup";
        Client: HttpClient;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseTxt: Text;
        JToken: JsonToken;
        MsgToken: JsonToken;
    begin
        Setup.Get(PaymentGatewayCode);

        Headers := Client.DefaultRequestHeaders();
        SetHeader(Headers, 'Accept', 'application/json');
        SetHeader(Headers, 'Accept-Version', 'v10');
        SetHeader(Headers, 'Authorization', CreateBasicAuth('', Setup.GetApiPassword()));

        Client.Get(APIBaseUrlTok + '/ping', Response);

        if (Response.Content.ReadAs(ResponseTxt)) then;

        if (not Response.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseTxt);

        if (ResponseTxt <> '') then begin
            JToken.ReadFrom(ResponseTxt);
            if (JToken.SelectToken('msg', MsgToken)) then
                ResponseMsg := MsgToken.AsValue().AsText();
        end;
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if (Headers.Contains(HeaderName)) then
            Headers.Remove(HeaderName);
        Headers.Add(HeaderName, HeaderValue);
    end;

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

    [TryFunction]
    local procedure TrySendWebRequest(HttpWebRequest: HttpRequestMessage; var HttpWebResponse: HttpResponseMessage)
    var
        Client: HttpClient;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);
    end;

    local procedure SetupHttpWebRequest(var HttpWebRequest: HttpRequestMessage; RequestMethod: Code[10]; PaymentRequest: Record "NPR PG Payment Request"; RequestService: Text; RequestBody: Text)
    var
        Setup: Record "NPR PG Quickpay Setup";
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        Setup.Get(PaymentRequest."Payment Gateway Code");

        Content.WriteFrom(RequestBody);
        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        Headers.Add('accept-version', 'v10');
        HeadersReq.Add('Authorization', CreateBasicAuth('', Setup.GetApiPassword()));

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri('https://api.quickpay.net/payments/' + PaymentRequest."Transaction ID" + '/' + RequestService);
        HttpWebRequest.Method := RequestMethod;
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
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

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    var
        PGQuickpaySetup: Record "NPR PG Quickpay Setup";
    begin
        if (not PGQuickpaySetup.Get(PaymentGatewayCode)) then begin
            PGQuickpaySetup.Init();
            PGQuickpaySetup.Code := PaymentGatewayCode;
            PGQuickpaySetup.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR PG Quickpay Setup Card", PGQuickpaySetup);
    end;
    #endregion
}
