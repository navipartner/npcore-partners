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
                    TaskCreated := ProcessItemVariant(DataLogEntry);
                end;

            Database::"NPR Spfy Item Variant Modif.":
                begin
                    TaskCreated := ProcessItemVariantModif(DataLogEntry);
                end;

            Database::"Stockkeeping Unit":
                begin
                    if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
                        exit;
                    ProcessStockkeepingUnit(DataLogEntry);
                    TaskCreated := false;
                end;

            Database::"NPR Spfy Store-Item Link":
                begin
                    TaskCreated := ProcessStoreItemLink(DataLogEntry);
                end;

            Database::"NPR Spfy Entity Metafield":
                begin
                    TaskCreated := ProcessMetafield(DataLogEntry);
                end;

            Database::"NPR Spfy Inventory Level":
                begin
                    if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
                        exit;
                    TaskCreated := UpdateShopifyInventory(DataLogEntry);
                end;

            Database::"NPR Spfy Item Price":
                begin
                    if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices") then
                        exit;
                    TaskCreated := UpdateShopifyItemPrice(DataLogEntry);
                end;

            Database::"Item Reference":
                begin
                    if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items) then
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
        ItemIntegrIsEnabled: Boolean;
        InventoryIntegrIsEnabled: Boolean;
        ProcessRec: Boolean;
        xRecRestored: Boolean;
        Updated_Cost: Boolean;
        Updated_ItemCat: Boolean;
    begin
        if ((DataLogEntry."Table ID" = Database::Item) and
            (DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Insert, DataLogEntry."Type of Change"::Delete])) or
           (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename)
        then
            exit;  //Renames and deletes of Shopify syncronized items are not allowed; Renames of related tables are not processed; New items are processed when integration is enabled for the item in the Store Item Link table

        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled) then
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

        if ItemIntegrIsEnabled then begin
            if (DataLogEntry."Table ID" = Database::Item) and (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify) then begin
                Updated_Cost := Item."Last Direct Cost" <> xItem."Last Direct Cost";
                Updated_ItemCat := Item."Item Category Code" <> xItem."Item Category Code";
            end;
            if (DataLogEntry."Table ID" = Database::"Item Reference") or Updated_Cost or Updated_ItemCat then
                repeat
                    if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code") then begin
                        if DataLogEntry."Table ID" = Database::"Item Reference" then
                            TaskCreated := ScheduleItemSync(DataLogEntry, Item, SpfyStoreItemLink) or TaskCreated;
                        if Updated_ItemCat then
                            if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStoreItemLink."Shopify Store Code") then
                                TaskCreated := ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", xItem."Item Category Code") or TaskCreated;
                        if Updated_Cost then
                            TaskCreated := ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;
                    end;
                until SpfyStoreItemLink.Next() = 0;
        end;

        if InventoryIntegrIsEnabled then
            if (DataLogEntry."Table ID" = Database::Item) and (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Modify) and
               (Item."NPR Spfy Safety Stock Quantity" <> xItem."NPR Spfy Safety Stock Quantity")
            then begin
                Commit();
                SpfyStoreItemLink.FindSet();
                repeat
                    if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreItemLink."Shopify Store Code") then
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

    local procedure ProcessItemVariant(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
        ProcessRec: Boolean;
    begin
        if DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename then
            exit;  //Renames are not supported

        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
        ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled or ItemPriceIntegrIsEnabled) then
            exit;

        ProcessRec := FindItemVariant(DataLogEntry, ItemVariant);
        if not ProcessRec and (DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Delete) then
            if DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogEntry."Entry No.", true, RecRef) then begin
                RecRef.SetTable(ItemVariant);
                ProcessRec := true;
            end;
        if not ProcessRec then
            exit;

        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(ItemVariant."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        exit(ScheduleItemVariantSync(DataLogEntry, ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled));
    end;

    local procedure ProcessItemVariantModif(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyVariantID: Text[30];
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
    begin
        if DataLogEntry."Type of Change" = DataLogEntry."Type of Change"::Rename then
            exit;  //Renames are not supported

        if not FindItemVariantModif(DataLogEntry, SpfyItemVariantModif) then
            exit;
        ShopifyVariantID := GetAssignedShopifyVariantID(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code", SpfyItemVariantModif."Shopify Store Code");

        if SpfyItemVariantModif."Variant Code" <> '' then begin
            if SpfyItemVariantModif."Not Available" and (ShopifyVariantID = '') then
                exit;
            if not ItemVariant.Get(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code") then
                exit;
            if not SpfyItemVariantModif."Not Available" then
                if not TestRequiredFields(ItemVariant) then
                    exit;

            if SpfyItemVariantModif."Not Available" then
                DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Delete
            else
                if ShopifyVariantID = '' then
                    DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Insert
                else
                    DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;

            ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", SpfyItemVariantModif."Shopify Store Code");
        end else begin
            if ShopifyVariantID = '' then
                exit;
            if not Item.Get(SpfyItemVariantModif."Item No.") then
                exit;
            if not TestRequiredFields(Item, false) then
                exit;
        end;
        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyItemVariantModif."Shopify Store Code");
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyItemVariantModif."Shopify Store Code");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled or ItemPriceIntegrIsEnabled) then
            exit;

        SpfyStoreLinkMgt.FilterStoreItemLinksToSync(SpfyItemVariantModif."Item No.", SpfyStoreItemLink);
        SpfyStoreItemLink.SetRange("Shopify Store Code", SpfyItemVariantModif."Shopify Store Code");
        if not SpfyStoreItemLink.FindSet() then
            exit;

        if SpfyItemVariantModif."Variant Code" <> '' then
            TaskCreated := ScheduleItemVariantSync(DataLogEntry, ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled)
        else
            repeat
                if ItemIntegrIsEnabled then
                    TaskCreated := ScheduleItemSync(DataLogEntry, Item, SpfyStoreItemLink) or TaskCreated;
                if InventoryIntegrIsEnabled then
                    UpdateInventoryLevels(SpfyStoreItemLink);
            until SpfyStoreItemLink.Next() = 0;
    end;

    local procedure ScheduleItemVariantSync(DataLogEntry: Record "NPR Data Log Record"; ItemVariant: Record "Item Variant"; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemIntegrIsEnabled: Boolean; InventoryIntegrIsEnabled: Boolean; ItemPriceIntegrIsEnabled: Boolean) TaskCreated: Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
        ProcessRec: Boolean;
    begin
        VariantSku := GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code);

        Clear(NcTask);
        if ItemVariantIsBlocked(ItemVariant) then
            NcTask.Type := NcTask.Type::Delete
        else
            case DataLogEntry."Type of Change" of
                DataLogEntry."Type of Change"::Insert:
                    NcTask.Type := NcTask.Type::Insert;
                DataLogEntry."Type of Change"::Modify:
                    NcTask.Type := NcTask.Type::Modify;
                DataLogEntry."Type of Change"::Delete:
                    NcTask.Type := NcTask.Type::Delete;
            end;

        if ItemIntegrIsEnabled then begin
            RecRef.GetTable(ItemVariant);
            repeat
                ProcessRec := NcTask.Type <> NcTask.Type::Delete;
                if not ProcessRec then
                    ProcessRec := GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code") <> '';
                if ProcessRec then
                    TaskCreated := SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, VariantSku, NcTask.Type, NcTask) or TaskCreated;
            until SpfyStoreItemLink.Next() = 0;
        end;

        if ItemPriceIntegrIsEnabled and (NcTask.Type = NcTask.Type::Insert) then begin
            Commit();
            SpfyStoreItemLink.FindSet();
            repeat
                SpfyStoreItemVariantLink := SpfyStoreItemLink;
                SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                UpdateItemPrices(SpfyStoreItemVariantLink);
            until SpfyStoreItemLink.Next() = 0;
        end;

        if InventoryIntegrIsEnabled then begin
            Commit();
            SpfyStoreItemLink.FindSet();
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreItemLink."Shopify Store Code") then begin
                    SpfyStoreItemVariantLink := SpfyStoreItemLink;
                    SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                    SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                    SpfyStoreItemVariantLink.CalcFields("Do Not Track Inventory");
                    if not SpfyStoreItemVariantLink."Do Not Track Inventory" then
                        UpdateInventoryLevels(SpfyStoreItemVariantLink);
                end;
            until SpfyStoreItemLink.Next() = 0;
        end;
    end;

    internal procedure ScheduleMissingVariantSync(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemIntegrIsEnabled: Boolean; InventoryIntegrIsEnabled: Boolean; ItemPriceIntegrIsEnabled: Boolean)
    var
        DataLogEntry: Record "NPR Data Log Record";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        ItemVariant.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if not ItemVariant.FindSet() then
            exit;

        Item.Get(SpfyStoreItemLink."Item No.");
        if not TestRequiredFields(Item, false) then
            exit;

        SpfyStoreItemLink.SetRecFilter();
        DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Insert;
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        repeat
            if GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code") = '' then begin
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                if not ItemIntegrIsEnabled then
                    SpfyItemVariantModifMgt.SetItemVariantAsNotAvailableInShopify(SpfyStoreItemVariantLink, true)
                else
                    if not SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink) then
                        if TestRequiredFields(ItemVariant) then begin
                            SpfyStoreItemLink.FindSet();
                            ScheduleItemVariantSync(DataLogEntry, ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled);
                        end;
            end;
        until ItemVariant.Next() = 0;
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
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
        NewItem: Boolean;
    begin
        if DataLogEntry."Type of Change" in [DataLogEntry."Type of Change"::Rename, DataLogEntry."Type of Change"::Delete] then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyStoreItemLink);
        if not SpfyStoreItemLink.Find() or not Item.Get(SpfyStoreItemLink."Item No.") then
            exit;
        if not (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled") then
            exit;
        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code");
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreItemLink."Shopify Store Code");
        ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", SpfyStoreItemLink."Shopify Store Code");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled or ItemPriceIntegrIsEnabled) then
            exit;
        if not TestRequiredFields(Item, false) then
            exit;

        NewItem := SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled";

        if ItemIntegrIsEnabled then begin
            DataLogEntry."Type of Change" := DataLogEntry."Type of Change"::Modify;
            TaskCreated := ScheduleItemSync(DataLogEntry, Item, SpfyStoreItemLink) or TaskCreated;
            if NewItem then begin
                TaskCreated := ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;
                if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStoreItemLink."Shopify Store Code") then
                    TaskCreated := ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", '') or TaskCreated;
            end;
        end;

        if not (InventoryIntegrIsEnabled or (NewItem and ItemPriceIntegrIsEnabled)) then
            exit;
        Commit();
        if InventoryIntegrIsEnabled then
            UpdateInventoryLevels(SpfyStoreItemLink);
        if ItemPriceIntegrIsEnabled then
            UpdateItemPrices(SpfyStoreItemLink);
    end;

    local procedure ProcessMetafield(DataLogEntry: Record "NPR Data Log Record") TaskCreated: Boolean
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        RecRef: RecordRef;
        RecRef2: RecordRef;
    begin
        if DataLogEntry."Type of Change" <> DataLogEntry."Type of Change"::Modify then
            exit;

        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyEntityMetafield);
        if not SpfyEntityMetafield.Find() then
            exit;
        case SpfyEntityMetafield."Table No." of
            Database::"NPR Spfy Store-Item Link":
                begin
                    RecRef2 := SpfyEntityMetafield."BC Record ID".GetRecord();
                    RecRef2.SetTable(SpfyStoreItemLink);
                    if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Variant then begin
                        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                        SpfyStoreItemLink."Variant Code" := '';
                    end;
                    if not Item.Get(SpfyStoreItemLink."Item No.") then
                        exit;
                    if not (SpfyStoreItemLink.Find() and (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled")) then
                        exit;
                    if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code") then
                        exit;
                    if not TestRequiredFields(Item, false) then
                        exit;
                end;
            else
                exit;
        end;

        clear(NcTask);
        NcTask.Type := NcTask.Type::Modify;
        TaskCreated := SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, SpfyEntityMetafield."BC Record ID", GetProductVariantSku(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code"), NcTask.Type, 0DT, 0DT, NcTask);
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
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", InventoryLevel."Shopify Store Code") then
            exit;

        VariantSku := GetProductVariantSku(InventoryLevel."Item No.", InventoryLevel."Variant Code");

        RecRef.GetTable(InventoryLevel);
        exit(SpfyScheduleSend.InitNcTask(InventoryLevel."Shopify Store Code", RecRef, VariantSku, NcTask.Type::Modify, InventoryLevel."Last Updated at", NcTask));
    end;

    local procedure UpdateShopifyItemPrice(DataLogEntry: Record "NPR Data Log Record"): Boolean
    var
        ItemPrice: Record "NPR Spfy Item Price";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
    begin
        if not FindItemPrice(DataLogEntry, ItemPrice) then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", ItemPrice."Shopify Store Code") then
            exit;

        VariantSku := GetProductVariantSku(ItemPrice."Item No.", ItemPrice."Variant Code");

        RecRef.GetTable(ItemPrice);
        exit(SpfyScheduleSend.InitNcTask(ItemPrice."Shopify Store Code", RecRef, RecRef.RecordId(), VariantSku, NcTask.Type::Modify, ItemPrice.SystemModifiedAt, CreateDateTime(ItemPrice."Starting Date", 0T), NcTask));
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

    internal procedure ScheduleTagsSync(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemCategoryCode: Code[20]; xItemCategoryCode: Code[20]): Boolean
    var
        NcTask: Record "NPR Nc Task";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        Updated: Boolean;
    begin
        if ItemCategoryCode = xItemCategoryCode then
            exit;
#if not (BC18 or BC19 or BC20 or BC21)
        TagUpdateRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        TagUpdateRequest.LockTable();
#endif
        Updated := false;
        if xItemCategoryCode <> '' then
            Updated := AddItemCategoryTagUpdateRequests(SpfyStoreItemLink.RecordId(), xItemCategoryCode, TagUpdateRequest.Type::Remove, TagUpdateRequest);
        if ItemCategoryCode <> '' then
            Updated := AddItemCategoryTagUpdateRequests(SpfyStoreItemLink.RecordId(), ItemCategoryCode, TagUpdateRequest.Type::"Add", TagUpdateRequest) or Updated;
        if not Updated then
            exit(false);
        RecRef.GetTable(TagUpdateRequest);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, SpfyStoreItemLink.RecordId(), SpfyStoreItemLink."Item No.", NcTask.Type::Modify, 0DT, 0DT, NcTask));
    end;

    local procedure AddItemCategoryTagUpdateRequests(RecID: RecordId; ItemCategoryCode: Code[20]; Type: Option; var TagUpdateRequest: Record "NPR Spfy Tag Update Request"): Boolean
    var
        ItemCategory: Record "Item Category";
        Updated: Boolean;
    begin
        if ItemCategoryCode = '' then
            exit;
        if not ItemCategory.Get(ItemCategoryCode) then
            exit;
        repeat
            TagUpdateRequest.SetCurrentKey("Table No.", "BC Record ID", "Tag Value");
            TagUpdateRequest.SetRange("Table No.", RecID.TableNo());
            TagUpdateRequest.SetRange("BC Record ID", RecID);
            TagUpdateRequest.SetRange("Tag Value", ItemCategory.Description);
            if not TagUpdateRequest.FindFirst() or (TagUpdateRequest."Nc Task Entry No." <> 0) then begin
                TagUpdateRequest.Init();
                TagUpdateRequest."Table No." := RecID.TableNo();
                TagUpdateRequest."BC Record ID" := RecID;
                TagUpdateRequest.Source := TagUpdateRequest.Source::"Item Category";
                TagUpdateRequest.Type := Type;
                TagUpdateRequest."Tag Value" := ItemCategory.Description;
                TagUpdateRequest."Entry No." := 0;
                TagUpdateRequest.Insert();
                Updated := true;
            end;
            if (TagUpdateRequest.Type <> Type) or (TagUpdateRequest.Source <> TagUpdateRequest.Source::"Item Category") then begin
                TagUpdateRequest.Type := Type;
                TagUpdateRequest.Source := TagUpdateRequest.Source::"Item Category";
                TagUpdateRequest.Modify();
                Updated := true;
            end;
            ItemCategory.Mark(true);  //prevent infinite loop
        until not ItemCategory.Get(ItemCategory."Parent Category") or ItemCategory.Mark();
        exit(Updated);
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

    local procedure FindItemVariant(var DataLogEntry: Record "NPR Data Log Record"; var ItemVariant: Record "Item Variant"): Boolean
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
                    if ItemVariantIsBlocked(ItemVariant) then
                        exit(true);
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

    local procedure FindItemVariantModif(DataLogEntry: Record "NPR Data Log Record"; var SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."): Boolean
    var
        RecRef: RecordRef;
    begin
        DataLogEntry.TestField("Table ID", Database::"NPR Spfy Item Variant Modif.");
        RecRef := DataLogEntry."Record ID".GetRecord();
        RecRef.SetTable(SpfyItemVariantModif);
        if not SpfyItemVariantModif.Find() then
            SpfyItemVariantModif.Init();
        exit((SpfyItemVariantModif."Item No." <> '') and (SpfyItemVariantModif."Shopify Store Code" <> ''));
    end;

    internal procedure GetAssignedShopifyVariantID(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]): Text[30]
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"));
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

    local procedure FindItemPrice(DataLogEntry: Record "NPR Data Log Record"; var ItemPrice: Record "NPR Spfy Item Price"): Boolean
    var
        Item: Record Item;
        RecRef: RecordRef;
    begin
        Clear(ItemPrice);
        case DataLogEntry."Table ID" of
            Database::"NPR Spfy Item Price":
                begin
                    RecRef := DataLogEntry."Record ID".GetRecord();
                    RecRef.SetTable(ItemPrice);
                    if not ItemPrice.Find() then
                        exit(false);
                end;
            else
                exit(false);
        end;

        if not Item.Get(ItemPrice."Item No.") then
            exit(false);

        Item.SetRange("NPR Spfy Store Filter", ItemPrice."Shopify Store Code");
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
        Item.CalcFields("NPR Spfy Synced Item", "NPR Spfy Synced Item (Planned)");
        exit(
            (Item."NPR Spfy Synced Item" or Item."NPR Spfy Synced Item (Planned)") and
            not Item.Blocked);
    end;

    [TryFunction]
    procedure TestRequiredFields(ItemVariant: Record "Item Variant")
    var
        Item: Record Item;
        VariantBlockedErr: Label 'The item %1 variant %2 is blocked.', Comment = '%1 - Item No., %2 - Variant Code';
    begin
        Item.Get(ItemVariant."Item No.");
        TestRequiredFields(Item, true);
        if ItemVariantIsBlocked(ItemVariant) then
            Error(VariantBlockedErr, ItemVariant."Item No.", ItemVariant.Code);
        CheckVarieties(Item, ItemVariant);
    end;

    [TryFunction]
    procedure TryCheckVarieties(Item: Record Item; ItemVariant: Record "Item Variant")
    begin
        CheckVarieties(Item, ItemVariant);
    end;

    procedure CheckVarieties(Item: Record Item; ItemVariant: Record "Item Variant")
    begin
        if ItemVariant.Code = '' then
            exit;

        CheckItemVariantHasVarieties(ItemVariant);

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

    procedure CheckItemVariantHasVarieties(ItemVariant: Record "Item Variant")
    var
        VariantVarietyValuesMissingErr: Label 'The item variant %1 of item %2 does not have any variety values selected. Each variant must have a unique combination of values selected on the item variant card, because Shopify uses these to distinguish between variants.', Comment = '%1 - Item Variant Code, %2 - Item No.';
    begin
        If ItemVariant.Code = '' then
            exit;
        if (ItemVariant."NPR Variety 1 Value" = '') and
           (ItemVariant."NPR Variety 2 Value" = '') and
           (ItemVariant."NPR Variety 3 Value" = '') and
           (ItemVariant."NPR Variety 4 Value" = '')
        then
            Error(VariantVarietyValuesMissingErr, ItemVariant.Code, ItemVariant."Item No.");
    end;

    local procedure IsValidItemReference(ItemReference: Record "Item Reference"): Boolean
    begin
        exit(
            (ItemReference."Reference Type" = ItemReference."Reference Type"::"Bar Code") and
            (ItemReference."Reference No." <> '') and not ItemReference."NPR Discontinued Barcode");
    end;

    procedure ParseItem(ShopifyJToken: JsonToken; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    begin
        exit(ParseItem(ShopifyJToken, 'sku', ItemVariant, Sku));
    end;

    procedure ParseItem(ShopifyJToken: JsonToken; SkuKeyPath: Text; var ItemVariant: Record "Item Variant"; var Sku: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        Sku := UpperCase(JsonHelper.GetJCode(ShopifyJToken, SkuKeyPath, 0, false));
        exit(ParseItem(Sku, ItemVariant));
    end;

    procedure ParseItem(Sku: Text; var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
        ItemNo: Text;
        VariantCode: Text;
        Position: Integer;
    begin
        Clear(ItemVariant);
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

    procedure FindItemByShopifyProductID(ProductId: Text[30]; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link") Found: Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
    begin
        Clear(SpfyStoreItemLink);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(
            Database::"NPR Spfy Store-Item Link", "NPR Spfy ID Type"::"Entry ID", ProductId, ShopifyAssignedID);
        if ShopifyAssignedID.FindSet() then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SpfyStoreItemLink);
                    SpfyStoreItemLink.Mark(SpfyStoreItemLink."Item No." <> '');
                end;
            until ShopifyAssignedID.Next() = 0;
        SpfyStoreItemLink.MarkedOnly(true);
        Found := not SpfyStoreItemLink.IsEmpty();
    end;

    internal procedure GetShopifyPictureUrl(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Text
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        JsonHelper: Codeunit "NPR Json Helper";
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        ShopifyResponse: JsonToken;
        OStream: OutStream;
        Success: Boolean;
        ProductId: Text[30];
        ProductMediaQLQueryTok: Label 'query ProductImageList($productId: ID!) { product(id: $productId) { media(first: 1, query: "media_type:IMAGE", sortKey: POSITION) { nodes { id alt ... on MediaImage { createdAt image { width height url } } } } } }', Locked = true;
    begin
        ProductId := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ProductId = '' then
            exit;
        Clear(RequestJson);
        RequestJson.Add('query', ProductMediaQLQueryTok);
        VariablesJson.Add('productId', 'gid://shopify/Product/' + ProductId);
        RequestJson.Add('variables', variablesJson.AsToken().AsObject());
        Clear(TempNcTask);
        TempNcTask."Store Code" := SpfyStoreItemLink."Shopify Store Code";
        TempNcTask."Data Output".CreateOutStream(OStream, TextEncoding::UTF8);
        RequestJson.WriteTo(OStream);

        ClearLastError();
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(TempNcTask, true, ShopifyResponse);
        if Success then
            exit(JsonHelper.GetJText(ShopifyResponse, '$[''data''].[''product''].[''media''].[''nodes''][0].[''image''].[''url'']', false));
    end;

    internal procedure UpdateInventoryLevels(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    begin
        Codeunit.Run(Codeunit::"NPR Spfy Item Recalc.Invt.Lev.", SpfyStoreItemLink);
    end;

    internal procedure UpdateItemPrices(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Item: Record Item;
        ShopifyStore: Record "NPR Spfy Store";
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
    begin
        if not (ShopifyStore.Get(SpfyStoreItemLink."Shopify Store Code") and Item.Get(SpfyStoreItemLink."Item No.")) then
            exit;
        ShopifyStore.SetRecFilter();
        Item.SetRecFilter();
        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Variant then
            Item.SetRange("Variant Filter", SpfyStoreItemLink."Variant Code");

        ItemPriceMgt.CalculateItemPrices(ShopifyStore, Item, true, Today());
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

    internal procedure AvailableInShopifyVariantsExist(ItemNo: Code[20]; ShopifyStoreCode: Code[20]): Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
#if BC18 or BC19 or BC20 or BC21 or BC22
        ItemVariant.SetRange("NPR Blocked", false);
#else
        ItemVariant.SetRange(Blocked, false);
#endif
        ItemVariant.SetLoadFields("Item No.", "Code");
        if ItemVariant.Find('-') then
            repeat
                if not SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(ItemVariant."Item No.", ItemVariant."Code", ShopifyStoreCode) then
                    exit(true);
            until ItemVariant.Next() = 0;
        exit(false);
    end;

    internal procedure ItemVariantIsBlocked(ItemVariant: Record "Item Variant"): Boolean
    begin
#if BC18 or BC19 or BC20 or BC21 or BC22
        exit(ItemVariant."NPR Blocked");
#else
        exit(ItemVariant.Blocked);
#endif
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeRenameEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeRenameEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyItemOnRename(var Rec: Record Item)
    var
        RenameNotAllowedErr: Label 'Shopify enabled items cannot be renamed.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckItemIsSynchronized(Rec) then
            Error(RenameNotAllowedErr);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeDeleteEvent, '', true, false)]
#endif
    local procedure CheckNotShopifyItemOnDelete(var Rec: Record Item)
    var
        DeleteNotAllowedErr: Label 'The item has already been synchronized with one or more Shopify stores. First, you will need to disable item synchronization with all Shopify stores and wait for the changes to sync with Shopify. Only then will you be able to delete the item from Business Central.';
    begin
        if Rec.IsTemporary() then
            exit;
        if CheckItemIsSynchronized(Rec) then
            Error(DeleteNotAllowedErr);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeModifyEvent, '', true, false)]
#endif
    local procedure CheckItemTypeAndSetDoNotTrack(var Rec: Record Item; var xRec: Record Item)
    var
        SpfyStore: Record "NPR Spfy Store";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;
        // no need to re-read xRec, as this change can only be triggered by a user via the UI
        if (Rec.Type <> Rec.Type::Inventory) and (xRec.Type = xRec.Type::Inventory) then
            if not SpfyStore.IsEmpty() then
                SpfyItemVariantModifMgt.SetDoNotTrackInventory(Rec."No.", true);
    end;
}
#endif