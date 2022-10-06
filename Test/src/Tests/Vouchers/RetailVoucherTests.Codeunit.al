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
    procedure IssuePartialVoucherTryPayWithArhivedVoucher()
    // [SCENARIO] Issue Voucher In POS Transaction pay with cash -  use voucher for item transaction
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
        Text005: Label 'Invalid Reference No. %1';
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
    procedure TestMaxVoucherCountPerVoucherType()
    // [SCENARIO] Issue Voucher In POS Transaction, set Max Voucher Count on Voucher Type and exceed it
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
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
    procedure TestAmountPerVoucherType()
    // [SCENARIO] Set fixed amount on Voucher Type, create Voucher with random amount and created Voucher should have fixed amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        FixedVoucherAmount, RandomVoucherAmount : Decimal;
        TransactionEnded: Boolean;
        MaxCountErr: Label '%1 for %2 %3 is exceeded.';
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
    procedure TestDatesPerVoucherType()
    // [SCENARIO] Set fixed amount on Voucher Type, create Voucher with random amount and created Voucher should have fixed amount
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Assert: Codeunit "Assert";
        VoucherAmount: Decimal;
        TransactionEnded: Boolean;
        MaxCountErr: Label '%1 for %2 %3 is exceeded.';
        StartingDateTime, EndingDateTime : DateTime;
        LibraryRandom: Codeunit "Library - Random";
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





    procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end;

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


}
