codeunit 85112 "NPR POS Act. SinSaleStat Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";

    [Test]
    [HandlerFunctions('OpenPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SingleSalesStatsPage()
    var
        Item: Record Item;
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        BusinessCodeunit: Codeunit "NPR POS Action: SinSaleStats-B";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SaleEnded: Boolean;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [When] Paying 4 LCY
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 10, '');

        //[When]
        BusinessCodeunit.RunSingleSalesStatsPage();

    end;

    [PageHandler]
    procedure OpenPageHandler(var SingleSaleStatPage: TestPage "NPR POS Single Sale Statistics")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;
}