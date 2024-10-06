codeunit 6184786 "NPR Adyen Tr. Matching Session"
{
    Access = Internal;

    trigger OnRun()
    var
        RecWebhookRequests: Record "NPR AF Rec. Webhook Request";
        RecWebhookRequests2: Record "NPR AF Rec. Webhook Request";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
        GeneralLogType: Enum "NPR Adyen Webhook Log Type";
        ReconciliationLogType: Enum "NPR Adyen Rec. Log Type";
    begin
        AdyenWebhook.Reset();
        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::REPORT_AVAILABLE);
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                if not WebhookProcessing.Run(AdyenWebhook) then begin
                    AdyenManagement.CreateGeneralLog(GeneralLogType::Error, false, GetLastErrorText(), AdyenWebhook."Entry No.");
                    AdyenWebhook.Status := AdyenWebhook.Status::Error;
                    AdyenWebhook.Modify();
                    Commit();
                end;
            until AdyenWebhook.Next() = 0;

        // Process all not processed Webhook Entries
        RecWebhookRequests.Reset();
        RecWebhookRequests.SetRange(Processed, false);

        if RecWebhookRequests.IsEmpty() then
            exit;

        if RecWebhookRequests.FindSet() then
            repeat
                RecWebhookRequests2 := RecWebhookRequests;
                if not Codeunit.Run(Codeunit::"NPR Adyen Rec. Report Process", RecWebhookRequests2) then begin
                    RecWebhookRequests2.Find();
                    RecWebhookRequests2.Processed := true;
                    RecWebhookRequests2."Processing Status" := RecWebhookRequests2."Processing Status"::Failed;
                    RecWebhookRequests2.Modify();
                    AdyenManagement.CreateReconciliationLog(ReconciliationLogType::"Background Session", false, GetLastErrorText(), RecWebhookRequests2.ID);
                    Commit();
                end;
            until RecWebhookRequests.Next() = 0;
    end;
}
