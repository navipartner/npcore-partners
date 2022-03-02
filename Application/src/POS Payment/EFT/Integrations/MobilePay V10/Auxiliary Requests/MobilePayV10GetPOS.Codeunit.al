#if not CLOUD
codeunit 6014513 "NPR MobilePayV10 GetPOS"
{
    Access = Internal;
    // GET /v10/pointofsales/{posid}
    TableNo = "NPR EFT Setup";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _posID: Text;

    trigger OnRun()
    begin
        clear(_request);
        clear(_response);
        clear(_responseHttpCode);
        SendRequest(Rec);
    end;

    internal procedure SetPOSId(posID: Text)
    begin
        _posID := posID;
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
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/pointofsales/' + _posID);

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
#endif