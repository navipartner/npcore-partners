codeunit 6151029 "NPR RS Purhc. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Purchase Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRunOnAfterPostInvoice', '', false, false)]
    local procedure AddGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var PurchaseHeader: Record "Purchase Header")
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        FillRetailPurchaseLines(PurchaseHeader);

        if not TempPurchLine.FindSet() then
            exit;

        FilterPriceListLines(PurchaseHeader);

        CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::Margin);
        CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::VAT);

        repeat
            CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::MarginNoVAT);
        until TempPurchLine.Next() = 0;
    end;
    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenLineFromLastGLEntry(GenJournalLine);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
        if RSGLEntryType = RSGLEntryType::Margin then
            GenJournalLine.Validate("Debit Amount", CalculateRSAmount(RSGLEntryType, GenJournalLine))
        else
            GenJournalLine.Validate("Credit Amount", CalculateRSAmount(RSGLEntryType, GenJournalLine));

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

    local procedure InitGenLineFromLastGLEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        if GLEntry.FindLast() then begin
            GenJournalLine."Document Type" := GLEntry."Document Type";
            GenJournalLine."Document No." := GLEntry."Document No.";
            GenJournalLine."External Document No." := GLEntry."External Document No.";
            GenJournalLine."Posting Date" := GLEntry."Posting Date";
            GenJournalLine.Description := GLEntry.Description;
            GenJournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
            GenJournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
            GenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
            GenJournalLine."Document Date" := GLEntry."Posting Date";
            GenJournalLine."Due Date" := GLEntry."Posting Date";
        end;
    end;

    local procedure PostGLAcc(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLAcc: Record "G/L Account";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
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
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
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

    #region Retail Price Calculation
    local procedure GetRSAccountNoFromSetup(RSGLEntryType: Option VAT,Margin,MarginNoVAT): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        LocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        LocalizationSetup.Get();
        case RSGLEntryType of
            RSGLEntryType::VAT:
                begin
                    LocalizationSetup.TestField("RS Calc. VAT GL Account");
                    exit(LocalizationSetup."RS Calc. VAT GL Account");
                end;
            RSGLEntryType::Margin:
                begin
                    InventoryPostingSetup.SetRange("Location Code", TempPurchLine."Location Code");
                    if InventoryPostingSetup.FindFirst() then
                        exit(InventoryPostingSetup."Inventory Account");
                end;
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    local procedure CalculateRSAmount(RSGLEntryType: Option VAT,Margin,MarginNoVAT; GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                exit(CalculateRSGLVATAmount());
            RSGLEntryType::Margin:
                exit(CalculateRSGLMarginAmount(GenJnlLine));
            RSGLEntryType::MarginNoVAT:
                exit(CalculateRSGLMarginNoVATAmount(GenJnlLine));
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    var
        CalcVat: Decimal;
    begin
        repeat
            PriceListLine.SetRange("Asset No.", TempPurchLine."No.");
            if PriceListLine.FindFirst() then
                CalcVat += (PriceListLine."Unit Price" * TempPurchLine.Quantity) * CalculateVATBreakDown();
        until TempPurchLine.Next() = 0;
        exit(CalcVat);
    end;

    local procedure CalculateRSGLMarginAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        CalcMarg: Decimal;
        ItemChargeAssigned: Decimal;
        ValueEntryCostAmount: Decimal;
    begin
        repeat
            PriceListLine.SetRange("Asset No.", TempPurchLine."No.");
            if PriceListLine.FindFirst() then begin
                CalculateValueEntryCostAmount(GenJnlLine, ValueEntryCostAmount, ItemChargeAssigned);
                CalcMarg += (PriceListLine."Unit Price" * TempPurchLine.Quantity) - ValueEntryCostAmount - ItemChargeAssigned;
            end;
        until TempPurchLine.Next() = 0;
        exit(CalcMarg);
    end;

    local procedure CalculateRSGLMarginNoVATAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        CalcMargNoVAT: Decimal;
        ItemChargeAssigned: Decimal;
        TotalPriceCalc: Decimal;
        ValueEntryCostAmount: Decimal;
    begin
        PriceListLine.SetRange("Asset No.", TempPurchLine."No.");
        if not PriceListLine.FindFirst() then
            exit;
        TotalPriceCalc := PriceListLine."Unit Price" * TempPurchLine.Quantity;
        CalculateValueEntryCostAmount(GenJnlLine, ValueEntryCostAmount, ItemChargeAssigned);
        CalcMargNoVAT := TotalPriceCalc - ValueEntryCostAmount - (TotalPriceCalc * CalculateVATBreakDown()) - ItemChargeAssigned;
        exit(CalcMargNoVAT);
    end;

    local procedure CalculateValueEntryCostAmount(GenJnlLine: Record "Gen. Journal Line"; var CostAmountActual: Decimal; var ItemChargeAssigned: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        ValueEntry.SetLoadFields("Item No.", "Document No.", "Location Code", "Document Line No.", "Cost Amount (Actual)");
        ValueEntry.SetRange("Item No.", TempPurchLine."No.");
        ValueEntry.SetRange("Document No.", GenJnlLine."Document No.");
        ValueEntry.SetRange("Location Code", TempPurchLine."Location Code");
        ValueEntry.SetRange("Document Line No.", TempPurchLine."Line No.");
        if not ValueEntry.FindFirst() then
            exit;
        ValueEntry.CalcSums("Cost Amount (Actual)");
        CalculateItemCharge(ValueEntry, ItemChargeAssigned);
        CostAmountActual := Abs(ValueEntry."Cost Amount (Actual)");
    end;

    local procedure CalculateItemCharge(ValueEntry: Record "Value Entry"; var LineItemChargeAmount: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ValueEntry."Item No.");
        if not ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.") then
            exit;
        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
        if ItemLedgerEntry."Cost Amount (Actual)" <> Abs(ValueEntry."Cost Amount (Actual)") then
            LineItemChargeAmount := ItemLedgerEntry."Cost Amount (Actual)" - Abs(ValueEntry."Cost Amount (Actual)");
    end;

    local procedure CalculateVATBreakDown(): Decimal
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        if not Item.Get(TempPurchLine."No.") then
            exit;
        if not VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            exit;
        exit((100 * VATSetup."VAT %") / (100 + VATSetup."VAT %") / 100);
    end;

    #endregion

    #region Helper Functions

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

            exit(ExchangeAmtLCYToFCY2(Amount));
        end;
        exit(OldAddCurrAmount);
    end;

    local procedure ExchangeAmtLCYToFCY2(Amount: Decimal): Decimal
    begin
        exit(Round(CurrExchRate.ExchangeAmtLCYToFCYOnlyFactor(Amount, CurrencyFactor), AddCurrency."Amount Rounding Precision"));
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

    local procedure FillRetailPurchaseLines(PurchaseHeader: Record "Purchase Header")
    var
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if not PurchaseLine.FindSet() then
            exit;
        repeat
            if Location.Get(PurchaseLine."Location Code") then
                if Location."NPR Retail Location" then begin
                    TempPurchLine.Init();
                    TempPurchLine.Copy(PurchaseLine);
                    TempPurchLine.Insert();
                end;
        until PurchaseLine.Next() = 0;
    end;

    local procedure FilterPriceListLines(PurchaseHeader: Record "Purchase Header")
    var
        EndingDateFilter: Label '>=%1|''''', Locked = true;
        StartingDateFilter: Label '<=%1', Locked = true;
    begin
        PriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Source No.", "Asset Type", "Asset No.", "Variant Code", "Starting Date", "Ending Date", "Minimum Quantity");
        PriceListLine.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "Asset No.", "Unit Price");
        PriceListLine.SetRange("Price Type", "Price Type"::Sale);
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, PurchaseHeader."Posting Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, PurchaseHeader."Posting Date"));
    end;
    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempPurchLine: Record "Purchase Line" temporary;
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}