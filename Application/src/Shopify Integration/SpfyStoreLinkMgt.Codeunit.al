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
            until ShopifyStore.Next() = 0;
    end;

    //#region Subscribers
    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterDeleteEvent', '', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure Item_RemoveAssignedShopifyID(var Rec: Record Item; RunTrigger: Boolean)
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

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ItemVariant_RemoveAssignedShopifyID(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::"Variant");
        SpfyStoreItemLink.SetRange("Item No.", Rec."Item No.");
        SpfyStoreItemLink.SetRange("Variant Code", Rec."Code");
        if not SpfyStoreItemLink.IsEmpty() then
            SpfyStoreItemLink.DeleteAll(true);
    end;
    //#endregion
}
#endif