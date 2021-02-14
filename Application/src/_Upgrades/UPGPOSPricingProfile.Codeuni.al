codeunit 6150927 "NPR UPG POS Pricing Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG POS Price Prof Tag Def";
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
        UpgradePOSPricingProfile();
    end;

    local procedure UpgradePOSPricingProfile()
    var
        Register: Record "NPR Register";
        POSUnit: Record "NPR POS Unit";
        POSPricingProfile: Record "NPR POS Pricing Profile";
    begin
        if not Register.FindSet() then
            exit;
        repeat
            POSUnit."No." := Register."Register No.";
            if POSUnit.Find() then begin
                POSPricingProfile.SetRange("Customer Disc. Group", Register."Customer Disc. Group");
                POSPricingProfile.SetRange("Customer Price Group", Register."Customer Price Group");
                if not POSPricingProfile.FindFirst() then begin
                    POSPricingProfile.Reset();
                    POSPricingProfile.Code := POSUnit."No." + '_UPG';
                    POSPricingProfile.Init();
                    POSPricingProfile."Customer Disc. Group" := Register."Customer Disc. Group";
                    POSPricingProfile."Customer Price Group" := Register."Customer Price Group";
                    POSPricingProfile.Description := CopyStr('Created by running upgrade procedure', 1, MaxStrLen(POSPricingProfile.Description));
                    POSPricingProfile.Insert();
                end;
                POSUnit."POS Pricing Profile" := POSPricingProfile.Code;
                POSUnit.Modify();
            end;
        until Register.Next() = 0;
    end;


}