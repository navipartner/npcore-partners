#if not BC17
codeunit 6184814 "NPR Spfy Order Mgt."
{
    Access = Internal;
    Permissions = tabledata "NPR Spfy Store" = rm;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OrderStatus: Option Open,Closed,Cancelled;
        StartedAt: DateTime;
    begin
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Sales Orders", '');

        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.FindSet() then
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", ShopifyStore) then begin
                    GetFromDT(ShopifyStore);
                    StartedAt := RoundDateTime(CurrentDateTime(), 1000, '<');

                    DownloadOrders(ShopifyStore, OrderStatus::Open);
                    if ShopifyStore."Delete on Cancellation" then
                        DownloadOrders(ShopifyStore, OrderStatus::Cancelled);
                    if ShopifyStore."Post on Completion" then
                        DownloadOrders(ShopifyStore, OrderStatus::Closed);

                    ShopifyStore."Last Orders Imported At" := StartedAt;
                    ShopifyStore.Modify();
                    Commit();
                end;
            until ShopifyStore.Next() = 0;
    end;

    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        TooLongValueErr: Label 'Incoming Shopify %1 "%2" exceeds maximum allowed length of %3 characters', Comment = '%1 - incoming field name, %2 - incoming field value, %3 - number of characters';

    local procedure DownloadOrders(ShopifyStore: Record "NPR Spfy Store"; OrderStatus: Option Open,Closed,Cancelled)
    var
        ImportType: Record "NPR Nc Import Type";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Orders: JsonArray;
        Link: Text;
        NextLink: Text;
        OrderStatusesTxt: Label 'open,closed,cancelled', Locked = true, Comment = 'Do not translate!';
        Limit: Integer;
    begin
        Limit := 5;
        case OrderStatus of
            OrderStatus::Open:
                InitImportTypeCreate(ImportType);
            OrderStatus::Closed:
                InitImportTypePost(ImportType);
            OrderStatus::Cancelled:
                InitImportTypeDelete(ImportType);
        end;

        repeat
            if SpfyCommunicationHandler.TryDownloadOrders(ShopifyStore.Code, Link, ShopifyStore."Last Orders Imported At" - 600 * 1000, Limit, SelectStr(OrderStatus + 1, OrderStatusesTxt), Orders, NextLink) then begin
                SaveOrders(ShopifyStore, Orders, OrderStatus, ImportType);
                Link := NextLink;
            end else
                Link := '';
        until Link = '';
    end;

    local procedure GetFromDT(var ShopifyStore: Record "NPR Spfy Store")
    begin
        if ShopifyStore."Last Orders Imported At" <> 0DT then
            exit;
        ShopifyStore."Last Orders Imported At" := GetDefaultFromDT(ShopifyStore);
    end;

    local procedure GetDefaultFromDT(ShopifyStore: Record "NPR Spfy Store"): DateTime
    begin
        if ShopifyStore."Get Orders Starting From" <> 0DT then
            exit(ShopifyStore."Get Orders Starting From");
        exit(CreateDateTime(DMY2Date(1, 1, 2022), 0T));
    end;

    local procedure SaveOrders(ShopifyStore: Record "NPR Spfy Store"; Orders: JsonArray; OrderStatus: Option Open,Closed,Cancelled; ImportType: Record "NPR Nc Import Type")
    var
        Order: JsonToken;
        DocName: Text[100];
        DocDT: DateTime;
    begin
        foreach Order in Orders do begin
            DocName := CopyStr(StrSubstNo('order%1.json', JsonHelper.GetJText(Order, 'order_number', true)), 1, MaxStrLen(DocName));
            case OrderStatus of
                OrderStatus::Open:
                    DocDT := JsonHelper.GetJDT(Order, 'created_at', false);
                OrderStatus::Closed:
                    DocDT := JsonHelper.GetJDT(Order, 'closed_at', false);
                OrderStatus::Cancelled:
                    DocDT := JsonHelper.GetJDT(Order, 'cancelled_at', false);
            end;

            SaveOrder(ShopifyStore, Order, OrderStatus, ImportType, DocName, DocDT);
        end;
    end;

    local procedure SaveOrder(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Option Open,Closed,Cancelled; ImportType: Record "NPR Nc Import Type"; DocName: Text[100]; DocDT: DateTime)
    var
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
    begin
        if not HasReadyState(ShopifyStore, Order, OrderStatus) then
            exit;

        if DocExists(ImportType, DocName) then
            exit;

        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Store Code" := ShopifyStore.Code;
        ImportEntry."Import Type" := ImportType.Code;
        ImportEntry."Document Name" := DocName;
        ImportEntry.Date := DocDT;
        ImportEntry."Document Source".CreateOutStream(OutStr, TextEncoding::UTF8);
        Order.WriteTo(OutStr);
        ImportEntry.Insert(true);
        Commit();
    end;

    local procedure HasReadyState(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Option Open,Closed,Cancelled): Boolean
    begin
        case OrderStatus of
            OrderStatus::Open:
                exit(SpfyIntegrationMgt.IsAllowedFinancialStatus(JsonHelper.GetJText(Order, 'financial_status', false), ShopifyStore.Code));
            OrderStatus::Closed:
                exit(
                    (JsonHelper.GetJDate(Order, 'closed_at', false) >= DT2Date(GetDefaultFromDT(ShopifyStore))) and
                    (JsonHelper.GetJDate(Order, 'cancelled_at', false) = 0D));
            OrderStatus::Cancelled:
                exit(true);
        end;
        exit(false);
    end;

    local procedure InitImportTypeCreate(var ImportType: Record "NPR Nc Import Type")
    var
        ImportTypeDescTxt: Label 'Create Shopify Order', MaxLength = 50;
    begin
        InitImportType(
            ImportType, StrSubstNo('%1_CREATE_ORDER', ShopifyImportListTaskPrefix()), ImportTypeDescTxt,
            "NPR Nc IL Process Handler"::"Spfy Order Create", "NPR Nc IL Lookup Handler"::"Spfy Order Lookup");
    end;

    local procedure InitImportTypeDelete(var ImportType: Record "NPR Nc Import Type")
    var
        ImportTypeDescTxt: Label 'Delete Shopify Order', MaxLength = 50;
    begin
        InitImportType(
            ImportType, StrSubstNo('%1_DELETE_ORDER', ShopifyImportListTaskPrefix()), ImportTypeDescTxt,
            "NPR Nc IL Process Handler"::"Spfy Order Delete", "NPR Nc IL Lookup Handler"::"Spfy Order Lookup");
    end;

    local procedure InitImportTypePost(var ImportType: Record "NPR Nc Import Type")
    var
        ImportTypeDescTxt: Label 'Post Shopify Order', MaxLength = 50;
    begin
        InitImportType(
            ImportType, StrSubstNo('%1_POST_ORDER', ShopifyImportListTaskPrefix()), ImportTypeDescTxt,
            "NPR Nc IL Process Handler"::"Spfy Order Post", "NPR Nc IL Lookup Handler"::"Spfy Order Lookup");
    end;

    local procedure InitImportType(var ImportType: Record "NPR Nc Import Type"; ImportTypeCode: Text; ImportTypeDescription: Text; ProcessHandler: Enum "NPR Nc IL Process Handler"; LookupHandler: Enum "NPR Nc IL Lookup Handler")
    begin
        Clear(ImportType);
        ImportType.SetRange("Import List Process Handler", ProcessHandler);
        if ImportType.FindFirst() then
            exit;

        if ImportType.Get(ImportTypeCode) then
            ImportType.TestField("Import List Process Handler", ProcessHandler);

        ImportType.Init();
        ImportType.Code := CopyStr(ImportTypeCode, 1, MaxStrLen(ImportType.Code));
        ImportType.Description := CopyStr(ImportTypeDescription, 1, MaxStrLen(ImportType.Description));
        ImportType."Import List Process Handler" := ProcessHandler;
        ImportType."Import List Lookup Handler" := LookupHandler;
        ImportType.Insert(true);
        Commit();
    end;

    procedure SetupJobQueues()
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        SetupJobQueues(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders"));
    end;

    local procedure SetupJobQueues(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcImportListProcessing: Codeunit "NPR Nc Import List Processing";
        GetOrdersFromShopifyLbl: Label 'Get Sales Orders from Shopify';
        ParamNameAndValueLbl: Label '%1=%2', Locked = true;
    begin
        if Enable then begin
            //Sales order update job
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId(),
                '', GetOrdersFromShopifyLbl,
                JobQueueMgt.NowWithDelayInSeconds(300), 5,
                '', JobQueueEntry)
            then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);

            //Import list processing job
            Clear(JQParamStrMgt);
            JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcImportListProcessing.ParamImportType(), ShopifyImportListTaskPrefix() + '*'));
            JQParamStrMgt.AddToParamDict(NcImportListProcessing.ParamProcessImport());

            JobQueueMgt.ScheduleNcImportListProcessing(JobQueueEntry, ShopifyImportListTaskPrefix() + '*', '', 5);
        end else
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId()) then
                JobQueueEntry.Cancel();
    end;

    local procedure ShopifyImportListTaskPrefix(): Text
    begin
        exit(CopyStr(SpfyIntegrationMgt.DataProcessingHandlerID(true), 1, 10));
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshJobQueueEntry()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        If ShopifySetup.IsEmpty() then
            exit;
        SetupJobQueues();
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', false, false)]
#endif
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = CurrCodeunitId())
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    local procedure DocExists(ImportType: Record "NPR Nc Import Type"; DocName: Text[100]): Boolean
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        if DocName = '' then
            exit(false);

        ImportEntry.SetRange("Import Type", ImportType.Code);
        ImportEntry.SetRange("Document Name", DocName);
        exit(ImportEntry.FindFirst());
    end;

    procedure LoadOrder(var ImportEntry: Record "NPR Nc Import Entry"; var Order: JsonToken)
    var
        InStr: InStream;
        InvalidDocSourceErr: Label 'Invalid Document Source';
    begin
        if not ImportEntry."Document Source".HasValue() then
            Error(InvalidDocSourceErr);
        ImportEntry.CalcFields("Document Source");

        ImportEntry."Document Source".CreateInStream(InStr, TextEncoding::UTF8);
        if not Order.ReadFrom(InStr) then
            Error(InvalidDocSourceErr);
    end;

    procedure IsAnonymizedCustomerOrder(var ImportEntry: Record "NPR Nc Import Entry"; Order: JsonToken; AnonymizedCustomerMsg: Text): Boolean
    var
        OutStr: OutStream;
    begin
        if JsonHelper.GetJText(Order, 'customer.first_name', false) <> 'Anonymous' then
            exit(false);
        if JsonHelper.GetJText(Order, 'customer.last_name', false) <> 'Customer' then
            exit(false);

        ImportEntry."Error Message" := CopyStr(AnonymizedCustomerMsg, 1, MaxStrLen(ImportEntry."Error Message"));
        ImportEntry."Last Error Message".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(AnonymizedCustomerMsg);
        ImportEntry.Modify(true);
        exit(true);
    end;

    procedure OrderExists(ShopifyStoreCode: Code[20]; Order: JsonToken): Boolean
    var
        SalesHeader: Record "Sales Header";
        TempSalesInvHeader: Record "Sales Invoice Header" temporary;
    begin
        if FindSalesOrder(ShopifyStoreCode, Order, SalesHeader) then
            exit(true);

        exit(FindSalesInvoices(ShopifyStoreCode, Order, TempSalesInvHeader));
    end;

    procedure FindSalesOrder(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        OrderNo: Text[50];
    begin
        SelectLatestVersion();
        Clear(SalesHeader);
        SpfyAssignedIDMgt.FilterWhereUsed("NPR Spfy ID Type"::"Entry ID", GetOrderID(Order), false, ShopifyAssignedID);
        ShopifyAssignedID.SetRange("Table No.", Database::"Sales Header");
        if ShopifyAssignedID.FindFirst() then
            if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                RecRef.SetTable(SalesHeader);
                exit(true);
            end;

        FindNpEcStore(ShopifyStoreCode, Order, NpEcStore);
        OrderNo := GetOrderNo(Order);
        if OrderNo = '' then
            exit(false);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", OrderNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
        if not NpEcDocument.FindFirst() then
            exit(false);

        exit(SalesHeader.Get(SalesHeader."Document Type"::Order, NpEcDocument."Document No."));
    end;

    procedure FindSalesInvoices(ShopifyStoreCode: Code[20]; Order: JsonToken; var TempSalesInvHeader: Record "Sales Invoice Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        SalesInvHeader: Record "Sales Invoice Header";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        OrderNo: Text[50];
    begin
        if not TempSalesInvHeader.IsTemporary() then
            FunctionCallOnNonTempVarErr('FindSalesInvoices()');

        Clear(TempSalesInvHeader);
        TempSalesInvHeader.DeleteAll();

        SpfyAssignedIDMgt.FilterWhereUsed("NPR Spfy ID Type"::"Entry ID", GetOrderID(Order), false, ShopifyAssignedID);
        ShopifyAssignedID.SetRange("Table No.", Database::"Sales Invoice Header");
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SalesInvHeader);
                    TempSalesInvHeader := SalesInvHeader;
                    if TempSalesInvHeader.Insert() then;
                end;
            until ShopifyAssignedID.Next() = 0;
        if not TempSalesInvHeader.IsEmpty() then
            exit(true);

        FindNpEcStore(ShopifyStoreCode, Order, NpEcStore);
        OrderNo := GetOrderNo(Order);
        if OrderNo = '' then
            exit(false);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", OrderNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Sales Invoice");
        if NpEcDocument.IsEmpty() then
            exit(false);

        NpEcDocument.FindSet();
        repeat
            if SalesInvHeader.Get(NpEcDocument."Document No.") and not TempSalesInvHeader.Get(SalesInvHeader."No.") then begin
                TempSalesInvHeader := SalesInvHeader;
                if TempSalesInvHeader.Insert() then;
            end;
        until NpEcDocument.Next() = 0;
        exit(TempSalesInvHeader.FindFirst());
    end;

    procedure FindShipmentMapping(ShippingLine: JsonToken; var ShipmentMapping: Record "NPR Magento Shipment Mapping"): Boolean
    var
        ShipmentMapping2: Record "NPR Magento Shipment Mapping";
        TempShipmentMapping: Record "NPR Magento Shipment Mapping" temporary;
        ShippingLineCodeJToken: JsonToken;
        ShippingLineCode: Text;
        ShippingMethodId: Text[50];
        Found: Boolean;
    begin
        clear(ShipmentMapping);
        ShippingLineCode := DelChr(JsonHelper.GetJText(ShippingLine, 'code', false), '=', '\');
        if ShippingLineCode = '' then
            exit;
        if ShippingLineCodeJToken.ReadFrom(ShippingLineCode) and ShippingLineCodeJToken.IsObject() then
#pragma warning disable AA0139
            ShippingMethodId := JsonHelper.GetJText(ShippingLineCodeJToken, 'shipping_rate_id', MaxStrLen(ShipmentMapping."External Shipment Method Code"), false)
#pragma warning restore AA0139
        else
            ShippingMethodId := CopyStr(ShippingLineCode, 1, MaxStrLen(ShipmentMapping."External Shipment Method Code"));
        if ShippingMethodId = '' then
            exit;

        ShipmentMapping."External Shipment Method Code" := ShippingMethodId;
        Found := ShipmentMapping.Find();
        if not Found and (ShippingMethodId <> '') then
            if ShipmentMapping2.FindSet() then begin
                TempShipmentMapping."External Shipment Method Code" := ShippingMethodId;
                TempShipmentMapping.Insert();
                repeat
                    TempShipmentMapping.SetFilter("External Shipment Method Code", ShipmentMapping2."External Shipment Method Code");
                    Found := TempShipmentMapping.Find();
                    if Found then
                        ShipmentMapping := ShipmentMapping2;
                until (ShipmentMapping2.Next() = 0) or Found;
            end;

        exit(Found);
    end;

    procedure GetPaymentMapping(PayMethodId: Text; ShopifyStoreCode: Code[20]; var PaymentMapping: Record "NPR Magento Payment Mapping")
    var
        ExternalPmtTypeFormatTok: Label '%1_%2', Locked = true;
    begin
        Clear(PaymentMapping);
        PaymentMapping.Get('Shopify', LowerCase(StrSubstNo(ExternalPmtTypeFormatTok, ShopifyStoreCode, PayMethodId)));
    end;

    local procedure FindNpEcStore(ShopifyStoreCode: Code[20]; Order: JsonToken; var NpEcStoreOut: Record "NPR NpEc Store")
    var
        NpEcStore: Record "NPR NpEc Store";
        StoreSourceName: Text;
    begin
        StoreSourceName := JsonHelper.GetJText(Order, 'source_name', true);
        NpEcStore.SetCurrentKey("Shopify Store Code", "Shopify Source Name");
        NpEcStore.SetRange("Shopify Store Code", ShopifyStoreCode);
        NpEcStore.SetRange("Shopify Source Name", CopyStr(StoreSourceName, 1, MaxStrLen(NpEcStore."Shopify Source Name")));
        NpEcStore.FindFirst();
        NpEcStoreOut := NpEcStore;
    end;

    local procedure GetOrderNo(Order: JsonToken) OrderNo: Text[50]
    var
        FullOrderNo: Text;
        OrderNoLbl: Label 'order number';
    begin
        FullOrderNo := JsonHelper.GetJText(Order, 'order_number', true);
        if StrLen(FullOrderNo) > MaxStrLen(OrderNo) then
            Error(TooLongValueErr, OrderNoLbl, FullOrderNo, MaxStrLen(OrderNo));
        OrderNo := CopyStr(FullOrderNo, 1, MaxStrLen(OrderNo));
    end;

    local procedure GetOrderID(Order: JsonToken) OrderId: Text[30]
    var
        FullOrderId: Text;
        OrderIdLbl: Label 'order id';
    begin
        FullOrderId := Format(JsonHelper.GetJBigInteger(Order, 'id', true), 0, 9);
        if StrLen(FullOrderId) > MaxStrLen(OrderId) then
            Error(TooLongValueErr, OrderIdLbl, FullOrderId, MaxStrLen(OrderId));
        OrderId := CopyStr(FullOrderId, 1, MaxStrLen(OrderId));
    end;

    procedure InsertSalesHeader(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        UpdateSalesHeader(ShopifyStoreCode, Order, SalesHeader);
    end;

    procedure UpdateSalesHeader(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header")
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        LocationMapping: Record "NPR Spfy Location Mapping";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ClosedAt: Date;
        OrderNo: Text[50];
        IsShpmtMappingLocation: Boolean;
        IsShpmtMappingShipAgent: Boolean;
    begin
        FindNpEcStore(ShopifyStoreCode, Order, NpEcStore);
        NpEcStore.TestField("Salesperson/Purchaser Code");

        OrderNo := GetOrderNo(Order);

        NpEcDocument.SetCurrentKey("Document Type", "Document No.");
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
        NpEcDocument.SetRange("Document No.", SalesHeader."No.");
        if not NpEcDocument.FindFirst() then begin
            NpEcDocument.Init();
            NpEcDocument."Document Type" := NpEcDocument."Document Type"::"Sales Order";
            NpEcDocument."Document No." := SalesHeader."No.";
            NpEcDocument."Entry No." := 0;
            NpEcDocument.Insert(true);
        end;
        if (NpEcDocument."Store Code" <> NpEcStore.Code) or (NpEcDocument."Reference No." <> OrderNo) then begin
            NpEcDocument."Store Code" := NpEcStore.Code;
            NpEcDocument."Reference No." := OrderNo;
            NpEcDocument.Modify();
        end;

        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", GetOrderID(Order), false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", ShopifyStoreCode, false);

        SetSellToCustomer(NpEcStore, Order, SalesHeader);
        SetShipToCustomer(NpEcStore, Order, SalesHeader);
        SalesHeader."External Document No." := CopyStr(ShopifyStoreCode + '-' + OrderNo, 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader."NPR External Order No." := CopyStr(SalesHeader."External Document No.", 1, MaxStrLen(SalesHeader."NPR External Order No."));
        SalesHeader."Prices Including VAT" := true;
        SalesHeader.Validate("Currency Code", GetCurrCode(Order));

        SetShipmentMethod(Order, SalesHeader, IsShpmtMappingLocation, IsShpmtMappingShipAgent);

        SalesHeader.Validate("Posting Date", DT2Date(JsonHelper.GetJDT(Order, 'created_at', true)));
        SalesHeader.Validate("Document Date", SalesHeader."Posting Date");
        SalesHeader.Validate("Order Date", SalesHeader."Posting Date");
        ClosedAt := DT2Date(JsonHelper.GetJDT(Order, 'closed_at', false));
        if ClosedAt > SalesHeader."Posting Date" then
            SalesHeader.Validate("Posting Date", ClosedAt);

        FindLocationMapping(Order, NpEcStore, LocationMapping);
        if (LocationMapping."Location Code" <> '') and not IsShpmtMappingLocation then
            SalesHeader.Validate("Location Code", LocationMapping."Location Code");
        if (LocationMapping."Shipping Agent Code" <> '') and not IsShpmtMappingShipAgent then begin
            SalesHeader.Validate("Shipping Agent Code", LocationMapping."Shipping Agent Code");
            SalesHeader.Validate("Shipping Agent Service Code", LocationMapping."Shipping Agent Service Code");
        end;

        if NpEcStore."Salesperson/Purchaser Code" <> '' then
            SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        IF NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");

        InsertComments(Order, SalesHeader);
        SpfyIntegrationEvents.OnUpdateSalesHeader(Order, SalesHeader);
        SalesHeader.Modify(true);
    end;

    local procedure SetShipmentMethod(Order: JsonToken; var SalesHeader: Record "Sales Header"; var IsShpmtMappingLocation: Boolean; var IsShpmtMappingShipAgent: Boolean)
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        ShippingLines: JsonToken;
        ShippingLine: JsonToken;
        FoundShipmentMapping: Boolean;
    begin
        if Order.SelectToken('shipping_lines', ShippingLines) and ShippingLines.IsArray() then
            foreach ShippingLine in ShippingLines.AsArray() do begin
                FoundShipmentMapping := FindShipmentMapping(ShippingLine, ShipmentMapping);
                if FoundShipmentMapping then begin
                    SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
                    IsShpmtMappingShipAgent := ShipmentMapping."Shipping Agent Code" <> '';
                    if IsShpmtMappingShipAgent then begin
                        SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
                        SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
                    end;
                    IsShpmtMappingLocation := ShipmentMapping."Spfy Location Code" <> '';
                    if IsShpmtMappingLocation then
                        SalesHeader.Validate("Location Code", ShipmentMapping."Spfy Location Code");
                    exit;
                end;
            end;
    end;

    local procedure FindCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var Customer: Record Customer)
    var
        Customer2: Record Customer;
        NpEcCustomerMapping: Record "NPR NpEc Customer Mapping";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        CountryCode: Code[10];
        CustomerShopifyID: Text[30];
        CustomerName: Text;
        Email: Text;
        Phone: Text;
        PostCode: Text;
        Found: Boolean;
    begin
        Clear(Customer);
        CustomerShopifyID := CopyStr(JsonHelper.GetJText(Order, 'customer.id', false), 1, MaxStrLen(CustomerShopifyID));
        if CustomerShopifyID <> '' then begin
            Found := false;
            SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::Customer, "NPR Spfy ID Type"::"Entry ID", CustomerShopifyID, ShopifyAssignedID);
            if ShopifyAssignedID.FindSet() then
                repeat
                    if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                        RecRef.SetTable(Customer);
                        Found := Customer.Find() and (Customer.Blocked = Customer.Blocked::" ");
                    end;
                until (ShopifyAssignedID.Next() = 0) or Found;
            if Found then
                exit;
            if not Found and (Customer."No." <> '') then
                Customer.TestField(Blocked, Customer.Blocked::" ");  //raise error
        end;

        Email := JsonHelper.GetJText(Order, 'customer.email', MaxStrLen(Customer."E-Mail"), false);
        Phone := JsonHelper.GetJText(Order, 'customer.phone', MaxStrLen(Customer."Phone No."), false);
        if (Phone = '') then
            Phone := JsonHelper.GetJText(Order, 'customer.default_address.phone', MaxStrLen(Customer."Phone No."), false);

        if ((NpEcStore."Customer Mapping" in [NpEcStore."Customer Mapping"::"E-mail", NpEcStore."Customer Mapping"::"E-mail OR Phone No."]) and (Email <> '')) or
           ((NpEcStore."Customer Mapping" in [NpEcStore."Customer Mapping"::"Phone No.", NpEcStore."Customer Mapping"::"E-mail OR Phone No."]) and (Phone <> '')) or
           ((NpEcStore."Customer Mapping" = NpEcStore."Customer Mapping"::"E-mail AND Phone No.") and (Email <> '') and (Phone <> ''))
        then begin
            case NpEcStore."Customer Mapping" of
                NpEcStore."Customer Mapping"::"E-mail":
                    begin
                        Customer2.SetRange("E-Mail", Email);
                    end;
                NpEcStore."Customer Mapping"::"E-mail AND Phone No.":
                    begin
                        Customer2.SetRange("E-Mail", Email);
                        Customer2.SetRange("Phone No.", Phone);
                    end;
                NpEcStore."Customer Mapping"::"E-mail OR Phone No.":
                    begin
                        if (Email <> '') and (Phone <> '') then begin
                            Customer2.SetRange("E-Mail", Email);
                            Customer2.SetRange("Phone No.", Phone);
                            if CustomerIsInSet(Customer2, CustomerShopifyID, false, Customer) then
                                exit;
                            Customer2.Reset();
                        end;
                        Customer2.FilterGroup(-1);
                        if Email <> '' then
                            Customer2.SetRange("E-Mail", Email);
                        if Phone <> '' then
                            Customer2.SetRange("Phone No.", Phone);
                    end;
                NpEcStore."Customer Mapping"::"Phone No.":
                    begin
                        Customer2.SetRange("Phone No.", Phone);
                    end;
            end;
            if CustomerIsInSet(Customer2, CustomerShopifyID, true, Customer) then
                exit;
        end;

        CountryCode := GetCountryCode(NpEcStore, Order, 'billing_address.country_code', false);
        PostCode := JsonHelper.GetJCode(Order, 'billing_address.zip', MaxStrLen(Customer."Post Code"), false);

        if NpEcStore."Allow Create Customers" then begin
            if not (NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, PostCode) and (NpEcCustomerMapping."Config. Template Code" <> '')) then
                if not NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, '') then
                    Clear(NpEcCustomerMapping);
            if NpEcCustomerMapping."Config. Template Code" <> '' then
                NpEcStore."Customer Config. Template Code" := NpEcCustomerMapping."Config. Template Code";

            NpEcStore.TestField("Customer Config. Template Code");
            CreateCustomerFromTemplate(Customer, NpEcStore."Customer Config. Template Code");
            CustomerName := JsonHelper.GetJText(Order, 'customer.first_name', false) + ' ' + JsonHelper.GetJText(Order, 'customer.last_name', false);
            Customer.Name := CopyStr(CustomerName, 1, MaxStrLen(Customer.Name));
            Customer."Name 2" := CopyStr(CustomerName, StrLen(Customer.Name) + 1, MaxStrLen(Customer."Name 2"));
