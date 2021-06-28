
codeunit 6151427 "NPR Magento Pmt. EasyNets Mgt"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"npr Magento Pmt. Mgt.", 'CapturePaymentEvent', '', true, true)]
    local procedure OnPayCapture(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
        if PaymentGateway."Capture Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;
        BaseAPIUrl(PaymentGateway);
        CapturePayment(PaymentGateway, PaymentLine);

    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
        if PaymentGateway."Capture Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Cr.Memo Header"]) then
            exit;

        RefundPayment(PaymentGateway, PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if PaymentGateway."Capture Codeunit Id" <> CurrCodeunitId() then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        if PaymentLine."Charge ID" <> '' then
            Exit;

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


        FormattedAmount := DelChr(Format(Round(PaymentLine.Amount * 100, 1), 0, 9), '=', '.');
        request +=
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
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        url := PaymentGateway."Api Url" + 'payments/' + paymentline."No." + '/charges';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + PaymentGateway.Token);
        SendHttpRequest(RequestMessage, ResponseText);

        Response.ReadFrom(ResponseText);
        paymentline."Charge ID" := GetJsonText(Response, 'chargeId', 0);
        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
    end;

    local procedure RefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentLine: record "NPR Magento Payment Line")
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


        FormattedAmount := DelChr(Format(Round(PaymentLine.Amount * 100, 1), 0, 9), '=', '.');
        request +=
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
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        url := PaymentGateway."Api Url" + 'charges/' + paymentline."Charge ID" + '/refunds';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + PaymentGateway.Token);
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


        FormattedAmount := DelChr(Format(Round(PaymentLine.Amount * 100, 1), 0, 9), '=', '.');
        request +=
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
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        url := PaymentGateway."Api Url" + 'payments/' + paymentline."No." + '/cancels';
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.Content(Content);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', 'Bearer ' + PaymentGateway.Token);
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

    local procedure BaseAPIUrl(var PaymentGateway: Record "NPR Magento Payment Gateway")
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



}