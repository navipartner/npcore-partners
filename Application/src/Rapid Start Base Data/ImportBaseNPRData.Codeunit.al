codeunit 6014602 "NPR Import Base NPR Data"
{
    trigger OnRun()
    var
        AllObj: Record AllObj;
        Attempts: Integer;
    begin
        //We've had problems that invoking this codeunit on a container programmatically right after publishing npretail give errors on missing npretail tables. 
        //This shouldn't be possible NST behaviour, so we try to workaround what appears to be a race condition in MS end by delaying up to 100 seconds:        

        while (not AllObj.Get(AllObj."Object Type"::Table, 6014404) and (Attempts < 10)) do begin
            Attempts += 1;
            Sleep(1000 * 10);
        end;

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
        EnvironmentHandler: Codeunit "NPR Environment Handler";
    begin
        packageName := package.Replace('.rapidstart', '');

        //Can be invoked in crane environment to auto import test data. Prevent multiple invocations on container re-creation.        
        if autoRapidstartImportLog.Get(packageName) then
            exit;

        EnvironmentHandler.EnableAllowHttpInSandbox();

        BaseUri := 'https://npretailbasedata.blob.core.windows.net';
        Secret := AzureKeyVaultMgt.GetSecret('NpRetailBaseDataSecret');

        BindSubscription(rapidStartBaseDataMgt);
        rapidStartBaseDataMgt.ImportPackage(
                        BaseUri + '/pos-test-data/' + package + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret, packageName, false);

        autoRapidstartImportLog."Package Name" := CopyStr(packageName, 1, MaxStrLen(autoRapidstartImportLog."Package Name"));
        autoRapidstartImportLog.Insert();
    end;
}