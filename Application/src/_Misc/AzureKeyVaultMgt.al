codeunit 6014494 "NPR Azure Key Vault Mgt."
{
    SingleInstance = true;
    Access = Internal;

    procedure GetSecret(Name: Text) KeyValue: Text
    var
        "NPR GetSecretFailedMessage": Label 'Failed to retrieve Azure KeyVault secret %1';
    begin
        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
            if not AppKeyVaultSecretProviderInitialised then
                AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

            if not AppKeyVaultSecretProviderInitialised then
                Error(GetLastErrorText());

            if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then
                InMemorySecretProvider.AddSecret(Name, KeyValue)
            else
                Error("NPR GetSecretFailedMessage", Name);
        end;
    end;

    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        AppKeyVaultSecretProviderInitialised: Boolean;
}