codeunit 6151307 "NPR RS Trans. Rec. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                tabledata "Value Entry" = rimd,
                tabledata "Item Ledger Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Transfer Recieve Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnBeforeDeleteOneTransferHeader', '', false, false)]
    local procedure AddTransferGLEntries(TransferReceiptHeader: Record "Transfer Receipt Header"; TransferHeader: Record "Transfer Header")
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        FillTempTransferLines(TransferHeader);

        if TempTransferLine.IsEmpty() then
            exit;

        if (not IsRetailLocation(TransferReceiptHeader."Transfer-from Code")) and (IsRetailLocation(TransferReceiptHeader."Transfer-to Code")) then
            PostAdditionalRetailEntries(TransferReceiptHeader);
    end;

    local procedure PostAdditionalRetailEntries(TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        RetailValueEntry: Record "Value Entry";
        TempRetailValueEntry: Record "Value Entry" temporary;
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        FilterPriceListHeader(TransferReceiptHeader, TransferReceiptHeader."Transfer-to Code");

        TempTransferLine.FindSet();
        repeat
            TempRetailValueEntry.DeleteAll();
            FindPriceListLine(TransferReceiptHeader."Transfer-to Code");

            InsertRetailValueEntries(TempRetailValueEntry, TransferReceiptHeader);

            TempRetailValueEntry.Reset();
            if TempRetailValueEntry.FindSet() then
                repeat
                    InsertTempToValueEntry(RetailValueEntry, TempRetailValueEntry);
                    CreateAdditionalGLEntries(TransferReceiptHeader, RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                    CreateAdditionalGLEntries(TransferReceiptHeader, RetailValueEntry, RSRetailCalculationType::VAT);
                    CreateAdditionalGLEntries(TransferReceiptHeader, RetailValueEntry, RSRetailCalculationType::Margin);

                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::VAT));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::"Margin with VAT"));
                    RSRLocalizationMgt.InsertGLItemLedgerRelations(RetailValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::Margin));
                until TempRetailValueEntry.Next() = 0;
        until TempTransferLine.Next() = 0;
    end;

    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(TransferReceiptHeader: Record "Transfer Receipt Header"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGeneralJournalLine(GenJournalLine, TransferReceiptHeader, RSRetailCalculationType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSRetailCalculationType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        CalculateRSGLEntryAmounts(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);

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

    local procedure InitGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        GenJournalLine.Init();
        GenJournalLine."Document No." := TransferReceiptHeader."No.";
        GenJournalLine."Posting Date" := TransferReceiptHeader."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
        end;
        GenJournalLine."VAT Reporting Date" := TransferReceiptHeader."Posting Date";
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
        StdItemLedgerEntry.SetRange("Item No.", TempTransferLine."Item No.");
        StdItemLedgerEntry.SetRange("Order Line No.", TempTransferLine."Line No.");
        if not StdItemLedgerEntry.FindSet() then
            exit;

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
                GenJournalLine.Validate("Credit Amount", CalculateRSGLVATAmount());
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculationValueEntry."Cost Amount (Actual)", GenJournalLine) - CalculateRSGLVATAmount());
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempTransferLine.Quantity) * CalculateVATBreakDown());
    end;

    local procedure CalculateVATBreakDown(): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(TempTransferLine."Item No.") then
            exit;
        exit(RSRLocalizationMgt.CalculateVATBreakDown(PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group"));
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
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempTransferLine."Item No.", TempTransferLine."Transfer-to Code"));
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

    local procedure IsRetailLocation(LocationCode: Code[20]): Boolean
    var
        Location: Record Location;
    begin
        Location.Get(LocationCode);
        exit(Location."NPR Retail Location");
    end;

    local procedure FillTempTransferLines(TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if not TransferLine.FindSet() then
            exit;
        repeat
            TempTransferLine.Init();
            TempTransferLine.Copy(TransferLine);
            TempTransferLine.Insert();
        until TransferLine.Next() = 0;
    end;

    local procedure FilterPriceListHeader(TransferReceiptHeader: Record "Transfer Receipt Header"; LocationCode: Code[20])
    var
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceListNotFoundErr: Label 'Price for the Location %1 has not been found.', Comment = '%1 - Location Code';
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);

        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, TransferReceiptHeader."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, TransferReceiptHeader."Posting Date"));
        PriceListHeader.SetRange("NPR Location Code", LocationCode);
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, LocationCode);
    end;

    local procedure FindPriceListLine(LocationCode: Code[20])
    var
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
    begin
        PriceListLine.SetLoadFields("Unit Price", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", TempTransferLine."Item No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, TempTransferLine."Item No.", PriceListHeader.Code, LocationCode);
    end;

    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        TempTransferLine: Record "Transfer Line" temporary;
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