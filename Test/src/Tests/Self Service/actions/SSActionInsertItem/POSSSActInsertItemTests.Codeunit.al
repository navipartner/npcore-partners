codeunit 85080 "NPR POS SSAct InsertItem Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,ItemGtin;
        IncreaseByQty: Decimal;
        ItemMaxQty: Decimal;
        ItemMinQty: Decimal;
        PresetUnitPrice: Decimal;
        UsePresetUnitPrice: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IncreaseQuantity()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActInsertItem: Codeunit "NPR POSAction: SS Insert ItemB";
        Success: Boolean;
    begin
        //PARAMETERS:
        //Edit Description = false
        //Item Identifier Type = ItemNo
        //ItemNo = ''
        //Item Qty = 1
        //Maximum Allowed Qty = 0
        //Minimum Allowed Qty = 1
        //Preset Unit Price = 0
        //Quantity Dialog Thershold = 10
        //usePresetUnitPrice = false

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        ItemMaxQty := 0;
        ItemMinQty := 1;
        PresetUnitPrice := 0;
        UsePresetUnitPrice := false;
        IncreaseByQty := 1;


        // [SCENARIO]
        //Increase Quantity on Line

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        //[When]
        SSActInsertItem.AddSalesLine(ItemIdentifierType, Item."No.", ItemMinQty, IncreaseByQty, PresetUnitPrice, UsePresetUnitPrice);
        Success := SSActInsertItem.IncreaseQuantity(Item."No.", ItemIdentifierType, IncreaseByQty, ItemMaxQty);

        //[Then]
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.FindFirst();

        Assert.IsTrue(SaleLinePOS.Quantity = IncreaseByQty + IncreaseByQty, 'Quantity is increased correctly');
        Assert.IsTrue(Success = true, 'Quantity is increased.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecreaseQuantity()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActInsertItem: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        //PARAMETERS:
        //Edit Description = false
        //Item Identifier Type = ItemNo
        //ItemNo = ''
        //Item Qty = 1
        //Maximum Allowed Qty = 0
        //Minimum Allowed Qty = 1
        //Preset Unit Price = 0
        //Quantity Dialog Thershold = 10
        //usePresetUnitPrice = false

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        ItemMaxQty := 0;
        ItemMinQty := 1;
        PresetUnitPrice := 0;
        UsePresetUnitPrice := false;
        IncreaseByQty := 1;

        // [SCENARIO]
        //Decrease Quantity on Line

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        //[When]
        SSActInsertItem.AddSalesLine(ItemIdentifierType, Item."No.", ItemMinQty, 2, PresetUnitPrice, UsePresetUnitPrice);
        SSActInsertItem.DecreaseQuantity(Item."No.", ItemIdentifierType, IncreaseByQty, ItemMinQty);

        //[Then]
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.FindFirst();
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity is decreased correctly');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddItemLine()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActInsertItem: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        //PARAMETERS:
        //Edit Description = false
        //Item Identifier Type = ItemNo
        //ItemNo = ''
        //Item Qty = 1
        //Maximum Allowed Qty = 0
        //Minimum Allowed Qty = 1
        //Preset Unit Price = 0
        //Quantity Dialog Thershold = 10
        //usePresetUnitPrice = false

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        ItemMaxQty := 0;
        ItemMinQty := 1;
        PresetUnitPrice := 0;
        UsePresetUnitPrice := false;
        IncreaseByQty := 1;

        // [SCENARIO]
        //Add Item on Line

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        //[When]
        SSActInsertItem.AddSalesLine(ItemIdentifierType, Item."No.", ItemMinQty, IncreaseByQty, PresetUnitPrice, UsePresetUnitPrice);

        //[Then]
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.FindFirst();

        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item is inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddItemLinePresetUnitPrice()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        LibraryRandom: Codeunit "Library - Random";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActInsertItem: Codeunit "NPR POSAction: SS Insert ItemB";
    begin
        //PARAMETERS:
        //Edit Description = false
        //Item Identifier Type = ItemNo
        //ItemNo = ''
        //Item Qty = 1
        //Maximum Allowed Qty = 0
        //Minimum Allowed Qty = 1
        //Preset Unit Price = 0
        //Quantity Dialog Thershold = 10
        //usePresetUnitPrice = false

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        ItemMaxQty := 0;
        ItemMinQty := 1;
        PresetUnitPrice := LibraryRandom.RandDecInRange(0, 100, 4);
        UsePresetUnitPrice := true;
        IncreaseByQty := 1;

        // [SCENARIO]
        //Add Item on Line

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        //[When]
        SSActInsertItem.AddSalesLine(ItemIdentifierType, Item."No.", ItemMinQty, IncreaseByQty, PresetUnitPrice, UsePresetUnitPrice);

        //[Then]
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.FindFirst();

        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item is inserted');
        Assert.IsTrue(SaleLinePOS."Unit Price" = PresetUnitPrice, 'Unit price inserted');
    end;
}