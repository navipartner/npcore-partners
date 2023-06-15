codeunit 85133 "NPR POSAct:Change ResCen Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        RespCenter: Record "Responsibility Center";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('OpenPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SelectSalespersonCode_QuickLogin()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        BusinessLogic: Codeunit "NPR POS Act:Change Resp Cent B";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Change resp center on pos sale - choose from list
        // [GIVEN] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateResponsibilityCenter(RespCenter);
        // [WHEN]
        BusinessLogic.OnActionLookupRespCenter(RespCenter.Code, POSSale);

        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Responsibility Center" = RespCenter.Code, 'Responsibility Center is not changed on Sale POS.');
    end;

    [ModalPageHandler]
    procedure OpenPageHandler(var RespCenterList: TestPage "Responsibility Center List")
    begin
        RespCenterList.GoToRecord(RespCenter);
        RespCenterList.OK().Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetFixedSalespersonCode_QuickLogin()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        BusinessLogic: Codeunit "NPR POS Act:Change Resp Cent B";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Change to specific salesperson on pos sale
        // [GIVEN] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateResponsibilityCenter(RespCenter);

        // [WHEN]
        BusinessLogic.ApplyRespCenterCode(RespCenter.Code, POSSale);

        // [THEN]
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Responsibility Center" = RespCenter.Code, 'Responsibility Center is not changed on Sale POS.');
    end;

    procedure CreateResponsibilityCenter(var ResponsibilityCenter: Record "Responsibility Center")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ResponsibilityCenter.Init();
        ResponsibilityCenter.Validate(
          Code, LibraryUtility.GenerateRandomCode(ResponsibilityCenter.FieldNo(Code), DATABASE::"Responsibility Center"));
        ResponsibilityCenter.Validate(Name, ResponsibilityCenter.Code);  // Validating Name as Code because value is not important.
        ResponsibilityCenter.Insert(true);
    end;
}