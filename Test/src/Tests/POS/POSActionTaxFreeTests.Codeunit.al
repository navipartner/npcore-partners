codeunit 85128 "NPR POS Action Tax Free Tests"
{
    Subtype = Test;

    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibTaxFree: Codeunit "NPR Library - Tax Free";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [HandlerFunctions('OpenVoucherPageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunVoucherList()
    var
        TaxFreePosUnit: Record "NPR Tax Free POS Unit";
        ActionBussinesLogic: Codeunit "NPR POS Action Tax Free B.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSetup(POSSetup);
        if not TaxFreePosUnit.Get(POSUnit."No.") then
            LibTaxFree.CreateTaxFreePosUnit(POSUnit."No.", TaxFreePosUnit);

        //[When]
        ActionBussinesLogic.OnActionTaxFree(1, POSSale, POSSetup);
    end;

    [ModalPageHandler]
    procedure OpenVoucherPageHandler(var TaxFreeVoucher: TestPage "NPR Tax Free Voucher")
    begin
        Assert.IsTrue(true, 'Tax Free Voucher page opened.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunToggleTaxFree()
    var
        SalePOS: Record "NPR POS Sale";
        TaxFreePosUnit: Record "NPR Tax Free POS Unit";
        ActionBussinesLogic: Codeunit "NPR POS Action Tax Free B.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        IssueTaxFreeVoucher: Boolean;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSession.GetSetup(POSSetup);
        if not TaxFreePosUnit.Get(POSUnit."No.") then
            LibTaxFree.CreateTaxFreePosUnit(POSUnit."No.", TaxFreePosUnit);

        // [When]
        POSSale.GetCurrentSale(SalePOS);
        IssueTaxFreeVoucher := SalePOS."Issue Tax Free Voucher";
        ActionBussinesLogic.OnActionTaxFree(0, POSSale, POSSetup);

        // [Then]
        POSSale.GetCurrentSale(SalePOS);
        Assert.IsTrue(SalePOS."Issue Tax Free Voucher" <> IssueTaxFreeVoucher, 'Sales POS is not modified.');
    end;
}