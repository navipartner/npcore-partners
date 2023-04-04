codeunit 85141 "NPR POS Action:Item Card Tests"
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
        PageEditable: Boolean;

    [Test]
    [HandlerFunctions('ItemCardHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemCard_Editable()
    var
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        BusinessLogic: Codeunit "NPR POS Action: Item Card-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        PageEditable := true;

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create Item and Create POS line
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        POSSession.ChangeViewSale();

        //[When] Non Editable Item Card Page should be opened with created Item
        BusinessLogic.OpenItemPage(POSSession, PageEditable, false);
    end;

    [Test]
    [HandlerFunctions('ItemCardHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemCard_NonEditable()
    var
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        BusinessLogic: Codeunit "NPR POS Action: Item Card-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        PageEditable := false;

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create Item and Create POS line
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        POSSession.ChangeViewSale();

        //[When] Non Editable Item Card Page should be opened with created Item
        BusinessLogic.OpenItemPage(POSSession, PageEditable, false);
    end;

    [ModalPageHandler]
    procedure ItemCardHandler(var ItemCard: TestPage "Item Card")
    begin
        Assert.IsTrue(true, 'Page opened.');
        Assert.AreEqual(ItemCard.Editable, PageEditable, 'Page Non-Editable.');
        Assert.AreEqual(Format(ItemCard."No."), Item."No.", 'Created Item opened.');
    end;
}