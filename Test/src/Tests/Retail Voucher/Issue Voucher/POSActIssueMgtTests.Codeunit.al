codeunit 85099 "NPR POS Act. Issue Mgt. Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";

    [Test]
    [HandlerFunctions('SelectHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SelectVoucherType()
    var
        VoucherTypeCode: Text;
    begin
        if _VoucherTypeDefault.Code = '' then
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
        if POSIssueMgt.SelectVoucherType(VoucherTypeCode) then
            Assert.Equal(VoucherTypeCode, _VoucherTypeDefault.Code);
    end;

    [ModalPageHandler]
    procedure SelectHandler(var VoucherTypes: TestPage "NPR NpRv Voucher Types")
    begin
        VoucherTypes.GoToRecord(_VoucherTypeDefault);
        VoucherTypes.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('OpenContactHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucher()
    var
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VoucherAmount: Decimal;
        DiscountPerc: Decimal;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Voucher Type, Amount, Disount Perc
        if _VoucherTypeDefault.Code = '' then
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        DiscountPerc := 20;
        POSSession.GetSaleLine(POSSaleLine);

        // [When] Create
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, TempVoucher, _VoucherTypeDefault, '0', 1, VoucherAmount, DiscountPerc, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, TempVoucher, _VoucherTypeDefault, POSSaleLine);

        //[When] Open pages
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSIssueMgt.ContactInfo(SaleLinePOS);

        // [Then]
        Assert.IsTrue(TempVoucher."No." <> '', 'Voucher not created.');
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Issue Voucher", 'POS Sale Line record not according to test scenario.');
        Assert.Equal(VoucherAmount, SaleLinePOS.Amount);
        Assert.Equal(DiscountPerc, SaleLinePOS."Discount %");
        Assert.Equal(SaleLinePOS.Description, TempVoucher.Description);
        // [Then]
        Assert.Equal(NpRvSalesLine."Voucher No.", TempVoucher."No.");
        Assert.Equal(NpRvSalesLine."Voucher Type", _VoucherTypeDefault.Code);
    end;

    [ModalPageHandler]
    procedure OpenContactHandler(var SalesLineCard: TestPage "NPR NpRv Sales Line Card")
    begin
        Assert.IsTrue(true, 'Page does not opened.');
    end;

    local procedure GetRandomVoucherAmount(PaymentMethod: Code[20]): Decimal
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryRandom.Init();
        POSPaymentMethod.Get(PaymentMethod);
        //Avoid lower limit to be zero for those cases where discount amount is greater then zero
        exit(Round(LibraryRandom.RandDecInRange(100, 10000, LibraryRandom.RandIntInRange(0, 2)), POSPaymentMethod."Rounding Precision"));
    end;
}