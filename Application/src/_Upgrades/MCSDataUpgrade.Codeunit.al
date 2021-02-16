codeunit 6014412 "NPR MCS Data Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        if UpgradeTagMgt.HasUpgradeTag(GetMagentoPassUpgradeTag()) then
            exit;

        UpdateSetupAPIKeys();
        UpgradeTagMgt.SetUpgradeTag(GetMagentoPassUpgradeTag());
    end;

    local procedure GetMagentoPassUpgradeTag(): Text
    begin
        exit('NPR_MCS_Data_Upgrade');
    end;

    local procedure UpdateSetupAPIKeys()
    var
        NPRMCSAPISetup: Record "NPR MCS API Setup";
    begin
        if NPRMCSAPISetup.FindSet() then
            repeat
                NPRMCSAPISetup.Validate("Key 1");
                NPRMCSAPISetup.Validate("Key 2");
                NPRMCSAPISetup.Modify(false);
            until NPRMCSAPISetup.Next() = 0;
    end;
}
