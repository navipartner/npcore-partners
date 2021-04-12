codeunit 6014552 "NPR MobilePayV10 Capt. Refund"
{
    // POST  /v10/refunds/{refundid}/capture
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
        posUnit.Get(eftSetup."POS Unit No.");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        jsonRequest.Add('amount', eftTrxRequest."Amount Input");
        jsonRequest.WriteTo(_request);
        reqMessage.Content.WriteFrom(_request);
        reqMessage.Content.GetHeaders(headers);
        headers.Clear();
        headers.Add('content-type', 'application/json');
        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/refunds/' + eftTrxRequest."Reference Number Output" + '/capture');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);

    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        stream: InStream;
        errorCode: Text;
        mobilePayResultCode: Enum "NPR MobilePayV10 Result Code";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        eftTrxRequest.Successful := true;
        eftTrxRequest."External Result Known" := true;
        eftTrxRequest."Result Amount" := eftTrxRequest."Amount Input";
        eftTrxRequest."Result Code" := mobilePayResultCode::Captured.AsInteger();
        eftTrxRequest.Modify();
    end;
}