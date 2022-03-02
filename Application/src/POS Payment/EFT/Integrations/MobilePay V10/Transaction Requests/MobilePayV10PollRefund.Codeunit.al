#if not CLOUD
codeunit 6014556 "NPR MobilePayV10 Poll Refund"
{
    Access = Internal;
    // GET  /v10/refunds/{refundid}
    TableNo = "NPR EFT Transaction Request";

    var
        _request: text;
        _response: text;
        _responseHttpCode: Integer;

        CANCELLED_Lbl: Label 'Transaction cancelled';

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
        eftSetup.FindSetup(eftTrxRequest."Register No.", eftTrxRequest."Original POS Payment Type Code");
        mobilePayUnitSetup.Get(eftSetup."POS Unit No.");
        mobilePayUnitSetup.TestField("MobilePay POS ID");
        eftTrxRequest.TestField("Reference Number Output");

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, eftTrxRequest);

        reqMessage.Method := 'GET';
        reqMessage.SetRequestUri(mobilePayProtocol.GetURL(eftSetup) + GetEndpoint() + eftTrxRequest."Reference Number Output");

        mobilePayProtocol.SendAndPreHandleTheRequest(httpClient, reqMessage, respMessage, httpRequestHelper, GetEndpoint());

        _responseHttpCode := respMessage.HttpStatusCode;
        respMessage.Content.ReadAs(_response);

        ParseResponse(reqMessage, respMessage, eftTrxRequest);
    end;

    local procedure ParseResponse(var reqMessage: HttpRequestMessage; respMessage: HttpResponseMessage; var eftTrxRequest: Record "NPR EFT Transaction Request")
    var
        jsonToken: JsonToken;
        jsonResponse: JsonObject;
        paymentResult: Enum "NPR MobilePayV10 Result Code";
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
                eftTrxRequest."Result Amount" := eftTrxRequest."Amount Output" * -1;
                eftTrxRequest.Successful := true;
                eftTrxRequest."External Result Known" := true;
            end;
            if paymentResult in [paymentResult::CancelledByClient,
                     paymentResult::CancelledByMobilePay,
                     paymentResult::CancelledByUser,
                     paymentResult::ExpiredAndCancelled,
                     paymentResult::RejectedByMobilePayDueToAgeRestrictions] then begin
                eftTrxRequest.Successful := false;
                eftTrxRequest."Result Display Text" := CANCELLED_Lbl;
                eftTrxRequest."Result Description" := CANCELLED_Lbl;
                eftTrxRequest."External Result Known" := true;
                eftTrxRequest.Modify();
            end;

            eftTrxRequest.Modify();
        end;
    end;

    local procedure GetEndpoint(): Text
    begin
        exit('/pos/v10/refunds/');
    end;
}
#endif