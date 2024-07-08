codeunit 6014494 "NPR Azure Key Vault Mgt."
{
    SingleInstance = true;
    Access = Internal;

    [NonDebuggable]
    procedure GetAzureKeyVaultSecret(Name: Text) KeyValue: Text
    var
        GetSecretFailedErr: Label 'Failed to retrieve Azure KeyVault secret %1', Comment = '%1 = Azure KeyVault secret name';
        WrongModuleErr: Label 'This procedure cannot be called from another application.';
        CallerModuleInfo: ModuleInfo;
        CurrentModuleInfo: ModuleInfo;
        SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
    begin
        if not NavApp.GetCallerModuleInfo(CallerModuleInfo) then
            exit;
        if not NavApp.GetCurrentModuleInfo(CurrentModuleInfo) then
            exit;
        if CurrentModuleInfo.Id <> CallerModuleInfo.Id then
            Error(WrongModuleErr);

        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
            if SandboxSecretInjection.TryGetSecret(Name, KeyValue) then
                exit;

            if not AppKeyVaultSecretProviderInitialised then
                AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

            if not AppKeyVaultSecretProviderInitialised then
                Error(GetLastErrorText());

            if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then
                InMemorySecretProvider.AddSecret(Name, KeyValue)
            else
                Error(GetSecretFailedErr, Name);
        end;
    end;

    [TryFunction]
    [NonDebuggable]
    procedure TryGetAzureKeyVaultSecret(Name: Text; var KeyValueOut: Text)
    begin
        KeyValueOut := GetAzureKeyVaultSecret(Name);
    end;

    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        AppKeyVaultSecretProviderInitialised: Boolean;
}