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
        _PreReleaseRefundPrefixTok: Label 'Refund/', Locked = true;

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
        ConvertEcomJQsToMonitoredNonProtected();
#endif
        UpdateGetPaymentLineOption();
        DisableSendCloseOrderRequest();
        SetPostReturnsAutomatically();
        CopyLegacyReturnSettlement();
        SetRefundsStartingFrom();
        MoveLegacyReturnQueue();
        RestampPreReleaseRefundDocs();
    end;

    internal procedure UpdateShopifySetup()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifySetup2: Record "NPR Spfy Integration Setup";
        DroppedBaseline: Text[10];
        NewApiVersion: Text[10];
    begin
        if not ShopifySetup.Get() then
            exit;
        ShopifySetup2.Init();
        if ShopifySetup2."Shopify Api Version" = '' then
            exit;

        //An admin deliberately confirmed an api version other than the recommended one. Honour that choice until we ship a
        //new recommended version, at which point the override is dropped. A blank baseline cannot match here, as we have
        //already exited when the recommended version is blank.
        if ShopifySetup."Api Version Override Baseline" = ShopifySetup2."Shopify Api Version" then
            exit;

        //Never move a tenant backwards. A baseline that no longer matches the recommended version is stale either way, so
        //it is dropped; the stored version is raised to the recommended one only when it is lower, which leaves a version
        //deliberately pinned above the recommended one as it is.
        NewApiVersion := ShopifySetup."Shopify Api Version";
        if NewApiVersion < ShopifySetup2."Shopify Api Version" then
            NewApiVersion := ShopifySetup2."Shopify Api Version";
        DroppedBaseline := ShopifySetup."Api Version Override Baseline";
        if (NewApiVersion = ShopifySetup."Shopify Api Version") and (DroppedBaseline = '') then
            exit;

        //Unlike the other steps this one has no upgrade tag, as it must re-evaluate the api version on every deployment.
        //It is logged only when it actually changes something, so support can tell what a deployment did to a tenant that
        //was running a pinned version.
        _UpgradeStep :=
            StrSubstNo(
                'UpdateShopifySetup (api version ''%1'' -> ''%2'', dropped override baseline ''%3'')',
                ShopifySetup."Shopify Api Version", NewApiVersion, DroppedBaseline);
        LogStart();

        ShopifySetup."Shopify Api Version" := NewApiVersion;
        ShopifySetup."Api Version Override Baseline" := '';
        ShopifySetup.Modify();

        LogFinish();
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

    local procedure ConvertEcomJQsToMonitoredNonProtected()
    begin
        _UpgradeStep := 'ConvertEcomJQsToMonitoredNonProtected';
        if HasUpgradeTag() then
            exit;

        LogStart();

        ConvertEcomJQs();

        SetUpgradeTag();
        LogFinish();
    end;

    internal procedure ConvertEcomJQs()
    var
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        if not ShopifyEcommOrderExp.IsFeatureEnabled() then
            exit;

        ConvertOneEcomJQ(Codeunit::"NPR Spfy Order Import JQ");
        ConvertOneEcomJQ(Codeunit::"NPR Spfy Event Doc ProcessorJQ");
    end;

    local procedure ConvertOneEcomJQ(JQCodeunitId: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", JQCodeunitId);
        MonitoredJQEntry.SetRange("NP Protected Job", true);
        if MonitoredJQEntry.FindSet(true) then
            repeat
                if not JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then begin
                    MonitoredJQEntry."NP Protected Job" := false;
                    MonitoredJQEntry.Modify();
                end;
            until MonitoredJQEntry.Next() = 0;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JQCodeunitId);
        JobQueueEntry.SetRange("Recurring Job", true);
        if not JobQueueEntry.FindSet() then
            exit;
        repeat
            if JobQueueEntry."NPR NP Protected Job" then begin
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                JobQueueEntry."NPR NP Protected Job" := false;
                JobQueueEntry.Modify();
                if not JobQueueEntry."NPR Manually Set On Hold" then
                    JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
            end;
            MonitoredJobQueueMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
        until JobQueueEntry.Next() = 0;
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

    local procedure DisableSendCloseOrderRequest()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        _UpgradeStep := 'DisableSendCloseOrderRequest';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if ShopifyStore.FindSet() then
            repeat
                if ShopifyStore."Send Close Order Requets" then begin
                    ShopifyStore."Send Close Order Requets" := false;
                    ShopifyStore.Modify();
                end;
            until ShopifyStore.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure SetPostReturnsAutomatically()
    begin
        _UpgradeStep := 'SetPostReturnsAutomatically';
        if HasUpgradeTag() then
            exit;
        LogStart();

        SwitchPostReturnsAutomaticallyOn();

        SetUpgradeTag();
        LogFinish();
    end;

    /// <summary>
    /// Stores that existed before "Post Returns Automatically" get the value a new store starts with.
    /// </summary>
    internal procedure SwitchPostReturnsAutomaticallyOn()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if ShopifyStore.FindSet(true) then
            repeat
                ShopifyStore."Post Returns Automatically" := true;
                ShopifyStore.Modify();
            until ShopifyStore.Next() = 0;
    end;

    local procedure CopyLegacyReturnSettlement()
    begin
        _UpgradeStep := 'CopyLegacyReturnSettlement';
        if HasUpgradeTag() then
            exit;
        LogStart();

        CopyLegacyReturnQueueToSettlement();

        SetUpgradeTag();
        LogFinish();
    end;

    /// <summary>
    /// Drafts built before the settlement table existed still settle: their queue rows' settlement values are copied.
    /// </summary>
    internal procedure CopyLegacyReturnQueueToSettlement()
    var
