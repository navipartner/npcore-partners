codeunit 6014516 "NPR MobilePayV10 Find Refund"
{
    // GET /v10/refunds
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _filter: Text;
        NOT_ONE_PAYMENT: Label 'Result did not contain a single payment';
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

    internal procedure SetFilter(filter: Text)
    begin
        _filter := filter;
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
        requestUrl: Text;
        httpRequestHelper: Codeunit "NPR HttpRequest Helper";
    begin
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        reqMessage.Method := 'GET';
        requestUrl := mobilePayProtocol.GetURL(eftSetup) + '/pos/v10/refunds';
        if (_filter <> '') then begin
            requestUrl += StrSubstNo('?%1', _filter);
        end;
        reqMessage.SetRequestUri(requestUrl);

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
        mobilePayAuxRequestType: Enum "NPR MobilePayV10 Auxiliary Request";
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('refundIds', jsonToken);
        jsonArray := jsonToken.AsArray();

        if (not MobilePayV10RefundBuffInitiated) then begin
            Error(REFUND_DETAIL_BUFFER_NOT_INITIALIZED);
        end;

        ParseMultiRefundsAndInsertToBuffer(jsonArray, MobilePayV10RefundBuff);
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