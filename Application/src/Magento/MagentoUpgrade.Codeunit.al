codeunit 6248468 "NPR Magento Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        EnableMagentoFeature();
    end;

    local procedure EnableMagentoFeature()
    var
        FeatureManagement: Interface "NPR Feature Management";
        Feature: Enum "NPR Feature";
    begin
        UpgradeStep := 'EnableMagentoFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Magento Upgrade', UpgradeStep);

        FeatureManagement := Feature::Magento;
        FeatureManagement.AddFeature();
        FeatureManagement.SetFeatureEnabled(true);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Magento Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
