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
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not CheckRetailLocation(TransferReceiptHeader) then
            exit;

        FillTempTransferLines(TransferHeader);

        if not TempTransferLine.FindSet() then
            exit;

        PostAdditionalRetailEntries(TransferReceiptHeader);
    end;

    local procedure PostAdditionalRetailEntries(TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        RSGLEntryType: Option VAT,Margin,MarginNoVAT,WarehouseAdjustment;
    begin
        FilterPriceListHeader(TransferReceiptHeader, TransferReceiptHeader."Transfer-to Code");
        repeat
            FindPriceListLine(TransferReceiptHeader."Transfer-to Code");

            CalculateStandardValueEntryCostAmount(TransferReceiptHeader);

            CreateAdditionalGLEntries(TransferReceiptHeader, RSGLEntryType::Margin);
            CreateAdditionalGLEntries(TransferReceiptHeader, RSGLEntryType::VAT);
            CreateAdditionalGLEntries(TransferReceiptHeader, RSGLEntryType::MarginNoVAT);

            InsertRetailValueEntry(TransferReceiptHeader);
        until TempTransferLine.Next() = 0;
    end;

    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(TransferReceiptHeader: Record "Transfer Receipt Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,WarehouseAdjustment)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGeneralJournalLine(GenJournalLine, TransferReceiptHeader, RSGLEntryType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
        if RSGLEntryType = RSGLEntryType::Margin then
            GenJournalLine.Validate("Debit Amount", CalculateRSAmount(RSGLEntryType))
        else
            GenJournalLine.Validate("Credit Amount", CalculateRSAmount(RSGLEntryType));

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

    local procedure InitGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,WarehouseAdjustment)
    var
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
        GenJnlLineWhouseAdjLbl: Label 'G/L Calculation Warehouse Adj.';
    begin
        GenJournalLine.Init();
        GenJournalLine."Document No." := TransferReceiptHeader."No.";
        GenJournalLine."Posting Date" := Today();
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSGLEntryType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSGLEntryType::WarehouseAdjustment:
                GenJournalLine.Description := GenJnlLineWhouseAdjLbl;
        end;
        GenJournalLine."VAT Reporting Date" := Today();
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

    local procedure InsertRetailValueEntry(TransferReceiptHeader: Record "Transfer Receipt Header")
    var
        NewValueEntry: Record "Value Entry";
    begin
        PostRetailValueEntry(TransferReceiptHeader, NewValueEntry)
    end;

    local procedure PostRetailValueEntry(TransferReceiptHeader: Record "Transfer Receipt Header"; var NewValueEntry: Record "Value Entry")
    var
        BaseRetailValueEntry: Record "Value Entry";
        CalculationValueEntryDescLbl: Label 'Calculation';
        RSGLEntryType: Option VAT,Margin,MarginNoVAT;
    begin
        BaseRetailValueEntry.SetRange("Order No.", TransferReceiptHeader."Transfer Order No.");
        BaseRetailValueEntry.SetRange("Location Code", TransferReceiptHeader."Transfer-to Code");
        BaseRetailValueEntry.SetRange("Item No.", TempTransferLine."Item No.");
        BaseRetailValueEntry.SetRange("Order Line No.", TempTransferLine."Line No.");
        if not BaseRetailValueEntry.FindFirst() then
            exit;
        NewValueEntry.Init();
        NewValueEntry.Copy(BaseRetailValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
        ResetValueEntryAmounts(NewValueEntry);
        if Abs(ValueEntryStd."Cost Amount (Actual)") = Abs((PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)")) then
            exit;
        if ValueEntryStd."Cost Amount (Actual)" > 0 then
            NewValueEntry."Cost Amount (Actual)" := (PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)")
        else
            NewValueEntry."Cost Amount (Actual)" := Abs((PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)"));
        NewValueEntry."Cost Posted to G/L" := NewValueEntry."Cost Amount (Actual)";
        NewValueEntry."Cost per Unit" := BaseRetailValueEntry."Cost per Unit";
        NewValueEntry.Description := CalculationValueEntryDescLbl;
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
    local procedure GetRSAccountNoFromSetup(RSGLEntryType: Option VAT,Margin,MarginNoVAT,WarehouseAdjustment): Code[20]
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
                exit(GetInventoryAccountFromInvPostingSetup(TempTransferLine."Transfer-to Code"));
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSGLEntryType::WarehouseAdjustment:
                exit(GetInventoryAccountFromInvPostingSetup(TempTransferLine."Transfer-to Code"));
        end;
    end;

    local procedure CalculateRSAmount(RSGLEntryType: Option VAT,Margin,MarginNoVAT,WarehouseAdjustment): Decimal
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                exit(CalculateRSGLVATAmount());
            RSGLEntryType::Margin:
                exit(CalculateRSGLMarginAmount());
            RSGLEntryType::MarginNoVAT:
                exit(CalculateRSGLMarginNoVATAmount());
            RSGLEntryType::WarehouseAdjustment:
                exit(CalculateWHouseAdjustmentAmount());
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempTransferLine.Quantity) * CalculateVATBreakDown());
    end;

    local procedure CalculateRSGLMarginAmount(): Decimal
    var
        MarginAmount: Decimal;
    begin
        MarginAmount := (PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)");
        if MarginAmount = 0 then
            exit((PriceListLine."Unit Price" * TempTransferLine.Quantity))
        else
            exit((PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)"))
    end;

    local procedure CalculateRSGLMarginNoVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempTransferLine.Quantity) - Abs(ValueEntryStd."Cost Amount (Actual)") - ((PriceListLine."Unit Price" * TempTransferLine.Quantity) * CalculateVATBreakDown()));
    end;

    local procedure CalculateWHouseAdjustmentAmount(): Decimal
    begin
        exit(Abs(NewWarehouseValueEntry."Cost Amount (Actual)"));
    end;

    local procedure CalculateStandardValueEntryCostAmount(TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        ValueEntryStd.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
        ValueEntryStd.SetLoadFields("Item No.", "Order No.", "Order Line No.", "Location Code", "Document No.", "Cost Amount (Actual)");
        ValueEntryStd.SetRange("Order No.", TransferReceiptHeader."Transfer Order No.");
        ValueEntryStd.SetRange("Location Code", TransferReceiptHeader."Transfer-to Code");
        ValueEntryStd.SetRange("Item No.", TempTransferLine."Item No.");
        ValueEntryStd.SetRange("Order Line No.", TempTransferLine."Line No.");
        ValueEntryStd.CalcSums("Cost Amount (Actual)");
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

    local procedure CheckRetailLocation(TransferReceiptHeader: Record "Transfer Receipt Header"): Boolean
    var
        Location: Record Location;
        Location2: Record Location;
    begin
        Location.Get(TransferReceiptHeader."Transfer-from Code");
        Location2.Get(TransferReceiptHeader."Transfer-to Code");

        exit((not Location."NPR Retail Location") and (Location2."NPR Retail Location"))
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
        PriceListHeader.SetLoadFields("Price Type", Status, "Starting Date", "Ending Date", "NPR Location Code", "Assign-to No.");
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
        PriceListLine.SetLoadFields("Price List Code", "Asset No.", "Unit Price", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", TempTransferLine."Item No.");
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, TempTransferLine."Item No.", PriceListHeader.Code, LocationCode);
    end;

    local procedure GetInventoryAccountFromInvPostingSetup(LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        Item.Get(TempTransferLine."Item No.");
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
        ValueEntry."Cost per Unit" := 0;
        ValueEntry."Valued Quantity" := 0;
        ValueEntry."Invoiced Quantity" := 0;
        ValueEntry."Item Ledger Entry Quantity" := 0;
    end;
    #endregion

    var
        AddCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        TempTransferLine: Record "Transfer Line" temporary;
        NewWarehouseValueEntry: Record "Value Entry";
        ValueEntryStd: Record "Value Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}