codeunit 6184933 "NPR Adyen PayByLink Status JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin
        if not IsSetupEnabled() then
            exit;

        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::AUTHORISATION);
        AdyenWebhook.SetRange("Webhook Type", AdyenWebhook."Webhook Type"::"Pay by Link");
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                WebhookProcessing.Run(AdyenWebhook);
            until AdyenWebhook.Next() = 0;
    end;

    local procedure IsSetupEnabled() SetupEnabled: Boolean;
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        SetupEnabled := false;

        //Magento PayByLink
        if AdyenManagement.IsMagentoPayByLinkEnabled() then
            SetupEnabled := true;

        //Subscription PayByLink Card Update
        If AdyenManagement.IsSubsPGEnabled() then
            SetupEnabled := true;
    end;
}