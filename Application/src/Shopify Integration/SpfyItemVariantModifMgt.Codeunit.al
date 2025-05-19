#if not BC17
codeunit 6248412 "NPR Spfy ItemVariantModif Mgt."
{
    Access = Internal;

    internal procedure RemoveShopifyItemVariantModification(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant then
            exit;
        SpfyItemVariantModif.SetRange("Item No.", SpfyStoreItemLink."Item No.");
        if SpfyStoreItemLink."Variant Code" <> '' then
            SpfyItemVariantModif.SetRange("Variant Code", SpfyStoreItemLink."Variant Code");
        SpfyItemVariantModif.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        if not SpfyItemVariantModif.IsEmpty() then
            SpfyItemVariantModif.DeleteAll();
    end;

    local procedure SaveItemVariantModifToDB(var SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."; DisableDataLog: Boolean)
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        if DisableDataLog then
            DataLogMgt.DisableDataLog(true);
        if IsNullGuid(SpfyItemVariantModif.SystemId) then
            SpfyItemVariantModif.Insert(true)
        else
            SpfyItemVariantModif.Modify(true);
        if DisableDataLog then
            DataLogMgt.DisableDataLog(false);
    end;

    internal procedure SetItemVariantAsNotAvailableInShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; NotAvailable: Boolean)
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Variant Code" = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit;

        SpfyItemVariantModif."Item No." := SpfyStoreItemLink."Item No.";
        SpfyItemVariantModif."Variant Code" := SpfyStoreItemLink."Variant Code";
        SpfyItemVariantModif."Shopify Store Code" := SpfyStoreItemLink."Shopify Store Code";
        if not SpfyItemVariantModif.Find() then begin
            if not NotAvailable then
                exit;
            SpfyItemVariantModif.Init();
            SpfyItemVariantModif."Not Available" := true;
            SpfyItemVariantModif.Insert(true);
            exit;
        end;
        if SpfyItemVariantModif."Not Available" = NotAvailable then
            exit;
        SpfyItemVariantModif."Not Available" := NotAvailable;
        SpfyItemVariantModif.Modify(true);
    end;

    internal procedure ItemVariantNotAvailableInShopify(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStoreCode;
        exit(ItemVariantNotAvailableInShopify(SpfyStoreItemVariantLink));
    end;

    internal procedure ItemVariantNotAvailableInShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Variant Code" = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit(false);

        if SpfyItemVariantModif.Get(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code", SpfyStoreItemLink."Shopify Store Code") then
            exit(SpfyItemVariantModif."Not Available");
    end;

    internal procedure SetAllowBackorder(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; Allow: Boolean; DisableDataLog: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Variant;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := VariantCode;
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        SetAllowBackorder(SpfyStoreItemLink, Allow, DisableDataLog);
    end;

    internal procedure SetAllowBackorder(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Allow: Boolean; DisableDataLog: Boolean)
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit;

        SpfyItemVariantModif."Item No." := SpfyStoreItemLink."Item No.";
        SpfyItemVariantModif."Variant Code" := SpfyStoreItemLink."Variant Code";
        SpfyItemVariantModif."Shopify Store Code" := SpfyStoreItemLink."Shopify Store Code";
        if not SpfyItemVariantModif.Find() then begin
            if not Allow then
                exit;
            SpfyItemVariantModif.Init();
            SpfyItemVariantModif."Allow Backorder" := true;
            SaveAllowBackorderToDB(SpfyItemVariantModif, SpfyStoreItemLink, DisableDataLog);
            exit;
        end;
        if SpfyItemVariantModif."Allow Backorder" = Allow then
            exit;
        SpfyItemVariantModif."Allow Backorder" := Allow;
        SaveAllowBackorderToDB(SpfyItemVariantModif, SpfyStoreItemLink, DisableDataLog);
    end;

    local procedure SaveAllowBackorderToDB(var SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; DisableDataLog: Boolean)
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
    begin
        SaveItemVariantModifToDB(SpfyItemVariantModif, DisableDataLog);
        SpfyIntegrationEvents.OnAfterUpdateAllowBackorder(SpfyStoreItemLink, SpfyItemVariantModif."Allow Backorder");
    end;

    internal procedure AllowBackorder(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit(false);
        SpfyStoreItemLink.CalcFields("Allow Backorder");
        exit(SpfyStoreItemLink."Allow Backorder");
    end;

    internal procedure SetDoNotTrackInventory(ItemNo: Code[20]; Set: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", ItemNo);
        SpfyStoreItemLink.SetRange("Variant Code", '');
        SpfyStoreItemLink.SetFilter("Shopify Store Code", '<>%1', '');
        if SpfyStoreItemLink.FindSet() then
            repeat
                SetDoNotTrackInventory(ItemNo, SpfyStoreItemLink."Shopify Store Code", Set, not SpfyStoreItemLink."Sync. to this Store");
            until SpfyStoreItemLink.Next() = 0;
    end;

    internal procedure SetDoNotTrackInventory(ItemNo: Code[20]; ShopifyStoreCode: Code[20]; Set: Boolean; DisableDataLog: Boolean)
    var
        ItemVariant: Record "Item Variant";
    begin
        SetDoNotTrackInventory(ItemNo, '', ShopifyStoreCode, Set, DisableDataLog);

        ItemVariant.SetRange("Item No.", ItemNo);
        if ItemVariant.FindSet() then
            repeat
                SetDoNotTrackInventory(ItemNo, ItemVariant.Code, ShopifyStoreCode, Set, DisableDataLog);
            until ItemVariant.Next() = 0;
    end;

    internal procedure SetDoNotTrackInventory(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; Set: Boolean; DisableDataLog: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Variant;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := VariantCode;
        SpfyStoreItemLink."Shopify Store Code" := ShopifyStoreCode;
        SetDoNotTrackInventory(SpfyStoreItemLink, Set, DisableDataLog);
    end;

    internal procedure SetDoNotTrackInventory(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Set: Boolean; DisableDataLog: Boolean)
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit;

        SpfyItemVariantModif."Item No." := SpfyStoreItemLink."Item No.";
        SpfyItemVariantModif."Variant Code" := SpfyStoreItemLink."Variant Code";
        SpfyItemVariantModif."Shopify Store Code" := SpfyStoreItemLink."Shopify Store Code";
        if not SpfyItemVariantModif.Find() then begin
            if not Set then
                exit;
            SpfyItemVariantModif.Init();
            SpfyItemVariantModif."Do Not Track Inventory" := true;
            SaveDoNotTrackInventoryToDB(SpfyItemVariantModif, SpfyStoreItemLink, DisableDataLog);
            exit;
        end;
        if SpfyItemVariantModif."Do Not Track Inventory" = Set then
            exit;
        SpfyItemVariantModif."Do Not Track Inventory" := Set;
        SaveDoNotTrackInventoryToDB(SpfyItemVariantModif, SpfyStoreItemLink, DisableDataLog);
    end;

    local procedure SaveDoNotTrackInventoryToDB(var SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif."; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; DisableDataLog: Boolean)
    var
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
    begin
        SaveItemVariantModifToDB(SpfyItemVariantModif, DisableDataLog);
        if SpfyItemVariantModif."Do Not Track Inventory" then
            InventoryLevelMgt.ClearInventoryLevels(SpfyStoreItemLink);
        SpfyIntegrationEvents.OnAfterUpdateDoNotTrackInventory(SpfyStoreItemLink, SpfyItemVariantModif."Do Not Track Inventory");
    end;

    internal procedure DoNotTrackInventory(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    begin
        if (SpfyStoreItemLink.Type <> SpfyStoreItemLink.Type::Variant) or
           (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Shopify Store Code" = '')
        then
            exit(false);
        SpfyStoreItemLink.CalcFields("Do Not Track Inventory");
        exit(SpfyStoreItemLink."Do Not Track Inventory");
    end;
}
#endif