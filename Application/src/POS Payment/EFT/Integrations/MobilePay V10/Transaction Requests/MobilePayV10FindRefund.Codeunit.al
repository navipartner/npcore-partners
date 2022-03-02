#if not CLOUD
codeunit 6014516 "NPR MobilePayV10 Find Refund"
{
    Access = Internal;
    // GET /v10/refunds
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _filter: Text;
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

    internal procedure SetFilter(filter: Text)
    begin
        _filter := filter;
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
        requestUrl: Text;
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
        requestUrlLbl: Label '?%1', Locked = true;
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, eftTrxRequest);

        reqMessage.Method := 'GET';
        requestUrl := mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/refunds';
        if (_filter <> '') then begin
            requestUrl += StrSubstNo(requestUrlLbl, _filter);
        end;
        reqMessage.SetRequestUri(requestUrl);

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper);

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; var respMessage: HttpResponseMessage)
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        jsonArray: JsonArray;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('refundIds', jsonToken);
        jsonArray := jsonToken.AsArray();

        if (not MobilePayV10RefundBuffInitiated) then begin
            Error(REFUND_DETAIL_BUFFER_NOT_INITIALIZED_Err);
        end;

        ParseMultiRefundsAndInsertToBuffer(jsonArray, TempMobilePayV10RefundBuff);
    end;

    local procedure ParseMultiRefundsAndInsertToBuffer(var PaymentsJsonArray: JsonArray; var MobilePayV10RefundBuffer: Record "NPR MobilePayV10 Refund" temporary)
    var
        jsonToken: JsonToken;
    begin
        foreach jsonToken in PaymentsJsonArray do begin
            MobilePayV10RefundBuffer.Init();
            Evaluate(MobilePayV10RefundBuffer.RefundId, jsonToken.AsValue().AsText());
            MobilePayV10RefundBuffer.Insert();
        end;
    end;
}
#endif