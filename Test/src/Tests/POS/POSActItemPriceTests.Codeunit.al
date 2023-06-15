codeunit 85061 "NPR POS Act. Item Price Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestGetLineNoOneLine()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LineNo := SaleLinePOS."Line No.";

        POSActionItemPriceB.GetSalesLineNo(POSSession, SaleLinePOS);

        Assert.IsTrue(LineNo = SaleLinePOS."Line No.", 'Line No.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestGetLineNo()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LineNo := -1;

        POSActionItemPriceB.GetSalesLineNo(POSSession, SaleLinePOS);

        Assert.IsTrue(LineNo = SaleLinePOS."Line No.", 'Line No.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestGetLineOneLine()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
        LineFound: Boolean;
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LineNo := SaleLinePOS."Line No.";

        LineFound := POSActionItemPriceB.GetSalesLine(POSSession, SaleLinePOS, LineNo);

        Assert.IsTrue(LineFound = false, 'Line not found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestDeleteLines()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionItemPriceB: Codeunit "NPR POS Action - Item Price B";
        POSSession: Codeunit "NPR POS Session";
        SalePOS: Record "NPR POS Sale";
        LineNo: Integer;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);

        LineNo := -1;

        POSActionItemPriceB.DeleteLines(POSSession, LineNo);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        Assert.IsTrue(SaleLinePOS.IsEmpty = true, 'Lines deleted');
    end;

}