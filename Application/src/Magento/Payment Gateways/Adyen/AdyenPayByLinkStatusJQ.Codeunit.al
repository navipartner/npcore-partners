codeunit 6184933 "NPR Adyen PayByLink Status JQ"
{
    Access = Internal;
    trigger OnRun()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenWebhookLogType: Enum "NPR Adyen Webhook Log Type";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin
        if not IsSetupEnabled() then
            exit;

        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::AUTHORISATION);
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

    local procedure IsSetupEnabled() SetupEnabled: Boolean;
    var
        AdyenSetup: Record "NPR Adyen Setup";
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
        SetupEnabled := false;

        //Magento PayByLink
        if AdyenSetup.Get() then
            if AdyenSetup."Enable Pay by Link" then
                SetupEnabled := true;

        //Subscription PayByLink Card Update
        SubsPaymentGateway.SetRange("Integration Type", SubsPaymentGateway."Integration Type"::Adyen);
        SubsPaymentGateway.SetRange(Status, SubsPaymentGateway.Status::Enabled);
        SubsPaymentGateway.SetLoadFields("Integration Type", Status, Code);
        if SubsPaymentGateway.FindFirst() then
            if SubsAdyenPGSetup.Get(SubsPaymentGateway.Code) then
                if SubsAdyenPGSetup."Card Update by Pay by Link" then
                    SetupEnabled := true;
    end;
}