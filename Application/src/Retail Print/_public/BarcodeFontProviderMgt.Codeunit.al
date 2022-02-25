#if not BC17
codeunit 6014528 "NPR Barcode Font Provider Mgt."
{
    var

        BarcodeFontProvider: Interface "Barcode Font Provider";

    procedure EncodeText(TextToEncode: Code[250]; BarcodeSombiology: Enum "Barcode Symbology"): Text;
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
        BarcodeFontProvider.ValidateInput(TextToEncode, BarcodeSombiology);
        exit(BarcodeFontProvider.EncodeFont(TextToEncode, BarcodeSombiology));
    end;

    procedure EncodeText(TextToEncode: Code[250]; BarcodeSombiology: Enum "Barcode Symbology"; BarcodeSetings: Record "Barcode Encode Settings"): Text;
    begin
        BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
        BarcodeFontProvider.ValidateInput(TextToEncode, BarcodeSombiology, BarcodeSetings);
        exit(BarcodeFontProvider.EncodeFont(TextToEncode, BarcodeSombiology, BarcodeSetings));
    end;

    procedure SetBarcodeSettings(CodeSet: Option "None","A","B","C"; AllowExtCharset: Boolean; EnableChecksum: Boolean; UseMod10: Boolean) BarCodeSettings: Record "Barcode Encode Settings" temporary
    begin
        BarCodeSettings.Init();
        BarCodeSettings."Code Set" := CodeSet;
        BarCodeSettings."Allow Extended Charset" := AllowExtCharset;
        BarCodeSettings."Enable Checksum" := EnableChecksum;
        BarCodeSettings."Use mod 10" := UseMod10;
    end;

    procedure SetBarcodeSimbiology(TextToEncode: Text) BarcodeSimbiology: Enum "Barcode Symbology"
    begin
        if StrLen(TextToEncode) = 13 then
            exit(BarcodeSimbiology::"EAN-13")
        else
            exit(BarcodeSimbiology::Code39);
    end;

    [NonDebuggable]
    procedure GenerateQRCodeAZ(DataToEncode: Text; ECCLevel: Text; EciMode: Text; ForceUTF8: Boolean; UTF8BOM: Boolean; PixelsPerModule: Integer): Text
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
        // {
        //     "DataToEncode": "Filip Morić",
        //     "ECCLevel": "H",
        //     "EciMode": "default",
        //     "ForceUTF8": true,
        //     "UTF8BOM": true,
        //     "PixelsPerModule": 5
        // }
        JObject.Add('DataToEncode', DataToEncode);
        JObject.Add('ECCLevel', ECCLevel);
        JObject.Add('EciMode', EciMode);
        JObject.Add('ForceUTF8', ForceUTF8);
        JObject.Add('UTF8BOM', UTF8BOM);
        JObject.Add('PixelsPerModule', PixelsPerModule);
        JObject.WriteTo(ContentText);
    end;


}
#endif
