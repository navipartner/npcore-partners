codeunit 6151029 "NPR RS Purhc. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)

    #region Eventsubscribers - RS Purchase Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnAfterPostInvoice', '', false, false)]
    local procedure OnRunOnAfterPostInvoice(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        PostRetailCalculationEntries(PurchInvHeader);
    end;
    #endregion

    #region Purchase Document Calculation Posting

    internal procedure PostRetailCalculationEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        RetailValueEntry: Record "Value Entry";
        SourceCodeSetup: Record "Source Code Setup";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if PurchInvHeader."No." = '' then
            exit;

        TempPurchInvLine.Reset();
        TempPurchInvLine.DeleteAll();

        FillRetailPurchaseLines(PurchInvHeader);

        if not TempPurchInvLine.FindSet() then
            exit;

        repeat
            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempPurchInvLine."No.", TempPurchInvLine."Location Code", PurchInvHeader."Posting Date");

            InsertRetailValueEntries(RetailValueEntry, PurchInvHeader);

            if RetailValueEntry."Entry No." <> 0 then begin
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::VAT);
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::Margin);
            end
        until TempPurchInvLine.Next() = 0;

        TempPurchInvLine.DeleteAll();

        RSRLocalizationMgt.ValidateGLEntriesBalanced(PurchInvHeader."No.");
        SourceCodeSetup.Get();
        RSRLocalizationMgt.AddGLEntriesToGLRegister(PurchInvHeader."No.", SourceCodeSetup.Purchases);
    end;

    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
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

        CalculatePurchLineItemTypeAmounts(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);

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

        if (TempPurchInvLine.Type in ["Purchase Line Type"::"Charge (Item)"]) and (RSRetailCalculationType in [RSRetailCalculationType::"Item Charge Margin With VAT"]) then begin
            GenJournalLine."Debit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Credit Amount" := 0;
        end;

        PostGLAcc(GenJournalLine, GLEntry);

        RSRLocalizationMgt.InsertGLItemLedgerRelation(GenJnlPostLine, GLEntry."Entry No.", CalculationValueEntry."Entry No.");
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
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Invoice;
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

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        StdValueEntry: Record "Value Entry";
    begin
        StdValueEntry.SetRange("Location Code", TempPurchInvLine."Location Code");
        StdValueEntry.SetRange("Document No.", PurchInvHeader."No.");
        StdValueEntry.SetRange("Item No.", TempPurchInvLine."No.");
        StdValueEntry.SetRange("Document Line No.", TempPurchInvLine."Line No.");
        if not StdValueEntry.FindFirst() then
            exit;

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(StdValueEntry);
        InsertRetailValueEntry(RetailValueEntry, StdValueEntry);
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry")
    var
        CalculationValueEntryDescLbl: Label 'Calculation';
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);
        RetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - CalculateStandardCostPerUnit(StdValueEntry);
        RetailValueEntry."Cost Amount (Actual)" := RetailValueEntry."Cost per Unit" * TempPurchInvLine.Quantity;
        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        RetailValueEntry.Description := CalculationValueEntryDescLbl;

        if (RetailValueEntry."Cost Amount (Actual)" = 0) then
            exit;

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    local procedure CalculateStandardCostPerUnit(StdValueEntry: Record "Value Entry"): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetLoadFields("Cost per Unit");
        ValueEntry.SetRange("Document No.", StdValueEntry."Document No.");
        ValueEntry.SetRange("Item Ledger Entry No.", StdValueEntry."Item Ledger Entry No.");
        ValueEntry.CalcSums("Cost per Unit");
        exit(ValueEntry."Cost per Unit");
    end;

    #endregion

    #region Retail Price Calculation

    local procedure CalculatePurchLineItemTypeAmounts(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Amount (Actual)");
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Amount (Actual)" - CalculateRSGLVATAmount());
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Credit Amount", CalculateRSGLVATAmount());
        end;
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
                exit(GetInventoryAccountFromInvPostingSetup(TempPurchInvLine."Location Code"));
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempPurchInvLine.Quantity) * RSRLocalizationMgt.CalculateVATBreakDown(TempPurchInvLine."VAT Bus. Posting Group", TempPurchInvLine."VAT Prod. Posting Group"));
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
        AddCurrency: Record Currency;
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

    local procedure FillRetailPurchaseLines(PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange(Type, "Purchase Line Type"::Item);
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.IsEmpty() then
            exit;
        PurchInvLine.FindSet();
        repeat
            if RSRLocalizationMgt.IsRetailLocation(PurchInvLine."Location Code") then
                if not (RSRLocalizationMgt.IsServiceItem(PurchInvLine."No.")) then begin
                    TempPurchInvLine.Init();
                    TempPurchInvLine.Copy(PurchInvLine);
                    TempPurchInvLine.Insert();
                end;
        until PurchInvLine.Next() = 0;
    end;

    local procedure GetInventoryAccountFromInvPostingSetup(LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        Item.Get(TempPurchInvLine."No.");
        if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
            Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                    InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    #endregion

    var
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempPurchInvLine: Record "Purch. Inv. Line" temporary;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}