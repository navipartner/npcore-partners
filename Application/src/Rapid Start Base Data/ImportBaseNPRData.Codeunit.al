codeunit 6014602 "NPR Import Base NPR Data"
{
    trigger OnRun()
    begin
        ImportRapidPackageFromFeed('MINIMAL-NPR.rapidstart');
    end;

    procedure ImportRapidPackageFromFeed(package: Text)
    var
        autoRapidstartImportLog: Record "NPR Auto Rapidstart Import Log";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        rapidStartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        BaseUri: Text;
        packageName: Text;
        Secret: Text;
    begin
        packageName := package.Replace('.rapidstart', '');

        //Can be invoked in crane environment to auto import test data. Prevent multiple invocations on container re-creation.        
        if autoRapidstartImportLog.Get(packageName) then
            exit;

        BaseUri := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataBaseUrl');
        Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidStartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, false);

        autoRapidstartImportLog."Package Name" := packageName;
        autoRapidstartImportLog.Insert();
    end;
}