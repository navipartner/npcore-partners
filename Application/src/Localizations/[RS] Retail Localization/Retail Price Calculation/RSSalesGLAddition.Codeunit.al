codeunit 6151094 "NPR RS Sales GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)

    #region Eventsubscribers - RS Sales Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(SalesInvoiceHeader: Record "Sales Invoice Header"; PreviewMode: Boolean)
    begin
        PostRetailCalculationEntries(SalesInvoiceHeader, PreviewMode);
    end;

    #endregion

    #region Sales Invoice Calculation Posting

    internal procedure PostRetailCalculationEntries(SalesInvoiceHeader: Record "Sales Invoice Header"; PreviewMode: Boolean)
    var
        RetailValueEntry: Record "Value Entry";
        SourceCodeSetup: Record "Source Code Setup";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if SalesInvoiceHeader."No." = '' then
            exit;

        TempSalesInvoiceLine.Reset();
        TempSalesInvoiceLine.DeleteAll();
        TempNivSalesInvLines.Reset();
        TempNivSalesInvLines.DeleteAll();
        FillRetailSalesLines(SalesInvoiceHeader);

        if TempSalesInvoiceLine.IsEmpty() then
            exit;

        TempSalesInvoiceLine.FindSet();
        repeat
            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempSalesInvoiceLine."No.", TempSalesInvoiceLine."Location Code", TempSalesInvoiceLine."Posting Date");

            InsertRetailValueEntries(RetailValueEntry, SalesInvoiceHeader);

            if (RetailValueEntry."Entry No." <> 0) and (RetailValueEntry."Cost Amount (Actual)" <> 0) then begin
                CreateAdditionalGLEntries(RetailValueEntry, SalesInvoiceHeader, RSRetailCalculationType::"Margin with VAT");
                CreateAdditionalGLEntries(RetailValueEntry, SalesInvoiceHeader, RSRetailCalculationType::VAT);
                CreateAdditionalGLEntries(RetailValueEntry, SalesInvoiceHeader, RSRetailCalculationType::Margin);
                RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::VAT));
                RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::"Margin with VAT"));
                RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::Margin));
            end;

            CheckIfNivelationNeeded(SalesInvoiceHeader);
        until TempSalesInvoiceLine.Next() = 0;

        if not TempNivSalesInvLines.IsEmpty() and not PreviewMode then
            CreateAndPostNivelationDocument(SalesInvoiceHeader);

        RSRLocalizationMgt.ValidateGLEntriesBalanced(SalesInvoiceHeader."No.");

        SourceCodeSetup.Get();
        RSRLocalizationMgt.AddGLEntriesToGLRegister(SalesInvoiceHeader."No.", SourceCodeSetup.Sales);
    end;

    #endregion

    #region Nivelation Document Posting
    local procedure CreateAndPostNivelationDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        NivelationLines: Record "NPR RS Nivelation Lines";
        NivelationPost: Codeunit "NPR RS Nivelation Post";
        LineNo: Integer;
    begin
        NivelationHeader.Init();
        NivelationHeader.Type := "NPR RS Nivelation Type"::"Promotions & Discounts";
        NivelationHeader."Source Type" := "NPR RS Nivelation Source Type"::"Posted Sales Invoice";
        NivelationHeader."Referring Document Code" := SalesInvoiceHeader."No.";
        NivelationHeader."Posting Date" := SalesInvoiceHeader."Posting Date";
        NivelationHeader.Insert(true);
        LineNo := NivelationLines.GetInitialLine() + 10000;
        TempNivSalesInvLines.FindSet();
        repeat
            NivelationLines.Init();
            NivelationLines."Line No." := LineNo;
            NivelationLines."Document No." := NivelationHeader."No.";
            NivelationLines."Location Code" := TempNivSalesInvLines."Location Code";
            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempNivSalesInvLines."No.", TempNivSalesInvLines."Location Code", TempNivSalesInvLines."Posting Date");
            NivelationLines."Price Valid Date" := PriceListLine."Starting Date";
            NivelationLines."Posting Date" := SalesInvoiceHeader."Posting Date";
            NivelationLines."VAT Bus. Posting Gr. (Price)" := PriceListLine."VAT Bus. Posting Gr. (Price)";
            NivelationLines.Validate("Item No.", TempNivSalesInvLines."No.");
            NivelationLines."Old Price" := PriceListLine."Unit Price";
            NivelationLines.Quantity := TempNivSalesInvLines.Quantity;
            NivelationLines.Validate("New Price", RSRLocalizationMgt.RoundAmountToCurrencyRounding((TempNivSalesInvLines.GetLineAmountInclVAT() / TempNivSalesInvLines.Quantity), SalesInvoiceHeader."Currency Code"));
            NivelationLines.Insert(true);
            LineNo += 10000;
        until TempNivSalesInvLines.Next() = 0;

        NivelationPost.RunNivelationPosting(NivelationHeader, true)
    end;

    local procedure CheckIfNivelationNeeded(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        case true of
            ((SalesInvoiceHeader."Prices Including VAT") and (PriceListLine."Price Includes VAT")) or ((not SalesInvoiceHeader."Prices Including VAT") and (not PriceListLine."Price Includes VAT")):
                if (TempSalesInvoiceLine."Unit Price" - TempSalesInvoiceLine."Line Discount Amount") = PriceListLine."Unit Price" then
                    exit;
            (SalesInvoiceHeader."Prices Including VAT") and (not PriceListLine."Price Includes VAT"):
                if (Round((TempSalesInvoiceLine."Unit Price" - TempSalesInvoiceLine."Line Discount Amount" - (TempSalesInvoiceLine."Unit Price" * (100 * TempSalesInvoiceLine."VAT %") / (100 + TempSalesInvoiceLine."VAT %") / 100)))) = Round(PriceListLine."Unit Price") then
                    exit;
            (not SalesInvoiceHeader."Prices Including VAT") and (PriceListLine."Price Includes VAT"):
                if Round(TempSalesInvoiceLine."Unit Price" - TempSalesInvoiceLine."Line Discount Amount") = Round((PriceListLine."Unit Price" - (PriceListLine."Unit Price" * ((100 * TempSalesInvoiceLine."VAT %") / (100 + TempSalesInvoiceLine."VAT %") / 100)))) then
                    exit;
        end;
        TempNivSalesInvLines.Init();
        TempNivSalesInvLines.Copy(TempSalesInvoiceLine);
        TempNivSalesInvLines.Insert();
    end;

    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        InitGenJournalLine(GenJournalLine, SalesInvoiceHeader, CalculationValueEntry, RSRetailCalculationType);
        GLSetup.Get();
        AddCurrencyCode := GLSetup."Additional Reporting Currency";
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        ValidateGenJnlLinePositiveAmounts(GenJournalLine, RSRetailCalculationType, CalculationValueEntry);

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

    local procedure ValidateGenJnlLinePositiveAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Credit Amount", Abs(CalculationValueEntry."Cost Posted to G/L"));
            RSRetailCalculationType::"Counter COGS Correction", RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Validate("Credit Amount", -CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Standard Correction":
                GenJournalLine.Validate("Debit Amount", -CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"));
        end;
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

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; SalesInvoiceHeader: Record "Sales Invoice Header"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
        GenJnlLineCOGSCorrectionLbl: Label 'COGS Correction';
        GenJnLineStdCorrectionLbl: Label 'Standard Correction';
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
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine.Description := GenJnlLineCOGSCorrectionLbl;
            RSRetailCalculationType::"Standard Correction", RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Description := GenJnLineStdCorrectionLbl;
        end;
        GenJournalLine."VAT Reporting Date" := CalculationValueEntry."VAT Reporting Date";
        GenJournalLine."Document Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Due Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Source Code" := CalculationValueEntry."Source Code";
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType);
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
        InitVAT(GenJnlLine, GLEntry);
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
    end;

    local procedure InitVAT(var GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
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
                InitVATAutomaticEntry(GLEntry, GenJnlLine, VATPostingSetup);
            GenJnlLine."VAT Posting"::"Manual VAT Entry":
                InitVATManualEntry(GLEntry, GenJnlLine);
        end;
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

    #region VAT Init
    local procedure InitVATAutomaticEntry(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        GLEntry.CopyPostingGroupsFromGenJnlLine(GenJnlLine);
        case GenJnlLine."VAT Calculation Type" of
            GenJnlLine."VAT Calculation Type"::"Normal VAT":
                InitNormalVATAmounts(GLEntry, GenJnlLine, VATPostingSetup);
            GenJnlLine."VAT Calculation Type"::"Reverse Charge VAT":
                InitReverseChargeVATAmounts(GLEntry, GenJnlLine, VATPostingSetup);
            GenJnlLine."VAT Calculation Type"::"Full VAT":
                InitFullVATAmounts(GLEntry, GenJnlLine, VATPostingSetup);
            GenJnlLine."VAT Calculation Type"::"Sales Tax":
                InitSalesTaxVATAmounts(GLEntry, GenJnlLine);
        end;
    end;

    local procedure InitVATManualEntry(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line")
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

    local procedure InitNormalVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
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

    local procedure InitReverseChargeVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        case GenJnlLine."Gen. Posting Type" of
            GenJnlLine."Gen. Posting Type"::Purchase:
                InitReverseChargeVATPurchase(GLEntry, GenJnlLine, VATPostingSetup);
            GenJnlLine."Gen. Posting Type"::Sale:
                begin
                    GLEntry."VAT Amount" := 0;
                    AddCurrGLEntryVATAmt := 0;
                end;
        end;
        GLEntry."Additional-Currency Amount" :=
          GLCalcAddCurrency(GLEntry.Amount, GLEntry."Additional-Currency Amount", GLEntry."Additional-Currency Amount", true, GenJnlLine);
    end;

    local procedure InitReverseChargeVATPurchase(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
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

    local procedure InitFullVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup")
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

    local procedure InitSalesTaxVATAmounts(var GLEntry: Record "G/L Entry"; GenJnlLine: Record "Gen. Journal Line")
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

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        StdValueEntry: Record "Value Entry";
        StdCorrectionValueEntry: Record "Value Entry";
        SumOfCOGSCostPerUnit: Decimal;
        SumOfCOGSCostAmtAct: Decimal;
    begin
        StdValueEntry.SetRange("Location Code", TempSalesInvoiceLine."Location Code");
        StdValueEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        StdValueEntry.SetRange("Item No.", TempSalesInvoiceLine."No.");
        StdValueEntry.SetRange("Document Line No.", TempSalesInvoiceLine."Line No.");

        if not StdValueEntry.FindFirst() then
            exit;

        InsertAppliedValueEntryAdj(StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, SalesInvoiceHeader);

        InsertRetailValueEntry(RetailValueEntry, SalesInvoiceHeader, StdValueEntry, StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct)
    end;

    local procedure InsertAppliedValueEntryAdj(var StdCorrectionValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
        TempApplicationItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ApplValueEntry: Record "Value Entry";
        ShowAppliedEntries: Codeunit "Show Applied Entries";
        QtyTakenFromEntry: Decimal;
        QtyNeeded: Decimal;
    begin
        if not StdItemLedgerEntry.Get(StdValueEntry."Item Ledger Entry No.") then
            exit;

        CorrectStdValueEntry(StdCorrectionValueEntry, StdValueEntry, SalesInvoiceHeader);

        ShowAppliedEntries.FindAppliedEntries(StdItemLedgerEntry, TempApplicationItemLedgerEntry);

        if TempApplicationItemLedgerEntry.IsEmpty() then
            exit;

        QtyNeeded := TempSalesInvoiceLine.Quantity;

        TempApplicationItemLedgerEntry.FindSet();
        repeat
            ApplValueEntry.SetRange("Item Ledger Entry No.", TempApplicationItemLedgerEntry."Entry No.");
            if ApplValueEntry.FindSet() then
                repeat
                    HandleApplicationValueEntry(ApplValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, QtyNeeded, QtyTakenFromEntry, StdValueEntry, SalesInvoiceHeader);
                until (ApplValueEntry.Next() = 0) or (QtyNeeded <= 0);
        until TempApplicationItemLedgerEntry.Next() = 0;
    end;

    local procedure HandleApplicationValueEntry(ApplValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; var QtyNeeded: Decimal; QtyTakenFromEntry: Decimal; StdValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        if not RSRetValueEntryMapp.Get(ApplValueEntry."Entry No.") then
            exit;
        if not ((RSRetValueEntryMapp."COGS Correction") and (RSRetValueEntryMapp.Open)) then
            exit;

        QtyTakenFromEntry := RSRetValueEntryMapp."Remaining Quantity";
        case true of
            (QtyTakenFromEntry < QtyNeeded) or (QtyTakenFromEntry = QtyNeeded):
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, SalesInvoiceHeader, CalculateAppliedCostPerUnit(ApplValueEntry), QtyTakenFromEntry);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyTakenFromEntry);
                end;
            QtyTakenFromEntry > QtyNeeded:
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, SalesInvoiceHeader, CalculateAppliedCostPerUnit(ApplValueEntry), QtyNeeded);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyNeeded);
                end;
        end;
        QtyNeeded := QtyNeeded - QtyTakenFromEntry;
    end;

    local procedure CalculateAppliedCostPerUnit(ApplValueEntry: Record "Value Entry") AppliedCostPerUnit: Decimal
    var
        ItemChargeValueEntries: Record "Value Entry";
    begin
        ItemChargeValueEntries.SetLoadFields("Cost per Unit");
        ItemChargeValueEntries.SetRange("Item Ledger Entry No.", ApplValueEntry."Item Ledger Entry No.");
        ItemChargeValueEntries.SetFilter("Item Charge No.", '<>%1', '');
        if ItemChargeValueEntries.IsEmpty() then
            AppliedCostPerUnit := ApplValueEntry."Cost per Unit"
        else begin
            ItemChargeValueEntries.CalcSums("Cost per Unit");
            AppliedCostPerUnit := ApplValueEntry."Cost per Unit" + ItemChargeValueEntries."Cost per Unit";
        end;
    end;

    local procedure InsertCOGSCorrectionValueEntry(var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header"; ApplCostPerUnit: Decimal; ApplQty: Decimal)
    var
        COGSCorrectionValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        CorrectionEntryDescLbl: Label 'COGS Correction';
    begin
        COGSCorrectionValueEntry.Init();
        COGSCorrectionValueEntry.Copy(StdValueEntry);
        COGSCorrectionValueEntry."Entry No." := COGSCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(COGSCorrectionValueEntry);
        COGSCorrectionValueEntry."Cost per Unit" := ApplCostPerUnit;
        COGSCorrectionValueEntry."Invoiced Quantity" := -ApplQty;
        COGSCorrectionValueEntry."Item Ledger Entry Quantity" := -ApplQty;
        COGSCorrectionValueEntry."Valued Quantity" := -ApplQty;
        COGSCorrectionValueEntry."Cost Amount (Actual)" := COGSCorrectionValueEntry."Cost per Unit" * COGSCorrectionValueEntry."Invoiced Quantity";
        COGSCorrectionValueEntry."Cost Posted to G/L" := COGSCorrectionValueEntry."Cost Amount (Actual)";
        COGSCorrectionValueEntry.Description := CorrectionEntryDescLbl;
        COGSCorrectionValueEntry.Insert();

        SumOfCOGSCostPerUnit += COGSCorrectionValueEntry."Cost per Unit";
        SumOfCOGSCostAmtAct += Abs(COGSCorrectionValueEntry."Cost Amount (Actual)");

        CreateAdditionalGLEntries(COGSCorrectionValueEntry, SalesInvoiceHeader, RSRetailCalculationType::"COGS Correction");
        CreateAdditionalGLEntries(COGSCorrectionValueEntry, SalesInvoiceHeader, RSRetailCalculationType::"Counter COGS Correction");
        RSRLocalizationMgt.InsertGLItemLedgerRelations(COGSCorrectionValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::"COGS Correction"));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(COGSCorrectionValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::"Counter COGS Correction"));

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(COGSCorrectionValueEntry);
    end;

    local procedure CorrectStdValueEntry(var StdCorrectionValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        StdCorrectionValueEntryDescLbl: Label 'Standard Correction';
    begin
        Clear(StdCorrectionValueEntry);
        StdCorrectionValueEntry.Init();
        StdCorrectionValueEntry.Copy(StdValueEntry);
        StdCorrectionValueEntry."Entry No." := StdCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(StdCorrectionValueEntry);
        StdCorrectionValueEntry."Cost Amount (Actual)" := Abs(StdValueEntry."Cost Amount (Actual)");
        StdCorrectionValueEntry."Cost Posted to G/L" := StdCorrectionValueEntry."Cost Amount (Actual)";
        StdCorrectionValueEntry."Cost per Unit" := -StdValueEntry."Cost per Unit";
        StdCorrectionValueEntry."Invoiced Quantity" := Abs(StdValueEntry."Invoiced Quantity");
        StdCorrectionValueEntry."Valued Quantity" := Abs(StdValueEntry."Valued Quantity");
        StdCorrectionValueEntry."Item Ledger Entry Quantity" := Abs(StdValueEntry."Item Ledger Entry Quantity");
        StdCorrectionValueEntry.Description := StdCorrectionValueEntryDescLbl;
        StdCorrectionValueEntry.Insert();

        RSRLocalizationMgt.InsertStdCorrectionValueEntryMappingEntry(StdCorrectionValueEntry);

        CreateAdditionalGLEntries(StdCorrectionValueEntry, SalesInvoiceHeader, RSRetailCalculationType::"Standard Correction");
        CreateAdditionalGLEntries(StdCorrectionValueEntry, SalesInvoiceHeader, RSRetailCalculationType::"Counter Std Correction");

        RSRLocalizationMgt.InsertGLItemLedgerRelations(StdCorrectionValueEntry, GetCOGSAccountFromGenPostingSetup(SalesInvoiceHeader));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(StdCorrectionValueEntry, GetRSAccountNoFromSetup(SalesInvoiceHeader, RSRetailCalculationType::"Counter Std Correction"));
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; SalesInvoiceHeader: Record "Sales Invoice Header"; StdValueEntry: Record "Value Entry"; StdCorrectionValueEntry: Record "Value Entry"; SumOfCOGSCostPerUnit: Decimal; SumOfCOGSCostAmtAct: Decimal)
    var
        CalculationValueEntryDescLbl: Label 'Calculation';
        DiscountPerUnit: Decimal;
        SumOfStdCostPerUnit: Decimal;
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;

        RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);

        DiscountPerUnit := TempSalesInvoiceLine."Line Discount Amount" / TempSalesInvoiceLine.Quantity;
        SumOfStdCostPerUnit := StdValueEntry."Cost per Unit" + SumOfCOGSCostPerUnit + StdCorrectionValueEntry."Cost per Unit";
        RetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - SumOfStdCostPerUnit - DiscountPerUnit;
        RetailValueEntry."Cost per Unit" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Cost per Unit", SalesInvoiceHeader."Currency Code");

        if (PriceListLine."Unit Price" * TempSalesInvoiceLine.Quantity) <> (StdValueEntry."Cost Amount (Actual)" + StdCorrectionValueEntry."Cost Amount (Actual)" + SumOfCOGSCostAmtAct) then begin
            RetailValueEntry."Cost Amount (Actual)" := -Abs((PriceListLine."Unit Price" * TempSalesInvoiceLine.Quantity) - SumOfCOGSCostAmtAct - TempSalesInvoiceLine."Line Discount Amount");
            RetailValueEntry."Cost Amount (Actual)" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Cost Amount (Actual)", SalesInvoiceHeader."Currency Code");
        end;

        if (PriceListLine."Unit Price" * TempSalesInvoiceLine.Quantity) <> Abs(StdValueEntry."Sales Amount (Actual)") then begin
            RetailValueEntry."Sales Amount (Actual)" := CalculateRSGLVATAmount();
            RetailValueEntry."Sales Amount (Actual)" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Sales Amount (Actual)", SalesInvoiceHeader."Currency Code");
        end;

        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        if (RetailValueEntry."Cost Amount (Actual)" = 0) and (RetailValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        RetailValueEntry.Description := CalculationValueEntryDescLbl;

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;
    #endregion

    #region Retail Price Calculation

    local procedure GetRSAccountNoFromSetup(SalesInvoiceHeader: Record "Sales Invoice Header"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
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
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempSalesInvoiceLine."No.", TempSalesInvoiceLine."Location Code"));
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Standard Correction":
                exit(GetCOGSAccountFromGenPostingSetup(SalesInvoiceHeader))
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    var
        CalculatedLineAmount: Decimal;
    begin
        CalculatedLineAmount := (PriceListLine."Unit Price" * TempSalesInvoiceLine.Quantity) - TempSalesInvoiceLine."Line Discount Amount";
        exit(CalculatedLineAmount * RSRLocalizationMgt.CalculateVATBreakDown(TempSalesInvoiceLine."VAT Bus. Posting Group", TempSalesInvoiceLine."VAT Prod. Posting Group"))
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

    local procedure FillRetailSalesLines(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '%1|%2', SalesInvoiceLine.Type::Item, SalesInvoiceLine.Type::"Charge (Item)");
        if SalesInvoiceLine.IsEmpty() then
            exit;
        SalesInvoiceLine.FindSet();
        repeat
            if RSRLocalizationMgt.IsRetailLocation(SalesInvoiceLine."Location Code") then
                case SalesInvoiceLine.Type of
                    SalesInvoiceLine.Type::Item:
                        if not (RSRLocalizationMgt.IsServiceItem(SalesInvoiceLine."No.")) then
                            InsertRetailSalesLine(SalesInvoiceLine);
                    SalesInvoiceLine.Type::"Charge (Item)":
                        InsertRetailSalesLine(SalesInvoiceLine);
                end;
        until SalesInvoiceLine.Next() = 0;
    end;

    local procedure InsertRetailSalesLine(SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        TempSalesInvoiceLine.Init();
        TempSalesInvoiceLine.Copy(SalesInvoiceLine);
        TempSalesInvoiceLine.Insert();
    end;

    local procedure GetCOGSAccountFromGenPostingSetup(SalesInvoiceHeader: Record "Sales Invoice Header"): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        GenPostingSetup.Get(SalesInvoiceHeader."Gen. Bus. Posting Group", TempSalesInvoiceLine."Gen. Prod. Posting Group");
        exit(GenPostingSetup."COGS Account");
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        LCYCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempNivSalesInvLines: Record "Sales Invoice Line" temporary;
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}
