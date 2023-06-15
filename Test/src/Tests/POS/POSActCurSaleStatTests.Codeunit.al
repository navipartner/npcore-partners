codeunit 85105 "NPR POS Act. CurSaleStat Tests"
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
    procedure RunObject()
    var
        POSSale: Codeunit "NPR POS Sale";
        RunPageCodeunit: Codeunit "NPR POS Action: CurSaleStats-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        //[When]
        RunPageCodeunit.RunSalesStatsPage();

    end;

    [ModalPageHandler]
    procedure OpenPageHandler(var CustomerList: TestPage "NPR POS Current Sale Stats")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;
}