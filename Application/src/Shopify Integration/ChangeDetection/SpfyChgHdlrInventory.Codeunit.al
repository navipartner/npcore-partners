codeunit 6151190 "NPR Spfy Chg Hdlr Inventory" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyInventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(false);
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
            exit(false);

        case DetectedChange.TableNo() of
            Database::"Item Ledger Entry":
                exit(ProcessILE(DetectedChange));
            Database::"Sales Line":
                exit(ProcessSalesLine(DetectedChange));
            Database::"Transfer Line":
                exit(ProcessTransferLine(DetectedChange));
            Database::"Stockkeeping Unit":
                exit(ProcessSKU(DetectedChange));
            Database::"NPR Spfy Inventory Level":
                exit(ProcessInventoryLevelSend(DetectedChange));
        end;
        exit(false);
    end;

    local procedure ProcessILE(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if not ItemLedgerEntry.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if not SpfyInventoryLevelMgt.IsShopifyInventoryItem(ItemLedgerEntry."Item No.") then   // perf gate (CORE-433 7d)
            exit(false);
        SpfyInventoryLevelMgt.RecalcKey(ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", ItemLedgerEntry."Location Code");
        exit(false);
    end;

    local procedure ProcessSalesLine(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        SalesLine: Record "Sales Line";
        TempOldSalesLine: Record "Sales Line" temporary;
        HadOld: Boolean;
    begin
        if not SalesLine.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        HadOld := SpfySyncStateMgt.GetSalesLineInvKey(SalesLine.SystemId, TempOldSalesLine);   // read baseline before it is overwritten below

        // Perf gate (CORE-433 7d): skip only when there's no baseline AND not a Shopify inventory item; HadOld must fall through to clear stale key + facet.
        if (not HadOld) and (not SpfyInventoryLevelMgt.IsShopifyInventoryItem(SalesLine."No.")) then
            exit(false);

        if not SpfyInventoryLevelMgt.SalesLineInScope(SalesLine) then begin
            if HadOld then begin
                SpfyInventoryLevelMgt.RecalcKey(TempOldSalesLine."No.", TempOldSalesLine."Variant Code", TempOldSalesLine."Location Code");
                SpfySyncStateMgt.RemoveBaseline(Database::"Sales Line", SalesLine.SystemId, '');
            end;
            exit(false);
        end;

        if HadOld and
           (TempOldSalesLine."No." = SalesLine."No.") and
           (TempOldSalesLine."Variant Code" = SalesLine."Variant Code") and
           (TempOldSalesLine."Location Code" = SalesLine."Location Code") and
           (TempOldSalesLine."Outstanding Qty. (Base)" = SalesLine."Outstanding Qty. (Base)")
        then
            exit(false);

        SpfyInventoryLevelMgt.RecalcKey(SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code");
        if HadOld and
           ((TempOldSalesLine."No." <> SalesLine."No.") or
            (TempOldSalesLine."Variant Code" <> SalesLine."Variant Code") or
            (TempOldSalesLine."Location Code" <> SalesLine."Location Code"))
        then
            SpfyInventoryLevelMgt.RecalcKey(TempOldSalesLine."No.", TempOldSalesLine."Variant Code", TempOldSalesLine."Location Code");

        SpfySyncStateMgt.SetSalesLineInvKey(SalesLine);
        exit(false);
    end;

    local procedure ProcessTransferLine(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        TransferLine: Record "Transfer Line";
        TempOldTransferLine: Record "Transfer Line" temporary;
        HadOld: Boolean;
    begin
        if not TransferLine.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        HadOld := SpfySyncStateMgt.GetTransferLineInvKey(TransferLine.SystemId, TempOldTransferLine);   // read baseline before it is overwritten below

        // Perf gate (CORE-433 7d): skip only when there's no baseline AND not a Shopify inventory item; HadOld must fall through to clear stale (from, to) keys.
        if (not HadOld) and (not SpfyInventoryLevelMgt.IsShopifyInventoryItem(TransferLine."Item No.")) then
            exit(false);

        if not SpfyInventoryLevelMgt.TransferLineInScope(TransferLine) then begin
            if HadOld then begin
                SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-from Code");
                SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-to Code");
                SpfySyncStateMgt.RemoveBaseline(Database::"Transfer Line", TransferLine.SystemId, '');
            end;
            exit(false);
        end;

        if HadOld and
           (TempOldTransferLine."Item No." = TransferLine."Item No.") and
           (TempOldTransferLine."Variant Code" = TransferLine."Variant Code") and
           (TempOldTransferLine."Transfer-from Code" = TransferLine."Transfer-from Code") and
           (TempOldTransferLine."Transfer-to Code" = TransferLine."Transfer-to Code") and
           (TempOldTransferLine."Outstanding Qty. (Base)" = TransferLine."Outstanding Qty. (Base)") and
           (TempOldTransferLine."Qty. in Transit (Base)" = TransferLine."Qty. in Transit (Base)")
        then
            exit(false);

        SpfyInventoryLevelMgt.RecalcKey(TransferLine."Item No.", TransferLine."Variant Code", TransferLine."Transfer-from Code");
        SpfyInventoryLevelMgt.RecalcKey(TransferLine."Item No.", TransferLine."Variant Code", TransferLine."Transfer-to Code");

        if HadOld and
           ((TempOldTransferLine."Item No." <> TransferLine."Item No.") or
            (TempOldTransferLine."Variant Code" <> TransferLine."Variant Code") or
            (TempOldTransferLine."Transfer-from Code" <> TransferLine."Transfer-from Code") or
            (TempOldTransferLine."Transfer-to Code" <> TransferLine."Transfer-to Code"))
        then begin
            SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-from Code");
            SpfyInventoryLevelMgt.RecalcKey(TempOldTransferLine."Item No.", TempOldTransferLine."Variant Code", TempOldTransferLine."Transfer-to Code");
        end;

        SpfySyncStateMgt.SetTransferLineInvKey(TransferLine);
        exit(false);
    end;

    local procedure ProcessSKU(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        SKU: Record "Stockkeeping Unit";
        TempOldSKU: Record "Stockkeeping Unit" temporary;
        HadOld: Boolean;
    begin
        if not SKU.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        HadOld := SpfySyncStateMgt.GetSkuInvKey(SKU.SystemId, TempOldSKU);

        // Perf gate: skip only when there's no baseline AND not a Shopify inventory item; HadOld must fall through to correct the old key.
        if (not HadOld) and (not SpfyInventoryLevelMgt.IsShopifyInventoryItem(SKU."Item No.")) then
            exit(false);

        // Compare the full inventory key, not just safety stock: a SKU whose variant/location was repurposed keeps the same
        // safety-stock quantity but points at a different inventory level, so quantity-only equality would silently miss it.
        if HadOld and
           (TempOldSKU."Item No." = SKU."Item No.") and
           (TempOldSKU."Variant Code" = SKU."Variant Code") and
           (TempOldSKU."Location Code" = SKU."Location Code") and
           (TempOldSKU."NPR Spfy Safety Stock Quantity" = SKU."NPR Spfy Safety Stock Quantity")
        then
            exit(false);

        SpfyInventoryLevelMgt.RecalcKey(SKU."Item No.", SKU."Variant Code", SKU."Location Code");
        if HadOld and
           ((TempOldSKU."Item No." <> SKU."Item No.") or
            (TempOldSKU."Variant Code" <> SKU."Variant Code") or
            (TempOldSKU."Location Code" <> SKU."Location Code"))
        then
            SpfyInventoryLevelMgt.RecalcKey(TempOldSKU."Item No.", TempOldSKU."Variant Code", TempOldSKU."Location Code");

        SpfySyncStateMgt.SetSkuInvKey(SKU);
        exit(false);
    end;

    local procedure ProcessInventoryLevelSend(var DetectedChange: Codeunit "NPR Spfy Detected Change") TaskCreated: Boolean
    var
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
        SpfyItemTaskBuilder: Codeunit "NPR Spfy Item Task Builder";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
        VariantSku: Text;
    begin
        if not SpfyInventoryLevel.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels", SpfyInventoryLevel."Shopify Store Code") then
            exit(false);
        if not Item.Get(SpfyInventoryLevel."Item No.") then
            exit(false);
        Item.SetRange("NPR Spfy Store Filter", SpfyInventoryLevel."Shopify Store Code");
        if not SpfyItemMgt.TestRequiredInvFields(Item) then
            exit(false);
        SpfyInvLocationAct.CreateNcTaskActivateInvLocation(SpfyInventoryLevel, false);

        VariantSku := SpfyItemTaskBuilder.GetProductVariantSku(SpfyInventoryLevel."Item No.", SpfyInventoryLevel."Variant Code");

        RecRef.GetTable(SpfyInventoryLevel);
        TaskCreated := SpfyScheduleSend.InitNcTask(SpfyInventoryLevel."Shopify Store Code", RecRef, VariantSku, NcTask.Type::Modify, SpfyInventoryLevel."Last Updated at", NcTask);
    end;
}
