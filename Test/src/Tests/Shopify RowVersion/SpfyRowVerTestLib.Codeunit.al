codeunit 85279 "NPR Spfy RowVer Test Lib"
{
    // Fixture harness for the Shopify RowVersion flow tier: real rows, real detection entry points, real result tables (no mock seam exists).
    Access = Internal;
    SingleInstance = true;

    var
        _Seq: Integer;
        _SessionSeed: Integer;
        _FeatureIdTok: Label 'ShopifyRowVersionChangeDetection', Locked = true;
        _TaskListFeatureIdTok: Label 'ShopifyTaskList', Locked = true;
        _Seam: Codeunit "NPR Spfy RowVer Fail Seam";

    procedure ResetState()
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeQuarantine: Record "NPR Change Quarantine";
        SyncState: Record "NPR Spfy Sync State";
        DeletionLog: Record "NPR Spfy Deletion Log";
        ResyncRun: Record "NPR Spfy Resync Run";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        ChangeTracker.DeleteAll(false);
        ChangeQuarantine.DeleteAll(false);
        SyncState.DeleteAll(false);
        DeletionLog.DeleteAll(false);
        ResyncRun.DeleteAll(false);
        NcTask.DeleteAll(false);
        SpfyTask.DeleteAll(false);
        TagUpdateRequest.DeleteAll(false);
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearSendBoundary();
        SetTaskListFeatureEnabled(false);
        DeleteDetectionJobQueueEntries();
        // Every test codeunit in this suite calls ResetState() from its own Initialize(), so this is what
        // actually guarantees a seam left armed by a failed poison-row test (which does not delete its own
        // Item) is cleared before the NEXT test runs, whichever codeunit that test lives in.
        _Seam.Disarm();
    end;

    procedure DeleteDetectionJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        // ZERO Shopify JQ entries may exist during a run: detection and task processing happen ONLY via direct calls - a live JQ session would race the tests.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter(Status, '<>%1', JobQueueEntry.Status::"In Process");
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Change Detection");
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
        // The per-store "Shopify updates" NC-task processors (created by the login-time JQ refresher for every enabled store).
        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
        JobQueueEntry.SetFilter("Parameter String", '@*SPFY*');
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
        // Reset first: the parameter-string filter above stays applied otherwise and hides the task list processors.
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter(Status, '<>%1', JobQueueEntry.Status::"In Process");
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task Processor");
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;

    procedure SetTaskListFeatureEnabled(Enabled: Boolean)
    var
        Feature: Record "NPR Feature";
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        // Raw writes: every supported activation path is blocked by the hardcoded availability gate. Enabling also stamps the
        // migration as completed so engine cycles run; disabling clears it again, or the stamp leaks into later feature-off tests.
        if not Feature.Get(_TaskListFeatureIdTok) then begin
            Feature.Init();
            Feature.Id := CopyStr(_TaskListFeatureIdTok, 1, MaxStrLen(Feature.Id));
            Feature.Enabled := Enabled;
            Feature.Insert(false);
        end else
            if Feature.Enabled <> Enabled then begin
                Feature.Enabled := Enabled;
                Feature.Modify(false);
            end;
        if not ShopifySetup.Get() then
            exit;
        if Enabled then
            ShopifySetup."Task List Migration Status" := ShopifySetup."Task List Migration Status"::Completed
        else begin
            ShopifySetup."Task List Migration Status" := ShopifySetup."Task List Migration Status"::NotStarted;
            ShopifySetup."Task List Migr. Started At" := 0DT;
        end;
        ShopifySetup.Modify(false);
    end;

    procedure TaskListFeatureId(): Text[50]
    begin
        exit(CopyStr(_TaskListFeatureIdTok, 1, 50));
    end;

    local procedure TaskListQueueActive(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        // Read the persisted state on every call: this library is SingleInstance, so a cached flag would outlive ResetState and drift from the database.
        Feature.SetLoadFields(Enabled);
        if not Feature.Get(_TaskListFeatureIdTok) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure NextCode(Prefix: Text; MaxLen: Integer): Code[20]
    begin
        if _SessionSeed = 0 then begin
            Randomize();
            _SessionSeed := Random(899) + 100;
        end;
        _Seq += 1;
        exit(CopyStr(Prefix + Format(_SessionSeed) + 'X' + Format(_Seq), 1, MaxLen));
    end;

    procedure SetFeatureEnabled(Enabled: Boolean)
    var
        Feature: Record "NPR Feature";
    begin
        // Direct write bypasses the validate guard AND the app's SetFeatureEnabled post-enable side effects; the JQ delete after is defensive.
        if not Feature.Get(_FeatureIdTok) then begin
            Feature.Init();
            Feature.Id := CopyStr(_FeatureIdTok, 1, MaxStrLen(Feature.Id));
            Feature.Enabled := Enabled;
            Feature.Insert(false);
            exit;
        end;
        if Feature.Enabled = Enabled then
            exit;
        Feature.Enabled := Enabled;
        Feature.Modify(false);
        DeleteDetectionJobQueueEntries();
    end;

    procedure ConsumeConfirm()
    begin
        // Guarantees a declared ConfirmHandler runs at least once: the app's own Confirm sites are GuiAllowed-gated, and an uncalled handler fails the test.
        if Confirm('Consuming the ConfirmHandler.') then;
    end;

    procedure ConsumeMessage()
    begin
        Message('Consuming the MessageHandler.');
    end;

    procedure FeatureId(): Text[50]
    begin
        exit(CopyStr(_FeatureIdTok, 1, 50));
    end;

    procedure EnsureIntegrationEnabled()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not ShopifySetup.Get() then begin
            ShopifySetup.Init();
            ShopifySetup.Insert(true);
        end;
        ShopifySetup."Enable Integration" := true;
        ShopifySetup.Modify(false);
        // The integration mgt codeunit is SingleInstance and caches the setup row for the session.
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    procedure CreateStore(ItemsEnabled: Boolean; InventoryEnabled: Boolean; PricesEnabled: Boolean; SalesOrdersEnabled: Boolean; VouchersEnabled: Boolean): Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Direct writes skip the heavy OnValidate side effects; codes are unique per call because the SingleInstance integration mgt caches per-store reads (never flip area flags on an existing store).
        ShopifyStore.Init();
        ShopifyStore.Code := NextCode('S', MaxStrLen(ShopifyStore.Code));
        ShopifyStore.Enabled := true;
        ShopifyStore."Item List Integration" := ItemsEnabled;
        ShopifyStore."Send Inventory Updates" := InventoryEnabled;
        ShopifyStore."Do Not Sync. Sales Prices" := not PricesEnabled;
        ShopifyStore."Sales Order Integration" := SalesOrdersEnabled;
        ShopifyStore."Retail Voucher Integration" := VouchersEnabled;
        ShopifyStore.Insert(false);
        exit(ShopifyStore.Code);
    end;

    // Safe at any point: the SetRereadSetup() below drops the SingleInstance integration mgt's cached setup and store rows, so a mid-test flip cannot be read stale.
    procedure DisableStore(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Enabled := false;
        ShopifyStore.Modify(false);
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    procedure EnableStore(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Enabled := true;
        ShopifyStore.Modify(false);
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    procedure DisableIntegration()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not ShopifySetup.Get() then begin
            ShopifySetup.Init();
            ShopifySetup.Insert(true);
        end;
        ShopifySetup."Enable Integration" := false;
        ShopifySetup.Modify(false);
        // The integration mgt codeunit is SingleInstance and caches the setup row for the session.
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    procedure CreateItem(var Item: Record Item)
    begin
        Item.Init();
        Item."No." := NextCode('IT', MaxStrLen(Item."No."));
        Item.Type := Item.Type::Inventory;
        Item.Insert(false);
    end;

    procedure CreateItemLink(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemNo: Code[20]; StoreCode: Code[20]; SyncToStore: Boolean; SyncEnabled: Boolean)
    begin
        SpfyStoreItemLink.Init();
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := '';
        SpfyStoreItemLink."Shopify Store Code" := StoreCode;
        SpfyStoreItemLink."Sync. to this Store" := SyncToStore;
        SpfyStoreItemLink."Synchronization Is Enabled" := SyncEnabled;
        SpfyStoreItemLink.Insert(false);
    end;

    procedure CreateSyncedItemWithLink(var Item: Record Item; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; StoreCode: Code[20])
    begin
        CreateItem(Item);
        CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, true, true);
    end;

    procedure CreateItemVariant(var ItemVariant: Record "Item Variant"; ItemNo: Code[20])
    begin
        ItemVariant.Init();
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := NextCode('V', MaxStrLen(ItemVariant.Code));
        ItemVariant."NPR Variety 1 Value" := 'V';   // at least one variety value is required by the variant send gate
        ItemVariant.Insert(false);
    end;

    procedure CreateVariantModif(var SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."; ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; NotAvailable: Boolean)
    begin
        SpfyItemVariantModif.Init();
        SpfyItemVariantModif."Item No." := ItemNo;
        SpfyItemVariantModif."Variant Code" := VariantCode;
        SpfyItemVariantModif."Shopify Store Code" := StoreCode;
        SpfyItemVariantModif."Not Available" := NotAvailable;
        SpfyItemVariantModif.Insert(false);
    end;

    procedure AssignEntryID(BCRecID: RecordId; ShopifyId: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(BCRecID, "NPR Spfy ID Type"::"Entry ID", ShopifyId, false);
    end;

    procedure VariantLinkRecordId(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]): RecordId
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := StoreCode;
        exit(SpfyStoreItemVariantLink.RecordId());
    end;

    procedure CreateItemCategory(Description: Text[100]): Code[20]
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.Init();
        ItemCategory.Code := NextCode('CAT', MaxStrLen(ItemCategory.Code));
        ItemCategory.Description := Description;
        ItemCategory.Insert(false);
        exit(ItemCategory.Code);
    end;

    procedure CreateCustomerWithLink(var Customer: Record Customer; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; StoreCode: Code[20]; SyncToStore: Boolean; SyncEnabled: Boolean)
    begin
        Customer.Init();
        Customer."No." := NextCode('CU', MaxStrLen(Customer."No."));
        Customer.Name := 'Test Customer';
        Customer."E-Mail" := 'test@example.com';
        Customer.Insert(false);

        SpfyStoreCustomerLink.Init();
        SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
        SpfyStoreCustomerLink."No." := Customer."No.";
        SpfyStoreCustomerLink."Shopify Store Code" := StoreCode;
        SpfyStoreCustomerLink."First Name" := 'First';
        SpfyStoreCustomerLink."Last Name" := 'Last';
        SpfyStoreCustomerLink."E-Mail" := Customer."E-Mail";
        SpfyStoreCustomerLink."Sync. to this Store" := SyncToStore;
        SpfyStoreCustomerLink."Synchronization Is Enabled" := SyncEnabled;
        SpfyStoreCustomerLink.Insert(false);
    end;

    procedure CreateMetafield(var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; OwnerTableNo: Integer; OwnerRecordId: RecordId; MetafieldValue: Text)
    begin
        SpfyEntityMetafield.Init();
        SpfyEntityMetafield."Entry No." := 0;
        SpfyEntityMetafield."Table No." := OwnerTableNo;
        SpfyEntityMetafield."BC Record ID" := OwnerRecordId;
        if OwnerTableNo = Database::"NPR Spfy Store-Customer Link" then
            SpfyEntityMetafield."Owner Type" := SpfyEntityMetafield."Owner Type"::CUSTOMER
        else
            SpfyEntityMetafield."Owner Type" := SpfyEntityMetafield."Owner Type"::PRODUCT;
        SpfyEntityMetafield."Metafield ID" := CopyStr('gid://mf/' + Format(_Seq + 1), 1, MaxStrLen(SpfyEntityMetafield."Metafield ID"));
        SpfyEntityMetafield."Metafield Key" := NextCode('K', 20);
        SpfyEntityMetafield.SetMetafieldValue(MetafieldValue);
        SpfyEntityMetafield.Insert(false);
    end;

    procedure CreateVoucherFixture(var Voucher: Record "NPR NpRv Voucher"; StoreCode: Code[20]; SyncedToShopify: Boolean)
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        VoucherType.Init();
        VoucherType.Code := NextCode('VT', MaxStrLen(VoucherType.Code));
        VoucherType."Integrate with Shopify" := true;
        VoucherType.Insert(false);
        SpfyAssignedIDMgt.AssignShopifyID(VoucherType.RecordId(), "NPR Spfy ID Type"::"Store Code", CopyStr(StoreCode, 1, 30), false);

        Voucher.Init();
        Voucher."No." := NextCode('VO', MaxStrLen(Voucher."No."));
        Voucher."Voucher Type" := VoucherType.Code;
        Voucher."Ending Date" := CreateDateTime(CalcDate('<+1M>', WorkDate()), 120000T);
        Voucher.Insert(false);
        if SyncedToShopify then
            AssignEntryID(Voucher.RecordId(), CopyStr('gid://gc/' + Voucher."No.", 1, 30));
    end;

    procedure CreateLocationWithLink(StoreCode: Code[20]; var ShopifyLocationId: Text[30]) LocationCode: Code[10]
    var
        Location: Record Location;
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
    begin
        Location.Init();
        Location.Code := CopyStr(NextCode('L', 10), 1, MaxStrLen(Location.Code));
        Location.Insert(false);
        LocationCode := Location.Code;

        SpfyStoreLocationLink.Init();
        SpfyStoreLocationLink."Location Code" := LocationCode;
        SpfyStoreLocationLink."Shopify Store Code" := StoreCode;
        SpfyStoreLocationLink."Line No." := 10000;
        SpfyStoreLocationLink.Insert(false);
        ShopifyLocationId := CopyStr('gid://loc/' + LocationCode, 1, 30);
        AssignEntryID(SpfyStoreLocationLink.RecordId(), ShopifyLocationId);
    end;

    procedure GetInventoryLevel(var SpfyInventoryLevel: Record "NPR Spfy Inventory Level"; StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    begin
        exit(SpfyInventoryLevel.Get(StoreCode, ShopifyLocationId, ItemNo, VariantCode));
    end;

    procedure InventoryLevelCount(ItemNo: Code[20]): Integer
    var
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
    begin
        SpfyInventoryLevel.SetCurrentKey("Item No.", "Variant Code");
        SpfyInventoryLevel.SetRange("Item No.", ItemNo);
        exit(SpfyInventoryLevel.Count());
    end;

    procedure CreateSalesOrderLine(var SalesLine: Record "Sales Line"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; OutstandingQtyBase: Decimal)
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := NextCode('SO', MaxStrLen(SalesLine."Document No."));
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := ItemNo;
        SalesLine."Variant Code" := VariantCode;
        SalesLine."Location Code" := LocationCode;
        SalesLine."Outstanding Qty. (Base)" := OutstandingQtyBase;
        SalesLine.Insert(false);
    end;

    procedure SetStoreIncludeTransferOrders(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Must run before the first IsEnabled read for this store (the SingleInstance mgt caches the row).
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Include Transfer Orders" := ShopifyStore."Include Transfer Orders"::All;
        ShopifyStore.Modify(false);
    end;

    procedure CreateTransferLine(var TransferLine: Record "Transfer Line"; ItemNo: Code[20]; VariantCode: Code[10]; FromLocationCode: Code[10]; ToLocationCode: Code[10]; OutstandingQtyBase: Decimal; QtyInTransitBase: Decimal)
    begin
        TransferLine.Init();
        TransferLine."Document No." := NextCode('TO', MaxStrLen(TransferLine."Document No."));
        TransferLine."Line No." := 10000;
        TransferLine."Item No." := ItemNo;
        TransferLine."Variant Code" := VariantCode;
        TransferLine."Transfer-from Code" := FromLocationCode;
        TransferLine."Transfer-to Code" := ToLocationCode;
        TransferLine."Outstanding Qty. (Base)" := OutstandingQtyBase;
        TransferLine."Qty. in Transit (Base)" := QtyInTransitBase;
        TransferLine."Derived From Line No." := 0;
        TransferLine.Insert(false);
    end;

    procedure InsertItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; Qty: Decimal)
    var
        LastItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Init();
        if LastItemLedgerEntry.FindLast() then
            ItemLedgerEntry."Entry No." := LastItemLedgerEntry."Entry No." + 1
        else
            ItemLedgerEntry."Entry No." := 1;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Variant Code" := VariantCode;
        ItemLedgerEntry."Location Code" := LocationCode;
        ItemLedgerEntry.Quantity := Qty;
        ItemLedgerEntry."Posting Date" := WorkDate();
        ItemLedgerEntry.Open := true;
        ItemLedgerEntry.Insert(false);
    end;

    procedure CreateItemPrice(var ItemPrice: Record "NPR Spfy Item Price"; ItemNo: Code[20]; StoreCode: Code[20]; UnitPrice: Decimal; StartingDate: Date)
    begin
        ItemPrice.Init();
        ItemPrice."Shopify Store Code" := StoreCode;
        ItemPrice."Item No." := ItemNo;
        ItemPrice."Variant Code" := '';
        ItemPrice."Unit Price" := UnitPrice;
        ItemPrice."Starting Date" := StartingDate;
        ItemPrice.Insert(false);
    end;

    procedure RegisterEnabledTables()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
    begin
        SpfyChangeTrackerMgt.RegisterEnabledTables();
    end;

    procedure RegisterTable(TableNo: Integer)
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        ChangeTrackerMgt.RegisterTable("NPR Integration Type"::Shopify, TableNo);
    end;

    procedure SetMark(TableNo: Integer; Mark: BigInteger)
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo);
        ChangeTracker."Last Row Version" := Mark;
        ChangeTracker.Modify(false);
    end;

    procedure GetMark(TableNo: Integer): BigInteger
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        if not ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo) then
            exit(-1);
        exit(ChangeTracker."Last Row Version");
    end;

    procedure TrackerExists(TableNo: Integer): Boolean
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        exit(ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo));
    end;

    procedure TrackerProcessingOrder(TableNo: Integer): Integer
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo);
        exit(ChangeTracker."Processing Order");
    end;

    procedure TrackerRowCount(TableNo: Integer): Integer
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        ChangeTracker.SetRange("Table No.", TableNo);
        exit(ChangeTracker.Count());
    end;

    procedure CurrentMaxRowVersion(TableNo: Integer): BigInteger
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        exit(ChangeTrackerMgt.CurrentMaxRowVersion(TableNo));
    end;

    procedure RunDetection()
    var
        SpfyChangeDetection: Codeunit "NPR Spfy Change Detection";
    begin
        SpfyChangeDetection.RunDetection();
    end;

    procedure PollTable(TableNo: Integer)
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyChangeDetection: Codeunit "NPR Spfy Change Detection";
    begin
        // PollSourceTable requires committed data (its real caller commits before every poll shell and the poll commits mid-loop); polling this transaction's own fresh rows failed without it.
        Commit();
        ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo);
        SpfyChangeDetection.PollSourceTable(ChangeTracker);
    end;

    procedure DispatchModify(RecVariant: Variant): Boolean
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeMgt.GetRecordRef(RecVariant, RecRef);
        DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(RecRef.Number()), "NPR Spfy Change Type"::Modify, RecRef.Number(), RecRef.RecordId(), ChangeTrackerMgt.SystemIdOf(RecRef));
        exit(SpfyChangeDispatcher.Dispatch(DetectedChange));
    end;

    procedure Facet(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]; FacetKey: Text): Text
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        Baseline: JsonObject;
    begin
        SpfySyncStateMgt.GetBaseline(TableNo, EntitySystemId, StoreCode, Baseline);
        exit(SpfySyncStateMgt.Facet(Baseline, FacetKey));
    end;

    procedure HasBaseline(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]): Boolean
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        exit(SpfySyncStateMgt.HasBaseline(TableNo, EntitySystemId, StoreCode));
    end;

    procedure DumpDetectionState(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        ChangeTracker: Record "NPR Change Tracker";
        ChangeQuarantine: Record "NPR Change Quarantine";
        FreshLink: Record "NPR Spfy Store-Item Link";
        ShopifyStore: Record "NPR Spfy Store";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Builder: TextBuilder;
    begin
        // Failure forensics: dumps every layer a lost product task could hide in, so one red run pinpoints the mechanism.
        Builder.Append('TASKS:');
        if NcTask.FindSet() then
            repeat
                Builder.Append(StrSubstNo(' [#%1 tbl=%2 type=%3 val=%4 store=%5 done=%6]', NcTask."Entry No.", NcTask."Table No.", NcTask.Type, NcTask."Record Value", NcTask."Store Code", NcTask.Processed));
            until NcTask.Next() = 0
        else
            Builder.Append(' <none>');
        if TaskListQueueActive() then begin
            Builder.Append(' | SPFYTASKS:');
            if SpfyTask.FindSet() then
                repeat
                    Builder.Append(StrSubstNo(' [#%1 tbl=%2 type=%3 val=%4 store=%5 state=%6]', SpfyTask."Entry No.", SpfyTask."Table No.", SpfyTask.Type, SpfyTask."Record Value", SpfyTask."Store Code", SpfyTask.State));
                until SpfyTask.Next() = 0
            else
                Builder.Append(' <none>');
        end;
        if ChangeTracker.Get("NPR Integration Type"::Shopify, Database::"NPR Spfy Store-Item Link") then
            Builder.Append(StrSubstNo(' | TRACKER: mark=%1 max=%2 fails=%3 failingRV=%4', ChangeTracker."Last Row Version", CurrentMaxRowVersion(Database::"NPR Spfy Store-Item Link"), ChangeTracker."Consecutive Failures", ChangeTracker."Failing Row Version"))
        else
            Builder.Append(' | TRACKER: <missing>');
        Builder.Append(StrSubstNo(' | QUAR: %1', ChangeQuarantine.Count()));
        if FreshLink.GetBySystemId(SpfyStoreItemLink.SystemId) then
            Builder.Append(StrSubstNo(' | LINK: name=%1 sync=%2 enab=%3 hasBase=%4 hashEq=%5 itemsGate=%6',
                FreshLink."Shopify Name", FreshLink."Sync. to this Store", FreshLink."Synchronization Is Enabled",
                HasBaseline(Database::"NPR Spfy Store-Item Link", FreshLink.SystemId, FreshLink."Shopify Store Code"),
                SpfySyncStateMgt.StoreItemLinkPayloadHash(FreshLink) = Facet(Database::"NPR Spfy Store-Item Link", FreshLink.SystemId, FreshLink."Shopify Store Code", 'storeItemLinkHash'),
                SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, FreshLink."Shopify Store Code")))
        else
            Builder.Append(' | LINK: GetBySystemId FAILED');
        if ShopifyStore.Get(SpfyStoreItemLink."Shopify Store Code") then
            Builder.Append(StrSubstNo(' | STORE: enabled=%1 items=%2', ShopifyStore.Enabled, ShopifyStore."Item List Integration"))
        else
            Builder.Append(' | STORE: <missing>');
        if ShopifySetup.Get() then
            Builder.Append(StrSubstNo(' | SETUP: enabled=%1', ShopifySetup."Enable Integration"))
        else
            Builder.Append(' | SETUP: <missing>');
        exit(Builder.ToText());
    end;

    procedure TaskCount(): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCount());
        exit(SpfyTask.Count());
    end;

    procedure TaskCount(TableNo: Integer): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCount(TableNo));
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.Count());
    end;

    procedure TaskCountTyped(TableNo: Integer; TaskType: Option): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCountTyped(TableNo, TaskType));
        if TaskType > "NPR Spfy Task Op"::Delete.AsInteger() then
            exit(0);   // Rename has no counterpart in the new queue
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange(Type, Enum::"NPR Spfy Task Op".FromInteger(TaskType));
        exit(SpfyTask.Count());
    end;

    procedure TaskCountForValue(TableNo: Integer; RecordValue: Text): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCountForValue(TableNo, RecordValue));
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange("Record Value", CopyStr(RecordValue, 1, MaxStrLen(SpfyTask."Record Value")));
        exit(SpfyTask.Count());
    end;

    procedure TaskCountForStore(TableNo: Integer; StoreCode: Code[20]): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCountForStore(TableNo, StoreCode));
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange("Store Code", StoreCode);
        exit(SpfyTask.Count());
    end;

    procedure TaskCountForRecordId(TableNo: Integer; RecId: RecordId): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCountForRecordId(TableNo, RecId));
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange("Record ID", RecId);
        exit(SpfyTask.Count());
    end;

    procedure TaskCountByStatus(TableNo: Integer; TaskType: Option; Unprocessed: Boolean): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(NcTaskCountByStatus(TableNo, TaskType, Unprocessed));
        if TaskType > "NPR Spfy Task Op"::Delete.AsInteger() then
            exit(0);
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange(Type, Enum::"NPR Spfy Task Op".FromInteger(TaskType));
        if Unprocessed then
            SpfyTask.SetFilter(State, '<>%1', SpfyTask.State::Completed)
        else
            SpfyTask.SetRange(State, SpfyTask.State::Completed);
        exit(SpfyTask.Count());
    end;

    // Keeps its NcTask-typed signature in both modes: the caller only reads the identity fields, which the new queue mirrors one to one.
    procedure FindLastTask(TableNo: Integer; var NcTask: Record "NPR Nc Task"): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then
            exit(FindLastNcTask(TableNo, NcTask));
        SpfyTask.SetRange("Table No.", TableNo);
        if not SpfyTask.FindLast() then
            exit(false);
        NcTask.Init();
        NcTask."Entry No." := SpfyTask."Entry No.";
        NcTask."Table No." := SpfyTask."Table No.";
        NcTask.Type := SpfyTask.Type.AsInteger();
        NcTask."Record ID" := SpfyTask."Record ID";
        NcTask."Record Value" := SpfyTask."Record Value";
        NcTask."Store Code" := SpfyTask."Store Code";
        NcTask."Not Before Date-Time" := SpfyTask."Not Before Date-Time";
        NcTask."Log Date" := SpfyTask."Log Date";
        NcTask.Processed := SpfyTask.State = SpfyTask.State::Completed;
        exit(true);
    end;

    procedure MarkAllTasksProcessed()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not TaskListQueueActive() then begin
            MarkAllNcTasksProcessed();
            exit;
        end;
        SpfyTask.SetFilter(State, '<>%1', SpfyTask.State::Completed);
        if not SpfyTask.IsEmpty() then
            SpfyTask.ModifyAll(State, SpfyTask.State::Completed, false);
    end;

    // Mode-agnostic: the outbox stamps exactly one of the two provenance fields, so following the populated one needs no flag branch.
    procedure TaskLinkedToDeletionLog(DeletionLogEntryNo: BigInteger): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not DeletionLog.Get(DeletionLogEntryNo) then
            exit(false);
        if DeletionLog."NC Task Entry No." <> 0 then
            exit(NcTaskExists(DeletionLog."NC Task Entry No."));
        if DeletionLog."Spfy Task Entry No." <> 0 then
            exit(SpfyTask.Get(DeletionLog."Spfy Task Entry No."));
        exit(false);
    end;

    procedure TaskIsDefused(DeletionLogEntryNo: BigInteger): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not DeletionLog.Get(DeletionLogEntryNo) then
            exit(false);
        if DeletionLog."NC Task Entry No." <> 0 then
            exit(NcTaskIsDefused(DeletionLog."NC Task Entry No."));
        if DeletionLog."Spfy Task Entry No." = 0 then
            exit(false);
        if not SpfyTask.Get(DeletionLog."Spfy Task Entry No.") then
            exit(false);
        exit(SpfyTask.State = SpfyTask.State::Completed);
    end;

    #region NC Task coexistence — DELETE at NC phase-out
    local procedure NcTaskCount(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        exit(NcTask.Count());
    end;

    local procedure NcTaskCount(TableNo: Integer): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        exit(NcTask.Count());
    end;

    local procedure NcTaskCountTyped(TableNo: Integer; TaskType: Option): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange(Type, TaskType);
        exit(NcTask.Count());
    end;

    local procedure NcTaskCountForValue(TableNo: Integer; RecordValue: Text): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange("Record Value", CopyStr(RecordValue, 1, MaxStrLen(NcTask."Record Value")));
        exit(NcTask.Count());
    end;

    local procedure NcTaskCountForStore(TableNo: Integer; StoreCode: Code[20]): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange("Store Code", StoreCode);
        exit(NcTask.Count());
    end;

    local procedure NcTaskCountForRecordId(TableNo: Integer; RecId: RecordId): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange("Record ID", RecId);
        exit(NcTask.Count());
    end;

    local procedure NcTaskCountByStatus(TableNo: Integer; TaskType: Option; Unprocessed: Boolean): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange(Type, TaskType);
        NcTask.SetRange(Processed, not Unprocessed);
        exit(NcTask.Count());
    end;

    local procedure FindLastNcTask(TableNo: Integer; var NcTask: Record "NPR Nc Task"): Boolean
    begin
        NcTask.Reset();
        NcTask.SetRange("Table No.", TableNo);
        exit(NcTask.FindLast());
    end;

    local procedure MarkAllNcTasksProcessed()
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange(Processed, false);
        if not NcTask.IsEmpty() then
            NcTask.ModifyAll(Processed, true, false);
    end;

    local procedure NcTaskExists(NcTaskEntryNo: BigInteger): Boolean
    var
        NcTask: Record "NPR Nc Task";
    begin
        exit(NcTask.Get(NcTaskEntryNo));
    end;

    local procedure NcTaskIsDefused(NcTaskEntryNo: BigInteger): Boolean
    var
        NcTask: Record "NPR Nc Task";
    begin
        if not NcTask.Get(NcTaskEntryNo) then
            exit(false);
        exit(NcTask.Processed and not NcTask."Process Error");
    end;
    #endregion

    procedure InsertPendingDelete(EntityTableNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; CustomerNo: Code[20]; StoreCode: Code[20]; ShopifyId: Text[30]) EntryNo: BigInteger
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.Init();
        DeletionLog."Table No." := EntityTableNo;
        DeletionLog."Item No." := ItemNo;
        DeletionLog."Variant Code" := VariantCode;
        DeletionLog."Customer No." := CustomerNo;
        DeletionLog."Entity System Id" := CreateGuid();
        DeletionLog."Shopify Store Code" := StoreCode;
        DeletionLog."Shopify ID Type" := "NPR Spfy ID Type"::"Entry ID";
        DeletionLog."Shopify ID" := ShopifyId;
        DeletionLog.Status := DeletionLog.Status::Pending;
        DeletionLog.Insert(true);
        exit(DeletionLog."Entry No.");
    end;

    procedure DrainDeleteRow(EntryNo: BigInteger)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        DrainRowRunner: Codeunit "NPR Spfy Drain Row Runner";
    begin
        DeletionLog.Get(EntryNo);
        DrainRowRunner.Run(DeletionLog);
    end;

    procedure DeletionRowCount(EntityTableNo: Integer; Status: Option): Integer
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.SetRange("Table No.", EntityTableNo);
        DeletionLog.SetRange(Status, Status);
        exit(DeletionLog.Count());
    end;

    procedure TotalDeletionRowCount(): Integer
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        exit(DeletionLog.Count());
    end;

    procedure InsertActiveResyncRun(): BigInteger
    var
        ResyncRun: Record "NPR Spfy Resync Run";
    begin
        // A fresh-heartbeat Running row makes IsResyncActive() true so detection defers the whole cycle.
        ResyncRun.Init();
        ResyncRun."Entry No." := 0;
        ResyncRun.Scope := ResyncRun.Scope::"Full Resync";
        ResyncRun.Status := ResyncRun.Status::Running;
        ResyncRun."Started At" := CurrentDateTime();
        ResyncRun."Heartbeat At" := CurrentDateTime();
        ResyncRun.Insert(true);
        exit(ResyncRun."Entry No.");
    end;

    procedure CompleteActiveResyncRuns()
    var
        ResyncRun: Record "NPR Spfy Resync Run";
    begin
        ResyncRun.SetRange(Status, ResyncRun.Status::Running);
        if ResyncRun.FindSet(true) then
            repeat
                ResyncRun.Status := ResyncRun.Status::Completed;
                ResyncRun."Completed At" := CurrentDateTime();
                ResyncRun.Modify(false);
            until ResyncRun.Next() = 0;
    end;

    procedure RunBulkResync(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
    begin
        SpfyResyncMgt.StartRun(ResyncRun);
        SpfyResyncMgt.DispatchScope(ResyncRun);
    end;

    procedure RunSeedWorker(BaselinesOnly: Boolean)
    var
        SeedWorker: Codeunit "NPR Spfy Sync St. Seed Worker";
    begin
        SeedWorker.SetBaselinesOnly(BaselinesOnly);
        SeedWorker.SetShowProgress(false);
        SeedWorker.Run();
    end;
}
