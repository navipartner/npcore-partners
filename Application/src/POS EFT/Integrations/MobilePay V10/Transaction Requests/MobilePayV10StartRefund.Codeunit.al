codeunit 6014557 "NPR MobilePayV10 Start Refund"
{
    // POST  /v10/refunds
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
        jsonResponse: JsonObject;
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        posUnit: Record "NPR POS Unit";
        beaconTypes: JsonArray;
        eftSetup: Record "NPR EFT Setup";
        procEftTrxRequest: Record "NPR EFT Transaction Request";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        if (eftTrxRequest."Processed Entry No." <> 0) then begin
            procEftTrxRequest.GET(eftTrxRequest."Processed Entry No.");
            procEftTrxRequest.TestField("Processing Type", procEftTrxRequest."Processing Type"::PAYMENT);
            procEftTrxRequest.TestField(Successful, true);
            procEftTrxRequest.TestField("Reference Number Output");
        end else begin
            // TODO: ??? Report a problem => We need their payment ID, without it we can't do anything here.
            // 
        end;

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, headers);
        httpRequestHelper.SetHeader('x-mobilepay-idempotency-key', Format(eftTrxRequest."Entry No."));

        jsonRequest.Add('paymentId', procEftTrxRequest."Reference Number Output");
        jsonRequest.Add('refundOrderId', eftTrxRequest."Reference Number Input");
        jsonRequest.Add('amount', Abs(eftTrxRequest."Amount Input"));
        jsonRequest.Add('currencyCode', eftTrxRequest."Currency Code");
        jsonRequest.WriteTo(_request);
        reqMessage.Content.WriteFrom(_request);
        reqMessage.Content.GetHeaders(headers);
        headers.Clear();
        headers.Add('content-type', 'application/json');
        reqMessage.Method := 'POST';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/refunds');

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
        jsonArray: JsonArray;
        paymentResult: Enum "NPR MobilePayV10 Result Code";
        amount: Decimal;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('refundId', jsonToken);
        eftTrxRequest."Reference Number Output" := jsonToken.AsValue().AsText();
        eftTrxRequest.Modify();
    end;
}