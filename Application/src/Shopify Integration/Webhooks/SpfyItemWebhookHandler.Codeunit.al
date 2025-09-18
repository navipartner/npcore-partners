#if not BC17
codeunit 6184951 "NPR Spfy Item Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        ShopifyPayload: JsonToken;
        ShopifyProductID: Text[30];
    begin
        case SpfyWebhookNotification.Topic of
            SpfyWebhookNotification.Topic::"products/create":
                NcTask.Type := NcTask.Type::Insert;
            SpfyWebhookNotification.Topic::"products/delete":
                NcTask.Type := NcTask.Type::Delete;
            SpfyWebhookNotification.Topic::"products/update":
                NcTask.Type := NcTask.Type::Modify;
        end;
        NcTask."Store Code" := SpfyWebhookNotification.GetStoreCode();

        ShopifyPayload.ReadFrom(SpfyWebhookNotification.GetPayloadStream());
#pragma warning disable AA0139        
        ShopifyProductID := JsonHelper.GetJText(ShopifyPayload, 'id', MaxStrLen(ShopifyProductID), true);
#pragma warning restore AA0139
        SendItemAndInventory.RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask, ShopifyProductID, true, false);

        SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Processed;
        SpfyWebhookNotification."Number of Process Attempts" += 1;
        SpfyWebhookNotification."Processed at" := CurrentDateTime();
        SpfyWebhookNotification.Modify();
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        ItemNotFoundErr: Label 'The Shopify product ID "%1" is not associated with any item in Business Central.', Comment = '%1 - Shopify product identificator';
    begin
        if not (SpfyWebhookNotification.Topic in
            [SpfyWebhookNotification.Topic::"products/create",
             SpfyWebhookNotification.Topic::"products/delete",
             SpfyWebhookNotification.Topic::"products/update"])
        then
            exit;

        SpfyWebhookNotification.TestField("Triggered for Source ID");
        if not SpfyItemMgt.FindItemByShopifyProductID(SpfyWebhookNotification.GetStoreCode(), SpfyWebhookNotification."Triggered for Source ID", SpfyStoreItemLink) then
            Error(ItemNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
        SpfyStoreItemLink.FindSet();
        repeat
            Item."No." := SpfyStoreItemLink."Item No.";
            Item.Mark(true);
        until SpfyStoreItemLink.Next() = 0;

        Item.MarkedOnly(true);
        Case Item.Count() of
            0:
                Error(ItemNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
            1:
                Page.Run(Page::"Item Card", Item);
            else
                Page.Run(Page::"Item List", Item);
        end;
    end;
}
#endif