codeunit 6151363 "NPR RS POS GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "G/L Register" = rm;

#if not (BC17 or BC18 or BC19)

    #region Eventsubscribers - RS Sales Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnAfterModifyPOSEntryOnMarkPOSEntries', '', false, false)]
    local procedure OnAfterModifyPOSEntryOnMarkPOSEntries(OptStatus: Option Posted,Error; var POSEntry: Record "NPR POS Entry"; var POSEntryWithError: Record "NPR POS Entry"; ShowProgressDialog: Boolean)
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if (OptStatus in [OptStatus::Posted]) and (POSEntry."Post Entry Status" in [POSEntry."Post Entry Status"::Posted]) then
            PostRetailCalculationEntries(POSEntry, ShowProgressDialog);
    end;
    #endregion

    #region POS Entry Calculation Posting

    internal procedure PostRetailCalculationEntries(var POSEntry: Record "NPR POS Entry"; ShowNivelationPostingMessage: Boolean)
    var
        RetailValueEntry: Record "Value Entry";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ReturnDocumentNo: Code[20];
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
    begin
        TempPOSEntrySalesLines.Reset();
        TempPOSEntrySalesLines.DeleteAll();
        TempNivelationSalesLines.Reset();
        TempNivelationSalesLines.DeleteAll();

        FillRetailPOSEntryLines(POSEntry);

        if TempPOSEntrySalesLines.IsEmpty() then
            exit;

        TempPOSEntrySalesLines.FindSet();
        repeat
            Clear(ReturnDocumentNo);

            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempPOSEntrySalesLines."No.", TempPOSEntrySalesLines."Location Code", POSEntry."Posting Date");

            if TempPOSEntrySalesLines.Quantity < 0 then
                GetReturnPOSEntryDocumentNo(ReturnDocumentNo, POSEntry);

            InsertRetailValueEntries(RetailValueEntry, POSEntry, ReturnDocumentNo);

            if (RetailValueEntry."Entry No." <> 0) and (RetailValueEntry."Cost Amount (Actual)" <> 0) then begin
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::"Margin with VAT");
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::VAT);
                CreateAdditionalGLEntries(RetailValueEntry, RSRetailCalculationType::Margin);
            end;

            CheckIfNivelationNeeded();
        until TempPOSEntrySalesLines.Next() = 0;

        RSRLocalizationMgt.ValidateGLEntriesBalanced(POSEntry."Document No.");

        if not TempNivelationSalesLines.IsEmpty() then
            CreateAndPostNivelationDocument(POSEntry, ShowNivelationPostingMessage);

        if not POSStore.Get(POSEntry."POS Store Code") then
            exit;
        if not POSPostingProfile.Get(POSStore."POS Posting Profile") then
            exit;

        RSRLocalizationMgt.AddGLEntriesToGLRegister(POSEntry."Document No.", POSPostingProfile."Source Code");
    end;

    #endregion

    #region Nivelation Document Posting
    local procedure CreateAndPostNivelationDocument(var POSEntry: Record "NPR POS Entry"; ShowNivelationPostingMessage: Boolean)
    var
        NivelationHeader: Record "NPR RS Nivelation Header";
        NivelationLines: Record "NPR RS Nivelation Lines";
        VATSetup: Record "VAT Posting Setup";
        NivelationPost: Codeunit "NPR RS Nivelation Post";
        LineNo: Integer;
    begin
        NivelationHeader.Init();
        NivelationHeader.Type := "NPR RS Nivelation Type"::"Promotions & Discounts";
        NivelationHeader."Source Type" := "NPR RS Nivelation Source Type"::"POS Entry";
        NivelationHeader."Referring Document Code" := POSEntry."Document No.";
        NivelationHeader."Posting Date" := POSEntry."Posting Date";
        NivelationHeader.Insert(true);
        LineNo := NivelationLines.GetInitialLine() + 10000;
        TempNivelationSalesLines.FindSet();
        repeat
            NivelationLines.Init();
            NivelationLines."Line No." := LineNo;
            NivelationLines."Document No." := NivelationHeader."No.";
            NivelationLines."Location Code" := TempNivelationSalesLines."Location Code";
            NivelationLines."VAT Bus. Posting Gr. (Price)" := PriceListLine."VAT Bus. Posting Gr. (Price)";
            NivelationLines.Validate("Item No.", TempNivelationSalesLines."No.");
            NivelationLines.Quantity := TempNivelationSalesLines.Quantity;
            RSRLocalizationMgt.GetPriceListLine(PriceListLine, TempNivelationSalesLines."No.", TempNivelationSalesLines."Location Code", POSEntry."Posting Date");
            NivelationLines."Old Price" := PriceListLine."Unit Price";
            NivelationLines."Posting Date" := POSEntry."Posting Date";
            NivelationLines.Validate("New Price", RSRLocalizationMgt.RoundAmountToCurrencyRounding((TempNivelationSalesLines."Amount Incl. VAT" / TempNivelationSalesLines.Quantity), TempNivelationSalesLines."Currency Code"));
            if VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", TempNivelationSalesLines."VAT Prod. Posting Group") then
                NivelationLines."VAT %" := VATSetup."VAT %";
            NivelationLines.Insert(true);
            LineNo += 10000;
        until TempNivelationSalesLines.Next() = 0;

        NivelationPost.RunNivelationPosting(NivelationHeader, ShowNivelationPostingMessage);
    end;

    local procedure CheckIfNivelationNeeded()
    begin
        if TempPOSEntrySalesLines."Line Discount %" = 0 then
            exit;
        if TempPOSEntrySalesLines."Amount Incl. VAT" = (PriceListLine."Unit Price" * TempPOSEntrySalesLines.Quantity) then
            exit;
        TempNivelationSalesLines.Init();
        TempNivelationSalesLines.Copy(TempPOSEntrySalesLines);
        TempNivelationSalesLines.Insert();
    end;

    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
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

        if TempPOSEntrySalesLines.Quantity > 0 then
            ValidatePositiveGenJnlLineAmounts(GenJournalLine, RSRetailCalculationType, CalculationValueEntry)
        else
            ValidateNegativeGenJnlLineAmounts(GenJournalLine, RSRetailCalculationType, CalculationValueEntry);

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

        if TempPOSEntrySalesLines.Quantity > 0 then
            CalculatePositiveGenJnlLineAmounts(GenJournalLine, RSRetailCalculationType, CalculationValueEntry)
        else
            CalculateNegativeGenJnlLineAmounts(GenJournalLine, RSRetailCalculationType, CalculationValueEntry);

        PostGLAcc(GenJournalLine, GLEntry);

        RSRLocalizationMgt.InsertGLItemLedgerRelation(GenJnlPostLine, GLEntry."Entry No.", CalculationValueEntry."Entry No.");
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
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
        GenJnlLineCOGSCorrectionLbl: Label 'COGS Correction';
        GenJnLineStdCorrectionLbl: Label 'Standard Correction';
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo('', '');
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
        GenJournalLine."Document No." := CalculationValueEntry."Document No.";
        GenJournalLine."External Document No." := CalculationValueEntry."External Document No.";
        GenJournalLine."Posting Date" := CalculationValueEntry."Posting Date";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Description := GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := GenJnlLineVATLbl;
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine.Description := GenJnlLineCOGSCorrectionLbl;
            RSRetailCalculationType::"Standard Correction", RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Description := GenJnLineStdCorrectionLbl;
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
        InitVAT(GenJnlLine, GLEntry);
        GenJnlPostLine.InsertGLEntry(GenJnlLine, GLEntry, true);
        PostJob(GenJnlLine, GLEntry);
        GLEntry.Insert();
    end;

    local procedure InitVAT(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
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

    #region Additional Item Ledger and Value Entry Posting

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; POSEntry: Record "NPR POS Entry"; ReturnDocumentNo: Code[20])
    var
        StdValueEntry: Record "Value Entry";
        StdCorrectionValueEntry: Record "Value Entry";
        SumOfCOGSCostPerUnit: Decimal;
        SumOfCOGSCostAmtAct: Decimal;
    begin
        StdValueEntry.SetRange("Location Code", TempPOSEntrySalesLines."Location Code");
        StdValueEntry.SetRange("Document No.", POSEntry."Document No.");
        StdValueEntry.SetRange("Item No.", TempPOSEntrySalesLines."No.");
        StdValueEntry.SetRange("Document Line No.", TempPOSEntrySalesLines."Line No.");

        if not StdValueEntry.FindFirst() then
            exit;

        if (ReturnDocumentNo <> '') then begin
            InsertReturnAppliedValueEntryAdjust(StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, ReturnDocumentNo);
            InsertRetailValueEntry(RetailValueEntry, StdValueEntry, StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, POSEntry, true);
        end
        else begin
            InsertAppliedValueEntryAdj(StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry);
            InsertRetailValueEntry(RetailValueEntry, StdValueEntry, StdCorrectionValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, POSEntry, false);
        end;
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; StdCorrectionValueEntry: Record "Value Entry"; SumOfCOGSCostPerUnit: Decimal; SumOfCOGSCostAmtAct: Decimal; POSEntry: Record "NPR POS Entry"; IsReturnEntry: Boolean)
    var
        CalculationValueEntryDescLbl: Label 'Calculation';
        DiscountPerUnit: Decimal;
        SumOfStdCostPerUnit: Decimal;
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;

        RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);

        SumOfStdCostPerUnit := StdValueEntry."Cost per Unit" + SumOfCOGSCostPerUnit + StdCorrectionValueEntry."Cost per Unit";
        DiscountPerUnit := Abs(TempPOSEntrySalesLines."Line Discount Amount Incl. VAT" / TempPOSEntrySalesLines.Quantity);
        RetailValueEntry."Cost per Unit" := GetUnitPriceInclVAT(POSEntry) - SumOfStdCostPerUnit - DiscountPerUnit;
        RetailValueEntry."Cost per Unit" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Cost per Unit", TempPOSEntrySalesLines."Currency Code");

        if (PriceListLine."Unit Price" * TempPOSEntrySalesLines.Quantity) <> (StdValueEntry."Cost Amount (Actual)" + StdCorrectionValueEntry."Cost Amount (Actual)" + SumOfCOGSCostAmtAct) then begin
            RetailValueEntry."Cost Amount (Actual)" := (GetUnitPriceInclVAT(POSEntry) * Abs(TempPOSEntrySalesLines.Quantity)) - SumOfCOGSCostAmtAct - Abs(TempPOSEntrySalesLines."Line Discount Amount Incl. VAT");
            RetailValueEntry."Cost Amount (Actual)" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Cost Amount (Actual)", TempPOSEntrySalesLines."Currency Code");
        end;

        if Abs(PriceListLine."Unit Price" * TempPOSEntrySalesLines.Quantity) <> Abs(StdValueEntry."Sales Amount (Actual)") then begin
            RetailValueEntry."Sales Amount (Actual)" := CalculateRSGLVATAmount(POSEntry);
            RetailValueEntry."Sales Amount (Actual)" := RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Sales Amount (Actual)", TempPOSEntrySalesLines."Currency Code");
        end;

        if IsReturnEntry then
            RetailValueEntry."Sales Amount (Actual)" := -RetailValueEntry."Sales Amount (Actual)"
        else
            RetailValueEntry."Cost Amount (Actual)" := -RetailValueEntry."Cost Amount (Actual)";

        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        if (RetailValueEntry."Cost Amount (Actual)" = 0) and (RetailValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        RetailValueEntry.Description := CalculationValueEntryDescLbl;

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    local procedure GetUnitPriceInclVAT(POSEntry: Record "NPR POS Entry"): Decimal
    begin
        if POSEntry."Prices Including VAT" then
            exit(PriceListLine."Unit Price")
        else
            exit(PriceListLine."Unit Price" * (100 + TempPOSEntrySalesLines."VAT %") / 100);
    end;

    local procedure InsertAppliedValueEntryAdj(var StdCorrectionValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry")
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
        TempApplicationItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ApplValueEntry: Record "Value Entry";
        ShowAppliedEntries: Codeunit "Show Applied Entries";
        QtyTakenFromEntry: Decimal;
        QtyNeeded: Decimal;
    begin
        if not StdItemLedgerEntry.Get(StdValueEntry."Item Ledger Entry No.") then
            exit;

        CorrectStdValueEntry(StdCorrectionValueEntry, StdValueEntry, false);

        ShowAppliedEntries.FindAppliedEntries(StdItemLedgerEntry, TempApplicationItemLedgerEntry);

        if TempApplicationItemLedgerEntry.IsEmpty() then
            exit;

        QtyNeeded := TempPOSEntrySalesLines.Quantity;
        TempApplicationItemLedgerEntry.FindSet();
        repeat
            ApplValueEntry.SetRange("Item Ledger Entry No.", TempApplicationItemLedgerEntry."Entry No.");
            if ApplValueEntry.FindSet() then
                repeat
                    HandleApplicationValueEntry(ApplValueEntry, StdValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, QtyNeeded, QtyTakenFromEntry);
                until (ApplValueEntry.Next() = 0) or (QtyNeeded <= 0);
        until TempApplicationItemLedgerEntry.Next() = 0;
    end;

    local procedure InsertReturnAppliedValueEntryAdjust(var StdCorrectionValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry"; ReturnDocumentNo: Code[20])
    var
        ApplValueEntry: Record "Value Entry";
        QtyTakenFromEntry: Decimal;
        QtyNeeded: Decimal;
    begin
        CorrectStdValueEntry(StdCorrectionValueEntry, StdValueEntry, true);

        ApplValueEntry.SetLoadFields("Cost per Unit");
        ApplValueEntry.SetRange("Document No.", ReturnDocumentNo);
        ApplValueEntry.SetRange("Item No.", TempPOSEntrySalesLines."No.");
        ApplValueEntry.SetRange("Location Code", TempPOSEntrySalesLines."Location Code");
        if ApplValueEntry.IsEmpty() then
            exit;

        QtyNeeded := Abs(TempPOSEntrySalesLines.Quantity);

        ApplValueEntry.FindSet();
        repeat
            HandleReturnApplicationValueEntry(ApplValueEntry, StdValueEntry, SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, QtyNeeded, QtyTakenFromEntry);
        until ApplValueEntry.Next() = 0;
    end;

    local procedure CorrectStdValueEntry(var StdCorrectionValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; IsReturnEntry: Boolean)
    var
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        StdCorrectionValueEntryDescLbl: Label 'Standard Correction';
    begin
        Clear(StdCorrectionValueEntry);
        StdCorrectionValueEntry.Init();
        StdCorrectionValueEntry.Copy(StdValueEntry);
        StdCorrectionValueEntry."Entry No." := StdCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(StdCorrectionValueEntry);
        StdCorrectionValueEntry."Cost per Unit" := -StdValueEntry."Cost per Unit";

        if IsReturnEntry then begin
            StdCorrectionValueEntry."Cost Amount (Actual)" := -StdValueEntry."Cost Amount (Actual)";
            StdCorrectionValueEntry."Invoiced Quantity" := -StdValueEntry."Invoiced Quantity";
            StdCorrectionValueEntry."Valued Quantity" := -StdValueEntry."Valued Quantity";
            StdCorrectionValueEntry."Item Ledger Entry Quantity" := -StdValueEntry."Item Ledger Entry Quantity";
        end
        else begin
            StdCorrectionValueEntry."Cost Amount (Actual)" := Abs(StdValueEntry."Cost Amount (Actual)");
            StdCorrectionValueEntry."Invoiced Quantity" := Abs(StdValueEntry."Invoiced Quantity");
            StdCorrectionValueEntry."Valued Quantity" := Abs(StdValueEntry."Valued Quantity");
            StdCorrectionValueEntry."Item Ledger Entry Quantity" := Abs(StdValueEntry."Item Ledger Entry Quantity");
        end;

        StdCorrectionValueEntry."Cost Posted to G/L" := StdCorrectionValueEntry."Cost Amount (Actual)";
        StdCorrectionValueEntry.Description := StdCorrectionValueEntryDescLbl;
        StdCorrectionValueEntry.Insert();

        RSRLocalizationMgt.InsertStdCorrectionValueEntryMappingEntry(StdCorrectionValueEntry);

        CreateAdditionalGLEntries(StdCorrectionValueEntry, RSRetailCalculationType::"Standard Correction");
        CreateAdditionalGLEntries(StdCorrectionValueEntry, RSRetailCalculationType::"Counter Std Correction");
    end;

    local procedure HandleApplicationValueEntry(ApplValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; var QtyNeeded: Decimal; QtyTakenFromEntry: Decimal)
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        if not RSRetValueEntryMapp.Get(ApplValueEntry."Entry No.") then
            exit;
        if not ((RSRetValueEntryMapp."COGS Correction") and (RSRetValueEntryMapp.Open)) then
            exit;

        QtyTakenFromEntry := RSRetValueEntryMapp."Remaining Quantity";
        case true of
            (QtyTakenFromEntry < QtyNeeded) or (QtyTakenFromEntry = QtyNeeded):
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, CalculateAppliedCostPerUnit(ApplValueEntry), QtyTakenFromEntry, false);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyTakenFromEntry);
                end;
            QtyTakenFromEntry > QtyNeeded:
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, CalculateAppliedCostPerUnit(ApplValueEntry), QtyNeeded, false);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyNeeded);
                end;
        end;
        QtyNeeded := QtyNeeded - QtyTakenFromEntry;
    end;

    local procedure CalculateAppliedCostPerUnit(ApplValueEntry: Record "Value Entry") AppliedCostPerUnit: Decimal
    var
        ItemChargeValueEntries: Record "Value Entry";
    begin
        ItemChargeValueEntries.SetLoadFields("Cost per Unit");
        ItemChargeValueEntries.SetRange("Item Ledger Entry No.", ApplValueEntry."Item Ledger Entry No.");
        ItemChargeValueEntries.SetFilter("Item Charge No.", '<>%1', '');
        if ItemChargeValueEntries.IsEmpty() then
            AppliedCostPerUnit := ApplValueEntry."Cost per Unit"
        else begin
            ItemChargeValueEntries.CalcSums("Cost per Unit");
            AppliedCostPerUnit := ApplValueEntry."Cost per Unit" + ItemChargeValueEntries."Cost per Unit";
        end;
    end;

    local procedure HandleReturnApplicationValueEntry(ApplValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; var QtyNeeded: Decimal; QtyTakenFromEntry: Decimal)
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        if QtyNeeded <= 0 then
            exit;
        if not RSRetValueEntryMapp.Get(ApplValueEntry."Entry No.") then
            exit;
        if not ((RSRetValueEntryMapp."COGS Correction") and (RSRetValueEntryMapp.Open)) then
            exit;

        QtyTakenFromEntry := Abs(RSRetValueEntryMapp."Remaining Quantity");

        case true of
            (QtyTakenFromEntry < QtyNeeded) or (QtyTakenFromEntry = QtyNeeded):
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, ApplValueEntry."Cost per Unit", QtyTakenFromEntry, true);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyTakenFromEntry);
                end;
            QtyTakenFromEntry > QtyNeeded:
                begin
                    InsertCOGSCorrectionValueEntry(SumOfCOGSCostPerUnit, SumOfCOGSCostAmtAct, StdValueEntry, ApplValueEntry."Cost per Unit", QtyNeeded, true);
                    RSRLocalizationMgt.SubRetValueEntryMappingRemainingQty(RSRetValueEntryMapp, QtyNeeded);
                end;
        end;

        QtyNeeded := QtyNeeded - QtyTakenFromEntry;
    end;

    local procedure InsertCOGSCorrectionValueEntry(var SumOfCOGSCostPerUnit: Decimal; var SumOfCOGSCostAmtAct: Decimal; StdValueEntry: Record "Value Entry"; ApplCostPerUnit: Decimal; ApplQty: Decimal; Positive: Boolean)
    var
        COGSCorrectionValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        CorrectionEntryDescLbl: Label 'COGS Correction';
    begin
        COGSCorrectionValueEntry.Init();
        COGSCorrectionValueEntry.Copy(StdValueEntry);
        COGSCorrectionValueEntry."Entry No." := COGSCorrectionValueEntry.GetLastEntryNo() + 1;
        RSRLocalizationMgt.ResetValueEntryAmounts(COGSCorrectionValueEntry);
        COGSCorrectionValueEntry."Cost per Unit" := ApplCostPerUnit;

        if Positive then begin
            COGSCorrectionValueEntry."Invoiced Quantity" := ApplQty;
            COGSCorrectionValueEntry."Valued Quantity" := ApplQty;
            COGSCorrectionValueEntry."Item Ledger Entry Quantity" := ApplQty;
        end
        else begin
            COGSCorrectionValueEntry."Invoiced Quantity" := -ApplQty;
            COGSCorrectionValueEntry."Item Ledger Entry Quantity" := -ApplQty;
            COGSCorrectionValueEntry."Valued Quantity" := -ApplQty;
        end;

        COGSCorrectionValueEntry."Cost Amount (Actual)" := COGSCorrectionValueEntry."Cost per Unit" * COGSCorrectionValueEntry."Invoiced Quantity";
        COGSCorrectionValueEntry."Cost Posted to G/L" := COGSCorrectionValueEntry."Cost Amount (Actual)";
        COGSCorrectionValueEntry.Description := CorrectionEntryDescLbl;
        COGSCorrectionValueEntry.Insert();

        SumOfCOGSCostPerUnit += COGSCorrectionValueEntry."Cost per Unit";
        SumOfCOGSCostAmtAct += Abs(COGSCorrectionValueEntry."Cost Amount (Actual)");

        CreateAdditionalGLEntries(COGSCorrectionValueEntry, RSRetailCalculationType::"COGS Correction");
        CreateAdditionalGLEntries(COGSCorrectionValueEntry, RSRetailCalculationType::"Counter COGS Correction");

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(COGSCorrectionValueEntry);
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
            RSRetailCalculationType::"Margin with VAT", RSRetailCalculationType::"Counter COGS Correction", RSRetailCalculationType::"Counter Std Correction":
                exit(RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(TempPOSEntrySalesLines."No.", TempPOSEntrySalesLines."Location Code"));
            RSRetailCalculationType::Margin:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSRetailCalculationType::"COGS Correction", RSRetailCalculationType::"Standard Correction":
                exit(GetCOGSAccountFromGenPostingSetup());
        end;
    end;

    local procedure ValidatePositiveGenJnlLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"COGS Correction":
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L"));
            RSRetailCalculationType::"Standard Correction":
                GenJournalLine.Validate("Debit Amount", -CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Debit Amount", -(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Credit Amount", -(CalculationValueEntry."Cost Posted to G/L"));
            RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine.Validate("Credit Amount", Abs(CalculationValueEntry."Cost Posted to G/L"));
            RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine.Validate("Credit Amount", -Abs(CalculationValueEntry."Cost Posted to G/L"));
        end;
    end;

    local procedure ValidateNegativeGenJnlLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Validate("Credit Amount", -CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::Margin:
                GenJournalLine.Validate("Debit Amount", -((CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)")));
            RSRetailCalculationType::VAT:
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Sales Amount (Actual)");
            RSRetailCalculationType::"Standard Correction":
                begin
                    GenJournalLine.Validate("Credit Amount", -Abs(CalculationValueEntry."Cost Posted to G/L"));
                    GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
                end;
            RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"COGS Correction":
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"Counter Std Correction":
                begin
                    GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Cost Posted to G/L"));
                    GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
                end;
        end;
    end;

    local procedure CalculatePositiveGenJnlLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"COGS Correction":
                GenJournalLine."Debit Amount" := Abs(CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"Standard Correction":
                GenJournalLine."Debit Amount" := -CalculationValueEntry."Cost Posted to G/L";
            RSRetailCalculationType::Margin:
                GenJournalLine."Debit Amount" := -(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)");
            RSRetailCalculationType::VAT:
                GenJournalLine."Debit Amount" := Abs(CalculationValueEntry."Sales Amount (Actual)");
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine."Credit Amount" := -(CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine."Credit Amount" := Abs(CalculationValueEntry."Cost Posted to G/L");
            RSRetailCalculationType::"Counter Std Correction":
                GenJournalLine."Credit Amount" := -Abs(CalculationValueEntry."Cost Posted to G/L");
        end;

        if GenJournalLine."Credit Amount" <> 0 then begin
            GenJournalLine.Amount := -GenJournalLine."Credit Amount";
            GenJournalLine."Debit Amount" := 0;
        end;

        if GenJournalLine."Debit Amount" <> 0 then begin
            GenJournalLine.Amount := GenJournalLine."Debit Amount";
            GenJournalLine."Credit Amount" := 0;
        end;
    end;

    local procedure CalculateNegativeGenJnlLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; CalculationValueEntry: Record "Value Entry")
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                begin
                    GenJournalLine."Credit Amount" := -CalculationValueEntry."Cost Posted to G/L";
                    GenJournalLine.Amount := CalculationValueEntry."Cost Posted to G/L";
                end;
            RSRetailCalculationType::Margin:
                begin
                    GenJournalLine."Debit Amount" := -((CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"));
                    GenJournalLine.Amount := GenJournalLine."Debit Amount";
                end;
            RSRetailCalculationType::VAT:
                begin
                    GenJournalLine."Debit Amount" := CalculationValueEntry."Sales Amount (Actual)";
                    GenJournalLine.Amount := GenJournalLine."Debit Amount";
                end;
            RSRetailCalculationType::"Standard Correction":
                begin
                    GenJournalLine."Credit Amount" := -Abs(CalculationValueEntry."Cost Posted to G/L");
                    GenJournalLine.Amount := Abs(GenJournalLine.Amount);
                    GenJournalLine."Debit Amount" := 0;
                end;
            RSRetailCalculationType::"Counter COGS Correction":
                GenJournalLine."Debit Amount" := CalculationValueEntry."Cost Posted to G/L";
            RSRetailCalculationType::"COGS Correction":
                GenJournalLine."Credit Amount" := CalculationValueEntry."Cost Posted to G/L";
            RSRetailCalculationType::"Counter Std Correction":
                begin
                    GenJournalLine."Debit Amount" := -Abs(CalculationValueEntry."Cost Posted to G/L");
                    GenJournalLine.Amount := -Abs(GenJournalLine.Amount);
                    GenJournalLine."Credit Amount" := 0;
                end;
        end;
    end;

    local procedure CalculateRSGLVATAmount(POSEntry: Record "NPR POS Entry"): Decimal
    var
        CalculatedLineAmount: Decimal;
    begin
        CalculatedLineAmount := Abs((GetUnitPriceInclVAT(POSEntry) * Abs(TempPOSEntrySalesLines.Quantity)) - Abs(TempPOSEntrySalesLines."Line Discount Amount Incl. VAT"));
        exit(CalculatedLineAmount * RSRLocalizationMgt.CalculateVATBreakDown(TempPOSEntrySalesLines."VAT Bus. Posting Group", TempPOSEntrySalesLines."VAT Prod. Posting Group"))
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

    local procedure FillRetailPOSEntryLines(POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("Exclude from Posting", false);
        POSEntrySalesLine.SetFilter(Type, 'Item');
        if POSEntrySalesLine.IsEmpty() then
            exit;
        POSEntrySalesLine.FindSet();
        repeat
            if RSRLocalizationMgt.IsRetailLocation(POSEntrySalesLine."Location Code") then
                if not (RSRLocalizationMgt.IsServiceItem(POSEntrySalesLine."No.")) then begin
                    TempPOSEntrySalesLines.Init();
                    TempPOSEntrySalesLines.Copy(POSEntrySalesLine);
                    TempPOSEntrySalesLines.Insert();
                end;
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure GetCOGSAccountFromGenPostingSetup(): Code[20]
    var
        GenPostingSetup: Record "General Posting Setup";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.Get(TempPOSEntrySalesLines."POS Store Code");
        POSPostingProfile.Get(POSStore."POS Posting Profile");
        GenPostingSetup.Get(POSPostingProfile."Gen. Bus. Posting Group", TempPOSEntrySalesLines."Gen. Prod. Posting Group");
        exit(GenPostingSetup."COGS Account");
    end;

    local procedure GetReturnPOSEntryDocumentNo(var ReturnDocNo: Code[20]; POSEntry: Record "NPR POS Entry")
    var
        POSRMALine: Record "NPR POS RMA Line";
    begin
        POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSRMALine.SetRange("Returned Item No.", TempPOSEntrySalesLines."No.");
        if not POSRMALine.FindFirst() then
            exit;
        ReturnDocNo := POSRMALine."Sales Ticket No.";
    end;
    #endregion

    var
        AddCurrency: Record Currency;
        LCYCurrency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        TempNivelationSalesLines: Record "NPR POS Entry Sales Line" temporary;
        TempPOSEntrySalesLines: Record "NPR POS Entry Sales Line" temporary;
        PriceListLine: Record "Price List Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
#endif
}