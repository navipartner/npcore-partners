codeunit 6014524 "NPR MobilePayV10 GetPOSList"
{
    Access = Internal;
    // GET  /v10/pointofsales
    TableNo = "NPR EFT Setup";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _filter: text;

    trigger OnRun()
    begin
        clear(_request);
        clear(_response);
        clear(_responseHttpCode);
        SendRequest(Rec);
    end;

    internal procedure SetFilter(filter: Text)
    begin
        _filter := filter;
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
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/pointofsales?' + _filter);

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
