codeunit 85085 "NPR POS Act. Item Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Quantity: Decimal;
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddSalesLine()
    var
        Item: Record Item;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        ItemReference: Record "Item Reference";
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
        ItemQuantity: Decimal;
        UnitPrice: Decimal;
        CustomDescription: Text;
        CustomDescription2: Text;
        InputSerial: Text;
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

        ItemIdentifierType := ItemIdentifierType::ItemNo;
        Quantity := 1;
        UnitPrice := LibraryRandom.RandDec(100, 4);
        CustomDescription := LibraryRandom.RandText(50);
        CustomDescription2 := LibraryRandom.RandText(30);

        POSSession.GetFrontEnd(FrontEnd, true);
        POSActionBusinessLogic.AddItemLine(Item,
                               ItemReference,
                               ItemIdentifierType,
                               ItemQuantity,
                               UnitPrice,
                               CustomDescription,
                               CustomDescription2,
                               InputSerial,
                               POSSession,
                               FrontEnd,
                               '');

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item Inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = Quantity, 'Quantity Inserted');
        Assert.IsTrue(SaleLinePOS."Unit Price" = UnitPrice, 'Unit Price Inserted');
        Assert.IsTrue(SaleLinePOS.Description = CustomDescription, 'New description inserted');
        Assert.IsTrue(SaleLinePOS."Description 2" = CustomDescription2, 'New description 2 inserted');
    end;
}