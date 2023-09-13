codeunit 6151517 "NPR Feature Flags Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        PrepareFeatureFlags();
    end;

    local procedure PrepareFeatureFlags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'PrepareFeatureFlags')) then
            exit;
        FeatureFlagsManagement.InitFeatureFlagSetup();
        FeatureFlagsManagement.ScheduleGetFeatureFlagsIntegration();
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'PrepareFeatureFlags'));
    end;
}