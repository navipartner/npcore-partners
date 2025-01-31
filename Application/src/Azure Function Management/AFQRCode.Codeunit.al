codeunit 6185125 "NPR AF QR Code"
{
    Access = Internal;

    [NonDebuggable]
    [TryFunction]
    internal procedure GenerateQRCode(Utf8Content: Text; var Base64QrPng: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        http: HttpClient;
        secret: Text;
        resp: HttpResponseMessage;
        HttpContent: HttpContent;
    begin
        secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpAfQrCodeGenSecret');
        HttpContent.WriteFrom(Utf8Content);
        http.SetBaseAddress('https://qrscanaf.azurewebsites.net');
        http.Post(StrSubstNo('api/QRCodeGen?code=%1&modulesize=50', secret), HttpContent, resp);
        if (resp.IsSuccessStatusCode()) then
            resp.Content().ReadAs(Base64QrPng);
    end;
}