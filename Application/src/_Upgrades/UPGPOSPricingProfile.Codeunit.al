codeunit 6150927 "NPR UPG POS Pricing Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Pricing Profile', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pricing Profile")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pricing Profile"));

        LogMessageStopwatch.LogFinish();
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
                POSPricingProfile."Item Price Codeunit ID" := POSUnit."Item Price Codeunit ID";
                POSPricingProfile."Item Price Function" := POSUnit."Item Price Function";
                POSPricingProfile.Modify();

                POSUnit."POS Pricing Profile" := POSPricingProfile.Code;
                POSUnit.Modify();
            end;
        until Register.Next() = 0;
    end;


}
