codeunit 6184743 "NPR RS SalesCrMemo GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Sales Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure AddSalesGLEntries(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if SalesCrMemoHeader."No." = '' then
            exit;

        FillRetailSalesLines(SalesCrMemoHeader);

        if not TempSalesCrMemoLine.FindSet() then
            exit;

        FilterPriceListHeader(SalesCrMemoHeader);

        repeat
            FindPriceListLine();

            CreateAdditionalGLEntries(SalesCrMemoHeader, GenJournalLine, RSGLEntryType::VAT);
            CreateAdditionalGLEntries(SalesCrMemoHeader, GenJournalLine, RSGLEntryType::MarginNoVAT);
            CreateAdditionalGLEntries(SalesCrMemoHeader, GenJournalLine, RSGLEntryType::Margin);
            CheckIfNivelationNeeded(SalesCrMemoHeader);

            InsertRetailValueEntry(SalesCrMemoHeader);
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
        if TempNivSalesCrMemoLines.FindSet() then
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

    local procedure CreateAdditionalGLEntries(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenLineFromLastGLEntry(GenJournalLine, RSGLEntryType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
        if RSGLEntryType = RSGLEntryType::Margin then begin
            GenJournalLine.Validate("Credit Amount", CalculateRSAmount(SalesCrMemoHeader, RSGLEntryType));
            if GenJournalLine."Credit Amount" = 0 then
                exit;
            GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
        end
        else begin
            GenJournalLine.Validate("Debit Amount", CalculateRSAmount(SalesCrMemoHeader, RSGLEntryType));
            if GenJournalLine."Debit Amount" = 0 then
                exit;
            GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
        end;

        GenJnlCheckLine.RunCheck(GenJournalLine);
        InitAmounts(GenJournalLine);
        if GenJournalLine."Bill-to/Pay-to No." = '' then
            case true of
                GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Account No.";
                GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer, GenJournalLine."Bal. Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Bal. Account No.";
            end;

        if (RSGLEntryType in [RSGLEntryType::Margin]) then begin
            GenJournalLine."Credit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Debit Amount" := 0;
        end;

        PostGLAcc(GenJournalLine, GLEntry);
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

    local procedure InitGenLineFromLastGLEntry(var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLEntry: Record "G/L Entry";
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        if not GLEntry.FindLast() then
            exit;
        GenJournalLine."Document Type" := GLEntry."Document Type";
        GenJournalLine."Document No." := GLEntry."Document No.";
        GenJournalLine."External Document No." := GLEntry."External Document No.";
        GenJournalLine."Posting Date" := GLEntry."Posting Date";
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSGLEntryType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
        end;
        GenJournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
        GenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
        GenJournalLine."Document Date" := GLEntry."Posting Date";
        GenJournalLine."Due Date" := GLEntry."Posting Date";
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

    local procedure InsertRetailValueEntry(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Location Code", TempSalesCrMemoLine."Location Code");
        ValueEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        ValueEntry.SetRange("Item No.", TempSalesCrMemoLine."No.");
        if not ValueEntry.FindFirst() then
            exit;

        InsertValueEntry(SalesCrMemoHeader, ValueEntry)
    end;

    local procedure InsertValueEntry(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; ValueEntryIn: Record "Value Entry")
    var
        NewValueEntry: Record "Value Entry";
        CalculationValueEntryDescLbl: Label 'Calculation';
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(ValueEntryIn);
        NewValueEntry."Entry No." := ValueEntryIn.GetLastEntryNo() + 1;
        ResetValueEntryAmounts(NewValueEntry);
        if PriceListLine."Unit Price" <> Abs(ValueEntryIn."Cost Amount (Actual)") then
            NewValueEntry."Cost Amount (Actual)" := -CalculateRSGLMarginAmount(SalesCrMemoHeader);
        if PriceListLine."Unit Price" <> Abs(ValueEntryIn."Sales Amount (Actual)") then
            NewValueEntry."Sales Amount (Actual)" := -(PriceListLine."Unit Price" - Abs(ValueEntryIn."Sales Amount (Actual)"));

        if (NewValueEntry."Cost Amount (Actual)" = 0) and (NewValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        NewValueEntry.Description := CalculationValueEntryDescLbl;

        NewValueEntry."Cost Posted to G/L" := NewValueEntry."Cost Amount (Actual)";

        NewValueEntry.Insert();

        InsertGLItemLedgerRelation(NewValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::VAT));
        InsertGLItemLedgerRelation(NewValueEntry, GetInventoryAccountFromInvPostingSetup(NewValueEntry."Location Code"));
        InsertGLItemLedgerRelation(NewValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::MarginNoVAT));
    end;

    local procedure InsertGLItemLedgerRelation(ValueEntry: Record "Value Entry"; GLAccountNo: Code[20])
    var
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
    begin
        GenJnlPostLine.GetGLReg(GLRegister);
        GLItemLedgerRelation.Init();
        GLItemLedgerRelation."Value Entry No." := ValueEntry."Entry No.";
        GLItemLedgerRelation."G/L Register No." := GLRegister."No.";

        GLEntry.SetLoadFields("Entry No.", "G/L Account No.", "Document No.");
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Document No.", ValueEntry."Document No.");
        if not GLEntry.FindFirst() then
            exit;
        GLItemLedgerRelation."G/L Entry No." := GLEntry."Entry No.";
        GLItemLedgerRelation.Insert(true);
    end;

    #endregion

    #region Retail Price Calculation

    local procedure GetRSAccountNoFromSetup(RSGLEntryType: Option VAT,Margin,MarginNoVAT): Code[20]
    var
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
                exit(GetInventoryAccountFromInvPostingSetup(TempSalesCrMemoLine."Location Code"));
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    local procedure CalculateRSAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Decimal
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                exit(CalculateRSGLVATAmount());
            RSGLEntryType::Margin:
                exit(CalculateRSGLMarginAmount(SalesCrMemoHeader));
            RSGLEntryType::MarginNoVAT:
                exit(CalculateRSGLMarginNoVATAmount(SalesCrMemoHeader));
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        if TempSalesCrMemoLine."Line Discount %" <> 0 then
            exit(-(Abs(TempSalesCrMemoLine.GetLineAmountInclVAT() * FindVATBreakDown())))
        else
            exit(-(Abs((PriceListLine."Unit Price" * TempSalesCrMemoLine.Quantity) * FindVATBreakDown())))
    end;

    local procedure CalculateRSGLMarginAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    begin
        if TempSalesCrMemoLine."Line Discount %" <> 0 then
            exit(-(Abs(TempSalesCrMemoLine.GetLineAmountInclVAT() - Abs(CalculateCostPerUnitForAppliedInvoice(SalesCrMemoHeader)))))
        else
            exit(-Abs(PriceListLine."Unit Price" - Abs(CalculateCostPerUnitForAppliedInvoice(SalesCrMemoHeader))));
    end;

    local procedure CalculateRSGLMarginNoVATAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    begin
        exit(-Abs(CalculateRSGLMarginAmount(SalesCrMemoHeader) - CalculateRSGLVATAmount()))
    end;

    local procedure CalculateCostPerUnitForAppliedInvoice(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ValueEntry: Record "Value Entry";
    begin
        SalesInvoiceHeader.Get(SalesCrMemoHeader."Applies-to Doc. No.");

        ValueEntry.SetLoadFields("Document No.", "Document Line No.", "Posting Date", "Location Code", "Item No.", "Cost per Unit");
        ValueEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        ValueEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        ValueEntry.SetRange("Item No.", TempSalesCrMemoLine."No.");
        ValueEntry.SetRange("Location Code", TempSalesCrMemoLine."Location Code");
        ValueEntry.FindFirst();

        exit(ValueEntry."Cost per Unit" * TempSalesCrMemoLine.Quantity);
    end;

    local procedure FindVATBreakDown(): Decimal
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        if not Item.Get(TempSalesCrMemoLine."No.") then
            exit;
        if not VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group") then
            exit;
        exit((100 * VATSetup."VAT %") / (100 + VATSetup."VAT %") / 100);
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
        if not SalesCrMemoLine.FindSet() then
            exit;
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
        PriceListHeader.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "NPR Location Code", "Assign-to No.");
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

    local procedure GetInventoryAccountFromInvPostingSetup(LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        Item.Get(TempSalesCrMemoLine."No.");
        if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
            Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                    InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    local procedure ResetValueEntryAmounts(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry."Cost Amount (Actual)" := 0;
        ValueEntry."Cost Amount (Expected)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)" := 0;
        ValueEntry."Cost Amount (Actual) (ACY)" := 0;
        ValueEntry."Cost Amount (Expected) (ACY)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)(ACY)" := 0;
        ValueEntry."Sales Amount (Actual)" := 0;
        ValueEntry."Sales Amount (Expected)" := 0;
        ValueEntry."Valued Quantity" := 0;
        ValueEntry."Invoiced Quantity" := 0;
        ValueEntry."Item Ledger Entry Quantity" := 0;
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