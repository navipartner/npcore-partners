codeunit 85073 "NPR POS Self Service Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeViewSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        CurrentView: Codeunit "NPR POS View";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        //[When]
        POSSession.ChangeViewSale();

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.GetType() = CurrentView.GetType() ::Sale, Format(CurrentView.GetType()));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeViewPayment()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        CurrentView: Codeunit "NPR POS View";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        //[When]
        POSSession.ChangeViewPayment();

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.GetType() = CurrentView.GetType() ::Payment, Format(CurrentView.GetType()));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeViewLogin()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        CurrentView: Codeunit "NPR POS View";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);

        //[When]
        POSSession.ChangeViewLogin();

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.GetType() = CurrentView.GetType() ::Login, Format(CurrentView.GetType()));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IncreaseQuantity()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
        GivenQuantity: Decimal;
        NewQuantity: Decimal;
    begin
        // [SCENARIO]
        //Increase Quantity on Line
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        GivenQuantity := LibraryRandom.RandDecInRange(0, 100, 4);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", GivenQuantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        NewQuantity := LibraryRandom.RandDecInRange(1, 100, 4);
        SSActionQtyIncrease.IncreaseSalelineQuantity(POSSession, NewQuantity, POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.Quantity = GivenQuantity + NewQuantity, 'Quantity is increased correctly');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecreaseQuantity()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
        GivenQuantity: Decimal;
        NewQuantity: Decimal;
    begin
        // [SCENARIO]
        //Decrease Quantity on Line ,GivenQuantity >= NewQuantity
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        GivenQuantity := 100;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", GivenQuantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        NewQuantity := LibraryRandom.RandDecInRange(1, 100, 4);
        SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, NewQuantity, POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.Quantity = GivenQuantity - NewQuantity, 'Quantity is decreased correctly');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecreaseQuantityToZero()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
        GivenQuantity: Decimal;
        NewQuantity: Decimal;
    begin
        // [SCENARIO]
        //Decrease Quantity on Line ,GivenQuantity <= NewQuantity
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        GivenQuantity := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", GivenQuantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        NewQuantity := LibraryRandom.RandDecInRange(1, 100, 4);
        SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, NewQuantity, POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.Quantity = 0, 'Quantity is Zero');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecreaseQuantityWithZero()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
        GivenQuantity: Decimal;
        NewQuantity: Decimal;
    begin
        // [SCENARIO]
        //Decrease Quantity on Line , NewQuantity=0
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        GivenQuantity := 100;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", GivenQuantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        NewQuantity := 0;
        SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, NewQuantity, POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.Quantity = GivenQuantity, 'Quantity remains the same');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecreaseQuantityWithNegative()
    var
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SSActionQtyDecrease: Codeunit "NPR SS Action - Qty Decrease";
        GivenQuantity: Decimal;
        NewQuantity: Decimal;
    begin
        // [SCENARIO]
        //Decrease Quantity on Line , NewQuantity<0
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        GivenQuantity := 100;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", GivenQuantity);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        //[When]
        NewQuantity := LibraryRandom.RandDecInRange(-100, -1, 4);
        //[Then] Error expected
        asserterror SSActionQtyDecrease.DecreaseSalelineQuantity(POSSession, NewQuantity, POSSaleLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LoginScreen()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ActionLoginScreen: Codeunit "NPR SS Action: Login Screen";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        CurrentView: Codeunit "NPR POS View";
        Response: Text;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        //[When]
        ActionLoginScreen.ChangeToLoginScreen(POSSession, Response);

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.GetType() = CurrentView.GetType() ::Login, Format(CurrentView.GetType()));
        POSEntry.FindLast();
        Assert.IsTrue(POSEntry."Entry Type" = POSEntry."Entry Type"::"Cancelled Sale", 'POS Entry type Cancelled Sale is not created.');

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.AreEqual(1, POSEntrySalesLine.Count(), 'More then one Sales Line created when cancelling sale');
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Comment);
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'Comment was not added when cancelling sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteLine()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActionDeleteLine: Codeunit "NPR SS Action: Delete POSLineB";
    begin
        // [SCENARIO]
        //Delete Line
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);

        //[When]
        SSActionDeleteLine.DeletePosLine(POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Line is not deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StartSelfService()
    var
        Language: Record Language;
        POSEntry: Record "NPR POS Entry";
        Salesperson: Record "Salesperson/Purchaser";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        CurrentView: Codeunit "NPR POS View";
        SelfService: Codeunit "NPR SS Action: Start SelfServ.";
    begin
        // [SCENARIO]
        //Start Self Service
        // [Given] Initialize
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        LibraryPOSMock.InitializePOSSession(POSSession, POSUnit);
        Language.SetRange("Windows Language ID", 1033);
        Language.FindFirst();
        LibrarySales.CreateSalesperson(Salesperson);

        //[When] Active self service
        SelfService.StartSelfService(POSSession, Salesperson.Code, Language.Code);

        //[Then]
        POSSession.GetCurrentView(CurrentView);
        Assert.IsTrue(CurrentView.GetType() = CurrentView.GetType() ::Sale, 'Self Service is not started.');

        POSEntry.FindLast();
        Assert.IsTrue(POSEntry."System Entry" = true, 'POS Entry is not created.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemAddOn()
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        ItemAddOnBLogic: Codeunit "NPR SS Action - Item AddOn-BL";
    begin
        // [SCENARIO]
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateItemAddOnTypeQuantity(ItemAddOn, POSUnit, POSStore);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        //[When]
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.FindFirst();
        ItemAddOnBLogic.ApplyUserQuantity('1', ItemAddOnLine, 0, POSSale, POSSaleLine);

        //[Then]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.IsEmpty then
            Assert.AssertRecordNotFound();
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity is not entered.');
        Assert.IsTrue(SaleLinePOS."No." = ItemAddOnLine."Item No.", 'Item from Item AddOn Line is not inserted.');
    end;

    local procedure CreateItemAddOnTypeQuantity(var ItemAddOn: Record "NPR NpIa Item AddOn"; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        Item: Record Item;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        ItemAddOn.Enabled := true;
        ItemAddOn.Insert(true);

        ItemAddOnLine.Validate("AddOn No.", ItemAddOn."No.");
        ItemAddOnLine.Validate("Line No.", 10000);
        ItemAddOnLine.Validate(Type, ItemAddOnLine.Type::Quantity);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        ItemAddOnLine.Validate("Item No.", Item."No.");
        ItemAddOnLine.Insert(true);
    end;
}
