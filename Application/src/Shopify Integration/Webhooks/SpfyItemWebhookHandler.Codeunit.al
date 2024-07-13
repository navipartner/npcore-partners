#if not BC17
codeunit 6184951 "NPR Spfy Item Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        NcTask: Record "NPR Nc Task";
        ShopifyStore: Record "NPR Spfy Store";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        ShopifyPayload: JsonToken;
        ShopifyProductJOb: JsonObject;
    begin
        case SpfyWebhookNotification.Topic of
            SpfyWebhookNotification.Topic::"products/create":
                NcTask.Type := NcTask.Type::Insert;
            SpfyWebhookNotification.Topic::"products/delete":
                NcTask.Type := NcTask.Type::Delete;
            SpfyWebhookNotification.Topic::"products/update":
                NcTask.Type := NcTask.Type::Modify;
        end;
        ShopifyStore.SetFilter("Shopify Url", StrSubstNo('@*%1*', SpfyWebhookNotification."Shop Domain"));
        ShopifyStore.SetRange(Enabled, true);
        ShopifyStore.FindFirst();
        NcTask."Store Code" := ShopifyStore.Code;

        ShopifyPayload.ReadFrom(SpfyWebhookNotification.GetPayloadStream());
        ShopifyProductJOb.Add('product', ShopifyPayload.AsObject());
        SendItemAndInventory.UpdateItemWithDataFromShopify(NcTask, ShopifyProductJOb.AsToken(), true);

        SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Processed;
        SpfyWebhookNotification."Number of Process Attempts" += 1;
        SpfyWebhookNotification."Processed at" := CurrentDateTime();
        SpfyWebhookNotification.Modify();
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        Item: Record Item;
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        Found: Boolean;
        ItemNotFoundErr: Label 'The Shopify product ID "%1" is not associated with any item in Business Central.', Comment = '%1 - Shopify product identificator';
    begin
        if not (SpfyWebhookNotification.Topic in
            [SpfyWebhookNotification.Topic::"products/create",
             SpfyWebhookNotification.Topic::"products/delete",
             SpfyWebhookNotification.Topic::"products/update"])
        then
            exit;
        SpfyWebhookNotification.TestField("Triggered for Source ID");
        SpfyAssignedIDMgt.FilterWhereUsedInTable(
            Database::"NPR Spfy Store-Item Link", "NPR Spfy ID Type"::"Entry ID", SpfyWebhookNotification."Triggered for Source ID", ShopifyAssignedID);
        if ShopifyAssignedID.Find('-') then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SpfyStoreItemLink);
                    if SpfyStoreItemLink."Item No." <> '' then begin
                        Item."No." := SpfyStoreItemLink."Item No.";
                        Found := Item.Find();
                    end;
                end;
            until Found or (ShopifyAssignedID.Next() = 0);
        if not Found then
            Error(ItemNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
        Page.Run(Page::"Item Card", Item);
    end;
}
#endif