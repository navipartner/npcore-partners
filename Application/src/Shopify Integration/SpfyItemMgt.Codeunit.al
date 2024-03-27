#if not BC17
codeunit 6184812 "NPR Spfy Item Mgt."
{
    Access = Internal;
    TableNo = "NPR Data Log Record";

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";

    procedure ProcessDataLogRecord(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    begin
        case DataLogEntry."Table ID" of
            Database::Item:
                begin
                    TaskCreated := ProcessItem(DataLogEntry);
                end;

            Database::"Item Variant":
                begin
                    if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) then
                        exit;
                    TaskCreated := ProcessItemVariant(DataLogEntry);
                end;

            Database::"Stockkeeping Unit":
                begin
                    if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels") then
                        exit;
                    ProcessStockkeepingUnit(DataLogEntry);
                    TaskCreated := false;
                end;

            Database::"NPR Spfy Store-Item Link":
                begin
                    TaskCreated := ProcessStoreItemLink(DataLogEntry);
                end;

            Database::"NPR Spfy Inventory Level":
                begin
                    if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels") then
                        exit;
                    TaskCreated := UpdateShopifyInventory(DataLogEntry);
                end;

            Database::"Item Reference":
                begin
                    if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) then
                        exit;
                    TaskCreated := ProcessItemReference(DataLogEntry);
                end;
            else
                exit;
        end;
        Commit();
    end;

    local procedure ProcessItem(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        Item: Record Item;
        xItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
        CostIsUpdated: Boolean;
        ProcessRec: Boolean;
        xRecRestored: Boolean;
    begin
        if ((DataLogEntry."Table ID" = Database::Item) and (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete)) or
           (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename)
        then
            exit;  //Renames and deletes of Shopify syncronized items are not allowed; Renames of related tables are not processed

        if not (SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) or SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels")) then
            exit;

        ProcessRec := FindItem(DataLogEntry, Item);
        if not ProcessRec and (DataLogEntry."Table ID" = Database::Item) and
           (DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Modify, DataLogEntry."Type of Change"::Delete])
        then begin
            xRecRestored := DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef);
            if xRecRestored then begin
                RecRef.SetTable(xItem);
                ProcessRec := TestRequiredFields(xItem, false);
            end;
        end;
        if not ProcessRec then
            exit;

        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(Item."No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        if not xRecRestored and (DataLogEntry."Table ID" = Database::Item) then begin
            xRecRestored := DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef);
            if xRecRestored then
                RecRef.SetTable(xItem);
        end;
        if not xRecRestored then
            xItem := Item
        else
            if not Item.Find() then
                Item := xItem;

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) then begin
            CostIsUpdated := Item."Last Direct Cost" <> xItem."Last Direct Cost";

            repeat
                TaskCreated := ScheduleItemSync(DataLogEntry, Item, SpfyStoreItemLink) or TaskCreated;
                if (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert) or
                   ((DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify) and CostIsUpdated)
                then
                    TaskCreated := ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;
            until SpfyStoreItemLink.Next() = 0;
        end;

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels") then begin
            Commit();
            SpfyStoreItemLink.FindSet();
            repeat
                UpdateInventoryLevels(SpfyStoreItemLink);
            until SpfyStoreItemLink.Next() = 0;
        end;
    end;

    local procedure ScheduleItemSync(DataLogEntry: Record "NPR Data Log Record"; Item: Record Item; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        clear(NcTask);
        case true of
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify:
                begin
                    case true of
                        not SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled":
                            exit;
                        SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Insert;
                        not SpfyStoreItemLink."Sync. to this Store" and SpfyStoreItemLink."Synchronization Is Enabled":
                            NcTask.Type := NcTask.Type::Delete;
                        else
                            NcTask.Type := NcTask.Type::Modify;
                    end;
                end;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        RecRef.GetTable(Item);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, Item."No.", NcTask.Type, NcTask));
    end;

    local procedure ProcessItemVariant(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
        ProcessRec: Boolean;
    begin
        if DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename then
            exit;  //Renames are not supported
        ProcessRec := FindItemVariant(DataLogEntry, ItemVariant);
        if not ProcessRec and (DataLogEntry."Table ID" = Database::"Item Variant") and
           (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete)
        then
            if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef) then begin
                RecRef.SetTable(ItemVariant);
                if Item.Get(ItemVariant."Item No.") then
                    ProcessRec := TestRequiredFields(Item, false);
            end;
        if not ProcessRec then
            exit;

        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(ItemVariant."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        VariantSku := GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code);

        clear(NcTask);
        case true of
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify:
                NcTask.Type := NcTask.Type::Modify;
            DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        repeat
            RecRef.GetTable(ItemVariant);
            TaskCreated := SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, VariantSku, NcTask.Type, NcTask) or TaskCreated;
        until SpfyStoreItemLink.Next() = 0;
    end;

    local procedure ProcessItemReference(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    begin
        DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;
        TaskCreated := ProcessItem(DataLogEntry) or ProcessItemVariant(DataLogEntry);
    end;

    local procedure ProcessStoreItemLink(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        RecRef: RecordRef;
    begin
        if DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;

        if not (SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) or SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels")) then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreItemLink);
        if not SpfyStoreItemLink.Find() or not Item.Get(SpfyStoreItemLink."Item No.") then
            exit;
        if not (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled") then
            exit;
        SpfyStoreItemLink.CalcFields("Store Integration Is Enabled");
        if not SpfyStoreItemLink."Store Integration Is Enabled" then
            exit;
        if not TestRequiredFields(Item, false) then
            exit;

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items) then begin
            DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;
            TaskCreated := ScheduleItemSync(DataLogEntry, Item, SpfyStoreItemLink);
            if SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled" then
                TaskCreated := ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;
        end;

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels") then begin
            Commit();
            UpdateInventoryLevels(SpfyStoreItemLink);
        end;
    end;

    local procedure ProcessStockkeepingUnit(DataLogEntry: Record "NPR Data Log Record")
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        xSKU: Record "Stockkeeping Unit";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
        ProcessRec: Boolean;
        xRecRestored: Boolean;
    begin
        if DataLogEntry."Table ID" <> Database::"Stockkeeping Unit" then
            exit;
        if DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename then
            exit;  //Renames are not supported

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SKU);
        ProcessRec := SKU.Find();
        if not ProcessRec and (DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Modify, DataLogEntry."Type of Change"::Delete]) then begin
            xRecRestored := DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef);
            if xRecRestored then begin
                RecRef.SetTable(xSKU);
                ProcessRec := true;
            end;
        end;
        if not ProcessRec then
            exit;

        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(SKU."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        if not xRecRestored then begin
            xRecRestored := DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef);
            if xRecRestored then
                RecRef.SetTable(xSKU);
        end else
            xSKU := SKU;

        if not SKU.Find() then begin
            SKU := xSKU;
            SKU."NPR Spfy Safety Stock Quantity" := 0;
        end;

        if SKU."NPR Spfy Safety Stock Quantity" = xSKU."NPR Spfy Safety Stock Quantity" then
            exit;
        if not Item.Get(SKU."Item No.") then
            exit;
        if not TestRequiredFields(Item, false) then
            exit;

        SpfyStoreItemLink.FindSet();
        repeat
            UpdateInventoryLevels(SpfyStoreItemLink);
        until SpfyStoreItemLink.Next() = 0;
    end;

    local procedure UpdateShopifyInventory(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
    begin
        if not FindInventoryLevelItem(DataLogEntry, InventoryLevel) then
            exit;
        if not SpfyIntegrationMgt.ShopifyStoreIsEnabled(InventoryLevel."Shopify Store Code") then
            exit;

        VariantSku := GetProductVariantSku(InventoryLevel."Item No.", InventoryLevel."Variant Code");

        RecRef.GetTable(InventoryLevel);
        exit(SpfyScheduleSend.InitNcTask(InventoryLevel."Shopify Store Code", RecRef, VariantSku, NcTask.Type::Modify, InventoryLevel."Last Updated at", NcTask));
    end;

    local procedure ScheduleCostSync(ShopifyStoreCode: Code[20]; Item: Record Item): Boolean
    var
        InventoryBuffer: Record "Inventory Buffer";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        InventoryBuffer."Item No." := Item."No.";
        RecRef.GetTable(InventoryBuffer);
        exit(SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, InventoryBuffer."Item No.", NcTask.Type::Modify, NcTask));
    end;

    procedure GetProductVariantSku(ItemNo: Code[20]; VariantCode: Code[10]): Text
    begin
        if VariantCode = '' then
            exit(ItemNo);
        exit(StrSubstNo('%1_%2', ItemNo, VariantCode));
    end;

    local procedure FindItem(DataLogEntry: Record "NPR Data Log Record"; var Item: Record Item): Boolean
    var
        ItemReference: Record "Item Reference";
        RecRef: RecordRef;
    begin
        Clear(Item);
        case DataLogEntry."Table ID" of
            Database::Item:
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(Item);
                    if not Item.Find() then
                        exit(false);
                end;
            Database::"Item Reference":
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(ItemReference);
                    if not ItemReference.Find() then
                        exit(false);

                    if ItemReference."Variant Code" <> '' then
                        exit(false);
                    if not IsValidItemReference(ItemReference) then
                        exit(false);
                    if not Item.Get(ItemReference."Item No.") then
                        exit(false);
                end;
            else
                exit(false)
        end;

        exit(TestRequiredFields(Item, false));
    end;

    local procedure FindItemVariant(DataLogEntry: Record "NPR Data Log Record"; var ItemVariant: Record "Item Variant"): Boolean
    var
        RecRef: RecordRef;
        ItemReference: Record "Item Reference";
    begin
        Clear(ItemVariant);
        case DataLogEntry."Table ID" of
            Database::"Item Variant":
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(ItemVariant);
                    if not ItemVariant.Find() then
                        exit(false);
                end;
            Database::"Item Reference":
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(ItemReference);
                    if not ItemReference.Find() then
                        exit(false);

                    if ItemReference."Variant Code" = '' then
                        exit(false);
                    if not IsValidItemReference(ItemReference) then
                        exit(false);

                    if not ItemVariant.Get(ItemReference."Item No.", ItemReference."Variant Code") then
                        exit(false);
                end;
            else
                exit(false)
        end;

        exit(TestRequiredFields(ItemVariant));
    end;

    local procedure FindInventoryLevelItem(DataLogEntry: Record "NPR Data Log Record"; var InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    var
        Item: Record Item;
        RecRef: RecordRef;
    begin
        Clear(InventoryLevel);
        case DataLogEntry."Table ID" of
            Database::"NPR Spfy Inventory Level":
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(InventoryLevel);
                    if not InventoryLevel.Find() then
                        exit(false);
                end;
            else
                exit(false);
        end;

        if not Item.Get(InventoryLevel."Item No.") then
            exit(false);

        Item.SetRange("NPR Spfy Store Filter", InventoryLevel."Shopify Store Code");
        exit(TestRequiredInvFields(Item));
    end;

    procedure TestRequiredFields(Item: Record Item; WithError: Boolean): Boolean
    begin
        if WithError then begin
            Item.TestField(Blocked, false);
            exit(true);
        end;

        exit(
            not Item.Blocked);
    end;

    procedure TestRequiredInvFields(var Item: Record Item): Boolean
    begin
        Item.CalcFields("NPR Spfy Synced Item");
        exit(
            Item."NPR Spfy Synced Item" and
            not Item.Blocked);
    end;

    [TryFunction]
    procedure TestRequiredFields(ItemVariant: Record "Item Variant")
    var
        Item: Record Item;
    begin
        Item.Get(ItemVariant."Item No.");
        TestRequiredFields(Item, true);
#IF BC18 or BC19 or BC20 or BC21 or BC22
        ItemVariant.TestField("NPR Blocked", false);
#ELSE
        ItemVariant.TestField(Blocked, false);
#ENDIF
        CheckVarieties(Item, ItemVariant);
    end;

    procedure CheckVarieties(Item: Record Item; ItemVariant: Record "Item Variant")
    begin
        if ItemVariant.Code = '' then
            exit;

        if ItemVariant."NPR Variety 1" <> '' then begin
            ItemVariant.TestField("NPR Variety 1", Item."NPR Variety 1");
            Item.TestField("NPR Variety 1 Table");
            ItemVariant.TestField("NPR Variety 1 Table", Item."NPR Variety 1 Table");
            ItemVariant.TestField("NPR Variety 1 Value");
        end;
        if ItemVariant."NPR Variety 2" <> '' then begin
            ItemVariant.TestField("NPR Variety 2", Item."NPR Variety 2");
            Item.TestField("NPR Variety 2 Table");
            ItemVariant.TestField("NPR Variety 2 Table", Item."NPR Variety 2 Table");
            ItemVariant.TestField("NPR Variety 2 Value");
        end;
        if ItemVariant."NPR Variety 3" <> '' then begin
            ItemVariant.TestField("NPR Variety 3", Item."NPR Variety 3");
            Item.TestField("NPR Variety 3 Table");
            ItemVariant.TestField("NPR Variety 3 Table", Item."NPR Variety 3 Table");
            ItemVariant.TestField("NPR Variety 3 Value");
        end;
        if ItemVariant."NPR Variety 4" <> '' then begin
            ItemVariant.TestField("NPR Variety 4");
            Item.TestField("NPR Variety 4 Table");
            ItemVariant.TestField("NPR Variety 4 Table", Item."NPR Variety 4 Table");
            ItemVariant.TestField("NPR Variety 4 Value");
        end;
    end;

    local procedure IsValidItemReference(ItemReference: Record "Item Reference"): Boolean
    begin
        exit(
            (ItemReference."Reference Type" = ItemReference."Reference Type"::"Bar Code") and
            (ItemReference."Reference No." <> '') and not ItemReference."NPR Discontinued Barcode");
    end;

    procedure ParseItem(ShopifyJToken: JsonToken; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    begin
        exit(ParseItem_WithSkuKeyPath(ShopifyJToken, 'sku', ItemVariant, Sku));
    end;

    procedure ParseItem_WithSkuKeyPath(ShopifyJToken: JsonToken; SkuKeyPath: Text; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    var
        Item: Record Item;
        JsonHelper: Codeunit "NPR Json Helper";
        ItemNo: Text;
        VariantCode: Text;
        Position: Integer;
    begin
        Clear(ItemVariant);
        Sku := UpperCase(JsonHelper.GetJCode(ShopifyJToken, SkuKeyPath, 0, false));
        if Sku = '' then
            exit(false);
        if StrLen(Sku) <= MaxStrLen(Item."No.") then
            if Item.Get(Sku) then begin
                ItemVariant."Item No." := Item."No.";
                exit(true);
            end;

        Position := StrPos(Sku, '_');
        if (Position > 0) and (Position - 1 <= MaxStrLen(Item."No.")) then begin
            ItemNo := CopyStr(Sku, 1, Position - 1);
            VariantCode := CopyStr(Sku, Position + 1);
            if StrLen(VariantCode) <= MaxStrLen(ItemVariant.Code) then
                if ItemVariant.Get(ItemNo, VariantCode) then
                    exit(true);
            if Item.Get(ItemNo) then begin
                ItemVariant."Item No." := Item."No.";
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure UpdateInventoryLevels(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        Codeunit.Run(Codeunit::"NPR Spfy Item Recalc.Invt.Lev.", SpfyStoreItemLink);
    end;

    local procedure CheckItemIsSynchronized(Item: Record Item): Boolean
    begin
        Item.CalcFields("NPR Spfy Synced Item");
        exit(Item."NPR Spfy Synced Item");
    end;

    internal procedure ItemIsPlannedForSync(Item: Record Item): Boolean
    begin
        Item.CalcFields("NPR Spfy Synced Item (Planned)");
        exit(Item."NPR Spfy Synced Item (Planned)");
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeRenameEvent', '', true, false)]
    local procedure CheckNotShopifyItemOnRename(var Rec: Record Item)
    var
        RenameNotAllowedErr: Label 'Shopify enabled items cannot be renamed.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckItemIsSynchronized(Rec) then
            Error(RenameNotAllowedErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure CheckNotShopifyItemOnDelete(var Rec: Record Item)
    var
        DeleteNotAllowedErr: Label 'Shopify enabled items cannot be deleted.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckItemIsSynchronized(Rec) then
            Error(DeleteNotAllowedErr);
    end;
}
#endif