codeunit 6184827 "NPR Adyen Fee Posting"
{
    Access = Internal;
    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        MerchantCurrencySetup: Record "NPR Merchant Currency Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        EFTTransPosting: Codeunit "NPR Adyen EFT Trans. Posting";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
        CurrencyCode: Code[10];
    begin
        if not GLSetup.Get() then
            GLSetup.Init();
        CurrencyCode := _ReconciliationLine."Adyen Acc. Currency Code";
        AdyenManagement.ValidateAdyenCurrencyCode(CurrencyCode, GLSetup);

        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);
        if _AdyenSetup."Post with Transaction Date" then
            GenJnlLine."Posting Date" := DT2Date(_ReconciliationLine."Transaction Date")
        else
            GenJnlLine."Posting Date" := _ReconciliationHeader."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;

        GenJnlLine."Document No." := _ReconciliationLine."Posting No.";
        GenJnlLine.Description := CopyStr(_ReconciliationLine."Modification Reference", 1, MaxStrLen(GenJnlLine.Description));
        AssignAccountNoAndAmountType(GenJnlLine, AmountType);
        if GenJnlLine."Currency Code" <> CurrencyCode then
            GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Validate(Amount, -_ReconciliationLine."Amount(AAC)");
        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
        _GLEntryNo := EFTTransPosting.PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        if MerchantCurrencySetup.Get(_ReconciliationLine."Merchant Account", MerchantCurrencySetup."Reconciliation Account Type"::"Reconciled Payment", _ReconciliationLine."Adyen Acc. Currency Code") then begin
            GenJnlLine."Account Type" := MerchantCurrencySetup."Account Type";
            GenJnlLine.Validate("Account No.", MerchantCurrencySetup."Account No.");
        end else begin
            GenJnlLine."Account Type" := _AdyenMerchantSetup."Reconciled Payment Acc. Type";
            GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Reconciled Payment Acc. No.");
        end;
        if GenJnlLine."Currency Code" <> CurrencyCode then
            GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Validate(Amount, _ReconciliationLine."Amount(AAC)");
        EFTTransPosting.PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        AdyenManagement.CreateGLEntryReconciliationLineRelation(_GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", AmountType, _ReconciliationLine."Amount(AAC)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
    end;

    internal procedure FeePosted(RecLine: Record "NPR Adyen Recon. Line"): Boolean
    var
        ReconRelation: Record "NPR Adyen Recons.Line Relation";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
    begin
        ReconRelation.SetRange("Document No.", RecLine."Document No.");
        ReconRelation.SetRange("Document Line No.", RecLine."Line No.");
        ReconRelation.SetRange(Reversed, false);
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::Fee);
            _GLAccountType::"Invoice Deduction G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Invoice Deduction");
            _GLAccountType::"Chargeback Fees G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Chargeback Fees");
            _GLAccountType::"Merchant Payout Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Merchant Payout");
            _GLAccountType::"Acquirer Payout Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Acquirer Payout");
            _GLAccountType::"Advancement External Commission G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Advancement External Commission");
            _GLAccountType::"Refunded External Commission G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Refunded External Commission");
            _GLAccountType::"Settled External Commission G/L Account":
                ReconRelation.SetRange("Amount Type", AmountType::"Settled External Commission");
        end;
        if ReconRelation.FindFirst() then begin
            _GLEntryNo := ReconRelation."GL Entry No.";
            exit(true);
        end;
        exit(false);
    end;

    [TryFunction]
    internal procedure PrepareRecords(RecLine: Record "NPR Adyen Recon. Line"; RecHeader: Record "NPR Adyen Reconciliation Hdr"; GLAccountType: Enum "NPR Adyen Posting GL Accounts")
    begin
        _AdyenSetup.GetRecordOnce();
        _GLAccountType := GLAccountType;
        _AdyenMerchantSetup.Get(RecLine."Merchant Account");
        TestGLAccountType(RecHeader."Merchant Account", RecLine."Adyen Acc. Currency Code");
        _ReconciliationLine := RecLine;
        _ReconciliationHeader := RecHeader;
    end;

    local procedure TestGLAccountType(MerchantAccount: Text[80]; CurrencyCode: Code[10])
    begin
        _MerchantCurrencySetup.SetRange("Merchant Account Name", MerchantAccount);
        _MerchantCurrencySetup.SetRange("NP Pay Currency Code", CurrencyCode);
        _MerchantCurrencySetup.SetFilter("Account No.", '<>%1', '');
        _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Reconciled Payment");
        if _MerchantCurrencySetup.IsEmpty() then
            _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::Fee);
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Fee G/L Account");
                end;
            _GLAccountType::"Invoice Deduction G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Invoice Deduction");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Invoice Deduction G/L Account");
                end;
            _GLAccountType::"Chargeback Fees G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Chargeback Fees");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Chargeback Fees G/L Account");
                end;
            _GLAccountType::"Merchant Payout Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Merchant Payout");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Merchant Payout Acc. No.");
                end;
            _GLAccountType::"Acquirer Payout Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"External Merchant Payout");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Acquirer Payout Acc. No.");
                end;
            _GLAccountType::"Advancement External Commission G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Advancement External Commission");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Advancement EC G/L Account");
                end;
            _GLAccountType::"Refunded External Commission G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Refunded External Commission");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Refunded EC G/L Account");
                end;
            _GLAccountType::"Settled External Commission G/L Account":
                begin
                    _MerchantCurrencySetup.SetRange("Reconciliation Account Type", _MerchantCurrencySetup."Reconciliation Account Type"::"Settled External Commission");
                    if _MerchantCurrencySetup.IsEmpty() then
                        _AdyenMerchantSetup.TestField("Settled EC G/L Account");
                end;
        end;
    end;

    local procedure AssignAccountNoAndAmountType(var GenJnlLine: Record "Gen. Journal Line"; var AmountType: Enum "NPR Adyen Recon. Amount Type")
    begin
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Fee G/L Account");
                    AmountType := AmountType::Fee;
                end;
            _GLAccountType::"Invoice Deduction G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Invoice Deduction G/L Account");
                    AmountType := AmountType::"Invoice Deduction";
                end;
            _GLAccountType::"Chargeback Fees G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Chargeback Fees G/L Account");
                    AmountType := AmountType::"Chargeback Fees";
                end;
            _GLAccountType::"Merchant Payout Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then begin
                        GenJnlLine."Account Type" := _MerchantCurrencySetup."Account Type";
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.");
                    end else begin
                        GenJnlLine."Account Type" := _AdyenMerchantSetup."Merchant Payout Acc. Type";
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Merchant Payout Acc. No.");
                    end;
                    AmountType := AmountType::"Merchant Payout";
                end;
            _GLAccountType::"Acquirer Payout Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then begin
                        GenJnlLine."Account Type" := _MerchantCurrencySetup."Account Type";
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.");
                    end else begin
                        GenJnlLine."Account Type" := _AdyenMerchantSetup."Acquirer Payout Acc. Type";
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Acquirer Payout Acc. No.");
                    end;
                    AmountType := AmountType::"Acquirer Payout";
                end;
            _GLAccountType::"Advancement External Commission G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Advancement EC G/L Account");
                    AmountType := AmountType::"Advancement External Commission";
                end;
            _GLAccountType::"Refunded External Commission G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Refunded EC G/L Account");
                    AmountType := AmountType::"Refunded External Commission";
                end;
            _GLAccountType::"Settled External Commission G/L Account":
                begin
                    if _MerchantCurrencySetup.FindFirst() then
                        GenJnlLine.Validate("Account No.", _MerchantCurrencySetup."Account No.")
                    else
                        GenJnlLine.Validate("Account No.", _AdyenMerchantSetup."Settled EC G/L Account");
                    AmountType := AmountType::"Settled External Commission";
                end;
        end;
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
        _MerchantCurrencySetup: Record "NPR Merchant Currency Setup";
        _GLEntryNo: Integer;
        _GLAccountType: Enum "NPR Adyen Posting GL Accounts";
}
