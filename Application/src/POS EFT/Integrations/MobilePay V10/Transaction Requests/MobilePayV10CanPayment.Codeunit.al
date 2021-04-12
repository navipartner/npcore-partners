codeunit 6014530 "NPR MobilePayV10 Can.Payment"
{
    // POST  /v10/payments/{paymentid}/cancel

    // This is only a request to cancel in MobilePays backend, the polling continues 
    // until the transaction is actually done or cancelled in their end.

    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;

    trigger OnRun()
    var
        rawResponse: JsonObject;
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

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
        jsonResponse: JsonObject;
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        beaconTypes: JsonArray;
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/payments/' + eftTrxRequest."Reference Number Output" + '/cancel');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);

    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonToken: JsonToken;
        mobilePayToken: Codeunit "NPR MobilePayV10 Token";
        jsonResponse: JsonObject;
        stream: InStream;
        errorCode: Text;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, false, '');
    end;
}