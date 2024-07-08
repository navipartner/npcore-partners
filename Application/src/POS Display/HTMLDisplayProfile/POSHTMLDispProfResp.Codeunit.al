codeunit 6184551 "NPR POS Html Disp. Resp"
{
    Access = Internal;

    /// <summary>
    /// Returns a Json Object of form:
    /// 
    /// </summary>
    /// <param name="HwcResponse"></param>
    [TryFunction]
    internal procedure ParseGetInputResponse(HwcResponse: JsonObject; var InputObj: JsonObject)
    var
        JToken: JsonToken;
        JsResult: JsonObject;
    begin
        HwcResponse.Get('IsSuccessfull', JToken);
        if (not JToken.AsValue().AsBoolean()) then begin
            HwcResponse.Get('Error', JToken);
            Error(JToken.AsValue().AsText());
        end;
        if (not HwcResponse.Contains('Version')) then begin
            HwcResponse.Get('JSON', JToken);
            JsResult := JToken.AsObject();
            JsResult.Get('Input', JToken);
            InputObj := JToken.AsObject();
            exit;
        end;
        HwcResponse.Get('Version', JToken);
        if (JToken.AsValue().AsInteger() = 1) then begin
            HwcResponse.Get('JsResult', JToken);
            JsResult.ReadFrom(JToken.AsValue().AsText());
            JsResult.Get('IsSuccessfull', JToken);
            if (not JToken.AsValue().AsBoolean()) then begin
                JsResult.Get('Error', JToken);
                Error(JToken.AsValue().AsText());
            end;
            JsResult.Get('JSON', JToken);
            JsResult := JToken.AsObject();
            JsResult.Get('Input', JToken);
            InputObj := JToken.AsObject();
            exit;
        end;
        Error('Invalid Branch');
    end;
}