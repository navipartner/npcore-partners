codeunit 6185038 "NPR Adyen Rec. Report Process"
{
    Access = Internal;
    TableNo = "NPR AF Rec. Webhook Request";

    trigger OnRun()
    var
        MatchedEntries: Integer;
        AdyenGenericSetup: Record "NPR Adyen Setup";
        AdyenWebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        JsonToken: JsonToken;
        NewDocumentsList: JsonArray;
        ReportTypeFormatNotSupportedLbl: Label 'The report type or format is not supported - %1.';
        NoDocumentsWereCreatedLbl: Label 'No documents were created from the report %1.';
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AdyenWebhookRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        AdyenWebhookRequest.LockTable();
#endif
        AdyenGenericSetup.Get();

        AdyenWebhookRequest.Get(Rec.ID);
        if AdyenWebhookRequest.Processed then
            exit;
        Clear(TransactionMatching);
        if not AdyenWebhookRequest."Report Name".Contains('.xlsx') then
            Error(ReportTypeFormatNotSupportedLbl, AdyenWebhookRequest."Report Name");

        TransactionMatching.ValidateReportScheme(AdyenWebhookRequest);
        NewDocumentsList := TransactionMatching.CreateSettlementDocuments(AdyenWebhookRequest, false, '');
        if NewDocumentsList.Count() = 0 then
            Error(NoDocumentsWereCreatedLbl, AdyenWebhookRequest."Report Name");
        foreach JsonToken in NewDocumentsList do begin
            ReconciliationHeader.Get(CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(ReconciliationHeader."Document No.")));
            MatchedEntries := TransactionMatching.MatchEntries(ReconciliationHeader);
            if MatchedEntries > 0 then
                if AdyenGenericSetup."Enable Automatic Posting" then
                    TransactionMatching.PostEntries(ReconciliationHeader)
                else
                    TransactionMatching.ReconcileEntries(ReconciliationHeader);
        end;

        AdyenWebhookRequest.Find();
        AdyenWebhookRequest.Processed := true;
        AdyenWebhookRequest."Processing Status" := AdyenWebhookRequest."Processing Status"::Success;
        AdyenWebhookRequest.Modify();
    end;
}
