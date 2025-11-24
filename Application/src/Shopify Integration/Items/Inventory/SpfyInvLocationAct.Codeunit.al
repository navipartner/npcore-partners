#if not BC17
codeunit 6248653 "NPR Spfy Inv. Location Act."
{
    Access = Internal;
    internal procedure IsLocationActivated(var LocationInvItem: Record "NPR Spfy Inv Item Location"; InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    begin
        LocationInvItem."Shopify Store Code" := InventoryLevel."Shopify Store Code";
        LocationInvItem."Shopify Location ID" := InventoryLevel."Shopify Location ID";
        LocationInvItem."Item No." := InventoryLevel."Item No.";
        LocationInvItem."Variant Code" := InventoryLevel."Variant Code";
        if not LocationInvItem.Find() then begin
            LocationInvItem.Init();
            LocationInvItem.Insert(true);
        end;
        exit(LocationInvItem.Activated);
    end;

    local procedure CreateNcTask(LocationInvItem: Record "NPR Spfy Inv Item Location"): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
    begin
        VariantSku := SpfyItemMgt.GetProductVariantSku(LocationInvItem."Item No.", LocationInvItem."Variant Code");
        RecRef.GetTable(LocationInvItem);
        exit(SpfyScheduleSend.InitNcTask(LocationInvItem."Shopify Store Code", RecRef, VariantSku, NcTask.Type::Insert, CurrentDateTime() + 1000, NcTask));
    end;

    internal procedure IsInventoryItemActivationRequired(InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        exit(not IsLocationActivated(LocationInvItem, InventoryLevel));
    end;

    internal procedure CreateNcTaskActivateInvLocation(InventoryLevel: Record "NPR Spfy Inventory Level"; Force: Boolean): Boolean
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        if not IsLocationActivated(LocationInvItem, InventoryLevel) or Force then
            exit(CreateNcTask(LocationInvItem));
    end;

    internal procedure IsNotStockedAtLocationErr(UserErrorText: Text): Boolean
    begin
        exit(UserErrorText.Contains('is not stocked at the location'));
    end;
}
#endif