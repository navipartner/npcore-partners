codeunit 6014602 "NPR Import Base NPR Data"
{
    Access = Internal;

    var
        MissingPackageNameParamErr: Label 'Package Name is required (parameter index 1)';
        MissingSecretParamErr: Label 'NP Retail Base Data Secret is required (parameter index 2)';

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

    [NonDebuggable]
    procedure ImportRapidPackageFromFeed(package: Text)
    var
        AutoRapidstartImportLog: Record "NPR Auto Rapidstart Import Log";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        CleanPackageName: Text;
        Secret: Text;
    begin
        CleanPackageName := package.Replace('.rapidstart', '');

        if AutoRapidstartImportLog.Get(CleanPackageName) then
            exit;

        Secret := AzureKeyVaultMgt.GetAzureKeyVaultSecret('NpRetailBaseDataSecret');
        DoImportRapidPackage(package, Secret);
    end;

    [NonDebuggable]
    procedure ImportRapidPackageFromFeedWithMultipleParams(commaSeparatedParams: Text)
    var
        AutoRapidstartImportLog: Record "NPR Auto Rapidstart Import Log";
        ParamList: List of [Text];
        PackageParam: Text;
        CleanPackageName: Text;
        NpRetailBaseDataSecret: Text;
    begin
        ParamList := commaSeparatedParams.Split(',');

        if (not ParamList.Get(1, PackageParam)) then
            Error(MissingPackageNameParamErr);

        CleanPackageName := PackageParam.Replace('.rapidstart', '');

        if AutoRapidstartImportLog.Get(CleanPackageName) then
            exit;

        if (not ParamList.Get(2, NpRetailBaseDataSecret)) then
            Error(MissingSecretParamErr);

        DoImportRapidPackage(PackageParam, NpRetailBaseDataSecret);
    end;

    [NonDebuggable]
    local procedure DoImportRapidPackage(PackageName: Text; Secret: Text)
    var
        AutoRapidstartImportLog: Record "NPR Auto Rapidstart Import Log";
        RapidStartBaseDataMgt: Codeunit "NPR RapidStart Base Data Mgt.";
        BaseUri: Text;
        CleanPackageName: Text;
    begin
        CleanPackageName := PackageName.Replace('.rapidstart', '');
        BaseUri := 'https://npretailbasedata.blob.core.windows.net';

        BindSubscription(RapidStartBaseDataMgt);
        RapidStartBaseDataMgt.ImportPackage(
            BaseUri + '/pos-test-data/' + PackageName + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=' + Secret,
            CleanPackageName,
            false);

        AutoRapidstartImportLog."Package Name" := CopyStr(CleanPackageName, 1, MaxStrLen(AutoRapidstartImportLog."Package Name"));
        AutoRapidstartImportLog.Insert();
    end;
}