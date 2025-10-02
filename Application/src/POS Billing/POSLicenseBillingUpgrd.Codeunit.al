#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248547 "NPR POS License Billing Upgrd."
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
        AddPOSLicenseBillingFeature();
    end;

    local procedure AddPOSLicenseBillingFeature()
    var
        FeatureManagement: Interface "NPR Feature Management";
        Feature: Enum "NPR Feature";
    begin
        UpgradeStep := 'AddPOSBillingFeature';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS License Billing Upgrd.", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS License Billing Upgrade', UpgradeStep);

        FeatureManagement := Feature::"POS License Billing Integration";
        FeatureManagement.AddFeature();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS License Billing Upgrd.", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif