codeunit 6014505 "NPR MobilePayV10 Get Refund"
{
    // GET /v10/refunds/{refundid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        TempMobilePayV10RefundBuff: Record "NPR MobilePayV10 Refund" temporary;
        MobilePayV10RefundBuffInitiated: Boolean;
        REFUND_DETAIL_BUFFER_NOT_INITIALIZED_Err: Label 'Refund detail buffer has not been initiated! This is a programming bug.';

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

    internal procedure SetRefundDetailBuffer(var MobilePayV10RefundBuffer: Record "NPR MobilePayV10 Refund" temporary)
    begin
        TempMobilePayV10RefundBuff.Copy(MobilePayV10RefundBuffer, true);
        MobilePayV10RefundBuffInitiated := true;
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
        if (not MobilePayV10RefundBuffInitiated) then begin
            Error(REFUND_DETAIL_BUFFER_NOT_INITIALIZED_Err);
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

        ParseResponse(reqMessage, respMessage);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage)
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        refundId: Text;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, GetEndpoint());

        jsonResponse.SelectToken('refundId', jsonToken);
        Evaluate(refundId, jsonToken.AsValue().AsText());

        if (not TempMobilePayV10RefundBuff.Get(refundId)) then begin
            TempMobilePayV10RefundBuff.Init();
            TempMobilePayV10RefundBuff.RefundId := refundId;
            TempMobilePayV10RefundBuff.Insert();
        end;

        jsonResponse.SelectToken('paymentId', jsonToken);
        Evaluate(TempMobilePayV10RefundBuff.PaymentId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('refundOrderId', jsonToken);
        Evaluate(TempMobilePayV10RefundBuff.RefundOrderId, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('amount', jsonToken);
        Evaluate(TempMobilePayV10RefundBuff.Amount, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('currencyCode', jsonToken);
        Evaluate(TempMobilePayV10RefundBuff.CurrencyCode, jsonToken.AsValue().AsText());

        jsonResponse.SelectToken('status', jsonToken);
        Evaluate(TempMobilePayV10RefundBuff.Status, jsonToken.AsValue().AsText());

        if (jsonResponse.SelectToken('pollDelayInMs', jsonToken)) then begin
            Evaluate(TempMobilePayV10RefundBuff.PollDelayInMs, jsonToken.AsValue().AsText());
        end;

        TempMobilePayV10RefundBuff.Modify();
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/refunds/');
    end;
}