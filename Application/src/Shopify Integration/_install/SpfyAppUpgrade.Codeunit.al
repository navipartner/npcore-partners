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
        SetDefaultProductStatus();
        RemoveOrphanShopifyAssignedIDs();
        UpdateGetPaymentLinesFromShopifyOption();
        MoveMetafieldValueToBlobField();
        UpdateMetafieldTaskSetup();
        CreateSOIntegrationRelatedDataLogSetups();
        MoveCustomerAssignedIDs();
        MoveLastOrdersImportedAt();
        UpdateShopifyInventoryLocations();
        RemoveEmptyShopifyStoreItemLinks();
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        PrepareForEcomFlow();
#endif
        UpdateGetPaymentLineOption();
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

    local procedure SetDataProcessingHandlerID()
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

    local procedure PhaseOutShopifyCCIntegration()
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

    local procedure StoreSpecificIntegrationSetups()
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

    local procedure UpgradeAllowedFinancialStatuses()
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

    local procedure UpdateShopifyPaymentModule()
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

    local procedure UpdateShopifyStoreDoNotSyncSalesPrices()
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

    local procedure EnableItemRelatedDataLogSubscribers()
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

    local procedure RescheduleInventorySyncTasks()
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

    local procedure UpdateMetafieldDataLogSetup()
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

    local procedure SetDefaultProductStatus()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'SetDefaultProductStatus';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet(true) then
            repeat
                if not (ShopifyStore."New Product Status" in [ShopifyStore."New Product Status"::DRAFT, ShopifyStore."New Product Status"::ACTIVE]) then begin
                    ShopifyStore."New Product Status" := ShopifyStore."New Product Status"::DRAFT;
                    ShopifyStore.Modify();
                end;
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure RemoveOrphanShopifyAssignedIDs()
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        RecRef: RecordRef;
    begin
        _UpgradeStep := 'RemoveOrphanShopifyAssignedIDs';
        if HasUpgradeTag() then
            exit;
        LogStart();

        ShopifyAssignedID.SetRange("Table No.", Database::"NPR Spfy Store");
        if ShopifyAssignedID.FindSet() then
            repeat
                if not RecRef.Get(ShopifyAssignedID."BC Record ID") then
                    ShopifyAssignedID.Delete();
            until ShopifyAssignedID.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure UpdateGetPaymentLinesFromShopifyOption()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'UpdateGetPaymentLinesFromShopifyOption';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet(true) then
            repeat
                if not ShopifyStore."Send Payment Capture Requests" and (ShopifyStore."Get Payment Lines from Shopify" = ShopifyStore."Get Payment Lines from Shopify"::ON_CAPTURE) then begin
                    ShopifyStore."Get Payment Lines from Shopify" := ShopifyStore."Get Payment Lines from Shopify"::ON_ORDER_IMPORT;
                    ShopifyStore.Modify();
                end;
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure MoveMetafieldValueToBlobField()
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        _UpgradeStep := 'MoveMetafieldValueToBlobField';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if not SpfyEntityMetafield.IsEmpty() then begin
            DataLogMgt.DisableDataLog(true);
            if SpfyEntityMetafield.FindSet(true) then
                repeat
                    SpfyEntityMetafield.SetMetafieldValue(SpfyEntityMetafield."Metafield Value");
                    SpfyEntityMetafield."Metafield Value" := '';
                    SpfyEntityMetafield.Modify();
                until SpfyEntityMetafield.Next() = 0;
            DataLogMgt.DisableDataLog(false);
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure UpdateMetafieldTaskSetup()
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        ShopifyTaskProcessorCode: Code[20];
    begin
        _UpgradeStep := 'UpdateMetafieldTaskSetup';
        if HasUpgradeTag() then
            exit;
        LogStart();

        ShopifyTaskProcessorCode := SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(false);
        if ShopifyTaskProcessorCode <> '' then begin
            NcTaskSetup.SetCurrentKey("Task Processor Code", "Table No.");
            NcTaskSetup.SetRange("Table No.", Database::"NPR Spfy Entity Metafield");
            NcTaskSetup.SetRange("Task Processor Code", ShopifyTaskProcessorCode);
            if NcTaskSetup.FindFirst() then
                if NcTaskSetup."Codeunit ID" = Codeunit::"NPR Spfy Send Items&Inventory" then begin
                    NcTaskSetup."Codeunit ID" := Codeunit::"NPR Spfy Send Metafields";
                    NcTaskSetup.Modify();
                end;
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure CreateSOIntegrationRelatedDataLogSetups()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyDataLogSubscrMgt: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
    begin
        _UpgradeStep := 'CreateSOIntegrationRelatedDataLogSetups';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                if ShopifyStore."Sales Order Integration" then
                    SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Sales Orders");
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure MoveCustomerAssignedIDs()
    var
        Customer: Record Customer;
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
    begin
        _UpgradeStep := 'MoveCustomerAssignedIDs';
        if HasUpgradeTag() then
            exit;
        LogStart();

        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.Count() = 1 then begin
            ShopifyStore.FindFirst();

            SpfyAssignedID.SetCurrentKey("Table No.", "Shopify ID Type", "Shopify ID");
            SpfyAssignedID.SetRange("Table No.", Database::Customer);
            SpfyAssignedID.SetRange("Shopify ID Type", "NPR Spfy ID Type"::"Entry ID");
            if SpfyAssignedID.FindSet(true) then
                repeat
                    if Customer.Get(SpfyAssignedID."BC Record ID") then begin
                        SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
                        SpfyStoreCustomerLink."No." := Customer."No.";
                        SpfyStoreCustomerLink."Shopify Store Code" := ShopifyStore.Code;
                        if SpfyStoreCustomerLink.Find() then
                            SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreCustomerLink.RecordId(), SpfyAssignedID."Shopify ID Type", SpfyAssignedID."Shopify ID", false);
                    end;
                    SpfyAssignedID.Delete();
                until SpfyAssignedID.Next() = 0;
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure MoveLastOrdersImportedAt()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'MoveLastOrdersImportedAt';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                if ShopifyStore."Last Orders Imported At" <> 0DT then begin
                    ShopifyStore.SetLastOrdersImportedAt(ShopifyStore."Last Orders Imported At");
                    ShopifyStore."Last Orders Imported At" := 0DT;
                    ShopifyStore.Modify();
                end;
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure UpdateShopifyInventoryLocations()
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        InvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
    begin
        _UpgradeStep := 'UpdateShopifyInventoryLocations';

        if HasUpgradeTag() then
            exit;
        if not InventoryLevel.FindSet() then
            exit;
        LogStart();

        if InventoryLevel.FindSet() then
            repeat
                if not InvLocationAct.IsLocationActivated(LocationInvItem, InventoryLevel) then begin
                    LocationInvItem.Activated := true;
                    LocationInvItem.Modify();
                end;
            until InventoryLevel.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure RemoveEmptyShopifyStoreItemLinks()
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        _UpgradeStep := 'RemoveEmptyShopifyStoreItemLinks';

        if HasUpgradeTag() then
            exit;
        if SpfyStoreItemLink.IsEmpty() then
            exit;
        LogStart();

        SpfyStoreItemLink.SetRange("Item No.", '');
        if not SpfyStoreItemLink.IsEmpty() then
            SpfyStoreItemLink.DeleteAll();

        SetUpgradeTag();
        LogFinish();
    end;
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    local procedure PrepareForEcomFlow()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        _UpgradeStep := 'PrepareForEcomFlow';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifySetup.Get() then
            if ShopifySetup."Max Doc Process Retry Count" = 0 then begin
                ShopifySetup."Max Doc Process Retry Count" := 2;
                ShopifySetup.Modify();
            end;
        if SpfyEventLogEntry.FindSet() then
            repeat
                SpfyEventLogEntry."Document Type" := SpfyEventLogEntry."Document Type"::Order;
                SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Processed;
                SpfyEventLogEntry.Modify();
            until SpfyEventLogEntry.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;
#endif
    local procedure UpdateGetPaymentLineOption()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'UpdateGetPaymentLineOption';
        if HasUpgradeTag() then
            exit;
        LogStart();
        if ShopifyStore.FindSet() then
            repeat
                if ShopifyStore."Get Payment Lines from Shopify" = ShopifyStore."Get Payment Lines from Shopify"::ON_ORDER_IMPORT then begin
                    ShopifyStore."Get Payment Lines from Shopify" := ShopifyStore."Get Payment Lines from Shopify"::ON_IMPORT_AND_CAPTURE;
                    ShopifyStore.Modify();
                end;
            until ShopifyStore.Next() = 0;

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