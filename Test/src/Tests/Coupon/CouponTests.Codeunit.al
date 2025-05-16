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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        TransactionEnded: Boolean;
    begin
        Initialize();
        // [GIVEN] POS Transaction
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, 1, TempCoupon);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN]
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, 0, '');
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
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
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
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
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, 0, '');
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
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
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryRandom: Codeunit "Library - Random";
        TransactionEnded: Boolean;
    begin
        Initialize();
        // [GIVEN] POS Transaction with 1 line
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        CreateItemTransaction(LibraryRandom.RandDecInRange(2, 100, LibraryRandom.RandIntInRange(0, 2)));
        // [WHEN]
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, '25554380000236153901015'); //3901 - 1 decimal place, 015 = 1.5

        // [THEN] Finish transaction with cash payment
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, _Item."Unit Price" - 1.5, '');
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentDefaultApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));
        CouponQty := 1;

        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Item in the POS Sale
        CreateItemTransaction(1000);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentDefaultApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with a default application and applied two times
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));
        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);

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
        // [THEN] Check if coupon entry discount amount is calculated properly
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", SumCouponDiscountPercentForApplicationNumber(TempCoupon."Discount %", 2), 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentDefaultApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentDefaultApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * SaleLinePOS."Discount %" / 100;

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", SumCouponDiscountPercentForApplicationNumber(TempCoupon."Discount %", 2), 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountDefaultApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountDefaultApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 200, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        Assert.AreEqual(TempCoupon."Discount Amount" * 2, SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountDefaultApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountDefaultApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 200, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount" * 2, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
    // [SCENARIO] Check discount percent when a Customer that doesnt requre VAT has been added to the POS Sale after a coupon has been added with an extra item application
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        ExtraItemSaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        CouponType: Record "NPR NpDc Coupon Type";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        Item: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [GIVEN] Coupon Scanned in the POS Sale two times
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(ExtraItemSaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;
        ExtraItemSaleLinePOSBeforeCustomerAssignment := ExtraItemSaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);
        ExtraItemSaleLinePOS.Get(ExtraItemSaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Amount Including VAT", ExtraItemSaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(ExtraItemSaleLinePOS."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;

        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession,
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

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession,
                                                           _POSUnit,
                                                           POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(ExtraItemSaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem := NPRPOSSaleTaxCalc.UnitPriceExclTax(ExtraItemSaleLinePOS) * ExtraItemSaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignmentExtraItem, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        ExtraItemSaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(ExtraItemSaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;
        ExtraItemSaleLinePOSBeforeCustomerAssignment := ExtraItemSaleLinePOS;

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);
        ExtraItemSaleLinePOS.Get(ExtraItemSaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Amount Including VAT", ExtraItemSaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(ExtraItemSaleLinePOS."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Extra item that is going to be added to the transaction when the coupon is scanned
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        Item."Unit Price" := 1000;
        Item.Modify(true);

        LibraryCoupon.SetExtraItemCoupon(CouponType, Item."No.");

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(ExtraItemSaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", ExtraItemSaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignmentExtraItem, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemQtyApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemQtyApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        ExtraItemSaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
        LineNo: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LineNo := SaleLinePOS."Line No.";
        ExtraItemSaleLinePOS.SetFilter("Line No.", '<>%1', LineNo);
        ExtraItemSaleLinePOS.FindLast();

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;
        ExtraItemSaleLinePOSBeforeCustomerAssignment := ExtraItemSaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that doesnt require the prices in the pos sale to have VAT
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        SaleLinePOS.Get(SaleLinePOS.RecordId);
        ExtraItemSaleLinePOS.Get(ExtraItemSaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Amount Including VAT", ExtraItemSaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(ExtraItemSaleLinePOS."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemQtyApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentExtraItemQtyApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
        LineNo: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LineNo := SaleLinePOS."Line No.";
        ExtraItemSaleLinePOS.SetFilter("Line No.", '<>%1', LineNo);
        ExtraItemSaleLinePOS.FindLast();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem := NPRPOSSaleTaxCalc.UnitPriceExclTax(ExtraItemSaleLinePOS) * ExtraItemSaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignmentExtraItem, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemQtyApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemQtyApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        ExtraItemSaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
        LineNo: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);


        // [GIVEN] Coupon Scanned in the POS Sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LineNo := SaleLinePOS."Line No.";
        ExtraItemSaleLinePOS.SetFilter("Line No.", '<>%1', LineNo);
        ExtraItemSaleLinePOS.FindLast();

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;
        ExtraItemSaleLinePOSBeforeCustomerAssignment := ExtraItemSaleLinePOS;

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
        ExtraItemSaleLinePOS.Get(ExtraItemSaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        Assert.AreEqual(ExtraItemSaleLinePOS."Amount Including VAT", ExtraItemSaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(ExtraItemSaleLinePOS."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        Assert.AreEqual(TempCoupon."Discount Amount", ExtraItemSaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemQtyApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountExtraItemQtyApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        ExtraItemSaleLinePOS: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SecondNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        SecondNpDcArchCouponEntryAmount: Decimal;
        LineNo: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, ExtraItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        LineNo := SaleLinePOS."Line No.";
        ExtraItemSaleLinePOS.SetFilter("Line No.", '<>%1', LineNo);
        ExtraItemSaleLinePOS.FindLast();

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");
        DiscountAmountWithoutVATAftereCouponAssignmentExtraItem := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", ExtraItemSaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(ExtraItemSaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignmentExtraItem, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", ExtraItemSaleLinePOS.Date, ExtraItemSaleLinePOS."Line No.", ExtraItemSaleLinePOS."Discount Amount", CouponType, SecondNpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;
        GetCouponEntryAmountAfterPosting(ExtraItemSaleLinePOS."Register No.", ExtraItemSaleLinePOS."Sales Ticket No.", SecondNpDcArchCouponEntryAmount);
        SecondNpDcArchCouponEntryAmount := SecondNpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
        Assert.AreEqual(SecondNpDcArchCouponEntryAmount, SecondNpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentItemListApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentItemListApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();


        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted Item that is going to get the discount
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

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
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %" * 2, 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentItemListApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountPercentItemListApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.UnitPriceExclTax(SaleLinePOS) * SaleLinePOS.Quantity * TempCoupon."Discount %" / 100;

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount %", TempCoupon."Discount %" * 2, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment * 2, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationNoVATCustomerAddedAfterCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationNoVATCustomerAddedAfterCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

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
        Assert.AreEqual(TempCoupon."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount" / 2, 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationNoVATCustomerAddedBeforeCoupon()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

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

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationNoVATCustomerAddedBeforeCouponAppliedTwice()
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        DiscountAmountWithoutVATAftereCouponAssignment: Decimal;
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
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
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        DiscountAmountWithoutVATAftereCouponAssignment := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(TempCoupon."Discount Amount", SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount including VAT should be the same which means that the amount including vat should be the same as it was before the customer assignment
        Assert.AreEqual(SaleLinePOS."Discount Amount", DiscountAmountWithoutVATAftereCouponAssignment * 2, 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [HandlerFunctions('OpenPageHandler')]

    [TestPermissions(TestPermissions::Disabled)]

    procedure VerifyCoupon()
    var
        SalePOS: Record "NPR POS Sale";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        NPNpDCCouponCheck: Codeunit "NPR POSAction: Coupon Verify B";
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryCoupon.IssueCouponMultipleQuantity(_CouponType, 1, TempCoupon);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
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

        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        Item."Unit Price" := 500;
        Item.Modify(true);

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
        Item."Unit Price" := 500;
        Item.Modify(true);

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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(0, NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(0, NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT" + NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT" + NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(0, NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecond: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecond);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(0, NpDcSaleLinePOSCouponSecond."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        Item."Unit Price" := 500;
        Item.Modify(true);
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
        Item."Unit Price" := 500;
        Item.Modify(true);
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;

        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);
        NpDcArchCouponEntryAmount := NpDcArchCouponEntryAmount / CouponQty;

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcSaleLinePOSCouponSecondItem: Record "NPR NpDc SaleLinePOS Coupon";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);
        Item1."Unit Price" := 500;
        Item1.Modify(true);
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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);
        CheckCouponAmountsBeforePosting(SaleLinePOSSecondItem."Register No.", SaleLinePOSSecondItem."Sales Ticket No.", SaleLinePOSSecondItem.Date, SaleLinePOSSecondItem."Line No.", SaleLinePOSSecondItem."Discount Amount", CouponType, NpDcSaleLinePOSCouponSecondItem);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
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
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcArchCouponEntryAmount: Decimal;
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
        Item."Unit Price" := 500;
        Item.Modify(true);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponApplicationMultipleCouponsWhenDiscountOnTransactionAndCustomerNoVatAddedAtTheEnd()
    // [SCENARIO] Check discount when mutliple coupon applied and discount on transaction with customer without VAT added at the end 
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        CouponQty: Integer;
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        LineAmountRemaining: Decimal;
        NpDcArchCouponEntryAmount: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Item in the POS Sale with discount
        CreateItemTransaction(1000);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        DiscountType := DiscountType::LineDiscountPercentABS;
        DiscountPct := 10;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountPct, SalePOS, SaleLinePOS, 0);
        LineAmountRemaining := 1 - DiscountPct / 100;

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LineAmountRemaining *= 1 - TempCoupon."Discount %" / 100;
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LineAmountRemaining *= 1 - TempCoupon."Discount %" / 100;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [Given] Customer added to the POS sale that doesn't require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        // [THEN] Check if coupon entry discount amount is calculated properly
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", 100 * (1 - LineAmountRemaining), 'Discount not calcualted according to test scenario.');
        Assert.AreNotEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        DiscountAmount := SaleLinePOS."Unit Price" * DiscountPct / 100;
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount" - DiscountAmount, CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponApplicationMultipleCouponsWhenDiscountOnTransactionAndCustomerNoVatAddedAtStart()
    var    // [SCENARIO] Check discount when mutliple coupon applied and discount on transaction with customer without VAT added at the start 

        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        CouponQty: Integer;
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that doesn't require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", false);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [GIVEN] Item in the POS Sale with discount
        CreateItemTransaction(1000);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        DiscountType := DiscountType::LineDiscountPercentABS;
        DiscountPct := 10;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountPct, SalePOS, SaleLinePOS, 0);

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        DiscountAmount := SaleLinePOS."Unit Price" * DiscountPct / 100;

        //[THEN] Check if coupon entry discount amount and discount percent on POS Sales Line is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount" - DiscountAmount, CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponApplicationMultipleCouponsWhenDiscountOnTransactionAndCustomerWithVatAddedAtTheEnd()
    // [SCENARIO] Check discount when multiple coupons aplied and discount is on transaction with customer with VAT added at the end 
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        CouponQty: Integer;
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        LineAmountRemaining: Decimal;
        NpDcArchCouponEntryAmount: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Item in the POS Sale with discount
        CreateItemTransaction(1000);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        DiscountType := DiscountType::LineDiscountPercentABS;
        DiscountPct := 10;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountPct, SalePOS, SaleLinePOS, 0);
        LineAmountRemaining := 1 - DiscountPct / 100;

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LineAmountRemaining *= 1 - TempCoupon."Discount %" / 100;
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LineAmountRemaining *= 1 - TempCoupon."Discount %" / 100;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [Given] Customer added to the POS sale that require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", true);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount should be the same which means that the amount including vat should be the same as it was before the customer assignment
        //[THEN] Check if coupon entry discount amount is calculated properly
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", SaleLinePOSBeforeCustomerAssignment."Amount Including VAT", 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount %", 100 * (1 - LineAmountRemaining), 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');
        DiscountAmount := SaleLinePOS."Unit Price" * DiscountPct / 100;
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount" - DiscountAmount, CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponApplicationMultipleCouponsWhenDiscountOnTransactionAndCustomerWithVatAddedAtStart()
    // [SCENARIO] Check discount when multiple coupons aplied and discount is on transaction with customer with VAT added at the start 
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CouponQty: Integer;
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        AmountToPay: Decimal;
        TransactionEnded: Boolean;
        NpDcArchCouponEntryAmount: Decimal;
        LineAmountRemaining: Decimal;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountPctCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 50, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [Given] Customer added to the POS sale that require the prices in the pos sale to have VAT
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", true);
        Customer.Modify(true);

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);

        // [GIVEN] Item in the POS Sale with discount
        CreateItemTransaction(1000);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        DiscountType := DiscountType::LineDiscountPercentABS;
        DiscountPct := 10;
        POSActionDiscountB.ProcessRequest(DiscountType, DiscountPct, SalePOS, SaleLinePOS, 0);
        LineAmountRemaining := 1 - DiscountPct / 100;

        // [When] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        DiscountAmount := SaleLinePOS."Unit Price" * DiscountPct / 100;

        //[THEN] Check if coupon entry discount amount and discount percent on POS Sales Line is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount" - DiscountAmount, CouponType, NpDcSaleLinePOSCoupon);

        AmountToPay := GetAmountToPay();
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, AmountToPay, '');
        // [THEN] Verify that transaction has ended successfuly
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        GetCouponEntryAmountAfterPosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", NpDcArchCouponEntryAmount);

        // [THEN] Check if coupon entries amount is calculated correctly
        Assert.AreEqual(NpDcArchCouponEntryAmount, NpDcSaleLinePOSCoupon."Discount Amount Including VAT", 'Amount on coupon entries not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationCouponOverappliedThenDeleted()
    // [SCENARIO] Check discount amount when coupon has been added with an Item List application and deleted after that
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActDeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 600, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.Get(SaleLinePOS.RecordId);

        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] The discount amount after overapplying the coupons should be equal to unit price and amount including VAT 0
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", 0, 'Discount not calcualted according to test scenario.');
        Assert.AreEqual(SaleLinePOS."Discount Amount", SaleLinePOS."Unit Price", 'Discount not calcualted according to test scenario.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        // [WHEN] Delete coupons from pos sale
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);

        // [THEN] Check if sale line with item has discount amount equal to 0 after deleting the coupons
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount not calcualted propery after deleting the coupons.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationNoVATCustomerCouponOverappliedThenDeleted()
    // [SCENARIO] Check discount amount when a customer that doesnt requre VAT has been added to the POS sale after a coupon has been added with an Item List application and deleted after that
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActDeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 600, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

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

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        // [WHEN] Delete coupons from pos sale
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);

        // [THEN] Check if sale line with item has discount amount equal to 0 after deleting the coupons
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount not calcualted propery after deleting the coupons.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountAmountItemListApplicationWithVATCustomerCouponOverappliedThenDeleted()
    // [SCENARIO] Check discount amount when a customer that requires VAT has been added to the POS sale after a coupon has been added with an Item List application and deleted after that
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Customer: Record Customer;
        SaleLinePOSBeforeCustomerAssignment: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActDeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        CouponQty: Integer;
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Percent Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 600, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);

        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 2;
        CouponType."Max Use per Sale" := 2;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOSBeforeCustomerAssignment := SaleLinePOS;

        // [GIVEN] Customer without VAT;
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Prices Including VAT", true);
        Customer.Modify(true);

        // [WHEN] Customer added to the POS sale that requires the prices in the pos sale to have VAT
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
        Assert.AreEqual(SaleLinePOS."Discount Amount", SaleLinePOSBeforeCustomerAssignment."Discount Amount", 'Discount not calcualted propery after customer without VAT assignment.');

        //[THEN] Check if coupon entry discount amount is calculated properly
        CheckCouponAmountsBeforePosting(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Line No.", SaleLinePOS."Discount Amount", CouponType, NpDcSaleLinePOSCoupon);

        // [WHEN] Delete coupons from pos sale
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);

        // [THEN] Check if sale line with item has discount amount equal to 0 after deleting the coupons
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount not calcualted propery after deleting the coupons.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountApplicationAfterQtyChangeOnItem()
    // [SCENARIO] Check if the coupon discount is calculated correctly after quantity change on the item where the coupon is applied
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        DiscountedItem: Record Item;
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActDeletePOSLineB: Codeunit "NPR POSAct:Delete POS Line-B";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        CouponQty: Integer;
    begin
        if not FeatureFlagsManagement.IsEnabled('removeCouponDiscountAfterChangeQuantity') then
            exit;

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 600, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Discounted item that is going to get the discount when the coupon is added
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(DiscountedItem, _POSUnit, _POSStore);
        DiscountedItem."Unit Price" := 1000;
        DiscountedItem.Modify(true);

        LibraryCoupon.SetItemListCoupon(CouponType, DiscountedItem, 1);

        CouponQty := 1;
        CouponType."Max Use per Sale" := 1;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        LibraryPOSMock.CreateItemLine(_POSSession, DiscountedItem."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        SaleLinePOS.Get(SaleLinePOS.RecordId);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon not activated');

        // [THEN] Check if discount applied correctly
        Assert.AreEqual(SaleLinePOS."Discount Amount", CouponType."Discount Amount", 'Discount not calcualted properly.');

        // [THEN] Change quantity on item sales line
        POSSaleLine.SetFirst();
        POSSaleLine.SetQuantity(5);
        SaleLinePOS.Get(SaleLinePOS.RecordId);

        // [THEN] Check if discount applied correctly. Discount should be the same as initial one, before quantity change
        Assert.AreEqual(SaleLinePOS."Discount Amount", CouponType."Discount Amount", 'Discount not calcualted properly.');

        // [WHEN] Delete coupon from pos sale
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        POSActDeletePOSLineB.DeleteSaleLine(POSSaleLine);

        // [THEN] Check if sale line with item has discount amount equal to 0 after deleting the coupons
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.AreEqual(SaleLinePOS."Discount Amount", 0, 'Discount not calcualted propery after deleting the coupons.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountItemListApplicationApplyDiscountLowestPriceWithTwoSameItemsDiffertentUOMs()
    // [SCENARIO] Check if coupon is correctly applied when there is item with different UOMs on sale. Apply discount - lowest price first.
    var
        LowerPriceSaleLinePOS: Record "NPR POS Sale Line";
        HigherPriceSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryInventory: Codeunit "Library - Inventory";
        CouponQty: Integer;
        ApplyDiscountOption: Option "Priority","Highest price","Lowest price";
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with 2 UOMs
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 5);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] ITEM_LIST coupon
        LibraryCoupon.SetItemListCouponApplyDiscountOption(CouponType, Item, 1, ApplyDiscountOption::"Lowest price", 0, 10000);
        CouponQty := 1;
        CouponType."Max Use per Sale" := 1;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] 1 item added 2 times on POS with different UOM on each line
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(LowerPriceSaleLinePOS);
        LowerPriceSaleLinePOS.Validate("Unit of Measure Code", UnitOfMeasure.Code);
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(HigherPriceSaleLinePOS);
        HigherPriceSaleLinePOS.Validate("Unit of Measure Code", SecondUnitOfMeasure.Code);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        LowerPriceSaleLinePOS.Get(LowerPriceSaleLinePOS.RecordId);
        HigherPriceSaleLinePOS.Get(HigherPriceSaleLinePOS.RecordId);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon no6t activated');

        // [THEN] Check if coupon applied on the line with the lowest price
        Assert.AreEqual(LowerPriceSaleLinePOS."Discount Amount", CouponType."Discount Amount", 'Discount not calcualted properly.');
        Assert.AreEqual(HigherPriceSaleLinePOS."Discount Amount", 0, 'Discount not calcualted properly.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountItemListApplicationApplyDiscountHighestPriceWithTwoSameItemsDiffertentUOMs()
    // [SCENARIO] Check if coupon is correctly applied when there is item with different UOMs on sale. Apply discount - highest price.
    var
        LowerPriceSaleLinePOS: Record "NPR POS Sale Line";
        HigherPriceSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryInventory: Codeunit "Library - Inventory";
        CouponQty: Integer;
        ApplyDiscountOption: Option "Priority","Highest price","Lowest price";
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Item with 2 UOMs
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 5);
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] ITEM_LIST coupon
        LibraryCoupon.SetItemListCouponApplyDiscountOption(CouponType, Item, 1, ApplyDiscountOption::"Highest price", 0, 10000);
        CouponQty := 1;
        CouponType."Max Use per Sale" := 1;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] 1 item added 2 times on POS with different UOM on each line
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(LowerPriceSaleLinePOS);
        LowerPriceSaleLinePOS.Validate("Unit of Measure Code", UnitOfMeasure.Code);
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(HigherPriceSaleLinePOS);
        HigherPriceSaleLinePOS.Validate("Unit of Measure Code", SecondUnitOfMeasure.Code);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        LowerPriceSaleLinePOS.Get(LowerPriceSaleLinePOS.RecordId);
        HigherPriceSaleLinePOS.Get(HigherPriceSaleLinePOS.RecordId);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon no6t activated');

        // [THEN] Check if coupon applied on the line with the lowest price
        Assert.AreEqual(HigherPriceSaleLinePOS."Discount Amount", CouponType."Discount Amount", 'Discount not calcualted properly.');
        Assert.AreEqual(LowerPriceSaleLinePOS."Discount Amount", 0, 'Discount not calcualted properly.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckCouponDiscountItemListApplicationApplyDiscountPriorityWithTwoSameItemsDiffertentUOMs()
    // [SCENARIO] Check if coupon is correctly applied when there are 2 items on sale. Apply discount - priority.
    var
        HigherPrioritySaleLinePOS: Record "NPR POS Sale Line";
        LowerPrioritySaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSCoupon: Record "NPR POS Sale Line";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponType: Record "NPR NpDc Coupon Type";
        Item: Record Item;
        SecondItem: Record Item;
        LibraryCoupon: Codeunit "NPR Library Coupon";
        Assert: Codeunit Assert;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        LibraryUtility: Codeunit "Library - Utility";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryInventory: Codeunit "Library - Inventory";
        CouponQty: Integer;
        ApplyDiscountOption: Option "Priority","Highest price","Lowest price";
    begin
        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Coupon with Discount Amount Application
        LibraryCoupon.CreateDiscountAmountCouponType(LibraryUtility.GenerateRandomCode20(CouponType.FieldNo(Code), Database::"NPR NpDc Coupon Type"), CouponType, 500, LibraryUtility.GenerateRandomCode20(CouponType.FieldNo("Reference No. Pattern"), Database::"NPR NpDc Coupon Type"));

        // [GIVEN] Items
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 1000;
        Item.Modify();
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, _POSUnit, _POSStore);
        SecondItem."Unit Price" := 2000;
        SecondItem.Modify();

        // [GIVEN] ITEM_LIST coupon
        LibraryCoupon.SetItemListCouponApplyDiscountOption(CouponType, Item, 1, ApplyDiscountOption::Priority, 1, 10000);
        LibraryCoupon.SetItemListCouponApplyDiscountOption(CouponType, SecondItem, 1, ApplyDiscountOption::Priority, 0, 20000);
        CouponQty := 1;
        CouponType."Max Use per Sale" := 1;
        CouponType.Modify(true);
        LibraryCoupon.IssueCouponMultipleQuantity(LibraryUtility.GenerateRandomCode20(TempCoupon.FieldNo("No."), Database::"NPR NpDc Coupon"), CouponType, CouponQty, TempCoupon);

        // [GIVEN] 1 item added 2 times on POS with different UOM on each line
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(LowerPrioritySaleLinePOS);
        LibraryPOSMock.CreateItemLine(_POSSession, SecondItem."No.", 1);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(HigherPrioritySaleLinePOS);

        // [GIVEN] Coupon Scanned in the POS Sale
        LibraryCoupon.ScanCouponReferenceCode(_POSSession, TempCoupon."Reference No.");
        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSCoupon);
        LowerPrioritySaleLinePOS.Get(LowerPrioritySaleLinePOS.RecordId);
        HigherPrioritySaleLinePOS.Get(HigherPrioritySaleLinePOS.RecordId);

        // [THEN] Check if coupon activated
        Assert.IsTrue(SaleLinePOSCoupon."Line Type" = SaleLinePOSCoupon."Line Type"::Comment, 'Coupon not activated');
        Assert.IsTrue(SaleLinePOSCoupon.Description = CouponType.Description, 'Coupon no6t activated');

        // [THEN] Check if coupon applied on the line with the lowest price
        Assert.AreEqual(HigherPrioritySaleLinePOS."Discount Amount", CouponType."Discount Amount", 'Discount not calcualted properly.');
        Assert.AreEqual(LowerPrioritySaleLinePOS."Discount Amount", 0, 'Discount not calcualted properly.');
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

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
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        _Item.Get(_Item."No.");
        _Item."Unit Price" := ItemPrice;
        _Item.Modify();
        LibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
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

    local procedure CheckCouponAmountsBeforePosting(RegisterNo: Code[10]; SalesTicketNo: Code[20]; Date: Date; LineNo: Integer; SaleLinePOSDiscountAmount: Decimal; CouponType: Record "NPR NpDc Coupon Type"; var NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon")
    var
        Assert: Codeunit Assert;
    begin
        NpDcSaleLinePOSCoupon.Reset();
        NpDcSaleLinePOSCoupon.SetRange("Register No.", RegisterNo);
        NpDcSaleLinePOSCoupon.SetRange("Sales Ticket No.", SalesTicketNo);
        NpDcSaleLinePOSCoupon.SetRange("Sale Type", NpDcSaleLinePOSCoupon."Sale Type"::Sale);
        NpDcSaleLinePOSCoupon.SetRange("Sale Date", Date);
        NpDcSaleLinePOSCoupon.SetRange(Type, NpDcSaleLinePOSCoupon.Type::Discount);
        NpDcSaleLinePOSCoupon.SetRange("Sale Line No.", LineNo);
        NpDcSaleLinePOSCoupon.CalcSums("Discount Amount", "Discount Amount Including VAT");

        // [THEN] Check if discount amount on coupon line is calculated correct
        Assert.AreEqual(NpDcSaleLinePOSCoupon."Discount Amount", SaleLinePOSDiscountAmount, 'Discount not calcualted according to test scenario.');
    end;

    local procedure GetCouponEntryAmountAfterPosting(RegisterNo: Code[10]; SalesTicketNo: Code[20]; var NpDcArchCouponEntryAmount: Decimal)
    var
        NpDcArchCouponEntry: Record "NPR NpDc Arch.Coupon Entry";
    begin
        NpDcArchCouponEntry.SetRange("Entry Type", NpDcArchCouponEntry."Entry Type"::"Discount Application");
        NpDcArchCouponEntry.SetRange("Document No.", SalesTicketNo);
        NpDcArchCouponEntry.SetRange("Register No.", RegisterNo);
        NpDcArchCouponEntry.CalcSums(Amount);
        NpDcArchCouponEntryAmount := -NpDcArchCouponEntry.Amount;
    end;

    local procedure SumCouponDiscountPercentForApplicationNumber(DiscountPercent: Decimal; NumberOfApplications: Integer) SumCouponDiscountPercent: Decimal
    var
    begin
        SumCouponDiscountPercent := 100 * (1 - Power((1 - DiscountPercent / 100), NumberOfApplications))
    end;

    local procedure GetAmountToPay() AmountToPay: Decimal
    var
        POSSale: Codeunit "NPR POS Sale";
        PaidAmountOut: Decimal;
        ChangeAmountOut: Decimal;
        RoundingAmountOut: Decimal;
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetTotals(AmountToPay, PaidAmountOut, ChangeAmountOut, RoundingAmountOut);
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
