codeunit 6184772 "NPR RS Undo Trans. Ship. Add."
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                tabledata "Value Entry" = rimd,
                tabledata "Item Ledger Entry" = rimd,
                tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)

    #region Eventsubscribers - RS Undo Transfer Shipment Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Transfer Shipment", 'OnBeforeModifyTransShptLine', '', false, false)]
    local procedure OnBeforeModifyTransShptLine(TransferShipmentLine: Record "Transfer Shipment Line")
    begin
        if (not RSRLocalizationMgt.IsRetailLocation(TransferShipmentLine."Transfer-from Code")) or RSRLocalizationMgt.IsRetailLocation(TransferShipmentLine."Transfer-to Code") then
            exit;

        PostRetailCalculationEntries(TransferShipmentLine);
    end;
    #endregion Eventsubscribers - RS Undo Transfer Shipment Posting Behaviour

    #region RS Undo Shipment - Calculation Value Entries

    local procedure PostRetailCalculationEntries(TransferShipmentLine: Record "Transfer Shipment Line")
    begin
        InsertTransitLocationCorrectionalValueEntries(TransferShipmentLine);
        InsertRetailLocationCorrectionalValueEntries(TransferShipmentLine);

        RSRLocalizationMgt.ValidateGLEntriesBalanced(TransferShipmentLine."Document No.");
    end;

    local procedure InsertRetailLocationCorrectionalValueEntries(TransferShipmentLine: Record "Transfer Shipment Line")
    var
        TransferShipmentHeader: Record "Transfer Shipment Header";
        StdRetailItemLedgEntry: Record "Item Ledger Entry";
        StdValueEntry: Record "Value Entry";
    begin
        if not GetRetailStandardItemLedgerEntry(StdRetailItemLedgEntry, TransferShipmentLine, false, false) then
            exit;

        TransferShipmentHeader.Get(TransferShipmentLine."Document No.");
        RSRLocalizationMgt.GetPriceListLine(PriceListLine, TransferShipmentLine."Item No.", TransferShipmentHeader."Transfer-from Code", TransferShipmentHeader."Posting Date");

        StdValueEntry.FindFirstValueEntryByItemLedgerEntryNo(StdRetailItemLedgEntry."Entry No.");
        InsertStdCorrectionEntryToRetail(StdRetailItemLedgEntry, StdValueEntry);

        InsertStdEntryToRetail(StdRetailItemLedgEntry, StdValueEntry, TransferShipmentLine);

        InsertRetailCalculationEntryToRetail(TransferShipmentLine);
    end;

    local procedure InsertStdCorrectionEntryToRetail(var StdItemLedgerEntry: Record "Item Ledger Entry"; StdValueEntry: Record "Value Entry")
    var
        NewValueEntry: Record "Value Entry";
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(StdValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ReverseSignOnValueEntry(NewValueEntry);
        NewValueEntry."Cost per Unit" := -NewValueEntry."Cost per Unit";
        NewValueEntry.Description := StdCorrectionValueEntryLbl;
        NewValueEntry.Insert();
        RSRLocalizationMgt.InsertStdCorrectionValueEntryMappingEntry(NewValueEntry);

        CreateAdditionalGLEntries(NewValueEntry, Enum::"NPR RS Retail Calculation Type"::"Margin with VAT");

        StdItemLedgerEntry.Quantity += NewValueEntry."Item Ledger Entry Quantity";
        StdItemLedgerEntry."Invoiced Quantity" += NewValueEntry."Invoiced Quantity";
        StdItemLedgerEntry."Remaining Quantity" += NewValueEntry."Invoiced Quantity";
        StdItemLedgerEntry.Modify();
    end;

    local procedure InsertStdEntryToRetail(StdItemLedgerEntry: Record "Item Ledger Entry"; StdValueEntry: Record "Value Entry"; TransferShipmentLine: Record "Transfer Shipment Line")
    var
        TransitItemLedgerEntry: Record "Item Ledger Entry";
        ProcessedFirst: Boolean;
    begin
        TransitItemLedgerEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        TransitItemLedgerEntry.SetLoadFields("Entry No.");
        TransitItemLedgerEntry.SetRange("Document Type", TransitItemLedgerEntry."Document Type"::"Transfer Shipment");
        TransitItemLedgerEntry.SetRange("Document No.", TransferShipmentLine."Document No.");
        TransitItemLedgerEntry.SetRange("Location Code", TransferShipmentLine."In-Transit Code");
        TransitItemLedgerEntry.SetFilter("Invoiced Quantity", '<0');

        if TransitItemLedgerEntry.FindSet() then
            repeat
                if not ProcessedFirst then begin
                    ProcessTransitValueEntryForRetail(StdItemLedgerEntry, StdValueEntry, TransitItemLedgerEntry, false);
                    ProcessedFirst := true;
                end else
                    ProcessTransitValueEntryForRetail(StdItemLedgerEntry, StdValueEntry, TransitItemLedgerEntry, true);
            until TransitItemLedgerEntry.Next() = 0;
    end;

    local procedure ProcessTransitValueEntryForRetail(StdItemLedgerEntry: Record "Item Ledger Entry"; StdValueEntry: Record "Value Entry"; TransitItemLedgerEntry: Record "Item Ledger Entry"; InsertNewItemLedger: Boolean)
    var
        TransitValueEntry: Record "Value Entry";
        NewValueEntry: Record "Value Entry";
        NewItemLedgerEntry: Record "Item Ledger Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
        COGSCorrectionValueEntryLbl: Label 'COGS Correction';
    begin
        TransitValueEntry.SetLoadFields("Cost Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl.)", "Cost Amount (Actual) (ACY)", "Cost Amount (Expected) (ACY)", "Sales Amount (Actual)", "Sales Amount (Expected)", "Valued Quantity", "Invoiced Quantity", "Item Ledger Entry Quantity", "Cost per Unit");
        TransitValueEntry.SetRange("Item Ledger Entry No.", TransitItemLedgerEntry."Entry No.");
        if TransitValueEntry.FindSet() then begin
            if InsertNewItemLedger then
                InsertItemLedgerEntryForRetail(NewItemLedgerEntry, StdItemLedgerEntry);
            repeat
                if RSRetValueEntryMapp.Get(TransitValueEntry."Entry No.") then begin
                    if RSRetValueEntryMapp."Retail Calculation" then begin
                        InsertTransitValueEntryForRetail(NewValueEntry, StdValueEntry, TransitValueEntry);

                        if InsertNewItemLedger then begin
                            NewValueEntry."Item Ledger Entry No." := NewItemLedgerEntry."Entry No.";
                            RecalculateItemLedgerQuantities(NewItemLedgerEntry, NewValueEntry)
                        end else
                            RecalculateItemLedgerQuantities(StdItemLedgerEntry, NewValueEntry);

                        NewValueEntry.Description := COGSCorrectionValueEntryLbl;
                        NewValueEntry.Modify();

                        CreateAdditionalGLEntries(NewValueEntry, Enum::"NPR RS Retail Calculation Type"::Margin);
                        CreateAdditionalGLEntries(NewValueEntry, Enum::"NPR RS Retail Calculation Type"::VAT);

                        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(NewValueEntry);
                    end
                end
                else begin
                    InsertTransitValueEntryForRetail(NewValueEntry, StdValueEntry, TransitValueEntry);

                    if InsertNewItemLedger then begin
                        NewValueEntry."Item Ledger Entry No." := NewItemLedgerEntry."Entry No.";
                        RecalculateItemLedgerQuantities(NewItemLedgerEntry, NewValueEntry);
                    end else
                        RecalculateItemLedgerQuantities(StdItemLedgerEntry, NewValueEntry);

                    NewValueEntry.Description := StdCorrectionValueEntryLbl;
                    NewValueEntry.Modify();

                    SetGlobalLineQty(NewValueEntry."Invoiced Quantity");

                    CreateAdditionalGLEntries(NewValueEntry, Enum::"NPR RS Retail Calculation Type"::"Margin with VAT");

                    RSRLocalizationMgt.InsertStdCorrectionValueEntryMappingEntry(NewValueEntry);
                end;
            until TransitValueEntry.Next() = 0;
        end;
    end;

    local procedure InsertItemLedgerEntryForRetail(var NewItemLedgerEntry: Record "Item Ledger Entry"; StdItemLedgerEntry: Record "Item Ledger Entry")
    begin
        NewItemLedgerEntry.Init();
        NewItemLedgerEntry.Copy(StdItemLedgerEntry);
        NewItemLedgerEntry."Entry No." := NewItemLedgerEntry.GetLastEntryNo() + 1;
        NewItemLedgerEntry.Insert();
    end;

    local procedure InsertTransitValueEntryForRetail(var NewValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; TransitValueEntry: Record "Value Entry")
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(StdValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(NewValueEntry);
        RSRLocalizationMgt.CopyValueEntryAmounts(TransitValueEntry, NewValueEntry);
        RSRLocalizationMgt.ReverseSignOnValueEntry(NewValueEntry);
        NewValueEntry.Insert();
    end;

    local procedure InsertRetailCalculationEntryToRetail(TransferShipmentLine: Record "Transfer Shipment Line")
    var
        StdRetailItemLedgEntry: Record "Item Ledger Entry";
        NewValueEntry: Record "Value Entry";
        StdValueEntry: Record "Value Entry";
    begin
        if not GetRetailStandardItemLedgerEntry(StdRetailItemLedgEntry, TransferShipmentLine, true, true) then
            exit;

        repeat
            StdValueEntry.FindFirstValueEntryByItemLedgerEntryNo(StdRetailItemLedgEntry."Entry No.");
            StdRetailItemLedgEntry.CalcFields("Cost Amount (Actual)");

            if StdRetailItemLedgEntry."Cost Amount (Actual)" = (PriceListLine."Unit Price" * Abs(StdRetailItemLedgEntry."Invoiced Quantity")) then
                exit;

            NewValueEntry.Init();
            NewValueEntry.Copy(StdValueEntry);
            NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
            RSRLocalizationMgt.ResetValueEntryAmounts(NewValueEntry);
            NewValueEntry."Cost Amount (Actual)" := (PriceListLine."Unit Price" * Abs(StdRetailItemLedgEntry."Invoiced Quantity")) - StdRetailItemLedgEntry."Cost Amount (Actual)";
            NewValueEntry."Cost per Unit" := NewValueEntry."Cost Amount (Actual)" / Abs(StdRetailItemLedgEntry."Invoiced Quantity");
            NewValueEntry.Description := RetailCalculationValueEntryLbl;
            NewValueEntry.Insert();

            RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(NewValueEntry);
        until StdRetailItemLedgEntry.Next() = 0;
    end;

    local procedure InsertTransitLocationCorrectionalValueEntries(TransferShipmentLine: Record "Transfer Shipment Line")
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
        TempAppliedItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ShowAppliedEntries: Codeunit "Show Applied Entries";
    begin
        StdItemLedgerEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        StdItemLedgerEntry.SetLoadFields("Cost Amount (Actual)", "Invoiced Quantity", "Entry No.");
        StdItemLedgerEntry.SetRange("Document Type", StdItemLedgerEntry."Document Type"::"Transfer Shipment");
        StdItemLedgerEntry.SetRange("Document No.", TransferShipmentLine."Document No.");
        StdItemLedgerEntry.SetRange("Location Code", TransferShipmentLine."In-Transit Code");
        StdItemLedgerEntry.SetFilter("Invoiced Quantity", '<0');

        StdItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        if StdItemLedgerEntry.FindSet() then
            repeat
                ShowAppliedEntries.FindAppliedEntries(StdItemLedgerEntry, TempAppliedItemLedgerEntry);
                ProcessAppliedItemLedgerEntriesForTransit(TempAppliedItemLedgerEntry, StdItemLedgerEntry);
                TempAppliedItemLedgerEntry.Reset();
                TempAppliedItemLedgerEntry.DeleteAll();
            until StdItemLedgerEntry.Next() = 0;
    end;

    local procedure ProcessAppliedItemLedgerEntriesForTransit(var TempAppliedItemLedgerEntry: Record "Item Ledger Entry" temporary; StdItemLedgerEntry: Record "Item Ledger Entry")
    var
        SumOfCostOnAppliedEntries: Decimal;
    begin
        if TempAppliedItemLedgerEntry.IsEmpty() then
            exit;

        TempAppliedItemLedgerEntry.SetLoadFields("Cost Amount (Actual)", "Invoiced Quantity", "Entry No.");
        TempAppliedItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        TempAppliedItemLedgerEntry.FindSet();
        repeat
            SumOfCostOnAppliedEntries += (TempAppliedItemLedgerEntry."Cost Amount (Actual)" / TempAppliedItemLedgerEntry."Invoiced Quantity") * Abs(StdItemLedgerEntry."Invoiced Quantity");
        until TempAppliedItemLedgerEntry.Next() = 0;

        if StdItemLedgerEntry."Cost Amount (Actual)" = SumOfCostOnAppliedEntries then
            exit;

        TempAppliedItemLedgerEntry.SetLoadFields("Entry No.");
        TempAppliedItemLedgerEntry.FindSet();
        repeat
            CorrectStdEntriesToApplied(TempAppliedItemLedgerEntry, StdItemLedgerEntry);
        until TempAppliedItemLedgerEntry.Next() = 0;
    end;

    local procedure CorrectStdEntriesToApplied(var TempAppliedItemLedgerEntry: Record "Item Ledger Entry" temporary; StdItemLedgerEntry: Record "Item Ledger Entry")
    var
        AppliedValueEntry: Record "Value Entry";
        StdValueEntry: Record "Value Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        StdValueEntry.FindFirstValueEntryByItemLedgerEntryNo(StdItemLedgerEntry."Entry No.");

        AppliedValueEntry.SetLoadFields("Entry No.", "Cost Amount (Actual)", "Cost Amount (Expected)", "Cost Amount (Non-Invtbl.)", "Cost Amount (Actual) (ACY)", "Cost Amount (Expected) (ACY)", "Sales Amount (Actual)", "Sales Amount (Expected)", "Valued Quantity", "Invoiced Quantity", "Item Ledger Entry Quantity", "Cost per Unit");
        AppliedValueEntry.SetRange("Item Ledger Entry No.", TempAppliedItemLedgerEntry."Entry No.");
        if AppliedValueEntry.FindSet() then
            repeat
                if RSRetValueEntryMapp.Get(AppliedValueEntry."Entry No.") then
                    if RSRetValueEntryMapp."Retail Calculation" then
                        InsertRetCalcCorrectionEntryToApplied(StdValueEntry, AppliedValueEntry);
            until AppliedValueEntry.Next() = 0;
    end;

    local procedure InsertRetCalcCorrectionEntryToApplied(StdValueEntry: Record "Value Entry"; AppliedValueEntry: Record "Value Entry")
    var
        NewValueEntry: Record "Value Entry";
    begin
        NewValueEntry.Init();
        NewValueEntry.Copy(StdValueEntry);
        NewValueEntry."Entry No." := NewValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(NewValueEntry);
        RSRLocalizationMgt.CopyValueEntryAmounts(AppliedValueEntry, NewValueEntry);
        RSRLocalizationMgt.ReverseSignOnValueEntry(NewValueEntry);
        NewValueEntry.Description := RetailCalculationValueEntryLbl;
        NewValueEntry.Insert();

        CreateAdditionalGLEntries(NewValueEntry, Enum::"NPR RS Retail Calculation Type"::"Transit Adjustment");

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(NewValueEntry);
    end;

    #endregion RS Undo Shipment - Calculation Value Entries

    #region RS Undo Shipment - G/L Posting Procedures

    local procedure CreateAdditionalGLEntries(ValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLEntry: Record "G/L Entry";
        GenJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        InitGenJournalLine(GenJournalLine, ValueEntry, RSRetailCalculationType);
        GLSetup.Get();
        AddCurrencyCode := GLSetup."Additional Reporting Currency";
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");

        CalculateRSGLEntryAmounts(GenJournalLine, ValueEntry, RSRetailCalculationType);

        if GenJournalLine.Amount = 0 then
            exit;

        SetGlobalDimensionCodes(GenJournalLine, ValueEntry);

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

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; ValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineTransitLbl: Label 'G/L Calculation Transit Adj.';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo('', '');
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."Document No." := ValueEntry."Document No.";
        GenJournalLine."External Document No." := ValueEntry."External Document No.";
        GenJournalLine."Posting Date" := ValueEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSRetailCalculationType::"Transit Adjustment":
                GenJournalLine.Description := GenJnlLineTransitLbl;
        end;
        GenJournalLine."VAT Reporting Date" := ValueEntry."VAT Reporting Date";
        GenJournalLine."Document Date" := ValueEntry."Posting Date";
        GenJournalLine."Due Date" := ValueEntry."Posting Date";
        GenJournalLine."Source Code" := ValueEntry."Source Code";
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(ValueEntry, RSRetailCalculationType);
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

    #endregion RS Undo Shipment - G/L Posting Procedures

    #region RS Undo Shipment - Helper Procedures

    local procedure GetRetailStandardItemLedgerEntry(var StdItemLedgerEntry: Record "Item Ledger Entry"; TransferShipmentLine: Record "Transfer Shipment Line"; LoadPartial: Boolean; ShouldFindSet: Boolean): Boolean
    begin
        StdItemLedgerEntry.SetCurrentKey("Document No.", "Document Line No.", "Document Type");
        if LoadPartial then
            StdItemLedgerEntry.SetLoadFields("Entry No.", "Invoiced Quantity", "Cost Amount (Actual)");

        StdItemLedgerEntry.SetRange("Document Type", StdItemLedgerEntry."Document Type"::"Transfer Shipment");
        StdItemLedgerEntry.SetRange("Document No.", TransferShipmentLine."Document No.");
        StdItemLedgerEntry.SetRange("Location Code", TransferShipmentLine."Transfer-from Code");
        StdItemLedgerEntry.SetFilter("Invoiced Quantity", '>0');

        StdItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");

        if ShouldFindSet then
            exit(StdItemLedgerEntry.FindSet())
        else
            exit(StdItemLedgerEntry.FindFirst());
    end;

    local procedure RecalculateItemLedgerQuantities(var ItemLedgerEntry: Record "Item Ledger Entry"; ValueEntry: Record "Value Entry")
    begin
        ItemLedgerEntry.Quantity += ValueEntry."Item Ledger Entry Quantity";
        ItemLedgerEntry."Invoiced Quantity" += ValueEntry."Invoiced Quantity";
        ItemLedgerEntry."Remaining Quantity" += ValueEntry."Invoiced Quantity";
        ItemLedgerEntry.Modify();
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

            exit(ExchangeAmtLCYToFCY2(Amount, GenJnlLine));
        end;
        exit(OldAddCurrAmount);
    end;

    local procedure ExchangeAmtLCYToFCY2(Amount: Decimal; GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        AddCurrency: Record Currency;
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

    local procedure GetRSAccountNoFromSetup(CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
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
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Transit Adjustment":
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(CalculationValueEntry."Item No.", CalculationValueEntry."Location Code"));
        end;
    end;

    local procedure CalculateRSGLEntryAmounts(var GenJournalLine: Record "Gen. Journal Line"; ValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Credit Amount", CalculateRSGLVATAmount());
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Debit Amount", ValueEntry."Cost Amount (Actual)");
            RSRetailCalculationType::"Transit Adjustment":
                GenJournalLine.Validate("Credit Amount", -ValueEntry."Cost Amount (Actual)");
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Credit Amount", Abs(ValueEntry."Cost Amount (Actual)") - CalculateRSGLVATAmount());
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        exit((PriceListLine."Unit Price" * Abs(_LineQty)) * CalculateVATBreakDown());
    end;

    local procedure CalculateVATBreakDown(): Decimal
    begin
        exit(RSRLocalizationMgt.CalculateVATBreakDown(PriceListLine."VAT Bus. Posting Gr. (Price)", PriceListLine."VAT Prod. Posting Group"));
    end;

    local procedure SetGlobalLineQty(Quantity: Decimal)
    begin
        _LineQty := Quantity;
    end;

    #endregion RS Undo Shipment - Helper Procedures

    var
        PriceListLine: Record "Price List Line";
        CurrExchRate: Record "Currency Exchange Rate";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        _LineQty: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
        StdCorrectionValueEntryLbl: Label 'Std Correction';
        RetailCalculationValueEntryLbl: Label 'Retail Calculation';
#endif
}