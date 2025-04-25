codeunit 6150746 "NPR Adyen Data Collection" implements "NPR MM IAdd. Info. Request"
{
    Access = Internal;


    procedure RequestAdditionalInfo(TempAddInfoRequest: Record "NPR MM Add. Info. Request" temporary; var TempAddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        EFTAdyenSignatureReq: Codeunit "NPR EFT Adyen Signature Req.";
        AdyenAcqPhoneNoReq: Codeunit "NPR Adyen Acq Phone No Req.";
        EFTAdyenAcqEMailReq: Codeunit "NPR EFT Adyen Acq EMail Req.";
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        DataCollectionStep: Enum "NPR Data Collect Step";
        Response: Text;
        Request: Text;
        URL: Text;
        Logs: Text;
        StatusCode: Integer;
        Completed: Boolean;
        Started: Boolean;
        JObject: JsonObject;
        JValue: JsonValue;
        ResponseInput: Text;
        OutStr: OutStream;
        JToken: JsonToken;
        ScreenTimeoutLbl: Label 'Screen%20timeout', Locked = true;
    begin
        EFTTransactionRequest.Get(TempAddInfoRequest."EFT Transaction No.");

        DataCollectionStep := TempAddInfoRequest."Data Collection Step";
        case DataCollectionStep of
            TempAddInfoRequest."Data Collection Step"::Signature:
                Request := EFTAdyenSignatureReq.GetRequestJson(EFTTransactionRequest);
            TempAddInfoRequest."Data Collection Step"::PhoneNo:
                Request := AdyenAcqPhoneNoReq.GetRequestJson(EFTTransactionRequest);
            TempAddInfoRequest."Data Collection Step"::EMail:
                Request := EFTAdyenAcqEMailReq.GetRequestJson(EFTTransactionRequest);
        end;

        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);
        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKeyFromReturnCollectionSetup(), URL, 1000 * 60 * 5, Response, StatusCode);
        Started := StatusCode in [0, 200]; //if we got 403 or other 4xx transaction didn't even start
        Logs := EFTAdyenCloudProtocol.GetLogBuffer();

        TempAddInfoResponse.Started := Started;
        TempAddInfoResponse.Completed := Completed;

        JObject.ReadFrom(Response);

        if EFTAdyenResponseParser.TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Response.Result', JValue, false) then begin
            ResponseInput := JValue.AsText();
            TempAddInfoResponse."Response Result" := CopyStr(ResponseInput, 1, MaxStrLen(TempAddInfoResponse."Response Result"));
            if ResponseInput = 'Success' then
                TempAddInfoResponse.Success := true;
        end;

        if EFTAdyenResponseParser.TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Response.ErrorCondition', JValue, false) then
            TempAddInfoResponse."Error Condition" := CopyStr(JValue.AsText(), 1, MaxStrLen(TempAddInfoResponse."Error Condition"));

        case DataCollectionStep of
            TempAddInfoRequest."Data Collection Step"::Signature:
                begin
                    if EFTAdyenResponseParser.TrySelectToken(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Input.ConfirmedFlag', JToken, false) then
                        TempAddInfoResponse."Confirmed Flag" := JToken.AsValue().AsBoolean();
                    if EFTAdyenResponseParser.TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Response.AdditionalResponse', JValue, false) then begin
                        if JValue.AsText().TrimStart('message=') = ScreenTimeoutLbl then
                            TempAddInfoResponse."Screen Timeout" := true
                        else begin
                            ResponseInput := JValue.AsText();
                            TempAddInfoResponse."Signature Data".CreateOutStream(OutStr);
                            OutStr.Write(ResponseInput);
                        end;
                    end;
                end;
            TempAddInfoRequest."Data Collection Step"::PhoneNo:
                begin
                    if TempAddInfoResponse.Success then
                        TempAddInfoResponse."Confirmed Flag" := true;
                    if EFTAdyenResponseParser.TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Input.DigitInput', JValue, false) then begin
                        ResponseInput := JValue.AsText();
                        TempAddInfoResponse."Phone No." := CopyStr(ResponseInput.TrimStart('"').TrimEnd('"'), 1, MaxStrLen(TempAddInfoResponse."Phone No."));
                    end;
                end;
            TempAddInfoRequest."Data Collection Step"::EMail:
                begin
                    if TempAddInfoResponse.Success then
                        TempAddInfoResponse."Confirmed Flag" := true;
                    if EFTAdyenResponseParser.TrySelectValue(JObject, 'SaleToPOIResponse.InputResponse.InputResult.Input.TextInput', JValue, false) then begin
                        ResponseInput := JValue.AsText();
                        TempAddInfoResponse."E-Mail" := CopyStr(ResponseInput.TrimStart('"').TrimEnd('"'), 1, MaxStrLen(TempAddInfoResponse."E-Mail"));
                    end;
                end;
        end;
    end;
}
