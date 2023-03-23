codeunit 6059829 "NPR Upgrade Shipping Provider"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnUpgradePerCompany()
    begin
        UpgradeShippingProvider();
        UpdatePackageDimensions();
        UpdatePackageServices();

    end;

    local procedure UpgradeShippingProvider()
    var
        ShippingProviderSetup: Record "NPR Shipping Provider Setup";
        ShipmentProviderDocs: Record "NPR Shipping Provider Document";
        PacsoftSetup: Record "NPR Pacsoft Setup";
        PacsoftshipmentDocuments: Record "NPR Pacsoft Shipment Document";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Shipping Provider', 'OnUpgradePerCompany');
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRShippingProvider')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if PacsoftSetup.Get() then
            if not ShippingProviderSetup.Get(PacsoftSetup."Primary Key") then begin
                ShippingProviderSetup.Init();
                ShippingProviderSetup.TransferFields(PacsoftSetup);
                ShippingProviderSetup.Insert();
            end;

        if PacsoftshipmentDocuments.FindSet() then
            repeat
                if not ShipmentProviderDocs.Get(PacsoftshipmentDocuments."Entry No.") then begin
                    ShipmentProviderDocs.Init();
                    ShipmentProviderDocs.TransferFields(PacsoftshipmentDocuments);
                    ShipmentProviderDocs.Insert();
                end;
            until PacsoftshipmentDocuments.Next() = 0;

        if not ShippingProviderSetup.Get() then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRShippingProvider'));
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if ShippingProviderSetup."Enable Shipping" then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRShippingProvider'));
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        if (ShippingProviderSetup."Package Service Codeunit ID" = Codeunit::"NPR Shipmondo Mgnt.")
        or (PacsoftSetup."Package Service Codeunit ID" = Codeunit::"NPR Shipmondo Mgnt.") then begin
            ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Shipmondo;
            if (ShippingProviderSetup."Api User" <> '') and (ShippingProviderSetup."Api Key" <> '') then
                ShippingProviderSetup."Enable Shipping" := true;
        end;

        if (ShippingProviderSetup."Use Pacsoft integration") or (PacsoftSetup."Use Pacsoft integration") then begin
            ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Pacsoft;
            ShippingProviderSetup."Enable Shipping" := true;
        end;

        if (ShippingProviderSetup."Use Consignor") or (PacsoftSetup."Use Consignor") then begin
            ShippingProviderSetup."Shipping Provider" := ShippingProviderSetup."Shipping Provider"::Consignor;
            ShippingProviderSetup."Enable Shipping" := true;
        end;

        ShippingProviderSetup.Modify();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRShippingProvider'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePackageDimensions()
    var
        ShippingProviderSetup: Record "NPR Shipping Provider Setup";
        SalesHeader: Record "Sales Header";
        PackageDimension: Record "NPR Package Dimension";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Package Code', 'OnUpgradePerCompany');
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageDimensions')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        if not ShippingProviderSetup.Get() then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageDimensions'));
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        if ShippingProviderSetup."Package Service Codeunit ID" <> Codeunit::"NPR Shipmondo Mgnt." then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageDimensions'));
            LogMessageStopwatch.LogFinish();
            exit;
        end;


        SalesHeader.SetFilter("Shipping Agent Code", '<>%1', '');
        SalesHeader.SetFilter("Shipping Agent Service Code", '<>%1', '');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                PackageDimension.Reset();
                PackageDimension.SetRange("Document Type", PackageDimension."Document Type"::Order);
                PackageDimension.SetRange("Document No.", SalesHeader."No.");
                if PackageDimension.IsEmpty() then begin
                    PackageDimension.Init();
                    PackageDimension."Document Type" := PackageDimension."Document Type"::Order;
                    PackageDimension."Document No." := SalesHeader."No.";
                    PackageDimension."Line No." := 10000;
                    PackageDimension.Quantity := SalesHeader."NPR Kolli";
                    PackageDimension.Insert();
                end;
            until SalesHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageDimensions'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePackageServices()
    var
        ServicesCombination: Record "NPR Services Combination";
        ShippingProviderservices: Record "NPR Shipping Provider Services";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upgrade Package Code', 'OnUpgradePerCompany');
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageServices')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        if ServicesCombination.FindSet() then
            repeat
                if not ShippingProviderservices.Get(ServicesCombination."Shipping Agent", ServicesCombination."Shipping Service", ServicesCombination."Service Code") then begin
                    ShippingProviderservices.TransferFields(ServicesCombination);
                    ShippingProviderservices.Insert();
                end;
            until ServicesCombination.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade Shipping Provider", 'NPRPackageServices'));
        LogMessageStopwatch.LogFinish();
    end;


}