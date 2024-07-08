codeunit 85100 "NPR POS ActMergeSimLines Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSimilarLines()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 5);

        POSSale.GetCurrentSale(SalePOS);

        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.FindFirst();

        Assert.IsTrue(SaleLinePOS.Quantity = 6, 'Quantity merged');
        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item inserted');
    end;

}