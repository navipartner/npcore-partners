codeunit 6184786 "NPR Adyen Tr. Matching Session"
{
    Access = Internal;

    trigger OnRun()
    var
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
        MatchedEntries: Integer;
        AdyenGenericSetup: Record "NPR Adyen Setup";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        RecWebhookRequests: Record "NPR AF Rec. Webhook Request";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
        LogType: Enum "NPR Adyen Webhook Log Type";
    begin
        AdyenWebhook.Reset();
        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::REPORT_AVAILABLE);
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                if not WebhookProcessing.Run(AdyenWebhook) then begin
                    AdyenManagement.CreateGeneralLog(LogType::Error, false, GetLastErrorText(), AdyenWebhook."Entry No.");
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

        if RecWebhookRequests.FindSet(true) then
            repeat
                Clear(TransactionMatching);
                if TransactionMatching.ValidateReportScheme(RecWebhookRequests) then begin
                    NewDocumentsList := TransactionMatching.CreateSettlementDocuments(RecWebhookRequests, false, '');
                    if NewDocumentsList.Count() > 0 then begin
                        foreach JsonToken in NewDocumentsList do begin
                            if ReconciliationHeader.Get(CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(ReconciliationHeader."Document No."))) then begin
                                MatchedEntries := TransactionMatching.MatchEntries(ReconciliationHeader);
                                if MatchedEntries > 0 then
                                    if not AdyenGenericSetup.Get() or AdyenGenericSetup."Enable Automatic Posting" then
                                        TransactionMatching.PostEntries(ReconciliationHeader);
                            end;
                        end;
                    end;
                end;
            until RecWebhookRequests.Next() = 0;
    end;
}
