codeunit 85076 "NPR POS Cash Voucher Tests"
{
    Subtype = Test;

    var
        Item: Record Item;
        NpRvVoucher: Record "NPR NpRv Voucher";
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        VoucherTypePartial: Record "NPR NpRv Voucher Type";
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        CashoutVoucherB: Codeunit "NPR Cashout Voucher B";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherApplicationWithoutCommision()
    var
        SalePOS: Record "NPR POS Sale";
        PaymentLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        TransactionEnded: Boolean;
        VoucherAmount: Decimal;
    begin
        //[SCENARIO]
        //Voucher Application without commision
        // [Given] POS & Payment setup
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        // Voucher issued
        VoucherAmount := GetRandomVoucherAmount(VoucherTypeDefault."Payment Type");
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, VoucherTypeDefault.Code);

        //[When]
        CashoutVoucherB.ApplyVoucherPayment(NpRvVoucher."Voucher Type", NpRvVoucher."Reference No.", POSSale, POSPaymentLine, SaleLine);

        //[Then]
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSPaymentLine.GetCurrentPaymentLine(PaymentLinePOS);
        Assert.IsTrue(PaymentLinePOS."Amount Including VAT" = VoucherAmount, 'Voucher full application');

        //[Then]
        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Comment, 'Comment is inserted');
        Assert.IsTrue(SaleLinePOS.Description = ('Cashout ' + NpRvVoucher.Description), 'Comment Description relatable');

        //[Then]
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, VoucherAmount, '');
        Assert.AreEqual(true, TransactionEnded, 'Transaction is ended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherApplicationWithCommisionTypePercentage()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        TransactionEnded: Boolean;
        AccountNo: Code[20];
        CommisionAmount: Decimal;
        CommisionPercentage: Decimal;
        VoucherAmount: Decimal;
        CommisionType: Option Percentage,Amount;
    begin
        //[SCENARIO]
        //Voucher Application with adding commision as percentage
        // [Given] POS & Payment setup
        Initialize();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        // Voucher already issued
        VoucherAmount := GetRandomVoucherAmount(VoucherTypeDefault."Payment Type");
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, VoucherTypeDefault.Code);
        // [Given] Commision Account And Commision Percentage
        AccountNo := LibraryERM.CreateGLAccountWithPurchSetup();
        CommisionPercentage := LibraryRandom.RandDecInRange(0, 1, 4);
        CommisionAmount := Round(VoucherAmount * CommisionPercentage / 100, POSPaymentMethodCash."Rounding Precision", POSPaymentMethodCash.GetRoundingType());
        //[When]
        CashoutVoucherB.ApplyVoucherPayment(NpRvVoucher."Voucher Type", NpRvVoucher."Reference No.", POSSale, POSPaymentLine, SaleLine);
        CashoutVoucherB.InsertCommision(AccountNo, VoucherTypeDefault.Code, CommisionType::Percentage, CommisionPercentage, POSPaymentLine, SaleLine);
        //[Then] Retrieve voucher
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."No." = AccountNo, 'GL account is inserted');
        Assert.IsTrue(SaleLinePOS.Description = ('Fee ' + Format(CommisionPercentage) + '%'), 'Commision Description relatable');
        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = CommisionAmount, 'Commision Amount is correct');
        //[Then] 
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, VoucherAmount - CommisionAmount, '');
        Assert.AreEqual(true, TransactionEnded, 'Transaction is ended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherApplicationWithCommisionTypeAmount()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        TransactionEnded: Boolean;
        AccountNo: Code[20];
        CommisionAmount: Decimal;
        VoucherAmount: Decimal;
        Pct: Decimal;
        CommisionType: Option Percentage,Amount;
        GLSetup: Record "General Ledger Setup";
    begin
        //[SCENARIO]
        //Voucher Application with adding commision as amount
        // [Given] POS & Payment setup
        Initialize();
        GLSetup.Get();
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(SaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        // Voucher already issued
        VoucherAmount := GetRandomVoucherAmount(VoucherTypeDefault."Payment Type");
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, VoucherTypeDefault.Code);
        // [Given] Commision Account And Commision Amount
        AccountNo := LibraryERM.CreateGLAccountWithPurchSetup();

        Pct := LibraryRandom.RandDecInRange(5, 15, 4);
        CommisionAmount := LibraryRandom.RandDecInRange(1, Round(VoucherAmount * Pct / 100, 1, '='), 4);
        CommisionAmount := Round(CommisionAmount, POSPaymentMethodCash."Rounding Precision", POSPaymentMethodCash.GetRoundingType());
        //[When]
        CashoutVoucherB.ApplyVoucherPayment(NpRvVoucher."Voucher Type", NpRvVoucher."Reference No.", POSSale, POSPaymentLine, SaleLine);
        CashoutVoucherB.InsertCommision(AccountNo, VoucherTypeDefault.Code, CommisionType::Amount, CommisionAmount, POSPaymentLine, SaleLine);
        //[Then] Retrieve voucher
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        Assert.IsTrue(SaleLinePOS."No." = AccountNo, 'GL account is inserted');
        Assert.IsTrue(SaleLinePOS.Description = ('Fee ' + Format(CommisionAmount) + GLSetup."LCY Code"), 'Commision Description relatable');
        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = CommisionAmount, 'Commision Amount is correct');
        //[Then] 
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, VoucherAmount - CommisionAmount, '');
        Assert.AreEqual(true, TransactionEnded, 'Transaction is ended');
    end;

    procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePartialVoucherType(VoucherTypePartial, false);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherTypeDefault, false);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);

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
        exit(Round(LibraryRandom.RandDecInRange(100, 10000, LibraryRandom.RandIntInRange(0, 2)), 0.01));
    end;

    local procedure CreateVoucherInPOSTransaction(var NpRvVoucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal; VoucherTypeCode: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(POSSession, VoucherTypeCode, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethodCash.Code, VoucherAmount, '');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        NpRvVoucher.SetRange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.SetRange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.SetRange("Voucher Type", VoucherTypeCode);
        NpRvVoucher.FindFirst();
    end;
}