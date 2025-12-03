#if not BC17
codeunit 6248665 "NPR Spfy Cust. Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    var
        CustomerNotFoundErr: Label 'The Shopify customer ID "%1" is not associated with any customer in Business Central.', Comment = '%1 - Shopify customer identificator';

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
        UnsupportedTopicErr: Label 'The webhook topic "%1" is not supported for customer webhooks.', Comment = '%1 - Shopify webhook topic';
    begin
        if not IsEligibleForProcessing(SpfyWebhookNotification) then
            Error(UnsupportedTopicErr, SpfyWebhookNotification."Topic (Received)");

        FindStoreCustomerLink(SpfyWebhookNotification, SpfyStoreCustomerLink);
        SpfyStoreCustomerLink.FindSet();
        repeat
            SpfySendCustomers.RetrieveShopifyCustomerAndUpdateBCCustomerWithDataFromShopify(
                SpfyStoreCustomerLink, SpfyWebhookNotification."Triggered for Source ID", SpfyWebhookNotification.Topic = SpfyWebhookNotification.Topic::"customers/delete", true, false);
        until SpfyStoreCustomerLink.Next() = 0;

        SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Processed;
        SpfyWebhookNotification."Number of Process Attempts" += 1;
        SpfyWebhookNotification."Processed at" := CurrentDateTime();
        SpfyWebhookNotification.Modify();
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if not IsEligibleForProcessing(SpfyWebhookNotification) then
            exit;

        FindStoreCustomerLink(SpfyWebhookNotification, SpfyStoreCustomerLink);
        SpfyStoreCustomerLink.FindSet();
        repeat
            Customer."No." := SpfyStoreCustomerLink."No.";
            Customer.Mark(true);
        until SpfyStoreCustomerLink.Next() = 0;

        Customer.MarkedOnly(true);
        Case Customer.Count() of
            0:
                Error(CustomerNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
            1:
                Page.Run(Page::"Customer Card", Customer);
            else
                Page.Run(Page::"Customer List", Customer);
        end;
    end;

    local procedure IsEligibleForProcessing(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification"): Boolean
    begin
        exit(SpfyWebhookNotification.Topic in
            [SpfyWebhookNotification.Topic::"customers/create",
             SpfyWebhookNotification.Topic::"customers/delete",
             SpfyWebhookNotification.Topic::"customers/update"]);
    end;

    local procedure FindStoreCustomerLink(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification"; var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
    begin
        if SpfyWebhookNotification."Triggered for Source ID" = '' then
            SpfyWebhookNotifParser.UpdateSourceIDFromPayload(SpfyWebhookNotification);
        SpfyWebhookNotification.TestField("Triggered for Source ID");
        if not SpfyCustomerMgt.FindCustomerByShopifyID(SpfyWebhookNotification.GetStoreCode(), SpfyWebhookNotification."Triggered for Source ID", SpfyStoreCustomerLink) then
            Error(CustomerNotFoundErr, SpfyWebhookNotification."Triggered for Source ID");
    end;

    internal procedure WebhookSubscriptionFields() IncludeFields: List of [Text]
    begin
        IncludeFields.Add('id');
        IncludeFields.Add('first_name');
        IncludeFields.Add('last_name');
        IncludeFields.Add('email');
        IncludeFields.Add('phone');
        IncludeFields.Add('updated_at');
    end;
}
#endif