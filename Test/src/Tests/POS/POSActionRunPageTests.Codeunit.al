codeunit 85095 "NPR POS Action:Run Page Tests"
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
    procedure RunPage()
    var
        POSSale: Codeunit "NPR POS Sale";
        RunPageCodeunit: Codeunit "NPR POS Action: Run Page-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        //[When]
        RunPageCodeunit.RunPage(9305, false, 0, '');

    end;

    [PageHandler]
    procedure OpenPageHandler(var OrderList: TestPage "Sales Order List")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;
}