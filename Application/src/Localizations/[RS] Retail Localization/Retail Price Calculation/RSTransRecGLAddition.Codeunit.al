codeunit 6151307 "NPR RS Trans. Rec. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd;
    
#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Transfer Recieve Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnRunOnAfterInsertTransRcptLines', '', false, false)]
    local procedure AddTransferGLEntries(TransRcptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header")
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not CheckRetailLocation(TransRcptHeader) then
            exit;

        FillRetailTransferLines(TransferHeader);

        if not TempTransferLine.FindSet() then
            exit;

        FilterPriceListLines(TransRcptHeader);

        CreateAdditionalGLEntries(GenJnlPostLine, TransRcptHeader, RSGLEntryType::Margin);
        CreateAdditionalGLEntries(GenJnlPostLine, TransRcptHeader, RSGLEntryType::VAT);

        repeat
            CreateAdditionalGLEntries(GenJnlPostLine, TransRcptHeader, RSGLEntryType::MarginNoVAT);
        until TempTransferLine.Next() = 0;
    end;
    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; TransRcptHeader: Record "Transfer Receipt Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT)
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
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(TransRcptHeader, RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
        if RSGLEntryType = RSGLEntryType::Margin then
            GenJournalLine.Validate("Debit Amount", CalculateRSAmount(TransRcptHeader, RSGLEntryType))
        else
            GenJournalLine.Validate("Credit Amount", CalculateRSAmount(TransRcptHeader, RSGLEntryType));

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
        GenJnlPostLine.InitVAT(GenJnlLine, GLEntry, VATPostingSetup);
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
    local procedure GetRSAccountNoFromSetup(TransRcptHeader: Record "Transfer Receipt Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Code[20]
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
                    InventoryPostingSetup.SetRange("Location Code", TransRcptHeader."Transfer-to Code");
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

    local procedure CalculateRSAmount(TransRcptHeader: Record "Transfer Receipt Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT): Decimal
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                exit(CalculateRSGLVATAmount());
            RSGLEntryType::Margin:
                exit(CalculateRSGLMarginAmount(TransRcptHeader));
            RSGLEntryType::MarginNoVAT:
                exit(CalculateRSGLMarginNoVATAmount(TransRcptHeader));
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    var
        CalcVat: Decimal;
    begin
        repeat
            PriceListLine.SetRange("Asset No.", TempTransferLine."Item No.");
            if PriceListLine.FindFirst() then
                CalcVat += (PriceListLine."Unit Price" * TempTransferLine.Quantity) * CalculateVATBreakDown();
        until TempTransferLine.Next() = 0;
        exit(CalcVat);
    end;

    local procedure CalculateRSGLMarginAmount(TransRcptHeader: Record "Transfer Receipt Header"): Decimal
    var
        CalcMarg: Decimal;
    begin
        repeat
            PriceListLine.SetRange("Asset No.", TempTransferLine."Item No.");
            if PriceListLine.FindFirst() then
                CalcMarg += (PriceListLine."Unit Price" * TempTransferLine.Quantity) - GetValueEntryCostAmount(TransRcptHeader);
        until TempTransferLine.Next() = 0;
        exit(CalcMarg);
    end;

    local procedure CalculateRSGLMarginNoVATAmount(TransRcptHeader: Record "Transfer Receipt Header"): Decimal
    var
        CalcMargNoVAT: Decimal;
        TotalPriceCalc: Decimal;
    begin
        PriceListLine.SetRange("Asset No.", TempTransferLine."Item No.");
        if not PriceListLine.FindFirst() then
            exit;
        TotalPriceCalc := PriceListLine."Unit Price" * TempTransferLine.Quantity;
        CalcMargNoVAT := TotalPriceCalc - GetValueEntryCostAmount(TransRcptHeader) - (TotalPriceCalc * CalculateVATBreakDown());
        exit(CalcMargNoVAT);
    end;

    local procedure GetValueEntryCostAmount(TransRcptHeader: Record "Transfer Receipt Header"): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
        ValueEntry.SetLoadFields("Item No.", "Order No.", "Order Line No.", "Location Code", "Cost Amount (Actual)");
        ValueEntry.SetRange("Order No.", TransRcptHeader."Transfer Order No.");
        ValueEntry.SetRange("Location Code", TransRcptHeader."Transfer-to Code");
        ValueEntry.SetRange("Item No.", TempTransferLine."Item No.");
        ValueEntry.SetRange("Order Line No.", TempTransferLine."Line No.");
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(Abs(ValueEntry."Cost Amount (Actual)"));
    end;

    local procedure CalculateVATBreakDown(): Decimal
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        if not Item.Get(TempTransferLine."Item No.") then
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

    local procedure CheckRetailLocation(TransRcptHeader: Record "Transfer Receipt Header"): Boolean
    var
        Location: Record Location;
        LocationCheck: Boolean;
    begin
        LocationCheck := false;
        if Location.Get(TransRcptHeader."Transfer-from Code") then
            if not Location."NPR Retail Location" then
                LocationCheck := true;
        if Location.Get(TransRcptHeader."Transfer-to Code") then
            if Location."NPR Retail Location" then
                LocationCheck := true;
        exit(LocationCheck);
    end;

    local procedure FillRetailTransferLines(TransferHeader: Record "Transfer Header")
    var
        Location: Record Location;
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if not TransferLine.FindSet() then
            exit;
        repeat
            if Location.Get(TransferHeader."Transfer-to Code") then
                if Location."NPR Retail Location" then begin
                    TempTransferLine.Init();
                    TempTransferLine.Copy(TransferLine);
                    TempTransferLine.Insert();
                end;
        until TransferLine.Next() = 0;
    end;

    local procedure FilterPriceListLines(TransRcptHeader: Record "Transfer Receipt Header")
    begin
        PriceListLine.SetCurrentKey(Status, "Price Type", "Amount Type", "Currency Code", "Unit of Measure Code", "Source Type", "Source No.", "Asset Type", "Asset No.", "Variant Code", "Starting Date", "Ending Date", "Minimum Quantity");
        PriceListLine.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "Asset No.", "Unit Price");
        PriceListLine.SetRange("Price Type", "Price Type"::Sale);
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, TransRcptHeader."Posting Date"));
        PriceListLine.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, TransRcptHeader."Posting Date"));
    end;
    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListLine: Record "Price List Line";
        TempTransferLine: Record "Transfer Line" temporary;
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
        StartingDateFilter: Label '<=%1', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Locked = true;
#endif
}