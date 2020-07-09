codeunit 6014602 "Import Base NPR Data"
{
    trigger OnRun()
    begin
        ImportData();
    end;

    local procedure ImportData()
    var
        rapidStartBaseDataMgt: Codeunit "RapidStart Base Data Mgt.";
        packageName: Text;
        package: Text;
    begin
        if GuiAllowed then begin
            if not Confirm('WARNING:\This will import test data in all base & NPR tables.\Are you sure you want to continue?') then
                exit;
        end;


        package := 'BASIC-NPR.rapidstart';
        packageName := package.Replace('.rapidstart', '');

        rapidStartBaseDataMgt.ImportPackage(
                        'https://npretailbasedata.blob.core.windows.net/pos-test-data/' + package
                        + '?sv=2019-10-10&ss=b&srt=co&sp=rlx&se=2050-06-23T00:45:22Z&st=2020-06-22T16:45:22Z&spr=https&sig=kIxoirxmw87n5k1rCHwsqjjS%2FMpOTTi5fCMCYzq2cH8%3D', packageName);
    end;
}