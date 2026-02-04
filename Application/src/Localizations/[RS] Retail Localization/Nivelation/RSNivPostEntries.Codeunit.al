codeunit 6151372 "NPR RS Niv. Post Entries"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
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
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationHeader, PostedNivelationLine, RSGLEntryType::Margin);
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationHeader, PostedNivelationLine, RSGLEntryType::VAT);
            CreateAndPostGLEntries(GenJnlPostLine, PostedNivelationHeader, PostedNivelationLine, RSGLEntryType::MarginNoVAT);

            PostValueItemLedgEntries(PostedNivelationHeader, PostedNivelationLine);
        until PostedNivelationLine.Next() = 0;
    end;

    #region Posting GL Entries

    local procedure CreateAndPostGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGenJnlLine(GenJournalLine, PostedNivelationHeader, PostedNivelationLines, RSGLEntryType);
        GenJournalLine."Document Type" := "Gen. Journal Document Type"::"NPR Nivelation";
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(PostedNivelationLines, RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        ValidateGenJournalLineAmounts(GenJournalLine, PostedNivelationHeader, PostedNivelationLines, RSGLEntryType);

        if GenJournalLine.Amount = 0 then
            exit;

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

        PostGLAcc(GenJournalLine, GLEntry);
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

    local procedure InitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    var
        Item2: Record Item;
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        GenJournalLine."Document No." := PostedNivelationHeader."No.";
        GenJournalLine."External Document No." := PostedNivelationHeader."Referring Document Code";
        GenJournalLine."Posting Date" := PostedNivelationLines."Posting Date";
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSGLEntryType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
        end;
        if Item2.Get(PostedNivelationLines."Item No.") then begin
            GenJournalLine."VAT Bus. Posting Group" := Item2."VAT Bus. Posting Gr. (Price)";
            GenJournalLine."VAT Prod. Posting Group" := Item2."VAT Prod. Posting Group";
        end;
        GenJournalLine."Gen. Posting Type" := "General Posting Type"::"NPR Nivelation";
        GenJournalLine."Document Date" := PostedNivelationLines."Posting Date";
        GenJournalLine."Due Date" := PostedNivelationLines."Posting Date";
    end;
    #endregion


    #region Retail Price Calculation
    local procedure GetRSAccountNoFromSetup(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Code[20]
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
                exit(GetInventoryAccountFromInvPostingSetup(PostedNivelationLines));
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
        end;
    end;

    local procedure ValidateGenJournalLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        case PostedNivelationHeader."Source Type" of
            PostedNivelationHeader."Source Type"::"POS Entry":
                ValidateGenJournalLinePOSEntryAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType);
            PostedNivelationHeader."Source Type"::"Posted Sales Invoice":
                ValidateGenJournalLineSalesInvoiceAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType);
            PostedNivelationHeader."Source Type"::"Posted Sales Credit Memo":
                ValidateGenJournalLineSalesCrMemoAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType);
            PostedNivelationHeader."Source Type"::"Sales Price List":
                ValidateGenJournalLineSalesPriceListAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType);
        end;
    end;

    local procedure ValidateGenJournalLinePOSEntryAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        if PostedNivelationLines.Quantity > 0 then begin
            case RSGLEntryType of
                RSGLEntryType::Margin:
                    GenJournalLine.Validate("Credit Amount", Abs(PostedNivelationLines."Value Difference"));
                RSGLEntryType::MarginNoVAT:
                    GenJournalLine.Validate("Debit Amount", RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Value Difference"), '') -
                                                            RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Calculated VAT"), ''));
                RSGLEntryType::VAT:
                    GenJournalLine.Validate("Debit Amount", Abs(PostedNivelationLines."Calculated VAT"));
            end;
        end else begin
            case RSGLEntryType of
                RSGLEntryType::Margin:
                    GenJournalLine.Validate("Credit Amount", -PostedNivelationLines."Value Difference");
                RSGLEntryType::MarginNoVAT:
                    GenJournalLine.Validate("Debit Amount", -(RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Value Difference"), '') -
                                                                RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Calculated VAT"), '')));
                RSGLEntryType::VAT:
                    GenJournalLine.Validate("Debit Amount", -(PostedNivelationLines."Calculated VAT"));
            end;
        end;
    end;

    local procedure ValidateGenJournalLineSalesInvoiceAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Credit Amount", Abs(PostedNivelationLines."Value Difference"));
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Value Difference"), '') -
                                                        RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Calculated VAT"), ''));
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", Abs(PostedNivelationLines."Calculated VAT"));
        end;
    end;

    local procedure ValidateGenJournalLineSalesCrMemoAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Credit Amount", -PostedNivelationLines."Value Difference");
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", -(RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Value Difference"), '') -
                                                            RSRLocalizationMgt.RoundAmountToCurrencyRounding(Abs(PostedNivelationLines."Calculated VAT"), '')));
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", -(PostedNivelationLines."Calculated VAT"));
        end;
    end;

    local procedure ValidateGenJournalLineSalesPriceListAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        if PostedNivelationLines."Value Difference" < 0 then
            ValidateNegativeValueDifferenceSalesPriceListAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType)
        else
            ValidatePositiveValueDifferenceSalesPriceListAmounts(GenJournalLine, PostedNivelationLines, RSGLEntryType);
    end;

    local procedure ValidateNegativeValueDifferenceSalesPriceListAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Credit Amount", Abs(PostedNivelationLines."Value Difference"));
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", Abs(PostedNivelationLines."Calculated VAT"));
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", Abs(RSRLocalizationMgt.RoundAmountToCurrencyRounding(PostedNivelationLines."Value Difference", '') -
                            RSRLocalizationMgt.RoundAmountToCurrencyRounding(PostedNivelationLines."Calculated VAT", '')));
        end;
    end;

    local procedure ValidatePositiveValueDifferenceSalesPriceListAmounts(var GenJournalLine: Record "Gen. Journal Line"; PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Debit Amount", Abs(PostedNivelationLines."Value Difference"));
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Credit Amount", Abs(PostedNivelationLines."Calculated VAT"));
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Credit Amount", Abs(RSRLocalizationMgt.RoundAmountToCurrencyRounding(PostedNivelationLines."Value Difference", '') -
                            RSRLocalizationMgt.RoundAmountToCurrencyRounding(PostedNivelationLines."Calculated VAT", '')));
        end;
    end;
    #endregion

    #region Posting Value and Item Ledger Entries
    procedure PostValueItemLedgEntries(PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLine: Record "NPR RS Posted Nivelation Lines")
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        InitItemJnlLine(ItemJournalLine, PostedNivelationHeader, PostedNivelationLine);

        PostValueEntry(ValueEntry, ItemJournalLine, ItemLedgEntry);

        PostItemLedgerEntry(ItemLedgEntry, ItemJournalLine, PostedNivelationHeader);

        ValueEntry."Item Ledger Entry Type" := ItemLedgEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgEntry."Entry No.";
        ValueEntry.Modify();

        InsertGLItemLedgerRelation(PostedNivelationLine, ValueEntry);

        RSRLocalizationMgt.InsertNivelationValueEntryMappingEntry(ValueEntry);

        ItemJournalLine.Delete();
    end;

    local procedure InitItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"; PostedNivelationLine: Record "NPR RS Posted Nivelation Lines")
    var
        Item: Record Item;
    begin
        ItemJournalLine.Init();
        ItemJournalLine."Item No." := PostedNivelationLine."Item No.";
        ItemJournalLine.Description := PostedNivelationLine."Item Description";
        ItemJournalLine."Posting Date" := PostedNivelationLine."Posting Date";
        ItemJournalLine.Amount := PostedNivelationLine."Value Difference";
        ItemJournalLine."Value Entry Type" := "Cost Entry Type"::"NPR Nivelation";
        ItemJournalLine."Document No." := PostedNivelationHeader."No.";
        ItemJournalLine."External Document No." := PostedNivelationHeader."Referring Document Code";
        ItemJournalLine."Document Type" := "Item Ledger Document Type"::"NPR Nivelation";
        ItemJournalLine."Location Code" := PostedNivelationLine."Location Code";
        ItemJournalLine.Quantity := PostedNivelationLine.Quantity;
        if Item.Get(PostedNivelationLine."Item No.") then begin
            ItemJournalLine."Unit of Measure Code" := Item."Base Unit of Measure";
            ItemJournalLine."Item Category Code" := Item."Item Category Code";
            ItemJournalLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
            ItemJournalLine."Inventory Posting Group" := Item."Inventory Posting Group";
        end;
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
        ItemLedgEntry."External Document No." := ItemJnlLine."External Document No.";
        ItemLedgEntry."Document Type" := ItemJnlLine."Document Type";
        ItemLedgEntry."Document Line No." := ItemJnlLine."Document Line No.";
        ItemLedgEntry."Order Type" := ItemJnlLine."Order Type";
        ItemLedgEntry."Order No." := ItemJnlLine."Order No.";
        ItemLedgEntry."Order Line No." := ItemJnlLine."Order Line No.";
        ItemLedgEntry.Description := ItemJnlLine.Description;
        ItemLedgEntry."Location Code" := ItemJnlLine."Location Code";
        ItemLedgEntry."Unit of Measure Code" := ItemJnlLine."Unit of Measure Code";
        ItemLedgEntry."Item Category Code" := ItemJnlLine."Item Category Code";
        ItemLedgEntry.Correction := ItemJnlLine.Correction;
        ItemLedgEntry.CalcFields("Cost Amount (Actual)");

        case PostedNivelationHeader.Type of
            PostedNivelationHeader.Type::"Price Change":
                ItemLedgEntry."Entry Type" := "Item Ledger Entry Type"::Purchase;
            PostedNivelationHeader.Type::"Promotions & Discounts":
                ItemLedgEntry."Entry Type" := "Item Ledger Entry Type"::Sale;
        end;

        ItemLedgEntry.Insert(true);
    end;

    local procedure PostValueEntry(var ValueEntry: Record "Value Entry"; ItemJnlLine: Record "Item Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ValueEntryNo: Integer;
    begin
        ValueEntryNo := ValueEntry.GetLastEntryNo() + 1;

        ValueEntry.Init();
        ValueEntry."Entry No." := ValueEntryNo;
        ValueEntry."Entry Type" := "Cost Entry Type"::"NPR Nivelation";
        ValueEntry."Item Ledger Entry Type" := ItemLedgerEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Item No." := ItemJnlLine."Item No.";
        ValueEntry."Variant Code" := ItemJnlLine."Variant Code";
        ValueEntry."Document No." := ItemJnlLine."Document No.";
        ValueEntry."External Document No." := ItemJnlLine."External Document No.";
        ValueEntry."Location Code" := ItemJnlLine."Location Code";
        ValueEntry."Gen. Prod. Posting Group" := ItemJnlLine."Gen. Prod. Posting Group";
        ValueEntry."Inventory Posting Group" := ItemJnlLine."Inventory Posting Group";
        ValueEntry."No." := ItemJnlLine."No.";
        ValueEntry.Description := ItemJnlLine.Description;
        ValueEntry."Posting Date" := ItemJnlLine."Posting Date";
        ValueEntry."Valuation Date" := ItemJnlLine."Posting Date";
        ValueEntry."Document Type" := ItemJnlLine."Document Type";
        ValueEntry."Document Line No." := ItemJnlLine."Document Line No.";
        ValueEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(ValueEntry."User ID"));

        ValueEntry."Cost Amount (Actual)" := ItemJnlLine.Amount;
        ValueEntry."Cost Posted to G/L" := ItemJnlLine.Amount;

        ValueEntry.Insert(true);
    end;

    local procedure InsertGLItemLedgerRelation(PostedNivelationLine: Record "NPR RS Posted Nivelation Lines"; ValueEntry: Record "Value Entry")
    var
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlPostLine.GetGLReg(GLRegister);
        GLItemLedgerRelation.Init();
        GLItemLedgerRelation."Value Entry No." := ValueEntry."Entry No.";
        GLItemLedgerRelation."G/L Register No." := GLRegister."No.";

        GLEntry.SetLoadFields("Entry No.", "G/L Account No.", "Document No.");
        GLEntry.SetRange("G/L Account No.", GetInventoryAccountFromInvPostingSetup(PostedNivelationLine));
        GLEntry.SetRange("Document No.", ValueEntry."Document No.");
        GLEntry.SetRange(Amount, ValueEntry."Cost Amount (Actual)");
        if not GLEntry.FindFirst() then
            exit;
        GLItemLedgerRelation."G/L Entry No." := GLEntry."Entry No.";
        GLItemLedgerRelation.Insert(true);
    end;
    #endregion

    #region Helper procedures

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

    local procedure GetInventoryAccountFromInvPostingSetup(PostedNivelationLines: Record "NPR RS Posted Nivelation Lines"): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code';
    begin
        Item.Get(PostedNivelationLines."Item No.");
        if not InventoryPostingSetup.Get(PostedNivelationLines."Location Code", Item."Inventory Posting Group") then
            Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), PostedNivelationLines."Location Code");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';

#endif
}