codeunit 6014525 "NPR MobilePayV10 Get Payment"
{
    // GET /v10/payments/{paymentid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        MobilePayV10PaymentBuff: Record "NPR MobilePayV10 Payment" temporary;
        MobilePayV10PaymentBuffInitiated: Boolean;
        PAYMENT_DETAIL_BUFFER_NOT_INITIALIZED: Label 'Payment detail buffer has not been initiated! This is a programming bug.';

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

    internal procedure SetPaymentDetailBuffer(var MobilePayV10PaymentBuffer: Record "NPR MobilePayV10 Payment" temporary)
    begin
        MobilePayV10PaymentBuff.Copy(MobilePayV10PaymentBuffer, true);
        MobilePayV10PaymentBuffInitiated := true;
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
        if (not MobilePayV10PaymentBuffInitiated) then begin
            Error(PAYMENT_DETAIL_BUFFER_NOT_INITIALIZED);
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
        paymentId: Text;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, GetEndpoint());

        jsonResponse.SelectToken('paymentId', jsonToken);
        Evaluate(paymentId, jsonToken.AsValue().AsText());

        if (not MobilePayV10PaymentBuff.Get(paymentId)) then begin
            MobilePayV10PaymentBuff.Init();
            MobilePayV10PaymentBuff.PaymentId := paymentId;
            MobilePayV10PaymentBuff.Insert();
        end;

        jsonResponse.SelectToken('posId', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.PosId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('orderId', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.OrderId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('amount', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.Amount, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('currencyCode', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.CurrencyCode, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('merchantPaymentLabel', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.MerchantPaymentLabel, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('plannedCaptureDelay', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.PlannedCaptureDelay, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('status', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.Status, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('paymentExpiresAt', jsonToken);
        Evaluate(MobilePayV10PaymentBuff.PaymentExpiresAt, jsonToken.AsValue().AsText());

        if (jsonResponse.SelectToken('pollDelayInMs', jsonToken)) then begin
            Evaluate(MobilePayV10PaymentBuff.PollDelayInMs, jsonToken.AsValue().AsText());
        end;

        MobilePayV10PaymentBuff.Modify();
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/payments/');
    end;
}