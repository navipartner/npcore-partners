// [FEATURE] [POS Posting] [Deferral]
codeunit 85610 "NPR POS Deferral Fail Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibPOSDeferral: Codeunit "NPR Library POS Deferral";
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineCheckFailure_WhenNightlyJobRuns_ThenNoRowOfReceiptRemainsAndOtherRowsStay()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryUtility: Codeunit "Library - Utility";
        I9DocumentNo: Code[20];
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
        I9Snapshot: Text;
        Mismatches: Text;
        PurchaseSnapshot: Text;
    begin
        // [SCENARIO] A nightly run that fails the journal line check leaves no row of the receipt, removes a leftover Sales row with the receipt's number, keeps the rows of another document and of another type, and keeps the open schedule
        Initialize();

        // [GIVEN] A receipt of ITEM2651 with a failure rule on the posting account of its payment line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);

        // [GIVEN] Table 1706 holds a Sales row of document I9, which is not a POS receipt, and a leftover Sales row with the receipt's number and deferral line 7
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        I9DocumentNo := CopyStr('I9' + LibraryUtility.GenerateGUID(), 1, MaxStrLen(I9DocumentNo));
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, I9DocumentNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -100, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, POSEntry."Document No.", 7, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -12.34, false);

        // [GIVEN] Table 1706 holds a Purchase row with the receipt's number
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -50, false);
        I9Snapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, I9DocumentNo);
        PurchaseSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.");

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt stays Unposted with no G/L entry and no Sales row, its log entry holds the dimension error, and the Purchase row with its number is unchanged
        Mismatches :=
            _LibPOSDeferral.GetStatusMismatch('S1.a', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.a', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.a', POSEntry."Document No.") +
            GetLogErrorMismatch('S1.a', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", C1."Dimension Code", '') +
            GetRowSnapshotMismatch('S1.a', Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.", PurchaseSnapshot);

        // [THEN] The I9 row is unchanged
        Mismatches +=
            GetRowsUnchangedMismatch('S1.i', I9DocumentNo, 1, -100) +
            GetRowSnapshotMismatch('S1.i', Enum::"Deferral Document Type"::Sales, I9DocumentNo, I9Snapshot);

        // [THEN] The leftover row with the receipt's number and deferral line 7 is removed
        Mismatches += GetNoRowsOfLineMismatch('E6', POSEntry."Document No.", 7);

        // [THEN] The open schedule of the sales line stays with DEF2651 and the 12 months of G1, and no row of the receipt remains
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        Mismatches +=
            _LibPOSDeferral.GetOpenScheduleMismatches('E11', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetNoRowsMismatch('E11', POSEntry."Document No.");
        _Assert.AreEqual('', Mismatches, 'S1.a, S1.i, E6 and E11: a failed nightly run leaves no row of its receipt and changes no other row');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineCheckFailure_WhenPostActionRuns_ThenErrorShowsAndNoRowOfReceiptRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] The post action with stop on error shows the dimension error after the failed run is saved, and leaves no row of the receipt
        Initialize();

        // [GIVEN] A receipt of ITEM2651 with a failure rule on the posting account of its payment line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);

        // [WHEN] The post action posts the receipt with stop on error
        asserterror _LibPOSDeferral.RunPostAction(POSEntry);

        // [THEN] The dimension error shows
        _Assert.ExpectedError(C1."Dimension Code");

        // [THEN] The saved run leaves the receipt Unposted with its log entry, no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.b', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.b', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.b', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.b', POSEntry."Document No."),
            'S1.b: a failed post action run leaves no row of its receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ErrorCountMessageHandler')]
    procedure GivenBalanceCheckFailure_WhenNightlyJobRuns_ThenNoRowOfReceiptRemains()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        I9DocumentNo: Code[20];
        ItemNos: List of [Code[20]];
        I9Snapshot: Text;
        PurchaseSnapshot: Text;
    begin
        // [SCENARIO] A nightly run that fails the balance check marks the receipt Error while Posting, reports one failed entry, leaves no row of the receipt and changes no row of another type or another document
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and ITEM2 whose ITEM2 line is deleted, so the run fails the balance check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item2."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item2."No.", POSEntrySalesLine);
        POSEntrySalesLine.Delete();

        // [GIVEN] Table 1706 holds a Purchase row with the receipt's number and a Sales row of document I9, which is not a POS receipt
        I9DocumentNo := InsertPurchaseAndI9Rows(POSEntry, Item."No.", DeferralTemplate."Deferral Account", I9Snapshot, PurchaseSnapshot);

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt is Error while Posting with the imbalance error in a new log entry, no G/L entry and no row; the message handler checks the error count 1
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.c', POSEntry."Entry No.", POSEntry."Post Entry Status"::"Error while Posting") +
            GetLogErrorMismatch('S1.c', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", ImbalanceErrorStartTxt(), POSEntry."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.c', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.c', POSEntry."Document No."),
            'S1.c: a failed balance check leaves no row of its receipt');

        // [THEN] The Purchase row with the receipt's number and the I9 row are unchanged
        _Assert.AreEqual('', GetPurchaseAndI9RowsMismatch('S1.c', POSEntry, I9DocumentNo, I9Snapshot, PurchaseSnapshot), 'S1.c: a failed balance check changes no row of another type or another document');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineCheckFailureOfSecondReceipt_WhenNightlyJobRuns_ThenNoRowOfEitherReceiptRemains()
    var
        C2: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemNos: List of [Code[20]];
        SameRegisterLbl: Label 'Receipts %1 and %2 must be in one period register', Locked = true;
    begin
        // [SCENARIO] A nightly run of one register whose second receipt fails the journal line check on its ITEM2 line posts neither receipt and leaves no row of either
        Initialize();

        // [GIVEN] Receipt T1 of ITEM2651 and receipt T2 of ITEM2651 and ITEM2 in one register, with a failure rule on the sales account of ITEM2
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item2."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry2);
        _Assert.AreEqual(POSEntry1."POS Period Register No.", POSEntry2."POS Period Register No.", StrSubstNo(SameRegisterLbl, POSEntry1."Document No.", POSEntry2."Document No."));
        _LibPOSDeferral.FindSalesLine(POSEntry2, Item2."No.", POSEntrySalesLine);
        _LibPOSDeferral.SetMandatoryDimension(Database::"G/L Account", _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), C2);

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Both receipts stay Unposted with the dimension error in a new log entry, no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.d', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetStatusMismatch('S1.d', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.d', POSEntry1."Entry No.", POSEntry1."POS Posting Log Entry No.", C2."Dimension Code", '') +
            GetLogErrorMismatch('S1.d', POSEntry2."Entry No.", POSEntry2."POS Posting Log Entry No.", C2."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.d', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.d', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.d', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.d', POSEntry2."Document No."),
            'S1.d: a line check failure of one receipt leaves no row of any receipt in the run');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUncompressedLineCheckFailure_WhenUncompressedRunPosts_ThenNoRowOfReceiptRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] An uncompressed run that fails the journal line check leaves the receipt Unposted with no row
        Initialize();

        // [GIVEN] A receipt of ITEM2651 under compression Uncompressed, with a failure rule on the posting account of its payment line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::Uncompressed);
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);

        // [WHEN] The receipt posts uncompressed with stop on error
        asserterror _LibPOSDeferral.RunPostAction(POSEntry);

        // [THEN] The dimension error shows
        _Assert.ExpectedError(C1."Dimension Code");

        // [THEN] The saved run leaves the receipt Unposted with its log entry, no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.e', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.e', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.e', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.e', POSEntry."Document No."),
            'S1.e: a failed uncompressed run leaves no row of its receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodLineCheckFailure_WhenNightlyJobRuns_ThenNoRowOfReceiptsOrRegisterRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        I9DocumentNo: Code[20];
        RegisterDocumentNo: Code[20];
        OtherRowsSnapshot: Text;
    begin
        // [SCENARIO] A nightly run of a Per POS Period register that fails the journal line check leaves no row of its receipts or of the register number, and changes no row of another type or another number
        Initialize();

        // [GIVEN] Register P1 with receipts T1 and T2 of ITEM2651 under Per POS Period, with a failure rule on the posting account of the payment line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry1, C1);
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry1);

        // [GIVEN] Table 1706 holds a leftover Sales row of another document numbered like T2, a Sales row of document I9, Purchase rows numbered like T1 and P1, and a G/L row numbered like T2
        I9DocumentNo := InsertOtherDocumentRows(POSEntry1, POSEntry2, RegisterDocumentNo, Item."No.", DeferralTemplate."Deferral Account");
        OtherRowsSnapshot := GetOtherDocumentRowsSnapshot(POSEntry1, POSEntry2, RegisterDocumentNo, I9DocumentNo);

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Both receipts stay Unposted with the dimension error in a new log entry, no G/L entry and no row of T1, T2 or P1 exists, and the I9, Purchase and G/L rows are unchanged
        _Assert.AreEqual('',
            GetOtherDocumentRowsMismatch('S1.f', POSEntry1, POSEntry2, RegisterDocumentNo, I9DocumentNo, OtherRowsSnapshot) +
            _LibPOSDeferral.GetStatusMismatch('S1.f', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetStatusMismatch('S1.f', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.f', POSEntry1."Entry No.", POSEntry1."POS Posting Log Entry No.", C1."Dimension Code", '') +
            GetLogErrorMismatch('S1.f', POSEntry2."Entry No.", POSEntry2."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.f', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.f', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.f', RegisterDocumentNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S1.f', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.f', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.f', RegisterDocumentNo),
            'S1.f: a failed Per POS Period run leaves no row of its receipts or its register');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesTaxStoreLineCheckFailure_WhenNightlyJobRuns_ThenNoRowOfReceiptRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        SalesTaxLbl: Label 'Receipt %1 must carry sales tax lines, so the run takes the sales tax route', Locked = true;
    begin
        // [SCENARIO] A nightly run of a receipt from a store with sales tax that fails the journal line check leaves the receipt Unposted with no row
        Initialize();

        // [GIVEN] A receipt of ITEM2651 from a store with sales tax, with a failure rule on the posting account of its payment line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SetUpSalesTaxStore(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.SetRange("Tax Calculation Type", POSEntryTaxLine."Tax Calculation Type"::"Sales Tax");
        _Assert.IsFalse(POSEntryTaxLine.IsEmpty(), StrSubstNo(SalesTaxLbl, POSEntry."Document No."));
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt stays Unposted with the dimension error in a new log entry, no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.g', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.g', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.g', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.g', POSEntry."Document No."),
            'S1.g: a failed run in a sales tax store leaves no row of its receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUserDefinedTemplate_WhenNightlyJobRuns_ThenRunIsUndoneWithoutRows()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ZeroDeferralAmtLbl: Label 'Deferral amounts cannot be 0. Line: %1, Deferral Template: %2.', Locked = true;
    begin
        // [SCENARIO] A nightly run that stops with a hard error while it builds the deferral lines of a User-Defined template is undone and leaves no row
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose template DEF2651 uses Calc. Method User-Defined, so its schedule lines have amount 0
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        DeferralTemplate."Calc. Method" := DeferralTemplate."Calc. Method"::"User-Defined";
        DeferralTemplate.Modify();
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);

        // [WHEN] The nightly job runs
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run stops with the zero deferral amount error
        _Assert.ExpectedError(StrSubstNo(ZeroDeferralAmtLbl, Item."No.", _LibPOSDeferral.DEF2651Code()));

        // [THEN] The receipt stays Unposted with no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.h', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.h', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.h', POSEntry."Document No."),
            'S1.h: a run undone by a hard error leaves no row of its receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFailedRunWithSavedSchedule_WhenNightlyJobFailsAgain_ThenNoRowOfReceiptRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ScheduleSavedLbl: Label 'The failed first run of receipt %1 must save the schedule of its sales line', Locked = true;
    begin
        // [SCENARIO] A second failed nightly run, while the schedule of the first failed run still exists, leaves no row of the receipt
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose first nightly run failed the journal line check and saved the schedule of its sales line
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        _Assert.IsTrue(_LibPOSDeferral.OpenScheduleExists(POSEntrySalesLine), StrSubstNo(ScheduleSavedLbl, POSEntry."Document No."));
        POSEntry.Get(POSEntry."Entry No.");

        // [WHEN] The nightly job runs again while the failure cause is still active
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt stays Unposted with the dimension error in a new log entry of the second run, no G/L entry and no row
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.j', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.j', POSEntry."Entry No.", POSEntry."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.j', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.j', POSEntry."Document No."),
            'S1.j: a second failed run leaves no row of its receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ErrorCountMessageHandler')]
    procedure GivenBalanceCheckFailureOfFirstReceipt_WhenNightlyJobRuns_ThenNoRowOfEitherReceiptRemains()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        I9DocumentNo: Code[20];
        ItemNos: List of [Code[20]];
        I9Snapshot: Text;
        PurchaseSnapshot: Text;
        SameRegisterLbl: Label 'Receipts %1 and %2 must be in one period register', Locked = true;
    begin
        // [SCENARIO] A nightly run of one register whose first receipt fails the balance check, while the second passes, posts neither receipt, leaves no row of either and changes no row of another type or another document
        Initialize();

        // [GIVEN] Receipt T1 of ITEM2651 and ITEM2 whose ITEM2 line is deleted, and receipt T2 of ITEM2651, in one register
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item2."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _Assert.AreEqual(POSEntry1."POS Period Register No.", POSEntry2."POS Period Register No.", StrSubstNo(SameRegisterLbl, POSEntry1."Document No.", POSEntry2."Document No."));
        _LibPOSDeferral.FindSalesLine(POSEntry1, Item2."No.", POSEntrySalesLine);
        POSEntrySalesLine.Delete();

        // [GIVEN] Table 1706 holds a Purchase row with T1's number and a Sales row of document I9, which is not a POS receipt
        I9DocumentNo := InsertPurchaseAndI9Rows(POSEntry1, Item."No.", DeferralTemplate."Deferral Account", I9Snapshot, PurchaseSnapshot);

        // [WHEN] The nightly job runs
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] T1 is Error while Posting and T2 stays Unposted, both with the imbalance error of T1 in a new log entry, and no G/L entry and no row of either; the message handler checks the error count 1
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S1.k', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::"Error while Posting") +
            _LibPOSDeferral.GetStatusMismatch('S1.k', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.k', POSEntry1."Entry No.", POSEntry1."POS Posting Log Entry No.", ImbalanceErrorStartTxt(), POSEntry1."Document No.") +
            GetLogErrorMismatch('S1.k', POSEntry2."Entry No.", POSEntry2."POS Posting Log Entry No.", ImbalanceErrorStartTxt(), POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.k', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.k', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.k', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.k', POSEntry2."Document No."),
            'S1.k: a balance check failure of one receipt leaves no row of any receipt in the run');

        // [THEN] The Purchase row with T1's number and the I9 row are unchanged
        _Assert.AreEqual('', GetPurchaseAndI9RowsMismatch('S1.k', POSEntry1, I9DocumentNo, I9Snapshot, PurchaseSnapshot), 'S1.k: a balance check failure of one receipt changes no row of another type or another document');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodFailure_WhenLogRepostFailsAgain_ThenErrorShowsAndNoRowOfReceiptsOrRegisterRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        I9DocumentNo: Code[20];
        RegisterDocumentNo: Code[20];
        OtherRowsSnapshot: Text;
    begin
        // [SCENARIO] A repost from the POS posting log page with stop on error, while the failure cause is still active, shows the dimension error after the run is saved, leaves no row of the receipts or the register, and changes no row of another type or another number
        Initialize();

        // [GIVEN] Register P1 with receipts T1 and T2 of ITEM2651 under Per POS Period, whose nightly run failed the journal line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _LibPOSDeferral.FailWithC1(POSEntry1, C1);
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry2);
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry1);
        POSEntry1.Get(POSEntry1."Entry No.");

        // [GIVEN] Table 1706 holds a leftover Sales row of another document numbered like T2, a Sales row of document I9, Purchase rows numbered like T1 and P1, and a G/L row numbered like T2
        I9DocumentNo := InsertOtherDocumentRows(POSEntry1, POSEntry2, RegisterDocumentNo, Item."No.", DeferralTemplate."Deferral Account");
        OtherRowsSnapshot := GetOtherDocumentRowsSnapshot(POSEntry1, POSEntry2, RegisterDocumentNo, I9DocumentNo);

        // [WHEN] The POS posting log page posts the register again
        asserterror _LibPOSDeferral.RepostFromPOSPostingLog(POSEntry1."POS Posting Log Entry No.");

        // [THEN] The dimension error shows
        _Assert.ExpectedError(C1."Dimension Code");

        // [THEN] The saved run leaves both receipts Unposted with a new log entry, no G/L entry and no row of T1, T2 or P1, and the I9, Purchase and G/L rows unchanged
        _Assert.AreEqual('',
            GetOtherDocumentRowsMismatch('S1.l', POSEntry1, POSEntry2, RegisterDocumentNo, I9DocumentNo, OtherRowsSnapshot) +
            _LibPOSDeferral.GetStatusMismatch('S1.l', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetStatusMismatch('S1.l', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Unposted) +
            GetLogErrorMismatch('S1.l', POSEntry1."Entry No.", POSEntry1."POS Posting Log Entry No.", C1."Dimension Code", '') +
            GetLogErrorMismatch('S1.l', POSEntry2."Entry No.", POSEntry1."POS Posting Log Entry No.", C1."Dimension Code", '') +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.l', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.l', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S1.l', RegisterDocumentNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S1.l', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.l', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S1.l', RegisterDocumentNo),
            'S1.l: a failed log page repost leaves no row of its receipts or its register');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFailedPOSRun_WhenInvoicesPost_ThenEachInvoicePostsAllDeferralMonths()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        RevenueAccountNo: Code[20];
        SameDayInvoiceNo: Code[20];
        LaterInvoiceNo: Code[20];
        Mismatches: Text;
    begin
        // [SCENARIO] Sales invoices of ITEM2651 posted after a failed POS run, a week later or on the POS posting date, post all their deferral months and leave no row
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose nightly run failed the journal line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);

        // [WHEN] Invoice I1 posts on 2026-10-20
        LaterInvoiceNo := _LibPOSDeferral.PostInvoiceI1(Item, 20261020D);

        // [THEN] The invoice of 2026-10-20 holds all of G2, has 12 posted schedule lines, and no row of I1 or T1 and no row on D remains
        Mismatches :=
            _LibPOSDeferral.GetG2Mismatches('S2.a', LaterInvoiceNo, 20261020D, RevenueAccountNo, DeferralTemplate."Deferral Account") +
            GetPostedInvoiceScheduleMismatch('S2.a', LaterInvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.a', LaterInvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.a', POSEntry."Document No.") +
            GetNoRowsOnAccountMismatch('S2.a', DeferralTemplate."Deferral Account");

        // [WHEN] Invoice I1 posts on 2026-10-13
        SameDayInvoiceNo := _LibPOSDeferral.PostInvoiceI1(Item, _LibPOSDeferral.SalePostingDate());

        // [THEN] The invoice of 2026-10-13 holds all of G2 with the initial pair on 2026-10-13, has 12 posted schedule lines, and no row of I1 or T1 and no row on D remains
        Mismatches +=
            _LibPOSDeferral.GetG2Mismatches('S2.d', SameDayInvoiceNo, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account") +
            GetPostedInvoiceScheduleMismatch('S2.d', SameDayInvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.d', SameDayInvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.d', POSEntry."Document No.") +
            GetNoRowsOnAccountMismatch('S2.d', DeferralTemplate."Deferral Account");
        _Assert.AreEqual('', Mismatches, 'S2.a and S2.d: an invoice after a failed POS run posts all its deferral months');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodPOSPosted_WhenInvoicePosts_ThenInvoicePostsAllDeferralMonths()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        InvoiceNo: Code[20];
        RegisterDocumentNo: Code[20];
        RevenueAccountNo: Code[20];
    begin
        // [SCENARIO] A sales invoice of ITEM2651 posted after a successful Per POS Period posting of the receipt posts all its deferral months and leaves no row
        Initialize();

        // [GIVEN] Register P1 with receipt T1 of ITEM2651 under Per POS Period, posted by the nightly job
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.RunNightlyJob();
        _Assert.AreEqual('', _LibPOSDeferral.GetStatusMismatch('S2.b first step', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted), 'The nightly job posts the receipt under Per POS Period');
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry);

        // [WHEN] Invoice I1 posts on 2026-10-20
        InvoiceNo := _LibPOSDeferral.PostInvoiceI1(Item, 20261020D);

        // [THEN] The invoice holds all of G2, has 12 posted schedule lines, and no row of I1, T1 or P1 and no row on D remains
        _Assert.AreEqual('',
            _LibPOSDeferral.GetG2Mismatches('S2.b', InvoiceNo, 20261020D, RevenueAccountNo, DeferralTemplate."Deferral Account") +
            GetPostedInvoiceScheduleMismatch('S2.b', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.b', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.b', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S2.b', RegisterDocumentNo) +
            GetNoRowsOnAccountMismatch('S2.b', DeferralTemplate."Deferral Account"),
            'S2.b: an invoice after a successful Per POS Period posting posts all its deferral months');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFailedPOSRunAndInvoice_WhenNightlyJobReposts_ThenInvoiceAndReceiptPostAllDeferralMonths()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        InvoiceNo: Code[20];
        RevenueAccountNo: Code[20];
        Mismatches: Text;
    begin
        // [SCENARIO] After a failed POS run and a sales invoice of ITEM2651, the repost of the receipt posts all of G1 and the invoice keeps all of G2
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose nightly run failed the journal line check, then invoice I1 posted on 2026-10-20
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        InvoiceNo := _LibPOSDeferral.PostInvoiceI1(Item, 20261020D);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        Mismatches :=
            _LibPOSDeferral.GetNoRowsMismatch('S2.c after the invoice', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.c after the invoice', POSEntry."Document No.") +
            GetNoRowsOnAccountMismatch('S2.c after the invoice', DeferralTemplate."Deferral Account");

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The invoice holds all of G2, and no row of I1 or T1 and no row on D remains, after the invoice and after the repost
        Mismatches +=
            _LibPOSDeferral.GetG2Mismatches('S2.c', InvoiceNo, 20261020D, RevenueAccountNo, DeferralTemplate."Deferral Account") +
            GetPostedInvoiceScheduleMismatch('S2.c', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.c', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S2.c', POSEntry."Document No.") +
            GetNoRowsOnAccountMismatch('S2.c', DeferralTemplate."Deferral Account");

        // [THEN] The receipt is Posted with all of G1, with the revenue credit of 350.00, the initial debit of 350.00 and the first month credit of 29.17 on R on 2026-10-13 as single entries
        Mismatches +=
            _LibPOSDeferral.GetStatusMismatch('S2.c', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1Mismatches('S2.c', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", 1) +
            GetEntryCountMismatch('S2.c', POSEntry."Document No.", RevenueAccountNo, _LibPOSDeferral.SalePostingDate(), 0, 350, 1) +
            GetEntryCountMismatch('S2.c', POSEntry."Document No.", RevenueAccountNo, _LibPOSDeferral.SalePostingDate(), 350, 0, 1) +
            GetEntryCountMismatch('S2.c', POSEntry."Document No.", RevenueAccountNo, _LibPOSDeferral.SalePostingDate(), 0, 29.17, 1);
        _Assert.AreEqual('', Mismatches, 'S2.c: the invoice and the reposted receipt each post all their deferral months');
    end;

    [MessageHandler]
    procedure ErrorCountMessageHandler(Message: Text[1024])
    var
        ErrorCountLbl: Label '%1 POS entries failed to post.', Locked = true;
    begin
        _Assert.AreEqual(StrSubstNo(ErrorCountLbl, 1), Message, 'S1.c and S1.k: the nightly job reports the one receipt that failed its balance check');
    end;

    local procedure Initialize()
    begin
        if _IsInitialized then
            exit;
        _LibPOSDeferral.EnsureGlobalSetup();
        _IsInitialized := true;
        Commit();
    end;

    local procedure SetUpSalesTaxStore(var Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        TaxArea: Record "Tax Area";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        TaxGroup: Record "Tax Group";
        TaxJurisdiction: Record "Tax Jurisdiction";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc.CreateTaxSetup();
        LibraryTaxCalc.CreateTaxGroup(TaxGroup);
        LibraryTaxCalc.CreateTaxArea(TaxArea, 2, 0);
        LibraryTaxCalc.CreateTaxDetail(TaxDetail, TaxArea.Code, TaxGroup.Code, 2, 3, 5);
        TaxAreaLine.SetRange("Tax Area", TaxArea.Code);
        TaxAreaLine.FindSet();
        repeat
            TaxJurisdiction.Get(TaxAreaLine."Tax Jurisdiction Code");
            TaxJurisdiction."Tax Account (Sales)" := LibraryERM.CreateGLAccountNo();
            TaxJurisdiction."Unreal. Tax Acc. (Sales)" := LibraryERM.CreateGLAccountNo();
            TaxJurisdiction.Modify();
        until TaxAreaLine.Next() = 0;

        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryTaxCalc.CreateSalesTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, Enum::"Tax Calculation Type"::"Sales Tax");

        _LibPOSDeferral.GetPOSPostingProfile(POSPostingProfile);
        POSPostingProfile."VAT Bus. Posting Group" := VATBusinessPostingGroup.Code;
        POSPostingProfile."Tax Area Code" := TaxArea.Code;
        POSPostingProfile."Tax Liable" := false;
        POSPostingProfile.Modify();

        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Show Prices Including VAT" := false;
        POSViewProfile.Modify();
        POSStore.SetRange("POS Posting Profile", POSPostingProfile.Code);
        POSStore.FindFirst();
        POSUnit.SetRange("POS Store Code", POSStore.Code);
        POSUnit.FindFirst();
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfile.Code);

        Item.Get(Item."No.");
        Item."Price Includes VAT" := false;
        Item."VAT Bus. Posting Gr. (Price)" := VATBusinessPostingGroup.Code;
        Item."VAT Prod. Posting Group" := VATProductPostingGroup.Code;
        Item."Tax Group Code" := TaxGroup.Code;
        Item."Unit Price" := 350;
        Item.Modify();
    end;

    local procedure ImbalanceErrorStartTxt(): Text
    var
        ImbalanceErrorStartLbl: Label 'Cannot post the lines. ', Locked = true;
    begin
        exit(ImbalanceErrorStartLbl);
    end;

    local procedure GetLogErrorMismatch(RowId: Text; POSEntryNo: Integer; PreviousLogEntryNo: Integer; ExpectedText: Text; OtherExpectedText: Text): Text
    var
        POSEntry: Record "NPR POS Entry";
        POSPostingLog: Record "NPR POS Posting Log";
        NoNewLogLbl: Label '%1: receipt %2 POS posting log entry expected a new entry after %3, actual %4; ', Locked = true;
        LogErrorLbl: Label '%1: POS posting log entry %2 of receipt %3 expected With Error and an error containing [%4] and [%5], actual With Error %6 and error [%7]; ', Locked = true;
    begin
        POSEntry.Get(POSEntryNo);
        if (POSEntry."POS Posting Log Entry No." = PreviousLogEntryNo) or not POSPostingLog.Get(POSEntry."POS Posting Log Entry No.") then
            exit(StrSubstNo(NoNewLogLbl, RowId, POSEntry."Document No.", PreviousLogEntryNo, POSEntry."POS Posting Log Entry No."));
        if (not POSPostingLog."With Error") or
           (StrPos(POSPostingLog."Error Description", ExpectedText) = 0) or
           ((OtherExpectedText <> '') and (StrPos(POSPostingLog."Error Description", OtherExpectedText) = 0))
        then
            exit(StrSubstNo(LogErrorLbl, RowId, POSPostingLog."Entry No.", POSEntry."Document No.", ExpectedText, OtherExpectedText, POSPostingLog."With Error", POSPostingLog."Error Description"));
    end;

    local procedure GetRowSnapshotMismatch(RowId: Text; DeferralDocType: Enum "Deferral Document Type"; DocumentNo: Code[20]; ExpectedSnapshot: Text): Text
    var
        ActualSnapshot: Text;
        SnapshotLbl: Label '%1: table 1706 %2 rows of %3 expected unchanged [%4], actual [%5]; ', Locked = true;
    begin
        ActualSnapshot := _LibPOSDeferral.GetRowsSnapshot(DeferralDocType, DocumentNo);
        if ActualSnapshot <> ExpectedSnapshot then
            exit(StrSubstNo(SnapshotLbl, RowId, DeferralDocType, DocumentNo, ExpectedSnapshot, ActualSnapshot));
    end;

    local procedure InsertPurchaseAndI9Rows(POSEntry: Record "NPR POS Entry"; ItemNo: Code[20]; DeferralAccountNo: Code[20]; var I9Snapshot: Text; var PurchaseSnapshot: Text) I9DocumentNo: Code[20]
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        LibraryUtility: Codeunit "Library - Utility";
        RevenueAccountNo: Code[20];
        RowLbl: Label 'Table 1706 must hold the %1 row numbered %2 before the run', Locked = true;
    begin
        _LibPOSDeferral.FindSalesLine(POSEntry, ItemNo, POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        I9DocumentNo := CopyStr('I9' + LibraryUtility.GenerateGUID(), 1, MaxStrLen(I9DocumentNo));
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, I9DocumentNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -100, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -50, false);
        I9Snapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, I9DocumentNo);
        PurchaseSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.");
        _Assert.AreNotEqual('', I9Snapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::Sales, I9DocumentNo));
        _Assert.AreNotEqual('', PurchaseSnapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::Purchase, POSEntry."Document No."));
    end;

    local procedure GetPurchaseAndI9RowsMismatch(RowId: Text; POSEntry: Record "NPR POS Entry"; I9DocumentNo: Code[20]; I9Snapshot: Text; PurchaseSnapshot: Text): Text
    begin
        exit(
            GetRowsUnchangedMismatch(RowId, I9DocumentNo, 1, -100) +
            GetRowSnapshotMismatch(RowId, Enum::"Deferral Document Type"::Sales, I9DocumentNo, I9Snapshot) +
            GetRowSnapshotMismatch(RowId, Enum::"Deferral Document Type"::Purchase, POSEntry."Document No.", PurchaseSnapshot));
    end;

    local procedure InsertOtherDocumentRows(POSEntry1: Record "NPR POS Entry"; POSEntry2: Record "NPR POS Entry"; RegisterDocumentNo: Code[20]; ItemNo: Code[20]; DeferralAccountNo: Code[20]) I9DocumentNo: Code[20]
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        LibraryUtility: Codeunit "Library - Utility";
        RevenueAccountNo: Code[20];
    begin
        _LibPOSDeferral.FindSalesLine(POSEntry1, ItemNo, POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        I9DocumentNo := CopyStr('I9' + LibraryUtility.GenerateGUID(), 1, MaxStrLen(I9DocumentNo));
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, POSEntry2."Document No.", 7, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -12.34, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, I9DocumentNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -100, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -50, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, RegisterDocumentNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -60, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::"G/L", POSEntry2."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralAccountNo, -70, false);
    end;

    local procedure GetOtherDocumentRowsSnapshot(POSEntry1: Record "NPR POS Entry"; POSEntry2: Record "NPR POS Entry"; RegisterDocumentNo: Code[20]; I9DocumentNo: Code[20]) Snapshot: Text
    var
        PartSnapshot: Text;
        RowLbl: Label 'Table 1706 must hold the %1 row numbered %2 before the run', Locked = true;
    begin
        PartSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, I9DocumentNo);
        _Assert.AreNotEqual('', PartSnapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::Sales, I9DocumentNo));
        Snapshot := PartSnapshot + '#';
        PartSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.");
        _Assert.AreNotEqual('', PartSnapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No."));
        Snapshot += PartSnapshot + '#';
        PartSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, RegisterDocumentNo);
        _Assert.AreNotEqual('', PartSnapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::Purchase, RegisterDocumentNo));
        Snapshot += PartSnapshot + '#';
        PartSnapshot := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry2."Document No.");
        _Assert.AreNotEqual('', PartSnapshot, StrSubstNo(RowLbl, Enum::"Deferral Document Type"::"G/L", POSEntry2."Document No."));
        Snapshot += PartSnapshot;
    end;

    local procedure GetOtherDocumentRowsMismatch(RowId: Text; POSEntry1: Record "NPR POS Entry"; POSEntry2: Record "NPR POS Entry"; RegisterDocumentNo: Code[20]; I9DocumentNo: Code[20]; ExpectedSnapshot: Text): Text
    var
        ActualSnapshot: Text;
        SnapshotLbl: Label '%1: the I9 Sales row, the Purchase rows of %2 and %3 and the G/L row of %4 expected unchanged [%5], actual [%6]; ', Locked = true;
    begin
        ActualSnapshot :=
            _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, I9DocumentNo) + '#' +
            _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.") + '#' +
            _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, RegisterDocumentNo) + '#' +
            _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry2."Document No.");
        if ActualSnapshot <> ExpectedSnapshot then
            exit(StrSubstNo(SnapshotLbl, RowId, POSEntry1."Document No.", RegisterDocumentNo, POSEntry2."Document No.", ExpectedSnapshot, ActualSnapshot));
    end;

    local procedure GetNoRowsOnAccountMismatch(RowId: Text; AccountNo: Code[20]): Text
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        DeferralAccountCount: Integer;
        GLAccountCount: Integer;
        RowsLbl: Label '%1: table 1706 rows of any type and number on account %2 expected 0, actual %3 as G/L Account and %4 as Deferral Account; ', Locked = true;
    begin
        DeferralPostingBuffer.SetRange("G/L Account", AccountNo);
        GLAccountCount := DeferralPostingBuffer.Count();
        DeferralPostingBuffer.SetRange("G/L Account");
        DeferralPostingBuffer.SetRange("Deferral Account", AccountNo);
        DeferralAccountCount := DeferralPostingBuffer.Count();
        if (GLAccountCount <> 0) or (DeferralAccountCount <> 0) then
            exit(StrSubstNo(RowsLbl, RowId, AccountNo, GLAccountCount, DeferralAccountCount));
    end;

    local procedure GetEntryCountMismatch(RowId: Text; DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date; DebitAmount: Decimal; CreditAmount: Decimal; ExpectedCount: Integer): Text
    var
        GLEntry: Record "G/L Entry";
        EntriesLbl: Label '%1: G/L entries of %2 on account %3 on %4 with debit %5 and credit %6 expected %7, actual %8; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Debit Amount", DebitAmount);
        GLEntry.SetRange("Credit Amount", CreditAmount);
        if GLEntry.Count() <> ExpectedCount then
            exit(StrSubstNo(EntriesLbl, RowId, DocumentNo, AccountNo, PostingDate, DebitAmount, CreditAmount, ExpectedCount, GLEntry.Count()));
    end;

    local procedure GetRowsUnchangedMismatch(RowId: Text; DocumentNo: Code[20]; ExpectedCount: Integer; ExpectedAmount: Decimal): Text
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        RowsLbl: Label '%1: table 1706 Sales rows of %2 expected %3 with amount %4, actual %5 with amount %6; ', Locked = true;
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        DeferralPostingBuffer.SetRange("Document No.", DocumentNo);
        DeferralPostingBuffer.CalcSums(Amount);
        if (DeferralPostingBuffer.Count() <> ExpectedCount) or (DeferralPostingBuffer.Amount <> ExpectedAmount) then
            exit(StrSubstNo(RowsLbl, RowId, DocumentNo, ExpectedCount, ExpectedAmount, DeferralPostingBuffer.Count(), DeferralPostingBuffer.Amount));
    end;

    local procedure GetNoRowsOfLineMismatch(RowId: Text; DocumentNo: Code[20]; DeferralLineNo: Integer): Text
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        RowsLbl: Label '%1: table 1706 Sales rows of %2 with deferral line %3 expected 0, actual %4; ', Locked = true;
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        DeferralPostingBuffer.SetRange("Document No.", DocumentNo);
        DeferralPostingBuffer.SetRange("Deferral Line No.", DeferralLineNo);
        if not DeferralPostingBuffer.IsEmpty() then
            exit(StrSubstNo(RowsLbl, RowId, DocumentNo, DeferralLineNo, DeferralPostingBuffer.Count()));
    end;

    local procedure GetPostedInvoiceScheduleMismatch(RowId: Text; InvoiceNo: Code[20]): Text
    var
        PostedDeferralLine: Record "Posted Deferral Line";
        PostedLinesLbl: Label '%1: posted deferral schedule lines of invoice %2 expected 12, actual %3; ', Locked = true;
    begin
        PostedDeferralLine.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        PostedDeferralLine.SetRange("Document No.", InvoiceNo);
        if PostedDeferralLine.Count() <> 12 then
            exit(StrSubstNo(PostedLinesLbl, RowId, InvoiceNo, PostedDeferralLine.Count()));
    end;
}
