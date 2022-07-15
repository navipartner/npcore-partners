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
        ShipmentProviderDocs: Record "NPR Shipping Provider Document";
        PacsoftSetup: Record "NPR Pacsoft Setup";
        PacsoftshipmentDocuments: Record "NPR Pacsoft Shipment Document";

    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider")) then
            exit;

        if PacsoftSetup.Get() then begin
            ShippingProviderSetup.Init();
            ShippingProviderSetup.TransferFields(PacsoftSetup);
            ShippingProviderSetup.Insert();
        end;

        if PacsoftshipmentDocuments.FindSet() then
            repeat
                ShipmentProviderDocs.Init();
                ShipmentProviderDocs.TransferFields(PacsoftshipmentDocuments);
                ShipmentProviderDocs.Insert();
            until PacsoftshipmentDocuments.Next() = 0;


        if ShippingProviderSetup.Get() then begin
            if ShippingProviderSetup."Enable Shipping" then
                exit;
            if ShippingProviderSetup."Package Service Codeunit ID" = Codeunit::"NPR Shipmondo Mgnt." then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Shipmondo;

            if ShippingProviderSetup."Use Pacsoft integration" then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Pacsoft;

            if ShippingProviderSetup."Use Consignor" then
                ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Consignor;

            ShippingProviderSetup."Enable Shipping" := true;
            ShippingProviderSetup.Modify();
        end;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider"));
    end;
}