codeunit 6184698 "NPR POS Action QRViewDigRcpt B"
{
    Access = Internal;

    internal procedure PrepareQRCode(POSUnit: Record "NPR POS Unit"; var TimeoutIntervalSec: Integer)
    var
        POSReceiptProfile: Record "NPR POS Receipt Profile";
    begin
        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit;

        if (POSReceiptProfile."QRCode Time Interval Enabled") and (POSReceiptProfile."QRCode Timeout Interval(sec.)" > 0) then
            TimeoutIntervalSec := POSReceiptProfile."QRCode Timeout Interval(sec.)";
    end;

    local procedure GenerateQRCodeAZ(DataToEncode: Text; ECCLevel: Text; EciMode: Text; ForceUTF8: Boolean; UTF8BOM: Boolean; PixelsPerModule: Integer): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Secret: Text;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        JsonResp: Text;
        JsonReq: Text;
        JsonTokValue: JsonToken;
        JsonObj: JsonObject;
    begin
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('QRCodeGenerator');
        JsonReq := CreateQRCodeJSON(DataToEncode, ECCLevel, EciMode, ForceUTF8, UTF8BOM, PixelsPerModule);
        Content.WriteFrom(JsonReq);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/json; charset=utf-8');
        RequestMessage.Content(Content);
        RequestMessage.Method('POST');
        RequestMessage.SetRequestUri(Secret);
        Client.Timeout(5000);
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error(GetLastErrorText());
        if not ResponseMessage.IsSuccessStatusCode then
            Error('%1 - %2', ResponseMessage.IsSuccessStatusCode, ResponseMessage.ReasonPhrase);

        Clear(Content);
        ResponseMessage.Content.ReadAs(JsonResp);
        if not JsonObj.ReadFrom(JsonResp) then
            Error(JsonResp);

        JsonObj.Get('QRCode', JsonTokValue);
        exit(JsonTokValue.AsValue().AsText());
    end;

    local procedure CreateQRCodeJSON(DataToEncode: Text; ECCLevel: Text; EciMode: Text; ForceUTF8: Boolean; UTF8BOM: Boolean; PixelsPerModule: Integer) ContentText: Text
    var
        JObject: JsonObject;
    begin
        JObject.Add('DataToEncode', DataToEncode);
        JObject.Add('ECCLevel', ECCLevel);
        JObject.Add('EciMode', EciMode);
        JObject.Add('ForceUTF8', ForceUTF8);
        JObject.Add('UTF8BOM', UTF8BOM);
        JObject.Add('PixelsPerModule', PixelsPerModule);
        JObject.WriteTo(ContentText);
    end;

    internal procedure GenerateQRCode(QRCodeLink: Text) QRCode: Text
    begin
        QRCode := GenerateQRCodeAZ(QRCodeLink, 'M', 'UTF8', true, true, 2);
    end;
}
