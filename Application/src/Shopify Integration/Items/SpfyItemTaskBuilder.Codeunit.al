#if not BC17
codeunit 6151225 "NPR Spfy Item Task Builder"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    internal procedure ScheduleItemSync(Item: Record Item; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; TaskType: Enum "NPR Spfy Change Type"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        Clear(NcTask);
        case TaskType of
            "NPR Spfy Change Type"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            "NPR Spfy Change Type"::Modify:
                NcTask.Type := NcTask.Type::Modify;
            "NPR Spfy Change Type"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        RecRef.GetTable(Item);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, Item."No.", NcTask.Type, NcTask));
    end;

    internal procedure ScheduleItemVariantSync(ItemVariant: Record "Item Variant"; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemIntegrIsEnabled: Boolean; InventoryIntegrIsEnabled: Boolean; ItemPriceIntegrIsEnabled: Boolean; TaskType: Enum "NPR Spfy Change Type") TaskCreated: Boolean
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
        case TaskType of
            "NPR Spfy Change Type"::Insert:
                NcTask.Type := NcTask.Type::Insert;
            "NPR Spfy Change Type"::Modify:
                NcTask.Type := NcTask.Type::Modify;
            "NPR Spfy Change Type"::Delete:
                NcTask.Type := NcTask.Type::Delete;
        end;

        if ItemIntegrIsEnabled then begin
            RecRef.GetTable(ItemVariant);
            repeat
                ProcessRec := NcTask.Type <> NcTask.Type::Delete;
                if not ProcessRec then
                    ProcessRec := GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code", false) <> '';
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

    internal procedure ScheduleProductDelete(ItemNo: Code[20]; ShopifyStoreCode: Code[20]; var CreatedTaskQueue: Enum "NPR Spfy Task Dest Queue") NcTaskEntryNo: BigInteger
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        Item."No." := ItemNo;
        RecRef.GetTable(Item);
        SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, RecRef.RecordId(), ItemNo, NcTask.Type::Delete, CurrentDateTime(), 0DT, Enum::"NPR Spfy Reuse Delayed NC Task"::Any, CreatedTaskQueue, NcTask);
        NcTaskEntryNo := NcTask."Entry No.";
    end;

    internal procedure ScheduleItemVariantDelete(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; var CreatedTaskQueue: Enum "NPR Spfy Task Dest Queue") NcTaskEntryNo: BigInteger
    var
        ItemVariant: Record "Item Variant";
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := VariantCode;
        RecRef.GetTable(ItemVariant);
        SpfyScheduleSend.InitNcTask(ShopifyStoreCode, RecRef, RecRef.RecordId(), GetProductVariantSku(ItemNo, VariantCode), NcTask.Type::Delete, CurrentDateTime(), 0DT, Enum::"NPR Spfy Reuse Delayed NC Task"::Any, CreatedTaskQueue, NcTask);
        NcTaskEntryNo := NcTask."Entry No.";
    end;

    internal procedure ScheduleCostSync(ShopifyStoreCode: Code[20]; Item: Record Item): Boolean
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
        TagUpdateRequest.ReadIsolation := IsolationLevel::UpdLock;
        Updated := false;
        if xItemCategoryCode <> '' then
            Updated := AddItemCategoryTagUpdateRequests(SpfyStoreItemLink.RecordId(), xItemCategoryCode, TagUpdateRequest.Type::Remove, TagUpdateRequest);
        if ItemCategoryCode <> '' then
            Updated := AddItemCategoryTagUpdateRequests(SpfyStoreItemLink.RecordId(), ItemCategoryCode, TagUpdateRequest.Type::"Add", TagUpdateRequest) or Updated;
        if not Updated then
            exit(false);
        RecRef.GetTable(TagUpdateRequest);
        exit(SpfyScheduleSend.InitNcTask(SpfyStoreItemLink."Shopify Store Code", RecRef, SpfyStoreItemLink.RecordId(), SpfyStoreItemLink."Item No.", NcTask.Type::Modify, 0DT, 0DT, Enum::"NPR Spfy Reuse Delayed NC Task"::Any, NcTask));
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
            if not TagUpdateRequest.FindFirst() or (TagUpdateRequest."Nc Task Entry No." <> 0) or (TagUpdateRequest."Spfy Task Entry No." <> 0) then begin
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

    internal procedure ScheduleMissingVariantSync(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemIntegrIsEnabled: Boolean; InventoryIntegrIsEnabled: Boolean; ItemPriceIntegrIsEnabled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        TaskType: Enum "NPR Spfy Change Type";
    begin
        ItemVariant.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if not ItemVariant.FindSet() then
            exit;

        Item.Get(SpfyStoreItemLink."Item No.");
        if not TestRequiredFields(Item, false) then
            exit;

        SpfyStoreItemLink.SetRecFilter();
        TaskType := "NPR Spfy Change Type"::Insert;
        SpfyStoreItemVariantLink := SpfyStoreItemLink;
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;

        repeat
            if GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code", false) = '' then begin
                SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
                if not ItemIntegrIsEnabled then
                    SpfyItemVariantModifMgt.SetItemVariantAsNotAvailableInShopify(SpfyStoreItemVariantLink, true)
                else
                    if not SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink) then
                        if TestRequiredFields(ItemVariant) then begin
                            SpfyStoreItemLink.FindSet();
                            ScheduleItemVariantSync(ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled, TaskType);
                        end;
            end;
        until ItemVariant.Next() = 0;
    end;

    internal procedure GetProductVariantSku(ItemNo: Code[20]; VariantCode: Code[10]): Text
    begin
        if VariantCode = '' then
            exit(ItemNo);
        exit(StrSubstNo('%1_%2', ItemNo, VariantCode));
    end;

    internal procedure GetAssignedShopifyVariantID(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; GetFromShopifyIfEmpty: Boolean) ShopifyVariantID: Text[30]
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfySendItemsInventory: Codeunit "NPR Spfy Send Items&Inventory";
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;

        ShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if (ShopifyVariantID = '') and GetFromShopifyIfEmpty then
            ShopifyVariantID := SpfySendItemsInventory.GetShopifyVariantID(SpfyStoreItemVariantLink, false);
    end;

    internal procedure TestRequiredFields(Item: Record Item; WithError: Boolean): Boolean
    begin
        if WithError then begin
            Item.TestField(Blocked, false);
            exit(true);
        end;

        exit(
            not Item.Blocked);
    end;

    internal procedure TestRequiredInvFields(var Item: Record Item): Boolean
    begin
        Item.CalcFields("NPR Spfy Synced Item", "NPR Spfy Synced Item (Planned)");
        exit(
            (Item."NPR Spfy Synced Item" or Item."NPR Spfy Synced Item (Planned)") and
            not Item.Blocked);
    end;

    [TryFunction]
    internal procedure TestRequiredFields(ItemVariant: Record "Item Variant")
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
    internal procedure TryCheckVarieties(Item: Record Item; ItemVariant: Record "Item Variant")
    begin
        CheckVarieties(Item, ItemVariant);
    end;

    internal procedure CheckVarieties(Item: Record Item; ItemVariant: Record "Item Variant")
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

    internal procedure CheckItemVariantHasVarieties(ItemVariant: Record "Item Variant")
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

    internal procedure ItemVariantIsBlocked(ItemVariant: Record "Item Variant"): Boolean
    begin
        exit(ItemVariant.Blocked);
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
}
#endif
