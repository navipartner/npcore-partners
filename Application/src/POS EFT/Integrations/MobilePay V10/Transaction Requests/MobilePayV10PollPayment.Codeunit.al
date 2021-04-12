codeunit 6014554 "NPR MobilePayV10 Poll Payment"
{
    // GET  /v10/payments/{paymentid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;
        _CANCELLED: Label 'Transaction cancelled';

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
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");
        eftTrxRequest.TestField("Reference Number Output");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper);

        reqMessage.Method := 'GET';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + GetEndpoint() + eftTrxRequest."Reference Number Output");

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper, GetEndpoint());

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
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, GetEndpoint());

        jsonResponse.SelectToken('status', jsonToken);
        case jsonToken.AsValue().AsText() of
            'Prepared':
                paymentResult := paymentResult::Prepared;
            'Initiated':
                paymentResult := paymentResult::Initiated;
            'Paired':
                paymentResult := paymentResult::Paired;
            'IssuedToUser':
                paymentResult := paymentResult::IssuedTouser;
            'Reserved':
                paymentResult := paymentResult::Reserved;
            'CancelledByUser':
                paymentResult := paymentResult::CancelledByUser;
            'CancelledByClient':
                paymentResult := paymentResult::CancelledByClient;
            'CancelledByMobilePay':
                paymentResult := paymentResult::CancelledByMobilePay;
            'ExpiredAndCancelled':
                paymentResult := paymentResult::ExpiredAndCancelled;
            'Captured':
                paymentResult := paymentResult::Captured;
            'RejectedByMobilePayDueToAgeRestrictions':
                paymentResult := paymentResult::RejectedByMobilePayDueToAgeRestrictions;
        end;

        if paymentResult.AsInteger() <> eftTrxRequest."Result Code" then begin
            eftTrxRequest."Result Code" := paymentResult.AsInteger();

            if paymentResult = paymentResult::Captured then begin
                jsonResponse.SelectToken('amount', jsonToken);
                eftTrxRequest."Amount Output" := jsonToken.AsValue().AsDecimal();
                eftTrxRequest."Result Amount" := eftTrxRequest."Amount Output";
                eftTrxRequest.Successful := true;
                eftTrxRequest."External Result Known" := true;
            end;
            if paymentResult in [paymentResult::CancelledByClient,
                                 paymentResult::CancelledByMobilePay,
                                 paymentResult::CancelledByUser,
                                 paymentResult::ExpiredAndCancelled,
                                 paymentResult::RejectedByMobilePayDueToAgeRestrictions] then begin
                eftTrxRequest.Successful := false;
                eftTrxRequest."Result Display Text" := _CANCELLED;
                eftTrxRequest."Result Description" := _CANCELLED;
                eftTrxRequest."External Result Known" := true;
                eftTrxRequest.Modify();
            end;

            eftTrxRequest.Modify();
        end;
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/payments/');
    end;
}