codeunit 6151514 "NPR Feature Flags Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        PrepareFeatureFlags();
    end;

    local procedure PrepareFeatureFlags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Install", 'PrepareFeatureFlags')) then
            exit;
        FeatureFlagsManagement.InitFeatureFlagSetup();
        FeatureFlagsManagement.ScheduleGetFeatureFlagsIntegration();
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Install", 'PrepareFeatureFlags'));
    end;
}