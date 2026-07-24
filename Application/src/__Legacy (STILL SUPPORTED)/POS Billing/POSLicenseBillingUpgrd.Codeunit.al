#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248547 "NPR POS License Billing Upgrd."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2026-06-05';
    ObsoleteReason = 'Replaced by NPR Module Licensing (NPR License User / NPR License Pool / NPR License Mgt.).';
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        AddPOSLicenseBillingFeature();
        MigrateValidDates();
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

    local procedure MigrateValidDates()
    var
        POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance";
        Modified: Boolean;
    begin
        UpgradeStep := 'MigrateValidDates';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS License Billing Upgrd.", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS License Billing Upgrade', UpgradeStep);

        if POSLicBillingAllowance.FindSet() then
            repeat
                Modified := false;

                // NOTE: DT2Date converts using the SESSION time zone, so a UTC-midnight "Valid Until" can shift to the
                // previous day when the upgrade runs in a UTC-negative session — diverging by up to a day from what the
                // new NPR Module Licensing parser writes. Accepted/bounded: these legacy date fields are effectively
                // display-only now (enforcement moved to NPR Module Licensing).
                if (POSLicBillingAllowance."Valid Since" <> 0DT) and (POSLicBillingAllowance."Valid Since Date" = 0D) then begin
                    POSLicBillingAllowance."Valid Since Date" := DT2Date(POSLicBillingAllowance."Valid Since");
                    Modified := true;
                end;

                if (POSLicBillingAllowance."Valid Until" <> 0DT) and (POSLicBillingAllowance."Valid Until Date" = 0D) then begin
                    POSLicBillingAllowance."Valid Until Date" := DT2Date(POSLicBillingAllowance."Valid Until");
                    Modified := true;
                end;

                if Modified then
                    POSLicBillingAllowance.Modify();
            until POSLicBillingAllowance.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS License Billing Upgrd.", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif