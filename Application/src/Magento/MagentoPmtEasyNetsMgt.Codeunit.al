
codeunit 6151427 "NPR Magento Pmt. EasyNets Mgt"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', true, true)]
    local procedure OnPayCapture(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
        if PaymentGateway."Capture Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        SetBaseAPIUrl(PaymentGateway);
        CapturePayment(PaymentGateway, PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
        if PaymentGateway."Refund Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Cr.Memo Header"]) then
            exit;

        RefundPayment(PaymentGateway, PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if PaymentGateway."Cancel Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        if PaymentLine."Charge ID" <> '' then // Payment has already been captured -> exit
            exit;

        CancelPayment(PaymentGateway, PaymentLine);
    end;

    local procedure CapturePayment(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentLine: record "NPR Magento Payment Line")
    var
        Url: Text;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Request: Text;
        Content: HttpContent;
        FormattedAmount: Text;
        Response: JsonToken;
    begin
        PaymentGateway.TestField(Token);

        FormattedAmount := GetApiAmount(PaymentLine.Amount);
        Request :=
                    '{' +

                        '"amount":' + FormattedAmount + ',' +
                        '"orderItems":[' +
                                        '{' +
                                            '"reference":' + '"' + format(PaymentLine."Document No.") + '"' + ',' +
                                            '"name":' + '"' + format(PaymentLine.Description) + '"' + ',' +
                                            '"quantity":1,' +
                                            '"unit":"pcs",' +
                                            '"grossTotalAmount":' + FormattedAmount +

                                         '}' +
                                    ']' +
                    '}';



        Content.WriteFrom(Request);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        Url := PaymentGateway."Api Url" + 'payments/' + paymentline."No." + '/charges';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + PaymentGateway.Token);
        SendHttpRequest(RequestMessage, ResponseText);

        Response.ReadFrom(ResponseText);
        paymentline."Charge ID" := CopyStr(GetJsonText(Response, 'chargeId', 0), 1, MaxStrLen(paymentline."Charge ID"));
        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
    end;

    local procedure RefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentLine: record "NPR Magento Payment Line")
    var
        Url: Text;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        RequestTxt: Text;
        Content: HttpContent;
        Response: JsonToken;
    begin
        // Try to get the payment's charge id.
        if PaymentLine."Charge ID" = '' then begin
            PaymentLine."Charge ID" := GetChargeId(PaymentGateway, PaymentLine."No.");
            PaymentLine.Modify(true);
            Commit();
        end;

        PaymentLine.TestField("Charge ID");
        PaymentGateway.TestField(Token);

        RequestTxt := '{' + '"amount":' + GetApiAmount(PaymentLine.Amount) + '}';
        Content.WriteFrom(RequestTxt);

        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');

        Url := PaymentGateway."Api Url" + 'charges/' + paymentline."Charge ID" + '/refunds';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + PaymentGateway.Token);
        SendHttpRequest(RequestMessage, ResponseText);

        Response.ReadFrom(ResponseText);
        PaymentLine."Date Refunded" := Today();
        PaymentLine.Modify(true);

    end;

    local procedure CancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentLine: record "NPR Magento Payment Line")
    var
        Url: Text;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        Request: Text;
        Content: HttpContent;
        FormattedAmount: Text;
        Response: JsonToken;
    begin
        PaymentGateway.TestField(Token);

        FormattedAmount := GetApiAmount(PaymentLine.Amount);
        Request := '{' + '"amount":' + FormattedAmount + '}';

        Content.WriteFrom(Request);
        Content.GetHeaders(Headers);
        SetHeader(Headers, 'Content-Type', 'application/json');
        Url := PaymentGateway."Api Url" + 'payments/' + paymentline."No." + '/cancels';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + PaymentGateway.Token);
        SendHttpRequest(RequestMessage, ResponseText);

        Response.ReadFrom(ResponseText);
        message(ResponseText);

    end;

    local procedure SendHttpRequest(Var RequestMessage: HttpRequestMessage; var ResponseText: Text);
    var
        Client: HttpClient;
        ErrorText: Text;
        ResponseMessage: HttpResponseMessage;
    begin
        Clear(ResponseMessage);
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error(GetLastErrorText);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ErrorText := Format(ResponseMessage.HttpStatusCode(), 0, 9) + ': ' + ResponseMessage.ReasonPhrase;
            if ResponseMessage.Content.ReadAs(ResponseText) then
                ErrorText += ':\' + ResponseText;
            Error(CopyStr(ErrorText, 1, 1000));
        end;
        ResponseMessage.Content.ReadAs(ResponseText);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Pmt. EasyNets Mgt");
    end;

    local procedure SetBaseAPIUrl(var PaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        if PaymentGateway."Api Url" = '' then begin
            PaymentGateway."Api Url" := 'https://test.api.dibspayment.eu/v1/';
            PaymentGateway.Modify(true);
            Commit();

        end;
    end;

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

    local procedure GetChargeId(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentID: Code[50]): Text
    var
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        ResponseTxt: Text;
        JsonResponse: JsonToken;
        JsonCharges: JsonToken;
        JsonCharge: JsonToken;
        PaymentIDEmptyErr: Label 'Payment ID cannot be empty. This is a programming bug, not user error. Please contact system vendor.';
        MultipleChargesErr: Label 'This payment has multiple charges. The current integration does not support refunding partially captured transactions.\Please refund directly in Nets admin panel.';
    begin
        if PaymentID = '' then
            Error(PaymentIDEmptyErr);

        PaymentGateway.TestField(Token);

        // Ensure we have a "/" at the end of the API url.
        if not (PaymentGateway."Api Url"[StrLen(PaymentGateway."Api Url")] = '/') then
            PaymentGateway."Api Url" += '/';

        RequestMessage.SetRequestUri(PaymentGateway."Api Url" + 'payments/' + PaymentID);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(Headers);
        SetHeader(Headers, 'Authorization', 'Bearer ' + PaymentGateway.Token);
        SendHttpRequest(RequestMessage, ResponseTxt); // This call will error if the HTTP request fails

        JsonResponse.ReadFrom(ResponseTxt);
        if not JsonResponse.SelectToken('$.payment.charges', JsonCharges) then
            exit('');

        if JsonCharges.AsArray().Count = 0 then
            exit('');

        if JsonCharges.AsArray().Count = 1 then begin
            JsonCharges.AsArray().Get(0, JsonCharge); // Unlike a lot of other things in BC this is 0-indexed...
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
}
