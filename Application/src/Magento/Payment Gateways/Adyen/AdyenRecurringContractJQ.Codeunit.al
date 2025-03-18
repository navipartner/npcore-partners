codeunit 6185118 "NPR Adyen Recurring ContractJQ"
{
    Access = Internal;
    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin
        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::RECURRING_CONTRACT);
        AdyenWebhook.SetRange("Webhook Type", AdyenWebhook."Webhook Type"::"Pay by Link");
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                WebhookProcessing.Run(AdyenWebhook);
            until AdyenWebhook.Next() = 0;
    end;
}