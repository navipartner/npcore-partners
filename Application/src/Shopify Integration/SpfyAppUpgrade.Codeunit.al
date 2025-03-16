#if not BC17
codeunit 6184802 "NPR Spfy App Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        _UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        UpdateShopifySetup();
        SetDataProcessingHandlerID();
        PhaseOutShopifyCCIntegration();
        StoreSpecificIntegrationSetups();
        UpdateShopifyPaymentModule();
        UpdateShopifyStoreDoNotSyncSalesPrices();
        EnableItemRelatedDataLogSubscribers();
        RemoveIncorrectlyAssignedIDs();
        RegisterShopifyAppRequestListenerWebservice();
        UpgradeAllowedFinancialStatuses();
        RescheduleInventorySyncTasks();
        UpdateMetafieldDataLogSetup();
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

    internal procedure RegisterShopifyAppRequestListenerWebservice()
    var
        SpfyAppRequestWS: Codeunit "NPR Spfy App Request WS";
    begin
        _UpgradeStep := 'RegisterShopifyAppRequestListenerWebservice';
        if HasUpgradeTag() then
            exit;
        LogStart();

        SpfyAppRequestWS.RegisterShopifyAppRequestListenerWebservice();

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure SetDataProcessingHandlerID()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        _UpgradeStep := 'SetDataProcessingHandlerID';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifySetup.Get() then
            if ShopifySetup."Data Processing Handler ID" = '' then begin
                ShopifySetup.SetDataProcessingHandlerIDToDefaultValue();
                ShopifySetup.Modify();
            end;

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure PhaseOutShopifyCCIntegration()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        WebServiceAggregate: Record "Web Service Aggregate";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        _UpgradeStep := 'PhaseOutShopifyCCIntegration';
        if HasUpgradeTag() then
            exit;
        LogStart();

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
        SetUpgradeTag();
        LogFinish();
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
        _UpgradeStep := 'StoreSpecificIntegrationSetups';
        if HasUpgradeTag() then
            exit;
        LogStart();

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

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure UpgradeAllowedFinancialStatuses()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'UpgradeAllowedFinancialStatuses';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                case ShopifyStore."Allowed Payment Statuses" of
                    ShopifyStore."Allowed Payment Statuses"::Authorized:
                        ShopifyStore.AddAllowedOrderFinancialStatus(Enum::"NPR Spfy Order FinancialStatus"::Authorized);
                    ShopifyStore."Allowed Payment Statuses"::Paid:
                        ShopifyStore.AddAllowedOrderFinancialStatus(Enum::"NPR Spfy Order FinancialStatus"::Paid);
                    ShopifyStore."Allowed Payment Statuses"::Both:
                        begin
                            ShopifyStore.AddAllowedOrderFinancialStatus(Enum::"NPR Spfy Order FinancialStatus"::Authorized);
                            ShopifyStore.AddAllowedOrderFinancialStatus(Enum::"NPR Spfy Order FinancialStatus"::Paid);
                        end;
                end;
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure UpdateShopifyPaymentModule()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        PaymentModuleShopify: Codeunit "NPR NpRv Module Pay. - Shopify";
    begin
        _UpgradeStep := 'UpdateShopifyPaymentModule';
        if HasUpgradeTag() then
            exit;
        LogStart();

        VoucherType.SetRange("Integrate with Shopify", true);
        if VoucherType.FindSet(true) then begin
            PaymentModuleShopify.CreateShopifyRetailVoucherModule();
            repeat
                VoucherType.Validate("Apply Payment Module", PaymentModuleShopify.ModuleCode());
                VoucherType.Modify();
            until VoucherType.Next() = 0;
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure UpdateShopifyStoreDoNotSyncSalesPrices()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'UpdateShopifyStoreDoNotSyncSalesPrices';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                if not ShopifyStore."Do Not Sync. Sales Prices" then
                    ShopifyStore.Validate("Do Not Sync. Sales Prices");
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure EnableItemRelatedDataLogSubscribers()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'EnableItemRelatedDataLogSubscribers';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                ShopifyStore.Validate("Item List Integration");
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure RemoveIncorrectlyAssignedIDs()
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        _UpgradeStep := 'RemoveIncorrectlyAssignedIDs';
        if HasUpgradeTag() then
            exit;
        LogStart();

        ShopifyAssignedID.SetRange("Table No.", Database::"Item Variant");
        if not ShopifyAssignedID.IsEmpty() then
            ShopifyAssignedID.DeleteAll();

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure RescheduleInventorySyncTasks()
    var
        NcTask: Record "NPR Nc Task";
        NcTask2: Record "NPR Nc Task";
        NcTask3: Record "NPR Nc Task";
    begin
        _UpgradeStep := 'RescheduleInventorySync';
        if HasUpgradeTag() then
            exit;
        LogStart();

        NcTask.SetRange("Table No.", Database::"NPR Spfy Inventory Level");
        NcTask.SetRange(Processed, true);
        NcTask.SetFilter("Log Date", '%1..', CreateDateTime(20250217D, 0T));
        NcTask.Ascending(false);
        if NcTask.FindSet(true) then
            repeat
                NcTask2.SetRange("Table No.", NcTask."Table No.");
                NcTask2.SetRange(Processed, false);
                NcTask2.SetRange("Record Value", NcTask."Record Value");
                NcTask2.SetRange("Store Code", NcTask."Store Code");
                if NcTask2.IsEmpty() then begin
                    NcTask3 := NcTask;
                    NcTask3.Processed := false;
                    NcTask3."Process Count" := 0;
                    NcTask3.Modify();
                end;
            until NcTask.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure UpdateMetafieldDataLogSetup()
    var
        DataLogSetupTable: Record "NPR Data Log Setup (Table)";
    begin
        _UpgradeStep := 'UpdateMetafieldDataLogSetup';
        if HasUpgradeTag() then
            exit;
        LogStart();

        DataLogSetupTable.SetRange("Table ID", Database::"NPR Spfy Entity Metafield");
        if not DataLogSetupTable.IsEmpty() then
            DataLogSetupTable.ModifyAll("Log Insertion", DataLogSetupTable."Log Insertion"::" ");

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        exit(_UpgradeTag.HasUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", _UpgradeStep)));
    end;

    local procedure SetUpgradeTag()
    begin
        if HasUpgradeTag() then
            exit;
        _UpgradeTag.SetUpgradeTag(_UpgTagDef.GetUpgradeTag(Codeunit::"NPR Spfy App Upgrade", _UpgradeStep));
    end;

    local procedure LogStart()
    begin
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR Spfy App Upgrade', _UpgradeStep);
    end;

    local procedure LogFinish()
    begin
        _LogMessageStopwatch.LogFinish();
    end;
}
#endif