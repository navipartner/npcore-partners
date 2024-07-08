codeunit 85118 "NPR POS Act. Change Loc. Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        FirstLocation: Record Location;
        SecondLocation: Record Location;
        ThirdLocation: Record Location;
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeLocation_DefaultLocation()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        DefaultLocation: Record Location;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        POSActionChangeLocB: Codeunit "NPR POS Action: Change Loc-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryWarehouse.CreateLocation(DefaultLocation);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        // [When] We call action for changing to location and provide default location code
        POSActionChangeLocB.ChangeLocation(POSSaleLine, DefaultLocation.Code);


        // [Then] Location code on the lines should be same as default location code
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Location Code" = DefaultLocation.Code, 'Location is changed.')
    end;

    [Test]
    [HandlerFunctions('LocationListPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeLocation_SelectedLocation()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        POSActionChangeLocB: Codeunit "NPR POS Action: Change Loc-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryWarehouse.CreateLocation(FirstLocation);
        LibraryWarehouse.CreateLocation(SecondLocation);
        LibraryWarehouse.CreateLocation(ThirdLocation);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        // [When] We call action for changing to location and select second location from the list
        POSActionChangeLocB.ChangeLocation(POSSaleLine, '');


        // [Then] Location code on the lines should be same as default location code
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Location Code" = SecondLocation.Code, 'Location is changed.')
    end;

    [ModalPageHandler]
    procedure LocationListPageHandler(var LocationList: TestPage "Location List")
    begin
        LocationList.GoToRecord(SecondLocation);
        LocationList.OK().Invoke();
    end;
}