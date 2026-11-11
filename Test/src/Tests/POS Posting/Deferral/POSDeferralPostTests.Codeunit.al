// [FEATURE] [POS Posting] [Deferral]
codeunit 85611 "NPR POS Deferral Post Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibPOSDeferral: Codeunit "NPR Library POS Deferral";
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOldRowsOfFailedRun_WhenReceiptPostsAlone_ThenOwnDeferralPostsOnceAndNoRowRemains()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        MergedPOSEntry: Record "NPR POS Entry";
        OldRowsPOSEntry: Record "NPR POS Entry";
        SecondLinePOSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A receipt whose old rows a failed run left before this change posts its own deferral once and leaves no row, whatever amounts and deferral line number the old rows carry
        Initialize();

        // [GIVEN] Per POS Entry posting with DEF2651 and ITEM2651, and a receipt with the 13 old rows of a failed run
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 1, 0, OldRowsPOSEntry);

        // [WHEN] The nightly job posts the receipt alone
        _LibPOSDeferral.RunNightlyJob();

        // [GIVEN] A receipt with the 13 old rows after 10 invoices merged into them
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 1, 10, MergedPOSEntry);

        // [WHEN] The nightly job posts the receipt alone
        _LibPOSDeferral.RunNightlyJob();

        // [GIVEN] A receipt with the 13 old rows under deferral line number 2
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 2, 0, SecondLinePOSEntry);

        // [WHEN] The nightly job posts the receipt alone, so its new rows carry deferral line number 1
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Each receipt posts G1 once and no row of it remains with any deferral line number
        _Assert.AreEqual('',
            GetOwnDeferralOnceMismatches('S4.a', OldRowsPOSEntry, Item."No.", DeferralTemplate."Deferral Account", 1) +
            GetOwnDeferralOnceMismatches('S4.b', MergedPOSEntry, Item."No.", DeferralTemplate."Deferral Account", 1) +
            GetOwnDeferralOnceMismatches('S4.f', SecondLinePOSEntry, Item."No.", DeferralTemplate."Deferral Account", 1),
            'S4.a, S4.b, S4.f: a receipt with old rows posts its own deferral once and leaves no row');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOldRowsOfFailedRun_WhenPerPeriodRegisterPosts_ThenDeferralPostsUnderRegisterAndNoRowRemains()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        RegisterDocumentNo: Code[20];
    begin
        // [SCENARIO] A receipt with old rows that now posts under Per POS Period posts its deferral once under the register number and leaves no row of the receipt or the register
        Initialize();

        // [GIVEN] Per POS Period posting, and register P1 with receipt T1 of ITEM2651 that holds the 13 old rows of a failed run
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 1, 0, POSEntry);

        // [WHEN] The nightly job posts the register
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] P1 carries G1 once and no row of T1 or P1 remains
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry);
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S4.c', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1Mismatches('S4.c', RegisterDocumentNo, GetRevenueAccount(POSEntry, Item."No."), DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetG1EntryMismatches('S4.c', RegisterDocumentNo, GetRevenueAccount(POSEntry, Item."No."), DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetNoRowsMismatch('S4.c', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S4.c', RegisterDocumentNo),
            'S4.c: the register posts the deferral of the receipt with old rows once and leaves no row');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOldRowsOfFailedRun_WhenRunFailsLineCheckAgain_ThenNoRowRemains()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A receipt with old rows whose run fails the journal line check again leaves no row of the receipt
        Initialize();

        // [GIVEN] A receipt of ITEM2651 with the 13 old rows of a failed run, and failure cause C1 on the payment account
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 1, 0, POSEntry);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run fails, the receipt stays Unposted with no G/L entry on any date, and no row of it remains
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S4.d', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoRowsMismatch('S4.d', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S4.d', POSEntry."Document No."),
            'S4.d: a failed run of a receipt with old rows posts nothing and leaves no row of it');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOldRowsOfTwoLineReceipt_WhenReceiptPosts_ThenBothDeferralsPostOnceAndNoRowRemains()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemNos: List of [Code[20]];
    begin
        // [SCENARIO] A receipt with two ITEM2651 lines whose old rows a failed run left posts the deferral of both lines once and leaves no row
        Initialize();

        // [GIVEN] A receipt with two lines of ITEM2651 that holds the 13 old rows of a failed run of both lines
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry);
        _LibPOSDeferral.InsertOldRowsOfFailedRun(POSEntry."Document No.", 1, GetRevenueAccount(POSEntry, Item."No."), DeferralTemplate."Deferral Account", 2, 0);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] R is credited 700.00 and G1 posts twice on each date, once, and no row of the receipt remains
        _Assert.AreEqual('', GetOwnDeferralOnceMismatches('S4.e', POSEntry, Item."No.", DeferralTemplate."Deferral Account", 2), 'S4.e: a two-line receipt with old rows posts the deferral of both lines once and leaves no row');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOldRowsAndBlockedDeferralAccount_WhenRunIsUndone_ThenOldRowsStayAsTheyWere()
    var
        DeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        RowsBefore: Text;
        RowCountLbl: Label 'S4.g: rows of %1 after the undone run expected 13, actual %2', Locked = true;
        RowsLbl: Label 'S4.g: the rows of %1 stay as they were before the undone run', Locked = true;
    begin
        // [SCENARIO] A run that a hard error undoes leaves the old rows of the receipt as they were before the run
        Initialize();

        // [GIVEN] A receipt of ITEM2651 with the 13 old rows of a failed run, and the deferral account D blocked
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SellItemWithOldRows(Item."No.", DeferralTemplate."Deferral Account", 1, 0, POSEntry);
        _LibPOSDeferral.SetGLAccountBlocked(DeferralTemplate."Deferral Account", true);
        RowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, POSEntry."Document No.");

        // [WHEN] The nightly job posts the receipt
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run stops on the Blocked field of the G/L account D
        _Assert.ExpectedError(GLAccount.FieldCaption(Blocked));
        _Assert.ExpectedError(GLAccount.TableCaption());
        _Assert.ExpectedError(DeferralTemplate."Deferral Account");

        // [THEN] The 13 old rows stay as they were
        _Assert.AreEqual(13, _LibPOSDeferral.CountDeferralBufferRows(POSEntry."Document No."), StrSubstNo(RowCountLbl, POSEntry."Document No.", _LibPOSDeferral.CountDeferralBufferRows(POSEntry."Document No.")));
        _Assert.AreEqual(RowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, POSEntry."Document No."), StrSubstNo(RowsLbl, POSEntry."Document No."));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoDeferralSalesInRegister_WhenNightlyJobPostsPerPeriod_ThenDeferralPostsUnderRegister()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] Per POS Period posts the deferral of both sales of a register under the register number, each date carrying the sum of both
        Initialize();

        // [GIVEN] Per POS Period posting, and register P1 with receipts T1 and T2, each a sale of ITEM2651
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);

        // [WHEN] The nightly job posts P1
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] P1 carries 700.00 revenue and G1 twice on each date, each sales line has its own posted schedule, and no row of T1, T2 or P1 remains
        _Assert.AreEqual('', _LibPOSDeferral.GetPeriodPostMismatches('S5.a', POSEntry1, POSEntry2, Item."No.", DeferralTemplate."Deferral Account"), 'S5.a: Per POS Period posts the deferral of both sales under P1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenDeferralSaleAndPlainSaleInRegister_WhenNightlyJobPostsPerPeriod_ThenOnlyDeferralSalePostsDeferral()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        RegisterDocumentNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        // [SCENARIO] Per POS Period posts G1 under the register for the deferral sale only, and the plain sale posts its revenue to its own account as today
        Initialize();

        // [GIVEN] Per POS Period posting, and register P1 with receipt T1 of ITEM2651 and receipt T2 of ITEM2
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item2."No.", POSEntry2);

        // [WHEN] The nightly job posts P1
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] P1 carries G1 for T1 only, T2's 100.00 is credited to R2, T1's sales line has its posted schedule, and no row of T1, T2 or P1 remains
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry1);
        _LibPOSDeferral.FindSalesLine(POSEntry1, Item."No.", POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S5.b', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetStatusMismatch('S5.b', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1Mismatches('S5.b', RegisterDocumentNo, _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetG1EntryMismatches('S5.b', RegisterDocumentNo, _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), DeferralTemplate."Deferral Account", 1) +
            GetAccountEntriesMismatch('S5.b', RegisterDocumentNo, GetRevenueAccount(POSEntry2, Item2."No."), 1, 0, 100) +
            _LibPOSDeferral.GetPostedScheduleMismatches('S5.b', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetNoRowsMismatch('S5.b', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S5.b', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S5.b', RegisterDocumentNo),
            'S5.b: Per POS Period posts G1 for the deferral sale only and the plain sale as today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCustomizedScheduleWithSkippedMonths_WhenFirstRunPosts_ThenExactlyTheScheduleLinesPost()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        SkipMonths: Codeunit "NPR POS Deferral Skip Months";
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        // [SCENARIO] A first run that succeeds posts exactly the 9 schedule lines a customization created, with no entry for January, February or March
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose schedule a customization builds with 9 lines and no January to March
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        BindSubscription(SkipMonths);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();
        UnbindSubscription(SkipMonths);

        // [THEN] D to R entries exist on exactly the 9 dates with their amounts, the initial pair is 350.00 from R to D, and the posted schedule holds the same 9 lines
        _LibPOSDeferral.GetS6Schedule(Dates, Amounts);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S6.a', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetDeferralGLMismatches('S6.a', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", _LibPOSDeferral.SalePostingDate(), 350, 350, Dates, Amounts) +
            _LibPOSDeferral.GetDeferralGLEntryMismatches('S6.a', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", _LibPOSDeferral.SalePostingDate(), 350, 350, Dates, Amounts) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.a', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270101D) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.a', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270201D) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.a', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270301D) +
            _LibPOSDeferral.GetPostedScheduleMismatches('S6.a', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetNoRowsMismatch('S6.a', POSEntry."Document No."),
            'S6.a: the first run posts exactly the schedule lines the customization created');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenDeferralSale_WhenNightlyJobPosts_ThenDeferralPostsAndJournalEventsSeeDeferralLine()
    var
        DeferralTemplate: Record "Deferral Template";
        RecordedLine: Record "Gen. Journal Line";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        JnlRecorder: Codeunit "NPR POS Deferral Jnl. Recorder";
        RevenueAccountNo: Code[20];
        Mismatches: Text;
        CheckEventTok: Label 'OnBeforeCheckAndPostGenJournal', Locked = true;
        NoLineLbl: Label 'E7: no journal line on revenue account %1 recorded by %2; ', Locked = true;
        LineDeferralLbl: Label 'E7: sales journal line in %1 deferral expected %2 line %3, actual %4 line %5; ', Locked = true;
    begin
        // [SCENARIO] A nightly run without a failure posts the deferral of the POS sale as today, and the journal events receive the sales line with its deferral code and line number
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and no failure cause, with a journal event recorder bound
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        JnlRecorder.AddDocumentNo(POSEntry."Document No.");
        BindSubscription(JnlRecorder);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();
        UnbindSubscription(JnlRecorder);

        // [THEN] The receipt posts G1 and the 350.00 revenue, its posted schedule has 12 lines, it is Posted and no row of it remains
        Mismatches := _LibPOSDeferral.GetPostedSaleMismatches('S7.a', POSEntry, Item."No.", DeferralTemplate."Deferral Account");

        // [THEN] Each of the 2 journal lines fires both insert events in turn with the same values, then the check event receives the same lines in the same order, the sales line with DEF2651 and deferral line 1
        RevenueAccountNo := GetRevenueAccount(POSEntry, Item."No.");
        if not JnlRecorder.FindRecordedLine(JnlRecorder.BufferLineEventName(), RevenueAccountNo, RecordedLine) then
            Mismatches += StrSubstNo(NoLineLbl, RevenueAccountNo, JnlRecorder.BufferLineEventName())
        else
            if (RecordedLine."Deferral Code" <> _LibPOSDeferral.DEF2651Code()) or (RecordedLine."Deferral Line No." <> 1) then
                Mismatches += StrSubstNo(LineDeferralLbl, JnlRecorder.BufferLineEventName(), _LibPOSDeferral.DEF2651Code(), 1, RecordedLine."Deferral Code", RecordedLine."Deferral Line No.");
        if not JnlRecorder.FindRecordedLine(CheckEventTok, RevenueAccountNo, RecordedLine) then
            Mismatches += StrSubstNo(NoLineLbl, RevenueAccountNo, CheckEventTok)
        else
            if (RecordedLine."Deferral Code" <> _LibPOSDeferral.DEF2651Code()) or (RecordedLine."Deferral Line No." <> 1) then
                Mismatches += StrSubstNo(LineDeferralLbl, CheckEventTok, _LibPOSDeferral.DEF2651Code(), 1, RecordedLine."Deferral Code", RecordedLine."Deferral Line No.");
        Mismatches += GetFirstAttemptSequenceMismatches(JnlRecorder.GetFullSequence(), JnlRecorder.BufferLineEventName(), CheckEventTok, 2);
        _Assert.AreEqual('', Mismatches, 'S7.a and E7: a run without a failure posts as today and the journal events see the deferral line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUncompressedRegister_WhenPostActionPosts_ThenDeferralPosts()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] An uncompressed run without a failure posts the deferral of the POS sale as today
        Initialize();

        // [GIVEN] Uncompressed posting and a receipt of ITEM2651 with no failure cause
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::Uncompressed);
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);

        // [WHEN] The post action posts the receipt uncompressed
        _LibPOSDeferral.RunPostAction(POSEntry);

        // [THEN] The receipt posts G1 and the 350.00 revenue, its posted schedule has 12 lines, it is Posted and no row of it remains
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S7.b', POSEntry, Item."No.", DeferralTemplate."Deferral Account"), 'S7.b: an uncompressed run without a failure posts the deferral as today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenDeferralSale_WhenPostActionPosts_ThenDeferralPosts()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] The post action on the POS entry page posts the deferral of the POS sale as today
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and no failure cause
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);

        // [WHEN] The post action posts the receipt
        _LibPOSDeferral.RunPostAction(POSEntry);

        // [THEN] The receipt posts G1 and the 350.00 revenue, its posted schedule has 12 lines, it is Posted and no row of it remains
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S7.c', POSEntry, Item."No.", DeferralTemplate."Deferral Account"), 'S7.c: the post action posts the deferral as today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineDiscountPosting_WhenNightlyJobPosts_ThenDiscountPostsSeparatelyAndDeferralPostsOnce()
    var
        DeferralTemplate: Record "Deferral Template";
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesReceivablesSetupBefore: Record "Sales & Receivables Setup";
        LibraryERM: Codeunit "Library - ERM";
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        // [SCENARIO] With line discounts posted separately, the sale credits 400.00 to revenue, debits the 50.00 discount to the line discount account, and the deferral pairs post once
        Initialize();

        // [GIVEN] Discount Posting "Line Discounts" and a Sales Line Disc. Account in the General Posting Setup of ITEM2651
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        SalesReceivablesSetup.Get();
        SalesReceivablesSetupBefore := SalesReceivablesSetup;
        SalesReceivablesSetup."Discount Posting" := SalesReceivablesSetup."Discount Posting"::"Line Discounts";
        SalesReceivablesSetup.Modify();

        // [GIVEN] A receipt of ITEM2651 at unit price 500.00 incl. VAT with a 12.5 % line discount, so 350.00 excl. VAT after the discount
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        GeneralPostingSetup.Get(POSEntrySalesLine."Gen. Bus. Posting Group", POSEntrySalesLine."Gen. Prod. Posting Group");
        GeneralPostingSetup."Sales Line Disc. Account" := LibraryERM.CreateGLAccountNo();
        GeneralPostingSetup.Modify();
        AddLineDiscount(POSEntrySalesLine);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Discount Posting" := SalesReceivablesSetupBefore."Discount Posting";
        SalesReceivablesSetup.Modify();
        Commit();

        // [THEN] R is credited 400.00 and carries the G1 pairs once, the line discount account is debited 50.00, the posted schedule has 12 lines and no row remains
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S7.d', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetDeferralGLMismatches('S7.d', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", _LibPOSDeferral.SalePostingDate(), 350, 400, Dates, Amounts) +
            _LibPOSDeferral.GetDeferralGLEntryMismatches('S7.d', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", _LibPOSDeferral.SalePostingDate(), 350, 400, Dates, Amounts) +
            GetAccountEntriesMismatch('S7.d', POSEntry."Document No.", GeneralPostingSetup."Sales Line Disc. Account", 1, 50, 0) +
            _LibPOSDeferral.GetPostedScheduleMismatches('S7.d', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetNoRowsMismatch('S7.d', POSEntry."Document No."),
            'S7.d: a line discount posts separately and the deferral pairs post once');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoDeferralLinesOnReceipt_WhenNightlyJobPosts_ThenBothDeferralsPost()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemNos: List of [Code[20]];
    begin
        // [SCENARIO] A receipt with two ITEM2651 lines posts 700.00 revenue, G1 twice on each date and two posted schedules, as today
        Initialize();

        // [GIVEN] A receipt with two lines of ITEM2651 and no failure cause
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] R is credited 700.00, 700.00 moves from R to D, 58.34 per month and 58.26 on 2027-09-01 move back, each line has a posted schedule of 12 lines, and no row remains
        _Assert.AreEqual('',
            GetOwnDeferralOnceMismatches('S7.e', POSEntry, Item."No.", DeferralTemplate."Deferral Account", 2) +
            GetPostedSchedulesOfItemMismatches('S7.e', POSEntry, Item."No.", 2),
            'S7.e: a receipt with two deferral lines posts both deferrals as today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPostingDifferenceWithinMaximum_WhenNightlyJobPosts_ThenDeferralPostsOnce()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        PostedDifferenceLine: Record "Gen. Journal Line";
        JnlRecorder: Codeunit "NPR POS Deferral Jnl. Recorder";
        MaxPostingDifferenceBefore: Decimal;
        Mismatches: Text;
        NoDiffAccountLbl: Label 'The posting profile of receipt %1 must have a POS posting difference account', Locked = true;
        NoDifferenceLineLbl: Label 'E8: no posted journal line of %1 on the difference account %2; ', Locked = true;
        DifferenceLineDeferralLbl: Label 'E8: the posted difference line of %1 deferral expected %2 line %3, actual %4 line %5; ', Locked = true;
    begin
        // [SCENARIO] A run whose posting difference line, within the allowed maximum, carries the deferral code and number of the last sales line posts the deferral of the POS sale once, as today
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose payment line has amount 0, so it makes no journal line and the sales line with DEF2651 and deferral line 1 is the last line the difference line copies
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        SetPaymentAmount(POSEntry, 0);

        // [GIVEN] A maximum posting difference of 500.00, so the 437.50 difference is within it
        _LibPOSDeferral.GetPOSPostingProfile(POSPostingProfile);
        _Assert.AreNotEqual('', POSPostingProfile."POS Posting Diff. Account", StrSubstNo(NoDiffAccountLbl, POSEntry."Document No."));
        MaxPostingDifferenceBefore := POSPostingProfile."Max. POS Posting Diff. (LCY)";
        POSPostingProfile."Max. POS Posting Diff. (LCY)" := 500;
        POSPostingProfile.Modify();
        JnlRecorder.AddDocumentNo(POSEntry."Document No.");
        BindSubscription(JnlRecorder);

        // [WHEN] The nightly job posts the receipt
        _LibPOSDeferral.RunNightlyJob();
        UnbindSubscription(JnlRecorder);
        POSPostingProfile.Get(POSPostingProfile.Code);
        POSPostingProfile."Max. POS Posting Diff. (LCY)" := MaxPostingDifferenceBefore;
        POSPostingProfile.Modify();
        Commit();

        // [THEN] The difference line that posted carries DEF2651 and deferral line 1 of the last sales line
        if not JnlRecorder.FindPostedLine(POSPostingProfile."POS Posting Diff. Account", PostedDifferenceLine) then
            Mismatches += StrSubstNo(NoDifferenceLineLbl, POSEntry."Document No.", POSPostingProfile."POS Posting Diff. Account")
        else
            if (PostedDifferenceLine."Deferral Code" <> _LibPOSDeferral.DEF2651Code()) or (PostedDifferenceLine."Deferral Line No." <> 1) then
                Mismatches += StrSubstNo(DifferenceLineDeferralLbl, POSEntry."Document No.", _LibPOSDeferral.DEF2651Code(), 1, PostedDifferenceLine."Deferral Code", PostedDifferenceLine."Deferral Line No.");

        // [THEN] The difference account is debited 437.50, and the receipt posts G1 once with its posted schedule and no row left
        Mismatches +=
            GetAccountEntriesMismatch('E8', POSEntry."Document No.", POSPostingProfile."POS Posting Diff. Account", 1, 437.5, 0) +
            _LibPOSDeferral.GetPostedSaleMismatches('E8', POSEntry, Item."No.", DeferralTemplate."Deferral Account");
        _Assert.AreEqual('', Mismatches, 'E8: a posting difference line carries the deferral of the last sales line and does not post the deferral a second time');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPostedReceipt_WhenPostingLogRunsAgain_ThenNothingPostsAgain()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        GLEntryCountBefore: Integer;
        GLEntryCountLbl: Label 'E16: G/L entries of %1 expected %2 as after the first run, actual %3; ', Locked = true;
        Mismatches: Text;
    begin
        // [SCENARIO] A run from the posting log for a receipt that is already Posted posts nothing again, its deferral included, and writes no row
        Initialize();

        // [GIVEN] A receipt of ITEM2651 that the nightly job posted
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.RunNightlyJob();
        POSEntry.Get(POSEntry."Entry No.");
        GLEntryCountBefore := CountGLEntries(POSEntry."Document No.");

        // [WHEN] The POS posting log page runs the posting of that run again
        _LibPOSDeferral.RepostFromPOSPostingLog(POSEntry."POS Posting Log Entry No.");

        // [THEN] The G/L of the receipt is unchanged: G1 once with its posted schedule, the receipt is Posted and no row of it exists
        Mismatches := _LibPOSDeferral.GetPostedSaleMismatches('E16', POSEntry, Item."No.", DeferralTemplate."Deferral Account");
        if CountGLEntries(POSEntry."Document No.") <> GLEntryCountBefore then
            Mismatches += StrSubstNo(GLEntryCountLbl, POSEntry."Document No.", GLEntryCountBefore, CountGLEntries(POSEntry."Document No."));
        _Assert.AreEqual('', Mismatches, 'E16: a run for a Posted receipt posts nothing again');
    end;

    local procedure Initialize()
    begin
        if _IsInitialized then
            exit;
        _LibPOSDeferral.EnsureGlobalSetup();
        _IsInitialized := true;
        Commit();
    end;

    local procedure SellItemWithOldRows(ItemNo: Code[20]; DeferralAccountNo: Code[20]; DeferralLineNo: Integer; NoOfMergedInvoices: Integer; var POSEntry: Record "NPR POS Entry")
    begin
        _LibPOSDeferral.CreateSaleOfItem(ItemNo, POSEntry);
        _LibPOSDeferral.InsertOldRowsOfFailedRun(POSEntry."Document No.", DeferralLineNo, GetRevenueAccount(POSEntry, ItemNo), DeferralAccountNo, 1, NoOfMergedInvoices);
    end;

    local procedure GetRevenueAccount(POSEntry: Record "NPR POS Entry"; SalesLineNo: Code[20]): Code[20]
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        _LibPOSDeferral.FindSalesLine(POSEntry, SalesLineNo, POSEntrySalesLine);
        exit(_LibPOSDeferral.GetSalesAccount(POSEntrySalesLine));
    end;

    local procedure AddLineDiscount(POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    begin
        POSEntrySalesLine.Get(POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.");
        POSEntrySalesLine."Unit Price" := 500;
        POSEntrySalesLine."Line Discount %" := 12.5;
        POSEntrySalesLine."Line Discount Amount Excl. VAT" := 50;
        POSEntrySalesLine."Line Discount Amount Incl. VAT" := 62.5;
        POSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := 50;
        POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := 62.5;
        POSEntrySalesLine.Modify();
    end;

    local procedure SetPaymentAmount(POSEntry: Record "NPR POS Entry"; NewAmount: Decimal)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.FindFirst();
        POSEntryPaymentLine.Amount := NewAmount;
        POSEntryPaymentLine."Amount (LCY)" := NewAmount;
        POSEntryPaymentLine.Modify();
    end;

    local procedure GetOwnDeferralOnceMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"; ItemNo: Code[20]; DeferralAccountNo: Code[20]; Multiplier: Integer): Text
    begin
        exit(
            _LibPOSDeferral.GetStatusMismatch(RowId, POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1Mismatches(RowId, POSEntry."Document No.", GetRevenueAccount(POSEntry, ItemNo), DeferralAccountNo, Multiplier) +
            _LibPOSDeferral.GetG1EntryMismatches(RowId, POSEntry."Document No.", GetRevenueAccount(POSEntry, ItemNo), DeferralAccountNo, Multiplier) +
            _LibPOSDeferral.GetNoRowsMismatch(RowId, POSEntry."Document No."));
    end;

    local procedure GetFirstAttemptSequenceMismatches(Sequence: Text; InsertEventName: Text; CheckEventName: Text; ExpectedNoOfLines: Integer) Mismatches: Text
    var
        EventNames: List of [Text];
        Values: List of [Text];
        FullSequence: Text;
        RecordText: Text;
        i: Integer;
        Pos: Integer;
        InsertFromEventTok: Label 'OnAfterInsertFromPOSPostingBufferToGenJournal', Locked = true;
        CountLbl: Label 'E7: journal event records expected %1 (%2 lines, each insert, insert-from and check), actual %3, sequence [%4]; ', Locked = true;
        OrderLbl: Label 'E7: journal line %1 events expected %2, %3 and %4, actual %5, %6 and %7; ', Locked = true;
        ValuesLbl: Label 'E7: journal line %1 values expected [%2] in every event, actual insert-from [%3] and check [%4]; ', Locked = true;
    begin
        FullSequence := Sequence;
        while Sequence <> '' do begin
            Pos := Sequence.IndexOf('; ');
            if Pos = 0 then
                Pos := StrLen(Sequence) + 1;
            RecordText := CopyStr(Sequence, 1, Pos - 1);
            Sequence := CopyStr(Sequence, Pos + 2);
            EventNames.Add(CopyStr(RecordText, 1, RecordText.IndexOf('|') - 1));
            Values.Add(CopyStr(RecordText, RecordText.IndexOf('|') + 1));
        end;
        if EventNames.Count() <> 3 * ExpectedNoOfLines then
            exit(StrSubstNo(CountLbl, 3 * ExpectedNoOfLines, ExpectedNoOfLines, EventNames.Count(), FullSequence));
        for i := 1 to ExpectedNoOfLines do begin
            if (EventNames.Get(2 * i - 1) <> InsertEventName) or (EventNames.Get(2 * i) <> InsertFromEventTok) or (EventNames.Get(2 * ExpectedNoOfLines + i) <> CheckEventName) then
                Mismatches += StrSubstNo(OrderLbl, i, InsertEventName, InsertFromEventTok, CheckEventName, EventNames.Get(2 * i - 1), EventNames.Get(2 * i), EventNames.Get(2 * ExpectedNoOfLines + i));
            if (Values.Get(2 * i) <> Values.Get(2 * i - 1)) or (Values.Get(2 * ExpectedNoOfLines + i) <> Values.Get(2 * i - 1)) then
                Mismatches += StrSubstNo(ValuesLbl, i, Values.Get(2 * i - 1), Values.Get(2 * i), Values.Get(2 * ExpectedNoOfLines + i));
        end;
    end;

    local procedure GetPostedSchedulesOfItemMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"; ItemNo: Code[20]; ExpectedNoOfLines: Integer) Mismatches: Text
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Amounts: List of [Decimal];
        Dates: List of [Date];
        LineCountLbl: Label '%1: sales lines of %2 on receipt %3 expected %4, actual %5; ', Locked = true;
    begin
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("No.", ItemNo);
        if POSEntrySalesLine.Count() <> ExpectedNoOfLines then
            Mismatches += StrSubstNo(LineCountLbl, RowId, ItemNo, POSEntry."Document No.", ExpectedNoOfLines, POSEntrySalesLine.Count());
        if POSEntrySalesLine.FindSet() then
            repeat
                Mismatches += _LibPOSDeferral.GetPostedScheduleMismatches(RowId, POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts);
            until POSEntrySalesLine.Next() = 0;
    end;

    local procedure GetAccountEntriesMismatch(RowId: Text; DocumentNo: Code[20]; AccountNo: Code[20]; ExpectedCount: Integer; ExpectedDebit: Decimal; ExpectedCredit: Decimal): Text
    var
        GLEntry: Record "G/L Entry";
        AccountEntriesLbl: Label '%1: G/L entries of %2 on account %3 expected %4 entries with debit %5 and credit %6, actual %7 entries with debit %8 and credit %9; ', Locked = true;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        GLEntry.CalcSums("Debit Amount", "Credit Amount");
        if (GLEntry.Count() <> ExpectedCount) or (GLEntry."Debit Amount" <> ExpectedDebit) or (GLEntry."Credit Amount" <> ExpectedCredit) then
            exit(StrSubstNo(AccountEntriesLbl, RowId, DocumentNo, AccountNo, ExpectedCount, ExpectedDebit, ExpectedCredit, GLEntry.Count(), GLEntry."Debit Amount", GLEntry."Credit Amount"));
    end;

    local procedure CountGLEntries(DocumentNo: Code[20]): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        exit(GLEntry.Count());
    end;
}
