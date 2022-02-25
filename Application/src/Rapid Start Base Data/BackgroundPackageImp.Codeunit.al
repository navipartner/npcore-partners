codeunit 6059792 "NPR Background Package Imp."
{
    Access = Internal;
    TableNo = "NPR Background Package Import";

    trigger OnRun()
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        rapidstartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        [NonDebuggable]
        BaseUri: Text;
        packageName: Text;
        [NonDebuggable]
        Secret: Text;
    begin
        packageName := Rec."Package Name".Replace('.rapidstart', '');
        BaseUri := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataBaseUrl');
        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidstartBaseDataMgt.ImportPackage(
            BaseUri + '/pos-test-data/' + Rec."Package Name"
            + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, Rec."Adjust Table Names");
    end;


}