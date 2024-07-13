#if not BC17
codeunit 6184950 "NPR Spfy Undef.Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    begin
        ThrowNoHandlerError(SpfyWebhookNotification.Topic);
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    begin
        ThrowNoHandlerError(SpfyWebhookNotification.Topic);
    end;

    local procedure ThrowNoHandlerError(Topic: Enum "NPR Spfy Webhook Topic")
    var
        NoHandlerErr: Label 'There is no handler registered in the system for Shopify webhook notifications of type "%1"', Comment = '%1 - Shopify webhook topic';
    begin
        Error(NoHandlerErr, Topic);
    end;
}
#endif