codeunit 6150970 "NPR AF HTTP Client"
{
    Access = Internal;

    var
        AzureApiUrl: Label 'https://navipartner.azure-api.net', Locked = true;
        NoSuchFunction: Label 'The specified Azure Function Action does not exist in the FunctionActionNames specification. This is a programming error, reach out to your system vendor.';

    procedure GetAFHttpClient(AFApp: Interface "NPR IAF App"; AFAppAction: Text; var http: HttpClient)
    var
        url: Text;
        acs: List of [Text];
    begin
        AFApp.FunctionActionNames(acs);
        if (not acs.Contains(AFAppAction)) then Error(NoSuchFunction);
        url := AzureApiUrl + '/' + AFApp.FunctionAppName() + '/v' + Format(AFApp.FunctionAppVersion()) + '/' + AFAppAction + '/';
        http.SetBaseAddress(url);
        http.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', GetSubscriptionKey(AFApp));
    end;


    [NonDebuggable]
    local procedure GetSubscriptionKey(AFApp: Interface "NPR IAF App"): Text
    var
        AFVault: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        exit(AFVault.GetAzureKeyVaultSecret(AFApp.AzureVaultKeyNameForSubscription()));
    end;
}