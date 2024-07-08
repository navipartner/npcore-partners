codeunit 85142 "NPR POS Act.:RunPageItem Tests"
{
    Subtype = Test;

    var
        Item: Record Item;
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        Assert: Codeunit "Assert";
        POSSession: Codeunit "NPR POS Session";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('ItemAvailabilityByLocationHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_ItemAvailabilityByLocation()
    var
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        BusinessLogic: Codeunit "NPR POS Action: RunPageItem-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create Item and Create POS line
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        //[When] Open page "Item Availability by Location"
        BusinessLogic.RunPageItem(POSSession, PAGE::"Item Availability by Location");
    end;

    [ModalPageHandler]
    procedure ItemAvailabilityByLocationHandler(var ItemCard: TestPage "Item Availability by Location")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;
}