codeunit 6151191 "NPR Spfy Chg Hdlr Item Prices" implements "NPR Spfy Change Handler"
{
    Access = Internal;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";

    procedure ProcessChange(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    begin
        if DetectedChange.ChangeType() = "NPR Spfy Change Type"::Delete then
            exit(false);
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices") then
            exit(false);
        case DetectedChange.TableNo() of
            Database::"NPR Spfy Item Price":
                exit(ProcessItemPrice(DetectedChange));
        end;
        exit(false);
    end;

    local procedure ProcessItemPrice(var DetectedChange: Codeunit "NPR Spfy Detected Change"): Boolean
    var
        ItemPrice: Record "NPR Spfy Item Price";
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        VariantSku: Text;
    begin
        if not ItemPrice.GetBySystemId(DetectedChange.SystemId()) then
            exit(false);
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Prices", ItemPrice."Shopify Store Code") then
            exit(false);
        if not Item.Get(ItemPrice."Item No.") then
            exit(false);
        Item.SetRange("NPR Spfy Store Filter", ItemPrice."Shopify Store Code");
        if not SpfyItemMgt.TestRequiredInvFields(Item) then
            exit(false);

        VariantSku := SpfyItemMgt.GetProductVariantSku(ItemPrice."Item No.", ItemPrice."Variant Code");
        RecRef.GetTable(ItemPrice);
        Clear(NcTask);
        exit(SpfyScheduleSend.InitNcTask(ItemPrice."Shopify Store Code", RecRef, RecRef.RecordId(), VariantSku, NcTask.Type::Modify, ItemPrice.SystemModifiedAt, CreateDateTime(ItemPrice."Starting Date", 0T), Enum::"NPR Spfy Reuse Delayed NC Task"::No, NcTask));
    end;
}
