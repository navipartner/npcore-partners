codeunit 6150939 "NPR UPG EFT Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG EFT Profile', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG EFT Profile")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG EFT Profile"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeTaxFreePOSUnit();
    end;

    local procedure UpgradeTaxFreePOSUnit()
    var
        TaxFreePOSUnit: Record "NPR Tax Free POS Unit";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.SetRange("POS Tax Free Profile", '');
        if not POSUnit.FindSet(true) then
            exit;
        repeat
            TaxFreePOSUnit."POS Unit No." := POSUnit."No.";
            if TaxFreePOSUnit.Find() then begin
                POSUnit."POS Tax Free Profile" := TaxFreePOSUnit."POS Unit No.";
                POSUnit.Modify();
            end;
        until POSUnit.Next() = 0;
    end;
}