codeunit 6184943 "NPR Adyen Missing Trans. Post"
{
    Access = Internal;

    trigger OnRun()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        DimensionSetID: Integer;
        TransactionAmountToPost: Decimal;
    begin
        DimensionSetID := GetInheritedDimensionSetID();
        TransactionAmountToPost := DetermineTransactionAmountToPost();

        if TransactionAmountToPost <> 0 then begin
            CreateAndPostGenJnlLine(_ReconciledAccountType, _ReconciledAccountNo, _ReconciliationLine."Adyen Acc. Currency Code", TransactionAmountToPost, _MissingTransactionAccountType, _MissingTransactionAccountNo, DimensionSetID, StrSubstNo(AdyenTransactionLabel, _ReconciliationLine."PSP Reference"), false);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(_GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", Enum::"NPR Adyen Recon. Amount Type"::Transaction, _ReconciliationLine."Amount(AAC)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;

        if _ReconciliationLine."Markup (LCY)" <> 0 then begin
            CreateAndPostGenJnlLine(Enum::"Gen. Journal Account Type"::"G/L Account", _MarkupAccountNo, _ReconciliationLine."Adyen Acc. Currency Code", _ReconciliationLine."Markup (LCY)", _ReconciledAccountType, _ReconciledAccountNo, DimensionSetID, AdyenMarkupLabel, true);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(_GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", Enum::"NPR Adyen Recon. Amount Type"::Markup, _ReconciliationLine."Markup (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if _ReconciliationLine."Other Commissions (LCY)" <> 0 then begin
            CreateAndPostGenJnlLine(Enum::"Gen. Journal Account Type"::"G/L Account", _OtherCommAccountNo, _ReconciliationLine."Adyen Acc. Currency Code", _ReconciliationLine."Other Commissions (LCY)", _ReconciledAccountType, _ReconciledAccountNo, DimensionSetID, AdyenOtherCommissionsLabel, true);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(_GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", Enum::"NPR Adyen Recon. Amount Type"::"Other commissions", _ReconciliationLine."Other Commissions (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
    end;

    internal procedure PrepareRecords(ReconLine: Record "NPR Adyen Recon. Line")
    begin
        InitRecords(ReconLine);
        InitAccounts(ReconLine);
    end;

    internal procedure GetGLSystemID(): Guid
    begin
        exit(_GLEntrySystemID);
    end;

    local procedure DetermineTransactionAmountToPost(): Decimal
    begin
        if IsCrossCurrency() then
            exit(_ReconciliationLine."Amount(AAC)");
        exit(_ReconciliationLine."Amount (TCY)");
    end;

    local procedure IsCrossCurrency(): Boolean
    begin
        exit((_ReconciliationLine."Transaction Currency Code" <> '') and (_ReconciliationLine."Adyen Acc. Currency Code" <> _ReconciliationLine."Transaction Currency Code"));
    end;

    local procedure GetInheritedDimensionSetID(): Integer
    var
        DimMgt: Codeunit DimensionManagement;
        DimSource: List of [Dictionary of [Integer, Code[20]]];
        GlobalDim1Code: Code[20];
        GlobalDim2Code: Code[20];
        SourceTableId: Integer;
    begin
        // A matched line inherits the dimensions of the document that carried the payment. An unmatched line has no
        // such document, so the account standing in for it - the Missing Transaction account - supplies them
        case _MissingTransactionAccountType of
            _MissingTransactionAccountType::"G/L Account":
                SourceTableId := Database::"G/L Account";
            _MissingTransactionAccountType::"Bank Account":
                SourceTableId := Database::"Bank Account";
            else
                exit(0);
        end;

        DimMgt.AddDimSource(DimSource, SourceTableId, _MissingTransactionAccountNo);
        exit(DimMgt.GetDefaultDimID(DimSource, _AdyenMerchantSetup."Posting Source Code", GlobalDim1Code, GlobalDim2Code, 0, 0));
    end;

    local procedure CreateGenJournalLine(var GenJnlLine: Record "Gen. Journal Line"; PaymentAccType: Enum "Gen. Journal Account Type"; PaymentAccNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; DimensionSetID: Integer; Description: Text[100]; CopyVATSetup: Boolean)
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);

        if _AdyenSetup."Post with Transaction Date" then
            GenJnlLine."Posting Date" := DT2Date(_ReconciliationLine."Transaction Date")
        else
            GenJnlLine."Posting Date" := _ReconciliationLine."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Account Type" := PaymentAccType;
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := CopyVATSetup;
        GenJnlLine.Validate("Account No.", PaymentAccNo);
        if (CurrencyCode <> '') and (CurrencyCode <> _GLSetup."LCY Code") then
            GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine."Document No." := _ReconciliationLine."Posting No.";
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description := Description;
        if DimensionSetID <> 0 then
            AdyenManagement.CreateDim(GenJnlLine, 0, DimensionSetID, PaymentAccNo, _AdyenMerchantSetup."Posting Source Code");
        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
    end;

    local procedure SetAsBalancingGenJournalLine(var GenJnlLine: Record "Gen. Journal Line"; PaymentAccType: Enum "Gen. Journal Account Type"; PaymentAccNo: Code[20]; CurrencyCode: Code[10]; Amount: Decimal; DimensionSetID: Integer)
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        GenJnlLine."Account Type" := PaymentAccType;
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        Clear(GenJnlLine."Gen. Posting Type");
        Clear(GenJnlLine."Gen. Bus. Posting Group");
        Clear(GenJnlLine."Gen. Prod. Posting Group");
        Clear(GenJnlLine."VAT Bus. Posting Group");
        Clear(GenJnlLine."VAT Prod. Posting Group");
        GenJnlLine.Validate("Account No.", PaymentAccNo);
        if (CurrencyCode <> _GLSetup."LCY Code") and (CurrencyCode <> GenJnlLine."Currency Code") then
            GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Validate(Amount, -Amount);
        if DimensionSetID <> 0 then
            AdyenManagement.CreateDim(GenJnlLine, 0, DimensionSetID, PaymentAccNo, _AdyenMerchantSetup."Posting Source Code");
    end;

    local procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line") GLEntryNo: Integer
    begin
        GLEntryNo := (GenJournalPostLine.RunWithCheck(GenJnlLine));
    end;

    local procedure InitRecords(ReconLine: Record "NPR Adyen Recon. Line")
    var
        MerchantCurrencySetup: Record "NPR Merchant Currency Setup";
    begin
        _ReconciliationLine := ReconLine;
        _GLSetup.GetRecordOnce();
        _AdyenSetup.GetRecordOnce();
        _AdyenMerchantSetup.Get(_ReconciliationLine."Merchant Account");
        if not MerchantCurrencySetup.Get(_ReconciliationLine."Merchant Account", MerchantCurrencySetup."Reconciliation Account Type"::"Missing Transaction", _ReconciliationLine."Transaction Currency Code") then
            _AdyenMerchantSetup.TestField("Missing Transaction Acc. No.");
        if not MerchantCurrencySetup.Get(_ReconciliationLine."Merchant Account", MerchantCurrencySetup."Reconciliation Account Type"::"Reconciled Payment", _ReconciliationLine."Transaction Currency Code") then
            _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");
    end;

    local procedure CreateAndPostGenJnlLine(PaymentAccType: Enum "Gen. Journal Account Type"; PaymentAccNo: Code[20]; CurrencyCodeParam: Code[10]; Amount: Decimal; BalancingAccType: Enum "Gen. Journal Account Type"; BalancingAccNo: Code[20]; DimensionSetID: Integer; Description: Text[100]; CopyVATSetup: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        AdyenManagement: Codeunit "NPR Adyen Management";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        CurrencyCode: Code[10];
    begin
        CurrencyCode := CurrencyCodeParam;
        AdyenManagement.ValidateAdyenCurrencyCode(CurrencyCode, _GLSetup);

        CreateGenJournalLine(GenJournalLine, PaymentAccType, PaymentAccNo, CurrencyCode, Amount, DimensionSetID, Description, CopyVATSetup);
        _GLEntryNo := PostGenJnlLine(GenJournalLine, GenJournalPostLine);

        if IsNullGuid(_GLEntrySystemID) then
            if GLEntry.Get(_GLEntryNo) then
                _GLEntrySystemID := GLEntry.SystemId;

        SetAsBalancingGenJournalLine(GenJournalLine, BalancingAccType, BalancingAccNo, CurrencyCode, Amount, DimensionSetID);
        PostGenJnlLine(GenJournalLine, GenJournalPostLine);
    end;

    local procedure InitAccounts(ReconLine: Record "NPR Adyen Recon. Line")
    var
        MerchantCurrencySetup: Record "NPR Merchant Currency Setup";
    begin
        MerchantCurrencySetup.SetRange("Merchant Account Name", ReconLine."Merchant Account");
        MerchantCurrencySetup.SetRange("NP Pay Currency Code", ReconLine."Transaction Currency Code");
        MerchantCurrencySetup.SetRange("Reconciliation Account Type", Enum::"NPR Merchant Account"::"Reconciled Payment");
        if MerchantCurrencySetup.FindFirst() then begin
            _ReconciledAccountType := MerchantCurrencySetup."Account Type";
            _ReconciledAccountNo := MerchantCurrencySetup."Account No.";
        end else begin
            _ReconciledAccountType := _AdyenMerchantSetup."Reconciled Payment Acc. Type";
            _ReconciledAccountNo := _AdyenMerchantSetup."Reconciled Payment Acc. No.";
        end;

        MerchantCurrencySetup.SetRange("Reconciliation Account Type", Enum::"NPR Merchant Account"::"Missing Transaction");
        if not MerchantCurrencySetup.IsEmpty() then begin
            MerchantCurrencySetup.FindFirst();
            _MissingTransactionAccountType := MerchantCurrencySetup."Account Type";
            _MissingTransactionAccountNo := MerchantCurrencySetup."Account No.";
        end else begin
            _MissingTransactionAccountType := _AdyenMerchantSetup."Missing Transaction Acc. Type";
            _MissingTransactionAccountNo := _AdyenMerchantSetup."Missing Transaction Acc. No.";
        end;

        MerchantCurrencySetup.SetRange("NP Pay Currency Code", ReconLine."Adyen Acc. Currency Code");
        MerchantCurrencySetup.SetRange("Reconciliation Account Type", Enum::"NPR Merchant Account"::Markup);
        if not MerchantCurrencySetup.IsEmpty() then begin
            MerchantCurrencySetup.FindFirst();
            _MarkupAccountNo := MerchantCurrencySetup."Account No.";
        end else
            _MarkupAccountNo := _AdyenMerchantSetup."Markup G/L Account";

        MerchantCurrencySetup.SetRange("Reconciliation Account Type", Enum::"NPR Merchant Account"::"Other commissions");
        if not MerchantCurrencySetup.IsEmpty() then begin
            MerchantCurrencySetup.FindFirst();
            _OtherCommAccountNo := MerchantCurrencySetup."Account No.";
        end else
            _OtherCommAccountNo := _AdyenMerchantSetup."Other commissions G/L Account";
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _ReconciliationLine: Record "NPR Adyen Recon. Line";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _GLSetup: Record "General Ledger Setup";
        _ReconciledAccountType: Enum "Gen. Journal Account Type";
        _MissingTransactionAccountType: Enum "Gen. Journal Account Type";
        _ReconciledAccountNo: Code[20];
        _MissingTransactionAccountNo: Code[20];
        _MarkupAccountNo: Code[20];
        _OtherCommAccountNo: Code[20];
        _GLEntryNo: Integer;
        _GLEntrySystemID: Guid;
        AdyenTransactionLabel: Label 'NP Pay: Transaction %1', MaxLength = 100;
        AdyenMarkupLabel: Label 'NP Pay: Markup', MaxLength = 100;
        AdyenOtherCommissionsLabel: Label 'NP Pay: Other Commissions (Commission, Markup, Scheme Fees, Interchange)', MaxLength = 100;
}
