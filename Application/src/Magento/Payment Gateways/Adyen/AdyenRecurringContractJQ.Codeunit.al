codeunit 6185118 "NPR Adyen Recurring ContractJQ"
{
    Access = Internal;
    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenWebhookLogType: Enum "NPR Adyen Webhook Log Type";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin
        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::RECURRING_CONTRACT);
        AdyenWebhook.SetRange("Webhook Type", AdyenWebhook."Webhook Type"::"Pay by Link");
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                if not WebhookProcessing.Run(AdyenWebhook) then begin
                    AdyenManagement.CreateGeneralLog(AdyenWebhookLogType::Error, false, GetLastErrorText(), AdyenWebhook."Entry No.");
                    AdyenWebhook.Status := AdyenWebhook.Status::Error;
                    AdyenWebhook.Modify();
                    Commit();
                end;
            until AdyenWebhook.Next() = 0;
    end;
}