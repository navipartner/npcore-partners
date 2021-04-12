codeunit 6014529 "NPR MobilePayV10 Delete POS"
{
    // DELETE  /v10/pointofsales/{posid}
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
        headers: HttpHeaders;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
        jsonResponse: JsonObject;
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        posUnit: Record "NPR POS Unit";
        beaconTypes: JsonArray;
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, headers);
        httpRequestHelper.SetHeader('x-mobilepay-idempotency-key', Format(eftTrxRequest."Entry No."));

        reqMessage.Method := 'DELETE';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/pointofsales/' + mobilePayUnitSetup."MobilePay POS ID");

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;

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
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        eftTrxRequest."External Result Known" := true;
        eftTrxRequest.Successful := true;
        eftTrxRequest.Modify();
    end;
}