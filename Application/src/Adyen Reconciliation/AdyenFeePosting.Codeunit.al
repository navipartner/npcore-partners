codeunit 6184827 "NPR Adyen Fee Posting"
{
    Access = Internal;
    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
        EFTTransPosting: Codeunit "NPR Adyen EFT Trans. Posting";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);
        if _AdyenSetup."Post with Transaction Date" then
            GenJnlLine."Posting Date" := DT2Date(_ReconciliationLine."Transaction Date")
        else
            GenJnlLine."Posting Date" := _ReconciliationHeader."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        case _GLAccountType of
            _GLAccountType::"Merchant Payout Account":
                begin
                    case _AdyenMerchantSetup."Merchant Payout Acc. Type" of
                        _AdyenMerchantSetup."Merchant Payout Acc. Type"::"G/L Account":
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        _AdyenMerchantSetup."Merchant Payout Acc. Type"::"Bank Account":
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                    end;
                end;
            _GLAccountType::"Acquirer Payout Account":
                begin
                    case _AdyenMerchantSetup."Acquirer Payout Acc. Type" of
                        _AdyenMerchantSetup."Acquirer Payout Acc. Type"::"G/L Account":
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        _AdyenMerchantSetup."Acquirer Payout Acc. Type"::"Bank Account":
                            GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
                    end;
                end;
            else
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        end;


        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Fee G/L Account");
                    AmountType := AmountType::Fee;
                end;
            _GLAccountType::"Invoice Deduction G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Invoice Deduction G/L Account");
                    AmountType := AmountType::"Invoice Deduction";
                end;
            _GLAccountType::"Chargeback Fees G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Chargeback Fees G/L Account");
                    AmountType := AmountType::"Chargeback Fees";
                end;
            _GLAccountType::"Merchant Payout Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Merchant Payout Acc. No.");
                    AmountType := AmountType::"Merchant Payout";
                end;
            _GLAccountType::"Acquirer Payout Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Acquirer Payout Acc. No.");
                    AmountType := AmountType::"Acquirer Payout";
                end;
            _GLAccountType::"Advancement External Commission G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Advancement EC G/L Account");
                    AmountType := AmountType::"Advancement External Commission";
                end;
            _GLAccountType::"Refunded External Commission G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Refunded EC G/L Account");
                    AmountType := AmountType::"Refunded External Commission";
                end;
            _GLAccountType::"Settled External Commission G/L Account":
                begin
                    GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Settled EC G/L Account");
                    AmountType := AmountType::"Settled External Commission";
                end;
        end;
        GenJnlLine."Document No." := _ReconciliationLine."Posting No.";
        GenJnlLine.Description := CopyStr(_ReconciliationLine."Modification Reference", 1, MaxStrLen(GenJnlLine.Description));
        if GLSetup.Get() and (_ReconciliationLine."Adyen Acc. Currency Code" <> GLSetup."LCY Code") then
            GenJnlLine.Validate("Currency Code", _ReconciliationLine."Adyen Acc. Currency Code");
        GenJnlLine.Validate(Amount, _ReconciliationLine."Amount(AAC)");
        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
        _GLEntryNo := EFTTransPosting.PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        GenJnlLine."Account Type" := _AdyenMerchantSetup."Reconciled Payment Acc. Type";
        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Reconciled Payment Acc. No.");
        GenJnlLine.Validate(Amount, -_ReconciliationLine."Amount(AAC)");
        EFTTransPosting.PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        AdyenManagement.CreateGLEntryReconciliationLineRelation(_GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", AmountType, _ReconciliationLine."Amount(AAC)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
    end;

    internal procedure FeePosted(RecLine: Record "NPR Adyen Recon. Line"): Boolean
    var
        ReconRelation: Record "NPR Adyen Recon. Line Relation";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
        TransactionFound: Boolean;
    begin
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::Fee);
            _GLAccountType::"Invoice Deduction G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Invoice Deduction");
            _GLAccountType::"Chargeback Fees G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Chargeback Fees");
            _GLAccountType::"Merchant Payout Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Merchant Payout");
            _GLAccountType::"Acquirer Payout Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Acquirer Payout");
            _GLAccountType::"Advancement External Commission G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Advancement External Commission");
            _GLAccountType::"Refunded External Commission G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Refunded External Commission");
            _GLAccountType::"Settled External Commission G/L Account":
                TransactionFound := ReconRelation.Get(RecLine."Document No.", RecLine."Line No.", AmountType::"Settled External Commission");
        end;
        if TransactionFound then begin
            _GLEntryNo := ReconRelation."GL Entry No.";
            exit(true);
        end;
        exit(false);
    end;

    [TryFunction]
    internal procedure PrepareRecords(var RecLine: Record "NPR Adyen Recon. Line"; RecHeader: Record "NPR Adyen Reconciliation Hdr"; GLAccountType: Enum "NPR Adyen Posting GL Accounts")
    begin
        _AdyenSetup.Get();
        _GLAccountType := GLAccountType;
        _AdyenMerchantSetup.Get(RecLine."Merchant Account");

        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                _AdyenMerchantSetup.TestField("Fee G/L Account");
            _GLAccountType::"Invoice Deduction G/L Account":
                _AdyenMerchantSetup.TestField("Invoice Deduction G/L Account");
            _GLAccountType::"Chargeback Fees G/L Account":
                _AdyenMerchantSetup.TestField("Chargeback Fees G/L Account");
            _GLAccountType::"Merchant Payout Account":
                _AdyenMerchantSetup.TestField("Merchant Payout Acc. No.");
            _GLAccountType::"Acquirer Payout Account":
                _AdyenMerchantSetup.TestField("Acquirer Payout Acc. No.");
            _GLAccountType::"Advancement External Commission G/L Account":
                _AdyenMerchantSetup.TestField("Advancement EC G/L Account");
            _GLAccountType::"Refunded External Commission G/L Account":
                _AdyenMerchantSetup.TestField("Refunded EC G/L Account");
            _GLAccountType::"Settled External Commission G/L Account":
                _AdyenMerchantSetup.TestField("Settled EC G/L Account");
        end;
        _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");
        _ReconciliationLine := RecLine;
        _ReconciliationHeader := RecHeader;
    end;

    internal procedure GetGlEntrySystemID(): Guid
    var
        GLEntry: Record "G/L Entry";
    begin
        if GLEntry.Get(_GLEntryNo) then
            exit(GLEntry.SystemId);
    end;

    var
        _ReconciliationLine: Record "NPR Adyen Recon. Line";
        _ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _AdyenSetup: Record "NPR Adyen Setup";
        _GLEntryNo: Integer;
        _GLAccountType: Enum "NPR Adyen Posting GL Accounts";
}