#pragma warning disable AL0432
        QueueRow: Record "NPR Spfy Legacy Return Queue";
#pragma warning restore AL0432
        Settlement: Record "NPR Spfy Refund Settlement";
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
    begin
        QueueRow.SetFilter("Sales Header Doc. No.", '<>%1', '');
        if QueueRow.FindSet() then
            repeat
                if not HasSettlement(QueueRow) then begin
                    Settlement.Init();
                    Settlement."Shopify Store Code" := QueueRow."Shopify Store Code";
                    Settlement."Source Doc. Type" := QueueRow."Source Type";
                    Settlement."Shopify Id" := PlainSourceDocId(QueueRow);
                    Settlement."Display Name" := SpfyLegacyReturnAPI.DocumentCaption(QueueRow."Source Type", QueueRow."Return Name", PlainSourceDocId(QueueRow));
                    Settlement."Order Id" := QueueRow."Order Id";
                    Settlement."Return Order No." := QueueRow."Sales Header Doc. No.";
#pragma warning disable AL0432
                    Settlement."Gift Card Refund Amount" := QueueRow."Gift Card Refund Amount";
                    Settlement."Voucher No." := QueueRow."Voucher No.";
#pragma warning restore AL0432
                    Settlement.Insert();
                end;
            until QueueRow.Next() = 0;
    end;

    local procedure MoveLegacyReturnQueue()
    begin
        _UpgradeStep := 'MoveLegacyReturnQueue';
        if HasUpgradeTag() then
            exit;
        LogStart();

        MoveLegacyReturnQueueRows();

        SetUpgradeTag();
        LogFinish();
    end;

    /// <summary>
    /// Copies the rows of the obsolete queue, keyed by store and id, to the queue keyed by entry number, where a return and a refund may share an id.
    /// </summary>
    internal procedure MoveLegacyReturnQueueRows()
    var
#pragma warning disable AL0432
        OldQueueRow: Record "NPR Spfy Legacy Return Queue";
