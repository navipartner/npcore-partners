codeunit 6014515 "NPR MobilePayV10 Auth"
{
    // POST  /connect/token

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

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        mobilePayPaymentSetup: Record "NPR MobilePayV10 Payment Setup";
        headers: HttpHeaders;
        base64Convert: Codeunit "Base64 Convert";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        eftSetup: Record "NPR EFT Setup";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayPaymentSetup.Get(eftTrxRequest."Original POS Payment Type Code");

        reqMessage.GetHeaders(headers);
        httpRequestHelper.SetHeaderCollectionObject(headers);
        httpRequestHelper.SetHeader('accept', 'application/json');
        httpRequestHelper.SetHeader('authorization', 'Basic ' + base64Convert.ToBase64(mobilePayProtocol.GetClientId(eftSetup) + ':' + mobilePayProtocol.GetClientSecret(eftSetup)));
        httpRequestHelper.SetHeader('x-ibm-client-id', mobilePayProtocol.GetClientId(eftSetup));

        _request := 'grant_type=client_credentials&merchant_vat=' + mobilePayPaymentSetup."Merchant VAT Number";
        reqMessage.Content.WriteFrom(_request);
        reqMessage.Content.GetHeaders(headers);
        headers.Clear();
        headers.Add('content-type', 'application/x-www-form-urlencoded');

        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup, false) + '/integrator-authentication/connect/token');

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        mobilePayToken: Codeunit "NPR MobilePayV10 Token";
        jsonResponse: JsonObject;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        mobilePayToken.SetToken(jsonResponse);

        eftTrxRequest."External Result Known" := true;
        eftTrxRequest.Successful := true;
        eftTrxRequest.Modify();
    end;
}