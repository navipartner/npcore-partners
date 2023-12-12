codeunit 6151094 "NPR RS Sales GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Sales Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure AddSalesGLEntries(SalesHeader: Record "Sales Header")
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        FillRetailSalesLines(SalesHeader);

        if not TempSalesLine.FindSet() then
            exit;

        FilterPriceListLines(SalesHeader);

        CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::Margin);
        CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::VAT);

        repeat
            CreateAdditionalGLEntries(GenJnlPostLine, RSGLEntryType::MarginNoVAT);
            CheckIfNivelationNeeded();
        until TempSalesLine.Next() = 0;

        if not TempNivelationSalesLines.IsEmpty() then
            CreateAndPostNivelationDocument(SalesHeader);
    end;
    #endregion

    #region Nivelation Document Posting
    local procedure CreateAndPostNivelationDocument(SalesHeader: Record "Sales Header")
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        NivelationLines: Record "NPR RS Nivelation Lines";
        VATSetup: Record "VAT Posting Setup";
        NivelationPost: Codeunit "NPR RS Nivelation Post";
        LineNo: Integer;
    begin
        NivelationHeader.Init();
        NivelationHeader.Type := "NPR RS Nivelation Type"::"Promotions & Discounts";
        NivelationHeader."Referring Document Code" := SalesHeader."No.";
        NivelationHeader."Posting Date" := SalesHeader."Posting Date";
        NivelationHeader.Insert(true);
        LineNo := NivelationLines.GetInitialLine(NivelationHeader);
        if TempNivelationSalesLines.FindSet() then
            repeat
                NivelationLines.Init();
                NivelationLines."Line No." := LineNo;
                NivelationLines."Document No." := NivelationHeader."No.";
                NivelationLines."Location Code" := TempNivelationSalesLines."Location Code";
                NivelationLines.Validate("Item No.", TempNivelationSalesLines."No.");
                NivelationLines.Quantity := TempNivelationSalesLines.Quantity;
                PriceListLine.SetRange("Asset No.", TempNivelationSalesLines."No.");
                if PriceListLine.FindFirst() then begin
                    NivelationLines."Old Price" := PriceListLine."Unit Price";
                    NivelationLines."VAT Bus. Posting Gr. (Price)" := PriceListLine."VAT Bus. Posting Gr. (Price)";
                end;
                NivelationLines."New Price" := TempNivelationSalesLines."Unit Price";
                NivelationLines."Posting Date" := SalesHeader."Posting Date";
                NivelationLines."Old Value" := NivelationLines."Old Price" * NivelationLines.Quantity;
                if VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", TempNivelationSalesLines."VAT Prod. Posting Group") then
                    NivelationLines."VAT %" := VATSetup."VAT %";

                NivelationLines.Insert(true);
                LineNo += 10000;
            until TempNivelationSalesLines.Next() = 0;
        NivelationHeader.CalcFields(Amount);
        NivelationHeader.Modify();

        NivelationPost.RunNivelationPosting(NivelationHeader)
    end;

    local procedure CheckIfNivelationNeeded()
    begin
        PriceListLine.SetRange("Asset No.", TempSalesLine."No.");
        if not PriceListLine.FindFirst() then
            exit;
        if TempSalesLine."Unit Price" = PriceListLine."Unit Price" then
            exit;
        TempNivelationSalesLines.Init();
        TempNivelationSalesLines.Copy(TempSalesLine);
        TempNivelationSalesLines.Insert();
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
            GenJournalLine.Validate("Credit Amount", CalculateRSAmount(RSGLEntryType, GenJournalLine))
        else
            GenJournalLine.Validate("Debit Amount", CalculateRSAmount(RSGLEntryType, GenJournalLine));

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
        if not GLEntry.FindLast() then
            exit;
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
        LocalizationSetup: Record "NPR RS R Localization Setup";
        InventoryPostingSetup: Record "Inventory Posting Setup";
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
                    InventoryPostingSetup.SetRange("Location Code", TempSalesLine."Location Code");
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
            PriceListLine.SetRange("Asset No.", TempSalesLine."No.");
            if PriceListLine.FindFirst() then
                CalcVat += (PriceListLine."Unit Price" * TempSalesLine.Quantity) * FindVATBreakDown(TempSalesLine);
        until TempSalesLine.Next() = 0;
        exit(CalcVat);
    end;

    local procedure CalculateRSGLMarginAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        CalcMarg: Decimal;
    begin
        repeat
            PriceListLine.SetRange("Asset No.", TempSalesLine."No.");
            if PriceListLine.FindFirst() then
                CalcMarg += (PriceListLine."Unit Price" * TempSalesLine.Quantity) - GetValueEntryCostAmount(GenJnlLine);
        until TempSalesLine.Next() = 0;
        exit(CalcMarg);
    end;

    local procedure CalculateRSGLMarginNoVATAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    begin
        PriceListLine.SetRange("Asset No.", TempSalesLine."No.");
        if not PriceListLine.FindFirst() then
            exit;
        exit(PriceListLine."Unit Price" * TempSalesLine.Quantity - Abs(GetValueEntryCostAmount(GenJnlLine)) - (PriceListLine."Unit Price" * TempSalesLine.Quantity * FindVATBreakDown(TempSalesLine)));
    end;

    local procedure GetValueEntryCostAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        ValueEntry.SetLoadFields("Item No.", "Document No.", "Location Code", "Document Line No.", "Item Ledger Entry No.", "Cost Amount (Actual)");
        ValueEntry.SetRange("Item No.", TempSalesLine."No.");
        ValueEntry.SetRange("Document No.", GenJnlLine."Document No.");
        ValueEntry.SetRange("Location Code", TempSalesLine."Location Code");
        ValueEntry.SetRange("Document Line No.", TempSalesLine."Line No.");
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(Abs(ValueEntry."Cost Amount (Actual)"));
    end;

    local procedure FindVATBreakDown(TempSalesLine2: Record "Sales Line" temporary): Decimal
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        if not Item.Get(TempSalesLine2."No.") then
            exit;
        if not VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            exit;
        exit((100 * VATSetup."VAT %") / (100 + VATSetup."VAT %") / 100);
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
                AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GenJnlLine."VAT Amount (LCY)");
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
                AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
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
                AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
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
                AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
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
                AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
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
            AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GenJnlLine."Amount (LCY)");
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
            AddCurrGLEntryVATAmt := GJnlPostLine.CalcLCYToAddCurr(GLEntry."VAT Amount");
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

    local procedure FillRetailSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Location: Record Location;
    begin
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.FindSet() then
            exit;
        repeat
            if Location.Get(SalesLine."Location Code") then
                if Location."NPR Retail Location" then begin
                    TempSalesLine.Init();
                    TempSalesLine.Copy(SalesLine);
                    TempSalesLine.Insert();
                end;
        until SalesLine.Next() = 0;
    end;

    local procedure FilterPriceListLines(SalesHeader: Record "Sales Header")
    begin
        PriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Source No.", "Asset Type", "Asset No.", "Variant Code", "Starting Date", "Ending Date", "Minimum Quantity");
        PriceListLine.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "Asset No.", "Unit Price");
        PriceListLine.SetRange("Price Type", "Price Type"::Sale);
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, SalesHeader."Posting Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, SalesHeader."Posting Date"));
    end;
    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempNivelationSalesLines: Record "Sales Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        LCYCurrency: Record Currency;
        GJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
        StartingDateFilter: Label '<=%1', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Locked = true;
#endif
}