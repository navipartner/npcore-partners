#if not BC17
codeunit 6184932 "NPR Spfy Webhook Webservice"
{
    Access = Public;

    procedure ReceiveWebhook(json: Text): Text
    var
        SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
    begin
        SpfyWebhookNotifParser.SetWebhook(json);
        SpfyWebhookNotifParser.Run();
        exit(SpfyWebhookNotifParser.GetResponse());
    end;
}
#endif