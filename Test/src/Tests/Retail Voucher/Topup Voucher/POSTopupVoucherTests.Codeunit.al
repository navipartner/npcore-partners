codeunit 85093 "NPR POS Top-up Voucher Tests"
{
    Subtype = Test;

    var
        VoucherTypePartial: Record "NPR NpRv Voucher Type";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FindVoucherByReference()
    var
        Voucher: Record "NPR NpRv Voucher";
        Assert: Codeunit Assert;
        POSActionTopUpB: Codeunit "NPR POS Act. Voucher Top-up-B";
        VoucherNo: Code[20];
    begin
        Initialize();
        // [GIVEN] Voucher created
        CreateVoucher(Voucher);
        // [WHEN]
        VoucherNo := POSActionTopUpB.FindVoucher('', Voucher."Reference No.");
        // [THEN]
        Assert.IsTrue(VoucherNo = Voucher."No.", 'Voucher is find.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TopUpPartialVoucher()
    var
        Voucher: Record "NPR NpRv Voucher";
        SalesLinePOS: Record "NPR POS Sale Line";
        Assert: Codeunit Assert;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        VoucherAmount: Decimal;
    begin
        // [GIVEN]
        Initialize();
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        VoucherAmount := GetRandomVoucherAmount(VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created
        CreateVoucher(Voucher);

        //[WHEN] Create new transaction use whole voucher amount
        NpRvVoucherMgt.TopUpVoucher(POSSession, Voucher."No.", '', VoucherAmount, 0, 0);

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(SalesLinePOS);
        // [THEN] Check
        Assert.IsTrue(SalesLinePOS."Line Type" = SalesLinePOS."Line Type"::"Issue Voucher", 'Voucher is inserted');
        Assert.IsTrue(SalesLinePOS."Unit Price" = VoucherAmount, 'Voucher amount is correct');
    end;

    procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if Initialized then begin
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePartialVoucherType(VoucherTypePartial, false);

            Initialized := true;
        end;

        Commit();
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

    local procedure CreateVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.GenerateTempVoucher(VoucherTypePartial, TempVoucher);
        Voucher.TransferFields(TempVoucher);
        Voucher.Validate("Allow Top-up", true);
        Voucher.Insert(true);
    end;
}