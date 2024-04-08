codeunit 85136 "NPR POS Act.SetTaxLiable Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit "Assert";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetTaxLiableTrue()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetTaxLiableB: Codeunit "NPR POSAction: Set TaxLiable B";
        TaxLiable: Boolean;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        TaxLiable := true;

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionSetTaxLiableB.SetTaxLiable(TaxLiable);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Assert.IsTrue(SalePOS."Tax Liable" = TaxLiable, 'Tax Area is set as true.')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SetTaxLiableFalse()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetTaxLiableB: Codeunit "NPR POSAction: Set TaxLiable B";
        TaxLiable: Boolean;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        TaxLiable := false;

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSActionSetTaxLiableB.SetTaxLiable(TaxLiable);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        Assert.IsTrue(SalePOS."Tax Liable" = TaxLiable, 'Tax Area is set as false.')
    end;

}