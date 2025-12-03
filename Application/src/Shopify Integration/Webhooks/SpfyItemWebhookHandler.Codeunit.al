#if not BC17
codeunit 6184951 "NPR Spfy Item Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    var
        ItemNotFoundErr: Label 'The Shopify product ID "%1" is not associated with any item in Business Central.', Comment = '%1 - Shopify product identificator';

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        NcTask: Record "NPR Nc Task";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
        UnsupportedTopicErr: Label 'The webhook topic "%1" is not supported for item webhooks.', Comment = '%1 - Shopify webhook topic';
    begin
        if not IsEligibleForProcessing(SpfyWebhookNotification) then
            Error(UnsupportedTopicErr, SpfyWebhookNotification."Topic (Received)");

        case SpfyWebhookNotification.Topic of
            SpfyWebhookNotification.Topic::"products/create":
                NcTask.Type := NcTask.Type::Insert;
            SpfyWebhookNotification.Topic::"products/delete":
                NcTask.Type := NcTask.Type::Delete;
            SpfyWebhookNotification.Topic::"products/update":
                NcTask.Type := NcTask.Type::Modify;
        end;
        NcTask."Store Code" := SpfyWebhookNotification.GetStoreCode();

        SpfyWebhookNotifParser.UpdateSourceIDFromPayload(SpfyWebhookNotification);
        SendItemAndInventory.RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask, SpfyWebhookNotification."Triggered for Source ID", true, false);

        SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Processed;
        SpfyWebhookNotification."Number of Process Attempts" += 1;
        SpfyWebhookNotification."Processed at" := CurrentDateTime();
        SpfyWebhookNotification.Modify();
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if not IsEligibleForProcessing(SpfyWebhookNotification) then
            exit;

        FindStoreItemLink(SpfyWebhookNotification, SpfyStoreItemLink);
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

    local procedure IsEligibleForProcessing(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification"): Boolean
    begin
        exit(SpfyWebhookNotification.Topic in
            [SpfyWebhookNotification.Topic::"products/create",
             SpfyWebhookNotification.Topic::"products/delete",
             SpfyWebhookNotification.Topic::"products/update"]);
    end;

    local procedure FindStoreItemLink(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification"; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
    begin
        if SpfyWebhookNotification."Triggered for Source ID" = '' then
            SpfyWebhookNotifParser.UpdateSourceIDFromPayload(SpfyWebhookNotification);
        SpfyWebhookNotification.TestField("Triggered for Source ID");
        if not SpfyItemMgt.FindItemByShopifyProductID(SpfyWebhookNotification.GetStoreCode(), SpfyWebhookNotification."Triggered for Source ID", SpfyStoreItemLink) then
            Error(ItemNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
    end;

    internal procedure WebhookSubscriptionFields() IncludeFields: List of [Text]
    begin
        IncludeFields.Add('id');
        IncludeFields.Add('title');
        IncludeFields.Add('status');
        IncludeFields.Add('updated_at');
    end;
}
#endif