#pragma warning disable AA0139
            Customer."E-Mail" := Email;
            Customer."Phone No." := Phone;
            Customer.Address := JsonHelper.GetJText(Order, 'billing_address.address1', MaxStrLen(Customer.Address), false);
            Customer."Address 2" := JsonHelper.GetJText(Order, 'billing_address.address2', MaxStrLen(Customer."Address 2"), false);
            Customer.City := JsonHelper.GetJText(Order, 'billing_address.city', MaxStrLen(Customer.City), false);
            Customer."Post Code" := PostCode;
#pragma warning restore AA0139
            Customer."Country/Region Code" := CountryCode;
            Customer.Modify();
            SpfyAssignedIDMgt.AssignShopifyID(Customer.RecordId(), "NPR Spfy ID Type"::"Entry ID", CustomerShopifyID, false);
            exit;
        end;

        if NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, PostCode) then begin
            NpEcCustomerMapping.TestField("Spfy Customer No.");
            Customer.Get(NpEcCustomerMapping."Spfy Customer No.");
            exit;
        end;
        if NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, '') then begin
            NpEcCustomerMapping.TestField("Spfy Customer No.");
            Customer.Get(NpEcCustomerMapping."Spfy Customer No.");
            exit;
        end;

        NpEcStore.testfield("Spfy Customer No.");
        Customer.Get(NpEcStore."Spfy Customer No.");
    end;

    local procedure CreateCustomerFromTemplate(var Customer: Record Customer; CustomerTemplCode: Code[20])
    var
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
    begin
        CustomerTempl.Get(CustomerTemplCode);

        Customer.SetInsertFromTemplate(true);
        Customer.Init();
