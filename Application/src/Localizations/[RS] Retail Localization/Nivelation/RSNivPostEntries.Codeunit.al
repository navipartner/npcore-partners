codeunit 6151372 "NPR RS Niv. Post Entries"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "VAT Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "Item Journal Line" = rimd;

#if not (BC17 or BC18 or BC19)
    internal procedure PostNivelationEntries(var PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr")
    var
        PostedNivelationLine: Record "NPR RS Posted Nivelation Lines";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        PostedNivelationLine.SetRange("Document No.", PostedNivelationHeader."No.");
        if not PostedNivelationLine.FindSet() then
            exit;
        repeat
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationLine, RSGLEntryType::Margin);
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationLine, RSGLEntryType::VAT);
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationLine, RSGLEntryType::MarginNoVAT);

            PostValueItemLedgEntries(PostedNivelationHeader, PostedNivelationLine);
        until PostedNivelationLine.Next() = 0;
    end;

    #region Posting GL Entries

    local procedure CreateAndPostGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenJnlLine(GenJournalLine, PostedNivelationLines);
        GenJournalLine."Document Type" := "Gen. Journal Document Type"::"NPR Nivelation";
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(PostedNivelationLines, RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        if PostedNivelationLines."Price Difference" < 0 then
            if RSGLEntryType = RSGLEntryType::Margin then
                GenJournalLine.Validate("Credit Amount", CalculateRSAmount(PostedNivelationLines, RSGLEntryType))
            else
                GenJournalLine.Validate("Debit Amount", CalculateRSAmount(PostedNivelationLines, RSGLEntryType))
        else
            if RSGLEntryType = RSGLEntryType::Margin then
                GenJournalLine.Validate("Debit Amount", CalculateRSAmount(PostedNivelationLines, RSGLEntryType))
            else
                GenJournalLine.Validate("Credit Amount", CalculateRSAmount(PostedNivelationLines, RSGLEntryType));

        GenJnlCheckLine.RunCheck(GenJournalLine);
        InitAmounts(GenJournalLine);
        if GenJournalLine."Bill-to/Pay-to No." = '' then
            case true of
                GenJournalLine."Account Type" in [GenJournalLine."Account Type"::Customer, GenJournalLine."Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Account No.";
                GenJournalLine."Bal. Account Type" in [GenJournalLine."Bal. Account Type"::Customer, GenJournalLine."Bal. Account Type"::Vendor]:
                    GenJournalLine."Bill-to/Pay-to No." := GenJournalLine."Bal. Account No.";
            end;

        GenJournalLine."VAT Bus. Posting Group" := PostedNivelationLines."VAT Bus. Posting Gr. (Price)";

        PostGLAcc(GenJournalLine, GLEntry, GLSetup, RSGLEntryType);
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

    local procedure PostGLAcc(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; GLSetup: Record "General Ledger Setup"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLAcc: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
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
        InitVAT(GenJnlLine, GLEntry, VATPostingSetup);
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
        if RSGLEntryType = RSGLEntryType::Margin then
            PostVAT(GenJnlLine, GLEntry, VATPostingSetup, GLSetup);
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

    local procedure InitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines")
    var
        Item2: Record Item;
        GenJnlLineDescriptionLbl: Label 'Nivelation';
    begin
        GenJournalLine."Document No." := PostedNivelationLines."Document No.";
        GenJournalLine."Posting Date" := PostedNivelationLines."Posting Date";
        GenJournalLine.Description := GenJnlLineDescriptionLbl;
        if Item2.Get(PostedNivelationLines."Item No.") then begin
            GenJournalLine."VAT Bus. Posting Group" := Item2."VAT Bus. Posting Gr. (Price)";
            GenJournalLine."VAT Prod. Posting Group" := Item2."VAT Prod. Posting Group";
        end;
        GenJournalLine."Gen. Posting Type" := "General Posting Type"::"NPR Nivelation";
        GenJournalLine."Document Date" := PostedNivelationLines."Posting Date";
        GenJournalLine."Due Date" := PostedNivelationLines."Posting Date";
    end;

    #endregion

    #region VAT Posting

    local procedure PostVAT(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; VATPostingSetup: Record "VAT Posting Setup"; GLSetup: Record "General Ledger Setup")
    var
        TaxDetail2: Record "Tax Detail";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SalesTaxCalculate: Codeunit "Sales Tax Calculate";
        TaxDetailFound: Boolean;
        RemSrcCurrVATAmount: Decimal;
        SalesTaxBaseAmount: Decimal;
        SrcCurrSalesTaxBaseAmount: Decimal;
        SrcCurrVATAmount: Decimal;
        SrcCurrVATBase: Decimal;
        VATAmount: Decimal;
        VATAmount2: Decimal;
        VATBase: Decimal;
        VATBase2: Decimal;
    begin
        case GenJnlLine."VAT Calculation Type" of
            GenJnlLine."VAT Calculation Type"::"Normal VAT",
            GenJnlLine."VAT Calculation Type"::"Reverse Charge VAT",
            GenJnlLine."VAT Calculation Type"::"Full VAT":
                begin
                    if GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Automatic VAT Entry" then
                        GenJnlLine."VAT Base Amount (LCY)" := GLEntry.Amount - GLEntry."VAT Amount";
                    if GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::Settlement then
                        AddCurrGLEntryVATAmt := GenJnlLine."Source Curr. VAT Amount";
                    InsertVAT(
                          GenJnlLine, VATPostingSetup,
                          GLEntry.Amount - GLEntry."VAT Amount", GLEntry."VAT Amount", GenJnlLine."VAT Base Amount (LCY)", GenJnlLine."Source Currency Code",
                          GLEntry."Additional-Currency Amount", AddCurrGLEntryVATAmt, GenJnlLine."Source Curr. VAT Base Amount", GLSetup);
                    NextConnectionNo := NextConnectionNo + 1;
                end;
            GenJnlLine."VAT Calculation Type"::"Sales Tax":
                begin
                    case GenJnlLine."VAT Posting" of
                        GenJnlLine."VAT Posting"::"Automatic VAT Entry":
                            SalesTaxBaseAmount := GLEntry.Amount - GLEntry."VAT Amount";
                        GenJnlLine."VAT Posting"::"Manual VAT Entry":
                            SalesTaxBaseAmount := GenJnlLine."VAT Base Amount (LCY)";
                    end;
                    if (GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Manual VAT Entry") and
                       (GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::Settlement)
                    then
                        InsertVAT(
                           GenJnlLine, VATPostingSetup,
                           GLEntry.Amount - GLEntry."VAT Amount", GLEntry."VAT Amount", GenJnlLine."VAT Base Amount (LCY)", GenJnlLine."Source Currency Code",
                           GenJnlLine."Source Curr. VAT Base Amount", GenJnlLine."Source Curr. VAT Amount", GenJnlLine."Source Curr. VAT Base Amount", GLSetup)
                    else begin
                        Clear(SalesTaxCalculate);
                        SalesTaxCalculate.InitSalesTaxLines(
                          GenJnlLine."Tax Area Code", GenJnlLine."Tax Group Code", GenJnlLine."Tax Liable",
                          SalesTaxBaseAmount, GenJnlLine.Quantity, GenJnlLine."Posting Date", GLEntry."VAT Amount");
                        SrcCurrVATAmount := 0;
                        SrcCurrSalesTaxBaseAmount := GenJnlPostLine.CalcLCYToAddCurr(SalesTaxBaseAmount);
                        RemSrcCurrVATAmount := AddCurrGLEntryVATAmt;
                        TaxDetailFound := false;
                        while SalesTaxCalculate.GetSalesTaxLine(TaxDetail2, VATAmount, VATBase) do begin
                            RemSrcCurrVATAmount := RemSrcCurrVATAmount - SrcCurrVATAmount;
                            if TaxDetailFound then
                                InsertVAT(
                                  GenJnlLine, VATPostingSetup,
                                  SalesTaxBaseAmount, VATAmount2, VATBase2, GenJnlLine."Source Currency Code",
                                  SrcCurrSalesTaxBaseAmount, SrcCurrVATAmount, SrcCurrVATBase, GLSetup);
                            TaxDetailFound := true;
                            TaxDetail := TaxDetail2;
                            VATAmount2 := VATAmount;
                            VATBase2 := VATBase;
                            SrcCurrVATAmount := GenJnlPostLine.CalcLCYToAddCurr(VATAmount);
                            SrcCurrVATBase := GenJnlPostLine.CalcLCYToAddCurr(VATBase);
                        end;
                        if TaxDetailFound then
                            InsertVAT(
                              GenJnlLine, VATPostingSetup,
                              SalesTaxBaseAmount, VATAmount2, VATBase2, GenJnlLine."Source Currency Code",
                              SrcCurrSalesTaxBaseAmount, RemSrcCurrVATAmount, SrcCurrVATBase, GLSetup);
                    end;
                end;
        end;
    end;

    local procedure InsertVAT(GenJnlLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; GLEntryAmount: Decimal; GLEntryVATAmount: Decimal; GLEntryBaseAmount: Decimal; SrcCurrCode: Code[10]; SrcCurrGLEntryAmt: Decimal; SrcCurrGLEntryVATAmt: Decimal; SrcCurrGLEntryBaseAmt: Decimal; GLSetup: Record "General Ledger Setup")
    var
        TaxJurisdiction: Record "Tax Jurisdiction";
        VATEntry: Record "VAT Entry";
        UnrealizedVAT: Boolean;
        SrcCurrVATAmount: Decimal;
        SrcCurrVATBase: Decimal;
        SrcCurrVATDifference: Decimal;
        VATAmount: Decimal;
        VATBase: Decimal;
        VATDifferenceLCY: Decimal;
    begin
        VATEntry.Init();
        VATEntry.CopyFromGenJnlLine(GenJnlLine);
        FindLastVATEntryNo();
        VATEntry."Entry No." := NextVATEntryNo;
        VATEntry."EU Service" := VATPostingSetup."EU Service";
        VATEntry."Transaction No." := NextTransactionNo;
        VATEntry."Sales Tax Connection No." := NextConnectionNo;

        if GenJnlLine."VAT Difference" = 0 then
            VATDifferenceLCY := 0
        else
            if GenJnlLine."Currency Code" = '' then
                VATDifferenceLCY := GenJnlLine."VAT Difference"
            else
                VATDifferenceLCY :=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                      GenJnlLine."Posting Date", GenJnlLine."Currency Code", GenJnlLine."VAT Difference",
                      CurrExchRate.ExchangeRate(GenJnlLine."Posting Date", GenJnlLine."Currency Code")));

        if GenJnlLine."VAT Calculation Type" = GenJnlLine."VAT Calculation Type"::"Sales Tax" then
            UpdateVATEntryTaxDetails(GenJnlLine, VATEntry, TaxDetail, TaxJurisdiction);

        if AddCurrencyCode <> '' then
            if AddCurrencyCode <> SrcCurrCode then begin
                SrcCurrGLEntryAmt := ExchangeAmtLCYToFCY2(GLEntryAmount);
                SrcCurrGLEntryVATAmt := ExchangeAmtLCYToFCY2(GLEntryVATAmount);
                SrcCurrGLEntryBaseAmt := ExchangeAmtLCYToFCY2(GLEntryBaseAmount);
                SrcCurrVATDifference := ExchangeAmtLCYToFCY2(VATDifferenceLCY);
            end else
                SrcCurrVATDifference := GenJnlLine."VAT Difference";

        UnrealizedVAT := CheckUnrealizedVAT(VATPostingSetup, TaxJurisdiction, GenJnlLine);

        if GLSetup."Prepayment Unrealized VAT" and not GLSetup."Unrealized VAT" and
           (VATPostingSetup."Unrealized VAT Type" > 0)
        then
            UnrealizedVAT := GenJnlLine.Prepayment;

        if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" " then begin
            case GenJnlLine."VAT Posting" of
                GenJnlLine."VAT Posting"::"Automatic VAT Entry":
                    begin
                        VATAmount := GLEntryVATAmount;
                        VATBase := GLEntryBaseAmount;
                        SrcCurrVATAmount := SrcCurrGLEntryVATAmt;
                        SrcCurrVATBase := SrcCurrGLEntryBaseAmt;
                    end;
                GenJnlLine."VAT Posting"::"Manual VAT Entry":
                    begin
                        if GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::Settlement then begin
                            VATAmount := GLEntryAmount;
                            SrcCurrVATAmount := SrcCurrGLEntryVATAmt;
                            VATEntry.Closed := true;
                        end else begin
                            VATAmount := GLEntryVATAmount;
                            SrcCurrVATAmount := SrcCurrGLEntryVATAmt;
                        end;
                        VATBase := GLEntryBaseAmount;
                        SrcCurrVATBase := SrcCurrGLEntryBaseAmt;
                    end;
            end;

            if UnrealizedVAT then begin
                VATEntry.Amount := 0;
                VATEntry.Base := 0;
                VATEntry."Unrealized Amount" := VATAmount;
                VATEntry."Unrealized Base" := VATBase;
                VATEntry."Remaining Unrealized Amount" := VATEntry."Unrealized Amount";
                VATEntry."Remaining Unrealized Base" := VATEntry."Unrealized Base";
            end else begin
                VATEntry.Amount := VATAmount;
                VATEntry.Base := VATBase;
                VATEntry."Unrealized Amount" := 0;
                VATEntry."Unrealized Base" := 0;
                VATEntry."Remaining Unrealized Amount" := 0;
                VATEntry."Remaining Unrealized Base" := 0;
            end;

            if AddCurrencyCode = '' then begin
                VATEntry."Additional-Currency Base" := 0;
                VATEntry."Additional-Currency Amount" := 0;
                VATEntry."Add.-Currency Unrealized Amt." := 0;
                VATEntry."Add.-Currency Unrealized Base" := 0;
            end else
                if UnrealizedVAT then begin
                    VATEntry."Additional-Currency Base" := 0;
                    VATEntry."Additional-Currency Amount" := 0;
                    VATEntry."Add.-Currency Unrealized Base" := SrcCurrVATBase;
                    VATEntry."Add.-Currency Unrealized Amt." := SrcCurrVATAmount;
                end else begin
                    VATEntry."Additional-Currency Base" := SrcCurrVATBase;
                    VATEntry."Additional-Currency Amount" := SrcCurrVATAmount;
                    VATEntry."Add.-Currency Unrealized Base" := 0;
                    VATEntry."Add.-Currency Unrealized Amt." := 0;
                end;
            VATEntry."Add.-Curr. Rem. Unreal. Amount" := VATEntry."Add.-Currency Unrealized Amt.";
            VATEntry."Add.-Curr. Rem. Unreal. Base" := VATEntry."Add.-Currency Unrealized Base";
            VATEntry."VAT Difference" := VATDifferenceLCY;
            VATEntry."Add.-Curr. VAT Difference" := SrcCurrVATDifference;
            if GenJnlLine."System-Created Entry" then
                VATEntry."Base Before Pmt. Disc." := GenJnlLine."VAT Base Before Pmt. Disc."
            else
                VATEntry."Base Before Pmt. Disc." := GLEntryAmount;

            VATEntry."Document No." := GenJnlLine."Document No.";
            VATEntry."Document Type" := GenJnlLine."Document Type";

            VATEntry.Insert(true);
            NextVATEntryNo := NextVATEntryNo + 1;
        end;
    end;

    local procedure CheckUnrealizedVAT(VATPostingSetup: Record "VAT Posting Setup"; TaxJurisdiction: Record "Tax Jurisdiction"; GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        if (((VATPostingSetup."Unrealized VAT Type" > 0) and
            (VATPostingSetup."VAT Calculation Type" in
             [VATPostingSetup."VAT Calculation Type"::"Normal VAT",
              VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT",
              VATPostingSetup."VAT Calculation Type"::"Full VAT"])) or
           ((TaxJurisdiction."Unrealized VAT Type" > 0) and
            (VATPostingSetup."VAT Calculation Type" in
             [VATPostingSetup."VAT Calculation Type"::"Sales Tax"]))) and
          IsNotPayment(GenJnlLine."Document Type") then
            exit(true);
        exit(false);
    end;

    local procedure InitVAT(var GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var VATPostingSetup: Record "VAT Posting Setup")
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

    local procedure UpdateVATEntryTaxDetails(GenJnlLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry"; TaxDetailParam: Record "Tax Detail"; var TaxJurisdiction: Record "Tax Jurisdiction")
    begin
        if TaxDetailParam."Tax Jurisdiction Code" <> '' then
            TaxJurisdiction.Get(TaxDetailParam."Tax Jurisdiction Code");
        if GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::Settlement then begin
            VATEntry."Tax Group Used" := TaxDetailParam."Tax Group Code";
            VATEntry."Tax Type" := TaxDetailParam."Tax Type";
            VATEntry."Tax on Tax" := TaxDetailParam."Calculate Tax on Tax";
        end;
        VATEntry."Tax Jurisdiction Code" := TaxDetailParam."Tax Jurisdiction Code";
    end;

    #endregion

    #region Retail Price Calculation

    local procedure GetRSAccountNoFromSetup(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Code[20]
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
                    InventoryPostingSetup.SetRange("Location Code", PostedNivelationLines."Location Code");
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

    local procedure CalculateRSAmount(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Decimal
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                exit(CalculateRSGLVATAmount(PostedNivelationLines));
            RSGLEntryType::Margin:
                exit(CalculateRSGLMarginAmount(PostedNivelationLines));
            RSGLEntryType::MarginNoVAT:
                exit(CalculateRSGLMarginNoVATAmount(PostedNivelationLines));
        end;
    end;

    local procedure CalculateRSGLVATAmount(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"): Decimal
    begin
        exit(Abs(PostedNivelationLines."Calculated VAT"));
    end;

    local procedure CalculateRSGLMarginAmount(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"): Decimal
    begin
        exit(Abs(PostedNivelationLines."Value Difference"));
    end;

    local procedure CalculateRSGLMarginNoVATAmount(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"): Decimal
    begin
        exit(Abs(PostedNivelationLines."Value Difference" - PostedNivelationLines."Calculated VAT"));
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

    #region Posting Value and Item Ledger Entries
    procedure PostValueItemLedgEntries(PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLine: Record "NPR RS Posted Nivelation Lines")
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        InitItemJnlLine(ItemJournalLine, PostedNivelationLine);

        PostItemLedgerEntry(ItemLedgEntry, ItemJournalLine, PostedNivelationHeader);

        PostValueEntry(ItemJournalLine, ItemLedgEntry, PostedNivelationHeader);

        ItemJournalLine.Delete();
    end;

    local procedure InitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; PostedNivelationLine: Record "NPR RS Posted Nivelation Lines")
    begin
        ItemJournalLine.Init();
        ItemJournalLine."Item No." := PostedNivelationLine."Item No.";
        ItemJournalLine.Description := PostedNivelationLine."Item Description";
        ItemJournalLine."Posting Date" := PostedNivelationLine."Posting Date";
        ItemJournalLine.Amount := PostedNivelationLine."Value Difference";
        ItemJournalLine."Value Entry Type" := "Cost Entry Type"::"NPR Nivelation";
        ItemJournalLine."Document No." := PostedNivelationLine."Document No.";
        ItemJournalLine."Document Type" := "Item Ledger Document Type"::"NPR Nivelation";
        ItemJournalLine."Location Code" := PostedNivelationLine."Location Code";
        ItemJournalLine.Correction := true;

        ItemJournalLine.Insert(false);
    end;

    local procedure PostItemLedgerEntry(var ItemLedgEntry: Record "Item Ledger Entry"; ItemJnlLine: Record "Item Journal Line"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr")
    var
        ItemLedgEntryNo: Integer;
    begin
        ItemLedgEntryNo := ItemLedgEntry.GetLastEntryNo() + 1;

        ItemLedgEntry.Init();
        ItemLedgEntry."Entry No." := ItemLedgEntryNo;
        ItemLedgEntry."Item No." := ItemJnlLine."Item No.";
        ItemLedgEntry."Posting Date" := ItemJnlLine."Posting Date";
        ItemLedgEntry."Document No." := ItemJnlLine."Document No.";
        ItemLedgEntry."Document Type" := ItemJnlLine."Document Type";
        ItemLedgEntry."Document Line No." := ItemJnlLine."Document Line No.";
        ItemLedgEntry."Order Type" := ItemJnlLine."Order Type";
        ItemLedgEntry."Order No." := ItemJnlLine."Order No.";
        ItemLedgEntry."Order Line No." := ItemJnlLine."Order Line No.";
        ItemLedgEntry."External Document No." := ItemJnlLine."External Document No.";
        ItemLedgEntry.Description := ItemJnlLine.Description;
        ItemLedgEntry."Location Code" := ItemJnlLine."Location Code";
        ItemLedgEntry."Applies-to Entry" := ItemJnlLine."Applies-to Entry";
        ItemLedgEntry."Source Type" := ItemJnlLine."Source Type";
        ItemLedgEntry."No. Series" := ItemJnlLine."Posting No. Series";
        ItemLedgEntry."Variant Code" := ItemJnlLine."Variant Code";
        ItemLedgEntry."Unit of Measure Code" := ItemJnlLine."Unit of Measure Code";
        ItemLedgEntry."Qty. per Unit of Measure" := ItemJnlLine."Qty. per Unit of Measure";
        ItemLedgEntry."Derived from Blanket Order" := ItemJnlLine."Derived from Blanket Order";
        ItemLedgEntry."Item Reference No." := ItemJnlLine."Item Reference No.";
        ItemLedgEntry."Originally Ordered No." := ItemJnlLine."Originally Ordered No.";
        ItemLedgEntry."Originally Ordered Var. Code" := ItemJnlLine."Originally Ordered Var. Code";
        ItemLedgEntry."Out-of-Stock Substitution" := ItemJnlLine."Out-of-Stock Substitution";
        ItemLedgEntry."Item Category Code" := ItemJnlLine."Item Category Code";
        ItemLedgEntry.Correction := ItemJnlLine.Correction;

        case PostedNivelationHeader.Type of
            PostedNivelationHeader.Type::"Price Change":
                begin
                    ItemLedgEntry."Entry Type" := "Item Ledger Entry Type"::Purchase;
                    ItemLedgEntry."Cost Amount (Actual)" := ItemJnlLine.Amount;
                end;
            PostedNivelationHeader.Type::"Promotions & Discounts":
                begin
                    ItemLedgEntry."Entry Type" := "Item Ledger Entry Type"::Sale;
                    ItemLedgEntry."Sales Amount (Actual)" := ItemJnlLine.Amount;
                end;
        end;

        ItemLedgEntry.Insert(true);
    end;

    local procedure PostValueEntry(ItemJnlLine: Record "Item Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr")
    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        ValueEntryNo: Integer;
    begin
        ValueEntryNo := ValueEntry.GetLastEntryNo() + 1;

        ValueEntry.Init();
        ValueEntry."Entry No." := ValueEntryNo;
        ValueEntry."Entry Type" := "Cost Entry Type"::"NPR Nivelation";
        ValueEntry."Item Ledger Entry Type" := ItemLedgerEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Document No." := ItemJnlLine."Document No.";

        ValueEntry."No." := ItemJnlLine."No.";
        ValueEntry.Description := ItemJnlLine.Description;

        case PostedNivelationHeader.Type of
            PostedNivelationHeader.Type::"Price Change":
                ValueEntry."Cost Amount (Actual)" := ItemJnlLine.Amount;
            PostedNivelationHeader.Type::"Promotions & Discounts":
                ValueEntry."Sales Amount (Actual)" := ItemJnlLine.Amount;
        end;

        if Item.Get(ItemJnlLine."Item No.") then begin
            ValueEntry."Inventory Posting Group" := Item."Inventory Posting Group";
            ValueEntry."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        end;

        ValueEntry."Posting Date" := ItemJnlLine."Posting Date";
        ValueEntry."Valuation Date" := ItemJnlLine."Posting Date";
        ValueEntry."Document Type" := ItemJnlLine."Document Type";

        ValueEntry."Document Line No." := ItemJnlLine."Document Line No.";
        ValueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(ValueEntry."User ID"));
        ValueEntry."Journal Batch Name" := ItemJnlLine."Journal Batch Name";

        ValueEntry.Insert(true);
    end;

    #endregion

    #region Helper procedures
    local procedure FindLastVATEntryNo()
    var
        VATEntry2: Record "VAT Entry";
    begin
        if VATEntry2.FindLast() then
            NextVATEntryNo := VATEntry2."Entry No." + 1
        else
            NextVATEntryNo := 1;
    end;

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

    local procedure IsNotPayment(DocumentType: Enum "Gen. Journal Document Type") Result: Boolean
    begin
        Result := DocumentType in [DocumentType::Invoice,
                              DocumentType::"Credit Memo",
                              DocumentType::"Finance Charge Memo",
                              DocumentType::Reminder];
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
    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        TaxDetail: Record "Tax Detail";
        LCYCurrency: Record Currency;
        GJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextConnectionNo: Integer;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NextVATEntryNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';

#endif
}