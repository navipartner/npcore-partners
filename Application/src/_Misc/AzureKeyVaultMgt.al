codeunit 6014494 "NPR Azure Key Vault Mgt."
{
    SingleInstance = true;
    Access = Internal;

    procedure GetSecret(Name: Text) KeyValue: Text
    var
        GetSecretFailedErr: Label 'Failed to retrieve Azure KeyVault secret %1', Comment = '%1 = Azure KeyVault secret name';
    begin
        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
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

    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        AppKeyVaultSecretProviderInitialised: Boolean;
}