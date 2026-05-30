#if not BC17
codeunit 6248653 "NPR Spfy Inv. Location Act."
{
    Access = Internal;
    internal procedure FindLocationRecord(var LocationInvItem: Record "NPR Spfy Inv Item Location"; InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    begin
        LocationInvItem.Init();
        LocationInvItem."Shopify Store Code" := InventoryLevel."Shopify Store Code";
        LocationInvItem."Shopify Location ID" := InventoryLevel."Shopify Location ID";
        LocationInvItem."Item No." := InventoryLevel."Item No.";
        LocationInvItem."Variant Code" := InventoryLevel."Variant Code";
        exit(LocationInvItem.Find());
    end;

    internal procedure IsLocationActivated(var LocationInvItem: Record "NPR Spfy Inv Item Location"; InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    begin
        if not FindLocationRecord(LocationInvItem, InventoryLevel) then
            LocationInvItem.Insert(true);
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

    internal procedure CreateNcTaskActivateInvLocation(InventoryLevel: Record "NPR Spfy Inventory Level"; Force: Boolean): Boolean
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        if IsLocationActivated(LocationInvItem, InventoryLevel) and not Force then
            exit(false);
        if LocationInvItem."Auto-Activation Disabled" then
            exit(false);
        exit(CreateNcTask(LocationInvItem));
    end;

    internal procedure HandleNotStockedAtLocation(InventoryLevel: Record "NPR Spfy Inventory Level"): Boolean
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        if IsLocationActivated(LocationInvItem, InventoryLevel) then begin
            //BC had successfully activated this variant at this location before, yet Shopify now reports
            //it as not stocked => the merchant deliberately deactivated it in Shopify Admin. Respect that:
            //stop auto-(re)activating, and clear the cache so clearing the flag later resumes activation.
            LocationInvItem.Validate("Auto-Activation Disabled", true);
            LocationInvItem.Modify();
            exit(true);
        end;
        CreateNcTaskActivateInvLocation(InventoryLevel, true);
        exit(false);
    end;

    internal procedure IsNotStockedAtLocationErr(UserErrorText: Text): Boolean
    begin
        exit(UserErrorText.Contains('is not stocked at the location'));
    end;
}
#endif