codeunit 6151308 "NPR RS Trans. Sh. GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                tabledata "Value Entry" = rimd,
                tabledata "Item Ledger Entry" = rimd,
                tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)

    #region Eventsubscribers - RS Transfer Shipment Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeCopyTransLines', '', false, false)]
    local procedure OnBeforeCopyTransLines(TransferHeader: Record "Transfer Header")
    begin
        PostRetailCalculationEntries(TransferHeader);
    end;

    #endregion

    #region Transfer Shipment Calculation Posting

    internal procedure PostRetailCalculationEntries(TransferHeader: Record "Transfer Header")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DocumentNo: Code[20];
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if (not RSRLocalizationMgt.IsRetailLocation(TransferHeader."Transfer-from Code")) or RSRLocalizationMgt.IsRetailLocation(TransferHeader."Transfer-to Code") then
            exit;

        TempTransferLine.Reset();
        TempTransferLine.DeleteAll();
        FillRetailTransferLines(TransferHeader);

        if TempTransferLine.IsEmpty() then
            exit;

        FilterPriceListHeader(TransferHeader, TransferHeader."Transfer-from Code");

        TempTransferLine.FindSet();
        repeat
            FindPriceListLine(TransferHeader."Transfer-from Code");
            PostTransitValueEntry(TransferHeader, DocumentNo);
        until TempTransferLine.Next() = 0;

        SourceCodeSetup.Get();
        RSRLocalizationMgt.AddGLEntriesToGLRegister(DocumentNo, SourceCodeSetup.Transfer);
    end;

    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; StdTransitValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        InitGenJournalLine(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);
        GLSetup.Get();
        AddCurrencyCode := GLSetup."Additional Reporting Currency";
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        CalculateRSGLEntryAmounts(GenJournalLine, CalculationValueEntry, StdTransitValueEntry, RSRetailCalculationType);

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

        ValidateNegativeDebitCredit(GenJournalLine, RSRetailCalculationType);

        PostGLAcc(GenJournalLine, GLEntry);
    end;

    local procedure ValidateNegativeDebitCredit(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        if RSRetailCalculationType in [RSRetailCalculationType::"Transit Adjustment"] then begin
            GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
            GenJournalLine."Debit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Credit Amount" := 0;
        end;
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

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineTransitLbl: Label 'G/L Calculation Transit Adj.';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo('', '');
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."Document No." := CalculationValueEntry."Document No.";
        GenJournalLine."External Document No." := CalculationValueEntry."External Document No.";
        GenJournalLine."Posting Date" := CalculationValueEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSRetailCalculationType::"Transit Adjustment":
                GenJournalLine.Description := GenJnlLineTransitLbl;
        end;
        GenJournalLine."VAT Reporting Date" := CalculationValueEntry."VAT Reporting Date";
        GenJournalLine."Document Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Due Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Source Code" := CalculationValueEntry."Source Code";
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(RSRetailCalculationType);
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

    #region Additional Value Entry Posting

    local procedure PostTransitValueEntry(TransferHeader: Record "Transfer Header"; var DocumentNo: Code[20])
    var
        TransferFromItemLedgerEntry: Record "Item Ledger Entry";
        TempTransferFromILEAppliedItemLedgerEntries: Record "Item Ledger Entry" temporary;
        TransitLocationItemLedgerEntries: Record "Item Ledger Entry";
        ShowAppliedEntries: Codeunit "Show Applied Entries";
        TransitCostPerUnit: Decimal;
        AppliedEntryCostPerUnit: Decimal;
    begin
        TransferFromItemLedgerEntry.SetRange("Document Type", TransferFromItemLedgerEntry."Document Type"::"Transfer Shipment");
        TransferFromItemLedgerEntry.SetRange("Document No.", GetCurrentTransferShipmentNo());
        TransferFromItemLedgerEntry.SetRange("Location Code", TransferHeader."Transfer-from Code");
        TransferFromItemLedgerEntry.SetRange("Item No.", TempTransferLine."Item No.");
        if TransferFromItemLedgerEntry.IsEmpty() then
            exit;

        TransitLocationItemLedgerEntries.SetLoadFields("Entry No.", "Invoiced Quantity", "Document No.", Quantity);
        TransitLocationItemLedgerEntries.SetRange("Document Type", TransitLocationItemLedgerEntries."Document Type"::"Transfer Shipment");
        TransitLocationItemLedgerEntries.SetRange("Document No.", GetCurrentTransferShipmentNo());
        TransitLocationItemLedgerEntries.SetRange("Location Code", TransferHeader."In-Transit Code");
        TransitLocationItemLedgerEntries.SetRange("Item No.", TempTransferLine."Item No.");
        if TransitLocationItemLedgerEntries.IsEmpty() then
            exit;

        TransferFromItemLedgerEntry.FindSet();
        repeat
            ShowAppliedEntries.FindAppliedEntries(TransferFromItemLedgerEntry, TempTransferFromILEAppliedItemLedgerEntries);
        until TransferFromItemLedgerEntry.Next() = 0;

        if TempTransferFromILEAppliedItemLedgerEntries.IsEmpty() then
            exit;

        TempTransferFromILEAppliedItemLedgerEntries.FindSet();
        TransitLocationItemLedgerEntries.FindSet();
        repeat
            Clear(AppliedEntryCostPerUnit);
            Clear(TransitCostPerUnit);
            CalculateTransferFromAppliedItemLedgerEntriesCostPerUnit(AppliedEntryCostPerUnit, TempTransferFromILEAppliedItemLedgerEntries);
            CalculateTransitLocationItemLedgerEntryCostPerUnit(TransitCostPerUnit, TransitLocationItemLedgerEntries);
            if AppliedEntryCostPerUnit <> TransitCostPerUnit then
                InsertCorrectionalValueEntryForTransitLocation(TransitLocationItemLedgerEntries, AppliedEntryCostPerUnit, TransitCostPerUnit);
        until (TransitLocationItemLedgerEntries.Next() = 0) and (TempTransferFromILEAppliedItemLedgerEntries.Next() = 0);

        DocumentNo := TempTransferFromILEAppliedItemLedgerEntries."Document No.";
    end;

    local procedure InsertCorrectionalValueEntryForTransitLocation(TransitLocationItemLedgerEntries: Record "Item Ledger Entry"; AppliedEntryCostPerUnit: Decimal; TransitCostPerUnit: Decimal)
    var
        CorrectionValueEntry: Record "Value Entry";
        StdTransitValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        CalculationValueEntryDescLbl: Label 'Calculation';
    begin
        StdTransitValueEntry.SetCurrentKey("Item Ledger Entry No.");
        StdTransitValueEntry.SetRange("Item Ledger Entry No.", TransitLocationItemLedgerEntries."Entry No.");
        if not StdTransitValueEntry.FindFirst() then
            exit;

        CorrectionValueEntry.Init();
        CorrectionValueEntry.Copy(StdTransitValueEntry);
        CorrectionValueEntry."Entry No." := CorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(CorrectionValueEntry);

        CorrectionValueEntry.Description := CalculationValueEntryDescLbl;
        CorrectionValueEntry."Cost per Unit" := -(TransitCostPerUnit - AppliedEntryCostPerUnit);
        CorrectionValueEntry."Cost Amount (Actual)" := CorrectionValueEntry."Cost per Unit" * TransitLocationItemLedgerEntries."Invoiced Quantity";
        CorrectionValueEntry."Cost Posted to G/L" := CorrectionValueEntry."Cost Amount (Actual)";

        if CorrectionValueEntry."Cost Amount (Actual)" = 0 then
            exit;

        CorrectionValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(CorrectionValueEntry);

        CreateAdditionalGLEntries(CorrectionValueEntry, StdTransitValueEntry, RSRetailCalculationType::Margin);
        CreateAdditionalGLEntries(CorrectionValueEntry, StdTransitValueEntry, RSRetailCalculationType::VAT);
        CreateAdditionalGLEntries(CorrectionValueEntry, StdTransitValueEntry, RSRetailCalculationType::"Transit Adjustment");

        RSRLocalizationMgt.InsertGLItemLedgerRelations(CorrectionValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::Margin));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(CorrectionValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::VAT));
        RSRLocalizationMgt.InsertGLItemLedgerRelations(CorrectionValueEntry, GetRSAccountNoFromSetup(RSRetailCalculationType::"Transit Adjustment"));
    end;

    local procedure CalculateTransferFromAppliedItemLedgerEntriesCostPerUnit(var CostPerUnit: Decimal; TempTransferFromILEAppliedItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        ValueEntry: Record "Value Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        ValueEntry.SetLoadFields("Cost per Unit", "Invoiced Quantity");
        ValueEntry.SetRange("Item Ledger Entry No.", TempTransferFromILEAppliedItemLedgerEntry."Entry No.");
        if ValueEntry.IsEmpty() then
            exit;
        ValueEntry.FindSet();
        repeat
            if (RSRetValueEntryMapp.Get(ValueEntry."Entry No.")) then begin
                if (RSRetValueEntryMapp."Standard Correction") or (RSRetValueEntryMapp."COGS Correction") then begin
                    CostPerUnit += ValueEntry."Cost per Unit";
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, Abs(ValueEntry."Invoiced Quantity"));
                end;
            end
            else
                CostPerUnit += ValueEntry."Cost per Unit";
        until ValueEntry.Next() = 0;
    end;

    local procedure CalculateTransitLocationItemLedgerEntryCostPerUnit(var CostPerUnit: Decimal; TransitLocationItemLedgerEntry: Record "Item Ledger Entry")
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", TransitLocationItemLedgerEntry."Entry No.");
        ValueEntry.CalcSums("Cost per Unit");
        CostPerUnit := ValueEntry."Cost per Unit";
    end;

    #endregion

    #region Retail Price Calculation
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
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSRetailCalculationType::"Transit Adjustment":
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempTransferLine."Item No.", TempTransferLine."In-Transit Code"));
        end;
    end;

    local procedure CalculateRSGLEntryAmounts(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; StdTransitValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Credit Amount", -CalculateRSGLVATAmount(StdTransitValueEntry));
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", CalculateRSGLMarginAmount(StdTransitValueEntry, CalculationValueEntry));
            RSRetailCalculationType::"Transit Adjustment":
                GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Cost Amount (Actual)"));
        end;
    end;

    local procedure CalculateRSGLMarginAmount(StdTransitValueEntry: Record "Value Entry"; CalculationValueEntry: Record "Value Entry"): Decimal
    begin
        exit(-(Abs(CalculationValueEntry."Cost Amount (Actual)") - Abs(CalculateRSGLVATAmount(StdTransitValueEntry))))
    end;

    local procedure CalculateRSGLVATAmount(StdTransitValueEntry: Record "Value Entry"): Decimal
    begin
        exit((PriceListLine."Unit Price" * StdTransitValueEntry."Invoiced Quantity") * CalculateVATBreakDown());
    end;

    local procedure CalculateVATBreakDown(): Decimal
    begin
        exit(RSRLocalizationMgt.CalculateVATBreakDown(PriceListLine."VAT Bus. Posting Gr. (Price)", PriceListLine."VAT Prod. Posting Group"));
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

    local procedure FillRetailTransferLines(TransferHeader: Record "Transfer Header")
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.IsEmpty() then
            exit;
        TransferLine.FindSet();
        repeat
            TempTransferLine.Init();
            TempTransferLine.Copy(TransferLine);
            TempTransferLine.Insert();
        until TransferLine.Next() = 0;
    end;

    local procedure FilterPriceListHeader(TransferHeader: Record "Transfer Header"; LocationCode: Code[20])
    var
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        PriceListNotFoundErr: Label 'Price for the Location %1 has not been found.', Comment = '%1 - Location Code';
    begin
        PriceListHeader.SetLoadFields(Code);
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

    local procedure GetCurrentTransferShipmentNo(): Code[20]
    var
        InventorySetup: Record "Inventory Setup";
#if (BC20 or BC21 or BC22 or BC23)
        NoSeriesLine: Record "No. Series Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
#else
        NoSeriesBatch: Codeunit "No. Series - Batch";
#endif
    begin
        InventorySetup.Get();
        InventorySetup.TestField("Posted Transfer Shpt. Nos.");
#if (BC20 or BC21 or BC22 or BC23)
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, InventorySetup."Posted Transfer Shpt. Nos.", Today());
        NoSeriesLine.FindFirst();
        exit(NoSeriesLine."Last No. Used");
#else
        exit(NoSeriesBatch.GetLastNoUsed(InventorySetup."Posted Transfer Shpt. Nos."));
#endif
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