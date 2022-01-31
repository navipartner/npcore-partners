codeunit 6059829 "NPR Upgrade Shipping Provider"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        UpgradeShippingProvider();
    end;

    local procedure UpgradeShippingProvider()
    var
        ShippingProviderSetup: Record "NPR Shipping Provider Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider")) then
            exit;
        if ShippingProviderSetup.get() then begin
            if ShippingProviderSetup."Api Key" <> '' then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Shipmondo;
            if ShippingProviderSetup."Use Pacsoft integration" then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Pacsoft;
            if ShippingProviderSetup."Use Consignor" then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Consignor;
            ShippingProviderSetup."Enable Shipping" := true;
            ShippingProviderSetup.modify();
        end;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider"));
    end;
}