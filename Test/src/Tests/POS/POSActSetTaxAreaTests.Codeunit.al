codeunit 85126 "NPR POS Act. SetTaxArea Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        NewTaxArea: Record "Tax Area";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('TaxAreaListPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetTaxAreaCode()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetTaxAreaCodeB: Codeunit "NPR POSAction: SetTaxAreaCodeB";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Create new Tax area
        CreateNewTaxArea('TEST_AREA');

        // [When] We call action for setting Tax area
        POSActionSetTaxAreaCodeB.SetTaxAreaCode(SalePOS);

        // [Then] Tax area code on the sale should be same newly created tax area
        Assert.IsTrue(SalePOS."Tax Area Code" = NewTaxArea.Code, 'Tax Area is set.')
    end;

    [ModalPageHandler]
    procedure TaxAreaListPageHandler(var TaxAreaList: TestPage "Tax Area List")
    begin
        TaxAreaList.GoToRecord(NewTaxArea);
        TaxAreaList.OK().Invoke();
    end;

    local procedure CreateNewTaxArea(TaxAreaCode: Code[20])
    begin
        NewTaxArea.Code := TaxAreaCode;
        NewTaxArea.Description := TaxAreaCode;
        if NewTaxArea.Insert() then;
    end;
}