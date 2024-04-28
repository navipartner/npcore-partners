codeunit 6151363 "NPR RS POS GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Item Ledger Entry" = rimd,
                  tabledata "Value Entry" = rimd;

#if not (BC17 or BC18 or BC19)
    #region Eventsubscribers - RS Sales Posting Behaviour
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Post Entries", 'OnAfterPostPOSEntry', '', false, false)]
    local procedure AddSalesGLEntries(var POSEntry: Record "NPR POS Entry")
    var
        GenJournalLine: Record "Gen. Journal Line";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        RetailValueEntry: Record "Value Entry";
        StdCorrectionValueEntry: Record "Value Entry";
        ReturnDocumentNo: Code[20];
        RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection;
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        FillRetailPOSEntryLines(POSEntry);

        if not TempPOSEntrySalesLines.FindSet() then
            exit;

        FilterPriceListHeader(POSEntry);

        repeat
            Clear(RetailValueEntry);
            Clear(StdCorrectionValueEntry);
            Clear(ReturnDocumentNo);

            FindPriceListLine(TempPOSEntrySalesLines."Location Code", TempPOSEntrySalesLines."No.");

            if TempPOSEntrySalesLines.Quantity < 0 then
                GetReturnPOSEntryDocumentNo(ReturnDocumentNo, POSEntry);

            InsertRetailValueEntries(RetailValueEntry, StdCorrectionValueEntry, POSEntry, ReturnDocumentNo);

            if (RetailValueEntry."Entry No." <> 0) and (RetailValueEntry."Cost Amount (Actual)" <> 0) then begin
                CreateAdditionalGLEntries(GenJournalLine, RetailValueEntry, RSGLEntryType::Margin);
                CreateAdditionalGLEntries(GenJournalLine, RetailValueEntry, RSGLEntryType::VAT);
                CreateAdditionalGLEntries(GenJournalLine, RetailValueEntry, RSGLEntryType::MarginNoVAT);
                InsertGLItemLedgerRelation(RetailValueEntry, GetInventoryAccountFromInvPostingSetup(TempPOSEntrySalesLines."Location Code"));
                InsertGLItemLedgerRelation(RetailValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::VAT));
                InsertGLItemLedgerRelation(RetailValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::MarginNoVAT));
            end;

            if (StdCorrectionValueEntry."Entry No." <> 0) then begin
                CreateAdditionalGLEntries(GenJournalLine, StdCorrectionValueEntry, RSGLEntryType::StdCorrection);
                CreateAdditionalGLEntries(GenJournalLine, StdCorrectionValueEntry, RSGLEntryType::CounterStdCorrection);
                InsertGLItemLedgerRelation(StdCorrectionValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::StdCorrection));
                InsertGLItemLedgerRelation(StdCorrectionValueEntry, GetRSAccountNoFromSetup(RSGLEntryType::CounterStdCorrection));
            end;

            CheckIfNivelationNeeded();
        until TempPOSEntrySalesLines.Next() = 0;

        if not TempNivelationSalesLines.IsEmpty() then
            CreateAndPostNivelationDocument(POSEntry);
    end;
    #endregion

    #region Nivelation Document Posting
    local procedure CreateAndPostNivelationDocument(var POSEntry: Record "NPR POS Entry")
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
        if TempNivelationSalesLines.FindSet() then
            repeat
                NivelationLines.Init();
                NivelationLines."Line No." := LineNo;
                NivelationLines."Document No." := NivelationHeader."No.";
                NivelationLines."Location Code" := TempNivelationSalesLines."Location Code";
                NivelationLines.Validate("Item No.", TempNivelationSalesLines."No.");
                NivelationLines.Quantity := TempNivelationSalesLines.Quantity;
                FindPriceListLine(TempNivelationSalesLines."Location Code", TempNivelationSalesLines."No.");
                NivelationLines."Old Price" := PriceListLine."Unit Price";
                NivelationLines."VAT Bus. Posting Gr. (Price)" := PriceListLine."VAT Bus. Posting Gr. (Price)";
                NivelationLines."Posting Date" := POSEntry."Posting Date";
                NivelationLines."New Price" := Abs(TempNivelationSalesLines."Unit Price") - Abs(TempNivelationSalesLines."Line Discount Amount Incl. VAT");
                if VATSetup.Get(PriceListLine."VAT Bus. Posting Gr. (Price)", TempNivelationSalesLines."VAT Prod. Posting Group") then
                    NivelationLines."VAT %" := VATSetup."VAT %";
                NivelationLines.Insert(true);
                LineNo += 10000;
            until TempNivelationSalesLines.Next() = 0;
        NivelationHeader.CalcFields(Amount);
        NivelationHeader.Modify();

        NivelationPost.RunNivelationPosting(NivelationHeader);
    end;

    local procedure CheckIfNivelationNeeded()
    begin
        if TempPOSEntrySalesLines."Line Discount %" = 0 then
            exit;
        if (TempPOSEntrySalesLines."Unit Price" - TempPOSEntrySalesLines."Line Discount Amount Incl. VAT") = PriceListLine."Unit Price" then
            exit;
        TempNivelationSalesLines.Init();
        TempNivelationSalesLines.Copy(TempPOSEntrySalesLines);
        TempNivelationSalesLines.Insert();
    end;

    #endregion

    #region GL Entry Posting
    local procedure CreateAdditionalGLEntries(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection)
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

        case true of
            TempPOSEntrySalesLines."Line Amount" > 0:
                ValidateGenJnlLinePositiveAmounts(GenJournalLine, RSGLEntryType, CalculationValueEntry);
            else
                ValidateGenJnlLineNegativeAmounts(GenJournalLine, RSGLEntryType, CalculationValueEntry);
        end;

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

        ValidateNegativeDebitCredit(GenJournalLine, RSGLEntryType);

        if (TempPOSEntrySalesLines."Line Amount" < 0) and (RSGLEntryType in [RSGLEntryType::Margin]) then begin
            GenJournalLine."Credit Amount" := -Abs(GenJournalLine.Amount);
            GenJournalLine."Debit Amount" := 0;
        end;

        PostGLAcc(GenJournalLine, GLEntry);
    end;


    local procedure ValidateNegativeDebitCredit(var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection)
    begin
        if TempPOSEntrySalesLines."Line Amount" > 0 then
            exit;

        case RSGLEntryType of
            RSGLEntryType::Margin:
                begin
                    GenJournalLine."Credit Amount" := -Abs(GenJournalLine.Amount);
                    GenJournalLine."Debit Amount" := 0;
                end;
            RSGLEntryType::MarginNoVAT, RSGLEntryType::VAT:
                begin
                    GenJournalLine."Debit Amount" := -Abs(GenJournalLine.Amount);
                    GenJournalLine."Credit Amount" := 0;
                end;
        end;
    end;

    local procedure ValidateGenJnlLinePositiveAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection; CalculationValueEntry: Record "Value Entry")
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin:
                GenJournalLine.Validate("Credit Amount", Abs(CalculationValueEntry."Cost Posted to G/L"));
            RSGLEntryType::CounterStdCorrection:
                GenJournalLine.Validate("Credit Amount", CalculationValueEntry."Cost Posted to G/L");
            RSGLEntryType::StdCorrection:
                GenJournalLine.Validate("Debit Amount", CalculationValueEntry."Cost Posted to G/L");
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"));
        end;
    end;

    local procedure ValidateGenJnlLineNegativeAmounts(var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection; CalculationValueEntry: Record "Value Entry")
    begin
        case RSGLEntryType of
            RSGLEntryType::Margin, RSGLEntryType::StdCorrection:
                begin
                    GenJournalLine.Validate("Credit Amount", -Abs(CalculationValueEntry."Cost Amount (Actual)"));
                    GenJournalLine.Validate(Amount, Abs(GenJournalLine.Amount));
                    exit;
                end;
            RSGLEntryType::CounterStdCorrection:
                GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Cost Amount (Actual)"));
            RSGLEntryType::VAT:
                GenJournalLine.Validate("Debit Amount", -Abs(CalculationValueEntry."Sales Amount (Actual)"));
            RSGLEntryType::MarginNoVAT:
                GenJournalLine.Validate("Debit Amount", Abs(CalculationValueEntry."Cost Posted to G/L") - Abs(CalculationValueEntry."Sales Amount (Actual)"));
        end;
        GenJournalLine.Validate(Amount, -Abs(GenJournalLine.Amount));
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

    local procedure InitGenLineFromLastGLEntry(var GenJournalLine: Record "Gen. Journal Line"; RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection)
    var
        GLEntry: Record "G/L Entry";
        GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        GenJnlLineVATLbl: Label 'G/L Calculation VAT';
        GenJnlLineStdCorrectionLbl: Label 'COGS Correction';
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
            RSGLEntryType::StdCorrection:
                GenJournalLine.Description := GenJnlLineStdCorrectionLbl;
            RSGLEntryType::CounterStdCorrection:
                GenJournalLine.Description := GenJnlLineStdCorrectionLbl;
        end;
        GenJournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
        GenJournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
        GenJournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
        GenJournalLine."Document Date" := GLEntry."Posting Date";
        GenJournalLine."Due Date" := GLEntry."Posting Date";
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

    local procedure InsertRetailValueEntries(var RetailValueEntry: Record "Value Entry"; var ApplValueEntry: Record "Value Entry"; POSEntry: Record "NPR POS Entry"; ReturnDocumentNo: Code[20])
    var
        StdValueEntry: Record "Value Entry";
    begin
        StdValueEntry.SetRange("Location Code", TempPOSEntrySalesLines."Location Code");
        StdValueEntry.SetRange("Document No.", POSEntry."Document No.");
        StdValueEntry.SetRange("Item No.", TempPOSEntrySalesLines."No.");
        if not StdValueEntry.FindFirst() then
            exit;

        case true of
            ReturnDocumentNo <> '':
                InsertReturnAppliedValueEntryCostAdjustment(ApplValueEntry, StdValueEntry, ReturnDocumentNo);
            else
                InsertAppliedValueEntryCostAdjustment(ApplValueEntry, StdValueEntry);
        end;

        InsertRetailValueEntry(RetailValueEntry, StdValueEntry, ApplValueEntry);
    end;

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; ApplValueEntry: Record "Value Entry")
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        CalculationDescLbl: Label 'Calculation';
    begin
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        RetailValueEntry.Description := CalculationDescLbl;
        ResetValueEntryAmounts(RetailValueEntry);

        RetailValueEntry."Cost per Unit" := PriceListLine."Unit Price" - StdValueEntry."Cost per Unit" - ApplValueEntry."Cost per Unit";

        case true of
            TempPOSEntrySalesLines.Quantity > 0:
                begin
                    if PriceListLine."Unit Price" <> (StdValueEntry."Cost Amount (Actual)" + ApplValueEntry."Cost Amount (Actual)") then
                        RetailValueEntry."Cost Amount (Actual)" := -CalculateRSGLMarginAmount(RetailValueEntry, StdValueEntry);

                    if PriceListLine."Unit Price" <> Abs(StdValueEntry."Sales Amount (Actual)") then
                        RetailValueEntry."Sales Amount (Actual)" := CalculateRSGLVATAmount();
                end
            else begin
                if PriceListLine."Unit Price" <> (StdValueEntry."Cost Amount (Actual)" + ApplValueEntry."Cost Amount (Actual)") then
                    RetailValueEntry."Cost Amount (Actual)" := CalculateRSGLMarginAmount(RetailValueEntry, StdValueEntry);

                if PriceListLine."Unit Price" <> Abs(StdValueEntry."Sales Amount (Actual)") then
                    RetailValueEntry."Sales Amount (Actual)" := -CalculateRSGLVATAmount();
            end;
        end;

        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        if (RetailValueEntry."Cost Amount (Actual)" = 0) and (RetailValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        if (RetailValueEntry."Cost Amount (Actual)" = 0) and (RetailValueEntry."Sales Amount (Actual)" = 0) then
            exit;

        RetailValueEntry.Insert();

        RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    local procedure InsertAppliedValueEntryCostAdjustment(var ApplValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry")
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        SumOfAppliedCostAmounts: Decimal;
        SumOfQty: Integer;
    begin
        if not StdItemLedgerEntry.Get(StdValueEntry."Item Ledger Entry No.") then
            exit;

        FindAppliedItemLedgerEntryCostSum(SumOfAppliedCostAmounts, SumOfQty, StdItemLedgerEntry);

        if Abs(StdValueEntry."Cost per Unit") = Abs(SumOfAppliedCostAmounts / SumOfQty) then
            exit;

        ApplValueEntry.Init();
        ApplValueEntry.Copy(StdValueEntry);
        ApplValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        ApplValueEntry.Description := AppliedValueEntryDescLbl;
        ResetValueEntryAmounts(ApplValueEntry);

        case (SumOfAppliedCostAmounts / SumOfQty) > StdValueEntry."Cost per Unit" of
            true:
                begin
                    ApplValueEntry."Cost per Unit" := (SumOfAppliedCostAmounts / SumOfQty) - StdValueEntry."Cost per Unit";
                    ApplValueEntry."Cost Amount (Actual)" := -Abs(ApplValueEntry."Cost per Unit" * StdValueEntry."Invoiced Quantity");
                end;
            false:
                begin
                    ApplValueEntry."Cost per Unit" := -(StdValueEntry."Cost per Unit" - (SumOfAppliedCostAmounts / SumOfQty));
                    ApplValueEntry."Cost Amount (Actual)" := Abs(ApplValueEntry."Cost per Unit" * StdValueEntry."Invoiced Quantity");
                end;
        end;

        if ApplValueEntry."Cost per Unit" = 0 then
            exit;

        ApplValueEntry."Cost Posted to G/L" := -ApplValueEntry."Cost Amount (Actual)";
        ApplValueEntry.Insert();

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(ApplValueEntry);
    end;

    local procedure InsertReturnAppliedValueEntryCostAdjustment(var ApplValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; ReturnDocumentNo: Code[20])
    var
        StdItemLedgerEntry: Record "Item Ledger Entry";
        ReturnValueEntry: Record "Value Entry";
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        SumOfAppliedCostAmounts: Decimal;
        SumOfQty: Integer;
    begin
        ReturnValueEntry.SetRange("Location Code", TempPOSEntrySalesLines."Location Code");
        ReturnValueEntry.SetRange("Document No.", ReturnDocumentNo);
        ReturnValueEntry.SetRange("Item No.", TempPOSEntrySalesLines."No.");
        if not ReturnValueEntry.FindFirst() then
            exit;
        if not StdItemLedgerEntry.Get(ReturnValueEntry."Item Ledger Entry No.") then
            exit;

        FindAppliedItemLedgerEntryCostSum(SumOfAppliedCostAmounts, SumOfQty, StdItemLedgerEntry);

        if Abs(StdValueEntry."Cost per Unit") = Abs(SumOfAppliedCostAmounts / SumOfQty) then
            exit;

        ApplValueEntry.Init();
        ApplValueEntry.Copy(StdValueEntry);
        ApplValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        ApplValueEntry.Description := AppliedValueEntryDescLbl;
        ResetValueEntryAmounts(ApplValueEntry);

        case (SumOfAppliedCostAmounts / SumOfQty) > StdValueEntry."Cost per Unit" of
            true:
                ApplValueEntry."Cost per Unit" := (SumOfAppliedCostAmounts / SumOfQty) - StdValueEntry."Cost per Unit";
            false:
                ApplValueEntry."Cost per Unit" := -(StdValueEntry."Cost per Unit" - (SumOfAppliedCostAmounts / SumOfQty));
        end;

        if ApplValueEntry."Cost per Unit" = 0 then
            exit;

        ApplValueEntry."Cost Amount (Actual)" := ApplValueEntry."Cost per Unit" * StdValueEntry."Invoiced Quantity";
        ApplValueEntry."Cost Posted to G/L" := ApplValueEntry."Cost Amount (Actual)";
        ApplValueEntry.Insert();

        RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(ApplValueEntry);
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

    local procedure GetRSAccountNoFromSetup(RSGLEntryType: Option VAT,Margin,MarginNoVAT,StdCorrection,CounterStdCorrection): Code[20]
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
            RSGLEntryType::Margin, RSGLEntryType::CounterStdCorrection:
                exit(GetInventoryAccountFromInvPostingSetup(TempPOSEntrySalesLines."Location Code"));
            RSGLEntryType::MarginNoVAT:
                begin
                    LocalizationSetup.TestField("RS Calc. Margin GL Account");
                    exit(LocalizationSetup."RS Calc. Margin GL Account");
                end;
            RSGLEntryType::StdCorrection:
                exit(GetCOGSAccountFromGenPostingSetup());
        end;
    end;

    local procedure CalculateRSGLVATAmount(): Decimal
    begin
        if TempPOSEntrySalesLines."Line Discount %" <> 0 then
            exit(Abs(TempPOSEntrySalesLines."Amount Incl. VAT") * CalculateVATBreakDown())
        else
            exit((PriceListLine."Unit Price" * Abs(TempPOSEntrySalesLines.Quantity)) * CalculateVATBreakDown());
    end;

    local procedure CalculateRSGLMarginAmount(NewValueEntry: Record "Value Entry"; ValueEntryIn: Record "Value Entry"): Decimal
    begin
        exit(NewValueEntry."Cost per Unit" * Abs(ValueEntryIn."Invoiced Quantity") - TempPOSEntrySalesLines."Line Discount Amount Incl. VAT");
    end;

    local procedure CalculateVATBreakDown(): Decimal
    var
        Item: Record Item;
        VATSetup: Record "VAT Posting Setup";
    begin
        if not Item.Get(TempPOSEntrySalesLines."No.") then
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

    local procedure FillRetailPOSEntryLines(POSEntry: Record "NPR POS Entry")
    var
        Location: Record Location;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, 'Item');
        if not POSEntrySalesLine.FindSet() then
            exit;
        repeat
            if Location.Get(POSEntrySalesLine."Location Code") then
                if Location."NPR Retail Location" then begin
                    TempPOSEntrySalesLines.Init();
                    TempPOSEntrySalesLines.Copy(POSEntrySalesLine);
                    TempPOSEntrySalesLines.Insert();
                end;
        until POSEntrySalesLine.Next() = 0;
    end;

    local procedure FindPriceListLine(LocationCode: Code[20]; ItemNo: Code[20])
    var
        PriceListNotFoundErr: Label 'Price for the Location %1 has not been found.', Comment = '%1 - Location Code';
        PriceNotFoundErr: Label 'Price for the Item %1 has not been found in Price List: %2 for Location %3', Comment = '%1 - Item No, %2 - Price List Code, %3 - Location Code';
    begin
        PriceListHeader.SetRange("NPR Location Code", LocationCode);
        if not PriceListHeader.FindFirst() then
            PriceListHeader.SetRange("Assign-to No.", '');
        if not PriceListHeader.FindFirst() then
            Error(PriceListNotFoundErr, LocationCode);

        PriceListLine.SetLoadFields("Unit Price", "VAT Bus. Posting Gr. (Price)");
        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset No.", ItemNo);
        if not PriceListLine.FindFirst() then
            Error(PriceNotFoundErr, ItemNo, PriceListHeader.Code, LocationCode);
    end;

    local procedure FilterPriceListHeader(POSEntry: Record "NPR POS Entry")
    begin
        PriceListHeader.SetLoadFields(Code);
        PriceListHeader.SetRange("Price Type", "Price Type"::Sale);
        PriceListHeader.SetRange(Status, "Price Status"::Active);
        PriceListHeader.SetRange("Assign-to No.", POSEntry."Customer No.");

        PriceListHeader.SetFilter("Starting Date", StrSubstNo(StartingDateFilter, POSEntry."Posting Date"));
        PriceListHeader.SetFilter("Ending Date", StrSubstNo(EndingDateFilter, POSEntry."Posting Date"));
    end;

    local procedure GetInventoryAccountFromInvPostingSetup(LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        Item.Get(TempPOSEntrySalesLines."No.");
        if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
            Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                    InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
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

    local procedure ResetValueEntryAmounts(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry."Cost Amount (Actual)" := 0;
        ValueEntry."Cost Amount (Expected)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)" := 0;
        ValueEntry."Cost Amount (Actual) (ACY)" := 0;
        ValueEntry."Cost Amount (Expected) (ACY)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)(ACY)" := 0;
        ValueEntry."Cost per Unit" := 0;
        ValueEntry."Sales Amount (Actual)" := 0;
        ValueEntry."Sales Amount (Expected)" := 0;
        ValueEntry."Valued Quantity" := 0;
        ValueEntry."Invoiced Quantity" := 0;
        ValueEntry."Item Ledger Entry Quantity" := 0;
    end;

    local procedure FindAppliedItemLedgerEntryCostSum(var SumOfCostAmounts: Decimal; var SumOfQty: Integer; StdItemLedgerEntry: Record "Item Ledger Entry")
    var
        TempApplicationItemLedgerEntry: Record "Item Ledger Entry" temporary;
        ShowAppliedEntries: Codeunit "Show Applied Entries";
        SumOfQtyPerEntry: Integer;
        SumOfCostPerUnit: Decimal;
    begin
        ShowAppliedEntries.FindAppliedEntries(StdItemLedgerEntry, TempApplicationItemLedgerEntry);

        if not TempApplicationItemLedgerEntry.FindSet() then
            exit;

        repeat
            Clear(SumOfCostPerUnit);
            Clear(SumOfQtyPerEntry);
            GetApplicationValueEntryCost(SumOfCostPerUnit, SumOfQtyPerEntry, TempApplicationItemLedgerEntry);
            SumOfCostAmounts += SumOfCostPerUnit * SumOfQtyPerEntry;
            SumOfQty += SumOfQtyPerEntry;
        until TempApplicationItemLedgerEntry.Next() = 0;
    end;

    local procedure GetApplicationValueEntryCost(var SumOfCostPerUnit: Decimal; var SumOfQty: Integer; TempApplicationItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        ValueEntry: Record "Value Entry";
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", TempApplicationItemLedgerEntry."Entry No.");
        if not ValueEntry.FindSet() then
            exit;
        repeat
            case RSRetValueEntryMapp.Get(ValueEntry."Entry No.") of
                true:
                    if RSRetValueEntryMapp."COGS Correction" then begin
                        SumOfCostPerUnit += ValueEntry."Cost per Unit";
                        SumOfQty += Abs(ValueEntry."Invoiced Quantity");
                    end;
                false:
                    begin
                        SumOfCostPerUnit += ValueEntry."Cost per Unit";
                        SumOfQty += Abs(ValueEntry."Invoiced Quantity");
                    end;
            end;
        until ValueEntry.Next() = 0;
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
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        JobLine: Boolean;
        AddCurrencyCode: Code[10];
        AddCurrGLEntryVATAmt: Decimal;
        CurrencyFactor: Decimal;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        EndingDateFilter: Label '>=%1|''''', Comment = '%1 = Ending Date', Locked = true;
        NeedsRoundingErr: Label '%1 needs to be rounded', Comment = '%1 - amount';
        StartingDateFilter: Label '<=%1', Comment = '%1 = Starting Date', Locked = true;
        AppliedValueEntryDescLbl: Label 'COGS Correction';
#endif
}