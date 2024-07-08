codeunit 6184651 "NPR AF Planet Proxy"
{
    Access = Internal;

    var
        _FunctionAppName: Label 'PlanetPaymentProxy', Locked = true;
        _AzureKeyVaultNameForSubKey: Label 'PlanetPaymentProxyV1', Locked = True;

    local procedure FunctionAppVersion(): Integer;
    begin
        exit(1);
    end;

    [TryFunction]
    internal procedure RunPlanetPaymentProxy(Url: Text; Content: HttpContent; var Response: HttpResponseMessage)
    var
        Http: HttpClient;
    begin
        GetAFHttpClient(_FunctionAppName, 'RunPlanetProxy', FunctionAppVersion(), _AzureKeyVaultNameForSubKey, Http);
        Http.DefaultRequestHeaders().Add('NP-PlanetPayment-Url', Url);
        Http.Post('', Content, Response);
    end;

    [NonDebuggable]
    local procedure GetAFHttpClient(
        FunctionAppName: Text;
        AFAppAction: Text;
        AppVersion: Integer;
        AzureVaultKeyNameForSubscription: Text;
        var http: HttpClient)
    var
        AFVault: Codeunit "NPR Azure Key Vault Mgt.";
        AzureApiUrl: Label 'https://navipartner.azure-api.net', Locked = true;
        url: Text;
    begin
        url := AzureApiUrl + '/' + FunctionAppName + '/v' + Format(AppVersion) + '/' + AFAppAction + '/';
        http.SetBaseAddress(url);
        http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', AFVault.GetAzureKeyVaultSecret(AzureVaultKeyNameForSubscription));
    end;
}

