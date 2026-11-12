#if not BC17
codeunit 6184800 "NPR Spfy Store Link Mgt."
{
    Access = Internal;

    procedure GetFirstAssignedShopifyID(BCRecID: RecordId; ShopifyIDType: Enum "NPR Spfy ID Type"): Text[30]
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
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

            Database::Customer:
                if FilterStoreCustomerLinks(BCRecID, SpfyStoreCustomerLink) then
                    if SpfyStoreCustomerLink.FindFirst() then
                        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), ShopifyIDType));

            Database::Location:
                if FilterStoreLocationLinks(BCRecID, SpfyStoreLocationLink) then
                    if SpfyStoreLocationLink.FindFirst() then
                        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreLocationLink.RecordId(), ShopifyIDType));
        end;
        exit('');
    end;

    procedure OpenStoreLinks(BCRecID: RecordId)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
    begin
        case BCRecID.TableNo of
            Database::Item,
            Database::"Item Variant":
                if FilterStoreItemLinks(BCRecID, SpfyStoreItemLink) then
                    Page.RunModal(0, SpfyStoreItemLink);

            Database::Customer:
                if FilterStoreCustomerLinks(BCRecID, SpfyStoreCustomerLink) then
                    Page.RunModal(0, SpfyStoreCustomerLink);

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

    procedure FilterStoreCustomerLinks(BCRecID: RecordId; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"): Boolean
    var
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        case BCRecID.TableNo of
            Database::Customer:
                begin
                    RecRef := BCRecID.GetRecord();
                    RecRef.SetTable(Customer);
                    SpfyStoreCustomerLink.Reset();
                    SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
                    SpfyStoreCustomerLink.SetRange("No.", Customer."No.");
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

    procedure UpdateStoreCustomerLinks(Customer: Record Customer)
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
    begin
        if Customer."No." = '' then
            exit;

        if ShopifyStore.FindSet() then
            repeat
                SpfyStoreCustomerLink.Type := SpfyStoreCustomerLink.Type::Customer;
                SpfyStoreCustomerLink."No." := Customer."No.";
                SpfyStoreCustomerLink."Shopify Store Code" := ShopifyStore.Code;
                if not SpfyStoreCustomerLink.Find() then begin
                    SpfyStoreCustomerLink.Init();
                    SpfyCustomerMgt.UpdateMarketingConsentState(SpfyStoreCustomerLink);
                    SpfyStoreCustomerLink.Insert();
                end;
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
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Customer, OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure Customer_RemoveStoreLinks(var Rec: Record Customer; RunTrigger: Boolean)
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", Rec."No.");
        if not SpfyStoreCustomerLink.IsEmpty() then
            SpfyStoreCustomerLink.DeleteAll(true);
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

        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
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

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnBeforeRenameEvent, '', false, false)]
    local procedure ItemVariant_CheckRenameAndRemoveLeftovers(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        ShopifyStore: Record "NPR Spfy Store";
        ItemVariant: Record "Item Variant";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        HasShopifyVariantID: Boolean;
        MoveToOtherItemErr: Label 'You cannot move item %1 variant %2 to another item because the variant is synced with Shopify. Create a new variant on the other item instead.', Comment = '%1 - Item No., %2 - Variant Code';
        RemovalPendingErr: Label 'You cannot rename item %1 variant %2 while its removal from Shopify store %3 is pending. Unblock the variant or make it available in Shopify again, or wait until the removal has been sent to Shopify, and then try again. If the removal failed, find its task on the Shopify Task List or NaviConnect Task List page. If the removal is quarantined, requeue it on the Shopify Deletion Log page.', Comment = '%1 - Item No., %2 - Variant Code, %3 - Shopify Store Code';
        EarlierVariantRemovalPendingErr: Label 'You cannot rename item %1 variant %2 to %3 while the removal of an earlier variant %3 from Shopify store %4 is pending. Wait until that removal has been sent to Shopify, and then try again. If the removal failed, find its task on the Shopify Task List or NaviConnect Task List page, or its entry on the Shopify Deletion Log page.', Comment = '%1 - Item No., %2 - Variant Code, %3 - New Variant Code, %4 - Shopify Store Code';
    begin
        if Rec.IsTemporary() then
            exit;
        if not ShopifyStore.FindSet() then
            exit;
        if not ItemVariant.Get(xRec."Item No.", xRec.Code) then
            exit;

        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
        repeat
            SpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStore.Code;
            HasShopifyVariantID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '';
            if Rec."Item No." <> ItemVariant."Item No." then
                if HasShopifyVariantID or (SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID") <> '') then
                    Error(MoveToOtherItemErr, ItemVariant."Item No.", ItemVariant.Code);
            if HasShopifyVariantID then begin
                if ShopifyRemovalIsPending(ItemVariant, ShopifyStore.Code) then
                    Error(RemovalPendingErr, ItemVariant."Item No.", ItemVariant.Code, ShopifyStore.Code);
                if EarlierVariantRemovalIsPending(Rec."Item No.", Rec.Code, ShopifyStore.Code) then
                    Error(EarlierVariantRemovalPendingErr, ItemVariant."Item No.", ItemVariant.Code, Rec.Code, ShopifyStore.Code);
            end;
        until ShopifyStore.Next() = 0;

        RemoveLeftoverVariantRows(Rec."Item No.", Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnAfterRenameEvent, '', false, false)]
    local procedure ItemVariant_MoveShopifyIDs(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    var
        ShopifyStore: Record "NPR Spfy Store";
        OldSpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        NewSpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
    begin
        if Rec.IsTemporary() then
            exit;
        if not ShopifyStore.FindSet() then
            exit;

        OldSpfyStoreItemVariantLink.Type := OldSpfyStoreItemVariantLink.Type::Variant;
        OldSpfyStoreItemVariantLink."Item No." := xRec."Item No.";
        OldSpfyStoreItemVariantLink."Variant Code" := xRec.Code;
        NewSpfyStoreItemVariantLink.Type := NewSpfyStoreItemVariantLink.Type::Variant;
        NewSpfyStoreItemVariantLink."Item No." := Rec."Item No.";
        NewSpfyStoreItemVariantLink."Variant Code" := Rec.Code;
        repeat
            OldSpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStore.Code;
            NewSpfyStoreItemVariantLink."Shopify Store Code" := ShopifyStore.Code;
            MoveVariantShopifyData(OldSpfyStoreItemVariantLink.RecordId(), NewSpfyStoreItemVariantLink.RecordId());
        until ShopifyStore.Next() = 0;
        MoveVariantDeleteIntents(Rec);
    end;
    #endregion

    local procedure ShopifyRemovalIsPending(ItemVariant: Record "Item Variant"; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        VariantSku: Text[50];
    begin
        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, ShopifyStoreCode) then begin
            if SpfyItemMgt.ItemVariantIsBlocked(ItemVariant) then
                exit(true);
            if SpfyItemVariantModifMgt.ItemVariantNotAvailableInShopify(ItemVariant."Item No.", ItemVariant.Code, ShopifyStoreCode) then
                exit(true);
            if SpfyDeletionLogMgt.HasOutstandingDeleteForEntity(Database::"Item Variant", ShopifyStoreCode, ItemVariant.SystemId) then
                exit(true);
        end;

        VariantSku := CopyStr(SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code), 1, MaxStrLen(VariantSku));
        exit(HasOpenShopifyDeleteTask(VariantSku, ShopifyStoreCode));
    end;

    local procedure EarlierVariantRemovalIsPending(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]): Boolean
    var
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        VariantSku: Text[50];
    begin
        if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, ShopifyStoreCode) then begin
            SpfyDeletionLog.SetRange("Table No.", Database::"Item Variant");
            SpfyDeletionLog.SetRange("Shopify Store Code", ShopifyStoreCode);
            SpfyDeletionLog.SetRange("Item No.", ItemNo);
            SpfyDeletionLog.SetRange("Variant Code", VariantCode);
            SpfyDeletionLog.SetFilter(Status, '%1|%2', SpfyDeletionLog.Status::Pending, SpfyDeletionLog.Status::Quarantined);
            if not SpfyDeletionLog.IsEmpty() then
                exit(true);
        end;

        VariantSku := CopyStr(SpfyItemMgt.GetProductVariantSku(ItemNo, VariantCode), 1, MaxStrLen(VariantSku));
        exit(HasOpenShopifyDeleteTask(VariantSku, ShopifyStoreCode));
    end;

    local procedure HasOpenShopifyDeleteTask(VariantSku: Text[50]; ShopifyStoreCode: Code[20]): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
    begin
        NcTask.SetCurrentKey("Record Value");
        NcTask.SetRange("Record Value", VariantSku);
        NcTask.SetRange("Table No.", Database::"Item Variant");
        NcTask.SetRange(Type, NcTask.Type::Delete);
        NcTask.SetRange("Store Code", ShopifyStoreCode);
        NcTask.SetRange(Processed, false);
        if not NcTask.IsEmpty() then
            exit(true);

        SpfyTask.SetCurrentKey("Table No.", "Store Code", "Record Value", State);
        SpfyTask.SetRange("Table No.", Database::"Item Variant");
        SpfyTask.SetRange("Store Code", ShopifyStoreCode);
        SpfyTask.SetRange("Record Value", VariantSku);
        SpfyTask.SetFilter(State, '<>%1', SpfyTask.State::Completed);
        SpfyTask.SetRange(Type, SpfyTask.Type::Delete);
        exit(not SpfyTask.IsEmpty());
    end;

    local procedure RemoveLeftoverVariantRows(ItemNo: Code[20]; VariantCode: Code[10])
    var
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyInvItemLocation: Record "NPR Spfy Inv Item Location";
        SpfyItemPrice: Record "NPR Spfy Item Price";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        if (ItemNo = '') or (VariantCode = '') then
            exit;

        SpfyInventoryLevel.SetCurrentKey("Item No.", "Variant Code");
        SpfyInventoryLevel.SetRange("Item No.", ItemNo);
        SpfyInventoryLevel.SetRange("Variant Code", VariantCode);
        if not SpfyInventoryLevel.IsEmpty() then
            SpfyInventoryLevel.DeleteAll();

        SpfyInvItemLocation.SetRange("Item No.", ItemNo);
        SpfyInvItemLocation.SetRange("Variant Code", VariantCode);
        if not SpfyInvItemLocation.IsEmpty() then
            SpfyInvItemLocation.DeleteAll();

        SpfyItemPrice.SetCurrentKey("Item No.", "Variant Code");
        SpfyItemPrice.SetRange("Item No.", ItemNo);
        SpfyItemPrice.SetRange("Variant Code", VariantCode);
        if not SpfyItemPrice.IsEmpty() then
            SpfyItemPrice.DeleteAll();

        SpfyItemVariantModif.SetRange("Item No.", ItemNo);
        SpfyItemVariantModif.SetRange("Variant Code", VariantCode);
        if not SpfyItemVariantModif.IsEmpty() then
            SpfyItemVariantModif.DeleteAll();
    end;

    local procedure MoveVariantShopifyData(OldVariantLinkRecID: RecordId; NewVariantLinkRecID: RecordId)
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        ShopifyAssignedID.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        ShopifyAssignedID.SetRange("BC Record ID", NewVariantLinkRecID);
        if not ShopifyAssignedID.IsEmpty() then
            ShopifyAssignedID.DeleteAll();
        ShopifyAssignedID.SetRange("BC Record ID", OldVariantLinkRecID);
        if not ShopifyAssignedID.IsEmpty() then
            ShopifyAssignedID.ModifyAll("BC Record ID", NewVariantLinkRecID);

        SpfyEntityMetafield.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        SpfyEntityMetafield.SetRange("BC Record ID", NewVariantLinkRecID);
        if not SpfyEntityMetafield.IsEmpty() then
            SpfyEntityMetafield.DeleteAll();
        SpfyEntityMetafield.SetRange("BC Record ID", OldVariantLinkRecID);
        if not SpfyEntityMetafield.IsEmpty() then
            SpfyEntityMetafield.ModifyAll("BC Record ID", NewVariantLinkRecID);
    end;

    local procedure MoveVariantDeleteIntents(ItemVariant: Record "Item Variant")
    var
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
    begin
        SpfyDeletionLog.SetCurrentKey("Table No.", "Entity System Id", "Shopify Store Code", Status);
        SpfyDeletionLog.SetRange("Table No.", Database::"Item Variant");
        SpfyDeletionLog.SetRange("Entity System Id", ItemVariant.SystemId);
        SpfyDeletionLog.SetFilter(Status, '%1|%2', SpfyDeletionLog.Status::Pending, SpfyDeletionLog.Status::Quarantined);
        if SpfyDeletionLog.IsEmpty() then
            exit;
        SpfyDeletionLog.ModifyAll("Item No.", ItemVariant."Item No.");
        SpfyDeletionLog.ModifyAll("Variant Code", ItemVariant.Code);
    end;

    internal procedure FindLocationCodeByShopifyLocationID(ShopifyStoreCode: Code[20]; ShopifyLocationID: Text[30]; var LocationCode: Code[10]): Boolean
    var
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
    begin
        Clear(LocationCode);
        if ShopifyLocationID = '' then
            exit(false);
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"NPR Spfy Store-Location Link", "NPR Spfy ID Type"::"Entry ID", ShopifyLocationID, ShopifyAssignedID);
        if not ShopifyAssignedID.FindSet() then
            exit(false);
        repeat
            if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                RecRef.SetTable(SpfyStoreLocationLink);
                if SpfyStoreLocationLink."Shopify Store Code" = ShopifyStoreCode then begin
                    LocationCode := SpfyStoreLocationLink."Location Code";
                    exit(true);
                end;
            end;
        until ShopifyAssignedID.Next() = 0;
        exit(false);
    end;
}
#endif