#if not BC17
codeunit 6184952 "NPR Spfy Order Webhook Handler" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Access = Internal;

    procedure ProcessWebhookNotification(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    begin
    end;

    procedure NavigateToRelatedBCEntity(SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    begin
    end;
}
#endif