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
    procedure IssueCoupon()
    var
        CouponTypeCode: Code[20];
        Quantity: Integer;
        NpDcModuleIssueOnSaleB: Codeunit "NPR NpDc Module Issue: OnSaleB";
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
}
