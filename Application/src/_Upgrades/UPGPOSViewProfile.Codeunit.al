codeunit 6150931 "NPR UPG POS View Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG POS View Prof Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
    end;

    local procedure Upgrade()
    begin
        UpgradePOSViewProfile();
    end;

    local procedure UpgradePOSViewProfile()
    var
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
    begin
        if not POSUnit.FindSet() then
            exit;
        repeat
            if not POSUnit.GetProfile(POSViewProfile) then begin
                POSViewProfile.Code := POSUnit."No." + '_UPG';
                POSViewProfile.Init();
                POSViewProfile.Insert();
            end;
            POSViewProfile."Lock Timeout" := "NPR POS View LockTimeout".FromInteger(POSUnit."Lock Timeout");
            POSViewProfile.Modify();

            POSUnit."POS View Profile" := POSViewProfile.Code;
            POSUnit.Modify();
        until POSUnit.Next() = 0;
    end;


}