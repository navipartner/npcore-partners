codeunit 6151307 "NPR RS Trans. Rec. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                tabledata "Value Entry" = rimd,
                tabledata "Item Ledger Entry" = rimd,
                tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)

    #region Eventsubscribers - RS Transfer Recieve Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeDeleteOneTransferHeader', '', false, false)]
    local procedure OnBeforeDeleteOneTransferHeader(TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        PostRetailCalculationEntries(TransferReceiptHeader);
    end;

    #endregion

    #region Transfer Receipt Calculation Posting
    local procedure PostRetailCalculationEntries(TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        RetailValueEntry: Record "Value Entry";
        TempRetailValueEntry: Record "Value Entry" temporary;
        SourceCodeSetup: Record "Source Code Setup";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if RSRLocalizationMgt.IsRetailLocation(TransferReceiptHeader."Transfer-from Code") or (not RSRLocalizationMgt.IsRetailLocation(TransferReceiptHeader."Transfer-to Code")) then
            exit;

        TempTransferReceiptLine.Reset();
        TempTransferReceiptLine.DeleteAll();
        FillTempTransferReceiptLines(TransferReceiptHeader);

        if TempTransferReceiptLine.IsEmpty() then
            exit;

        TempTransferReceiptLine.FindSet();
        repeat
            TempRetailValueEntry.Reset();
            TempRetailValueEntry.DeleteAll();

            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempTransferReceiptLine."Item No.", TransferReceiptHeader."Transfer-to Code", TransferReceiptHeader."Posting Date");

            InsertRetailValueEntries(TempRetailValueEntry, TransferReceiptHeader);

            TempRetailValueEntry.Reset();
            if TempRetailValueEntry.FindSet() then
                repeat
                    InsertTempToValueEntry(RetailValueEntry, TempRetailValueEntry);
                    CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                    CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::VAT);
                    CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::Margin);

                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::VAT));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::"Margin with VAT"));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::Margin));
                until TempRetailValueEntry.Next() = 0;
        until TempTransferReceiptLine.Next() = 0;

        RSRLocalizationMgt.ValidateGLEntriesBalanced(TransferReceiptHeader."No.");

        SourceCodeSetup.Get();
        RSRLocalizationMgt.AddGLEntriesToGLRegister(TransferReceiptHeader."No.", SourceCodeSetup.Transfer);
    end;

    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        InitGenJournalLine(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);
        GLSetup.Get();
        AddCurrencyCode := GLSetup."Additional Reporting Currency";
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        CalculateRSGLEntryAmounts(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);

        if GenJournalLine.Amount = 0 then
            exit;

        SetGlobalDimensionCodes(GenJournalLine, CalculationValueEntry);

        GenJnlCheckLine.RunCheck(GenJournalLine);
        InitAmounts(GenJournalLine);
        if GenJournalLine."Bill-to/Pay-to No." = '' then
            case true of
                GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Account No.";
                GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer, GenJournalLine."Bal. Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Bal. Account No.";
            end;

        PostGLAcc(GenJournalLine, GLEntry);
    end;

    local procedure InitAmounts(var GenJnlLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
    begin
        if GenJnlLine."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
            GenJnlLine.Amount := Round(GenJnlLine.Amount, Currency."Amount Rounding Precision");
            GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
            GenJnlLine."VAT Amount (LCY)" := GenJnlLine."VAT Amount";
            GenJnlLine."VAT Base Amount (LCY)" := GenJnlLine."VAT Base Amount";
        end else begin
            Currency.Get(GenJnlLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            if not GenJnlLine."System-Created Entry" then begin
                GenJnlLine."Source Currency Code" := GenJnlLine."Currency Code";
                GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
                GenJnlLine."Source Curr. VAT Base Amount" := GenJnlLine."VAT Base Amount";
                GenJnlLine."Source Curr. VAT Amount" := GenJnlLine."VAT Amount";
            end;
        end;
        if GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::None then begin
            if GenJnlLine.Amount <> Round(GenJnlLine.Amount, Currency."Amount Rounding Precision") then
                GenJnlLine.FieldError(
                  GenJnlLine.Amount,
                  StrSubstNo(NeedsRoundingErr, GenJnlLine.Amount));
            if GenJnlLine."Amount (LCY)" <> Round(GenJnlLine."Amount (LCY)") then
                GenJnlLine.FieldError(
                  "Amount (LCY)",
                  StrSubstNo(NeedsRoundingErr, GenJnlLine."Amount (LCY)"));
        end;
    end;

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo('', '');
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."Document No." := CalculationValueEntry."Document No.";
        GenJournalLine."External Document No." := CalculationValueEntry."External Document No.";
        GenJournalLine."Posting Date" := CalculationValueEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
        end;
        GenJournalLine."VAT Reporting Date" := CalculationValueEntry."VAT Reporting Date";
        GenJournalLine."Document Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Due Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Source Code" := CalculationValueEntry."Source Code";
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSRetailCalculationType);
    end;

    local procedure SetGlobalDimensionCodes(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry")
    begin
        GenJournalLine."Shortcut Dimension 1 Code" := CalculationValueEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := CalculationValueEntry."Global Dimension 2 Code";
    end;

    local procedure PostGLAcc(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLAcc: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GLAcc.Get(GenJnlLine."Account No.");
        InitGLEntry(GenJnlLine, GLEntry,
         GenJnlLine."Account No.", GenJnlLine."Amount (LCY)",
          GenJnlLine."Source Currency Amount", true, GenJnlLine."System-Created Entry");
        CheckGLAccDirectPosting(GenJnlLine, GLAcc);
        CheckDescriptionForGL(GLAcc, GenJnlLine.Description);
        GLEntry."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
        GLEntry."Bal. Account Type" := GenJnlLine."Bal. Account Type";
        GLEntry."Bal. Account No." := GenJnlLine."Bal. Account No.";
        GLEntry."No. Series" := GenJnlLine."Posting No. Series";
        GLEntry."Journal Templ. Name" := GenJnlLine."Journal Template Name";
        if GenJnlLine."Additional-Currency Posting" =
           GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only"
        then begin
            GLEntry."Additional-Currency Amount" := GenJnlLine.Amount;
            GLEntry.Amount := 0;
        end;
        GenJnlPostLine.InitVAT(GenJnlLine, GLEntry, VATPostingSetup);
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
    end;

    local procedure InitGLEntry(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GLAccNo: Code[20]; Amount: Decimal; AmountAddCurr: Decimal; UseAmountAddCurr: Boolean; SystemCreatedEntry: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        if GLAccNo <> '' then begin
            GLAcc.Get(GLAccNo);
            GLAcc.TestField(Blocked, false);
            GLAcc.TestField("Account Type", GLAcc."Account Type"::Posting);

            if (not CheckForGLAccountType(GLAccNo, GenJnlLine)) then
                GenJnlPostLine.CheckGLAccDimError(GenJnlLine, GLAccNo);
        end;

        GLEntry.Init();
        GLEntry.CopyFromGenJnlLine(GenJnlLine);
        InitNextEntryNo();
        GLEntry."Entry No." := NextEntryNo;
        GLEntry."Transaction No." := NextTransactionNo;
        GLEntry."G/L Account No." := GLAccNo;
        GLEntry."System-Created Entry" := SystemCreatedEntry;
        GLEntry.Amount := Amount;
        GLEntry."Debit Amount" := GenJnlLine."Debit Amount";
        GLEntry."Credit Amount" := GenJnlLine."Credit Amount";
        GLEntry."Additional-Currency Amount" :=
          GLCalcAddCurrency(Amount, AmountAddCurr, GLEntry."Additional-Currency Amount", UseAmountAddCurr, GenJnlLine);
    end;
    #endregion

    #region Additional Item Ledger and Value Entry Posting

    local procedure InsertRetailValueEntries(var TempRetailValueEntry: Record "Value Entry" temporary; TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
    begin
        StdItemLedgerEntry.SetRange("Document No.", TransferReceiptHeader."No.");
        StdItemLedgerEntry.SetRange("Entry Type", StdItemLedgerEntry."Entry Type"::Transfer);
        StdItemLedgerEntry.SetRange("Document Type", StdItemLedgerEntry."Document Type"::"Transfer Receipt");
        StdItemLedgerEntry.SetRange("Location Code", TransferReceiptHeader."Transfer-to Code");
        StdItemLedgerEntry.SetRange("Item No.", TempTransferReceiptLine."Item No.");
        StdItemLedgerEntry.SetRange("Order Line No.", TempTransferReceiptLine."Line No.");
        if StdItemLedgerEntry.IsEmpty() then
            exit;

        StdItemLedgerEntry.FindSet();
        repeat
            InsertRetailValueEntry(TempRetailValueEntry, StdItemLedgerEntry);
        until StdItemLedgerEntry.Next() = 0;
    end;

    local procedure InsertRetailValueEntry(var TempRetailValueEntry: Record "Value Entry" temporary; StdItemLedgerEntry: Record "Item Ledger Entry")
    var
        StdValueEntry: Record "Value Entry";
        SumOfStdCostPerUnit: Decimal;
        SumOfStdInvQty: Decimal;
        CalculationValueEntryDescLbl: Label 'Calculation';
    begin
        StdValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        StdValueEntry.SetRange("Item Ledger Entry No.", StdItemLedgerEntry."Entry No.");
        if StdValueEntry.FindSet() then
            repeat
                SumOfStdCostPerUnit += StdValueEntry."Cost per Unit";
                SumOfStdInvQty += StdValueEntry."Invoiced Quantity";
                RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(StdValueEntry);
            until StdValueEntry.Next() = 0;

        if PriceListLine."Unit Price" = SumOfStdCostPerUnit then
            exit;

        TempRetailValueEntry.Init();
        TempRetailValueEntry.Copy(StdValueEntry);
        TempRetailValueEntry."Entry No." := TempRetailValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(TempRetailValueEntry);
        TempRetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - SumOfStdCostPerUnit;
        TempRetailValueEntry."Cost Amount (Actual)" := TempRetailValueEntry."Cost per Unit" * SumOfStdInvQty;
        TempRetailValueEntry."Cost Posted to G/L" := TempRetailValueEntry."Cost Amount (Actual)";
        TempRetailValueEntry.Description := CalculationValueEntryDescLbl;
        TempRetailValueEntry.Insert();
    end;

    local procedure InsertTempToValueEntry(var NewValueEntry: Record "Value Entry"; TempValueEntry: Record "Value Entry" temporary)
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(TempValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
        NewValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(NewValueEntry);
    end;

    #endregion

    #region Retail Price Calculation
    local procedure CalculateRSGLEntryAmounts(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Amount (Actual)");
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Credit Amount", CalculateRSGLVATAmount(CalculationValueEntry));
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Amount (Actual)" - RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculateRSGLVATAmount(CalculationValueEntry), GenJournalLine."Currency Code"));
        end;
    end;

    local procedure CalculateRSGLVATAmount(CalculationValueEntry: Record "Value Entry"): Decimal
    begin
        exit((PriceListLine."Unit Price" * GetItemLedgerQuantityFromCalcEntry(CalculationValueEntry)) * CalculateVATBreakDown());
    end;

    local procedure CalculateVATBreakDown(): Decimal
    begin
        exit(RSRLocalizationMgt.CalculateVATBreakDown(PriceListLine."VAT Bus. Posting Gr. (Price)", PriceListLine."VAT Prod. Posting Group"));
    end;

    local procedure GetItemLedgerQuantityFromCalcEntry(CalculationValueEntry: Record "Value Entry"): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Get(CalculationValueEntry."Item Ledger Entry No.");
        exit(ItemLedgerEntry."Invoiced Quantity");
    end;

    local procedure GetRSAccountNoFromSetup(RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
    var
        LocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        LocalizationSetup.Get();
        case RSRetailCalculationType of
            RSRetailCalculationType::VAT:
                begin
                    LocalizationSetup.TestField("RS Calc. VAT GL Account");
                    exit(LocalizationSetup."RS Calc. VAT GL Account");
                end;
            RSRetailCalculationType::"Margin with VAT":
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempTransferReceiptLine."Item No.", TempTransferReceiptLine."Transfer-to Code"));
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    #endregion

    #region Helper Procedures
    local procedure InitNextEntryNo()
    var
        GLEntry: Record "G/L Entry";
        LastEntryNo: Integer;
        LastTransactionNo: Integer;
    begin
        GLEntry.LockTable();
        GLEntry.GetLastEntry(LastEntryNo, LastTransactionNo);
        NextEntryNo := LastEntryNo + 1;
        NextTransactionNo := LastTransactionNo + 1;
    end;

    local procedure GLCalcAddCurrency(Amount: Decimal; AddCurrAmount: Decimal; OldAddCurrAmount: Decimal; UseAddCurrAmount: Boolean; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        if (AddCurrencyCode <> '') and
           (GenJnlLine."Additional-Currency Posting" = GenJnlLine."Additional-Currency Posting"::None)
        then begin
            if (GenJnlLine."Source Currency Code" = AddCurrencyCode) and UseAddCurrAmount then
                exit(AddCurrAmount);

            exit(ExchangeAmtLCYToFCY2(Amount, GenJnlLine));
        end;
        exit(OldAddCurrAmount);
    end;

    local procedure ExchangeAmtLCYToFCY2(Amount: Decimal; GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        NewCurrencyDate: Date;
        CurrencyDate: Date;
        UseCurrFactorOnly: Boolean;
    begin
        AddCurrency.Get(AddCurrencyCode);

        NewCurrencyDate := GenJnlLine."Posting Date";

        if GenJnlLine."Reversing Entry" then
            NewCurrencyDate := NewCurrencyDate - 1;

        if (NewCurrencyDate <> CurrencyDate) then begin
            UseCurrFactorOnly := false;
            CurrencyDate := NewCurrencyDate;
            CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, AddCurrencyCode);
        end;

        if (GenJnlLine."FA Add.-Currency Factor" <> 0) and (GenJnlLine."FA Add.-Currency Factor" <> CurrencyFactor)
        then begin
            UseCurrFactorOnly := true;
            CurrencyDate := 0D;
            CurrencyFactor := GenJnlLine."FA Add.-Currency Factor";
        end;

        if UseCurrFactorOnly then
            exit(Round(CurrExchRate.ExchangeAmtLCYToFCYOnlyFactor(Amount, CurrencyFactor), AddCurrency."Amount Rounding Precision"));

        exit(Round(CurrExchRate.ExchangeAmtLCYToFCY(CurrencyDate, AddCurrencyCode, Amount, CurrencyFactor), AddCurrency."Amount Rounding Precision"));
    end;

    local procedure PostJob(GenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    var
        JobPostLine: Codeunit "Job Post-Line";
    begin
        if not JobLine then
            exit;
        JobLine := false;
        JobPostLine.PostGenJnlLine(GenJnlLine, GLEntry);
    end;

    local procedure CheckGLAccDirectPosting(GenJnlLine: Record "Gen. Journal Line"; GLAcc: Record "G/L Account")
    begin
        if not GenJnlLine."System-Created Entry" then
            if GenJnlLine."Posting Date" = NormalDate(GenJnlLine."Posting Date") then
                GLAcc.TestField("Direct Posting", true);
    end;

    local procedure CheckDescriptionForGL(GLAccount: Record "G/L Account"; Description: Text[100])
    var
        GLEntry: Record "G/L Entry";
        DescriptionMustNotBeBlankErr: Label 'When %1 is selected for %2, %3 must have a value.', Comment = '%1: Field Omit Default Descr. in Jnl., %2 G/L Account No, %3 Description';
    begin
        if GLAccount."Omit Default Descr. in Jnl." then
            if DelChr(Description, '=', ' ') = '' then
                Error(
                    DescriptionMustNotBeBlankErr,
                    GLAccount.FieldCaption("Omit Default Descr. in Jnl."),
                    GLAccount."No.",
                    GLEntry.FieldCaption(Description));
    end;

    local procedure CheckForGLAccountType(GLAccNo: Code[20]; GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        if ((GLAccNo = GenJnlLine."Account No.") and
                 (GenJnlLine."Account Type" = GenJnlLine."Account Type"::"G/L Account")) or
                ((GLAccNo = GenJnlLine."Bal. Account No.") and
                 (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"G/L Account")) then
            exit(true);
    end;

    local procedure FillTempTransferReceiptLines(TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        TransferReceiptLine.SetRange("Document No.", TransferReceiptHeader."No.");
        TransferReceiptLine.SetFilter(Quantity, '<>%1', 0);
        if TransferReceiptLine.IsEmpty() then
            exit;
        TransferReceiptLine.FindSet();
        repeat
            TempTransferReceiptLine.Init();
            TempTransferReceiptLine.Copy(TransferReceiptLine);
            TempTransferReceiptLine.Insert();
        until TransferReceiptLine.Next() = 0;
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempTransferReceiptLine: Record "Transfer Receipt Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}