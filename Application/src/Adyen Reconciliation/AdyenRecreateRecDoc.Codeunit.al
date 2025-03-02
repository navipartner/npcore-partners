codeunit 6248336 "NPR Adyen Recreate Rec. Doc."
{
    TableNo = "NPR Adyen Reconciliation Hdr";
    Access = Internal;

    trigger OnRun()
    var
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        AdyenTransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        RecreatedLines: Integer;
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        ReconHeader.ReadIsolation := IsolationLevel::UpdLock;
#else
        ReconHeader.LockTable();
#endif
        ReconHeader.Get(Rec."Document No.");

        if ReconHeader."Document No." <> '' then begin
            RecreatedLines := AdyenTransactionMatching.RecreateDocumentEntries(ReconHeader);
            if RecreatedLines > 0 then
                TransactionMatching.MatchEntries(ReconHeader);
        end;
    end;
}
