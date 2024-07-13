#if not BC17
interface "NPR Spfy Webhook Notif. IHndlr"
{
    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification");
    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification");
}
#endif