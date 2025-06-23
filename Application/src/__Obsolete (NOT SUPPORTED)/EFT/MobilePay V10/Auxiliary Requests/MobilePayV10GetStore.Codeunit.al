﻿codeunit 6014512 "NPR MobilePayV10 Get Store"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';
    // GET /v10/stores/{storeid}
    TableNo = "NPR EFT Setup";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _storeId: text;

    trigger OnRun()
    begin
        clear(_request);
        clear(_response);
        clear(_responseHttpCode);
        SendRequest(Rec);
    end;

    internal procedure SetStoreId(storeId: text)
    begin
        _storeId := storeId;
    end;

    internal procedure GetResponse(): text
    begin
        exit(_response);
    end;

    local procedure SendRequest(var eftSetup: Record "NPR EFT Setup")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        reqMessage.Method := 'GET';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/stores/' + _storeId);

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage)
    var
        jsonResponse: JsonObject;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');
    end;
}