codeunit 85144 "NPR POS Action Zoom Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        Item: Record Item;
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('ZoomLineHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ZoomLine()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionZoomB: Codeunit "NPR POS Action: Zoom-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create Item and Create POS line
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        POSSession.ChangeViewSale();

        //[When]  Open page "NPR TouchScreen: SalesLineZoom"
        POSActionZoomB.ZoomLine(POSSession);
    end;

    [ModalPageHandler]
    procedure ZoomLineHandler(var TouchScreenSalesLineZoom: TestPage "NPR TouchScreen: SalesLineZoom")
    var
        PageOpenedLbl: Label 'Page is opened.';
    begin
        Assert.IsTrue(true, PageOpenedLbl);
    end;
}