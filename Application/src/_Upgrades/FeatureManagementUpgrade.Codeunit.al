codeunit 6151470 "NPR Feature Management Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        FeatureManagementInstall: Codeunit "NPR Feature Management Install";
    begin
        FeatureManagementInstall.AddFeatures();
    end;
}
