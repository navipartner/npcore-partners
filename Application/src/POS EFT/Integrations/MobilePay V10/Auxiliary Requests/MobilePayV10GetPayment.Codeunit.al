codeunit 6014525 "NPR MobilePayV10 Get Payment"
{
    // GET /v10/payments/{paymentid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        TempMobilePayV10Payment: Record "NPR MobilePayV10 Payment" temporary;
        TempMobilePayV10PaymentInitiated: Boolean;
        PAYMENT_DETAIL_BUFFER_NOT_INITIALIZED_Err: Label 'Payment detail buffer has not been initiated! This is a programming bug.';

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

    internal procedure SetPaymentDetailBuffer(var TempMobilePayV10Paymenter: Record "NPR MobilePayV10 Payment" temporary)
    begin
        TempMobilePayV10Payment.Copy(TempMobilePayV10Paymenter, true);
        TempMobilePayV10PaymentInitiated := true;
    end;

    local procedure SendRequest(var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        reqMessage: HttpRequestMessage;
        httpClient: HttpClient;
        respMessage: HttpResponseMessage;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
        eftSetup: Record "NPR EFT Setup";
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        if (not TempMobilePayV10PaymentInitiated) then begin
            Error(PAYMENT_DETAIL_BUFFER_NOT_INITIALIZED_Err);
        end;

        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, eftTrxRequest);

        reqMessage.Method := 'GET';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + GetEndpoint() + eftTrxRequest."Reference Number Output");

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage)
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        paymentId: Text;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, GetEndpoint());

        jsonResponse.SelectToken('paymentId', jsonToken);
        Evaluate(paymentId, jsonToken.AsValue().AsText());

        if (not TempMobilePayV10Payment.Get(paymentId)) then begin
            TempMobilePayV10Payment.Init();
            TempMobilePayV10Payment.PaymentId := paymentId;
            TempMobilePayV10Payment.Insert();
        end;

        jsonResponse.SelectToken('posId', jsonToken);
        Evaluate(TempMobilePayV10Payment.PosId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('orderId', jsonToken);
        Evaluate(TempMobilePayV10Payment.OrderId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('amount', jsonToken);
        Evaluate(TempMobilePayV10Payment.Amount, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('currencyCode', jsonToken);
        Evaluate(TempMobilePayV10Payment.CurrencyCode, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('merchantPaymentLabel', jsonToken);
        Evaluate(TempMobilePayV10Payment.MerchantPaymentLabel, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('plannedCaptureDelay', jsonToken);
        Evaluate(TempMobilePayV10Payment.PlannedCaptureDelay, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('status', jsonToken);
        Evaluate(TempMobilePayV10Payment.Status, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('paymentExpiresAt', jsonToken);
        Evaluate(TempMobilePayV10Payment.PaymentExpiresAt, jsonToken.AsValue().AsText());

        if (jsonResponse.SelectToken('pollDelayInMs', jsonToken)) then begin
            Evaluate(TempMobilePayV10Payment.PollDelayInMs, jsonToken.AsValue().AsText());
        end;

        TempMobilePayV10Payment.Modify();
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/payments/');
    end;
}