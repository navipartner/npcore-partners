codeunit 6059792 "NPR Background Package Imp."
{
    Access = Internal;
    TableNo = "NPR Background Package Import";

    trigger OnRun()
    var

        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        [NonDebuggable]
        BaseUri: Text;
        packageName: Text;
        [NonDebuggable]
        Secret: Text;
    begin
        packageName := Rec."Package Name".Replace('.rapidstart', '');
        BaseUri := GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidstartBaseDataMgt.ImportPackage(
            BaseUri + '/pos-test-data/' + Rec."Package Name"
            + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, Rec."Adjust Table Names");
    end;

    [NonDebuggable]
    local procedure GetAzureKeyVaultSecret(Name: Text) KeyValue: Text
    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        TextMgt: Codeunit "NPR Text Mgt.";
        AppKeyVaultSecretProviderInitialised: Boolean;
    begin
        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
            if not AppKeyVaultSecretProviderInitialised then
                AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

            if not AppKeyVaultSecretProviderInitialised then
                Error(GetLastErrorText());

            if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then
                InMemorySecretProvider.AddSecret(Name, KeyValue)
            else
                Error(TextMgt.GetSecretFailedErr(), Name);
        end;
    end;
}