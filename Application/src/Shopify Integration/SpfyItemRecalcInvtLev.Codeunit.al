#if not BC17
codeunit 6184813 "NPR Spfy Item Recalc.Invt.Lev."
{
    Access = Internal;
    TableNo = "NPR Spfy Store-Item Link";

    trigger OnRun()
    begin
        UpdateInventoryLevelsForItem(Rec);
    end;

    local procedure UpdateInventoryLevelsForItem(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Item: Record Item;
        InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
    begin
        if not Item.Get(SpfyStoreItemLink."Item No.") then
            exit;
        Item.SetRecFilter();
        If SpfyStoreItemLink."Variant Code" <> '' then
            Item.SetRange("Variant Filter", SpfyStoreItemLink."Variant Code");
        InventoryLevelMgt.InitializeInventoryLevels(SpfyStoreItemLink."Shopify Store Code", Item, true);
    end;
}
#endif