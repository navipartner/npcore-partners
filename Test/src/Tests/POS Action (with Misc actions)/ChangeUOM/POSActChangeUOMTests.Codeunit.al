codeunit 85072 "NPR POS Act. Change UOM Tests"
{
    Subtype = Test;

    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit "Assert";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeUOM()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionChangeUOMB: Codeunit "NPR POS Action: Change UOM-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Quantity: Decimal;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [GIVEN] Item with unit price        
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := 1;
        // Create Unit Of Measure and use it as parameter
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        // [When]
        POSActionChangeUOMB.SetUoM(UnitOfMeasure.Code, POSSaleLine);
        // [Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Unit of Measure Code" = UnitOfMeasure.Code, 'Unit of Measure is changed.')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('PageHandler_ItemUnitsofMeasure_LookupOK')]
    procedure ChangeUOMWithoutDefaultUOM()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        UnitOfMeasure: Record "Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionChangeUOMB: Codeunit "NPR POS Action: Change UOM-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        Quantity: Decimal;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Quantity := 1;
        // Create Unit Of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Quantity);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        // [When]
        POSActionChangeUOMB.SetUoM('', POSSaleLine);
        // [Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."Unit of Measure Code" = UnitOfMeasure.Code, 'Unit of Measure is changed.')
    end;

    [ModalPageHandler]
    procedure PageHandler_ItemUnitsofMeasure_LookupOK(var ItemUnitsofMeasurePage: Page "Item Units of Measure"; var ActionResponse: Action)
    begin
        ItemUnitsofMeasurePage.SetRecord(ItemUnitOfMeasure);
        ActionResponse := Action::LookupOK;
    end;

}