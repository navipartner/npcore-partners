codeunit 6151351 "NPR UPG Tax Free"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Tax Free', 'OnUpgradePerCompany');

        UpgradeTaxFreePOSProfile();

        UpgradeTaxFreePOSProfileTable();

        LogMessageStopwatch.LogFinish();
    end;

    procedure UpgradeTaxFreePOSProfileTable()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        NPRTaxFreePOSUnit: Record "NPR Tax Free POS Unit";
        NPRPOSTaxFreeProfile: Record "NPR POS Tax Free Profile";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Tax Free', 'NPRTaxFreePOSProfileTable');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfileTable')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if NPRTaxFreePOSUnit.FindSet() then
            repeat
                if NPRPOSTaxFreeProfile."Handler Parameters".HASVALUE then
                    NPRPOSTaxFreeProfile.CALCFIELDS("Handler Parameters");
                NPRPOSTaxFreeProfile.TransferFields(NPRTaxFreePOSUnit);
                NPRPOSTaxFreeProfile.Insert();
            until NPRTaxFreePOSUnit.Next() = 0;


        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfileTable'));

        LogMessageStopwatch.LogFinish();
    end;

    procedure UpgradeTaxFreePOSProfile()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        NPRPOSUnit: Record "NPR POS Unit";
        NPRTaxFreePOSUnit: Record "NPR Tax Free POS Unit";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Tax Free', 'NPRTaxFreePOSProfile');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfile')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if NPRPOSUnit.FindSet() then
            repeat
                if NPRPOSUnit."POS Tax Free Prof." = '' then begin
                    if NPRTaxFreePOSUnit.Get(NPRPOSUnit."No.") then
                        NPRPOSUnit."POS Tax Free Prof." := NPRTaxFreePOSUnit."POS Unit No.";
                end;
                NPRPOSUnit.Modify();
            until NPRPOSUnit.Next() = 0;


        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Tax Free", 'NPRTaxFreePOSProfile'));

        LogMessageStopwatch.LogFinish();
    end;

}