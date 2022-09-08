codeunit 85073 "NPR POS Self Service Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";

    [Test]
    procedure ChangeViewSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
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
        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Sale, Format(CurrentView.Type()));

    end;

    [Test]
    procedure ChangeViewPayment()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
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
        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Payment, Format(CurrentView.Type()));

    end;

    [Test]
    procedure ChangeViewLogin()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
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
        Assert.IsTrue(CurrentView.Type() = CurrentView.Type() ::Login, Format(CurrentView.Type()));

    end;

    [Test]
    procedure IncreaseQuantity()
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        LibraryRandom: Codeunit "Library - Random";
        SaleLinePOS: Record "NPR POS Sale Line";
        SSActionQtyIncrease: Codeunit "NPR SS Action - Qty Increase";
        NewQuantity: Decimal;
        GivenQuantity: Decimal;
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
}
