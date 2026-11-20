// [FEATURE] NP Email POS receipt data
codeunit 85655 "NPR NP Email POS Rcpt Tests"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPOSEntryWithItemAndAttachedComment_WhenEmailReceiptDataIsBuilt_ThenTheCommentHasABlankNo()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Assert: Codeunit Assert;
        InsertCommentB: Codeunit "NPR POS Action - Insert Comm B";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSRcptDataProv: Codeunit "NPR NPEmailPOSRcptDataProv";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        RecRef: RecordRef;
        Content: JsonObject;
        CommentLineNo: Integer;
        ItemLineNo: Integer;
        CommentNoValue: Text;
        ItemNoValue: Text;
        CommentEntryMissingMsg: Label 'F2: the e-mail receipt data should hold a sales_lines entry for the comment "No sugar" (POS entry %1, line %2)', Locked = true;
        ItemEntryMissingMsg: Label 'F2: the e-mail receipt data should hold a sales_lines entry for the item %1 (POS entry %2, line %3)', Locked = true;
        ItemEntryNoMsg: Label 'F2: the sales_lines entry of the item %1 should carry the item no.', Locked = true;
    begin
        // [SCENARIO] The e-mail receipt data sends a blank no for a comment attached to an item, and the item no. for the item
        Initialize();

        // [GIVEN] F2: a POS entry of a cash sale of an item with the comment "No sugar" attached to it (No. "*")
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        InsertCommentB.InputPosCommentLine('No sugar', true, POSSaleLine);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Amount Including VAT");
        Assert.IsTrue(
            LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '', false),
            'F2: the cash sale of the item with the comment "No sugar" should end');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Comment);
        POSEntrySalesLine.FindFirst();
        Assert.AreEqual('*', POSEntrySalesLine."No.", 'F2: the attached comment "No sugar" should reach the POS entry with No. "*"');
        CommentLineNo := POSEntrySalesLine."Line No.";
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.FindFirst();
        ItemLineNo := POSEntrySalesLine."Line No.";

        // [WHEN] The NP Email POS receipt data is built for the POS entry
        RecRef.GetTable(POSEntry);
        Content := POSRcptDataProv.GetContent(RecRef);

        // [THEN] The sales_lines entry of the comment carries a blank no
        Assert.IsTrue(
            FindSalesLineNo(Content, CommentLineNo, CommentNoValue),
            StrSubstNo(CommentEntryMissingMsg, POSEntry."Entry No.", CommentLineNo));
        Assert.AreEqual('', CommentNoValue, 'F2: the sales_lines entry of the comment "No sugar" should carry a blank no');

        // [THEN] The sales_lines entry of the item carries the item no.
        Assert.IsTrue(
            FindSalesLineNo(Content, ItemLineNo, ItemNoValue),
            StrSubstNo(ItemEntryMissingMsg, Item."No.", POSEntry."Entry No.", ItemLineNo));
        Assert.AreEqual(Item."No.", ItemNoValue, StrSubstNo(ItemEntryNoMsg, Item."No."));
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(_IsInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
    end;

    local procedure FindSalesLineNo(Content: JsonObject; LineNo: Integer; var NoValue: Text): Boolean
    var
        SalesLine: JsonToken;
        SalesLines: JsonToken;
        Value: JsonToken;
    begin
        NoValue := '';
        if not Content.Get('sales_lines', SalesLines) then
            exit(false);
        foreach SalesLine in SalesLines.AsArray() do
            if SalesLine.AsObject().Get('line_no', Value) then
                if Value.AsValue().AsInteger() = LineNo then begin
                    if SalesLine.AsObject().Get('no', Value) then
                        NoValue := Value.AsValue().AsText()
                    else
                        NoValue := '<no key>';
                    exit(true);
                end;
        exit(false);
    end;
}
