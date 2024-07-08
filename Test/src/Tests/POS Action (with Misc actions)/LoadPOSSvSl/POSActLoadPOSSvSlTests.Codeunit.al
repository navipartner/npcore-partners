codeunit 85086 "NPR POS ActLoadPOSSvSl Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestLoadFromQuote()
    var
        POSActGetParkedSaleB: Codeunit "NPR POS Action: LoadPOSSvSl B";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Item: Record Item;
        POSActSaveSale: Codeunit "NPR POS Action: SavePOSSvSl B";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";

    begin
        NPRLibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        NPRLibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSActSaveSale.SaveSaleAndStartNewSale(POSQuoteEntry);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        POSActGetParkedSaleB.LoadFromQuote(POSQuoteEntry, SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.SetRange(Quantity, 1);

        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Parked Sale Inserted');
    end;
}