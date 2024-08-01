codeunit 85024 "NPR Retail Voucher Tests"
{
    // [Feature] Retail Voucher Test scenarios
    Subtype = Test;

    var
        _Item: Record "Item";
        _POSPaymentMethodCash: Record "NPR POS Payment Method";
        _POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _VoucherTypePartial: Record "NPR NpRv Voucher Type";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherInPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction - check NpRv Sales Line
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        Initialize();
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypePartial.Code, 1, 100, '', 0);
        // [THEN] Then NpRv Sales Line should exist
        NpRvSalesLine.Setrange("Register No.", SalePOS."Register No.");
        NpRvSalesLine.Setrange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        NpRvSalesLine.Setrange(Type, NpRvSalesLine.Type::"New Voucher");
        NpRvSalesLine.Setrange("Voucher Type", _VoucherTypePartial.Code);
        Assert.Istrue(NpRvSalesLine.FindFirst(), 'NpRv Sales Line exists with matching info issued voucher');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypePartial.Code, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount, '');
        // [THEN] Retail Voucher should Exist with correct amount
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypePartial.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists ');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueMultiplePartialVouchersFinishPOSTransaction()
    // [SCENARIO] Issue Multiple Vouchers In POS Transaction pay with cash - check Retail Voucher exist with correct count
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        VoucherAmount: Decimal;
        VoucherCount: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        VoucherCount := LibraryRandom.RandInt(50);
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypePartial.Code, VoucherCount, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount * VoucherCount, '');
        // [THEN] Retail Voucher should Exist with correct amount
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypePartial.Code);
        Assert.AreEqual(VoucherCount, NpRvVoucher.Count(), 'Count of issued vouchers not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithReferenceNumberAndAmount()
    // [SCENARIO] Issue Voucher with amount and reference number
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        Assert: Codeunit "Assert";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherAmount: Decimal;
        ReferenceNo: Text[50];
    begin
        Initialize();
        // [GIVEN] Voucher Amount and Reference number
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        ReferenceNo := GetRandomVoucherReferenceNo();

        // [WHEN] Issue voucher
        NpRvVoucherMgt.IssueVoucher(_VoucherTypeDefault.Code, ReferenceNo, VoucherAmount);

        // [THEN] Voucher and Voucher Entry should Exist with correct amount
        NpRvVoucher.SetRange("Reference No.", ReferenceNo);
        Assert.IsTrue(NpRvVoucher.FindFirst(), 'Voucher exists.');

        NpRvVoucherEntry.SetRange("Entry Type", NpRvVoucherEntry."Entry Type"::"Issue Voucher");
        NpRvVoucherEntry.SetRange("Voucher No.", NpRvVoucher."No.");

        Assert.IsTrue(NpRvVoucherEntry.FindFirst(), 'Voucher Entry exists.');
        Assert.AreEqual(VoucherAmount, NpRvVoucherEntry.Amount, 'Voucher Amount not according to test scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVouchersWithQuantityNumberAndAmount()
    // [SCENARIO] Issue Vouchers with quantity and amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        Assert: Codeunit "Assert";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherAmount: Decimal;
        Quantity: Integer;
        CountBefore: Integer;
    begin
        Initialize();
        // [GIVEN] Voucher Amount and Quantity
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        Quantity := GetRandomInteger(100);

        CountBefore := NpRvVoucher.Count();

        // [WHEN] Issue vouchers
        NpRvVoucherMgt.IssueVouchers(_VoucherTypeDefault.Code, Quantity, VoucherAmount);

        // [THEN] Voucher and Voucher Entry should Exist with correct amount
        Assert.AreEqual(CountBefore + Quantity, NpRvVoucher.Count(), 'Voucher Count not according to test scenario');

        NpRvVoucher.SetRange("Voucher Type", _VoucherTypeDefault.Code);
        NpRvVoucher.FindLast();
        NpRvVoucherEntry.SetRange("Entry Type", NpRvVoucherEntry."Entry Type"::"Issue Voucher");
        NpRvVoucherEntry.SetRange("Voucher No.", NpRvVoucher."No.");

        Assert.IsTrue(NpRvVoucherEntry.FindFirst(), 'Voucher Entry exists.');
        Assert.AreEqual(VoucherAmount, NpRvVoucherEntry.Amount, 'Voucher Amount not according to test scenario');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherScanVoucherFull()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction use whole voucher amount
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherScanVoucherPartial()
    // [SCENARIO] Issue Voucher - partially use voucher end transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction, don't use whole voucher amount
        CreateItemTransaction(VoucherAmount - 1);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Retail Voucher  is open
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvVoucher.CalcFields(Open);
        Assert.AreEqual(true, NpRvVoucher.Open, 'Voucher open not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherScanVoucherIn2TransactionsEnd()
    // [SCENARIO] Issue Voucher - fully use voucher end 2 transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(1, Round(VoucherAmount, 1) - 1, LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherScanVoucherIn2TransactionsDontEnd()
    // [SCENARIO] Issue Voucher - fully use voucher , don't end 2. transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transactions
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(1, Round(VoucherAmount, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount + LibraryRandom.RandDec(10000, LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction didn't end, Archived Retail Voucher Exist and Retail Voucher Exist (because transaction didn't end)
        Assert.AreEqual(false, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(true, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherScanVoucherIn2TransactionsDontEndPayWithCash()
    // [SCENARIO] Issue Voucher - fully use voucher , don't end 2. transaction with voucher but with cash
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        Suggestion: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(0, Round(VoucherAmount - 1, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount + LibraryRandom.RandDecInRange(0, Round(VoucherAmount - 1, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction didn't end
        Assert.AreEqual(false, TransactionEnded, 'Second Transaction end with voucher not according to test scenario.');
        _POSSession.GetPaymentLine(POSPaymentLine);
        Suggestion := POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(_POSPaymentMethodCash);
        // Pay the rest
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, Suggestion, '');
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Retail Voucher don't exist
        Assert.AreEqual(true, TransactionEnded, 'Second Transaction end with cash not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherTryScanArhivedVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
        VourcherRedeemedErr: Label 'The voucher with Reference No. %1 has already been redeemed in another transaction on %2.', Comment = '%1 - voucher reference number, 2% - date';
        Text005: Label 'Invalid Reference No. %1';
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchvoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        Assert: Codeunit "Assert";
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        CreateItemTransaction(NpRvVoucher.Amount);
        // [THEN] Check if error when reusing voucher
        asserterror NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        if NpRvVoucherMgt.FindArchivedVoucher(NpRvVoucher."Voucher Type", NpRvVoucher."Reference No.", ArchVoucher) then begin
            ArchvoucherEntry.SetCurrentKey("Arch. Voucher No.");
            ArchvoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
            if ArchvoucherEntry.FindLast() then
                Assert.ExpectedError(StrSubstNo(VourcherRedeemedErr, NpRvVoucher."Reference No.", ArchvoucherEntry."Posting Date"))
            else
                Assert.ExpectedError(StrSubstNo(Text005, NpRvVoucher."Reference No."));
        end
        else
            Assert.ExpectedError(StrSubstNo(Text005, NpRvVoucher."Reference No."));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherPayWithVoucherFull()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction use whole voucher amount
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherPayWithVoucherPartial()
    // [SCENARIO] Issue Voucher - partially use voucher end transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction, don't use whole voucher amount
        CreateItemTransaction(VoucherAmount - 1);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Retail Voucher  is open
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvVoucher.CalcFields(Open);
        Assert.AreEqual(true, NpRvVoucher.Open, 'Voucher open not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherPayWithVoucherIn2TransactionsEnd()
    // [SCENARIO] Issue Voucher - fully use voucher end 2 transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(1, Round(VoucherAmount, 1) - 1, LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherPayWithVoucherIn2TransactionsDontEnd()
    // [SCENARIO] Issue Voucher - fully use voucher , don't end 2. transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transactions
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(1, Round(VoucherAmount, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount + LibraryRandom.RandDec(10000, LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction didn't end, Archived Retail Voucher Exist and Retail Voucher Exist (because transaction didn't end)
        Assert.AreEqual(false, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(true, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherPayWithVoucherIn2TransactionsDontEndPayWithCash()
    // [SCENARIO] Issue Voucher - fully use voucher , don't end 2. transaction with voucher but with cash
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        VoucherAmount: Decimal;
        Suggestion: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transactions
        CreateItemTransaction(VoucherAmount - LibraryRandom.RandDecInRange(0, Round(VoucherAmount - 1, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        NpRvVoucher.CalcFields(Amount);
        CreateItemTransaction(NpRvVoucher.Amount + LibraryRandom.RandDecInRange(0, Round(VoucherAmount - 1, 1), LibraryRandom.RandIntInRange(0, 2)));
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction didn't end
        Assert.AreEqual(false, TransactionEnded, 'Second Transaction end with voucher not according to test scenario.');
        _POSSession.GetPaymentLine(POSPaymentLine);
        Suggestion := POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(_POSPaymentMethodCash);
        //Pay the rest with cash
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, Suggestion, '');
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Retail Voucher don't exist
        Assert.AreEqual(true, TransactionEnded, 'Second Transaction end with cash not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherTryPayWithArhivedVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        CreateItemTransaction(NpRvVoucher.Amount);
        TransactionEnded := false;
        // [THEN] Check if error when reusing voucher
        asserterror TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        Assert.IsFalse(TransactionEnded, 'Transaction should not end');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherDiscountAmtFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        DiscountAmt: Decimal;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        DiscountAmt := LibraryRandom.RandDecInRange(0, Round(VoucherAmount, 1), LibraryRandom.RandIntInRange(0, 2));
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypePartial.Code, 1, VoucherAmount, '0', DiscountAmt);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount - DiscountAmt, '');
        // [THEN] Retail Voucher Exist
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypePartial.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists.');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssuePartialVoucherDiscountPctFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        DiscountPct: Decimal;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        DiscountPct := LibraryRandom.RandDecInRange(0, 100, LibraryRandom.RandIntInRange(0, 2));
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypePartial.Code, 1, VoucherAmount, '1', DiscountPct);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, Round(VoucherAmount - VoucherAmount * DiscountPct / 100, _POSPaymentMethodCash."Rounding Precision"), '');
        // [THEN] Retail Voucher Exist
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypePartial.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists ');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherInPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction - check NpRv Sales Line
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        Initialize();
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, 100, '', 0);
        // [THEN] Then NpRv Sales Line should exist
        NpRvSalesLine.Setrange("Register No.", SalePOS."Register No.");
        NpRvSalesLine.Setrange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        NpRvSalesLine.Setrange(Type, NpRvSalesLine.Type::"New Voucher");
        NpRvSalesLine.Setrange("Voucher Type", _VoucherTypeDefault.Code);
        Assert.Istrue(NpRvSalesLine.FindFirst(), 'NpRv Sales Line exists with matching info issued voucher');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount, '');
        // [THEN] Retail Voucher should Exist with correct amount
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypeDefault.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists ');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherScanVoucherFull()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction use whole voucher amount
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault.Code, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherScanVoucherPartial()
    // [SCENARIO] Issue Voucher - partially use voucher end transaction
    var
        SalePOS: Record "NPR POS Sale";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction, don't use whole voucher amount
        CreateItemTransaction(VoucherAmount - 1);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault.Code, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Voucher for remaining amount is issued
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.", NpRvVoucher."Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        NpRvVoucher.Reset();
        NpRvVoucher.SetRange("Issue Document No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(true, NpRvVoucher.FindFirst(), 'Issued Voucher open not according to test scenario.');
        NpRvVoucher.CalcFields(Open, Amount);
        Assert.AreEqual(1, NpRvVoucher.Amount, 'Issued Voucher Amount not according to test scenario.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherTryScanArhivedVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault.Code, NpRvVoucher."Reference No.");
        CreateItemTransaction(NpRvVoucher.Amount);
        TransactionEnded := false;
        // [THEN] Check if error when reusing voucher
        asserterror TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault.Code, NpRvVoucher."Reference No.");
        Assert.IsFalse(TransactionEnded, 'Transaction should not end');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherPayWithVoucherFull()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction use whole voucher amount
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherPayWithVoucherPartial()
    // [SCENARIO] Issue Voucher - partially use voucher end transaction
    var
        SalePOS: Record "NPR POS Sale";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        TransactionEnded: Boolean;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction, don't use whole voucher amount
        CreateItemTransaction(VoucherAmount - 1);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        // [THEN] Check if Transaction ended, Archived Retail Voucher Exist and Retail Voucher  is open        
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.", NpRvVoucher."Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        NpRvVoucher.Reset();
        NpRvVoucher.SetRange("Issue Document No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(true, NpRvVoucher.FindFirst(), 'Issued Voucher open not according to test scenario.');
        NpRvVoucher.CalcFields(Open, Amount);
        Assert.AreEqual(1, NpRvVoucher.Amount, 'Issued Voucher Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherTryPayWithArhivedVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TransactionEnded: Boolean;
        VoucherAmount: Decimal;
        VoucherNotValidErr: Label 'Voucher %1 is not valid.';
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //Create new transaction
        CreateItemTransaction(VoucherAmount);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        CreateItemTransaction(NpRvVoucher.Amount);
        // [THEN] Check if error when reusing voucher
        asserterror TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _VoucherTypeDefault."Payment Type", VoucherAmount, NpRvVoucher."Reference No.");
        Assert.ExpectedError(StrSubstNo(VoucherNotValidErr, NpRvVoucher."Reference No."));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherDiscountAmtFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        DiscountAmt: Decimal;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        DiscountAmt := LibraryRandom.RandDecInRange(0, Round(VoucherAmount, 1), LibraryRandom.RandIntInRange(0, 2));
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '0', DiscountAmt);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount - DiscountAmt, '');
        // [THEN] Retail Voucher Exist
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypeDefault.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists.');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueDefaultVoucherDiscountPctFinishPOSTransaction()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash - check Retail Voucher exist with correct amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        DiscountPct: Decimal;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        DiscountPct := LibraryRandom.RandDecInRange(0, 100, LibraryRandom.RandIntInRange(0, 2));
        // [GIVEN] POS Transaction
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '1', DiscountPct);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, Round(VoucherAmount - VoucherAmount * DiscountPct / 100, _POSPaymentMethodCash."Rounding Precision"), '');
        // [THEN] Retail Voucher Exist
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", _VoucherTypeDefault.Code);
        Assert.Istrue(NpRvVoucher.FindFirst(), 'Issued Voucher exists ');
        NpRvVoucher.Calcfields("Amount");
        Assert.AreEqual(VoucherAmount, NpRvVoucher."Amount", 'Issued Voucher Initial Amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TopUpPartialVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TransactionEnded: Boolean;
        VoucherAmount: Decimal;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction use whole voucher amount
        NpRvVoucherMgt.TopUpVoucher(_POSSession, NpRvVoucher."No.", '', VoucherAmount, 0, 0);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount, '');
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvVoucher.CalcFields(Amount);
        Assert.AreEqual(VoucherAmount * 2, NpRvVoucher.Amount, 'Voucher amount not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestMaxVoucherCountPerVoucherType()
    // [SCENARIO] Issue Voucher In POS Transaction, set Max Voucher Count on Voucher Type and exceed it
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        MaxCountErr: Label '%1 for %2 %3 is exceeded.';
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // Create voucher should not fail
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //set Max Qty on Voucher Type to all vouchers + 2
        SetMaxVoucherCountOnVoucherType(_VoucherTypePartial);
        // Create voucher should not fail - 1
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        // Create voucher should not fail - 2
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        // Create voucher should  fail
        asserterror CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        Assert.ExpectedError(StrSubstNo(MaxCountErr, _VoucherTypePartial.FieldCaption("Max Voucher Count"), _VoucherTypePartial.TableCaption, _VoucherTypePartial.Code));
        SetMaxVoucherCountOnVoucherType(_VoucherTypePartial, 0); //cleanup
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestAmountPerVoucherType()
    // [SCENARIO] Set fixed amount on Voucher Type, create Voucher with random amount and created Voucher should have fixed amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        FixedVoucherAmount, RandomVoucherAmount : Decimal;
    begin
        exit; //TODO: [Test result: FAIL] Fixing in progress
        Initialize();
        FixedVoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        RandomVoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        //set Voucher Amount on Voucher Type 
        SetVoucherAmountVoucherType(FixedVoucherAmount);

        // Create voucher with any amount
        CreateVoucherInPOSTransaction(NpRvVoucher, RandomVoucherAmount, FixedVoucherAmount, _VoucherTypePartial.Code);
        NpRvVoucher.CalcFields("Initial Amount");
        Assert.AreEqual(_VoucherTypePartial."Voucher Amount", NpRvVoucher."Initial Amount", 'Issued Voucher Initial Amount not according to test scenario.');
        SetVoucherAmountVoucherType(0); //cleanup
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestDatesPerVoucherType()
    // [SCENARIO] Set fixed amount on Voucher Type, create Voucher with random amount and created Voucher should have fixed amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        StartingDateTime, EndingDateTime : DateTime;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // Date different than today
        StartingDateTime := CreateDateTime(20210101D, Time());
        EndingDateTime := CreateDateTime(20250101D, Time());
        // set Dates on Voucher Type 
        SetDatesToVoucherType(StartingDateTime, EndingDateTime);
        // Create voucher with any amount
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        // Check
        Assert.AreEqual(_VoucherTypePartial."Starting Date", NpRvVoucher."Starting Date", 'Issued Voucher Starting Date not according to test scenario.');
        Assert.AreEqual(_VoucherTypePartial."Ending Date", NpRvVoucher."Ending Date", 'Issued Voucher Ending Date not according to test scenario.');
        SetDatesToVoucherType(0DT, 0DT); //cleanup
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestStoreGroupPerVoucherType()
    // [SCENARIO] Set Store Group on Voucher Type, try to use voucher in wrong company
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
        NotAllowedErr: Label '%1 %2 is not allowed to be used in store %3', Comment = '%1 = Voucher Type Caption, %2 = Voucher Type Code, %3 = Store Code';
    begin
        Initialize();
        SetStoreGroupPerVoucherType(CreateStoreGroup());
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        // [GIVEN] Voucher created in POS Transaction
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        //Create new transaction use whole voucher amount
        CreateItemTransaction(VoucherAmount);
        //Usage of the voucher should fail 
        asserterror TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        Assert.ExpectedError(StrSubstNo(NotAllowedErr, _VoucherTypePartial.TableCaption(), _VoucherTypePartial.Code, _POSStore.Code));
        //Usage of the voucher should succeed after adding store to store group 
        CreateStoreGroupLine(_VoucherTypePartial."POS Store Group", _POSStore.Code);
        TransactionEnded := NPRLibraryPOSMock.PayWithVoucherAndTryEndSaleAndStartNew(_POSSession, _VoucherTypePartial.Code, NpRvVoucher."Reference No.");
        // [THEN] Check ifTransaction ended, Archived Retail Voucher Exist and Retail Voucher doesn't Exist
        Assert.AreEqual(true, TransactionEnded, 'Transaction end not according to test scenario.');
        NpRvArchVoucher.SetRange("Reference No.");
        Assert.Istrue(NpRvArchVoucher.FindFirst(), 'Archived Voucher exists ');
        Assert.AreEqual(false, NpRvVoucher.Get(NpRvVoucher."No."), 'Voucher record not according to test scenario.');
        SetStoreGroupPerVoucherType('');//cleanup
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TestDisabledOnWeb()
    // [SCENARIO] Create voucher, disable it for web, API function should return error
    var
        Voucher, NpRvVoucher : Record "NPR NpRv Voucher";
        ExtVoucherWS: codeunit "NPR NpRv Ext. Voucher WS";
        Assert: Codeunit "Assert";
        Found: Boolean;
    begin
        Initialize();

        // Create voucher with any amount
        CreateVoucherInPOSTransaction(NpRvVoucher, 100, _VoucherTypePartial.Code);
        // Check
        Found := ExtVoucherWS.FindVoucher(_VoucherTypePartial.Code, NpRvVoucher."Reference No.", Voucher);
        Assert.AreEqual(true, Found, 'Find Voucher before disabling for web not according to test scenario.');
        NpRvVoucher."Disabled for Web Service" := true;
        NpRvVoucher.Modify();
        Found := ExtVoucherWS.FindVoucher(_VoucherTypePartial.Code, NpRvVoucher."Reference No.", Voucher);
        Assert.AreEqual(false, Found, 'Find Voucher before disabling for web not according to test scenario.');
    end;




    procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePartialVoucherType(_VoucherTypePartial, false);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
            NPRLibraryPOSMasterData.CreateReturnVoucherType(_VoucherTypePartial.Code, _VoucherTypeDefault.Code);
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);
            _POSPaymentMethodCash."Rounding Precision" := 0.01;
            _POSPaymentMethodCash.Modify();

            _Initialized := true;
        end;

        NPRLibraryPOSMasterData.ItemReferenceCleanup();

        Commit();
    end;

    local procedure CreateVoucherInPOSTransaction(var NpRvVoucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal; VoucherTypeCode: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, VoucherTypeCode, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount, '');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", VoucherTypeCode);
        NpRvVoucher.FindFirst();
    end;

    local procedure CreateVoucherInPOSTransaction(var NpRvVoucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal; PaymentAmount: Decimal; VoucherTypeCode: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [WHEN] Create line with issue voucher, finish transaction
        NPRLibraryPOSMock.CreateVoucherLine(_POSSession, VoucherTypeCode, 1, VoucherAmount, '', 0);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, PaymentAmount, '');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        NpRvVoucher.Setrange("Issue Register No.", SalePOS."Register No.");
        NpRvVoucher.SetRange("Issue Document Type", NpRvVoucher."Issue Document Type"::"Audit Roll");
        NpRvVoucher.Setrange("Issue Document No.", POSEntry."Document No.");
        NpRvVoucher.Setrange("Voucher Type", VoucherTypeCode);
        NpRvVoucher.FindFirst();
    end;


    local procedure CreateItemTransaction(VoucherAmount: Decimal)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
    begin
        _Item.Get(_Item."No.");
        _Item."Unit Price" := VoucherAmount;
        _Item.Modify();
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);
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

    local procedure GetRandomVoucherReferenceNo(): Text[50]
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryRandom.Init();
        exit(LibraryRandom.RandText(50));
    end;

    local procedure GetRandomInteger(Range: Integer): Integer
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibraryRandom.Init();
        exit(LibraryRandom.RandInt(Range));
    end;

    local procedure SetMaxVoucherCountOnVoucherType(_VoucherTypePartial: Record "NPR NpRv Voucher Type")
    begin
        _VoucherTypePartial.Get(_VoucherTypePartial.Code);
        _VoucherTypePartial.CalcFields("Voucher Qty. (Closed)", "Voucher Qty. (Open)", "Arch. Voucher Qty.");
        _VoucherTypePartial."Max Voucher Count" := _VoucherTypePartial."Voucher Qty. (Closed)" + _VoucherTypePartial."Voucher Qty. (Open)" + _VoucherTypePartial."Arch. Voucher Qty." + 2;
        _VoucherTypePartial.Modify();
    end;

    local procedure SetMaxVoucherCountOnVoucherType(_VoucherTypePartial: Record "NPR NpRv Voucher Type"; MaxCount: Integer)
    begin
        _VoucherTypePartial.Get(_VoucherTypePartial.Code);
        _VoucherTypePartial."Max Voucher Count" := MaxCount;
        _VoucherTypePartial.Modify();
    end;

    local procedure SetVoucherAmountVoucherType(VoucherAmount: Decimal)
    begin
        _VoucherTypePartial.Get(_VoucherTypePartial.Code);
        _VoucherTypePartial."Voucher Amount" := VoucherAmount;
        _VoucherTypePartial.Modify();
    end;

    local procedure SetDatesToVoucherType(StartingDateTime: DateTime; EndingDateTime: DateTime)
    begin
        _VoucherTypePartial.Get(_VoucherTypePartial.Code);
        _VoucherTypePartial."Starting Date" := StartingDateTime;
        _VoucherTypePartial."Ending Date" := EndingDateTime;
        _VoucherTypePartial.Modify();
    end;

    local procedure SetStoreGroupPerVoucherType(StoreGroup: Code[20])
    begin
        _VoucherTypePartial.Get(_VoucherTypePartial.Code);
        _VoucherTypePartial."POS Store Group" := StoreGroup;
        _VoucherTypePartial.Modify();
    end;

    local procedure CreateStoreGroup(): Code[20]
    var
        POSStoreGroup: Record "NPR POS Store Group";
    begin
        if not POSStoreGroup.Get('TEST') then begin
            POSStoreGroup.Init();
            POSStoreGroup."No." := 'TEST';
            POSStoreGroup.Insert();
        end;
        exit(POSStoreGroup."No.");
    end;

    local procedure CreateStoreGroupLine(POSStoreGroup: Code[20]; POSStoreCode: Code[10])
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
    begin
        POSStoreGroupLine.Init();
        POSStoreGroupLine."No." := POSStoreGroup;
        POSStoreGroupLine."POS Store" := POSStoreCode;
        POSStoreGroupLine.Insert();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]

    [HandlerFunctions('OpenVoucherCardHandler')]
    procedure CheckExistingVoucher()
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        POSActionCheckVoucherB: codeunit "NPR POS Action:Check Voucher B";
        VoucherAmount: Decimal;
    begin
        // [SCENARIO] Scanned Reference No. open Voucher Card Page
        // [GIVEN] Voucher created in POS Transaction
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        // [WHEN]
        POSActionCheckVoucherB.CheckVoucher(_VoucherTypeDefault.Code, NpRvVoucher."Reference No.");
        // [THEN] Voucher Card opens. Caught by OpenVoucherCardHandler 
    end;

    [ModalPageHandler]
    procedure OpenVoucherCardHandler(var VoucherCard: Page "NPR NpRv Voucher Card"; var ActionResponse: Action)
    begin
        ActionResponse := Action::Cancel;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckMissingVoucher()
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        POSActionCheckVoucherB: codeunit "NPR POS Action:Check Voucher B";
        VoucherAmount: Decimal;
        ReferenceNo: Text[50];
        NotFoundErr: Label 'Reference No. %1 and Voucher Type %2 not found', Comment = '%1=Voucher Reference No;%2=Voucher Type Code';
    begin
        // [SCENARIO] Scanned Reference No. caused error
        // [GIVEN] Voucher created in POS Transaction
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypePartial."Payment Type");
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypeDefault.Code);
        //[WHEN]
        ReferenceNo := NpRvVoucher."Reference No.";
        NpRvVoucher.Delete(); //Voucher doesn't exist anymore
        // [THEN] 
        asserterror POSActionCheckVoucherB.CheckVoucher(_VoucherTypeDefault.Code, ReferenceNo);
        Assert.ExpectedError(StrSubstNo(NotFoundErr, ReferenceNo, _VoucherTypeDefault.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TopupExtendsVoucher()
    // [SCENARIO] Test if topup extends voucher
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Assert: Codeunit "Assert";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TransactionEnded: Boolean;
        VoucherAmount: Decimal;
        ReferenceNo: Text[50];
        DFormula: DateFormula;
        NewEndingDT: DateTime;
    begin
        Initialize();

        // [GIVEN] Voucher Amount and Reference number
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        ReferenceNo := GetRandomVoucherReferenceNo();

        // [WHEN] Issue voucher
        CreateVoucherInPOSTransaction(NpRvVoucher, VoucherAmount, _VoucherTypePartial.Code);
        _VoucherTypePartial."Top-up Extends Ending Date" := true;
        Evaluate(DFormula, '<11Y>'); //any big valid period
        _VoucherTypePartial."Valid Period" := DFormula;
        _VoucherTypePartial.Modify();

        //Topup voucher
        NpRvVoucherMgt.TopUpVoucher(_POSSession, NpRvVoucher."No.", '', VoucherAmount, 0, 0);
        TransactionEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, VoucherAmount, '');
        // [THEN] Check if new ending date is created
        NpRvVoucher.Get(NpRvVoucher."No.");
        NewEndingDT := CreateDateTime(CalcDate(_VoucherTypePartial."Valid Period", DT2Date(CurrentDateTime())), DT2Time(CurrentDateTime()));
        Assert.AreNearlyEqual(0, NewEndingDT - NpRvVoucher."Ending Date", 2000, 'Voucher Ending Date not according to test scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure SetReferenceNoOnSaleLineThatIsNotVoucher()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetVoucherRefNo: Codeunit "NPR POS Action Set Vch Ref NoB";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ReferenceNo: Text[50];
        LineTypeErrorLbl: Label 'The line is not a voucher. Please select a voucher.';
    begin
        // [SCENARIO] Set reference number on sale line that is not of type voucher
        // - Add sale line that is not a voucher(item i.e.)
        // - Try setting reference no on that sale line
        // - Check if reference no is not applied and error is thrown

        Initialize();

        // [GIVEN] POS Transaction
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        //[GIVEN] Random reference number
        ReferenceNo := GetRandomVoucherReferenceNo();

        // [GIVEN] Item in the POS Sale
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);

        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[WHEN]
        asserterror POSActionSetVoucherRefNo.AssignReferenceNo(SaleLinePOS, '', ReferenceNo);
        // [THEN] Reference number cannot be applied on sale line which is not voucher
        Assert.ExpectedError(LineTypeErrorLbl);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure SetEmptyReferenceNoOnVoucher()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetVoucherRefNo: Codeunit "NPR POS Action Set Vch Ref NoB";
        Assert: Codeunit Assert;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VoucherAmount: Decimal;
        EmptyReferenceNoErrorLbl: Label 'Reference No. cannot be empty.';
    begin
        // [SCENARIO] Set empty reference number on voucher 
        // - Add sale line of type voucher
        // - Try setting empty reference no on voucher
        // - Check if reference no is not applied and error is thrown

        Initialize();

        // [GIVEN] POS Transaction and default voucher created
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        LibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '', 0);

        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[WHEN] Apply empty reference number
        asserterror POSActionSetVoucherRefNo.AssignReferenceNo(SaleLinePOS, '', '');
        // [THEN] Reference number cannot be empty
        Assert.ExpectedError(EmptyReferenceNoErrorLbl);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    internal procedure ChangeVoucherReferenceNoWhichIsAlreadySet()
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionSetVoucherRefNo: Codeunit "NPR POS Action Set Vch Ref NoB";
        Assert: Codeunit Assert;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        VoucherAmount: Decimal;
        ReferenceNo: Text[50];
    begin
        // [SCENARIO] Change reference no of voucher with different one
        // - Add sale line of type voucher
        // - Try setting reference no on voucher that already has one
        // - Check if reference no is applied

        Initialize();

        // [GIVEN] POS Transaction and default voucher created
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");
        LibraryPOSMock.CreateVoucherLine(_POSSession, _VoucherTypeDefault.Code, 1, VoucherAmount, '', 0);

        //[GIVEN] Random reference number
        ReferenceNo := GetRandomVoucherReferenceNo();

        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[WHEN]
        POSActionSetVoucherRefNo.AssignReferenceNo(SaleLinePOS, '', ReferenceNo);

        NpRvSalesLine.Reset();
        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS.SystemId);
        if not NpRvSalesLine.FindFirst() then
            Error(GetLastErrorText());

        NpRvSalesLineRef.Reset();
        NpRvSalesLineRef.SetCurrentKey("Sales Line Id");
        NpRvSalesLineRef.Setrange("Sales Line Id", NpRvSalesLine.Id);
        if not NpRvSalesLineRef.FindFirst() then
            Error(GetLastErrorText());

        // [THEN] Reference is applied on voucher
        Assert.AreEqual(NpRvSalesLineRef."Reference No.", ReferenceNo, 'Reference No. not applied according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountNoCustomerPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountCustomerWithoutVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountCustomerWithVATPricesNoVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices without VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatNoDiscountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatNoDiscountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, no discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountPctCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountPctCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherNoVatDiscountAmountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyNoVatDiscountAmountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. No VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] VAT change on voucher - 0% VAT
        ChangeGLAccountNoVAT(_VoucherTypeDefault."Account No.");

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatNoDiscountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatNoDiscountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, no discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, 0, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountPctCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountPctCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := GetRandomVoucherAmount(_VoucherTypeDefault."Payment Type");

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '1', Qty, VoucherAmount, 50, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", VoucherAmount * Qty * SaleLinePOS."Discount %" / 100, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherWithVatDiscountAmountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 1;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountNoCustomerPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, no customer, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountCustomerWithoutVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer without VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        VoucherAmountExclVAT: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := false;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        VoucherAmountExclVAT := POSSaleTaxCalc.CalcAmountWithoutVAT(VoucherAmount, SaleLinePOS."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmountExclVAT, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IssueVoucherTwoQtyWithVatDiscountAmountCustomerWithVATPricesWithVAT()
    // [SCENARIO] Check voucher price and amount including VAT when issue voucher on POS that has POS view profile prices with VAT. 
    //            Check voucher amount after posting. With VAT, discount, customer with VAT, two quantity on transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSViewProfile: Record "NPR POS View Profile";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Customer: Record Customer;
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSIssueMgt: Codeunit "NPR NpRv Issue POSAction Mgt-B";
        LibrarySales: Codeunit "Library - Sales";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
        VoucherAmount: Decimal;
        DiscountAmount: Decimal;
        Qty: Integer;
    begin
        Initialize();
        VoucherAmount := 2000;

        // [GIVEN] POS view profile and POS transaction
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := true;
        POSViewProfile.Modify(true);
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(_POSUnit, POSViewProfile.Code);
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        // [GIVEN] Sale with customer attached
        LibrarySales.CreateCustomer(Customer);
        Customer."Prices Including VAT" := true;
        Customer.Modify(true);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false);

        // [WHEN] Create line with issue voucher
        Qty := 2;
        _POSSession.GetSaleLine(POSSaleLine);
        DiscountAmount := 500;
        POSIssueMgt.IssueVoucherCreate(POSSaleLine, NpRvVoucher, _VoucherTypeDefault, '0', Qty, VoucherAmount, DiscountAmount, '');
        POSIssueMgt.CreateNpRvSalesLine(POSSale, NpRvSalesLine, NpRvVoucher, _VoucherTypeDefault, POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [THEN] Check if voucher price and amount including VAT is calculated correctly
        Assert.AreNearlyEqual(SaleLinePOS."Unit Price", VoucherAmount, 0.1, 'Issued voucher price not calculated correctly.');
        Assert.AreNearlyEqual(SaleLinePOS."Amount Including VAT", (VoucherAmount - DiscountAmount) * Qty, 0.1, 'Issued voucher amount including VAT not calculated correctly.');

        EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS, VoucherAmount, Qty);
    end;

    local procedure EndSaleAndCheckRetailVoucherEntriesAmount(SalePOS: Record "NPR POS Sale"; VoucherAmount: Decimal; Quantity: Integer)
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        SaleLinePOS: Record "NPR POS Sale Line";
        Assert: Codeunit "Assert";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TransactionEnded: Boolean;
    begin
        // [GIVEN] The amount to be paid for transaction
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Amount Including VAT");

        // [THEN] End sale
        TransactionEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, SaleLinePOS."Amount Including VAT", '');
        Assert.IsTrue(TransactionEnded, 'Transaction end not according to test scenario.');

        // [THEN] Retail voucher entry should exist with correct amount
        NpRvVoucherEntry.SetRange("Voucher Type", _VoucherTypeDefault.Code);
        NpRvVoucherEntry.SetRange("Entry Type", NpRvVoucherEntry."Entry Type"::"Issue Voucher");
        NpRvVoucherEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        NpRvVoucherEntry.CalcSums(Amount);
        Assert.AreNearlyEqual(NpRvVoucherEntry.Amount, VoucherAmount * Quantity, 0.1, 'Voucher Amount not according to test scenario');
    end;

    local procedure ChangeGLAccountNoVAT(GLAccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not GLAccount.Get(GLAccountNo) then
            exit;
        if not VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group") then
            exit;
        VATPostingSetup.Validate("VAT %", 0);
        VATPostingSetup.Modify(true);
    end;
}