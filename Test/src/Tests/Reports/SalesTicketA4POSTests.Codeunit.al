// [FEATURE] Sales Ticket A4 - POS report
codeunit 85654 "NPR Sales Ticket A4 POS Tests"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _POSEntryNoFilter: Text;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('SalesTicketA4POSRequestPageHandler')]
    procedure GivenPOSEntryWithItemAndAttachedComment_WhenA4SalesTicketRuns_ThenTheCommentRowHasABlankNo()
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
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CommentLineNo: Integer;
        ItemLineNo: Integer;
        ItemNoValue: Text;
        CommentNoValue: Text;
        ReportXml: XmlDocument;
        CommentRowMissingMsg: Label 'F3: the A4 ticket should print a row for the comment "No sugar" (POS entry %1, line %2)', Locked = true;
        ItemRowMissingMsg: Label 'F3: the A4 ticket should print a row for the item %1 (POS entry %2, line %3)', Locked = true;
        ItemRowNoMsg: Label 'F3: the A4 ticket row of the item %1 should print the item no.', Locked = true;
    begin
        // [SCENARIO] The A4 sales ticket prints a blank No. for a comment attached to an item, and the item no. for the item
        Initialize();

        // [GIVEN] F3: a POS entry of a cash sale of an item with the comment "No sugar" attached to it (No. "*")
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        InsertCommentB.InputPosCommentLine('No sugar', true, POSSaleLine);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Amount Including VAT");
        LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '', false);
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Comment);
        POSEntrySalesLine.FindFirst();
        CommentLineNo := POSEntrySalesLine."Line No.";
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.FindFirst();
        ItemLineNo := POSEntrySalesLine."Line No.";

        // [WHEN] The A4 sales ticket of the POS entry runs to its XML dataset
        LoadSalesTicketA4Xml(POSEntry."Entry No.", ReportXml);

        // [THEN] The row of the comment prints a blank No.
        Assert.IsTrue(
            FindSalesLineNo(ReportXml, POSEntry."Entry No.", CommentLineNo, CommentNoValue),
            StrSubstNo(CommentRowMissingMsg, POSEntry."Entry No.", CommentLineNo));
        Assert.AreEqual('', CommentNoValue, 'F3: the A4 ticket row of the comment "No sugar" should print a blank No.');

        // [THEN] The row of the item prints the item no.
        Assert.IsTrue(
            FindSalesLineNo(ReportXml, POSEntry."Entry No.", ItemLineNo, ItemNoValue),
            StrSubstNo(ItemRowMissingMsg, Item."No.", POSEntry."Entry No.", ItemLineNo));
        Assert.AreEqual(Item."No.", ItemNoValue, StrSubstNo(ItemRowNoMsg, Item."No."));
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        LibraryPOSMock.InitializeData(_IsInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
    end;

    // Library - Report Dataset flattens only the first nested record per parent, so the sales line rows are read from the raw XML.
    local procedure LoadSalesTicketA4Xml(POSEntryNo: Integer; var ReportXml: XmlDocument)
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        XmlParameters: Text;
    begin
        _POSEntryNoFilter := Format(POSEntryNo, 0, 9);
        Commit();
        XmlParameters := Report.RunRequestPage(Report::"NPR Sales Ticket A4 - POS Rdlc");
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        Report.SaveAs(Report::"NPR Sales Ticket A4 - POS Rdlc", XmlParameters, ReportFormat::Xml, OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        XmlDocument.ReadFrom(InStr, ReportXml);
    end;

    local procedure FindSalesLineNo(ReportXml: XmlDocument; POSEntryNo: Integer; LineNo: Integer; var NoValue: Text): Boolean
    var
        NoNode: XmlNode;
        RowNode: XmlNode;
        RowXPathTxt: Label '//DataItem[Columns/Column[@name=''POSEntryNo_POS_Entry_Sales_Line'']=''%1''][Columns/Column[@name=''LineNo_POS_Entry_Sales_Line'']=''%2'']', Locked = true;
    begin
        NoValue := '';
        if not ReportXml.SelectSingleNode(StrSubstNo(RowXPathTxt, Format(POSEntryNo, 0, 9), Format(LineNo, 0, 9)), RowNode) then
            exit(false);
        if RowNode.SelectSingleNode('Columns/Column[@name=''No_POS_Entry_Sales_Line'']', NoNode) then
            NoValue := NoNode.AsXmlElement().InnerText();
        exit(true);
    end;

    [RequestPageHandler]
    procedure SalesTicketA4POSRequestPageHandler(var SalesTicketA4POS: TestRequestPage "NPR Sales Ticket A4 - POS Rdlc")
    begin
        SalesTicketA4POS."NPR POS Entry".SetFilter("Entry No.", _POSEntryNoFilter);
        SalesTicketA4POS.OK().Invoke();
    end;
}
