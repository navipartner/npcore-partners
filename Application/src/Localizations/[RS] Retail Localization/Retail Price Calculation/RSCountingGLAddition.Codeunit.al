codeunit 6151528 "NPR RS Counting GL Addition"
{
    Access = Internal;
    Permissions = tabledata "G/L Entry" = rimd,
                  tabledata "Value Entry" = rimd,
                  tabledata "G/L Register" = rm,
                  tabledata "NPR RS Reason Code Acc. Mapp." = rd;

    #region Eventsubscribers - RS Item Counting Posting Behaviour

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnAfterPostLines', '', false, false)]
    local procedure OnAfterPostLines(var ItemRegNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemRegister: Record "Item Register";
    begin
        if not _RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;
        if not ItemRegister.Get(ItemRegNo) then
            exit;

        ItemLedgerEntry.SetRange("Entry No.", ItemRegister."From Entry No.", ItemRegister."To Entry No.");
        PostCountCalculationEntries(ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Adjust Inv. B", 'OnAfterPostItemJnlLine', '', false, false)]
    local procedure OnAfterPostPOSInventoryAdjustment(var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if not _RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        if TempItemJnlLine."Document No." = '' then
            exit;

        ItemLedgerEntry.SetRange("Document No.", TempItemJnlLine."Document No.");
        ItemLedgerEntry.SetRange("Item No.", TempItemJnlLine."Item No.");
        ItemLedgerEntry.SetRange("Location Code", TempItemJnlLine."Location Code");
        if ItemLedgerEntry.IsEmpty() then
            exit;

        PostCountCalculationEntries(ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforePostInvtPostBuf', '', false, false)]
    local procedure OnBeforePostInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry")
    begin
        RouteCountCounterpartAccount(GenJournalLine, InvtPostingBuffer, ValueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Posting To G/L", 'OnBeforeCheckInvtPostBuf', '', false, false)]
    local procedure OnBeforeCheckInvtPostBuf(var GenJournalLine: Record "Gen. Journal Line"; var InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry")
    begin
        RouteCountCounterpartAccount(GenJournalLine, InvtPostingBuffer, ValueEntry);
    end;

    local procedure RouteCountCounterpartAccount(var GenJournalLine: Record "Gen. Journal Line"; InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry")
    begin
        CheckPostingMethodSupported(InvtPostingBuffer, ValueEntry);

        if InvtPostingBuffer."Account Type" <> InvtPostingBuffer."Account Type"::"Inventory Adjmt." then
            exit;
        if GenJournalLine."Account No." = '' then
            exit;
        if not IsRetailCountCounterpart(ValueEntry) then
            exit;

        GenJournalLine."Account No." := GetCountCounterpartAccount(ValueEntry);
    end;

    local procedure CheckPostingMethodSupported(InvtPostingBuffer: Record "Invt. Posting Buffer"; ValueEntry: Record "Value Entry")
    var
        PostingMethodNotSupportedErr: Label 'Inventory cost cannot be posted to the general ledger per posting group while %1 is enabled, because %2 for a location such as %3 would be summarised without the %4 each entry belongs to. Run %5 again and set %6 to %7.', Comment = '%1 = Enable RS Retail Localization field caption, %2 = Value Entry table caption, %3 = Location Code, %4 = Item table caption, %5 = Post Inventory Cost to G/L report name, %6 = Posting Method option caption, %7 = Per Entry option value';
        PerEntryPostingMethodLbl: Label 'Per Entry';
        PostingMethodOptionLbl: Label 'Posting Method';
        PostInvtCostToGLLbl: Label 'Post Inventory Cost to G/L';
        RSRLocalizationSetup: Record "NPR RS R Localization Setup";
        Item: Record Item;
    begin
        if ValueEntry."Entry No." <> 0 then
            exit;
        if not (InvtPostingBuffer."Account Type" in [InvtPostingBuffer."Account Type"::"Inventory Adjmt."]) and
           not (InvtPostingBuffer."Bal. Account Type" in [InvtPostingBuffer."Bal. Account Type"::"Inventory Adjmt."])
        then
            exit;
        if not _RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;
        if not _RSRLocalizationMgt.IsRetailLocation(InvtPostingBuffer."Location Code") then
            exit;

        Error(PostingMethodNotSupportedErr,
            RSRLocalizationSetup.FieldCaption("Enable RS Retail Localization"),
            ValueEntry.TableCaption(),
            InvtPostingBuffer."Location Code",
            Item.TableCaption(),
            PostInvtCostToGLLbl,
            PostingMethodOptionLbl,
            PerEntryPostingMethodLbl);
    end;

    local procedure IsRetailCountCounterpart(ValueEntry: Record "Value Entry"): Boolean
    begin
        if not (ValueEntry."Item Ledger Entry Type" in ["Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt."]) then
            exit(false);

        if ValueEntry."Entry Type" <> ValueEntry."Entry Type"::"Direct Cost" then
            exit(false);

        if ValueEntry."Item No." = '' then
            exit(false);

        if not _RSRLocalizationMgt.IsRSLocalizationActive() then
            exit(false);

        if not _RSRLocalizationMgt.IsRetailLocation(ValueEntry."Location Code") then
            exit(false);

        exit(not _RSRLocalizationMgt.IsServiceItem(ValueEntry."Item No."));
    end;

    local procedure GetCountCounterpartAccount(ValueEntry: Record "Value Entry"): Code[20]
    var
        ReasonType: Enum "NPR RS Count Reason Type";
        ReasonCode: Code[10];
    begin
        GetAdjustmentReason(ValueEntry, ReasonType, ReasonCode);

        if ValueEntry."Item Ledger Entry Type" = "Item Ledger Entry Type"::"Positive Adjmt." then
            exit(_RSRLocalizationMgt.GetSurplusAccount(ValueEntry."Item No.", ValueEntry."Location Code", ReasonType, ReasonCode));
        exit(_RSRLocalizationMgt.GetShortageAccount(ValueEntry."Item No.", ValueEntry."Location Code", ReasonType, ReasonCode));
    end;

    local procedure GetAdjustmentReason(ValueEntry: Record "Value Entry"; var ReasonType: Enum "NPR RS Count Reason Type"; var ReasonCode: Code[10])
    begin
        if ValueEntry."Reason Code" <> '' then begin
            ReasonType := ReasonType::"Reason Code";
            ReasonCode := ValueEntry."Reason Code";
            exit;
        end;

        ReasonType := ReasonType::"Return Reason";
        ReasonCode := ValueEntry."Return Reason Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reason Code", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ReasonCodeOnAfterDeleteEvent(var Rec: Record "Reason Code"; RunTrigger: Boolean)
    var
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
    begin
        if Rec.IsTemporary() then
            exit;

        if RSReasonCodeAccMapp.Get(RSReasonCodeAccMapp."Reason Type"::"Reason Code", Rec.Code) then
            RSReasonCodeAccMapp.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Return Reason", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ReturnReasonOnAfterDeleteEvent(var Rec: Record "Return Reason"; RunTrigger: Boolean)
    var
        RSReasonCodeAccMapp: Record "NPR RS Reason Code Acc. Mapp.";
    begin
        if Rec.IsTemporary() then
            exit;

        if RSReasonCodeAccMapp.Get(RSReasonCodeAccMapp."Reason Type"::"Return Reason", Rec.Code) then
            RSReasonCodeAccMapp.Delete();
    end;
    #endregion

    #region Item Counting Calculation Posting

    internal procedure PostCountCalculationEntries(var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        RetailValueEntry: Record "Value Entry";
        StdValueEntry: Record "Value Entry";
        RSRetailCalculationType: Enum "NPR RS Retail Calculation Type";
        SourceCodePerDocumentNo: Dictionary of [Code[20], Code[10]];
        MarkupAmountInclVAT: Decimal;
        StandardCostPerUnit: Decimal;
        VATAmount: Decimal;
    begin
        if not _RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;

        ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', "Item Ledger Entry Type"::"Positive Adjmt.", "Item Ledger Entry Type"::"Negative Adjmt.");
        ItemLedgerEntry.SetLoadFields("Item No.", "Location Code", "Posting Date", "Document No.", Quantity);
        if not ItemLedgerEntry.FindSet() then
            exit;

        repeat
            Clear(RetailValueEntry);

            if IsRetailCountAdjustment(ItemLedgerEntry) and FindStandardValueEntry(StdValueEntry, ItemLedgerEntry) then begin
                EnsureCOGSCorrectionMapping(StdValueEntry);

                _RSRLocalizationMgt.GetPriceListLine(_PriceListLine, ItemLedgerEntry."Item No.", ItemLedgerEntry."Location Code", ItemLedgerEntry."Posting Date");

                StandardCostPerUnit := CalculateStandardCostPerUnit(ItemLedgerEntry);
                MarkupAmountInclVAT := _RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculateMarkupInclVAT(ItemLedgerEntry, StandardCostPerUnit), '');
                VATAmount := _RSRLocalizationMgt.RoundAmountToCurrencyRounding(CalculateRSGLVATAmount(ItemLedgerEntry), '');

                InsertRetailValueEntry(RetailValueEntry, StdValueEntry, ItemLedgerEntry, StandardCostPerUnit);
                if RetailValueEntry."Entry No." <> 0 then begin
                    CreateAdditionalGLEntries(RetailValueEntry, ItemLedgerEntry, RSRetailCalculationType::"Margin with VAT", MarkupAmountInclVAT, VATAmount);
                    CreateAdditionalGLEntries(RetailValueEntry, ItemLedgerEntry, RSRetailCalculationType::VAT, MarkupAmountInclVAT, VATAmount);
                    CreateAdditionalGLEntries(RetailValueEntry, ItemLedgerEntry, RSRetailCalculationType::Margin, MarkupAmountInclVAT, VATAmount);

                    if not SourceCodePerDocumentNo.ContainsKey(ItemLedgerEntry."Document No.") then
                        SourceCodePerDocumentNo.Add(ItemLedgerEntry."Document No.", RetailValueEntry."Source Code");
                end;
            end;
        until ItemLedgerEntry.Next() = 0;

        ValidateAndRegisterDocuments(SourceCodePerDocumentNo);
    end;

    local procedure ValidateAndRegisterDocuments(SourceCodePerDocumentNo: Dictionary of [Code[20], Code[10]])
    var
        DocumentNo: Code[20];
    begin
        foreach DocumentNo in SourceCodePerDocumentNo.Keys() do begin
            _RSRLocalizationMgt.ValidateGLEntriesBalanced(DocumentNo);
            _RSRLocalizationMgt.AddGLEntriesToGLRegister(DocumentNo, SourceCodePerDocumentNo.Get(DocumentNo));
        end;
    end;

    local procedure IsRetailCountAdjustment(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    begin
        if ItemLedgerEntry.Quantity = 0 then
            exit(false);

        if not _RSRLocalizationMgt.IsRetailLocation(ItemLedgerEntry."Location Code") then
            exit(false);

        if _RSRLocalizationMgt.IsServiceItem(ItemLedgerEntry."Item No.") then
            exit(false);

        exit(not HasRetailCalculationEntry(ItemLedgerEntry));
    end;

    local procedure FindStandardValueEntry(var StdValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    begin
        StdValueEntry.Reset();
        StdValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        _RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(StdValueEntry, false);
        exit(StdValueEntry.FindFirst());
    end;

    local procedure EnsureCOGSCorrectionMapping(StdValueEntry: Record "Value Entry")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        if RSRetValueEntryMapp.Get(StdValueEntry."Entry No.") then
            exit;

        _RSRLocalizationMgt.InsertCOGSCorrectionValueEntryMappingEntry(StdValueEntry);
    end;

    local procedure HasRetailCalculationEntry(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        _RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, true);
        exit(not ValueEntry.IsEmpty());
    end;

    #endregion

    #region Additional Value Entry Posting

    local procedure InsertRetailValueEntry(var RetailValueEntry: Record "Value Entry"; StdValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; StandardCostPerUnit: Decimal)
    begin
        Clear(RetailValueEntry);
        RetailValueEntry.Init();
        RetailValueEntry.Copy(StdValueEntry);
        RetailValueEntry."Entry No." := StdValueEntry.GetLastEntryNo() + 1;
        _RSRLocalizationMgt.ResetValueEntryAmounts(RetailValueEntry);
        RetailValueEntry."Cost per Unit" := _PriceListLine."Unit Price" - StandardCostPerUnit;
        RetailValueEntry."Cost Amount (Actual)" := _RSRLocalizationMgt.RoundAmountToCurrencyRounding(RetailValueEntry."Cost per Unit" * ItemLedgerEntry.Quantity, '');
        RetailValueEntry."Cost Posted to G/L" := RetailValueEntry."Cost Amount (Actual)";
        RetailValueEntry.Description := _CalculationValueEntryDescLbl;
        RetailValueEntry."Entry Type" := RetailValueEntry."Entry Type"::"NPR RS Retail Calculation";

        if RetailValueEntry."Cost Amount (Actual)" = 0 then begin
            Clear(RetailValueEntry);
            exit;
        end;

        RetailValueEntry.Insert();

        _RSRLocalizationMgt.InsertRetailCalculationValueEntryMappingEntry(RetailValueEntry);
    end;

    local procedure CalculateStandardCostPerUnit(ItemLedgerEntry: Record "Item Ledger Entry"): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetLoadFields("Cost per Unit");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        _RSRLocalizationMgt.SetSynthesisedEntryTypeFilter(ValueEntry, false);
        ValueEntry.CalcSums("Cost per Unit");
        exit(ValueEntry."Cost per Unit");
    end;

    #endregion

    #region GL Entry Posting

    local procedure CreateAdditionalGLEntries(CalculationValueEntry: Record "Value Entry"; ItemLedgerEntry: Record "Item Ledger Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; MarkupAmountInclVAT: Decimal; VATAmount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        InitGenJournalLine(GenJournalLine, CalculationValueEntry, RSRetailCalculationType);
        SetGenJournalLineAmounts(GenJournalLine, ItemLedgerEntry, RSRetailCalculationType, MarkupAmountInclVAT, VATAmount);

        if GenJournalLine.Amount = 0 then
            exit;

        _RSRetailCalcGLPost.PostCalculationGLEntry(GenJournalLine, CalculationValueEntry."Entry No.");
    end;

    local procedure InitGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type")
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GenJournalLine.Init();
        GenJournalLine."Line No." := GenJournalLine.GetNewLineNo('', '');
        GenJournalLine."Document No." := CalculationValueEntry."Document No.";
        GenJournalLine."External Document No." := CalculationValueEntry."External Document No.";
        GenJournalLine."Posting Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Document Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Due Date" := CalculationValueEntry."Posting Date";
        GenJournalLine."Source Code" := CalculationValueEntry."Source Code";
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                GenJournalLine.Description := _GenJnlLineMarginLbl;
            RSRetailCalculationType::Margin:
                GenJournalLine.Description := _GenJnlLineMarginNoVATLbl;
            RSRetailCalculationType::VAT:
                GenJournalLine.Description := _GenJnlLineVATLbl;
        end;
        GenJournalLine."Account No." := GetRSAccountNoFromSetup(CalculationValueEntry, RSRetailCalculationType);
        GenJournalLine."Shortcut Dimension 1 Code" := CalculationValueEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := CalculationValueEntry."Global Dimension 2 Code";
        GenJournalLine."System-Created Entry" := true;

        GLSetup.Get();
        if (GenJournalLine."Document Date" = 0D) and (GLSetup."VAT Reporting Date" = GLSetup."VAT Reporting Date"::"Document Date") then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."Posting Date"
        else
            GenJournalLine."VAT Reporting Date" := GLSetup.GetVATDate(GenJournalLine."Posting Date", GenJournalLine."Document Date");
    end;

    local procedure GetRSAccountNoFromSetup(CalculationValueEntry: Record "Value Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"): Code[20]
    begin
        case RSRetailCalculationType of
            RSRetailCalculationType::"Margin with VAT":
                exit(_RSRLocalizationMgt.GetInventoryAccountFromInvPostingSetup(CalculationValueEntry."Item No.", CalculationValueEntry."Location Code"));
            RSRetailCalculationType::VAT:
                exit(_RSRLocalizationMgt.GetCalcVATAccount(CalculationValueEntry."Item No.", CalculationValueEntry."Location Code"));
            RSRetailCalculationType::Margin:
                exit(_RSRLocalizationMgt.GetCalcMarginAccount(CalculationValueEntry."Item No.", CalculationValueEntry."Location Code"));
        end;
    end;

    local procedure SetGenJournalLineAmounts(var GenJournalLine: Record "Gen. Journal Line"; ItemLedgerEntry: Record "Item Ledger Entry"; RSRetailCalculationType: Enum "NPR RS Retail Calculation Type"; MarkupAmountInclVAT: Decimal; VATAmount: Decimal)
    begin
        if ItemLedgerEntry.Quantity > 0 then
            case RSRetailCalculationType of
                RSRetailCalculationType::"Margin with VAT":
                    GenJournalLine.Validate("Debit Amount", MarkupAmountInclVAT);
                RSRetailCalculationType::VAT:
                    GenJournalLine.Validate("Credit Amount", VATAmount);
                RSRetailCalculationType::Margin:
                    GenJournalLine.Validate("Credit Amount", MarkupAmountInclVAT - VATAmount);
            end
        else
            case RSRetailCalculationType of
                RSRetailCalculationType::"Margin with VAT":
                    GenJournalLine.Validate("Credit Amount", MarkupAmountInclVAT);
                RSRetailCalculationType::VAT:
                    GenJournalLine.Validate("Debit Amount", VATAmount);
                RSRetailCalculationType::Margin:
                    GenJournalLine.Validate("Debit Amount", MarkupAmountInclVAT - VATAmount);
            end;
    end;

    local procedure CalculateMarkupInclVAT(ItemLedgerEntry: Record "Item Ledger Entry"; StandardCostPerUnit: Decimal): Decimal
    begin
        exit((_PriceListLine."Unit Price" - StandardCostPerUnit) * Abs(ItemLedgerEntry.Quantity));
    end;

    local procedure CalculateRSGLVATAmount(ItemLedgerEntry: Record "Item Ledger Entry"): Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("VAT Prod. Posting Group");
        Item.Get(ItemLedgerEntry."Item No.");
        exit((_PriceListLine."Unit Price" * Abs(ItemLedgerEntry.Quantity)) *
             _RSRLocalizationMgt.CalculateVATBreakDown(_PriceListLine."VAT Bus. Posting Gr. (Price)", Item."VAT Prod. Posting Group"));
    end;

    #endregion

    var
        _PriceListLine: Record "Price List Line";
        _RSRetailCalcGLPost: Codeunit "NPR RS Retail Calc. GL Post";
        _RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        _CalculationValueEntryDescLbl: Label 'Calculation';
        _GenJnlLineMarginLbl: Label 'G/L Calculation Margin';
        _GenJnlLineMarginNoVATLbl: Label 'G/L Calculation Margin Excl. VAT';
        _GenJnlLineVATLbl: Label 'G/L Calculation VAT';
}
