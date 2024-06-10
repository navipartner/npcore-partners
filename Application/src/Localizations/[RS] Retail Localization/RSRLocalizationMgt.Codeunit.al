codeunit 6151490 "NPR RS R Localization Mgt."
{
    Access = Internal;
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
        Location: Record Location;
    begin
        if not IsRSLocalizationActive() then
            exit;
        PurchInvLines.SetLoadFields("Document No.", "Location Code");
        PurchInvLines.SetRange("Document No.", PostedPurchInvHdr."No.");
        if not PurchInvLines.FindSet() then
            exit;
        repeat
            case true of
                PurchInvLines."Location Code" <> '':
                    begin
                        if Location.Get(PurchInvLines."Location Code") then
                            RetailLocationCodeExists := Location."NPR Retail Location";
                        if RetailLocationCodeExists then
                            exit;
                    end;
            end;
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

    internal procedure RoundAmountToCurrencyRounding(Amount: Decimal; GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        Currency: Record Currency;
    begin
        if (GenJnlLine."Currency Code" = '') then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(GenJnlLine."Currency Code");
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

    #endregion RS Retail Localization Helper Procedures
}