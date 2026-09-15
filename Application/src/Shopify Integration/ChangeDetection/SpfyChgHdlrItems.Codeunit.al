codeunit 6151189 "NPR Spfy Chg Hdlr Items" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        SpfyItemTaskBuilder: Codeunit "NPR Spfy Item Task Builder";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        SpfyInventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(ProcessDelete(DetectedChange));

        case DetectedChange.TableNo() of
            Database::Item:
                exit(ProcessItem(DetectedChange));
            Database::"NPR Spfy Store-Item Link":
                exit(ProcessStoreItemLink(DetectedChange));
            Database::"NPR Spfy Item Variant Modif.":
                exit(ProcessItemVariantModif(DetectedChange));
            Database::"Item Variant":
                exit(ProcessItemVariant(DetectedChange));
            Database::"Item Reference":
                exit(ProcessItemReference(DetectedChange));
        end;
        exit(false);
    end;

    local procedure ProcessDelete(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        NcTaskEntryNo: BigInteger;
    begin
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, DetectedChange.StoreCode()) then
            exit(false);
        case DetectedChange.TableNo() of
            Database::Item:
                NcTaskEntryNo := SpfyItemTaskBuilder.ScheduleProductDelete(DetectedChange.ItemNo(), DetectedChange.StoreCode());
            Database::"Item Variant":
                NcTaskEntryNo := SpfyItemTaskBuilder.ScheduleItemVariantDelete(DetectedChange.ItemNo(), DetectedChange.VariantCode(), DetectedChange.StoreCode());
            else
                exit(false);
        end;
        if NcTaskEntryNo = 0 then
            exit(false);
        DetectedChange.SetCreatedNcTaskEntryNo(NcTaskEntryNo);
        exit(true);
    end;

    local procedure ProcessItem(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Baseline: JsonObject;
        CurrentCategory: Text;
        OldCategory: Code[20];
        CostChanged: Boolean;
        CategoryChanged: Boolean;
        CategoryFacetChanged: Boolean;
        SafetyStockChanged: Boolean;
        ItemEnabledForStore: Boolean;
        InvEnabledForStore: Boolean;
    begin
        if not (SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items) or
                SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels"))
        then
            exit;
        if not Item.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if not SpfyItemTaskBuilder.TestRequiredFields(Item, false) then
            exit;
        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(Item."No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        CurrentCategory := SpfySyncStateMgt.ItemCategoryCode(Item);

        repeat
            ItemEnabledForStore := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code");
            InvEnabledForStore := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreItemLink."Shopify Store Code");
            if ItemEnabledForStore or InvEnabledForStore then begin
                SafetyStockChanged := false;
                SpfySyncStateMgt.GetBaseline(Database::Item, Item.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);

                CostChanged := false;
                CategoryChanged := false;
                CategoryFacetChanged := false;
                if ItemEnabledForStore then begin
                    CostChanged := SpfySyncStateMgt.FacetAsDecimal(Baseline, SpfySyncStateMgt.GetItemCostKey()) <> Item."Last Direct Cost";
                    CategoryChanged := SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetItemCategoryCodeKey()) <> CurrentCategory;

                    if CategoryChanged then
                        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStoreItemLink."Shopify Store Code") then
                            CategoryFacetChanged := true   // category is synced via the metafield path; this facet only tracks it
                        else begin
                            OldCategory := CopyStr(SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetItemCategoryCodeKey()), 1, MaxStrLen(OldCategory));
                            TaskCreated := SpfyItemTaskBuilder.ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", OldCategory) or TaskCreated;
                            // Advance only when the new category resolves (or is blank); a deleted category leaves the facet
                            // stale so tags re-attempt on the item's next change (restore-recovery is the CORE-1205 reset job).
                            CategoryFacetChanged := (Item."Item Category Code" = '') or ItemCategory.Get(Item."Item Category Code");
                        end;
                    if CostChanged then
                        TaskCreated := SpfyItemTaskBuilder.ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;

                    if CostChanged then
                        SpfySyncStateMgt.SetFacetDecimal(Baseline, SpfySyncStateMgt.GetItemCostKey(), Item."Last Direct Cost");
                    if CategoryFacetChanged then
                        SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetItemCategoryCodeKey(), CurrentCategory);
                end;

                if InvEnabledForStore then
                    if SpfySyncStateMgt.FacetAsDecimal(Baseline, SpfySyncStateMgt.GetItemSafetyStockKey()) <> Item."NPR Spfy Safety Stock Quantity" then begin
                        SpfyInventoryLevelMgt.RecalcItemStructural(Item."No.", SpfyStoreItemLink."Shopify Store Code");
                        SpfySyncStateMgt.SetFacetDecimal(Baseline, SpfySyncStateMgt.GetItemSafetyStockKey(), Item."NPR Spfy Safety Stock Quantity");
                        SafetyStockChanged := true;
                    end;

                if CostChanged or CategoryFacetChanged or SafetyStockChanged then
                    SpfySyncStateMgt.SaveBaseline(Database::Item, Item.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);
            end;
        until SpfyStoreItemLink.Next() = 0;
    end;

    local procedure ProcessStoreItemLink(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Baseline: JsonObject;
        CurrentLinkHash: Text;
        ItemIntegrIsEnabled: Boolean;
        NewItem: Boolean;
        TaskType: Enum "NPR Spfy Change Type";
    begin
        if not SpfyStoreItemLink.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if not Item.Get(SpfyStoreItemLink."Item No.") then
            exit;
        if not (SpfyStoreItemLink."Sync. to this Store" or SpfyStoreItemLink."Synchronization Is Enabled") then
            exit;

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyStoreItemLink."Shopify Store Code") then
            SpfyInventoryLevelMgt.RecalcItemStructural(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Shopify Store Code");

        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", SpfyStoreItemLink."Shopify Store Code") then
            if SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled" then
                SpfyItemTaskBuilder.UpdateItemPrices(SpfyStoreItemLink);

        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code");
        if not ItemIntegrIsEnabled then
            exit;
        if not SpfyItemTaskBuilder.TestRequiredFields(Item, false) then
            exit;

        NewItem := SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled";

        if not ResolveItemTaskType(SpfyStoreItemLink, TaskType) then
            exit;

        CurrentLinkHash := SpfySyncStateMgt.StoreItemLinkPayloadHash(SpfyStoreItemLink);
        SpfySyncStateMgt.GetBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);
        if (not NewItem) and (TaskType = "NPR Spfy Change Type"::Modify) and (SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetStoreItemLinkHashKey()) = CurrentLinkHash) then
            exit;

        TaskCreated := SpfyItemTaskBuilder.ScheduleItemSync(Item, SpfyStoreItemLink, TaskType) or TaskCreated;
        if NewItem then begin
            TaskCreated := SpfyItemTaskBuilder.ScheduleCostSync(SpfyStoreItemLink."Shopify Store Code", Item) or TaskCreated;
            if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyStoreItemLink."Shopify Store Code") then
                TaskCreated := SpfyItemTaskBuilder.ScheduleTagsSync(SpfyStoreItemLink, Item."Item Category Code", '') or TaskCreated;
            // The first sync sends the item's current cost and category; record them so the next item change is compared against what was sent, not against an empty baseline.
            SpfySyncStateMgt.SeedItemBaseline(Item, SpfyStoreItemLink."Shopify Store Code");
        end;

        SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetStoreItemLinkHashKey(), CurrentLinkHash);
        SpfySyncStateMgt.SaveBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, SpfyStoreItemLink."Shopify Store Code", Baseline);
    end;


    local procedure ProcessItemVariantModif(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Baseline: JsonObject;
        CurrentModifHash: Text;
        ShopifyVariantID: Text[30];
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
        BaseType: Enum "NPR Spfy Change Type";
        TaskType: Enum "NPR Spfy Change Type";
    begin
        if not SpfyItemVariantModif.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if (SpfyItemVariantModif."Item No." = '') or (SpfyItemVariantModif."Shopify Store Code" = '') then
            exit;
        ShopifyVariantID := SpfyItemTaskBuilder.GetAssignedShopifyVariantID(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code", SpfyItemVariantModif."Shopify Store Code", false);

        if SpfyItemVariantModif."Variant Code" <> '' then begin
            if SpfyItemVariantModif."Not Available" and (ShopifyVariantID = '') then
                exit;
            if not ItemVariant.Get(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code") then
                exit;
            if not SpfyItemVariantModif."Not Available" then
                if not SpfyItemTaskBuilder.TestRequiredFields(ItemVariant) then
                    exit;

            if not ResolveVariantModifTaskType(SpfyItemVariantModif, ShopifyVariantID, BaseType) then
                exit;
            ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", SpfyItemVariantModif."Shopify Store Code");
        end else begin
            if ShopifyVariantID = '' then
                exit;
            if not Item.Get(SpfyItemVariantModif."Item No.") then
                exit;
            if not SpfyItemTaskBuilder.TestRequiredFields(Item, false) then
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

        CurrentModifHash := SpfySyncStateMgt.ItemVariantModifHash(SpfyItemVariantModif);
        SpfySyncStateMgt.GetBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, SpfyItemVariantModif."Shopify Store Code", Baseline);

        if SpfyItemVariantModif."Variant Code" <> '' then begin
            if not ResolveVariantTaskType(ItemVariant, BaseType, TaskType) then
                exit;
            if (TaskType = "NPR Spfy Change Type"::Modify) and (SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetItemVariantModifHashKey()) = CurrentModifHash) then
                exit;
            TaskCreated := SpfyItemTaskBuilder.ScheduleItemVariantSync(ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled, TaskType);
        end else begin
            if SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetItemVariantModifHashKey()) = CurrentModifHash then
                exit;
            TaskType := "NPR Spfy Change Type"::Modify;
            repeat
                if ItemIntegrIsEnabled then
                    TaskCreated := SpfyItemTaskBuilder.ScheduleItemSync(Item, SpfyStoreItemLink, TaskType) or TaskCreated;
                if InventoryIntegrIsEnabled then
                    SpfyItemTaskBuilder.UpdateInventoryLevels(SpfyStoreItemLink);
            until SpfyStoreItemLink.Next() = 0;
        end;

        // Advance the modif-payload hash only when Items is enabled (product payload covered); see ProcessItemVariant.
        if ItemIntegrIsEnabled then begin
            SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetItemVariantModifHashKey(), CurrentModifHash);
            SpfySyncStateMgt.SaveBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, SpfyItemVariantModif."Shopify Store Code", Baseline);
        end;
    end;

    local procedure ProcessItemVariant(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        RecRef: RecordRef;
        Baseline: JsonObject;
        CurrentVariantHash: Text;
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
        BaseType: Enum "NPR Spfy Change Type";
        TaskType: Enum "NPR Spfy Change Type";
    begin
        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
        ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled or ItemPriceIntegrIsEnabled) then
            exit;

        if not ItemVariant.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if not SpfyItemTaskBuilder.ItemVariantIsBlocked(ItemVariant) then
            if not SpfyItemTaskBuilder.TestRequiredFields(ItemVariant) then
                exit;

        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(ItemVariant."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        BaseType := VariantBaseType(ItemVariant, SpfyStoreItemLink);
        if not ResolveVariantTaskType(ItemVariant, BaseType, TaskType) then
            exit;

        RecRef.GetTable(ItemVariant);
        CurrentVariantHash := SpfySyncStateMgt.RecordHash(RecRef);
        SpfySyncStateMgt.GetBaseline(Database::"Item Variant", ItemVariant.SystemId, '', Baseline);
        if (TaskType = "NPR Spfy Change Type"::Modify) and (SpfySyncStateMgt.Facet(Baseline, SpfySyncStateMgt.GetItemVariantHashKey()) = CurrentVariantHash) then
            exit;

        if not SpfyStoreItemLink.FindSet() then   // VariantBaseType advanced the cursor; re-position for the scheduler
            exit;
        TaskCreated := SpfyItemTaskBuilder.ScheduleItemVariantSync(ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled, TaskType);

        // Advance the variant-payload hash only when Items is enabled (the product task was covered); if only
        // inventory/price side-effects ran, leave it stale so the variant re-syncs once Items is enabled.
        if ItemIntegrIsEnabled then begin
            SpfySyncStateMgt.SetFacet(Baseline, SpfySyncStateMgt.GetItemVariantHashKey(), CurrentVariantHash);
            SpfySyncStateMgt.SaveBaseline(Database::"Item Variant", ItemVariant.SystemId, '', Baseline);
        end;
    end;

    local procedure VariantBaseType(var ItemVariant: Record "Item Variant"; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Enum "NPR Spfy Change Type"
    begin
        if SpfyStoreItemLink.FindSet() then
            repeat
                if SpfyItemTaskBuilder.GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code", false) <> '' then
                    exit("NPR Spfy Change Type"::Modify);
            until SpfyStoreItemLink.Next() = 0;
        exit("NPR Spfy Change Type"::Insert);
    end;

    local procedure ResolveItemTaskType(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var TaskType: Enum "NPR Spfy Change Type"): Boolean
    begin
        case true of
            SpfyStoreItemLink."Sync. to this Store" and not SpfyStoreItemLink."Synchronization Is Enabled":
                TaskType := "NPR Spfy Change Type"::Insert;
            SpfyStoreItemLink."Sync. to this Store" and SpfyStoreItemLink."Synchronization Is Enabled":
                TaskType := "NPR Spfy Change Type"::Modify;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure ResolveVariantTaskType(ItemVariant: Record "Item Variant"; BaseType: Enum "NPR Spfy Change Type"; var TaskType: Enum "NPR Spfy Change Type"): Boolean
    begin
        if SpfyItemTaskBuilder.ItemVariantIsBlocked(ItemVariant) then
            exit(false);
        TaskType := BaseType;
        exit(true);
    end;

    local procedure ResolveVariantModifTaskType(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."; ShopifyVariantID: Text[30]; var TaskType: Enum "NPR Spfy Change Type"): Boolean
    begin
        if SpfyItemVariantModif."Not Available" then
            exit(false);
        if ShopifyVariantID = '' then
            TaskType := "NPR Spfy Change Type"::Insert
        else
            TaskType := "NPR Spfy Change Type"::Modify;
        exit(true);
    end;

    local procedure ProcessItemReference(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        ItemReference: Record "Item Reference";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled : Boolean;
        BaseType: Enum "NPR Spfy Change Type";
        TaskType: Enum "NPR Spfy Change Type";
    begin
        if not ItemReference.GetBySystemId(DetectedChange.SystemId()) then
            exit;
        if not IsValidItemReference(ItemReference) then
            exit;

        if ItemReference."Variant Code" = '' then begin
            if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items) then
                exit;
            if not Item.Get(ItemReference."Item No.") then
                exit;
            if not SpfyItemTaskBuilder.TestRequiredFields(Item, false) then
                exit;
            if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(Item."No.", SpfyStoreItemLink) then
                exit;
            if not SpfyStoreItemLink.FindSet() then
                exit;
            repeat
                if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code") then
                    if ResolveItemTaskType(SpfyStoreItemLink, TaskType) then
                        TaskCreated := SpfyItemTaskBuilder.ScheduleItemSync(Item, SpfyStoreItemLink, TaskType) or TaskCreated;
            until SpfyStoreItemLink.Next() = 0;
            exit;
        end;

        ItemIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
        InventoryIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
        ItemPriceIntegrIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices");
        if not (ItemIntegrIsEnabled or InventoryIntegrIsEnabled or ItemPriceIntegrIsEnabled) then
            exit;
        if not ItemVariant.Get(ItemReference."Item No.", ItemReference."Variant Code") then
            exit;
        if not SpfyItemTaskBuilder.ItemVariantIsBlocked(ItemVariant) then
            if not SpfyItemTaskBuilder.TestRequiredFields(ItemVariant) then
                exit;
        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(ItemVariant."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;

        BaseType := "NPR Spfy Change Type"::Modify;
        if not ResolveVariantTaskType(ItemVariant, BaseType, TaskType) then
            exit;
        TaskCreated := SpfyItemTaskBuilder.ScheduleItemVariantSync(ItemVariant, SpfyStoreItemLink, ItemIntegrIsEnabled, InventoryIntegrIsEnabled, ItemPriceIntegrIsEnabled, TaskType);
    end;

    local procedure IsValidItemReference(ItemReference: Record "Item Reference"): Boolean
    begin
        exit(
            (ItemReference."Reference Type" = ItemReference."Reference Type"::"Bar Code") and
            (ItemReference."Reference No." <> '') and not ItemReference."NPR Discontinued Barcode");
    end;
}
