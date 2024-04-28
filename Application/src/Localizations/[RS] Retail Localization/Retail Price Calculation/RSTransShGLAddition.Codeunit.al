codeunit 6151308 "NPR RS Trans. Sh. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                tabledata "Value Entry" = rimd,
                tabledata "Item Ledger Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Transfer Shipment Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeCopyTransLines', '', false, false)]
    local procedure AddTransferGLEntries(TransferHeader: Record "Transfer Header")
    var
        NewRetailValueEntry: Record "Value Entry";
        TempTransitValueEntry: Record "Value Entry" temporary;
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        RSGLEntryType: Option VAT,Margin,MarginNoVAT,TransitAdjustment;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if not CheckRetailLocation(TransferHeader) then
            exit;

        FillRetailTransferLines(TransferHeader);

        if not TempTransferLine.FindSet() then
            exit;

        FilterPriceListHeader(TransferHeader, TransferHeader."Transfer-from Code");

        repeat
            FindPriceListLine(TransferHeader."Transfer-from Code");

            InsertRetailValueEntry(NewRetailValueEntry, TransferHeader);

            if NewRetailValueEntry."Entry No." <> 0 then begin
                CreateAdditionalGLEntries(TransferHeader, NewRetailValueEntry, RSGLEntryType::VAT);
                CreateAdditionalGLEntries(TransferHeader, NewRetailValueEntry, RSGLEntryType::MarginNoVAT);

                InsertGLItemLedgerRelation(NewRetailValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::VAT));
                InsertGLItemLedgerRelation(NewRetailValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::MarginNoVAT));
            end;

            PostTransitValueEntry(TempTransitValueEntry, TransferHeader);
            if TempTransitValueEntry.FindSet() then
                repeat
                    InsertTempToValueEntry(NewRetailValueEntry, TempTransitValueEntry);
                    CreateAdditionalGLEntries(TransferHeader, NewRetailValueEntry, RSGLEntryType::TransitAdjustment);
                    InsertGLItemLedgerRelation(NewRetailValueEntry, GetInventoryAccountFromInvPostingSetup(NewRetailValueEntry."Location Code"));
                until TempTransitValueEntry.Next() = 0;
        until TempTransferLine.Next() = 0;
    end;
    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(TransferHeader: Record "Transfer Header"; CalculationValueEntry: Record "Value Entry"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,TransitAdjustment)
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        GenJournalLine.Init();
        InitGeneralJournalLine(GenJournalLine, TransferHeader, RSGLEntryType);
        GenJnlPostLine.GetGLReg(GLRegister);
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo(GLRegister."Journal Templ. Name", GLRegister."Journal Batch Name");
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSGLEntryType);
        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        CalculateRSGLEntryAmounts(GenJournalLine, CalculationValueEntry, RSGLEntryType);

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

    local procedure InitGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; TransferHeader: Record "Transfer Header"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,TransitAdjustment)
    var
        ValueEntry: Record "Value Entry";
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineTransitLbl: Label 'G/L Calculation Transit Adj.';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        ValueEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
        ValueEntry.SetLoadFields("Document No.");
        ValueEntry.SetRange("Order No.", TransferHeader."No.");
        ValueEntry.SetRange("Location Code", TransferHeader."Transfer-from Code");
        ValueEntry.SetRange("Item No.", TempTransferLine."Item No.");
        ValueEntry.SetRange("Order Line No.", TempTransferLine."Line No.");
        ValueEntry.FindFirst();
        GenJournalLine.Init();
        GenJournalLine."Document No." := ValueEntry."Document No.";
        GenJournalLine."Posting Date" := Today();
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSGLEntryType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSGLEntryType::TransitAdjustment:
                GenJournalLine.Description := GenJnlLineTransitLbl;
        end;
        GenJournalLine."VAT Reporting Date" := Today();
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

    local procedure PostJob(GenJnlLine: Record "Gen. Journal Line"; GLEntry: Record "G/L Entry")
    var
        JobPostLine: Codeunit "Job Post-Line";
    begin
        if not JobLine then
            exit;
        JobLine := false;
        JobPostLine.PostGenJnlLine(GenJnlLine, GLEntry);
    end;

    #endregion

    #region Additional Item Ledger and Value Entry Posting
    local procedure InsertRetailValueEntry(var NewValueEntry: Record "Value Entry"; TransferHeader: Record "Transfer Header")
    var
        StdValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
    begin
        StdValueEntry.SetCurrentKey("Order Type", "Order No.", "Order Line No.");
        StdValueEntry.SetRange("Order No.", TransferHeader."No.");
        StdValueEntry.SetRange("Location Code", TransferHeader."Transfer-from Code");
        StdValueEntry.SetRange("Item No.", TempTransferLine."Item No.");
        StdValueEntry.SetRange("Order Line No.", TempTransferLine."Line No.");
        if not StdValueEntry.FindFirst() then
            exit;

        if PriceListLine."Unit Price" = StdValueEntry."Cost per Unit" then
            exit;

        NewValueEntry.Init();
        NewValueEntry.Copy(StdValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;

        ResetValueEntryAmounts(NewValueEntry);

        NewValueEntry.Description := CalculationValueEntryDescLbl;
        NewValueEntry."Cost per Unit" := PriceListLine."Unit Price" - StdValueEntry."Cost per Unit";
        NewValueEntry."Cost Amount (Actual)" := NewValueEntry."Cost per Unit" * StdValueEntry."Invoiced Quantity";
        NewValueEntry."Cost Posted to G/L" := NewValueEntry."Cost Amount (Actual)";
        NewValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(NewValueEntry);
    end;

    local procedure PostTransitValueEntry(var TempTransitValueEntry: Record "Value Entry" temporary; TransferHeader: Record "Transfer Header"): Boolean
    var
        StdItemLedgEntry: Record "Item Ledger Entry";
        StdTransitValueEntry: Record "Value Entry";
        NewTransitValueEntry: Record "Value Entry";
    begin
        if TransferHeader."In-Transit Code" = '' then
            exit;

        StdItemLedgEntry.SetRange("Document Type", StdItemLedgEntry."Document Type"::"Transfer Shipment");
        StdItemLedgEntry.SetRange("Order No.", TransferHeader."No.");
        StdItemLedgEntry.SetRange("Location Code", TransferHeader."In-Transit Code");
        StdItemLedgEntry.SetRange("Item No.", TempTransferLine."Item No.");
        if not StdItemLedgEntry.FindSet() then
            exit;

        repeat
            StdTransitValueEntry.SetRange("Item Ledger Entry No.", StdItemLedgEntry."Entry No.");
            if StdTransitValueEntry.FindSet() then
                InsertTransitValueEntry(NewTransitValueEntry, TempTransitValueEntry, StdTransitValueEntry);
        until StdItemLedgEntry.Next() = 0;
    end;

    local procedure InsertTransitValueEntry(var NewTransitValueEntry: Record "Value Entry"; var TempTransitValueEntry: Record "Value Entry" temporary; StdTransitValueEntry: Record "Value Entry")
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        SumOfCostPerUnit: Decimal;
        SumOfInvQty: Integer;
    begin
        repeat
            SumOfCostPerUnit += StdTransitValueEntry."Cost per Unit";
            SumOfInvQty += StdTransitValueEntry."Invoiced Quantity";
        until StdTransitValueEntry.Next() = 0;

        if PriceListLine."Unit Price" = SumOfCostPerUnit then
            exit;

        NewTransitValueEntry.Init();
        NewTransitValueEntry.Copy(StdTransitValueEntry);
        NewTransitValueEntry."Entry No." := NewTransitValueEntry.GetLastEntryNo() + 1;

        ResetValueEntryAmounts(NewTransitValueEntry);

        NewTransitValueEntry."Cost per Unit" := Abs(PriceListLine."Unit Price" - SumOfCostPerUnit);

        if (StdTransitValueEntry."Cost Amount (Actual)" > 0) then
            NewTransitValueEntry."Cost Amount (Actual)" := -(NewTransitValueEntry."Cost per Unit" * SumOfInvQty)
        else
            NewTransitValueEntry."Cost Amount (Actual)" := Abs(NewTransitValueEntry."Cost per Unit" * SumOfInvQty);

        if NewTransitValueEntry."Cost Amount (Actual)" = 0 then
            exit;

        NewTransitValueEntry."Cost Posted to G/L" := NewTransitValueEntry."Cost Amount (Actual)";
        NewTransitValueEntry."Cost per Unit" := PriceListLine."Unit Price" - SumOfCostPerUnit;
        NewTransitValueEntry.Description := CalculationValueEntryDescLbl;
        NewTransitValueEntry.Insert();

        TempTransitValueEntry.Init();
        TempTransitValueEntry.Copy(NewTransitValueEntry);
        TempTransitValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(NewTransitValueEntry);
    end;

    local procedure InsertTempToValueEntry(NewValueEntry: Record "Value Entry"; TempValueEntry: Record "Value Entry" temporary)
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(TempValueEntry);
        NewValueEntry.Insert();
    end;

    local procedure InsertGLItemLedgerRelation(ValueEntry: Record "Value Entry"; GLAccountNo: Code[20])
    var
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
    begin
        GenJnlPostLine.GetGLReg(GLRegister);
        GLEntry.SetLoadFields("Entry No.");
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Document No.", ValueEntry."Document No.");
        if not GLEntry.FindSet() then
            exit;
        repeat
            if not GLItemLedgerRelation.Get(GLEntry."Entry No.", ValueEntry."Entry No.") then begin
                GLItemLedgerRelation.Init();
                GLItemLedgerRelation."Value Entry No." := ValueEntry."Entry No.";
                GLItemLedgerRelation."G/L Register No." := GLRegister."No.";

                GLItemLedgerRelation."G/L Entry No." := GLEntry."Entry No.";
                GLItemLedgerRelation.Insert(true);
            end;
        until GLEntry.Next() = 0;
    end;

    #endregion

    #region Retail Price Calculation
    local procedure GetRSAccountNoFromSetup(RSGLEntryType: Option VAT,Margin,MarginNoVAT,TransitAdjustment): Code[20]
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
                exit(GetInventoryAccountFromInvPostingSetup(TempTransferLine."Transfer-from Code"));
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSGLEntryType::TransitAdjustment:
                exit(GetInventoryAccountFromInvPostingSetup(TempTransferLine."In-Transit Code"));
        end;
    end;

    local procedure CalculateRSGLEntryAmounts(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,TransitAdjustment)
    begin
        case RSGLEntryType of
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", CalculateRSGLVATAmount());
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Amount (Actual)");
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Amount (Actual)" - CalculateRSGLVATAmount());
            RSGLEntryType::TransitAdjustment:
                GenJournalLine.Validate("Credit Amount", Abs(CalculationValueEntry."Cost Amount (Actual)"));
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * TempTransferLine.Quantity) * CalculateVATBreakDown());
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

    local procedure CheckRetailLocation(TransferHeader: Record "Transfer Header"): Boolean
    var
        Location: Record Location;
        Location2: Record Location;
    begin
        Location.Get(TransferHeader."Transfer-from Code");
        Location2.Get(TransferHeader."Transfer-to Code");

        exit((Location."NPR Retail Location") and (not Location2."NPR Retail Location"))
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
            if Location.Get(TransferHeader."Transfer-from Code") then
                if Location."NPR Retail Location" then begin
                    TempTransferLine.Init();
                    TempTransferLine.Copy(TransferLine);
                    TempTransferLine.Insert();
                end;
        until TransferLine.Next() = 0;
    end;

    local procedure FilterPriceListHeader(TransferHeader: Record "Transfer Header"; LocationCode: Code[20])
    var
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceListNotFoundErr: Label 'Price for the Location %1 has not been found.', Comment = '%1 - Location Code';
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);

        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, TransferHeader."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, TransferHeader."Posting Date"));
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
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
        CalculationValueEntryDescLbl: Label 'Calculation';
#endif
}