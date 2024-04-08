codeunit 85130 "NPR POS Act: Quick Login Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('OpenPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SelectSalespersonCode_QuickLogin()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActBusinessLog: Codeunit "NPR POS Action: Quick Login B.";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Change salesperson on pos sale - choose from list
        // [GIVEN] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesperson(Salesperson);

        // [WHEN]
        POSActBusinessLog.OnActionLookupSalespersonCode(Salesperson.Code, POSSale);

        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Salesperson Code" = Salesperson.Code, 'Salesperson Code is not changed on Sale POS.');
    end;

    [ModalPageHandler]
    procedure OpenPageHandler(var SalespersonList: TestPage "Salespersons/Purchasers")
    begin
        SalespersonList.GoToRecord(Salesperson);
        SalespersonList.OK().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFixedSalespersonCode_QuickLogin()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActBusinessLog: Codeunit "NPR POS Action: Quick Login B.";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Change to specific salesperson on pos sale
        // [GIVEN] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesperson(Salesperson);

        // [WHEN]
        POSActBusinessLog.ApplySalespersonCode(Salesperson.Code, POSSale);

        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Salesperson Code" = Salesperson.Code, 'Salesperson Code is not changed on Sale POS.');
    end;
}