#pragma warning restore AL0432
        QueueRow: Record "NPR Spfy NC Return Queue";
    begin
        if OldQueueRow.FindSet() then
            repeat
                if not QueueRow.FindSourceDoc(OldQueueRow."Shopify Store Code", OldQueueRow."Source Type", PlainSourceDocId(OldQueueRow)) then begin
                    QueueRow.Init();
                    QueueRow."Entry No." := 0;
                    QueueRow."Shopify Store Code" := OldQueueRow."Shopify Store Code";
                    QueueRow."Source Doc. Type" := OldQueueRow."Source Type";
                    QueueRow."Source Doc. ID" := PlainSourceDocId(OldQueueRow);
                    QueueRow."Source Doc. Name" := OldQueueRow."Return Name";
                    QueueRow."Order Id" := OldQueueRow."Order Id";
                    QueueRow."Order No." := OldQueueRow."Order No.";
                    QueueRow.Status := OldQueueRow.Status;
                    QueueRow."Detected At" := OldQueueRow."Detected At";
                    QueueRow."Processed At" := OldQueueRow."Processed At";
                    QueueRow."Retry Count" := OldQueueRow."Retry Count";
                    QueueRow."Last Error" := OldQueueRow."Last Error";
                    QueueRow."Sales Header Doc. No." := OldQueueRow."Sales Header Doc. No.";
                    QueueRow."Posted Doc. No." := OldQueueRow."Posted Doc. No.";
                    QueueRow."Location Fallback Used" := OldQueueRow."Location Fallback Used";
                    QueueRow."Not Restocked" := OldQueueRow."Not Restocked";
                    QueueRow."Outcome Note" := OldQueueRow."Outcome Note";
                    QueueRow.Insert(false);
                end;
            until OldQueueRow.Next() = 0;
    end;

    /// <summary>
    /// A row already settles under its plain id, or, for a pre-release refund, still under the prefixed id it was written with; the restamp rekeys that one, so a copy here would shadow it.
    /// </summary>
#pragma warning disable AL0432
    local procedure HasSettlement(OldQueueRow: Record "NPR Spfy Legacy Return Queue"): Boolean
#pragma warning restore AL0432
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        if Settlement.Get(OldQueueRow."Shopify Store Code", OldQueueRow."Source Type", PlainSourceDocId(OldQueueRow)) then
            exit(true);
        exit(Settlement.Get(OldQueueRow."Shopify Store Code", Settlement."Source Doc. Type"::Return, OldQueueRow."Return Id"));
    end;

    /// <summary>
    /// The plain Shopify id of an obsolete queue row. Refund rows of a pre-release build were keyed by "Refund/" and the id; released rows are returns with the plain id.
    /// </summary>
#pragma warning disable AL0432
    local procedure PlainSourceDocId(OldQueueRow: Record "NPR Spfy Legacy Return Queue"): Text[30]
