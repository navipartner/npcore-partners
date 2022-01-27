codeunit 6150929 "NPR UPG MPOS App Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG MPOS App Setup', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MPOS App Setup"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradeMPOSAppSetup();
    end;

    local procedure UpgradeMPOSAppSetup()
    var
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        MPOSProfile: Record "NPR MPOS Profile";
        MPOSAppSetup: Record "NPR MPOS App Setup";
    begin
        if not Register.FindSet() then
            exit;
        repeat
            POSUnit."No." := Register."Register No.";
            MPOSAppSetup."Register No." := Register."Register No.";
            if POSUnit.Find() and MPOSAppSetup.Find() then begin
                MPOSProfile.Code := POSUnit."No.";
                if not MPOSProfile.Find() then begin
                    MPOSProfile.Init();
                    MPOSProfile.Description := CopyStr('Upgrade from NPR Register', 1, MaxStrLen(MPOSProfile.Description));
                    MPOSProfile."Ticket Admission Web Url" := MPOSAppSetup."Ticket Admission Web Url";
                    MPOSProfile.Insert();
                    POSUnit."MPOS Profile" := MPOSProfile.Code;
                    POSUnit.Modify();
                end;
            end;
        until Register.Next() = 0;
    end;
}
