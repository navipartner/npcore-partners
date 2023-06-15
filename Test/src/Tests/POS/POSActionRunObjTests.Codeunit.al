codeunit 85104 "NPR POS Action Run Obj. Tests"
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
        RunPageCodeunit: Codeunit "NPR POS Action: Run Object-B";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        //[When]
        RunPageCodeunit.RunObject('CUSDOM', POSSession);

    end;

    [PageHandler]
    procedure OpenPageHandler(var CustomerList: TestPage "Customer List")
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;
}