#pragma warning restore AL0432
    begin
        if (OldQueueRow."Source Type" = OldQueueRow."Source Type"::Refund) and OldQueueRow."Return Id".StartsWith(_PreReleaseRefundPrefixTok) then
            exit(WithoutPrefix(OldQueueRow."Return Id", _PreReleaseRefundPrefixTok));
        exit(OldQueueRow."Return Id");
    end;

    local procedure RestampPreReleaseRefundDocs()
    begin
        _UpgradeStep := 'RestampPreReleaseRefundDocs';
        if HasUpgradeTag() then
            exit;
        LogStart();

        RestampPreReleaseRefundIds();

        SetUpgradeTag();
        LogFinish();
    end;

    /// <summary>
    /// Pre-release builds stamped a refund's documents with "Refund/" and the refund id, and post-sale discount lines with "Discount/" and the line item id, both as Entry ID; this gives them the types and plain ids the engine reads.
    /// </summary>
    internal procedure RestampPreReleaseRefundIds()
    var
        PreReleaseDiscountPrefixTok: Label 'Discount/', Locked = true;
    begin
        RestampPreReleaseIds(StrSubstNo('%1|%2|%3', Database::"Sales Header", Database::"Sales Cr.Memo Header", Database::"Return Receipt Header"), _PreReleaseRefundPrefixTok, "NPR Spfy ID Type"::"Refund ID");
        RestampPreReleaseIds(StrSubstNo('%1|%2|%3', Database::"Sales Line", Database::"Sales Cr.Memo Line", Database::"Return Receipt Line"), PreReleaseDiscountPrefixTok, "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID");
        RekeyPreReleaseRefundSettlements();
    end;

    local procedure RestampPreReleaseIds(TableNoFilter: Text; Prefix: Text; NewIdType: Enum "NPR Spfy ID Type")
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        TempShopifyAssignedID: Record "NPR Spfy Assigned ID" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyAssignedID.SetFilter("Table No.", TableNoFilter);
        ShopifyAssignedID.SetRange("Shopify ID Type", "NPR Spfy ID Type"::"Entry ID");
        ShopifyAssignedID.SetFilter("Shopify ID", Prefix + '*');
        if not ShopifyAssignedID.FindSet() then
            exit;
        repeat
            TempShopifyAssignedID := ShopifyAssignedID;
            TempShopifyAssignedID.Insert();
        until ShopifyAssignedID.Next() = 0;

        TempShopifyAssignedID.FindSet();
        repeat
            if SpfyAssignedIDMgt.GetAssignedShopifyID(TempShopifyAssignedID."BC Record ID", NewIdType) = '' then
                SpfyAssignedIDMgt.AssignShopifyID(TempShopifyAssignedID."BC Record ID", NewIdType, WithoutPrefix(TempShopifyAssignedID."Shopify ID", Prefix), false);
            ShopifyAssignedID.Get(TempShopifyAssignedID."Entry No.");
            ShopifyAssignedID.Delete();
        until TempShopifyAssignedID.Next() = 0;
    end;

    local procedure RekeyPreReleaseRefundSettlements()
    var
        Settlement: Record "NPR Spfy Refund Settlement";
        TempSettlement: Record "NPR Spfy Refund Settlement" temporary;
        ExistingSettlement: Record "NPR Spfy Refund Settlement";
        PlainId: Text[30];
    begin
        Settlement.SetRange("Source Doc. Type", Settlement."Source Doc. Type"::Return);
        Settlement.SetFilter("Shopify Id", _PreReleaseRefundPrefixTok + '*');
        if not Settlement.FindSet() then
            exit;
        repeat
            TempSettlement := Settlement;
            TempSettlement.Insert();
        until Settlement.Next() = 0;

        TempSettlement.FindSet();
        repeat
            Settlement.Get(TempSettlement."Shopify Store Code", TempSettlement."Source Doc. Type", TempSettlement."Shopify Id");
            PlainId := WithoutPrefix(TempSettlement."Shopify Id", _PreReleaseRefundPrefixTok);
            if ExistingSettlement.Get(TempSettlement."Shopify Store Code", ExistingSettlement."Source Doc. Type"::Refund, PlainId) then
                Settlement.Delete()
            else
                Settlement.Rename(TempSettlement."Shopify Store Code", Settlement."Source Doc. Type"::Refund, PlainId);
        until TempSettlement.Next() = 0;
    end;

    local procedure WithoutPrefix(ShopifyId: Text; Prefix: Text): Text[30]
    begin
        exit(CopyStr(ShopifyId.Substring(StrLen(Prefix) + 1), 1, 30));
    end;

    local procedure SetRefundsStartingFrom()
    begin
        _UpgradeStep := 'SetRefundsStartingFrom';
        if HasUpgradeTag() then
            exit;
        LogStart();

        StampRefundsStartingFrom(CurrentDateTime());

        SetUpgradeTag();
        LogFinish();
    end;

    /// <summary>
    /// Refunds made without a return before the upgrade were credited by hand, so existing stores import refunds from the upgrade on.
    /// </summary>
    internal procedure StampRefundsStartingFrom(StartingFrom: DateTime)
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.SetRange("Get Refunds Starting From", 0DT);
        if ShopifyStore.FindSet(true) then
            repeat
                ShopifyStore."Get Refunds Starting From" := StartingFrom;
                ShopifyStore.Modify();
            until ShopifyStore.Next() = 0;
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