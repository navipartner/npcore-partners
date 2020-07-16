codeunit 6014602 "Import Base NPR Data"
{
    trigger OnRun()
    begin
        ImportRapidPackageFromFeed('MINIMAL-NPR.rapidstart');
    end;

    procedure ImportRapidPackageFromFeed(package: Text)
    var
        rapidStartBaseDataMgt: Codeunit "RapidStart Base Data Mgt.";
        packageName: Text;
        autoRapidstartImportLog: Record "Auto Rapidstart Import Log";
    begin
        packageName := package.Replace('.rapidstart', '');

        //Can be invoked in crane environment to auto import test data. Prevent multiple invocations on container re-creation.        
        if autoRapidstartImportLog.Get(packageName) then
            exit;

        rapidStartBaseDataMgt.ImportPackage(
                        'https://npretailbasedata.blob.core.windows.net/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=kIxoirxmw87n5k1rCHwsqjjS%2FMpOTTi5fCMCYzq2cH8%3D', packageName);

        autoRapidstartImportLog."Package Name" := packageName;
        autoRapidstartImportLog.Insert();
    end;
}