codeunit 6151235 "NPR Spfy Del. Capture Subscr."
{
    Access = Internal;

    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyItemTaskBuilder: Codeunit "NPR Spfy Item Task Builder";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Item Variant Modif.", OnAfterInsertEvent, '', false, false)]
    local procedure ItemVariantModifOnAfterInsert(var Rec: Record "NPR Spfy Item Variant Modif.")
    begin
        ReconcileVariantNotAvailableDeleteIntent(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Item Variant Modif.", OnAfterModifyEvent, '', false, false)]
    local procedure ItemVariantModifOnAfterModify(var Rec: Record "NPR Spfy Item Variant Modif.")
    begin
        ReconcileVariantNotAvailableDeleteIntent(Rec);
    end;

    // Desired-state reconciliation, NOT xRec transition detection: xRec is unreliable in a modify subscriber when the
    // Modify comes from code (it equals Rec). LogDelete/CancelDeleteForEntity are idempotent and CancelVariantDelete
    // keeps other (Blocked/link) deactivations intact, so driving off the CURRENT "Not Available" is both reliable and safe.
    local procedure ReconcileVariantNotAvailableDeleteIntent(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.")
    begin
        if SpfyItemVariantModif.IsTemporary() or not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        if SpfyItemVariantModif."Not Available" then
            CaptureVariantNotAvailable(SpfyItemVariantModif)
        else
            CancelVariantDelete(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code", SpfyItemVariantModif."Shopify Store Code");
    end;

    local procedure CaptureVariantNotAvailable(SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.")
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyVariantID: Text[30];
    begin
        if (SpfyItemVariantModif."Item No." = '') or (SpfyItemVariantModif."Variant Code" = '') or (SpfyItemVariantModif."Shopify Store Code" = '') then
            exit;
        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(SpfyItemVariantModif."Item No.", SpfyStoreItemLink) then
            exit;
        SpfyStoreItemLink.SetRange("Shopify Store Code", SpfyItemVariantModif."Shopify Store Code");
        if SpfyStoreItemLink.IsEmpty() then
            exit;
        ShopifyVariantID := SpfyItemTaskBuilder.GetAssignedShopifyVariantID(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code", SpfyItemVariantModif."Shopify Store Code", false);
        if ShopifyVariantID = '' then
            exit;
        if not ItemVariant.Get(SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code") then begin
            ItemVariant."Item No." := SpfyItemVariantModif."Item No.";
            ItemVariant.Code := SpfyItemVariantModif."Variant Code";
        end;
        SpfyDeletionLogMgt.LogDelete(
            Database::"Item Variant", SpfyItemVariantModif."Item No.", SpfyItemVariantModif."Variant Code", '',
            ItemVariant.RecordId(), ItemVariant.SystemId, SpfyItemVariantModif."Shopify Store Code",
            "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnAfterModifyEvent, '', false, false)]
    local procedure ItemVariantOnAfterModify(var Rec: Record "Item Variant")
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyVariantID: Text[30];
        Capture: Boolean;
    begin
        // Desired-state reconciliation off current Blocked, NOT an xRec transition (xRec is unreliable when Modify comes
        // from code). Cheap: FilterStoreItemLinksToSync returns empty fast for non-Shopify items, LogDelete/CancelDeleteForEntity
        // are idempotent, and it's gated behind the cached feature flag.
        if Rec.IsTemporary() or not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        Capture := Rec.Blocked;
        if not SpfyStoreLinkMgt.FilterStoreItemLinksToSync(Rec."Item No.", SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;
        repeat
            // The id guard is capture-only: with no id there is nothing to delete, but a cancel must still land after the id was cleared.
            if Capture then begin
                ShopifyVariantID := SpfyItemTaskBuilder.GetAssignedShopifyVariantID(Rec."Item No.", Rec.Code, SpfyStoreItemLink."Shopify Store Code", false);
                if ShopifyVariantID <> '' then
                    SpfyDeletionLogMgt.LogDelete(
                        Database::"Item Variant", Rec."Item No.", Rec.Code, '',
                        Rec.RecordId(), Rec.SystemId, SpfyStoreItemLink."Shopify Store Code",
                        "NPR Spfy ID Type"::"Entry ID", ShopifyVariantID);
            end else
                CancelVariantDelete(Rec."Item No.", Rec.Code, SpfyStoreItemLink."Shopify Store Code");
        until SpfyStoreItemLink.Next() = 0;
    end;

    internal procedure OnStoreItemLinkSyncValidated(var Rec: Record "NPR Spfy Store-Item Link"; SyncToStore: Boolean; xSyncToStore: Boolean)
    begin
        if Rec.IsTemporary() or not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        if SyncToStore = xSyncToStore then
            exit;
        if not SyncToStore then
            CaptureStoreItemLinkDelete(Rec)
        else
            CancelStoreItemLinkDelete(Rec);
    end;

    local procedure CaptureStoreItemLinkDelete(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        EntityTableNo: Integer;
        ItemNo: Code[20];
        VariantCode: Code[10];
        ShopifyID: Text[30];
    begin
        if not StoreItemLinkEntity(SpfyStoreItemLink, EntityTableNo, ItemNo, VariantCode) then
            exit;
        ShopifyID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyID = '' then
            exit;
        SpfyDeletionLogMgt.LogDelete(
            EntityTableNo, ItemNo, VariantCode, '',
            SpfyStoreItemLink.RecordId(), EntitySystemId(EntityTableNo, ItemNo, VariantCode), SpfyStoreItemLink."Shopify Store Code",
            "NPR Spfy ID Type"::"Entry ID", ShopifyID);
    end;

    local procedure CancelStoreItemLinkDelete(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        EntityTableNo: Integer;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if not StoreItemLinkEntity(SpfyStoreItemLink, EntityTableNo, ItemNo, VariantCode) then
            exit;
        if (EntityTableNo = Database::"Item Variant") and OtherVariantDeactivationActive(ItemNo, VariantCode, SpfyStoreItemLink."Shopify Store Code", false) then
            exit;
        if EntityTableNo = Database::Item then
            CancelStaleVariantDeletes(ItemNo, SpfyStoreItemLink."Shopify Store Code");
        SpfyDeletionLogMgt.CancelDeleteForEntity(EntityTableNo, SpfyStoreItemLink."Shopify Store Code", EntitySystemId(EntityTableNo, ItemNo, VariantCode));
    end;

    // An item-link re-sync reactivates the item's variants, so any delete intent captured while the link was
    // unsynced is stale unless another deactivation cause still demands it (CORE-433 4-transition edge).
    local procedure CancelStaleVariantDeletes(ItemNo: Code[20]; ShopifyStoreCode: Code[20])
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.SetRange("Table No.", Database::"Item Variant");
        DeletionLog.SetRange("Item No.", ItemNo);
        DeletionLog.SetRange("Shopify Store Code", ShopifyStoreCode);
        // Include Processed: a drained-but-unsent delete is still cancellable via CancelDeleteForEntity/CancelOutstandingNcTask.
        DeletionLog.SetFilter(Status, '%1|%2|%3', DeletionLog.Status::Pending, DeletionLog.Status::Processed, DeletionLog.Status::Quarantined);
        if DeletionLog.FindSet() then
            repeat
                if not OtherVariantDeactivationActive(DeletionLog."Item No.", DeletionLog."Variant Code", ShopifyStoreCode, true) then
                    SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"Item Variant", ShopifyStoreCode, DeletionLog."Entity System Id");
            until DeletionLog.Next() = 0;
    end;

    local procedure StoreItemLinkEntity(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var EntityTableNo: Integer; var ItemNo: Code[20]; var VariantCode: Code[10]): Boolean
    begin
        if (SpfyStoreItemLink."Item No." = '') or (SpfyStoreItemLink."Shopify Store Code" = '') then
            exit(false);
        ItemNo := SpfyStoreItemLink."Item No.";
        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Variant then begin
            VariantCode := SpfyStoreItemLink."Variant Code";
            EntityTableNo := Database::"Item Variant";
        end else
            EntityTableNo := Database::Item;
        exit(true);
    end;

    local procedure EntitySystemId(EntityTableNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]): Guid
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        case EntityTableNo of
            Database::Item:
                if Item.Get(ItemNo) then
                    exit(Item.SystemId);
            Database::"Item Variant":
                if ItemVariant.Get(ItemNo, VariantCode) then
                    exit(ItemVariant.SystemId);
        end;
    end;

    internal procedure OnStoreCustomerLinkSyncValidated(var Rec: Record "NPR Spfy Store-Customer Link"; SyncToStore: Boolean; xSyncToStore: Boolean)
    begin
        if Rec.IsTemporary() or not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        if SyncToStore = xSyncToStore then
            exit;
        if not SyncToStore then
            CaptureStoreCustomerLinkDelete(Rec)
        else
            CancelStoreCustomerLinkDelete(Rec);
    end;

    local procedure CaptureStoreCustomerLinkDelete(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Customer: Record Customer;
        ShopifyID: Text[30];
        CustomerSystemId: Guid;
    begin
        if (SpfyStoreCustomerLink."No." = '') or (SpfyStoreCustomerLink."Shopify Store Code" = '') then
            exit;
        ShopifyID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreCustomerLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyID = '' then
            exit;
        if Customer.Get(SpfyStoreCustomerLink."No.") then
            CustomerSystemId := Customer.SystemId;
        SpfyDeletionLogMgt.LogDelete(
            Database::Customer, '', '', SpfyStoreCustomerLink."No.",
            SpfyStoreCustomerLink.RecordId(), CustomerSystemId, SpfyStoreCustomerLink."Shopify Store Code",
            "NPR Spfy ID Type"::"Entry ID", ShopifyID);
    end;

    local procedure CancelStoreCustomerLinkDelete(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Customer: Record Customer;
        CustomerSystemId: Guid;
    begin
        if (SpfyStoreCustomerLink."No." = '') or (SpfyStoreCustomerLink."Shopify Store Code" = '') then
            exit;
        if Customer.Get(SpfyStoreCustomerLink."No.") then
            CustomerSystemId := Customer.SystemId;
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::Customer, SpfyStoreCustomerLink."Shopify Store Code", CustomerSystemId);
    end;

    local procedure CancelVariantDelete(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20])
    begin
        if (ItemNo = '') or (VariantCode = '') or (ShopifyStoreCode = '') then
            exit;
        if OtherVariantDeactivationActive(ItemNo, VariantCode, ShopifyStoreCode, true) then
            exit;
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"Item Variant", ShopifyStoreCode, EntitySystemId(Database::"Item Variant", ItemNo, VariantCode));
    end;

    // A delete intent can no longer be sent once its Shopify id is gone, so clearing the id cancels it.
    internal procedure OnShopifyIDCleared(BCRecID: RecordId; IDType: Enum "NPR Spfy ID Type")
    var
        EntitySystemIdValue: Guid;
        StoreCode: Code[20];
        EntityTableNo: Integer;
    begin
        if IDType <> "NPR Spfy ID Type"::"Entry ID" then
            exit;
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        if not ResolveClearedIDEntity(BCRecID, EntityTableNo, StoreCode, EntitySystemIdValue) then
            exit;
        SpfyDeletionLogMgt.CancelDeleteForEntity(EntityTableNo, StoreCode, EntitySystemIdValue);
    end;

    internal procedure HasOutstandingDeleteForClearedID(BCRecID: RecordId; IDType: Enum "NPR Spfy ID Type"): Boolean
    var
        EntitySystemIdValue: Guid;
        StoreCode: Code[20];
        EntityTableNo: Integer;
    begin
        if IDType <> "NPR Spfy ID Type"::"Entry ID" then
            exit(false);
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit(false);
        if not ResolveClearedIDEntity(BCRecID, EntityTableNo, StoreCode, EntitySystemIdValue) then
            exit(false);
        exit(SpfyDeletionLogMgt.HasOutstandingDeleteForEntity(EntityTableNo, StoreCode, EntitySystemIdValue));
    end;

    local procedure ResolveClearedIDEntity(BCRecID: RecordId; var EntityTableNo: Integer; var StoreCode: Code[20]; var EntitySystemIdParam: Guid): Boolean
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        RecRef: RecordRef;
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        case BCRecID.TableNo() of
            Database::"NPR Spfy Store-Item Link":
                begin
                    if not RecRef.Get(BCRecID) then
                        exit(false);
                    RecRef.SetTable(SpfyStoreItemLink);
                    if not StoreItemLinkEntity(SpfyStoreItemLink, EntityTableNo, ItemNo, VariantCode) then
                        exit(false);
                    StoreCode := SpfyStoreItemLink."Shopify Store Code";
                    EntitySystemIdParam := EntitySystemId(EntityTableNo, ItemNo, VariantCode);
                    exit(true);
                end;
            Database::"NPR Spfy Store-Customer Link":
                begin
                    if not RecRef.Get(BCRecID) then
                        exit(false);
                    RecRef.SetTable(SpfyStoreCustomerLink);
                    if (SpfyStoreCustomerLink."No." = '') or (SpfyStoreCustomerLink."Shopify Store Code" = '') then
                        exit(false);
                    if not Customer.Get(SpfyStoreCustomerLink."No.") then
                        exit(false);
                    EntityTableNo := Database::Customer;
                    StoreCode := SpfyStoreCustomerLink."Shopify Store Code";
                    EntitySystemIdParam := Customer.SystemId;
                    exit(true);
                end;
        end;
        exit(false);
    end;

    // 3 triggers (Blocked, Not-Available, link unsync) dedup to ONE outbox row; only cancel when none still demands the delete, else the delete is lost. CheckLinkUnsync=false from the link's own OnValidate (its persisted state is stale mid-validation).
    local procedure OtherVariantDeactivationActive(ItemNo: Code[20]; VariantCode: Code[10]; ShopifyStoreCode: Code[20]; CheckLinkUnsync: Boolean): Boolean
    var
        ItemVariant: Record "Item Variant";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
    begin
        if ItemVariant.Get(ItemNo, VariantCode) then
            if ItemVariant.Blocked then
                exit(true);
        if SpfyItemVariantModif.Get(ItemNo, VariantCode, ShopifyStoreCode) then
            if SpfyItemVariantModif."Not Available" then
                exit(true);
        if CheckLinkUnsync then
            if SpfyStoreItemVariantLink.Get(SpfyStoreItemVariantLink.Type::Variant, ItemNo, VariantCode, ShopifyStoreCode) then
                if not SpfyStoreItemVariantLink."Sync. to this Store" then
                    exit(true);
        exit(false);
    end;

    // Drop the Sync State baseline when the entity row is physically deleted: its SystemId is gone, so the rowversion
    // poll can never revisit it to clean up.
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterDeleteEvent, '', false, false)]
    local procedure ItemOnAfterDelete_CleanupBaseline(var Rec: Record Item)
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::Item, Rec.SystemId);
        DeleteInventoryLevels(Rec.IsTemporary(), Rec."No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Variant", OnAfterDeleteEvent, '', false, false)]
    local procedure ItemVariantOnAfterDelete_CleanupBaseline(var Rec: Record "Item Variant")
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::"Item Variant", Rec.SystemId);
        DeleteInventoryLevels(Rec.IsTemporary(), Rec."Item No.", Rec.Code);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Store-Item Link", OnAfterDeleteEvent, '', false, false)]
    local procedure StoreItemLinkOnAfterDelete_CleanupBaseline(var Rec: Record "NPR Spfy Store-Item Link")
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::"NPR Spfy Store-Item Link", Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Store-Customer Link", OnAfterDeleteEvent, '', false, false)]
    local procedure StoreCustomerLinkOnAfterDelete_CleanupBaseline(var Rec: Record "NPR Spfy Store-Customer Link")
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::"NPR Spfy Store-Customer Link", Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Item Variant Modif.", OnAfterDeleteEvent, '', false, false)]
    local procedure ItemVariantModifOnAfterDelete_CleanupBaseline(var Rec: Record "NPR Spfy Item Variant Modif.")
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::"NPR Spfy Item Variant Modif.", Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher", OnAfterDeleteEvent, '', false, false)]
    local procedure VoucherOnAfterDelete_CleanupBaseline(var Rec: Record "NPR NpRv Voucher")
    begin
        RemoveEntityBaseline(Rec.IsTemporary(), Database::"NPR NpRv Voucher", Rec.SystemId);
    end;

    local procedure RemoveEntityBaseline(RecIsTemporary: Boolean; TableNo: Integer; EntitySystemIdParam: Guid)
    begin
        if RecIsTemporary then
            exit;
        SpfySyncStateMgt.RemoveBaselineAllStores(TableNo, EntitySystemIdParam);
    end;

    // A level row must not outlive its item: nothing else deletes it, and a task parked on it can never become sendable.
    local procedure DeleteInventoryLevels(RecIsTemporary: Boolean; ItemNo: Code[20]; VariantCode: Code[10])
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
    begin
        if RecIsTemporary or not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        InventoryLevel.SetCurrentKey("Item No.", "Variant Code");
        InventoryLevel.SetRange("Item No.", ItemNo);
        if VariantCode <> '' then
            InventoryLevel.SetRange("Variant Code", VariantCode);
        if not InventoryLevel.IsEmpty() then
            InventoryLevel.DeleteAll();
    end;
}
