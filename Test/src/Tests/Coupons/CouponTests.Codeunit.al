codeunit 85074 "NPR Coupon Tests"
{
    // [Feature] Coupon Test scenarios
    Subtype = Test;

    var
        _Item: Record Item;
        _POSSession: Codeunit "NPR POS Session";
        _POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethodCash: Record "NPR POS Payment Method";
        _CouponType: Record "NPR NpDc Coupon Type";
        _Initialized: Boolean;
        _GS1Lbl: Label 'GS1';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UseFreeItemCouponInPOSTransaction()
    // [SCENARIO] Use Free Item Coupon POS Transaction - End transaction
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        TransactionEnded: Boolean;
    begin
        Initialize();
        // [GIVEN] POS Transaction
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, 1, TempCoupon);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN]
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, 0, '');
        // [THEN]
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeCouponLineQtyInPOSTransaction()
    // [SCENARIO] Change Coupon Line Quantity POS Transaction
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleLine: Record "NPR POS Sale Line";
        TransactionEnded: Boolean;
        CouponQty: Integer;
    begin
        Initialize();
        // [GIVEN] POS Transaction
        CouponQty := Random(10) + 1;
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, CouponQty, TempCoupon);
        Commit();
        // [WHEN]
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        // [THEN] Change coupon line quantity
        _POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        POSSaleLineUnit.SetQuantity(CouponQty);

        // [THEN]
        //check discount line qty
        POSSaleLineUnit.SetLast();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        Assert.AreEqual(POSSaleLine.Quantity, CouponQty, 'Discount line quantity not according test scenario.');
        // finish transaction
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, 0, '');
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeCouponLineQtyInPOSTransactionFail()
    // [SCENARIO] Change Coupon Line Quantity should fail
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";
        POSSaleLine: Record "NPR POS Sale Line";
        CouponQty: Integer;
        QtyErr: Label 'Coupon quantity is %1 but you want to use %2. Action aborted.';
    begin
        Initialize();
        // [GIVEN] POS Transaction
        CouponQty := Random(10) + 1;
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, CouponQty, TempCoupon);
        Commit();
        // [WHEN]
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        // [THEN] Change coupon line quantity
        _POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.SetFirst();
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
        asserterror POSSaleLineUnit.SetQuantity(CouponQty + 1);

        Assert.ExpectedError(StrSubstNo(QtyErr, CouponQty, CouponQty + 1));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GS1DiscountAmountTest()
    // [SCENARIO] Scan GS1 coupon, discount amount 1.5 is applied, transaction is ended
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryRandom: Codeunit "Library - Random";
        TransactionEnded: Boolean;
    begin
        Initialize();
        // [GIVEN] POS Transaction with 1 line
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        CreateItemTransaction(LibraryRandom.RandDecInRange(2, 100, LibraryRandom.RandIntInRange(0, 2)));
        // [WHEN]
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, '25554380000236153901015'); //3901 - 1 decimal place, 015 = 1.5

        // [THEN] Finish transaction with cash payment
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, _Item."Unit Price" - 1.5, '');
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentDefaultApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with a default application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));
        CouponQty := 1;

        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [GIVEN] Item in the POS Sale
        CreateItemTransaction(1000);

        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentDefaultApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with a default application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Item in the POS Sale
        CreateItemTransaction(1000);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");


        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountDefaultApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount amount when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with a default application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 200, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [GIVEN] Item in the POS Sale
        CreateItemTransaction(1000);

        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountDefaultApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount amount when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with default application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 200, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Item in the POS Sale
        CreateItemTransaction(1000);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentExtraItemApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an extra item application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentExtraItemApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an extra item application
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession,
                                                           _POSUnit,
                                                           POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountExtraItemApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an extra item application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountExtraItemApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an extra item application
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentExtraItemQtyApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an extra item qty application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraItem: Record Item;
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be used to trigger the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ExtraItem, _POSUnit, _POSStore);

        ExtraItem."Unit Price" := 500;
        ExtraItem.Modify(true);

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetExtraQtyItemCoupon(CouponType, ExtraItem, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentExtraItemQtyApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an extra item qty application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraItem: Record Item;
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be used to trigger the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ExtraItem, _POSUnit, _POSStore);

        ExtraItem."Unit Price" := 500;
        ExtraItem.Modify(true);

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetExtraQtyItemCoupon(CouponType, ExtraItem, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale and extra item added to the pos sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountExtraItemQtyApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an extra item qty application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        ExtraItem: Record Item;
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be used to trigger the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ExtraItem, _POSUnit, _POSStore);

        ExtraItem."Unit Price" := 500;
        ExtraItem.Modify(true);

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetExtraQtyItemCoupon(CouponType, ExtraItem, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountExtraItemQtyApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an extra item qty application
    var
        ExtraItem: Record Item;
        DiscountedItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be used to trigger the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ExtraItem, _POSUnit, _POSStore);

        ExtraItem."Unit Price" := 500;
        ExtraItem.Modify(true);

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetExtraQtyItemCoupon(CouponType, ExtraItem, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned and the extra item has been added to the pos sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentItemListApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an item list application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted Item that is going to get the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntPercentItemListApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an item list application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned in the POS Sale and extra item added to the pos sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountItemListApplicationNoVATCustomerAddedAfterCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an Item List application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDisocuntAmountItemListApplicationNoVATCustomerAddedBeforeCoupon()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale before a coupon has been added with an item list application
    var
        DiscountedItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [When] Coupon Scanned and the extra item has been added to the pos sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        NPRLibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

    end;

    [Test]
    [HandlerFunctions('OpenPageHandler')]

    [TestPermissions(TestPermissions::Disabled)]

    procedure VerifyCoupon()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        NPNpDCCouponCheck: Codeunit "NPR POSAction: Coupon Verify B";
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, 1, TempCoupon);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //[WHEN] when
        NPNpDCCouponCheck.VerifyCoupon(TempCoupon."Reference No.");
    end;

    [ModalPageHandler]
    procedure OpenPageHandler(var CouponCard: TestPage "NPR NpDc Coupon Card")
    var
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(true, 'Page opened.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueCoupon()
    var
        CouponTypeCode: Code[20];
        Quantity: Integer;
        NpDcModuleIssueOnSaleB: Codeunit "NPR POSAction Issue DC OnSaleB";
        InstantIssue: Boolean;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        DiscountPct: Decimal;
        LibraryUtility: Codeunit "Library - Utility";
        CouponType: Record "NPR NpDc Coupon Type";
        POSSale: Codeunit "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NewDiscCouponCpt: Label 'New Discount Coupon: %1';
        Assert: Codeunit Assert;
    begin
        Initialize();
        //[GIVEN] given
        Quantity := Random(10) + 1;
        DiscountPct := Random(100);
        InstantIssue := false;

        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        CouponTypeCode := LibraryUtility.GenerateRandomCode(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type");
        LibraryCoupon.CreateDiscountPctCouponType(CouponTypeCode, DiscountPct);
        Commit();
        //[WHEN] when
        NpDcModuleIssueOnSaleB.IssueCoupon(CouponTypeCode, Quantity, InstantIssue, POSSale);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        //[THEN] then
        Assert.IsTrue(SaleLinePOS.Count = Quantity, 'Quantity ok.');
        Assert.IsTrue(SaleLinePOS.FindFirst(), 'Line found');
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment, 'Comment Type');
        Assert.IsTrue(SaleLinePOS.Description = CopyStr(StrSubstNo(NewDiscCouponCpt, CouponType.Description), 1, MaxStrLen(SaleLinePOS.Description)), 'New description inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountPercentOnItemWithoutSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount percentage activity coupon on one item without a serial no that is applicable for an activity coupon discount
        // - Add one item without a serial no that is applicable for an activity coupon discount
        // - Apply one activity coupon with a percentage discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the discount % on coupon should be the same as on item
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountAmountOnItemWithoutSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount amount activity coupon on one item without a serial no that is applicable for an activity coupon discount
        // - Add one item without a serial no that is applicable for an activity coupon discount
        // - Apply one activity coupon with an amount discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the discount amount on coupon should be the same as on item
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountPercentOnItemWithoutSerialNoNotApplicable()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount percentage activity coupon on one item without a serial no that is NOT applicable for an activity coupon discount
        // - Add one item without a serial no that is NOT applicable for an activity coupon discount
        // - Apply one activity coupon with a percentage discount
        // - Check if the discount is not applied.

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetApplyActivityDiscountModule(CouponType);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the different which means that the discount % should not be applied on item
        Assert.AreEqual(SaleLinePOS."Discount %", 0, 'Discount % is applied which is not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountAmountOnItemWithoutSerialNoNotApplicable()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount amount activity coupon on one item without a serial no that is NOT applicable for an activity coupon discount
        // - Add one item without a serial no that is NOT applicable for an activity coupon discount
        // - Apply one activity coupon with an amount discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetApplyActivityDiscountModule(CouponType);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the different which means that the discount % should not be applied on item
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount amount is applied which is not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountPercentOnTwoItemWithoutSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply one discount percentage activity coupon on two items without a serial no that are applicable for an activity coupon discount
        // - Add two items without a serial no that are applicable for an activity coupon discount
        // - Apply one activity coupon with a percentage discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be the same as first item's discount % and should not be applied on the second item
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.01, 'Discount % not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount %", 0, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyDiscountAmountOnTwoItemWithoutSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply one discount amount activity coupon on two items without a serial no that are applicable for an activity coupon discount
        // - Add two items without a serial no that are applicable for an activity coupon discount
        // - Apply one activity coupon with an amount discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount on coupon should be the same as first item's discount amount and should not be applied on the second item
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", 0, 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountPercentOnTwoItemWithoutSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount percentage activity coupon on two items without a serial no that are applicable for an activity coupon discount
        // - Add two items without a serial no that are applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be the same as on both items on POS sale lines
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
        Assert.AreNearlyEqual(SaleLinePOSSecondItem."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountAmountOnTwoItemWithoutSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount amount activity coupon on two items without a serial no that are applicable for an activity coupon discount
        // - Add two items without a serial no that are applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount on coupon should be the same as on both items on POS sale lines
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountPercentOnTwoItemOneApplicableOneNot()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount percentage activity coupon on two items without a serial no one of which is applicable for an activity coupon discount, and one is not
        // - Add an item without a serial no that is applicable for an activity coupon discount
        // - Add an item without a serial no that is NOT applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be applied on one item and shold not be applied on other one
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount %", 0, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountAmountOnTwoItemOneApplicableOneNot()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount amount activity coupon on two items without a serial no one of which is applicable for an activity coupon discount, and one is not
        // - Add an item without a serial no that is applicable for an activity coupon discount
        // - Add an item without a serial no that is NOT applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLine(_POSSession, Item1."No.", 1);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be applied on one item and shold not be applied on other one
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", 0, 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwiceDiscountPercentOnItemWithSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice discount percentage activity coupon on one item with a serial no that is applicable for an activity coupon discount
        // - Add an item with a serial no that is applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryCoupon.CreateItemTrackingAndAssignToItem(Item, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] Only one discount percentage should be applied on item
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwiceDiscountAmountOnItemWithSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice discount amount activity coupon on one item with a serial no that is applicable for an activity coupon discount
        // - Add an item with a serial no that is applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryCoupon.CreateItemTrackingAndAssignToItem(Item, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] Only one discount amount should be applied on item
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyOneDiscountPercentOnItemWithSerialNoNotApplicable()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount percentage activity coupon on one item with a serial no that is NOT applicable for an activity coupon discount
        // - Add one item with  a serial no that is NOT applicable for an activity coupon discount
        // - Apply one activity coupon with a discount percentage
        // - Check if the discount is not applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryCoupon.CreateItemTrackingAndAssignToItem(Item, ItemTrackingCode);

        LibraryCoupon.SetApplyActivityDiscountModule(CouponType);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] Discount % should not be applied on item
        Assert.AreEqual(SaleLinePOS."Discount %", 0, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyOneDiscountAmountOnItemWithSerialNoNotApplicable()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply a discount amount activity coupon on one item with a serial no that is NOT applicable for an activity coupon discount
        // - Add one item with  a serial no that is NOT applicable for an activity coupon discount
        // - Apply one activity coupon with a discount amount
        // - Check if the discount is not applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryCoupon.CreateItemTrackingAndAssignToItem(Item, ItemTrackingCode);

        LibraryCoupon.SetApplyActivityDiscountModule(CouponType);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] Discount amount should not be applied on item
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyOneDiscountPercentOnTwoItemWithSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply one discount percentage activity coupon on two items with a serial no that are applicable for an activity coupon discount
        // - Add two items with a serial no that are applicable for an activity coupon discount
        // - Apply one activity coupon with a percentage discount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be the same as first item's discount % and should not be applied on the second item
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount %", 0, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyOneDiscountAmountOnTwoItemWithSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply one discount amount activity coupon on two items with a serial no that are applicable for an activity coupon discount
        // - Add two items with a serial no that are applicable for an activity coupon discount
        // - Apply one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 1;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount on coupon should be the same as first item's discount amount and should not be applied on the second item
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", 0, 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountPercentOnTwoItemWithSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount percentage activity coupon on two items with a serial no that are applicable for an activity coupon discount
        // - Add two items with a serial no that are applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be the same on both POS sale lines
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
        Assert.AreNearlyEqual(SaleLinePOSSecondItem."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountAmountOnTwoItemWithSerialNo()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount amount activity coupon on two items with a serial no that are applicable for an activity coupon discount
        // - Add two items with a serial no that are applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCouponTwice(CouponType, Item, Item1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount on coupon should be the same on both POS sale lines
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountPercentOnTwoItemsWithSerialNoOneApplicableOneNot()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount percentage activity coupon on two items with a serial no one of which is applicable for an activity coupon discount, and one is not
        // - Add an item with a serial no that is applicable for an activity coupon discount
        // - Add an item with a serial no that is NOT applicable for an activity coupon discount.
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % on coupon should be applied on first item, but not on second one
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.01, 'Discount % not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount %", 0, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwoDiscountAmountOnTwoItemsWithSerialNoOneApplicableOneNot()
    var
        Item: Record Item;
        Item1: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ItemTrackingCode: Record "Item Tracking Code";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSSecondItem: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount amount activity coupon on two items with a serial no one of which is applicable for an activity coupon discount, and one is not
        // - Add an item with a serial no that is applicable for an activity coupon discount
        // - Add an item with a serial no that is NOT applicable for an activity coupon discount.
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Two Item with tracking in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item1, _POSUnit, _POSStore);
        LibraryCoupon.CreateTwoItemTrackingAndAssignToItem(Item, Item1, ItemTrackingCode);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item."No.", 1, LibraryUtility.GenerateRandomCode20(Item.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LibraryPOSMock.CreateItemLineWithSerialNo(_POSSession, Item1."No.", 1, LibraryUtility.GenerateRandomCode20(Item1.FieldNo("Serial Nos."), Database::Item));
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSSecondItem);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount on coupon should be applied on first item, but not on second one
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOSSecondItem."Discount Amount", 0, 'Discount amount not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwiceDiscountPercentOnItemWithoutSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount percentage activity coupon on one item without a serial no that is applicable for an activity coupon discount
        // - Add one item without a serial no that is applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount percentage
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount % should only be applied once
        Assert.AreNearlyEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 0.1, 'Discount % not calcualted according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ActivityCouponApplyTwiceDiscountAmountOnItemWithoutSerialNo()
    var
        Item: Record Item;
        CouponType: Record "NPR NpDc Coupon Type";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
    begin
        // [SCENARIO] Apply twice a discount amount activity coupon on one item without a serial no that is applicable for an activity coupon discount
        // - Add one item without a serial no that is applicable for an activity coupon discount
        // - Apply twice one activity coupon with a discount amount
        // - Check if the discount is correctly applied

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 1, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryCoupon.SetItemListActivityCoupon(CouponType, Item, 1);

        CouponQty := 2;
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount should only be applied once
        Assert.AreEqual(SaleLinePOS."Discount Amount", TempCoupon."Discount Amount", 'Discount amount not calcualted according to test scenario.');
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);

            CreateDiscountType(100, _Item."No.");
            CreateGS1DiscountTypeAmount();

            _Initialized := true;
        end;
        Commit();
    end;

    local procedure CreateDiscountType(DiscountPct: Decimal; ItemNo: Code[20])
    var
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(_CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), _CouponType, DiscountPct);
        LibraryCoupon.SetExtraItemCoupon(_CouponType, ItemNo);
    end;

    local procedure CreateItemTransaction(ItemPrice: Decimal)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        _Item.Get(_Item."No.");
        _Item."Unit Price" := ItemPrice;
        _Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);
    end;

    local procedure CreateGS1DiscountTypeAmount()
    var
        NpDcCouponType: Record "NPR NpDc Coupon Type";
        NpDcModuleApplyGS1: Codeunit "NPR NpDc Module Apply GS1";
        LibraryERM: Codeunit "Library - ERM";
        VATPostSetup: Record "VAT Posting Setup";
        GLAccountNo: Code[20];
    begin
        CreateGS1CouponType(NpDcCouponType, 0);
        LibraryERM.FindVATPostingSetup(VATPostSetup, "Tax Calculation Type"::"Normal VAT");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostSetup, "General Posting Type"::Sale);
        NpDcCouponType."GS1 Account No." := GLAccountNo;
        NpDcCouponType."Apply Discount Module" := NpDcModuleApplyGS1.ModuleCode();
        NpDcCouponType.Modify();
    end;

    procedure CreateGS1CouponType(var CouponType: Record "NPR NpDc Coupon Type"; DiscountType: Option)
    begin
        CouponType.Init();
        CouponType.Code := _GS1Lbl;
        CouponType."Issue Coupon Module" := _GS1Lbl;
        CouponType.Description := _GS1Lbl;
        CouponType."Issue Coupon Module" := _GS1Lbl;
        CouponType."Validate Coupon Module" := 'DEFAULT';
        CouponType."Apply Discount Module" := 'DEFAULT';
        CouponType."Discount Type" := DiscountType;
        CouponType."Starting Date" := CreateDateTime(Today(), 0T);
        CouponType.Enabled := true;
        CouponType.Insert();
    end;
}
