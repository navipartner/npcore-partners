codeunit 6151230 "NPR Spfy Invt. Delete Subscr."
{
    Access = Internal;

    var
        SpfyInventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterDeleteEvent, '', false, false)]
    local procedure SalesLineOnAfterDelete(var Rec: Record "Sales Line")
    var
        TempOldSalesLine: Record "Sales Line" temporary;
        HadOld: Boolean;
    begin
        if Rec.IsTemporary() or not SpfyChangeTrackerMgt.InventoryOnRowVersionPoll() then
            exit;

        // OLD key FIRST — line may have moved; recover it before any scope check
        HadOld := SpfySyncStateMgt.GetSalesLineInvKey(Rec.SystemId, TempOldSalesLine);
        if HadOld then
            SpfyInventoryLevelMgt.RecalcKey(TempOldSalesLine."No.", TempOldSalesLine."Variant Code", TempOldSalesLine."Location Code");
        if SpfyInventoryLevelMgt.SalesLineInScope(Rec) and
           (HadOld or SpfyInventoryLevelMgt.IsShopifyInventoryItem(Rec."No.")) and
           ((not HadOld) or
            (TempOldSalesLine."No." <> Rec."No.") or
            (TempOldSalesLine."Variant Code" <> Rec."Variant Code") or
            (TempOldSalesLine."Location Code" <> Rec."Location Code"))
        then
            SpfyInventoryLevelMgt.RecalcKey(Rec."No.", Rec."Variant Code", Rec."Location Code");
        // RemoveBaseline unconditional — no orphan
        SpfySyncStateMgt.RemoveBaseline(Database::"Sales Line", Rec.SystemId, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnAfterDeleteEvent, '', false, false)]
    local procedure TransferLineOnAfterDelete(var Rec: Record "Transfer Line")
    var
        TempOldTransferLine: Record "Transfer Line" temporary;
        HadOld: Boolean;
    begin
        if Rec.IsTemporary() or not SpfyChangeTrackerMgt.InventoryOnRowVersionPoll() then
            exit;

        HadOld := SpfySyncStateMgt.GetTransferLineInvKey(Rec.SystemId, TempOldTransferLine);
        if HadOld then begin
            SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-from Code");
            SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-to Code");
        end;
        if SpfyInventoryLevelMgt.TransferLineInScope(Rec) and
           (HadOld or SpfyInventoryLevelMgt.IsShopifyInventoryItem(Rec."Item No.")) and
           ((not HadOld) or
            (TempOldTransferLine."Item No." <> Rec."Item No.") or
            (TempOldTransferLine."Variant Code" <> Rec."Variant Code") or
            (TempOldTransferLine."Transfer-from Code" <> Rec."Transfer-from Code") or
            (TempOldTransferLine."Transfer-to Code" <> Rec."Transfer-to Code"))
        then begin
            SpfyInventoryLevelMgt.RecalcKey(Rec."Item No.", Rec."Variant Code", Rec."Transfer-from Code");
            SpfyInventoryLevelMgt.RecalcKey(Rec."Item No.", Rec."Variant Code", Rec."Transfer-to Code");
        end;
        SpfySyncStateMgt.RemoveBaseline(Database::"Transfer Line", Rec.SystemId, '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit", OnAfterDeleteEvent, '', false, false)]
    local procedure SKUOnAfterDelete(var Rec: Record "Stockkeeping Unit")
    var
        TempOldSKU: Record "Stockkeeping Unit" temporary;
        HadOld: Boolean;
    begin
        if Rec.IsTemporary() or not SpfyChangeTrackerMgt.InventoryOnRowVersionPoll() then
            exit;

        // OLD key FIRST — the SKU may have been repurposed (variant/location) since its baseline; recover it before scope check
        HadOld := SpfySyncStateMgt.GetSkuInvKey(Rec.SystemId, TempOldSKU);
        if HadOld then
            SpfyInventoryLevelMgt.RecalcKey(TempOldSKU."Item No.", TempOldSKU."Variant Code", TempOldSKU."Location Code");
        if (HadOld or SpfyInventoryLevelMgt.IsShopifyInventoryItem(Rec."Item No.")) and
           ((not HadOld) or
            (TempOldSKU."Item No." <> Rec."Item No.") or
            (TempOldSKU."Variant Code" <> Rec."Variant Code") or
            (TempOldSKU."Location Code" <> Rec."Location Code"))
        then
            SpfyInventoryLevelMgt.RecalcKey(Rec."Item No.", Rec."Variant Code", Rec."Location Code");
        // RemoveBaseline unconditional — no orphan Sync State row
        SpfySyncStateMgt.RemoveBaseline(Database::"Stockkeeping Unit", Rec.SystemId, '');
    end;
}
