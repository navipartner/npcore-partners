codeunit 6184743 "NPR RS SalesCrMemo GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Sales Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure AddSalesGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        RetailValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if SalesCrMemoHeader."No." = '' then
            exit;

        FillRetailSalesLines(SalesCrMemoHeader);

        if TempSalesCrMemoLine.IsEmpty() then
            exit;

        FilterPriceListHeader(SalesCrMemoHeader);

        TempSalesCrMemoLine.FindSet();
        repeat
            FindPriceListLine();

            InsertRetailValueEntries(RetailValueEntry, SalesCrMemoHeader, GenJnlPostLine);

            if (RetailValueEntry."Entry No." <> 0) then begin
                CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, RetailValueEntry, RSRetailCalculationType::VAT);
                CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, RetailValueEntry, RSRetailCalculationType::Margin);
                CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::VAT));
                RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::Margin));
                if RetailValueEntry."Cost Amount (Actual)" <> 0 then
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::"Margin with VAT"));
            end;

            CheckIfNivelationNeeded(SalesCrMemoHeader);
        until TempSalesCrMemoLine.Next() = 0;

        if not TempNivSalesCrMemoLines.IsEmpty() and not PreviewMode then
            CreateAndPostNivelationDocument(SalesCrMemoHeader);
    end;

    #endregion

    #region Nivelation Document Posting
    local procedure CreateAndPostNivelationDocument(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        NivelationLines: Record "NPR RS Nivelation Lines";
        NivelationPost: Codeunit "NPR RS Nivelation Post";
        LineNo: Integer;
    begin
        NivelationHeader.Init();
        NivelationHeader.Type := "NPR RS Nivelation Type"::"Promotions & Discounts";
        NivelationHeader."Source Type" := "NPR RS Nivelation Source Type"::"Posted Sales Credit Memo";
        NivelationHeader."Referring Document Code" := SalesCrMemoHeader."No.";
        NivelationHeader."Posting Date" := SalesCrMemoHeader."Posting Date";
        NivelationHeader.Insert(true);
        LineNo := NivelationLines.GetInitialLine() + 10000;
        TempNivSalesCrMemoLines.FindSet();
        repeat
            NivelationLines.Init();
            NivelationLines."Line No." := LineNo;
            NivelationLines."Document No." := NivelationHeader."No.";
            NivelationLines."Location Code" := TempNivSalesCrMemoLines."Location Code";
            FindPriceListLine();
            NivelationLines."Price Valid Date" := PriceListLine."Starting Date";
            NivelationLines."Posting Date" := SalesCrMemoHeader."Posting Date";
            NivelationLines."VAT Bus. Posting Gr. (Price)" := PriceListLine."VAT Bus. Posting Gr. (Price)";
            NivelationLines.Validate("Item No.", TempNivSalesCrMemoLines."No.");
            NivelationLines."Old Price" := PriceListLine."Unit Price";
            NivelationLines.Quantity := TempNivSalesCrMemoLines.Quantity;
            NivelationLines.Validate("New Price", TempNivSalesCrMemoLines.GetLineAmountInclVAT() / TempNivSalesCrMemoLines.Quantity);
            NivelationLines.Insert(true);
            LineNo += 10000;
        until TempNivSalesCrMemoLines.Next() = 0;
        NivelationHeader.CalcFields(Amount);
        NivelationHeader.Modify();

        NivelationPost.RunNivelationPosting(NivelationHeader)
    end;

    local procedure CheckIfNivelationNeeded(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        case SalesCrMemoHeader."Prices Including VAT" of
            true:
                if TempSalesCrMemoLine."Line Amount" = (PriceListLine."Unit Price" * TempSalesCrMemoLine.Quantity) then
                    exit;
            false:
                if (Round(TempSalesCrMemoLine."Line Amount" * (1 + TempSalesCrMemoLine."VAT %" / 100), 1, '=') / TempSalesCrMemoLine.Quantity) = PriceListLine."Unit Price" then
                    exit;
        end;
        TempNivSalesCrMemoLines.Init();
        TempNivSalesCrMemoLines.Copy(TempSalesCrMemoLine);
        TempNivSalesCrMemoLines.Insert();
    end;
    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenLineFromLastGLEntry(GenJournalLine, RSRetailCalculationType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        ValidateGenJnlLineNegativeAmounts(GenJournalLine, SalesCrMemoHeader, RSRetailCalculationType, CalculationValueEntry);

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

        if (RSRetailCalculationType in [RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Standard Correction"]) then begin
            GenJournalLine."Credit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Debit Amount" := 0;
        end;

        PostGLAcc(GenJnlPostLine, GenJournalLine, GLEntry);

        RSRLocalizationMgt.ModifyGLRegForRetailCalculationEntries(GLRegister, GLEntry);
    end;

    local procedure ValidateGenJnlLineNegativeAmounts(var GenJournalLine: Record "Gen. Journal Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Standard Correction":
                if CalculationValueEntry."Cost Amount (Actual)" <> 0 then begin
                    GenJournalLine.Validate("Credit Amount", -Abs(CalculationValueEntry."Cost Amount (Actual)"));
                    GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
                    exit;
                end;
            RSRetailCalculationType::"Counter COGS Correction":
                begin
                    GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L"));
                    GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
                    exit;
                end;
            RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Cost Posted to G/L"));
            RSRetailCalculationType::"COGS Correction":
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSRetailCalculationType::Margin:
                if CalculationValueEntry."Cost Posted to G/L" <> 0 then
                    GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"))
                else
                    GenJournalLine.Validate("Debit Amount", RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculateRSGLMarginNoVATAmount(SalesCrMemoHeader), GenJournalLine));
        end;
        GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
    end;

    local procedure InitAmounts(var GenJournalLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
    begin
        if GenJournalLine."Currency Code" = '' then begin
            Currency.InitRoundingPrecision();
            GenJournalLine.Amount := Round(GenJournalLine.Amount, Currency."Amount Rounding Precision");
            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
        end else begin
            Currency.Get(GenJournalLine."Currency Code");
            Currency.TestField("Amount Rounding Precision");
            if not GenJournalLine."System-Created Entry" then begin
                GenJournalLine."Source Currency Code" := GenJournalLine."Currency Code";
                GenJournalLine."Source Currency Amount" := GenJournalLine.Amount;
                GenJournalLine."Source Curr. VAT Base Amount" := GenJournalLine."VAT Base Amount";
                GenJournalLine."Source Curr. VAT Amount" := GenJournalLine."VAT Amount";
            end;
        end;
        if GenJournalLine."Additional-Currency Posting" = GenJournalLine."Additional-Currency Posting"::None then begin
            if GenJournalLine.Amount <> Round(GenJournalLine.Amount, Currency."Amount Rounding Precision") then
                GenJournalLine.FieldError(
                  GenJournalLine.Amount,
                  StrSubstNo(NeedsRoundingErr, GenJournalLine.Amount));
            if GenJournalLine."Amount (LCY)" <> Round(GenJournalLine."Amount (LCY)") then
                GenJournalLine.FieldError(
                  "Amount (LCY)",
                  StrSubstNo(NeedsRoundingErr, GenJournalLine."Amount (LCY)"));
        end;
    end;

    local procedure InitGenLineFromLastGLEntry(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
        GenJnlLineCOGSCorrectionLbl: Label 'COGS Correction';
        GenJnLineStdCorrectionLbl: Label 'Standard Correction';
    begin
        if not GLEntry.FindLast() then
            exit;
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Posting Date" := GLEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine.Description := GenJnlLineCOGSCorrectionLbl;
            RSRetailCalculationType::"Standard Correction", RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Description := GenJnLineStdCorrectionLbl;
        end;
        GenJournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
        GenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
        GenJournalLine."Document Date" := GLEntry."Posting Date";
        GenJournalLine."Due Date" := GLEntry."Posting Date";
    end;

    local procedure SetGlobalDimensionCodes(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry")
    begin
        GenJournalLine."Shortcut Dimension 1 Code" := CalculationValueEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := CalculationValueEntry."Global Dimension 2 Code";
    end;

    local procedure PostGLAcc(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get(GenJnlLine."Account No.");
        InitGLEntry(GenJnlPostLine, GenJnlLine, GLEntry,
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
        InitVAT(GenJnlLine, GLEntry, GenJnlPostLine);
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
    end;

    local procedure InitVAT(var GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LCYCurrency.InitRoundingPrecision();
        if GenJnlLine."Gen. Posting Type" in [GenJnlLine."Gen. Posting Type"::" "] then
            exit;
        VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group");
        VATPostingSetup.TestField(Blocked, false);

        GenJnlLine.TestField("VAT Calculation Type", VATPostingSetup."VAT Calculation Type");
        case GenJnlLine."VAT Posting" of
            GenJnlLine."VAT Posting"::"Automatic VAT Entry":
                InitVATAutomaticEntry(GLEntry, GenJnlLine, VATPostingSetup, GenJnlPostLine);
            GenJnlLine."VAT Posting"::"Manual VAT Entry":
                InitVATManualEntry(GLEntry, GenJnlLine, GenJnlPostLine);
        end;
    end;

    local procedure InitGLEntry(GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GLAccNo: Code[20]; Amount: Decimal; AmountAddCurr: Decimal; UseAmountAddCurr: Boolean; SystemCreatedEntry: Boolean)
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

    #region VAT Init
    local procedure InitVATAutomaticEntry(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GLEntry.CopyPostingGroupsFromGenJnlLine(GenJnlLine);
        case GenJnlLine."VAT Calculation Type" of
            GenJnlLine."VAT Calculation Type"::"Normal VAT":
                InitNormalVATAmounts(GLEntry, GenJnlLine, VATPostingSetup, GenJnlPostLine);
            GenJnlLine."VAT Calculation Type"::"Reverse Charge VAT":
                InitReverseChargeVATAmounts(GLEntry, GenJnlLine, VATPostingSetup, GenJnlPostLine);
            GenJnlLine."VAT Calculation Type"::"Full VAT":
                InitFullVATAmounts(GLEntry, GenJnlLine, VATPostingSetup, GenJnlPostLine);
            GenJnlLine."VAT Calculation Type"::"Sales Tax":
                InitSalesTaxVATAmounts(GLEntry, GenJnlLine, GenJnlPostLine);
        end;
    end;

    local procedure InitVATManualEntry(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::Settlement then begin
            GLEntry.CopyPostingGroupsFromGenJnlLine(GenJnlLine);
            GLEntry."VAT Amount" := GenJnlLine."VAT Amount (LCY)";
            if GenJnlLine."Source Currency Code" = AddCurrencyCode then
                AddCurrGLEntryVATAmt := GenJnlLine."Source Curr. VAT Amount"
            else
                AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GenJnlLine."VAT Amount (LCY)");
        end;
    end;

    local procedure InitNormalVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if GenJnlLine."VAT Difference" <> 0 then begin
            GLEntry."VAT Amount" := GenJnlLine."Amount (LCY)" - GLEntry.Amount;
            GLEntry."Additional-Currency Amount" := GenJnlLine."Source Curr. VAT Base Amount";
            if GenJnlLine."Source Currency Code" = AddCurrencyCode then
                AddCurrGLEntryVATAmt := GenJnlLine."Source Curr. VAT Amount"
            else
                AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
        end else begin
            GLEntry."VAT Amount" :=
              Round(
                GenJnlLine."Amount (LCY)" * VATPostingSetup."VAT %" / (100 + VATPostingSetup."VAT %"),
                LCYCurrency."Amount Rounding Precision", LCYCurrency.VATRoundingDirection());
            if GenJnlLine."Source Currency Code" = AddCurrencyCode then
                AddCurrGLEntryVATAmt :=
                  Round(
                    GenJnlLine."Source Currency Amount" * VATPostingSetup."VAT %" / (100 + VATPostingSetup."VAT %"),
                    AddCurrency."Amount Rounding Precision", AddCurrency.VATRoundingDirection())
            else
                AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
            GLEntry."Additional-Currency Amount" := GenJnlLine."Source Currency Amount" - AddCurrGLEntryVATAmt;
        end;
    end;

    local procedure InitReverseChargeVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        case GenJnlLine."Gen. Posting Type" of
            GenJnlLine."Gen. Posting Type"::Purchase:
                InitReverseChargeVATPurchase(GLEntry, GenJnlLine, VATPostingSetup, GenJnlPostLine);
            GenJnlLine."Gen. Posting Type"::Sale:
                begin
                    GLEntry."VAT Amount" := 0;
                    AddCurrGLEntryVATAmt := 0;
                end;
        end;
        GLEntry."Additional-Currency Amount" :=
          GLCalcAddCurrency(GLEntry.Amount, GLEntry."Additional-Currency Amount", GLEntry."Additional-Currency Amount", true, GenJnlLine);
    end;

    local procedure InitReverseChargeVATPurchase(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if GenJnlLine."VAT Difference" <> 0 then begin
            GLEntry."VAT Amount" := GenJnlLine."VAT Amount (LCY)";
            if GenJnlLine."Source Currency Code" = AddCurrencyCode then
                AddCurrGLEntryVATAmt := GenJnlLine."Source Curr. VAT Amount"
            else
                AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
        end else begin
            GLEntry."VAT Amount" :=
              Round(
                GLEntry.Amount * VATPostingSetup."VAT %" / 100,
                LCYCurrency."Amount Rounding Precision", LCYCurrency.VATRoundingDirection());
            if GenJnlLine."Source Currency Code" = AddCurrencyCode then
                AddCurrGLEntryVATAmt :=
                  Round(
                    GLEntry."Additional-Currency Amount" * VATPostingSetup."VAT %" / 100,
                    AddCurrency."Amount Rounding Precision", AddCurrency.VATRoundingDirection())
            else
                AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
        end;
    end;

    local procedure InitFullVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        case GenJnlLine."Gen. Posting Type" of
            GenJnlLine."Gen. Posting Type"::Sale:
                GenJnlLine.TestField("Account No.", VATPostingSetup.GetSalesAccount(false));
            GenJnlLine."Gen. Posting Type"::Purchase:
                GenJnlLine.TestField("Account No.", VATPostingSetup.GetPurchAccount(false));
        end;
        GLEntry."Additional-Currency Amount" := 0;
        GLEntry."VAT Amount" := GenJnlLine."Amount (LCY)";
        if GenJnlLine."Source Currency Code" = AddCurrencyCode then
            AddCurrGLEntryVATAmt := GenJnlLine."Source Currency Amount"
        else
            AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GenJnlLine."Amount (LCY)");
    end;

    local procedure InitSalesTaxVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
    begin
        if (GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::Purchase) and
           GenJnlLine."Use Tax"
        then
            GLEntry."VAT Amount" :=
              Round(
                SalesTaxCalculate.CalculateTax(
                  GenJnlLine."Tax Area Code", GenJnlLine."Tax Group Code", GenJnlLine."Tax Liable",
                  GenJnlLine."Posting Date", GenJnlLine."Amount (LCY)", GenJnlLine.Quantity, 0))
        else
            GLEntry."VAT Amount" := GenJnlLine."Amount (LCY)" - GLEntry.Amount;
        GLEntry."Additional-Currency Amount" := GenJnlLine."Source Currency Amount";
        if GenJnlLine."Source Currency Code" = AddCurrencyCode then
            AddCurrGLEntryVATAmt := GenJnlLine."Source Curr. VAT Amount"
        else
            AddCurrGLEntryVATAmt := GenJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
    end;

    #endregion

    #region Additional Item Ledger and Value Entry Posting

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        StdValueEntry: Record "Value Entry";
        StdCorrectionValueEntry: Record "Value Entry";
        SumOfCOGSCostPerUnit: Decimal;
        SumOfCOGSCostAmtAct: Decimal;
    begin
        StdValueEntry.SetRange("Location Code", TempSalesCrMemoLine."Location Code");
        StdValueEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        StdValueEntry.SetRange("Item No.", TempSalesCrMemoLine."No.");
        StdValueEntry.SetRange("Document Line No.", TempSalesCrMemoLine."Line No.");

        if not StdValueEntry.FindFirst() then
            exit;

        InsertAppliedValueEntryAdjust(StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, SalesCrMemoHeader, GenJnlPostLine);

        InsertRetailValueEntry(RetailValueEntry, StdValueEntry, StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct)
    end;

    local procedure InsertAppliedValueEntryAdjust(var StdCorrectionValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        AppliedDocValueEntry: Record "Value Entry";
        QtyTakenFromEntry: Decimal;
        QtyNeeded: Decimal;
    begin
        CorrectStdValueEntry(StdCorrectionValueEntry, StdValueEntry, SalesCrMemoHeader, GenJnlPostLine);

        AppliedDocValueEntry.SetLoadFields("Cost per Unit", "Invoiced Quantity");
        AppliedDocValueEntry.SetRange("Document No.", SalesCrMemoHeader."Applies-to Doc. No.");
        AppliedDocValueEntry.SetRange("Item No.", TempSalesCrMemoLine."No.");
        AppliedDocValueEntry.SetRange("Location Code", TempSalesCrMemoLine."Location Code");
        if AppliedDocValueEntry.IsEmpty() then
            exit;

        QtyNeeded := Abs(TempSalesCrMemoLine.Quantity);

        AppliedDocValueEntry.FindSet();
        repeat
            HandleAppliedDocumentAndInsertCOGSCorrection(AppliedDocValueEntry, StdValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, QtyNeeded, QtyTakenFromEntry, SalesCrMemoHeader, GenJnlPostLine);
        until AppliedDocValueEntry.Next() = 0;
    end;

    local procedure HandleAppliedDocumentAndInsertCOGSCorrection(AppliedDocValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; var QtyNeeded: Decimal; QtyTakenFromEntry: Decimal; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        COGSCorrectionValueEntry: Record "Value Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        COGSCorrectionValueEntryDescLbl: Label 'COGS Correction';
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if QtyNeeded <= 0 then
            exit;
        if not RSRetValueEntryMapp.Get(AppliedDocValueEntry."Entry No.") then
            exit;
        if not ((RSRetValueEntryMapp."COGS Correction") and (RSRetValueEntryMapp.Open)) then
            exit;

        QtyTakenFromEntry := Abs(AppliedDocValueEntry."Invoiced Quantity");

        COGSCorrectionValueEntry.Init();
        COGSCorrectionValueEntry.Copy(StdValueEntry);
        COGSCorrectionValueEntry."Entry No." := COGSCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(COGSCorrectionValueEntry);
        COGSCorrectionValueEntry."Cost per Unit" := Abs(AppliedDocValueEntry."Cost per Unit");

        case true of
            (QtyTakenFromEntry < QtyNeeded) or (QtyTakenFromEntry = QtyNeeded):
                SetValueEntryCostAmtActualAndQuantites(COGSCorrectionValueEntry, QtyTakenFromEntry);
            QtyTakenFromEntry > QtyNeeded:
                SetValueEntryCostAmtActualAndQuantites(COGSCorrectionValueEntry, QtyNeeded);
        end;
        RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, COGSCorrectionValueEntry."Invoiced Quantity");

        QtyNeeded := QtyNeeded - QtyTakenFromEntry;
        COGSCorrectionValueEntry.Description := COGSCorrectionValueEntryDescLbl;
        COGSCorrectionValueEntry.Insert();

        SumOfCOGSCostPerUnit += COGSCorrectionValueEntry."Cost per Unit";
        SumOfCOGSCostAmtAct += Abs(COGSCorrectionValueEntry."Cost Amount (Actual)");

        CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, COGSCorrectionValueEntry, RSRetailCalculationType::"COGS Correction");
        CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, COGSCorrectionValueEntry, RSRetailCalculationType::"Counter COGS Correction");
        RSRLocalizationMgt.InsertGLItemLedgerRelations(COGSCorrectionValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::"COGS Correction"));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(COGSCorrectionValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::"Counter COGS Correction"));
        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(COGSCorrectionValueEntry);
    end;

    local procedure CorrectStdValueEntry(var StdCorrectionValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        StdCorrectionValueEntryDescLbl: Label 'Standard Correction';
    begin
        Clear(StdCorrectionValueEntry);
        StdCorrectionValueEntry.Init();
        StdCorrectionValueEntry.Copy(StdValueEntry);
        StdCorrectionValueEntry."Entry No." := StdCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(StdCorrectionValueEntry);
        StdCorrectionValueEntry."Cost Amount (Actual)" := -StdValueEntry."Cost Amount (Actual)";
        StdCorrectionValueEntry."Cost Posted to G/L" := StdCorrectionValueEntry."Cost Amount (Actual)";
        StdCorrectionValueEntry."Cost per Unit" := -StdValueEntry."Cost per Unit";
        StdCorrectionValueEntry."Invoiced Quantity" := -StdValueEntry."Invoiced Quantity";
        StdCorrectionValueEntry."Valued Quantity" := -StdValueEntry."Valued Quantity";
        StdCorrectionValueEntry."Item Ledger Entry Quantity" := -StdValueEntry."Item Ledger Entry Quantity";
        StdCorrectionValueEntry.Description := StdCorrectionValueEntryDescLbl;
        StdCorrectionValueEntry.Insert();

        CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, StdCorrectionValueEntry, RSRetailCalculationType::"Standard Correction");
        CreateAdditionalGLEntries(GenJnlPostLine, SalesCrMemoHeader, StdCorrectionValueEntry, RSRetailCalculationType::"Counter Std Correction");

        RSRLocalizationMgt.InsertGLItemLedgerRelations(StdCorrectionValueEntry, GetCOGSAccountFromGenPostingSetup(SalesCrMemoHeader));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(StdCorrectionValueEntry, GetRSAccountNoFromSetup(SalesCrMemoHeader, RSRetailCalculationType::"Counter Std Correction"));
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; StdCorrectionValueEntry: Record "Value Entry"; SumOfCOGSCostPerUnit: Decimal; SumOfCOGSCostAmtAct: Decimal)
    var
        CalculationValueEntryDescLbl: Label 'Calculation';
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);
        RetailValueEntry.Description := CalculationValueEntryDescLbl;

        RetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - StdValueEntry."Cost per Unit" - StdCorrectionValueEntry."Cost per Unit" - SumOfCOGSCostPerUnit;

        if PriceListLine."Unit Price" * Abs(StdValueEntry."Invoiced Quantity") <> (StdValueEntry."Cost Amount (Actual)" + StdCorrectionValueEntry."Cost Amount (Actual)" + SumOfCOGSCostAmtAct) then
            RetailValueEntry."Cost Amount (Actual)" := Abs((PriceListLine."Unit Price" * TempSalesCrMemoLine.Quantity) - SumOfCOGSCostAmtAct);

        if PriceListLine."Unit Price" * Abs(StdValueEntry."Invoiced Quantity") <> StdValueEntry."Sales Amount (Actual)" then
            RetailValueEntry."Sales Amount (Actual)" := -CalculateRSGLVATAmount();

        if (RetailValueEntry."Cost Amount (Actual)" = 0) and (RetailValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    #endregion

    #region Retail Price Calculation

    local procedure GetRSAccountNoFromSetup(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
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
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Counter COGS Correction", RSRetailCalculationType::"Counter Std Correction":
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempSalesCrMemoLine."No.", TempSalesCrMemoLine."Location Code"));
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Standard Correction":
                exit(GetCOGSAccountFromGenPostingSetup(SalesCrMemoHeader))
        end;
    end;

    local procedure CalculateSumOfAppliedRetailCostAmounts(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        ValueEntry: Record "Value Entry";
        SumOfCostAmounts: Decimal;
    begin
        SalesInvoiceHeader.Get(SalesCrMemoHeader."Applies-to Doc. No.");

        ValueEntry.SetLoadFields("Cost per Unit");
        ValueEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        ValueEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        ValueEntry.SetRange("Item No.", TempSalesCrMemoLine."No.");
        ValueEntry.SetRange("Location Code", TempSalesCrMemoLine."Location Code");

        if ValueEntry.IsEmpty() then
            exit;

        ValueEntry.FindSet();
        repeat
            case RSRetValueEntryMapp.Get(ValueEntry."Entry No.") of
                true:
                    if RSRetValueEntryMapp."Retail Calculation" then
                        SumOfCostAmounts += ValueEntry."Cost per Unit";
            end;
        until ValueEntry.Next() = 0;

        exit(SumOfCostAmounts * TempSalesCrMemoLine.Quantity)
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        if TempSalesCrMemoLine."Line Discount %" <> 0 then
            exit(-(Abs(TempSalesCrMemoLine.GetLineAmountInclVAT() * RSRLocalizationMgt.CalculateVATBreakDown(TempSalesCrMemoLine."VAT Bus. Posting Group", TempSalesCrMemoLine."VAT Prod. Posting Group"))))
        else
            exit(Abs((PriceListLine."Unit Price" * TempSalesCrMemoLine.Quantity) * RSRLocalizationMgt.CalculateVATBreakDown(TempSalesCrMemoLine."VAT Bus. Posting Group", TempSalesCrMemoLine."VAT Prod. Posting Group")))
    end;

    local procedure CalculateRSGLMarginNoVATAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    begin
        exit(CalculateSumOfAppliedRetailCostAmounts(SalesCrMemoHeader) - CalculateRSGLVATAmount());
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

    local procedure FillRetailSalesLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        Location: Record Location;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '%1|%2', SalesCrMemoLine.Type::Item, SalesCrMemoLine.Type::"Charge (Item)");
        if SalesCrMemoLine.IsEmpty() then
            exit;
        SalesCrMemoLine.FindSet();
        repeat
            if Location.Get(SalesCrMemoLine."Location Code") then
                if Location."NPR Retail Location" then begin
                    TempSalesCrMemoLine.Init();
                    TempSalesCrMemoLine.Copy(SalesCrMemoLine);
                    TempSalesCrMemoLine.Insert();
                end;
        until SalesCrMemoLine.Next() = 0;
    end;

    local procedure FilterPriceListHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PriceListFilter: Text;
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);
        PriceListFilter := SalesCrMemoHeader."Sell-to Customer No.";
        if (SalesCrMemoHeader."Customer Disc. Group" <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesCrMemoHeader."Customer Disc. Group"
        else
            PriceListFilter += SalesCrMemoHeader."Customer Disc. Group";
        if (SalesCrMemoHeader."Customer Price Group" <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesCrMemoHeader."Customer Price Group"
        else
            PriceListFilter += SalesCrMemoHeader."Customer Price Group";
        if (SalesCrMemoHeader."Campaign No." <> '') and (PriceListFilter <> '') then
            PriceListFilter += '|' + SalesCrMemoHeader."Campaign No."
        else
            PriceListFilter += SalesCrMemoHeader."Campaign No.";

        PriceListHeader.SetFilter("Assign-to No.", PriceListFilter);
        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, SalesCrMemoHeader."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, SalesCrMemoHeader."Posting Date"));
    end;

    local procedure FindPriceListLine()
    var
        PriceListNotFoundErr: Label 'Price for the Location %2 has not been found.', Comment = '%1 - Location Code';
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
    begin
        PriceListHeader.SetRange("NPR Location Code", TempSalesCrMemoLine."Location Code");
        if not PriceListHeader.FindFirst() then
            PriceListHeader.SetRange("Assign-to No.", '');
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, TempSalesCrMemoLine."Location Code");

        PriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price", "Starting Date", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", TempSalesCrMemoLine."No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, TempSalesCrMemoLine."No.", PriceListHeader.Code, TempSalesCrMemoLine."Location Code");
    end;

    local procedure GetCOGSAccountFromGenPostingSetup(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        GenPostingSetup.Get(SalesCrMemoHeader."Gen. Bus. Posting Group", TempSalesCrMemoLine."Gen. Prod. Posting Group");
        exit(GenPostingSetup."COGS Account");
    end;

    local procedure SetValueEntryCostAmtActualAndQuantites(var ValueEntry: Record "Value Entry"; Quantity: Decimal)
    begin
        ValueEntry."Cost Amount (Actual)" := ValueEntry."Cost per Unit" * Quantity;
        ValueEntry."Cost Posted to G/L" := ValueEntry."Cost Amount (Actual)";
        ValueEntry."Invoiced Quantity" := Quantity;
        ValueEntry."Valued Quantity" := Quantity;
        ValueEntry."Item Ledger Entry Quantity" := Quantity;
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        LCYCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        TempNivSalesCrMemoLines: Record "Sales Cr.Memo Line" temporary;
        TempSalesCrMemoLine: Record "Sales Cr.Memo Line" temporary;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}