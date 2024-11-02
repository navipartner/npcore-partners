#if not BC17
codeunit 6184802 "NPR Spfy App Upgrade"
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
        UpdateShopifySetup();
        SetDataProcessingHandlerID();
        PhaseOutShopifyCCIntegration();
        StoreSpecificIntegrationSetups();
        UpdateShopifyPaymentModule();
        UpdateShopifyStoreDoNotSyncSalesPrices();
    end;

    internal procedure UpdateShopifySetup()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifySetup2: Record "NPR Spfy Integration Setup";
    begin
        if not ShopifySetup.Get() then
            exit;
        ShopifySetup2.Init();
        if ShopifySetup2."Shopify Api Version" = '' then
            exit;
        if ShopifySetup."Shopify Api Version" >= ShopifySetup2."Shopify Api Version" then
            exit;
        ShopifySetup."Shopify Api Version" := ShopifySetup2."Shopify Api Version";
        ShopifySetup.Modify();
    end;

    internal procedure SetDataProcessingHandlerID()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        UpgradeStep := 'SetDataProcessingHandlerID';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        if ShopifySetup.Get() then
            if ShopifySetup."Data Processing Handler ID" = '' then begin
                ShopifySetup.SetDataProcessingHandlerIDToDefaultValue();
                ShopifySetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure PhaseOutShopifyCCIntegration()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        WebServiceAggregate: Record "Web Service Aggregate";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        UpgradeStep := 'PhaseOutShopifyCCIntegration';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        if ShopifySetup.Get() then begin
            ShopifySetup."C&C Order Integration" := false;
            ShopifySetup.Modify();
        end;

        if RetenPolAllowedTables.IsAllowedTable(Database::"NPR Spfy C&C Order") then
            RetenPolAllowedTables.RemoveAllowedTable(Database::"NPR Spfy C&C Order");

        WebServiceManagement.LoadRecords(WebServiceAggregate);
        if WebServiceAggregate.Get(WebServiceAggregate."Object Type"::Page, 6184559) then  //Page::"NPR API Spfy C&C Order WS"
#if BC18 or BC19
            DeleteWebService(WebServiceAggregate);

#else
            WebServiceManagement.DeleteWebService(WebServiceAggregate);
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

#if BC18 or BC19
    procedure DeleteWebService(var WebServiceAggregate: Record "Web Service Aggregate")
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        if TenantWebService.Get(WebServiceAggregate."Object Type", WebServiceAggregate."Service Name") then
            TenantWebService.Delete();
    end;
#endif

    internal procedure StoreSpecificIntegrationSetups()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        UpgradeStep := 'StoreSpecificIntegrationSetups';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        if ShopifySetup.Get() then
            if ShopifyStore.FindSet(true) then
                repeat
                    ShopifyStore."Item List Integration" := ShopifySetup."Item List Integration";
                    ShopifyStore."Do Not Sync. Sales Prices" := ShopifySetup."Do Not Sync. Sales Prices";
                    ShopifyStore."Set Shopify Name/Descr. in BC" := ShopifySetup."Set Shopify Name/Descr. in BC";
                    ShopifyStore."Send Inventory Updates" := ShopifySetup."Send Inventory Updates";
                    ShopifyStore."Include Transfer Orders" := ShopifySetup."Include Transfer Orders";
                    ShopifyStore."Sales Order Integration" := ShopifySetup."Sales Order Integration";
                    ShopifyStore."Post on Completion" := ShopifySetup."Post on Completion";
                    ShopifyStore."Delete on Cancellation" := ShopifySetup."Delete on Cancellation";
                    ShopifyStore."Get Payment Lines from Shopify" := ShopifySetup."Get Payment Lines From Shopify";
                    ShopifyStore."Send Order Fulfillments" := ShopifySetup."Send Order Fulfillments";
                    ShopifyStore."Send Payment Capture Requests" := ShopifySetup."Send Payment Capture Requests";
                    ShopifyStore."Send Close Order Requets" := ShopifySetup."Send Close Order Requets";
                    ShopifyStore."Allowed Payment Statuses" := ShopifySetup."Allowed Payment Statuses";
                    ShopifyStore."Retail Voucher Integration" := ShopifySetup."Retail Voucher Integration";
                    ShopifyStore."Send Negative Inventory" := ShopifySetup."Send Negative Inventory";
                    ShopifyStore.Modify();
                until ShopifyStore.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure UpdateShopifyPaymentModule()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        PaymentModuleShopify: Codeunit "NPR NpRv Module Pay. - Shopify";
    begin
        UpgradeStep := 'UpdateShopifyPaymentModule';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        VoucherType.SetRange("Integrate with Shopify", true);
        if VoucherType.FindSet(true) then begin
            PaymentModuleShopify.CreateShopifyRetailVoucherModule();
            repeat
                VoucherType.Validate("Apply Payment Module", PaymentModuleShopify.ModuleCode());
                VoucherType.Modify();
            until VoucherType.Next() = 0;
        end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    internal procedure UpdateShopifyStoreDoNotSyncSalesPrices()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        UpgradeStep := 'UpdateShopifyStoreDoNotSyncSalesPrices';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', UpgradeStep);

        if ShopifyStore.FindSet() then
            repeat
                if not ShopifyStore."Do Not Sync. Sales Prices" then
                    ShopifyStore.Validate("Do Not Sync. Sales Prices");
            until ShopifyStore.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif