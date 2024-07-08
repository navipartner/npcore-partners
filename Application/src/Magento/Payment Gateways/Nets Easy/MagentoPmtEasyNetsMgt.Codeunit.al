
codeunit 6151427 "NPR Magento Pmt. EasyNets Mgt" implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        WrongTableSuppliedErr: Label 'Table no. %1 was not expected. Expected %2', Comment = '%1 = actual table no., %2 = expected table no.';
        BadApiResponseErr: Label 'Received a bad response from the Nets Easy API.\Status code: %1 - %2\Body: %3', Comment = '%1 = http status code, %2 = http reason phrase, %3 = response body';
        MissingChargeID: Label 'The integration was not supplied or could not find the last charge id which is a requirement for refunding. Could not refund the payment %1!', Comment = '%1 = transaction id';
        PaymentIDEmptyErr: Label 'Payment ID cannot be empty. This is a programming bug, not user error. Please contact system vendor.';
        MultipleChargesErr: Label 'This payment has multiple charges. The current integration does not support refunding partially captured transactions.\Please refund directly in Nets admin panel.';

    #region Payment Integration
    local procedure CapturePayment(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        Url: Text;
        Headers: HttpHeaders;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        RequestTxt: Text;
        Content: HttpContent;
        FormattedAmount: Text;
        ResponseToken: JsonToken;
        NetsEasySetup: Record "NPR PG Nets Easy Setup";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        NetsEasySetup.Get(Request."Payment Gateway Code");
        NetsEasySetup.VerifyHasAuthorizationToken();

        if (Request."Document Table No." <> Database::"Sales Invoice Header") then
            Error(WrongTableSuppliedErr, Request."Document Table No.", Database::"Sales Invoice Header");

        SalesInvHeader.GetBySystemId(Request."Document System Id");

        FormattedAmount := GetApiAmount(Request."Request Amount");

        RequestTxt :=
                    '{' +
                        '"amount":' + FormattedAmount + ',' +
                        '"orderItems":[' +
                                        '{' +
                                            '"reference":' + '"' + Format(SalesInvHeader."No.", 0, 9) + '"' + ',' +
                                            '"name":' + '"' + Format(Request."Request Description", 0, 9) + '"' + ',' +
                                            '"quantity":1,' +
                                            '"unit":"pcs",' +
                                            '"grossTotalAmount":' + FormattedAmount +
                                         '}' +
                                    ']' +
                    '}';

        Request.AddBody(RequestTxt);

        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        Url := NetsEasySetup.GetBaseAPIUrl() + 'payments/' + Request."Transaction ID" + '/charges';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + NetsEasySetup.GetAuthorizationToken());

        Client.Send(RequestMessage, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseText);
        Response.AddResponse(ResponseText);
        Response."Response Success" := ResponseMessage.IsSuccessStatusCode();

        if (ResponseToken.ReadFrom(ResponseText)) then
            Response."Response Operation Id" := CopyStr(GetJsonText(ResponseToken, 'chargeId', 0), 1, MaxStrLen(Response."Response Operation Id"));

        if (not ResponseMessage.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase(), ResponseText);
    end;

    local procedure RefundPayment(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        Url: Text;
        Headers: HttpHeaders;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        RequestTxt: Text;
        Content: HttpContent;
        NetsEasySetup: Record "NPR PG Nets Easy Setup";
    begin
        NetsEasySetup.Get(Request."Payment Gateway Code");

        // Try to get the payment's charge id.
        if Request."Last Operation Id" = '' then
#pragma warning disable AA0139
            Request."Last Operation Id" := GetChargeId(NetsEasySetup, Request."Transaction ID");
#pragma warning restore

        if (Request."Last Operation Id" = '') then
            Error(MissingChargeID, Request."Transaction ID");

        NetsEasySetup.VerifyHasAuthorizationToken();

        RequestTxt := '{' + '"amount":' + GetApiAmount(Request."Request Amount") + '}';
        Request.AddBody(RequestTxt);

        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        Url := NetsEasySetup.GetBaseAPIUrl() + 'charges/' + Request."Last Operation Id" + '/refunds';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + NetsEasySetup.GetAuthorizationToken());

        Client.Send(RequestMessage, ResponseMessage);

        ResponseMessage.Content.ReadAs(ResponseText);
        Response.AddResponse(ResponseText);
        Response."Response Success" := ResponseMessage.IsSuccessStatusCode();

        if (not ResponseMessage.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase(), ResponseText);
    end;

    local procedure CancelPayment(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        Url: Text;
        Headers: HttpHeaders;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        RequestTxt: Text;
        Content: HttpContent;
        FormattedAmount: Text;
        NetsEasySetup: Record "NPR PG Nets Easy Setup";
    begin
        NetsEasySetup.VerifyHasAuthorizationToken();

        FormattedAmount := GetApiAmount(Request."Request Amount");
        RequestTxt := '{' + '"amount":' + FormattedAmount + '}';

        Request.AddBody(RequestTxt);
        Content.WriteFrom(RequestTxt);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        Url := NetsEasySetup.GetBaseAPIUrl() + 'payments/' + Request."Transaction ID" + '/cancels';

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + NetsEasySetup.GetAuthorizationToken());

        Client.Send(RequestMessage, ResponseMessage);

        Response."Response Success" := ResponseMessage.IsSuccessStatusCode();
        ResponseMessage.Content.ReadAs(ResponseText);
        Response.AddResponse(ResponseText);

        if (not ResponseMessage.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase(), ResponseText);
    end;
    #endregion

    #region aux
    local procedure GetJsonText(JToken: JsonToken; Path: Text; MaxLen: Integer) Value: Text
    var
        Token2: JsonToken;
    begin

        if not JToken.SelectToken(Path, Token2) then
            exit('');

        Value := token2.AsValue().AsText();

        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);

        exit(Value)
    end;

    local procedure GetChargeId(NetsEasySetup: Record "NPR PG Nets Easy Setup"; PaymentID: Text): Text
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        ResponseTxt: Text;
        JsonResponse: JsonToken;
        JsonCharges: JsonToken;
        JsonCharge: JsonToken;
    begin
        if PaymentID = '' then
            Error(PaymentIDEmptyErr);

        NetsEasySetup.VerifyHasAuthorizationToken();

        RequestMessage.SetRequestUri(NetsEasySetup.GetBaseAPIUrl() + 'payments/' + PaymentID);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + NetsEasySetup.GetAuthorizationToken());

        if (not Client.Send(RequestMessage, ResponseMessage)) then
            exit('');

        if (not ResponseMessage.Content.ReadAs(ResponseTxt)) then
            exit('');

        if (not JsonResponse.ReadFrom(ResponseTxt)) then
            exit('');

        if not JsonResponse.SelectToken('$.payment.charges', JsonCharges) then
            exit('');

        if JsonCharges.AsArray().Count = 0 then
            exit('');

        if JsonCharges.AsArray().Count = 1 then begin
            JsonCharges.AsArray().Get(0, JsonCharge);
            exit(GetJsonText(JsonCharge, 'chargeId', 0));
        end;

        Error(MultipleChargesErr);
    end;

    local procedure SetHeader(var Headers: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if Headers.Contains(HeaderName) then
            Headers.Remove(HeaderName);

        Headers.Add(HeaderName, HeaderValue);
    end;

    local procedure GetApiAmount(Amount: Decimal): Text
    begin
        exit(DelChr(Format(Round(Amount * 100, 1), 0, 9), '=', '.'));
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CapturePayment(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        RefundPayment(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CancelPayment(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    var
        PGEasyNetsSetup: Record "NPR PG Nets Easy Setup";
    begin
        if (not PGEasyNetsSetup.Get(PaymentGatewayCode)) then begin
            PGEasyNetsSetup.Init();
            PGEasyNetsSetup.Code := PaymentGatewayCode;
            PGEasyNetsSetup.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR PG Nets Easy Setup Card", PGEasyNetsSetup);
    end;
    #endregion
}
