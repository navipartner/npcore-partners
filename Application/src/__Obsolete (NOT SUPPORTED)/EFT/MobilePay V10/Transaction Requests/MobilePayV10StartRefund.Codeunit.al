﻿codeunit 6014557 "NPR MobilePayV10 Start Refund"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';
    // POST  /v10/refunds
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
    var
        ReqRespLbl: Label '==Request==\%1\\==Response==\(%2)\%3', Locked = true;
    begin
        exit(StrSubstNo(ReqRespLbl, _request, _responseHttpCode, _response));
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
        jsonRequest: JsonObject;
        mobilePayUnitSetup: Record "NPR MobilePayV10 Unit Setup";
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
        eftTrxRequest.TestField(Token);

        mobilePayProtocol.SetGenericHeaders(eftSetup, reqMessage, httpRequestHelper, headers, eftTrxRequest);

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
        jsonResponse: JsonObject;
        mobilePayProtocol: Codeunit "NPR MobilePayV10 Protocol";
    begin
        mobilePayProtocol.PreHandlerTheResponse(reqMessage, respMessage, jsonResponse, true, '');

        jsonResponse.SelectToken('refundId', jsonToken);
#pragma warning disable AA0139
        eftTrxRequest."Reference Number Output" := jsonToken.AsValue().AsText();
#pragma warning restore AA0139
        eftTrxRequest.Modify();
    end;
}