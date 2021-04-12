codeunit 6014505 "NPR MobilePayV10 Get Refund"
{
    // GET /v10/refunds/{refundid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        MobilePayV10RefundBuff: Record "NPR MobilePayV10 Refund" temporary;
        MobilePayV10RefundBuffInitiated: Boolean;
        REFUND_DETAIL_BUFFER_NOT_INITIALIZED: Label 'Refund detail buffer has not been initiated! This is a programming bug.';

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

    internal procedure SetRefundDetailBuffer(var MobilePayV10RefundBuffer: Record "NPR MobilePayV10 Refund" temporary)
    begin
        MobilePayV10RefundBuff.Copy(MobilePayV10RefundBuffer, true);
        MobilePayV10RefundBuffInitiated := true;
    end;

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        jsonResponse: JsonObject;
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        posUnit: Record "NPR POS Unit";
        beaconTypes: JsonArray;
        eftSetup: Record "NPR EFT Setup";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        if (not MobilePayV10RefundBuffInitiated) then begin
            Error(REFUND_DETAIL_BUFFER_NOT_INITIALIZED);
        end;

        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        reqMessage.Method := 'GET';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + GetEndpoint() + eftTrxRequest."Reference Number Output");

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonToken: JsonToken;
        mobilePayToken: Codeunit "NPR MobilePayV10 Token";
        jsonResponse: JsonObject;
        stream: InStream;
        errorCode: Text;
        jsonArray: JsonArray;
        refundId: Text;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, GetEndpoint());

        jsonResponse.SelectToken('refundId', jsonToken);
        Evaluate(refundId, jsonToken.AsValue().AsText());

        if (not MobilePayV10RefundBuff.Get(refundId)) then begin
            MobilePayV10RefundBuff.Init();
            MobilePayV10RefundBuff.RefundId := refundId;
            MobilePayV10RefundBuff.Insert();
        end;

        jsonResponse.SelectToken('paymentId', jsonToken);
        Evaluate(MobilePayV10RefundBuff.PaymentId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('refundOrderId', jsonToken);
        Evaluate(MobilePayV10RefundBuff.RefundOrderId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('amount', jsonToken);
        Evaluate(MobilePayV10RefundBuff.Amount, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('currencyCode', jsonToken);
        Evaluate(MobilePayV10RefundBuff.CurrencyCode, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('status', jsonToken);
        Evaluate(MobilePayV10RefundBuff.Status, jsonToken.AsValue().AsText());

        if (jsonResponse.SelectToken('pollDelayInMs', jsonToken)) then begin
            Evaluate(MobilePayV10RefundBuff.PollDelayInMs, jsonToken.AsValue().AsText());
        end;

        MobilePayV10RefundBuff.Modify();
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/refunds/');
    end;
}