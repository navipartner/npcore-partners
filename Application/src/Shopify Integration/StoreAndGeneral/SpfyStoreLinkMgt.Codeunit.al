#if not BC17
codeunit 6184800 "NPR Spfy Store Link Mgt."
{
    Access = Internal;

    procedure GetFirstAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"): Text[30]
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        case BCRecID.TableNo of
            Database::Item,
            Database::"Item Variant":
                if FilterStoreItemLinks(BCRecID, SpfyStoreItemLink) then
                    if SpfyStoreItemLink.FindFirst() then
                        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), ShopifyIDType));

            Database::Location:
                if FilterStoreLocationLinks(BCRecID, SpfyStoreLocationLink) then
                    if SpfyStoreLocationLink.FindFirst() then
                        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreLocationLink.RecordId(), ShopifyIDType));
        end;
        exit('');
    end;

    procedure OpenStoreLinks(BCRecID: RecordId)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
    begin
        case BCRecID.TableNo of
            Database::Item,
            Database::"Item Variant":
                if FilterStoreItemLinks(BCRecID, SpfyStoreItemLink) then
                    Page.RunModal(0, SpfyStoreItemLink);

            Database::Location:
                if FilterStoreLocationLinks(BCRecID, SpfyStoreLocationLink) then
                    Page.RunModal(0, SpfyStoreLocationLink);
        end;
    end;

    procedure FilterStoreItemLinks(BCRecID: RecordId; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        RecRef: RecordRef;
    begin
        case BCRecID.TableNo of
            Database::Item:
                begin
                    RecRef := BCRecID.GetRecord();
                    RecRef.SetTable(Item);
                    SpfyStoreItemLink.Reset();
                    SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
                    SpfyStoreItemLink.SetRange("Item No.", Item."No.");
                    SpfyStoreItemLink.SetRange("Variant Code", '');
                    exit(true);
                end;
            Database::"Item Variant":
                begin
                    RecRef := BCRecID.GetRecord();
                    RecRef.SetTable(ItemVariant);
                    SpfyStoreItemLink.Reset();
                    SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::"Variant");
                    SpfyStoreItemLink.SetRange("Item No.", ItemVariant."Item No.");
                    SpfyStoreItemLink.SetRange("Variant Code", ItemVariant."Code");
                    exit(true);
                end;
        end;
        exit(false);
    end;

    procedure FilterStoreItemLinksToSync(ItemNo: Code[20]; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    begin
        Clear(SpfyStoreItemLink);
        if ItemNo = '' then
            exit(false);
        SpfyStoreItemLink.SetAutoCalcFields("Store Integration Is Enabled");
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", ItemNo);
        SpfyStoreItemLink.SetRange("Variant Code", '');
        SpfyStoreItemLink.SetFilter("Shopify Store Code", '<>%1', '');
        SpfyStoreItemLink.SetRange("Sync. to this Store", true);
        SpfyStoreItemLink.SetRange("Store Integration Is Enabled", true);
        exit(true);
    end;

    procedure FilterStoreLocationLinks(BCRecID: RecordId; var SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link"): Boolean
    var
        Location: Record Location;
        RecRef: RecordRef;
    begin
        case BCRecID.TableNo of
            Database::Location:
                begin
                    RecRef := BCRecID.GetRecord();
                    RecRef.SetTable(Location);
                    SpfyStoreLocationLink.Reset();
                    SpfyStoreLocationLink.SetRange("Location Code", Location."Code");
                    exit(true);
                end;
        end;
        exit(false);
    end;

    procedure UpdateStoreItemLinks(Item: Record Item)
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        if Item."No." = '' then
            exit;

        if ShopifyStore.FindSet() then
            repeat
                SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                SpfyStoreItemLink."Item No." := Item."No.";
                SpfyStoreItemLink."Variant Code" := '';
                SpfyStoreItemLink."Shopify Store Code" := ShopifyStore.Code;
                if not SpfyStoreItemLink.Find() then begin
                    SpfyStoreItemLink.Init();
                    SpfyStoreItemLink.Insert();
                end;
                if Item.Type <> Item.Type::Inventory then
                    SpfyItemVariantModifMgt.SetDoNotTrackInventory(Item."No.", ShopifyStore.Code, true, not SpfyStoreItemLink."Sync. to this Store");
            until ShopifyStore.Next() = 0;
    end;

    #region Subscribers
#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Location, OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure Location_RemoveStoreLinks(var Rec: Record Location; RunTrigger: Boolean)
    var
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyStoreLocationLink.SetRange("Location Code", Rec.Code);
        if not SpfyStoreLocationLink.IsEmpty() then
            SpfyStoreLocationLink.DeleteAll(true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure Item_RemoveStoreLinks(var Rec: Record Item; RunTrigger: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyStoreItemLink.SetRange("Item No.", Rec."No.");
        SpfyStoreItemLink.SetRange("Variant Code", '');
        if not SpfyStoreItemLink.IsEmpty() then
            SpfyStoreItemLink.DeleteAll(true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnBeforeDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnBeforeDeleteEvent, '', false, false)]
#endif
    local procedure ItemVariant_CheckIsNotSyncedWithShopify(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifySyncedVariantErr: Label 'You cannot delete item %1 variant %2 because it is already synced with Shopify. First, please set it as "Not available in Shopify", wait for the changes to sync with Shopify, and then you can safely delete the variant.', Comment = '%1 - Item No., %2 - Variant Code';
    begin
        if Rec.IsTemporary() then
            exit;
        if ShopifyStore.IsEmpty() then
            exit;

        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := Rec."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := Rec."Code";
        ShopifyStore.FindSet();
        repeat
            SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStore.Code;
            if SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '' then
                Error(ShopifySyncedVariantErr, Rec."Item No.", Rec."Code");
        until ShopifyStore.Next() = 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure ItemVariant_RemoveAssignedShopifyID(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
    begin
        if Rec.IsTemporary() then
            exit;
        if ShopifyStore.IsEmpty() then
            exit;

        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        SpfyStoreItemVariantLink."Item No." := Rec."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := Rec."Code";
        ShopifyStore.FindSet();
        repeat
            SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStore.Code;
            SendItemAndInventory.ClearVariantShopifyIDs(SpfyStoreItemVariantLink);
            SpfyItemVariantModifMgt.RemoveShopifyItemVariantModification(SpfyStoreItemVariantLink);
        until ShopifyStore.Next() = 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure ItemVariant_UpdateStoreLink(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
    begin
        if Rec.IsTemporary() then
            exit;

        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", Rec."Item No.");
        SpfyStoreItemLink.SetRange("Variant Code", '');
        if SpfyStoreItemLink.IsEmpty() then
            exit;
        SpfyStoreItemLink.SetAutoCalcFields("Allow Backorder", "Do Not Track Inventory");
        SpfyStoreItemLink.FindSet();
        repeat
            SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
            SpfyStoreItemVariantLink."Item No." := Rec."Item No.";
            SpfyStoreItemVariantLink."Variant Code" := Rec."Code";
            SpfyStoreItemVariantLink."Shopify Store Code" := SpfyStoreItemLink."Shopify Store Code";
            if SpfyStoreItemLink."Allow Backorder" then
                SpfyItemVariantModifMgt.SetAllowBackorder(SpfyStoreItemVariantLink, SpfyStoreItemLink."Allow Backorder", true);
            if SpfyStoreItemLink."Do Not Track Inventory" then
                SpfyItemVariantModifMgt.SetDoNotTrackInventory(SpfyStoreItemVariantLink, SpfyStoreItemLink."Do Not Track Inventory", true);
        until SpfyStoreItemLink.Next() = 0;
    end;
    #endregion
}
#endif