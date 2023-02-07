codeunit 85122 "NPR POS Act. Retail Inv. Tests"
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
    [HandlerFunctions('PageHandler_RetailInventoryBuffer')]
    procedure RetailInventorySets()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action - Retail Inv. B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        CreateRetailInvSetup();

        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        POSActionBusinessLogic.ProcessInventorySet(POSSaleLine, '');
    end;

    [ModalPageHandler]
    procedure PageHandler_RetailInventoryBuffer(var InvRetailPage: Page "NPR RIS Retail Inv. Buffer"; var ActionResponse: Action)
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;

    local procedure CreateRetailInvSetup()
    var
        LibraryUtility: Codeunit "Library - Utility";
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
    begin
        RetailInventorySet.Init();
        RetailInventorySet.Code := LibraryUtility.GenerateRandomCode(RetailInventorySet.FieldNo(Code), Database::"NPR RIS Retail Inv. Set");
        RetailInventorySet.Insert();
    end;
}