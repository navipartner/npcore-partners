codeunit 6248227 "NPR Adyen Refund Status JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin

        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::REFUND);
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                WebhookProcessing.Run(AdyenWebhook);
            until AdyenWebhook.Next() = 0;
    end;
}