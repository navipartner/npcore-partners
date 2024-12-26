codeunit 6151490 "NPR RS R Localization Mgt."
{
    Access = Internal;
    Permissions = tabledata "G/L Register" = rimd;

    internal procedure IsRSLocalizationActive(): Boolean
    var
        RSRetLocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        if not RSRetLocalizationSetup.Get() then begin
            RSRetLocalizationSetup.Init();
            RSRetLocalizationSetup.Insert();
        end;
        exit(RSRetLocalizationSetup."Enable RS Retail Localization");
    end;

    #region RS Retail Lcl. Mgt. - Posted Purch. Invoice Action Mgt.
    internal procedure CheckForRetailLocationLines(PostedPurchInvHdr: Record "Purch. Inv. Header") RetailLocationCodeExists: Boolean
    var
        PurchInvLines: Record "Purch. Inv. Line";
    begin
        if not IsRSLocalizationActive() then
            exit;
        PurchInvLines.SetLoadFields("Document No.", "Location Code");
        PurchInvLines.SetRange("Document No.", PostedPurchInvHdr."No.");
        PurchInvLines.SetFilter("Location Code", '<>%1', '');
        if PurchInvLines.IsEmpty() then
            exit;

        PurchInvLines.FindSet();
        repeat
            if IsRetailLocation(PurchInvLines."Location Code") then begin
                RetailLocationCodeExists := true;
                exit;
            end
        until PurchInvLines.Next() = 0;
    end;
    #endregion

    #region RS Retail Lcl. Mgt. - Sales Price List Lines Mgt.
    internal procedure RetailCheckForModifyActiveLine(PrevPriceListLine: Record "Price List Line")
    var
        ActivePriceListLineModifyNotAllowedErr: Label 'You cannot edit a verified Price List Line.';
    begin
        if not IsRSLocalizationActive() then
            exit;
        if PrevPriceListLine.Status = "Price Status"::Active then
            Error(ActivePriceListLineModifyNotAllowedErr);
    end;

    internal procedure RetailCheckForDeleteActiveLine(PrevPriceListLine: Record "Price List Line")
    var
        ActivePriceListLineDeleteNotAllowedErr: Label 'You cannot remove a verified Price List Line.';
    begin
        if not IsRSLocalizationActive() then
            exit;
        if PrevPriceListLine."Unit Price" = 0 then
            exit;
        if PrevPriceListLine.Status = "Price Status"::Active then
            Error(ActivePriceListLineDeleteNotAllowedErr);
    end;
    #endregion

    #region RS Retail Lcl. Mgt. - Sales Line Retail Price Mgt.
    internal procedure GetPriceFromSalesPriceList(var SalesLine: Record "Sales Line")
    var
        RSSalesLineRetailCalc: Codeunit "NPR RS Sales Line Retail Cal.";
    begin
        if not IsRSLocalizationActive() then
            exit;
        RSSalesLineRetailCalc.GetPriceFromSalesPriceList(SalesLine);
    end;
    #endregion

    #region RS Retail Value Entry Mapping Mgt.

    internal procedure InsertRetailCalculationValueEntryMappingEntry(ValueEntry: Record "Value Entry")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        RSRetValueEntryMapp.Init();
        RSRetValueEntryMapp."Entry Type" := ValueEntry."Entry Type";
        RSRetValueEntryMapp."Entry No." := ValueEntry."Entry No.";
        RSRetValueEntryMapp."Item No." := ValueEntry."Item No.";
        RSRetValueEntryMapp."Document Type" := ValueEntry."Document Type";
        RSRetValueEntryMapp."Document No." := ValueEntry."Document No.";
        RSRetValueEntryMapp."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type";
        RSRetValueEntryMapp."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
        RSRetValueEntryMapp."Location Code" := ValueEntry."Location Code";
        RSRetValueEntryMapp."Retail Calculation" := true;
        RSRetValueEntryMapp.Insert();
    end;

    internal procedure InsertNivelationValueEntryMappingEntry(ValueEntry: Record "Value Entry")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        RSRetValueEntryMapp.Init();
        RSRetValueEntryMapp."Entry Type" := ValueEntry."Entry Type";
        RSRetValueEntryMapp."Entry No." := ValueEntry."Entry No.";
        RSRetValueEntryMapp."Item No." := ValueEntry."Item No.";
        RSRetValueEntryMapp."Document Type" := ValueEntry."Document Type";
        RSRetValueEntryMapp."Document No." := ValueEntry."Document No.";
        RSRetValueEntryMapp."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type";
        RSRetValueEntryMapp."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
        RSRetValueEntryMapp."Location Code" := ValueEntry."Location Code";
        RSRetValueEntryMapp.Nivelation := true;
        RSRetValueEntryMapp.Insert();
    end;

    internal procedure InsertCOGSCorrectionValueEntryMappingEntry(ValueEntry: Record "Value Entry")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        RSRetValueEntryMapp.Init();
        RSRetValueEntryMapp."Entry Type" := ValueEntry."Entry Type";
        RSRetValueEntryMapp."Entry No." := ValueEntry."Entry No.";
        RSRetValueEntryMapp."Item No." := ValueEntry."Item No.";
        RSRetValueEntryMapp."Document Type" := ValueEntry."Document Type";
        RSRetValueEntryMapp."Document No." := ValueEntry."Document No.";
        RSRetValueEntryMapp."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type";
        RSRetValueEntryMapp."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
        RSRetValueEntryMapp."Location Code" := ValueEntry."Location Code";
        RSRetValueEntryMapp."COGS Correction" := true;
        RSRetValueEntryMapp.Open := true;
        RSRetValueEntryMapp."Remaining Quantity" := Abs(ValueEntry."Invoiced Quantity");
        RSRetValueEntryMapp.Insert();
    end;

    internal procedure InsertStdCorrectionValueEntryMappingEntry(ValueEntry: Record "Value Entry")
    var
        RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp.";
    begin
        RSRetValueEntryMapp.Init();
        RSRetValueEntryMapp."Entry Type" := ValueEntry."Entry Type";
        RSRetValueEntryMapp."Entry No." := ValueEntry."Entry No.";
        RSRetValueEntryMapp."Document Type" := ValueEntry."Document Type";
        RSRetValueEntryMapp."Document No." := ValueEntry."Document No.";
        RSRetValueEntryMapp."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type";
        RSRetValueEntryMapp."Item Ledger Entry No." := ValueEntry."Item Ledger Entry No.";
        RSRetValueEntryMapp."Location Code" := ValueEntry."Location Code";
        RSRetValueEntryMapp."Standard Correction" := true;
        RSRetValueEntryMapp.Insert();
    end;

    internal procedure SubRetValueEntryMappingRemainingQty(var RSRetValueEntryMapp: Record "NPR RS Ret. Value Entry Mapp."; QuantityToSubtract: Decimal)
    begin
        RSRetValueEntryMapp."Remaining Quantity" -= QuantityToSubtract;
        if RSRetValueEntryMapp."Remaining Quantity" = 0 then
            RSRetValueEntryMapp.Open := false;
        RSRetValueEntryMapp.Modify();
    end;

    #endregion RS Retail Value Entry Mapping Mgt.

    #region RS Retail Localization Helper Procedures

    internal procedure GetInventoryAccountFromInvPostingSetup(ItemNo: Code[20]; LocationCode: Code[10]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Item: Record Item;
        InvPostingSetupNotFoundErr: Label '%1 for %2 : %3 and %4 : %5 not found.', Comment = '%1 = Inventory Posting Setup Table Caption, %2 = Location Code Field Caption %3 = Location Code, %4 = Invt. Posting Group Code Field Caption, %5 = Inventory Posting Group';
    begin
        Item.Get(ItemNo);
        if not InventoryPostingSetup.Get(LocationCode, Item."Inventory Posting Group") then
            Error(InvPostingSetupNotFoundErr, InventoryPostingSetup.TableCaption(), InventoryPostingSetup.FieldCaption("Location Code"), LocationCode,
                    InventoryPostingSetup.FieldCaption("Invt. Posting Group Code"), Item."Inventory Posting Group");
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    internal procedure InsertGLItemLedgerRelations(ValueEntry: Record "Value Entry"; GLAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetLoadFields("Entry No.");
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Document No.", ValueEntry."Document No.");
        if GLEntry.IsEmpty() then
            exit;

        GLEntry.FindSet();
        repeat
            InsertGLItemLedgerRelation(GLEntry."Entry No.", ValueEntry."Entry No.");
        until GLEntry.Next() = 0;
    end;

    local procedure InsertGLItemLedgerRelation(GLEntryNo: Integer; ValueEntryNo: Integer)
    var
        GLRegister: Record "G/L Register";
        GLItemLedgerRelation: Record "G/L - Item Ledger Relation";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlPostLine.GetGLReg(GLRegister);
        if not GLItemLedgerRelation.Get(GLEntryNo, ValueEntryNo) then begin
            GLItemLedgerRelation.Init();
            GLItemLedgerRelation."Value Entry No." := ValueEntryNo;
            GLItemLedgerRelation."G/L Register No." := GLRegister."No.";

            GLItemLedgerRelation."G/L Entry No." := GLEntryNo;
            GLItemLedgerRelation.Insert(true);
        end;
    end;

    internal procedure ResetValueEntryAmounts(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry."Cost Amount (Actual)" := 0;
        ValueEntry."Cost Amount (Expected)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)" := 0;
        ValueEntry."Cost Amount (Actual) (ACY)" := 0;
        ValueEntry."Cost Amount (Expected) (ACY)" := 0;
        ValueEntry."Cost Amount (Non-Invtbl.)(ACY)" := 0;
        ValueEntry."Sales Amount (Actual)" := 0;
        ValueEntry."Sales Amount (Expected)" := 0;
        ValueEntry."Valued Quantity" := 0;
        ValueEntry."Invoiced Quantity" := 0;
        ValueEntry."Item Ledger Entry Quantity" := 0;
        ValueEntry."Cost per Unit" := 0;
    end;

    internal procedure CopyValueEntryAmounts(FromValueEntry: Record "Value Entry"; var ToValueEntry: Record "Value Entry")
    begin
        ToValueEntry."Cost Amount (Actual)" := FromValueEntry."Cost Amount (Actual)";
        ToValueEntry."Cost Amount (Expected)" := FromValueEntry."Cost Amount (Expected)";
        ToValueEntry."Cost Amount (Non-Invtbl.)" := FromValueEntry."Cost Amount (Non-Invtbl.)";
        ToValueEntry."Cost Amount (Actual) (ACY)" := FromValueEntry."Cost Amount (Actual) (ACY)";
        ToValueEntry."Cost Amount (Expected) (ACY)" := FromValueEntry."Cost Amount (Expected) (ACY)";
        ToValueEntry."Cost Amount (Non-Invtbl.)(ACY)" := FromValueEntry."Cost Amount (Non-Invtbl.)(ACY)";
        ToValueEntry."Sales Amount (Actual)" := FromValueEntry."Sales Amount (Actual)";
        ToValueEntry."Sales Amount (Expected)" := FromValueEntry."Sales Amount (Expected)";
        ToValueEntry."Valued Quantity" := FromValueEntry."Valued Quantity";
        ToValueEntry."Invoiced Quantity" := FromValueEntry."Invoiced Quantity";
        ToValueEntry."Item Ledger Entry Quantity" := FromValueEntry."Item Ledger Entry Quantity";
        ToValueEntry."Cost Posted to G/L" := FromValueEntry."Cost Amount (Actual)";
        ToValueEntry."Cost per Unit" := FromValueEntry."Cost per Unit";
    end;

    internal procedure ReverseSignOnValueEntry(var ValueEntry: Record "Value Entry")
    begin
        ValueEntry."Sales Amount (Actual)" := -ValueEntry."Sales Amount (Actual)";
        ValueEntry."Sales Amount (Expected)" := -ValueEntry."Sales Amount (Expected)";
        ValueEntry."Cost Amount (Actual)" := -ValueEntry."Cost Amount (Actual)";
        ValueEntry."Cost Amount (Expected)" := -ValueEntry."Cost Amount (Expected)";
        ValueEntry."Cost Amount (Actual) (ACY)" := -ValueEntry."Cost Amount (Actual) (ACY)";
        ValueEntry."Cost Amount (Expected) (ACY)" := -ValueEntry."Cost Amount (Expected) (ACY)";
        ValueEntry."Cost Amount (Non-Invtbl.)" := -ValueEntry."Cost Amount (Non-Invtbl.)";
        ValueEntry."Cost Amount (Non-Invtbl.)(ACY)" := -ValueEntry."Cost Amount (Non-Invtbl.)(ACY)";
        ValueEntry."Valued Quantity" := -ValueEntry."Valued Quantity";
        ValueEntry."Invoiced Quantity" := -ValueEntry."Invoiced Quantity";
        ValueEntry."Item Ledger Entry Quantity" := -ValueEntry."Item Ledger Entry Quantity";
        ValueEntry."Cost Posted to G/L" := -ValueEntry."Cost Posted to G/L";
    end;

    internal procedure RoundAmountToCurrencyRounding(Amount: Decimal; CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        if (CurrencyCode = '') then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;

        exit(Round(Amount, Currency."Amount Rounding Precision"));
    end;

    internal procedure CalculateVATBreakDown(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATPostingSetupNotFoundErr: Label '%1 has not been found for %2:%3, %4:%5', Comment = '%1 = VAT Posting Setup, %2 = VAT Bus. Post. Gr. Caption , %3 = VAT Bus. Post. Gr., %4 = VAT Prod. Post. Gr. Caption, %5 = VAT Prod. Post. Gr.';
    begin
        if not VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
            Error(VATPostingSetupNotFoundErr, VATPostingSetup.TableCaption, VATPostingSetup.FieldCaption("VAT Bus. Posting Group"), VATBusPostingGroup, VATPostingSetup.FieldCaption("VAT Prod. Posting Group"), VATProdPostingGroup);
        exit((100 * VATPostingSetup."VAT %") / (100 + VATPostingSetup."VAT %") / 100);
    end;

    internal procedure AddGLEntriesToGLRegister(DocumentNo: Code[20]; SourceCode: Code[10])
    var
        GLEntry: Record "G/L Entry";
        GLRegister: Record "G/L Register";
        FromEntryNo: Integer;
        ToEntryNo: Integer;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        if not GLEntry.FindFirst() then
            exit;
        FromEntryNo := GLEntry."Entry No.";
        GLEntry.FindLast();
        ToEntryNo := GLEntry."Entry No.";

        GLRegister.Init();
        GLRegister."No." := GLRegister.GetLastEntryNo() + 1;
#if not (BC23 or BC24)
        GLRegister."Creation Date" := Today();
        GLRegister."Creation Time" := Time();
#endif
        GLRegister."Source Code" := SourceCode;
        GLRegister."From Entry No." := FromEntryNo;
        GLRegister."To Entry No." := ToEntryNo;
        GLRegister."User ID" := CopyStr(UserId(), 1, MaxStrLen(GLRegister."User ID"));
        GLRegister.Insert();
    end;

    internal procedure IsServiceItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        exit(Item.Type in [Item.Type::Service]);
    end;

    internal procedure IsRetailLocation(LocationCode: Code[20]): Boolean
    var
        Location: Record Location;
    begin
        if not Location.Get(LocationCode) then
            exit(false);
        exit(Location."NPR Retail Location");
    end;

    internal procedure ValidateGLEntriesBalanced(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        GenLedgerNotBalancedErr: Label 'You cannot post document %1 right now. If you proceed, the General Ledger will become imbalanced. Current sum of amounts in General Ledger is %2. This is an issue with RS Retail Localization, please contact your administrator for further guidance.', Comment = '%1 = Document No., %2 = Amount';
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.CalcSums(Amount);
        if GLEntry.Amount <> 0 then
            Error(GenLedgerNotBalancedErr, DocumentNo, GLEntry.Amount);
    end;
    #endregion RS Retail Localization Helper Procedures
}