codeunit 6014532 "NPR MobilePayV10 Capt. Payment"
{
    // POST  /v10/payments/{paymentid}/capture
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
    var
        ReqRespLbl: Label '==Request==\%1\\==Response==\(%2)\%3', Locked = true;
    begin
        exit(StrSubstNo(ReqRespLbl, _request, _responseHttpCode, _response));
    end;

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        headers: HttpHeaders;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        posUnit: Record "NPR POS Unit";
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
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/payments/' + eftTrxRequest."Reference Number Output" + '/capture');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);

    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonResponse: JsonObject;
        mobilePayResultCode: Enum "NPR MobilePayV10 Result Code";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, false, '');

        eftTrxRequest.Successful := true;
        eftTrxRequest."External Result Known" := true;
        eftTrxRequest."Amount Output" := eftTrxRequest."Amount Input";
        eftTrxRequest."Result Amount" := eftTrxRequest."Amount Input";
        eftTrxRequest."Result Code" := mobilePayResultCode::Captured.AsInteger();
        eftTrxRequest.Modify();
    end;
}