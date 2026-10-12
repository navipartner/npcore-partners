codeunit 85515 "NPR DE DSFINVK Export Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _VATProdPostingGroupTxt: Label 'DSFVK-PROD', Locked = true;
        _VATBusPostingGroupTxt: Label 'DSFVK-BUS', Locked = true;
        _VATIdentifierTxt: Label 'DSFVK19', Locked = true;
        _POSUnitNoTxt: Label 'DSFVKTEST', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineAmountsPerVatIdHoldOnlyThatLine()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        Lines: JsonArray;
        LineAmounts: List of [Decimal];
        LineAmountsPerVatId: JsonArray;
        LineToken: JsonToken;
        LineInclVatSum: Decimal;
        LineIndex: Integer;
    begin
        // [Scenario] A DE receipt with several sales lines is exported to DSFinV-K. Each line's
        //            business_case.amounts_per_vat_id maps to that line's Bonpos_USt record, so it
        //            must carry only that line's amounts - not a running total of the receipt.

        // [GIVEN] a fiscalized POS entry with three sales lines on the same VAT rate
        LineAmounts.Add(10);
        LineAmounts.Add(20);
        LineAmounts.Add(30);
        CreateFiscalizedPOSEntry(DSFINVKClosing, LineAmounts);

        // [WHEN] the DSFinV-K cash point closing document is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] each line has exactly one VAT entry holding that line's own gross amount
        Lines := GetSingleTransactionData(DSFINVKJson).GetArray('lines');
        _Assert.AreEqual(LineAmounts.Count(), Lines.Count(), 'One DSFinV-K line per sales line expected.');
        for LineIndex := 1 to Lines.Count() do begin
            Lines.Get(LineIndex - 1, LineToken);
            LineAmountsPerVatId := LineToken.AsObject().GetObject('business_case').GetArray('amounts_per_vat_id');
            _Assert.AreEqual(1, LineAmountsPerVatId.Count(), StrSubstNo('Line %1 must carry only its own VAT entry.', LineIndex));
            _Assert.AreEqual(LineAmounts.Get(LineIndex), GetInclVat(LineAmountsPerVatId, 0), StrSubstNo('Line %1 incl_vat must equal its own amount.', LineIndex));
            LineInclVatSum += GetInclVat(LineAmountsPerVatId, 0);
        end;

        // [THEN] the line amounts reconcile with the transaction's VAT breakdown
        _Assert.AreEqual(GetInclVat(GetSingleTransactionData(DSFINVKJson).GetArray('amounts_per_vat_id'), 0), LineInclVatSum, 'Sum of line incl_vat must equal the transaction incl_vat.');
    end;

    local procedure CreateFiscalizedPOSEntry(var DSFINVKClosing: Record "NPR DSFINVK Closing"; LineAmounts: List of [Decimal])
    var
        DEAuditLog: Record "NPR DE POS Audit Log Aux. Info";
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        VATPostGroupMapper: Record "NPR VAT Post. Group Mapper";
        ClosingDate: Date;
        LineAmount: Decimal;
        TotalAmount: Decimal;
        LineNo: Integer;
    begin
        // A date no other test posts on, so the export only picks up this entry.
        ClosingDate := DMY2Date(15, 3, 2003);
        POSEntry.SetRange("Entry Date", ClosingDate);
        POSEntry.DeleteAll();

        if not VATPostGroupMapper.Get(_VATProdPostingGroupTxt, _VATBusPostingGroupTxt) then begin
            VATPostGroupMapper.Init();
            VATPostGroupMapper."VAT Prod. Pos. Group" := _VATProdPostingGroupTxt;
            VATPostGroupMapper."VAT Bus. Posting Group" := _VATBusPostingGroupTxt;
            VATPostGroupMapper.Insert();
        end;
        VATPostGroupMapper."VAT Identifier" := _VATIdentifierTxt;
        VATPostGroupMapper."DSFINVK ID" := 1;
        VATPostGroupMapper.Modify();

        if not DEPOSUnitAuxInfo.Get(_POSUnitNoTxt) then begin
            DEPOSUnitAuxInfo.Init();
            DEPOSUnitAuxInfo."POS Unit No." := _POSUnitNoTxt;
            DEPOSUnitAuxInfo.Insert();
        end;

        foreach LineAmount in LineAmounts do
            TotalAmount += LineAmount;

        POSEntry.Init();
        POSEntry."Entry Date" := ClosingDate;
        POSEntry."Fiscal No." := 'DSFVK-0001';
        POSEntry."Amount Incl. Tax" := TotalAmount;
        POSEntry.Insert();

        DEAuditLog.Init();
        DEAuditLog."POS Entry No." := POSEntry."Entry No.";
        DEAuditLog."Transaction ID" := CreateGuid();
        DEAuditLog."Client ID" := CreateGuid();
        DEAuditLog."Start Time" := CreateDateTime(ClosingDate, 100000T);
        DEAuditLog."Finish Time" := CreateDateTime(ClosingDate, 100100T);
        DEAuditLog.Insert();

        foreach LineAmount in LineAmounts do begin
            LineNo += 10000;
            POSEntrySalesLine.Init();
            POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
            POSEntrySalesLine."Line No." := LineNo;
            POSEntrySalesLine.Type := POSEntrySalesLine.Type::Item;
            POSEntrySalesLine."No." := 'DSFVK-ITEM';
            POSEntrySalesLine.Quantity := 1;
            POSEntrySalesLine."Unit Price" := LineAmount;
            POSEntrySalesLine."VAT Prod. Posting Group" := _VATProdPostingGroupTxt;
            POSEntrySalesLine."VAT Bus. Posting Group" := _VATBusPostingGroupTxt;
            POSEntrySalesLine."Amount Incl. VAT (LCY)" := LineAmount;
            POSEntrySalesLine."Amount Excl. VAT (LCY)" := Round(LineAmount / 1.19);
            POSEntrySalesLine.Insert();
        end;

        POSEntryTaxLine.Init();
        POSEntryTaxLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryTaxLine."VAT Identifier" := _VATIdentifierTxt;
        POSEntryTaxLine."Amount Including Tax" := TotalAmount;
        POSEntryTaxLine."Tax Base Amount" := Round(TotalAmount / 1.19);
        POSEntryTaxLine."Tax Amount" := TotalAmount - POSEntryTaxLine."Tax Base Amount";
        POSEntryTaxLine.Insert();

        DSFINVKClosing."POS Unit No." := _POSUnitNoTxt;
        DSFINVKClosing."Closing Date" := ClosingDate;
        DSFINVKClosing."DSFINVK Closing No." := 1;
    end;

    local procedure GetSingleTransactionData(DSFINVKJson: JsonObject): JsonObject
    var
        Transactions: JsonArray;
        TransactionToken: JsonToken;
    begin
        Transactions := DSFINVKJson.GetArray('transactions');
        _Assert.AreEqual(1, Transactions.Count(), 'Exactly one exported transaction expected.');
        Transactions.Get(0, TransactionToken);
        exit(TransactionToken.AsObject().GetObject('data'));
    end;

    local procedure GetInclVat(AmountsPerVatId: JsonArray; Index: Integer) InclVat: Decimal
    var
        AmountToken: JsonToken;
    begin
        AmountsPerVatId.Get(Index, AmountToken);
        Evaluate(InclVat, AmountToken.AsObject().GetText('incl_vat'), 9);
    end;
}
