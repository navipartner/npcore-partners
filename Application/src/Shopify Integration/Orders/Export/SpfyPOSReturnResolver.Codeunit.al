codeunit 6151315 "NPR Spfy POS Return Resolver"
{
    Access = Internal;

    procedure Resolve(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        EntryCurrency: Code[10];
        StoreCurrency: Code[10];
        EntryCurrencyReason: Text;
        EntryCurrencyLbl: Label 'The POS entry is in %1 while the Shopify store uses %2; refunds in another currency are not supported yet.', Comment = '%1 = POS entry currency, %2 = Shopify store currency';
    begin
        ReturnLineBuf.Reset();
        ReturnLineBuf.DeleteAll();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '<%1', 0);
        if POSEntrySalesLine.IsEmpty() then
            exit;
        if not CurrencyMatchesStore(POSEntry, ShopifyStoreCode, EntryCurrency, StoreCurrency) then
            EntryCurrencyReason := StrSubstNo(EntryCurrencyLbl, EntryCurrency, StoreCurrency);
        if POSEntrySalesLine.FindSet() then
            repeat
                if not IsPayInOrPayOut(POSEntrySalesLine) then begin
                    ReturnLineBuf.Init();
                    ReturnLineBuf."POS Entry No." := POSEntrySalesLine."POS Entry No.";
                    ReturnLineBuf."Line No." := POSEntrySalesLine."Line No.";
                    ReturnLineBuf."Is Item Line" := POSEntrySalesLine.Type = POSEntrySalesLine.Type::Item;
                    ReturnLineBuf."Item No." := POSEntrySalesLine."No.";
                    ReturnLineBuf."Variant Code" := POSEntrySalesLine."Variant Code";
                    ReturnLineBuf.Quantity := Round(Abs(POSEntrySalesLine.Quantity), 1, '>');
                    // Sign kept: a negative-priced line taken back is money the customer pays, not money refunded.
                    ReturnLineBuf."Amount Incl. VAT" := -POSEntrySalesLine."Amount Incl. VAT";
                    ReturnLineBuf."Unit Price" := POSEntrySalesLine."Unit Price";
                    ReturnLineBuf."Line Title" := CopyStr(SpfyPOSEntryExportMgt.GetLineItemTitle(POSEntrySalesLine), 1, MaxStrLen(ReturnLineBuf."Line Title"));
                    ReturnLineBuf."Original Line SystemId" := POSEntrySalesLine."Orig.POS Entry S.Line SystemId";
                    ReturnLineBuf."Return Reason Code" := POSEntrySalesLine."Return Reason Code";
                    ResolveCase(POSEntrySalesLine, ShopifyStoreCode, EntryCurrencyReason, ReturnLineBuf);
                    ReturnLineBuf.Insert();
                end;
            until POSEntrySalesLine.Next() = 0;
    end;

    procedure HasReturnLines(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '<%1', 0);
        if POSEntrySalesLine.FindSet() then
            repeat
                if not IsPayInOrPayOut(POSEntrySalesLine) then
                    exit(true);
            until POSEntrySalesLine.Next() = 0;
        exit(false);
    end;

    // The POS writes pay-ins and pay-outs as Payout lines, or as G/L Account lines when the account's posting type is not Purchase. A G/L Account line without an origin (a pay-in, a pay-out or an imported invoice's G/L line) can never be refunded on a Shopify order; one with an origin is a reversed sale line.
    local procedure IsPayInOrPayOut(POSEntrySalesLine: Record "NPR POS Entry Sales Line"): Boolean
    begin
        if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Payout then
            exit(true);
        exit((POSEntrySalesLine.Type = POSEntrySalesLine.Type::"G/L Account") and IsNullGuid(POSEntrySalesLine."Orig.POS Entry S.Line SystemId"));
    end;

    procedure HasSaleLines(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Quantity, '>%1', 0);
        exit(not POSEntrySalesLine.IsEmpty());
    end;

    procedure HasPendingLines(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]): Boolean
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
    begin
        Resolve(POSEntry, ShopifyStoreCode, TempReturnLineBuf);
        TempReturnLineBuf.SetRange("Return Case", TempReturnLineBuf."Return Case"::Pending);
        exit(not TempReturnLineBuf.IsEmpty());
    end;

    /// <summary>Whether the scheduler is still going to send the original sale; when it is not, NotSentReason says why.</summary>
    local procedure IsExpectedToBeSent(OriginalPOSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]; var NotSentReason: Text): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        NotEligibleLbl: Label 'it is not eligible for Shopify: it is a %1, it has no %2, or its %3 is neither %4 nor %5', Comment = '%1 = System Entry field caption, %2 = Customer No. field caption, %3 = Entry Type field caption, %4 = Direct Sale entry type, %5 = Credit Sale entry type';
        NoSaleLinesLbl: Label 'it has no sale lines';
        CustomerNotLinkedLbl: Label 'its customer has no %1 for the Shopify store', Comment = '%1 = Shopify Store-Customer Link table caption';
        CustomerNotSyncedLbl: Label 'its customer''s %1 is not set for the Shopify store', Comment = '%1 = Sync. with Store field caption';
        BeforeCutOffLbl: Label 'it was made before the store''s %1 (%2)', Comment = '%1 = Histor.POS Trans. Cut-Off Date field caption, %2 = cut-off date';
        PassedLbl: Label 'the scheduler passed it without sending it (its Shopify task was closed without sending, or it was skipped as historical)';
    begin
        NotSentReason := '';
        // The scheduler sends an original by the line-based rule, so a queued zero-total exchange must still count as expected.
        if not SpfyPOSEntryExportMgt.IsEligibleForSync(OriginalPOSEntry, true) then begin
            NotSentReason := StrSubstNo(NotEligibleLbl, OriginalPOSEntry.FieldCaption("System Entry"), OriginalPOSEntry.FieldCaption("Customer No."), OriginalPOSEntry.FieldCaption("Entry Type"),
                Format(OriginalPOSEntry."Entry Type"::"Direct Sale"), Format(OriginalPOSEntry."Entry Type"::"Credit Sale"));
            exit(false);
        end;
        if not HasSaleLines(OriginalPOSEntry) then begin
            NotSentReason := NoSaleLinesLbl;
            exit(false);
        end;
        if not SpfyStoreCustomerLink.Get(SpfyStoreCustomerLink.Type::Customer, OriginalPOSEntry."Customer No.", ShopifyStoreCode) then begin
            NotSentReason := StrSubstNo(CustomerNotLinkedLbl, SpfyStoreCustomerLink.TableCaption());
            exit(false);
        end;
        if not SpfyStoreCustomerLink."Sync. to this Store" then begin
            NotSentReason := StrSubstNo(CustomerNotSyncedLbl, SpfyStoreCustomerLink.FieldCaption("Sync. to this Store"));
            exit(false);
        end;
        ShopifyStore.Get(ShopifyStoreCode);
        if (ShopifyStore."Historical Data Cut-Off Date" <> 0D) and (OriginalPOSEntry."Entry Date" < ShopifyStore."Historical Data Cut-Off Date") then begin
            NotSentReason := StrSubstNo(BeforeCutOffLbl, ShopifyStore.FieldCaption("Historical Data Cut-Off Date"), ShopifyStore."Historical Data Cut-Off Date");
            exit(false);
        end;
        if SpfyTaskQueue.OutstandingTasksExist(Database::"NPR POS Entry", Format(OriginalPOSEntry."Entry No."), ShopifyStoreCode) then
            exit(true);
        ShopifyStore.CalcFields("Last POS Entry Row Version");
        if OriginalPOSEntry.SystemRowVersion > ShopifyStore."Last POS Entry Row Version" then
            exit(true);
        NotSentReason := PassedLbl;
        exit(false);
    end;

    /// <summary>Identifies this entry's refund on a Shopify order; a retry matches it exactly, whatever reasons follow it in the note.</summary>
    procedure NoteMarker(POSEntryNo: Integer; DocumentNo: Code[20]): Text
    var
        MarkerLbl: Label 'POS Return %1/%2', Locked = true;
    begin
        exit(StrSubstNo(MarkerLbl, POSEntryNo, DocumentNo));
    end;

    /// <summary>The marker followed by the distinct return reasons of the refunded lines, in line order, and how the money went back.</summary>
    procedure RefundNote(Marker: Text; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; PaidBackMethods: Text): Text
    var
        ReturnReason: Record "Return Reason";
        Reasons: List of [Text];
        Reason: Text;
        Separator: Text;
        Note: TextBuilder;
        PaidBackLbl: Label 'paid back as %1', Locked = true;
    begin
        ReturnReason.SetLoadFields(Description);
        if ReturnLineBuf.FindSet() then
            repeat
                if (ReturnLineBuf."Refund Quantity" > 0) and (ReturnLineBuf."Return Reason Code" <> '') then begin
                    Reason := ReturnLineBuf."Return Reason Code";
                    if ReturnReason.Get(ReturnLineBuf."Return Reason Code") then
                        if ReturnReason.Description <> '' then
                            Reason := ReturnReason.Description;
                    if not Reasons.Contains(Reason) then
                        Reasons.Add(Reason);
                end;
            until ReturnLineBuf.Next() = 0;

        Note.Append(Marker);
        Separator := ': ';
        foreach Reason in Reasons do begin
            Note.Append(Separator + Reason);
            Separator := ', ';
        end;
        // Shopify records the refund on the original sale's gateway whatever is sent, so the note is the only place that says how the money went back.
        if PaidBackMethods <> '' then begin
            if Reasons.Count() > 0 then
                Separator := '; ';
            Note.Append(Separator + StrSubstNo(PaidBackLbl, PaidBackMethods));
        end;
        exit(Note.ToText());
    end;

    /// <summary>The payment methods whose lines on the entry net below zero, in line order, by the method's description or its code.</summary>
    procedure PaidBackAs(POSEntry: Record "NPR POS Entry"): Text
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        NetAmounts: Dictionary of [Code[10], Decimal];
        MethodCodes: List of [Code[10]];
        MethodCode: Code[10];
        Separator: Text;
        Result: TextBuilder;
    begin
        // Netted per method, so change handed back on an over-tender does not count. Named by the payment method, never the line, whose description can carry a voucher or card number.
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetLoadFields("POS Payment Method Code", "Amount (Sales Currency)");
        if POSEntryPaymentLine.FindSet() then
            repeat
                MethodCode := POSEntryPaymentLine."POS Payment Method Code";
                if NetAmounts.ContainsKey(MethodCode) then
                    NetAmounts.Set(MethodCode, NetAmounts.Get(MethodCode) + POSEntryPaymentLine."Amount (Sales Currency)")
                else begin
                    NetAmounts.Add(MethodCode, POSEntryPaymentLine."Amount (Sales Currency)");
                    MethodCodes.Add(MethodCode);
                end;
            until POSEntryPaymentLine.Next() = 0;

        POSPaymentMethod.SetLoadFields(Description);
        foreach MethodCode in MethodCodes do
            if NetAmounts.Get(MethodCode) < 0 then begin
                if not POSPaymentMethod.Get(MethodCode) then
                    POSPaymentMethod.Description := '';
                if POSPaymentMethod.Description <> '' then
                    Result.Append(Separator + POSPaymentMethod.Description)
                else
                    Result.Append(Separator + MethodCode);
                Separator := ', ';
            end;
        exit(Result.ToText());
    end;

    procedure SummaryText(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary): Text
    var
        Summary: TextBuilder;
        LinkedLbl: Label 'Line %1: refund on Shopify order %2, quantity %3, amount %4.', Comment = '%1 = POS entry sales line number, %2 = Shopify order id, %3 = quantity, %4 = amount';
        CoveredLbl: Label 'Line %1: not sent again, the entry already has a refund on Shopify order %2.', Comment = '%1 = POS entry sales line number, %2 = Shopify order id';
        PendingLbl: Label 'Line %1: waiting for the original POS sale %2 to be sent to Shopify.', Comment = '%1 = POS entry sales line number, %2 = original POS entry number';
        UnlinkedLbl: Label 'Line %1: not sent. %2', Comment = '%1 = POS entry sales line number, %2 = reason';
    begin
        ReturnLineBuf.Reset();
        if ReturnLineBuf.FindSet() then
            repeat
                case ReturnLineBuf."Return Case" of
                    ReturnLineBuf."Return Case"::Linked:
                        if ReturnLineBuf."Refund Quantity" = 0 then
                            Summary.AppendLine(StrSubstNo(CoveredLbl, ReturnLineBuf."Line No.", ReturnLineBuf."Target Shopify Order ID"))
                        else
                            Summary.AppendLine(StrSubstNo(LinkedLbl, ReturnLineBuf."Line No.", ReturnLineBuf."Target Shopify Order ID", ReturnLineBuf."Refund Quantity", ReturnLineBuf."Refund Amount"));
                    ReturnLineBuf."Return Case"::Pending:
                        Summary.AppendLine(StrSubstNo(PendingLbl, ReturnLineBuf."Line No.", ReturnLineBuf."Original POS Entry No."));
                    ReturnLineBuf."Return Case"::Unlinked:
                        Summary.AppendLine(StrSubstNo(UnlinkedLbl, ReturnLineBuf."Line No.", ReturnLineBuf."Unlinked Reason"));
                end;
            until ReturnLineBuf.Next() = 0;
        exit(Summary.ToText());
    end;

    local procedure ResolveCase(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; ShopifyStoreCode: Code[20]; EntryCurrencyReason: Text; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary)
    var
        OriginalPOSEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        TempSpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link" temporary;
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        LineItemQuantities: List of [Integer];
        LineItemUnitPrices: List of [Decimal];
        LineItemTaxAmounts: List of [Decimal];
        NoOriginLbl: Label 'The line is not linked to a POS sale.';
        OriginalGoneLbl: Label 'The original POS sales line no longer exists.';
        OriginMismatchLbl: Label 'The line''s origin, line %1 of POS entry %2, is for %3 and does not match this line, so it is not refunded.', Comment = '%1 = original line no., %2 = original POS entry no., %3 = item or account no. of the original line';
        NeverSentLbl: Label 'The original POS sale %1 is not in Shopify and will not be sent: %2.', Comment = '%1 = original POS entry number, %2 = why the scheduler will not send it';
        NotSentReason: Text;
        OtherCurrencyLbl: Label 'The original POS sale %1 is in %2 while the Shopify store uses %3; refunds on orders in another currency are not supported yet.', Comment = '%1 = original POS entry number, %2 = POS entry currency, %3 = Shopify store currency';
        OriginalCurrency: Code[10];
        StoreCurrency: Code[10];
    begin
        ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Unlinked;
        if IsNullGuid(POSEntrySalesLine."Orig.POS Entry S.Line SystemId") then begin
            ReturnLineBuf."Unlinked Reason" := NoOriginLbl;
            exit;
        end;
        if not OriginalLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId") then begin
            ReturnLineBuf."Unlinked Reason" := OriginalGoneLbl;
            exit;
        end;
        // Import Posted Invoice links an origin by line number, which can point at another item; the match keys below come from the original line, so it must be the same item or account.
        if (OriginalLine.Type <> POSEntrySalesLine.Type) or (OriginalLine."No." <> POSEntrySalesLine."No.") or (OriginalLine."Variant Code" <> POSEntrySalesLine."Variant Code") then begin
            ReturnLineBuf."Unlinked Reason" := CopyStr(StrSubstNo(OriginMismatchLbl, OriginalLine."Line No.", OriginalLine."POS Entry No.", OriginalLine."No."), 1, MaxStrLen(ReturnLineBuf."Unlinked Reason"));
            exit;
        end;
        ReturnLineBuf."Original POS Entry No." := OriginalLine."POS Entry No.";
        // Matched against what the sale sent for the original line.
        ReturnLineBuf."Is Item Line" := OriginalLine.Type = OriginalLine.Type::Item;
        ReturnLineBuf."Item No." := OriginalLine."No.";
        ReturnLineBuf."Variant Code" := OriginalLine."Variant Code";
        ReturnLineBuf."Unit Price" := OriginalLine."Unit Price";
        ReturnLineBuf."Line Title" := CopyStr(SpfyPOSEntryExportMgt.GetLineItemTitle(OriginalLine), 1, MaxStrLen(ReturnLineBuf."Line Title"));
        OriginalPOSEntry.Get(OriginalLine."POS Entry No.");
        SpfyPOSEntryExportMgt.GetLineItemSplit(OriginalLine, OriginalPOSEntry."Prices Including VAT", LineItemQuantities, LineItemUnitPrices, LineItemTaxAmounts);
        ReturnLineBuf."Line Item Price" := LineItemUnitPrices.Get(1);
        ReturnLineBuf."Line Item Price 2" := LineItemUnitPrices.Get(LineItemUnitPrices.Count());
        // Decided before the sale part runs, so a return in another currency than the store's, on either entry, never counts as funding a new order.
        if EntryCurrencyReason <> '' then begin
            ReturnLineBuf."Unlinked Reason" := CopyStr(EntryCurrencyReason, 1, MaxStrLen(ReturnLineBuf."Unlinked Reason"));
            exit;
        end;
        if not CurrencyMatchesStore(OriginalPOSEntry, ShopifyStoreCode, OriginalCurrency, StoreCurrency) then begin
            ReturnLineBuf."Unlinked Reason" := CopyStr(StrSubstNo(OtherCurrencyLbl, OriginalPOSEntry."Entry No.", OriginalCurrency, StoreCurrency), 1, MaxStrLen(ReturnLineBuf."Unlinked Reason"));
            exit;
        end;
        TempSpfyStorePOSEntryLink."POS Entry No." := OriginalPOSEntry."Entry No.";
        TempSpfyStorePOSEntryLink."Shopify Store Code" := ShopifyStoreCode;
        if LinkToSentOriginal(TempSpfyStorePOSEntryLink, ReturnLineBuf) then
            exit;
        if IsExpectedToBeSent(OriginalPOSEntry, ShopifyStoreCode, NotSentReason) then begin
            ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Pending;
            exit;
        end;
        // The original's task may have completed in another session since the first read.
        if LinkToSentOriginal(TempSpfyStorePOSEntryLink, ReturnLineBuf) then
            exit;
        ReturnLineBuf."Unlinked Reason" := CopyStr(StrSubstNo(NeverSentLbl, OriginalPOSEntry."Entry No.", NotSentReason), 1, MaxStrLen(ReturnLineBuf."Unlinked Reason"));
    end;

    local procedure LinkToSentOriginal(var TempSpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link" temporary; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ReturnLineBuf."Target Shopify Order ID" := SpfyAssignedIDMgt.GetAssignedShopifyID(TempSpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ReturnLineBuf."Target Shopify Order ID" = '' then
            exit(false);
        ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Linked;
        exit(true);
    end;

    local procedure CurrencyMatchesStore(POSEntry: Record "NPR POS Entry"; ShopifyStoreCode: Code[20]; var EntryCurrency: Code[10]; var StoreCurrency: Code[10]): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        EntryCurrency := POSEntry."Currency Code";
        if EntryCurrency = '' then begin
            GeneralLedgerSetup.Get();
            EntryCurrency := GeneralLedgerSetup."LCY Code";
        end;
        StoreCurrency := SpfyIntegrationMgt.StoreCurrencyCode(ShopifyStoreCode);
        exit(EntryCurrency = StoreCurrency);
    end;
}
