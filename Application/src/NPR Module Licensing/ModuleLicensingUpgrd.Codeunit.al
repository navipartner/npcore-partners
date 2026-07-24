codeunit 6248194 "NPR Module Licensing Upgrd."
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        RegisterModuleLicensingFeature();
        DisableLegacyPosBillingFeature();
    end;

    local procedure RegisterModuleLicensingFeature()
    var
        FeatureManagement: Interface "NPR Feature Management";
        Feature: Enum "NPR Feature";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'RegisterModuleLicensingFeature';
        if _UpgradeTag.HasUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Module Licensing Upgrd.", UpgradeStep)) then
            exit;
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR Module Licensing Upgrade', UpgradeStep);

        FeatureManagement := Feature::"NPR Module Licensing";
        FeatureManagement.AddFeature();

        _UpgradeTag.SetUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Module Licensing Upgrd.", UpgradeStep));
        _LogMessageStopwatch.LogFinish();
    end;

    local procedure DisableLegacyPosBillingFeature()
    var
        LegacyFeatureMgt: Codeunit "NPR POS License Billing Feat.";
        UpgradeStep: Text;
    begin
        UpgradeStep := 'DisableLegacyPosBilling';
        if _UpgradeTag.HasUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Module Licensing Upgrd.", UpgradeStep)) then
            exit;
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR Module Licensing Upgrade', UpgradeStep);

        // Force the old POS billing feature off so it can't enforce licensing alongside the new module.
        // The legacy gate is already disabled elsewhere, so this is just a safety net, and it can be
        // dropped once "NPR POS License Billing Feat." is fully removed (ObsoleteState = Removed).
        LegacyFeatureMgt.SetFeatureEnabled(false);

        _UpgradeTag.SetUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Module Licensing Upgrd.", UpgradeStep));
        _LogMessageStopwatch.LogFinish();
    end;
}
