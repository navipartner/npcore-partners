codeunit 6184943 "NPR Adyen Missing Trans. Post"
{
    TableNo = "NPR Adyen Recon. Line";
    Access = Internal;

    trigger OnRun()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        GLEntry: Record "G/L Entry";
    begin
        InitSetup(Rec."Merchant Account");

        CreateGenJournalLine(GenJournalLine, Rec);
        PostGenJnlLine(GenJournalLine, GenJournalPostLine);

        if GLEntry.Get(_GLEntryNo) then
            _GLEntrySystemID := GLEntry.SystemId;

        SetAsBalancingGenJournalLine(GenJournalLine);
        PostGenJnlLine(GenJournalLine, GenJournalPostLine);
    end;

    internal procedure GetGLSystemID(): Guid
    begin
        exit(_GLEntrySystemID);
    end;

    local procedure CreateGenJournalLine(var GenJnlLine: Record "Gen. Journal Line"; ReconLine: Record "NPR Adyen Recon. Line")
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeries: Codeunit "No. Series";
#else
        NoSeries: Codeunit NoSeriesManagement;
#endif
        AdyenTransactionLabel: Label 'Adyen: Transaction %1', MaxLength = 100;
    begin

        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);

        if _AdyenSetup."Post with Transaction Date" then
            GenJnlLine."Posting Date" := DT2Date(ReconLine."Transaction Date")
        else
            GenJnlLine."Posting Date" := ReconLine."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Account Type" := _AdyenMerchantSetup."Reconciled Payment Acc. Type";
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Reconciled Payment Acc. No.");
        GenJnlLine."Document No." := NoSeries.GetNextNo(_AdyenSetup."Reconciliation Document Nos.", Today(), true);
        if (ReconLine."Transaction Currency Code" <> '') and (ReconLine."Transaction Currency Code" <> _GLSetup."LCY Code") then
            GenJnlLine.Validate("Currency Code", ReconLine."Transaction Currency Code");

        GenJnlLine.Validate(Amount, ReconLine."Amount (TCY)");
        GenJnlLine.Description := StrSubstNo(AdyenTransactionLabel, ReconLine."PSP Reference");

        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
    end;

    local procedure SetAsBalancingGenJournalLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."Account Type" := _AdyenMerchantSetup."Missing Transaction Acc. Type";
        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Missing Transaction Acc. No.");
        GenJnlLine.Validate(Amount, -GenJnlLine.Amount);
    end;

    local procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        _GLEntryNo := GenJournalPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure InitSetup(MerchantAccount: Text[80])
    begin
        _GLSetup.GetRecordOnce();
        _AdyenSetup.GetRecordOnce();
        _AdyenMerchantSetup.Get(MerchantAccount);
        _AdyenMerchantSetup.TestField("Missing Transaction Acc. No.");
        _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _GLSetup: Record "General Ledger Setup";
        _GLEntrySystemID: Guid;
        _GLEntryNo: Integer;
}
