codeunit 85121 "NPR POS Act. Change Bin Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        Bin1: Record Bin;
        BinContent1: Record "Bin Content";
        Bin2: Record Bin;
        BinContent2: Record "Bin Content";
        Bin3: Record Bin;
        BinContent3: Record "Bin Content";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('BinListPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeBin_SelectedBin()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        POSActionChangeBinB: Codeunit "NPR POS Action: Change Bin-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryWarehouse.CreateBin(Bin1, SaleLinePOS."Location Code", '', '', '');
        LibraryWarehouse.CreateBinContent(BinContent1, SaleLinePOS."Location Code", '', Bin1.Code, SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code");
        LibraryWarehouse.CreateBin(Bin2, SaleLinePOS."Location Code", '', '', '');
        LibraryWarehouse.CreateBinContent(BinContent2, SaleLinePOS."Location Code", '', Bin2.Code, SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code");
        LibraryWarehouse.CreateBin(Bin3, SaleLinePOS."Location Code", '', '', '');
        LibraryWarehouse.CreateBinContent(BinContent3, SaleLinePOS."Location Code", '', Bin3.Code, SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Unit of Measure Code");

        // [When] We call action for changing to location and select second location from the list
        POSActionChangeBinB.ChangeBin(POSSaleLine);


        // [Then] Location code on the lines should be same as default location code
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Bin Code" = Bin2.Code, 'Bin is changed.')
    end;

    [ModalPageHandler]
    procedure BinListPageHandler(var BinContentList: TestPage "Bin Contents List")
    begin
        BinContentList.GoToRecord(BinContent2);
        BinContentList.OK().Invoke();
    end;
}