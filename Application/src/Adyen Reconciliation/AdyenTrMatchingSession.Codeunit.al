codeunit 6184786 "NPR Adyen Tr. Matching Session"
{
    Access = Internal;
    TableNo = "NPR AF Rec. Webhook Request";

    trigger OnRun()
    var
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
#IF NOT BC17
        NewDocumentsList: List of [Code[20]];
#ELSE
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
#ENDIF
        MatchedEntries: Integer;
        AdyenGenericSetup: Record "NPR Adyen Setup";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        i: Integer;
    begin
        Rec.FindLast();
        if TransactionMatching.ValidateReportScheme(Rec) then begin
            NewDocumentsList := TransactionMatching.CreateSettlementDocuments(Rec, false, '');
            if NewDocumentsList.Count() > 0 then begin
                for i := 1 to NewDocumentsList.Count() do begin
#IF NOT BC17
                    if ReconciliationHeader.Get(NewDocumentsList.Get(i)) then begin
                        MatchedEntries := TransactionMatching.MatchEntries(ReconciliationHeader);
                        if MatchedEntries > 0 then
                            if not AdyenGenericSetup.Get() or AdyenGenericSetup."Enable Automatic Posting" then
                                TransactionMatching.PostEntries(ReconciliationHeader);
                    end;
#ELSE
                    NewDocumentsList.Get(i, JsonToken);
                    if ReconciliationHeader.Get(CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(ReconciliationHeader."Document No."))) then begin
                        MatchedEntries := TransactionMatching.MatchEntries(ReconciliationHeader);
                        if MatchedEntries > 0 then
                            if not AdyenGenericSetup.Get() or AdyenGenericSetup."Enable Automatic Posting" then
                                TransactionMatching.PostEntries(ReconciliationHeader);
                    end;
#ENDIF
                end;
            end;
        end;
    end;
}