#if BC18 or BC19
        InitCustomerNo(Customer, CustomerTempl);
#else
        CustomerTemplMgt.InitCustomerNo(Customer, CustomerTempl);
#endif
        Customer."Contact Type" := CustomerTempl."Contact Type";
        Customer.Insert(true);
        Customer.SetInsertFromTemplate(false);

        CustomerTemplMgt.ApplyCustomerTemplate(Customer, CustomerTempl);
    end;

#if BC18 or BC19
    procedure InitCustomerNo(var Customer: Record Customer; CustomerTempl: Record "Customer Templ.")
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if CustomerTempl."No. Series" = '' then
            exit;

        NoSeriesManagement.InitSeries(CustomerTempl."No. Series", '', 0D, Customer."No.", Customer."No. Series");
    end;
#endif

    local procedure CustomerIsInSet(var CustomerSet: Record Customer; CustomerShopifyID: Text[30]; RaiseBlockedError: Boolean; var SelectedCustomer: Record Customer): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Found: Boolean;
    begin
        if CustomerShopifyID = '' then
            exit(false);

        Clear(SelectedCustomer);
        if CustomerSet.FindSet() then
            repeat
                Found := SpfyAssignedIDMgt.GetAssignedShopifyID(CustomerSet.RecordId(), "NPR Spfy ID Type"::"Entry ID") in ['', CustomerShopifyID];
                if Found then begin
                    SelectedCustomer := CustomerSet;
                    Found := SelectedCustomer.Blocked = SelectedCustomer.Blocked::" ";
                end;
            until (CustomerSet.Next() = 0) or Found;

        if Found then
            SpfyAssignedIDMgt.AssignShopifyID(SelectedCustomer.RecordId(), "NPR Spfy ID Type"::"Entry ID", CustomerShopifyID, false)
        else
            if (SelectedCustomer."No." <> '') and RaiseBlockedError then
                SelectedCustomer.TestField(Blocked, SelectedCustomer.Blocked::" ");  //raise error

        exit(Found);
    end;

    local procedure SetSellToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        Company: Text;
        SellToName: Text;
        BillingAddress: JsonToken;
    begin
        FindCustomer(NpEcStore, Order, Customer);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");

        if Order.SelectToken('billing_address', BillingAddress) then begin
            SellToName := JsonHelper.GetJText(BillingAddress, 'first_name', false);
            if JsonHelper.GetJText(BillingAddress, 'last_name', false) <> '' then begin
                if SellToName <> '' then
                    SellToName += ' ';
                SellToName += JsonHelper.GetJText(BillingAddress, 'last_name', false);
            end;
            Company := JsonHelper.GetJText(BillingAddress, 'company', false);
            if Company = '' then begin
                SalesHeader."Sell-to Customer Name" := CopyStr(SellToName, 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
                SalesHeader."Sell-to Customer Name 2" := CopyStr(SellToName, StrLen(SalesHeader."Sell-to Customer Name") + 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
            end else begin
                SalesHeader."Sell-to Customer Name" := CopyStr(Company, 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
                SalesHeader."Sell-to Customer Name 2" := CopyStr(Company, StrLen(SalesHeader."Sell-to Customer Name") + 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
                SalesHeader."Sell-to Contact" := CopyStr(SellToName, 1, MaxStrLen(SalesHeader."Sell-to Contact"));
            end;
#pragma warning disable AA0139
            SalesHeader."Sell-to Address" := JsonHelper.GetJText(BillingAddress, 'address1', MaxStrLen(SalesHeader."Sell-to Address"), false);
            SalesHeader."Sell-to Address 2" := JsonHelper.GetJText(BillingAddress, 'address2', MaxStrLen(SalesHeader."Sell-to Address 2"), false);
            SalesHeader."Sell-to Post Code" := JsonHelper.GetJCode(BillingAddress, 'zip', MaxStrLen(SalesHeader."Sell-to Post Code"), false);
            SalesHeader."Sell-to City" := JsonHelper.GetJText(BillingAddress, 'city', MaxStrLen(SalesHeader."Sell-to City"), false);
#pragma warning restore AA0139
            SalesHeader.Validate("Sell-to Country/Region Code", GetCountryCode(NpEcStore, BillingAddress, 'country_code', false));
        end;
        if SalesHeader."Sell-to Contact" = '' then
            SalesHeader."Sell-to Contact" := SalesHeader."Sell-to Customer Name";

        SalesHeader."Bill-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Bill-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."Bill-to Contact" := SalesHeader."Sell-to Contact";
        SalesHeader."Bill-to Address" := SalesHeader."Sell-to Address";
        SalesHeader."Bill-to Address 2" := SalesHeader."Sell-to Address 2";
        SalesHeader."Bill-to Post Code" := SalesHeader."Sell-to Post Code";
        SalesHeader."Bill-to City" := SalesHeader."Sell-to City";
        SalesHeader.Validate("Bill-to Country/Region Code", SalesHeader."Sell-to Country/Region Code");
#pragma warning disable AA0139
        SalesHeader."NPR Bill-to E-mail" := JsonHelper.GetJText(Order, 'customer.email', MaxStrLen(SalesHeader."NPR Bill-to E-mail"), false);
        SalesHeader."NPR Bill-to Phone No." := JsonHelper.GetJText(Order, 'customer.phone', MaxStrLen(SalesHeader."NPR Bill-to Phone No."), false);
#pragma warning restore AA0139
    end;

    local procedure SetShipToCustomer(NpEcStore: Record "NPR NpEc Store"; Order: JsonToken; var SalesHeader: Record "Sales Header")
    var
        Company: Text;
        ShipToName: Text;
        ShippingAddress: JsonToken;
    begin
        SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."Ship-to Contact" := SalesHeader."Sell-to Contact";
        SalesHeader."Ship-to Address" := SalesHeader."Sell-to Address";
        SalesHeader."Ship-to Address 2" := SalesHeader."Sell-to Address 2";
        SalesHeader."Ship-to Post Code" := SalesHeader."Sell-to Post Code";
        SalesHeader."Ship-to City" := SalesHeader."Sell-to City";
        SalesHeader.Validate("Ship-to Country/Region Code", SalesHeader."Sell-to Country/Region Code");

        if not Order.SelectToken('shipping_address', ShippingAddress) or not ShippingAddress.IsObject() then
            exit;

        ShipToName := JsonHelper.GetJText(ShippingAddress, 'first_name', false);
        if JsonHelper.GetJText(ShippingAddress, 'last_name', false) <> '' then begin
            if ShipToName <> '' then
                ShipToName += ' ';
            ShipToName += JsonHelper.GetJText(ShippingAddress, 'last_name', false);
        end;
        Company := JsonHelper.GetJText(ShippingAddress, 'company', false);
        if Company = '' then begin
            SalesHeader."Ship-to Name" := CopyStr(ShipToName, 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(ShipToName, StrLen(SalesHeader."Ship-to Name") + 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
        end else begin
            SalesHeader."Ship-to Name" := CopyStr(Company, 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(Company, StrLen(SalesHeader."Ship-to Name") + 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
            SalesHeader."Ship-to Contact" := CopyStr(ShipToName, 1, MaxStrLen(SalesHeader."Ship-to Contact"));
        end;
#pragma warning disable AA0139
        SalesHeader."Ship-to Address" := JsonHelper.GetJText(ShippingAddress, 'address1', MaxStrLen(SalesHeader."Ship-to Address"), false);
        SalesHeader."Ship-to Address 2" := JsonHelper.GetJText(ShippingAddress, 'address2', MaxStrLen(SalesHeader."Ship-to Address 2"), false);
        SalesHeader."Ship-to Post Code" := JsonHelper.GetJCode(ShippingAddress, 'zip', MaxStrLen(SalesHeader."Ship-to Post Code"), false);
        SalesHeader."Ship-to City" := JsonHelper.GetJText(ShippingAddress, 'city', MaxStrLen(SalesHeader."Ship-to City"), false);
#pragma warning restore AA0139
        SalesHeader.Validate("Ship-to Country/Region Code", GetCountryCode(NpEcStore, ShippingAddress, 'country_code', false));
    end;

    local procedure GetCountryCode(NpEcStore: Record "NPR NpEc Store"; Token: JsonToken; Path: Text; MustExistInJson: Boolean) CountryCode: Code[10]
    begin
#pragma warning disable AA0139
        CountryCode := JsonHelper.GetJCode(Token, Path, MaxStrLen(CountryCode), MustExistInJson);
#pragma warning restore AA0139
        if CountryCode = '' then
            CountryCode := NpEcStore."Spfy Country/Region Code";
    end;

    local procedure GetCurrCode(Order: JsonToken): Code[10]
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        CurrCode: Code[10];
    begin
#pragma warning disable AA0139
        CurrCode := JsonHelper.GetJCode(Order, 'currency', MaxStrLen(CurrCode), false);
#pragma warning restore AA0139
        if CurrCode <> '' then begin
            GLSetup.Get();
            if CurrCode <> GLSetup."LCY Code" then
                Currency.Get(CurrCode)
            else
                if not Currency.get(CurrCode) then
                    CurrCode := '';
        end;
        exit(CurrCode);
    end;

    procedure DeleteSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindFirst() then
            SalesLine.DeleteAll(true);
    end;

    procedure InsertSalesLines(ShopifyStoreCode: Code[20]; Order: JsonToken; SalesHeader: Record "Sales Header"; ForPosting: Boolean)
    var
        TempFulfillmentLineBuffer: Record "NPR Spfy Fulfillment Entry" temporary;
        TempFulfillmEntryDetailBuffer: Record "NPR Spfy Fulfillm.Entry Detail" temporary;
        OrderLines: JsonToken;
        OrderLine: JsonToken;
        LastLineNo: Integer;
    begin
        CalculateFulfillments(Order, TempFulfillmentLineBuffer, TempFulfillmEntryDetailBuffer);
        if Order.SelectToken('line_items', OrderLines) and OrderLines.IsArray() then
            foreach OrderLine in OrderLines.AsArray() do
                if not SkipLine(OrderLine) then
                    InsertSalesLine(ShopifyStoreCode, OrderLine, TempFulfillmentLineBuffer, TempFulfillmEntryDetailBuffer, SalesHeader, ForPosting, LastLineNo);

        if Order.SelectToken('shipping_lines', OrderLines) and OrderLines.IsArray() then
            foreach OrderLine in OrderLines.AsArray() do
                InsertSalesLineShipmentFee(OrderLine, SalesHeader, LastLineNo);
    end;

    local procedure CalculateFulfillments(Order: JsonToken; var FulfillmentLineBuffer: Record "NPR Spfy Fulfillment Entry"; var FulfillmEntryDetailBuffer: Record "NPR Spfy Fulfillm.Entry Detail")
    var
        Fulfillment: JsonToken;
        FulfillmentLine: JsonToken;
        FulfillmentLines: JsonToken;
        Fulfillments: JsonToken;
        GiftCard: JsonToken;
        GiftCards: JsonToken;
        OrderLineID: Text[30];
        FulfilledQty: Decimal;
        LastEntryNo: Integer;
        LastDetEntryNo: Integer;
    begin
        if Order.SelectToken('fulfillments', Fulfillments) and Fulfillments.IsArray() then
            foreach Fulfillment in Fulfillments.AsArray() do
                if JsonHelper.GetJText(Fulfillment, 'status', true) = 'success' then begin
                    if Fulfillment.SelectToken('line_items', FulfillmentLines) and FulfillmentLines.IsArray() then
                        foreach FulfillmentLine in FulfillmentLines.AsArray() do
                            if JsonHelper.GetJText(FulfillmentLine, 'fulfillment_status', true) = 'fulfilled' then begin
                                FulfilledQty := JsonHelper.GetJDecimal(FulfillmentLine, 'quantity', false);
                                if FulfilledQty > 0 then begin
#pragma warning disable AA0139
                                    OrderLineID := JsonHelper.GetJText(FulfillmentLine, 'id', MaxStrLen(OrderLineID), true);
#pragma warning restore AA0139
                                    FulfillmentLineBuffer.SetRange("Order Line ID", OrderLineID);
                                    if not FulfillmentLineBuffer.FindFirst() then begin
                                        LastEntryNo += 1;
                                        FulfillmentLineBuffer.Init();
                                        FulfillmentLineBuffer."Order Line ID" := OrderLineID;
                                        FulfillmentLineBuffer."Entry No." := LastEntryNo;
                                        FulfillmentLineBuffer.Insert();
                                    end;
                                    FulfillmentLineBuffer."Fulfilled Quantity" += FulfilledQty;
                                    FulfillmentLineBuffer.Modify();
                                end;
                            end;

                    if Fulfillment.SelectToken('receipt.gift_cards', GiftCards) and GiftCards.IsArray() then
                        foreach GiftCard in GiftCards.AsArray() do begin
#pragma warning disable AA0139
                            OrderLineID := JsonHelper.GetJText(GiftCard, 'line_item_id', MaxStrLen(OrderLineID), true);
#pragma warning restore AA0139
                            FulfillmentLineBuffer.SetRange("Order Line ID", OrderLineID);
                            FulfillmentLineBuffer.FindFirst();
                            FulfillmentLineBuffer."Gift Card" := true;
                            FulfillmentLineBuffer.Modify();
                            FulfillmentLineBuffer.SetRange("Order Line ID");

                            LastDetEntryNo += 1;
                            FulfillmEntryDetailBuffer.Init();
                            FulfillmEntryDetailBuffer."Entry No." := LastDetEntryNo;
                            FulfillmEntryDetailBuffer."Parent Entry No." := FulFillmentLineBuffer."Entry No.";
#pragma warning disable AA0139
                            FulfillmEntryDetailBuffer."Gift Card ID" := JsonHelper.GetJText(GiftCard, 'id', MaxStrLen(FulfillmEntryDetailBuffer."Gift Card ID"), true);
                            FulfillmEntryDetailBuffer."Gift Card Reference No." := JsonHelper.GetJText(GiftCard, 'masked_code', MaxStrLen(FulfillmEntryDetailBuffer."Gift Card Reference No."), true);
                            if StrLen(FulfillmEntryDetailBuffer."Gift Card Reference No.") > 4 then
                                FulfillmEntryDetailBuffer."Gift Card Reference No." := CopyStr(FulfillmEntryDetailBuffer."Gift Card Reference No.", StrLen(FulfillmEntryDetailBuffer."Gift Card Reference No.") - 3);
                            FulfillmEntryDetailBuffer."Gift Card Reference No." := StrSubstNo('%1/%2', FulfillmEntryDetailBuffer."Gift Card ID", FulfillmEntryDetailBuffer."Gift Card Reference No.");
#pragma warning restore AA0139
                            FulfillmEntryDetailBuffer.Insert();
                        end;
                end;
    end;

    local procedure InsertSalesLine(ShopifyStoreCode: Code[20]; OrderLine: JsonToken; var FulfillmentLineBuffer: Record "NPR Spfy Fulfillment Entry"; var FulfillmEntryDetailBuffer: Record "NPR Spfy Fulfillm.Entry Detail"; SalesHeader: Record "Sales Header"; ForPosting: Boolean; var LastLineNo: Integer)
    var
        ItemVariant: Record "Item Variant";
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        SalesLine: Record "Sales Line";
        VoucherType: Record "NPR NpRv Voucher Type";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        PropertyDict: Dictionary of [Text, Text];
        UnitPrice: Decimal;
        OrderLineID: Text[30];
        Sku: Text;
        Handled: Boolean;
        IsGiftCard: Boolean;
        IsNPGiftCard: Boolean;
        UnknownIdErr: Label 'Unknown %1: %2%3';
    begin
        OrderLineID := GetOrderID(OrderLine);
        IsGiftCard := OrderLineIsGiftCard(OrderLine, IsNPGiftCard);
        if IsGiftCard then begin
            GetOrderLineProperties(OrderLine, PropertyDict);
            GetVoucherType(ShopifyStoreCode, PropertyDict, VoucherType);
        end else
            if not SpfyItemMgt.ParseItem(OrderLine, ItemVariant, Sku) then
                Error(UnknownIdErr, 'sku', Sku, StrSubstNo(' (line ID: %1, name: %2)', OrderLineID, JsonHelper.GetJText(OrderLine, 'name', false)));

        UnitPrice := JsonHelper.GetJDecimal(OrderLine, 'price', true);

        Clear(NpEcStore);
        NpEcDocument.SetCurrentKey("Document Type", "Document No.");
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
        NpEcDocument.SetRange("Document No.", SalesHeader."No.");
        if NpEcDocument.FindFirst() then
            if NpEcStore.Get(NpEcDocument."Store Code") then;

        LastLineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LastLineNo;
        SalesLine.Insert(true);

        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderLineID, false);

        FulfillmentLineBuffer.SetRange("Order Line ID", OrderLineID);
        if not FulfillmentLineBuffer.FindFirst() then
            FulfillmentLineBuffer.Init();

        SpfyIntegrationEvents.OnBeforeFillInSalesLine(OrderLine, FulfillmentLineBuffer."Fulfilled Quantity", ForPosting, ItemVariant, SalesHeader, SalesLine, Handled);
        if not Handled then begin
            if IsGiftCard then begin
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                SalesLine.Validate("No.", VoucherType."Account No.");
#pragma warning disable AA0139
                SalesLine.Description := JsonHelper.GetJText(OrderLine, 'name', MaxStrLen(SalesLine.Description), false);
#pragma warning restore AA0139
            end else begin
                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", ItemVariant."Item No.");
                if ItemVariant.Code <> '' then
                    SalesLine.Validate("Variant Code", ItemVariant.Code);
#pragma warning disable AA0139
                SalesLine.Description := JsonHelper.GetJText(OrderLine, 'title', MaxStrLen(SalesLine.Description), true);
                SalesLine."Description 2" := JsonHelper.GetJText(OrderLine, 'variant_title', MaxStrLen(SalesLine."Description 2"), false);
#pragma warning restore AA0139
            end;
            SalesLine.Validate(Quantity, JsonHelper.GetJDecimal(OrderLine, 'fulfillable_quantity', true) + FulfillmentLineBuffer."Fulfilled Quantity");
            if ForPosting then
                if SalesLine."Qty. to Ship" <> FulfillmentLineBuffer."Fulfilled Quantity" then
                    SalesLine.Validate("Qty. to Ship", FulfillmentLineBuffer."Fulfilled Quantity");
            SalesLine.Validate("Unit Price", UnitPrice);
            if SalesLine."Unit Price" <> 0 then
                SalesLine.Validate("Line Discount Amount", CalcLineDiscountAmount(OrderLine, SalesLine));
            if IsGiftCard then begin
                SetRetailVoucher(SalesHeader, SalesLine, IsNPGiftCard, VoucherType, PropertyDict, FulfillmentLineBuffer, FulfillmEntryDetailBuffer);
                FulfillmEntryDetailBuffer.Reset();
            end;
        end;
        SalesLine.Modify(true);
        SpfyIntegrationEvents.OnAfterInsertSalesLine(SalesHeader, SalesLine, LastLineNo);
    end;

    local procedure SetRetailVoucher(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; IsNpGiftCard: Boolean; VoucherType: Record "NPR NpRv Voucher Type"; PropertyDict: Dictionary of [Text, Text]; FulfillmentLineBuffer: Record "NPR Spfy Fulfillment Entry"; var FulfillmEntryDetailBuffer: Record "NPR Spfy Fulfillm.Entry Detail")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetRange("Document Type", SalesLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", SalesLine."Line No.");
        if not NpRvSalesLine.IsEmpty() then
            NpRvSalesLine.DeleteAll(true);

        if not (FulfillmentLineBuffer."Gift Card" or IsNpGiftCard) then
            exit;

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
        NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
        NpRvSalesLine."Voucher Type" := VoucherType.Code;
        NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
        NpRvSalesLine.Description := CopyStr(SalesLine.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        NpRvSalesLine."Spfy Initiated in Shopify" := not IsNpGiftCard;
        UpdateVoucherRecipient(PropertyDict, NpRvSalesLine);
        NpRvSalesLine.Insert(true);

        FulfillmEntryDetailBuffer.SetRange("Parent Entry No.", FulfillmentLineBuffer."Entry No.");
        FulfillmEntryDetailBuffer.SetFilter("Gift Card ID", '<>%1', '');
        if not FulfillmEntryDetailBuffer.FindSet() then
            exit;
        repeat
            SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR NpRv Voucher", "NPR Spfy ID Type"::"Entry ID", FulfillmEntryDetailBuffer."Gift Card ID", ShopifyAssignedID);
            if ShopifyAssignedID.FindLast() then
                Voucher.Get(ShopifyAssignedID."BC Record ID")
            else begin
                VoucherMgt.InitVoucher(VoucherType, '', FulfillmEntryDetailBuffer."Gift Card Reference No.", 0DT, true, Voucher);
                SpfyAssignedIDMgt.AssignShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID", FulfillmEntryDetailBuffer."Gift Card ID", false);
            end;

            NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, Voucher);
        until FulfillmEntryDetailBuffer.Next() = 0;
    end;

    local procedure OrderLineIsGiftCard(OrderLine: JsonToken; var IsNPGiftCard: Boolean): Boolean
    var
        OrderLineProperties: JsonToken;
        OrderLineProperty: JsonToken;
    begin
        IsNPGiftCard := false;
        if JsonHelper.GetJBoolean(OrderLine, 'gift_card', false) then
            exit(true);
        if not (JsonHelper.GetJsonToken(OrderLine, 'properties', OrderLineProperties) and OrderLineProperties.IsArray()) then
            exit(false);
        foreach OrderLineProperty in OrderLineProperties.AsArray() do
            if JsonHelper.GetJText(OrderLineProperty, 'name', false) = '_is_giftcard' then begin
                IsNPGiftCard := JsonHelper.GetJBoolean(OrderLineProperty, 'value', false);
                exit(IsNPGiftCard);
            end;
    end;

    local procedure GetOrderLineProperties(OrderLine: JsonToken; var PropertyDict: Dictionary of [Text, Text]): Boolean
    var
        OrderLineProperties: JsonToken;
        OrderLineProperty: JsonToken;
        PropertyName: Text;
        PropertyValue: Text;
    begin
        Clear(PropertyDict);
        if not JsonHelper.GetJsonToken(OrderLine, 'properties', OrderLineProperties) or not OrderLineProperties.IsArray() then
            exit(false);
        foreach OrderLineProperty in OrderLineProperties.AsArray() do begin
            PropertyName := JsonHelper.GetJText(OrderLineProperty, 'name', false);
            if PropertyName <> '' then begin
                PropertyValue := JsonHelper.GetJText(OrderLineProperty, 'value', false);
                if PropertyValue <> '' then
                    PropertyDict.Add(PropertyName, PropertyValue);
            end;
        end;
    end;

    local procedure GetVoucherType(ShopifyStoreCode: Code[20]; PropertyDict: Dictionary of [Text, Text]; var VoucherType: Record "NPR NpRv Voucher Type")
    var
        ShopifyStore: Record "NPR Spfy Store";
        PropertyValue: Text;
        VoucherTypeCode: Code[20];
    begin
        if PropertyDict.Get('_np_voucher_type', PropertyValue) then
            VoucherTypeCode := CopyStr(PropertyValue, 1, MaxStrLen(VoucherTypeCode));
        if (VoucherTypeCode = '') or not VoucherType.Get(VoucherTypeCode) then begin
            ShopifyStore.Get(ShopifyStoreCode);
            ShopifyStore.TestField("Voucher Type (Sold at Shopify)");
            VoucherType.Get(ShopifyStore."Voucher Type (Sold at Shopify)");
        end;
        VoucherType.TestField("Account No.");
    end;

    local procedure UpdateVoucherRecipient(PropertyDict: Dictionary of [Text, Text]; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        PropertyKey: Text;
        PropertyValue: Text;
    begin
        foreach PropertyKey in PropertyDict.Keys() do begin
            PropertyValue := PropertyDict.Get(PropertyKey);
            case PropertyKey of
                '_send_giftcard':
                    NpRvSalesLine."Spfy Send from Shopify" := LowerCase(PropertyValue) in ['on', 'true', 'yes', '1'];
                'Recipient Email':
                    NpRvSalesLine."E-mail" := CopyStr(PropertyValue, 1, MaxStrLen(NpRvSalesLine."E-mail"));
                'Recipient Name':
                    begin
                        NpRvSalesLine.Name := CopyStr(PropertyValue, 1, MaxStrLen(NpRvSalesLine.Name));
                        if StrLen(PropertyValue) > MaxStrLen(NpRvSalesLine.Name) then
                            NpRvSalesLine."Name 2" := CopyStr(PropertyValue, MaxStrLen(NpRvSalesLine.Name) + 1, MaxStrLen(NpRvSalesLine."Name 2"));
                    end;
                'Message':
                    NpRvSalesLine."Voucher Message" := CopyStr(PropertyValue, 1, MaxStrLen(NpRvSalesLine."Voucher Message"));
                'Template Suffix':
                    NpRvSalesLine."Spfy Liquid Template Suffix" := CopyStr(PropertyValue, 1, MaxStrLen(NpRvSalesLine."Spfy Liquid Template Suffix"));
                'Send On':
                    if Evaluate(NpRvSalesLine."Spfy Send on", PropertyValue, 9) then;
            end;
        end;
    end;

    local procedure InsertSalesLineShipmentFee(ShippingLine: JsonToken; SalesHeader: Record "Sales Header"; var LastLineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShipmentFee: Decimal;
        ShipmentFeeTitle: Text;
    begin
        ShipmentFee := JsonHelper.GetJDecimal(ShippingLine, 'price', false);
        if ShipmentFee <= 0 then
            exit;

        FindShipmentMapping(ShippingLine, ShipmentMapping);
        ShipmentMapping.TestField("Shipment Fee No.");
        ShipmentFeeTitle := JsonHelper.GetJText(ShippingLine, 'title', false);

        LastLineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LastLineNo;
        SalesLine.Insert(true);

        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", GetOrderID(ShippingLine), false);

        case ShipmentMapping."Shipment Fee Type" of
            ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
                SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
            ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
                SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
            ShipmentMapping."Shipment Fee Type"::"G/L Account":
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
            ShipmentMapping."Shipment Fee Type"::Item:
                SalesLine.Validate(Type, SalesLine.Type::Item);
            ShipmentMapping."Shipment Fee Type"::Resource:
                SalesLine.Validate(Type, SalesLine.Type::Resource);
        end;
        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", ShipmentFee);
        SalesLine.validate("Line Discount Amount", CalcLineDiscountAmount(ShippingLine, SalesLine));
        if ShipmentFeeTitle <> '' then begin
            SalesLine.Description := CopyStr(ShipmentFeeTitle, 1, MaxStrLen(SalesLine.Description));
            SalesLine."Description 2" := CopyStr(ShipmentFeeTitle, MaxStrLen(SalesLine.Description) + 1, MaxStrLen(SalesLine."Description 2"));
        end;
        SalesLine.Modify(true);

        SpfyIntegrationEvents.OnAfterInsertSalesLineShipmentFee(SalesHeader, SalesLine, LastLineNo);
    end;

    procedure InsertPaymentLines(ShopifyStoreCode: Code[20]; Order: JsonToken; var SalesHeader: Record "Sales Header")
    var
        NcTask: Record "NPR Nc Task";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeInsertPaymentLines(ShopifyStoreCode, Order, SalesHeader, Handled);
        if not Handled then
            if SpfyIntegrationMgt.CreatePmtLinesOnOrderImport(ShopifyStoreCode) then begin
                Clear(NcTask);
                NcTask."Record ID" := SalesHeader.RecordId();
                NcTask."Record Value" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 1, MaxStrLen(NcTask."Record Value"));
                NcTask."Store Code" := ShopifyStoreCode;
                SpfyCapturePayment.UpdatePmtLinesAndScheduleCapture(NcTask, false, false);
            end;

        Handled := false;
        SpfyIntegrationEvents.OnAfterInsertPaymentLines(ShopifyStoreCode, Order, SalesHeader, Handled);
    end;

    local procedure CalcLineDiscountAmount(OrderLine: JsonToken; SalesLine: Record "Sales Line") LineDiscountAmount: Decimal
    var
        Discount: JsonToken;
        Discounts: JsonToken;
        OriginalOrderQty: Decimal;
    begin
        LineDiscountAmount := 0;
        if OrderLine.SelectToken('discount_allocations', Discounts) and Discounts.IsArray() then
            foreach Discount in Discounts.AsArray() do
                LineDiscountAmount += JsonHelper.GetJDecimal(Discount, 'amount', false);

        if LineDiscountAmount = 0 then
            exit;

        OriginalOrderQty := JsonHelper.GetJDecimal(OrderLine, 'quantity', false);
        if (SalesLine.Quantity < OriginalOrderQty) and (OriginalOrderQty <> 0) then
            LineDiscountAmount := LineDiscountAmount / OriginalOrderQty * SalesLine.Quantity;
    end;

    local procedure FindLocationMapping(Order: JsonToken; NpEcStore: Record "NPR NpEc Store"; var LocationMapping: Record "NPR Spfy Location Mapping")
    var
        CountryCode: Text;
        PostCode: Text;
    begin
        CountryCode := GetCountryCode(NpEcStore, Order, 'shipping_address.country_code', false);
        PostCode := JsonHelper.GetJCode(Order, 'shipping_address.zip', MaxStrLen(LocationMapping."From Post Code"), false);

        LocationMapping.SetRange("Store Code", NpEcStore.Code);
        LocationMapping.SetRange("Country/Region Code", CountryCode);
        LocationMapping.SetFilter("From Post Code", '..%1', PostCode);
        LocationMapping.SetFilter("To Post Code", '%1|%2..', '', PostCode);
        LocationMapping.SetFilter("Location Code", '<>%1', '');
        if LocationMapping.IsEmpty() then
            LocationMapping.SetFilter("Country/Region Code", '%1|%2', '', CountryCode);
        if LocationMapping.FindFirst() then
            exit;

        NpEcStore.TestField("Location Code");
        Clear(LocationMapping);
        LocationMapping."Location Code" := CopyStr(NpEcStore."Location Code", 1, MaxStrLen(LocationMapping."Location Code"));
    end;

    local procedure InsertComments(Order: JsonToken; SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        RecordLinkMgt: Codeunit "Record Link Management";
        CommentLine: Text;
        LinkID: Integer;
    begin
        CommentLine := JsonHelper.GetJText(Order, 'note', false);
        if CommentLine = '' then
            exit;
        LinkID := SalesHeader.AddLink('', SalesHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := SpfyIntegrationMgt.DataProcessingHandlerID(true);
        RecordLinkMgt.WriteNote(RecordLink, CommentLine);
        RecordLink.Modify(true);
    end;

    local procedure SkipLine(OrderLine: JsonToken): Boolean
    var
        Handled: Boolean;
        Skip: Boolean;
        FulfilledTok: Label 'fulfilled', Locked = true, Comment = 'Do not translate!';
    begin
        SpfyIntegrationEvents.OnCheckIfSkipLine(OrderLine, Skip, Handled);
        if not Handled then
            Skip :=
                (LowerCase(JsonHelper.GetJText(OrderLine, 'fulfillment_status', false)) <> FulfilledTok) and
                (JsonHelper.GetJDecimal(OrderLine, 'fulfillable_quantity', true) = 0);
        exit(Skip);
    end;

    procedure PostOrder(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
    end;

    procedure LockTables()
    var
        NpEcDocument: Record "NPR NpEc Document";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
    begin
        //Always perform table locking in the same order to prevent deadlocks
        ShopifyAssignedID.LockTable();
        NpEcDocument.LockTable();
        SalesHeader.LockTable();
        SalesLine.LockTable();
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Order Mgt.(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy Order Mgt.");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterCopyFromItem', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterCopyFromItem, '', true, false)]
#endif
    local procedure CopyAdditionalDataFromItem(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine.Validate("Purchasing Code", Item."NPR Purchasing Code");
    end;
}
#endif