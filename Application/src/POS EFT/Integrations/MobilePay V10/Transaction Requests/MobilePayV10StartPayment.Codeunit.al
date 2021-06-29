codeunit 6014521 "NPR MobilePayV10 Start Payment"
{
    // POST  /v10/payments
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;

    trigger OnRun()
    begin
        clear(_request);
        clear(_response);
        clear(_responseHttpCode);
        SendRequest(Rec);
    end;

    internal procedure GetRequestResponse(): text
    begin
        exit(StrSubstNo('==Request==\%1\\==Response==\(%2)\%3', _request, _responseHttpCode, _response));
    end;

    internal procedure GetResponse(): Text
    begin
        exit(_response);
    end;

    internal procedure GetResponseHttpCode(): Integer
    begin
        exit(_responseHttpCode);
    end;

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        headers: HttpHeaders;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        eftSetup: Record "NPR EFT Setup";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, headers);
        httpRequestHelper.SetHeader('x-mobilepay-idempotency-key', Format(eftTrxRequest."Entry No."));

        jsonRequest.Add('posId', mobilePayUnitSetup."MobilePay POS ID");
        jsonRequest.Add('orderId', eftTrxRequest."Reference Number Input");
        jsonRequest.Add('amount', eftTrxRequest."Amount Input");
        jsonRequest.Add('currencyCode', eftTrxRequest."Currency Code");
        jsonRequest.Add('merchantPaymentLabel', CopyStr(StrSubstNo('%1 - %2', eftTrxRequest."Register No.", eftTrxRequest."Sales Ticket No."), 1, 36));
        jsonRequest.Add('plannedCaptureDelay', 'None'); //If we didn't capture immediately, a problem must have occurred.
        jsonRequest.WriteTo(_request);
        reqMessage.Content.WriteFrom(_request);
        reqMessage.Content.GetHeaders(headers);
        headers.Clear();
        headers.Add('content-type', 'application/json');
        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/payments');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('paymentId', jsonToken);
        eftTrxRequest."Reference Number Output" := jsonToken.AsValue().AsText();
        eftTrxRequest.Modify();
    end;
}