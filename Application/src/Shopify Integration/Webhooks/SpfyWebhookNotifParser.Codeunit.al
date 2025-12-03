#if not BC17
codeunit 6184930 "NPR Spfy Webhook Notif. Parser"
{
    Access = Internal;

    var
        _AFPayloadTxt: Text;

    trigger OnRun()
    begin
        RegisterSpfyWebhookNotification();
    end;

    local procedure RegisterSpfyWebhookNotification()
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
    begin
        ClearLastError();
        SpfyWebhookNotification.Init();
        SpfyWebhookNotification."Entry No." := 0;
        SpfyWebhookNotification.SetAFRawPayload(_AFPayloadTxt);
        if not TryReadNotificationDetails(SpfyWebhookNotification) then begin
            SpfyWebhookNotification.Status := SpfyWebhookNotification.Status::Error;
            SpfyWebhookNotification.SetErrorMessage(GetLastErrorText());
        end;
        SpfyWebhookNotification.Insert();
    end;

    [TryFunction]
    internal procedure TryReadNotificationDetails(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        AFPayload: JsonToken;
        ShopifyWebhookDetails: JsonToken;
    begin
        AFPayload.ReadFrom(_AFPayloadTxt);
        ShopifyWebhookDetails := JsonHelper.GetJsonToken(AFPayload, 'HeadersDictionary');
#pragma warning disable AA0139
        SpfyWebhookNotification."Api Version" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Api-Version', MaxStrLen(SpfyWebhookNotification."Api Version"), false);
        SpfyWebhookNotification."Event ID" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Event-Id', MaxStrLen(SpfyWebhookNotification."Event ID"), false);
        //SpfyWebhookNotification."HMAC" := JsonHelper.GetJText(WebhookDetails, 'X-Shopify-Hmac-Sha256', MaxStrLen(SpfyWebhookNotification."HMAC"), false);
        SpfyWebhookNotification."Triggered for Source ID" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Product-Id', MaxStrLen(SpfyWebhookNotification."Triggered for Source ID"), false);
        SpfyWebhookNotification."Shop Domain" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Shop-Domain', MaxStrLen(SpfyWebhookNotification."Shop Domain"), false);
        SpfyWebhookNotification."Topic (Received)" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Topic', MaxStrLen(SpfyWebhookNotification."Topic (Received)"), false);
        SpfyWebhookNotification."Triggered At" := JsonHelper.GetJDT(ShopifyWebhookDetails, 'X-Shopify-Triggered-At', false);
        SpfyWebhookNotification."Webhook ID" := JsonHelper.GetJText(ShopifyWebhookDetails, 'X-Shopify-Webhook-Id', MaxStrLen(SpfyWebhookNotification."Webhook ID"), false);
#pragma warning restore AA0139

        //read the original Shopify content payload through a text to remove the escape characters added by double searialization
        ShopifyWebhookDetails.ReadFrom(JsonHelper.GetJText(AFPayload, 'Content', true));
        if SpfyWebhookNotification."Triggered for Source ID" = '' then
#pragma warning disable AA0139
            SpfyWebhookNotification."Triggered for Source ID" := JsonHelper.GetJText(ShopifyWebhookDetails, 'id', MaxStrLen(SpfyWebhookNotification."Triggered for Source ID"), false);
#pragma warning restore AA0139
        SpfyWebhookNotification.SetPayload(ShopifyWebhookDetails);

        IdentifyTopic(SpfyWebhookNotification);
    end;

    internal procedure IdentifyTopic(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        UnsupportedTopicErr: Label 'The webhook topic "%1" is not supported.', Comment = '%1 - Shopify webhook topic';
    begin
        if not TryParseTopic(SpfyWebhookNotification."Topic (Received)", SpfyWebhookNotification.Topic) then
            Error(UnsupportedTopicErr, SpfyWebhookNotification."Topic (Received)");
    end;

    [TryFunction]
    internal procedure TryParseTopic(TopicAsText: Text; var Topic: Enum "NPR Spfy Webhook Topic")
    begin
        Topic := Enum::"NPR Spfy Webhook Topic".FromInteger(Enum::"NPR Spfy Webhook Topic".Ordinals().Get(Enum::"NPR Spfy Webhook Topic".Names().IndexOf(TopicAsText)));
    end;

    internal procedure UpdateSourceIDFromPayload(var SpfyWebhookNotification: Record "NPR Spfy Webhook Notification")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ShopifyPayload: JsonToken;
    begin
        ShopifyPayload.ReadFrom(SpfyWebhookNotification.GetPayloadStream());
#pragma warning disable AA0139
        SpfyWebhookNotification."Triggered for Source ID" := JsonHelper.GetJText(ShopifyPayload, 'id', MaxStrLen(SpfyWebhookNotification."Triggered for Source ID"), true);
#pragma warning restore AA0139
    end;

    internal procedure SetWebhook(json: Text)
    begin
        _AFPayloadTxt := json;
    end;

    internal procedure GetResponse(): Text
    var
        SuccessLbl: Label 'Successfully registered.';
    begin
        exit(SuccessLbl);
    end;
}
#endif