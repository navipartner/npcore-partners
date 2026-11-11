// [FEATURE] [POS Posting] [Deferral]
codeunit 85606 "NPR POS Deferral Repost Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibPOSDeferral: Codeunit "NPR Library POS Deferral";
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineCheckFailure_WhenNightlyJobReposts_ThenDeferralPostsAndJournalLinesMatchFirstAttempt()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        RecordedLine: Record "Gen. Journal Line";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        JnlRecorder: Codeunit "NPR POS Deferral Jnl. Recorder";
        FirstAttemptMismatches: Text;
        FirstAttemptSequence: Text;
        Mismatches: Text;
        SequenceLbl: Label 'E7: repost journal events expected [%1], actual [%2]; ', Locked = true;
        NoLineLbl: Label 'E7: no repost journal line on revenue account %1; ', Locked = true;
        LineDeferralLbl: Label 'E7: repost sales journal line deferral expected %1 line %2, actual %3 line %4; ', Locked = true;
    begin
        // [SCENARIO] A nightly repost after a failed line check posts the saved deferral of the POS sale, and the journal events receive the lines of the first attempt
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose first nightly run failed the journal line check, with a journal event recorder bound
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        JnlRecorder.AddDocumentNo(POSEntry."Document No.");
        BindSubscription(JnlRecorder);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        FirstAttemptSequence := JnlRecorder.GetFullSequence();
        FirstAttemptMismatches := GetJournalEventMismatches('E7 first attempt', JnlRecorder, _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), C1."No.");
        JnlRecorder.ClearRecords();

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();
        UnbindSubscription(JnlRecorder);

        // [THEN] The receipt posts all of G1 from its saved schedule and leaves no row behind
        Mismatches := _LibPOSDeferral.GetPostedSaleMismatches('S3.a', POSEntry, Item."No.", DeferralTemplate."Deferral Account");

        // [THEN] The repost journal events receive the same complete lines in the same order as the first attempt, in today's event order, the sales line with DEF2651 and deferral line 1
        Mismatches += FirstAttemptMismatches + GetJournalEventMismatches('E7 repost', JnlRecorder, _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), C1."No.");
        if JnlRecorder.GetFullSequence() <> FirstAttemptSequence then
            Mismatches += StrSubstNo(SequenceLbl, FirstAttemptSequence, JnlRecorder.GetFullSequence());
        if not JnlRecorder.FindRecordedLine(JnlRecorder.BufferLineEventName(), _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), RecordedLine) then
            Mismatches += StrSubstNo(NoLineLbl, _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine))
        else
            if (RecordedLine."Deferral Code" <> _LibPOSDeferral.DEF2651Code()) or (RecordedLine."Deferral Line No." <> 1) then
                Mismatches += StrSubstNo(LineDeferralLbl, _LibPOSDeferral.DEF2651Code(), 1, RecordedLine."Deferral Code", RecordedLine."Deferral Line No.");
        _Assert.AreEqual('', Mismatches, 'S3.a and E7: the nightly repost posts the saved deferral and the journal events see first-attempt lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPostActionFailure_WhenPostActionReposts_ThenDeferralPosts()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A repost from the POS entry post action after a failed post action posts the saved deferral of the POS sale
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose post action run failed the journal line check with stop on error
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.SetFailureCauseC1(POSEntry, C1);
        asserterror _LibPOSDeferral.RunPostAction(POSEntry);
        _Assert.ExpectedError(_LibPOSDeferral.GetMandatoryDimensionErrorText(C1));
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The post action posts the receipt again
        _LibPOSDeferral.RunPostAction(POSEntry);

        // [THEN] The receipt posts all of G1 from its saved schedule and leaves no row behind
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S3.b', POSEntry, Item."No.", DeferralTemplate."Deferral Account"), 'S3.b: the post action repost posts the saved deferral of the POS sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoFailedNights_WhenNightlyJobReposts_ThenDeferralPosts()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Amounts: List of [Decimal];
        Dates: List of [Date];
        Mismatches: Text;
    begin
        // [SCENARIO] A nightly repost after two failed nights, the second one with the schedule of the first, keeps that schedule through the second failure and posts its 12 months after the template changes
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose nightly run failed the line check, and failed again the next night
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.RunNightlyJob();
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        Mismatches := _LibPOSDeferral.GetOpenScheduleMismatches('S3.c after the second failed night', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts);

        // [GIVEN] DEF2651 changes from 12 to 6 periods, and the failure cause is removed
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate."No. of Periods" := 6;
        DeferralTemplate.Modify();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The second failed night kept the open schedule of the first with DEF2651 and the 12 months of G1, and the repost posts all of G1 from it and leaves no row behind
        Mismatches += _LibPOSDeferral.GetPostedSaleMismatches('S3.c', POSEntry, Item."No.", DeferralTemplate."Deferral Account");
        _Assert.AreEqual('', Mismatches, 'S3.c: the second failed night keeps the first saved schedule and the nightly repost posts its 12 months');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ErrorCountMessageHandler')]
    procedure GivenBalanceCheckFailure_WhenLineRestoredAndNightlyJobReposts_ThenDeferralPosts()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry: Record "NPR POS Entry";
        DeletedSalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemNos: List of [Code[20]];
    begin
        // [SCENARIO] A nightly repost after a failed balance check, once the deleted line is restored, posts the saved deferral of the POS sale
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and ITEM2 whose ITEM2 line is deleted, so the nightly run fails the balance check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        ItemNos.Add(Item."No.");
        ItemNos.Add(Item2."No.");
        _LibPOSDeferral.CreateSale(ItemNos, POSEntry);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item2."No.", POSEntrySalesLine);
        DeletedSalesLine := POSEntrySalesLine;
        POSEntrySalesLine.Delete();
        _LibPOSDeferral.RunNightlyJob();
        _Assert.AreEqual('', _LibPOSDeferral.GetStatusMismatch('S3.d first run', POSEntry."Entry No.", POSEntry."Post Entry Status"::"Error while Posting"), 'The balance check failure marks the receipt Error while Posting');

        // [GIVEN] The deleted line is restored
        DeletedSalesLine.Insert();

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt posts all of G1 from its saved schedule and leaves no row behind
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S3.d', POSEntry, Item."No.", DeferralTemplate."Deferral Account"), 'S3.d: the nightly repost after a failed balance check posts the saved deferral of the POS sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodFailure_WhenNightlyJobReposts_ThenBothDeferralsPostUnderRegister()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A nightly repost of a failed Per POS Period register posts both sales' saved deferrals under the register number, each month carrying the sum
        Initialize();

        // [GIVEN] Register P1 with receipts T1 and T2 of ITEM2651 under Per POS Period, whose nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _LibPOSDeferral.FailWithC1(POSEntry1, C1);
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry2);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the register again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] P1 carries G1 twice on each date, each sales line has its own posted schedule, and no row of T1, T2 or P1 remains
        _Assert.AreEqual('', _LibPOSDeferral.GetPeriodPostMismatches('S3.e', POSEntry1, POSEntry2, Item."No.", DeferralTemplate."Deferral Account"), 'S3.e: the nightly repost of the register posts both saved deferrals under P1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTemplateAndMembershipDatesChanged_WhenNightlyJobReposts_ThenFirstScheduleMonthsPost()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        LinkPOSEntry: Record "NPR POS Entry";
        POSEntry: Record "NPR POS Entry";
        LinkPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Amounts: List of [Decimal];
        Dates: List of [Date];
    begin
        // [SCENARIO] A repost keeps the 12 months of the first schedule when the template, the membership start date or the membership number of periods change after the failed run
        Initialize();

        // [GIVEN] Receipts T1 and T2 of ITEM2651 whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", LinkPOSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(LinkPOSEntry);

        // [GIVEN] DEF2651 changes from 12 to 6 periods
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate."No. of Periods" := 6;
        DeferralTemplate.Modify();

        // [GIVEN] A membership entry of T1's sales line now starts on 2027-01-01, and a membership entry link of T2's sales line now covers 2027-01-01 to 2027-06-30, 6 periods
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        InsertMembershipEntryForSalesLine(POSEntrySalesLine, 20270101D);
        _LibPOSDeferral.FindSalesLine(LinkPOSEntry, Item."No.", LinkPOSEntrySalesLine);
        InsertMembershipEntryLinkForSalesLine(LinkPOSEntrySalesLine, 20270101D, 20270630D);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipts again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The G/L of each receipt holds the 12 months of G1
        _Assert.AreEqual('',
            _LibPOSDeferral.GetStatusMismatch('S3.f', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1EntryMismatches('S3.f', POSEntry."Document No.", _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetNoRowsMismatch('S3.f', POSEntry."Document No.") +
            _LibPOSDeferral.GetStatusMismatch('S3.f T2', LinkPOSEntry."Entry No.", LinkPOSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1EntryMismatches('S3.f T2', LinkPOSEntry."Document No.", _LibPOSDeferral.GetSalesAccount(LinkPOSEntrySalesLine), DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetNoRowsMismatch('S3.f T2', LinkPOSEntry."Document No."),
            'S3.f: the repost posts the 12 months of the first schedule though DEF2651 now has 6 periods');

        // [THEN] Each posted schedule keeps the 12 months of the first schedule from 2026-10-13, not the new membership start date or number of periods, and no open schedule remains
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        _Assert.AreEqual('',
            _LibPOSDeferral.GetPostedScheduleMismatches('E4 start date', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetOpenScheduleGoneMismatch('E4 start date', POSEntrySalesLine) +
            _LibPOSDeferral.GetPostedScheduleMismatches('E4 periods', LinkPOSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetOpenScheduleGoneMismatch('E4 periods', LinkPOSEntrySalesLine),
            'E4: the repost keeps the months of the first schedule though the membership dates changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodFailureAndFailedLogRepost_WhenLogRepostsAfterFix_ThenBothDeferralsPostUnderRegister()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A repost from the POS posting log page, after the nightly run and a log repost both failed, posts both saved deferrals under the register number
        Initialize();

        // [GIVEN] Register P1 with receipts T1 and T2 of ITEM2651 under Per POS Period, whose nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _LibPOSDeferral.FailWithC1(POSEntry1, C1);

        // [GIVEN] A repost from the POS posting log page fails again while the cause is still active
        POSEntry1.Get(POSEntry1."Entry No.");
        asserterror _LibPOSDeferral.RepostFromPOSPostingLog(POSEntry1."POS Posting Log Entry No.");
        _Assert.ExpectedError(_LibPOSDeferral.GetMandatoryDimensionErrorText(C1));
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry1);
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(POSEntry2);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The POS posting log page posts the register again
        POSEntry1.Get(POSEntry1."Entry No.");
        _LibPOSDeferral.RepostFromPOSPostingLog(POSEntry1."POS Posting Log Entry No.");

        // [THEN] P1 carries G1 twice on each date, each sales line has its own posted schedule, and no row of T1, T2 or P1 remains
        _Assert.AreEqual('', _LibPOSDeferral.GetPeriodPostMismatches('S3.g', POSEntry1, POSEntry2, Item."No.", DeferralTemplate."Deferral Account"), 'S3.g: the log page repost of the register posts both saved deferrals under P1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenGLAccountLineFailure_WhenNightlyJobReposts_ThenDeferralPostsFromGLAccount()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        // [SCENARIO] A nightly repost of a failed receipt that sells GLDEF as a G/L Account line posts the saved deferral with GLDEF in place of the revenue account
        Initialize();

        // [GIVEN] A receipt that sells GLDEF as a G/L Account line, whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateGLDEF(GLAccount, Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.ConvertSalesLineToGLAccount(POSEntry, GLAccount."No.");
        _LibPOSDeferral.FailWithC1(POSEntry, C1);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt posts all of G1 with GLDEF in place of R and leaves no row behind
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S3.h', POSEntry, GLAccount."No.", DeferralTemplate."Deferral Account"), 'S3.h: the nightly repost posts the saved deferral of the G/L Account line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenRepostUndoneByBlockedAccount_WhenNightlyJobRepostsAfterTemplateChange_ThenFirstScheduleMonthsPost()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        BlockedRunRaisedError: Boolean;
        Amounts: List of [Decimal];
        Dates: List of [Date];
        BlockedRunErrorText: Text;
        BlockedRunMismatches: Text;
        Mismatches: Text;
        NoErrorLbl: Label 'S3.i undone run: the nightly run with the deferral account %1 blocked raised no error; ', Locked = true;
        TestFieldTextLbl: Label '%1 must be equal to ''%2''', Locked = true;
        ErrorTextLbl: Label 'S3.i undone run: the error expected to contain [%1] and the account %2, actual [%3]; ', Locked = true;
    begin
        // [SCENARIO] A repost that a hard error undid keeps the schedule of the first failed run, so the next repost posts its 12 months though the template changed
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);

        // [GIVEN] The failure cause is removed and the next nightly run runs with the deferral account D blocked, the run a hard error undoes
        _LibPOSDeferral.RemoveFailureCause(C1);
        _LibPOSDeferral.SetGLAccountBlocked(DeferralTemplate."Deferral Account", true);
        Commit();
        BlockedRunRaisedError := not Codeunit.Run(Codeunit::"NPR POS Post GL Entries JQ");
        BlockedRunErrorText := GetLastErrorText();
        if not BlockedRunRaisedError then
            BlockedRunMismatches := StrSubstNo(NoErrorLbl, DeferralTemplate."Deferral Account")
        else
            if (StrPos(BlockedRunErrorText, StrSubstNo(TestFieldTextLbl, GLAccount.FieldCaption(Blocked), Format(false))) = 0) or (StrPos(BlockedRunErrorText, DeferralTemplate."Deferral Account") = 0) then
                BlockedRunMismatches := StrSubstNo(ErrorTextLbl, StrSubstNo(TestFieldTextLbl, GLAccount.FieldCaption(Blocked), Format(false)), DeferralTemplate."Deferral Account", BlockedRunErrorText);
        BlockedRunMismatches +=
            _LibPOSDeferral.GetStatusMismatch('S3.i undone run', POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('S3.i undone run', POSEntry."Document No.") +
            _LibPOSDeferral.GetNoAccountEntriesMismatch('S3.i undone run', POSEntry."Document No.", _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine)) +
            _LibPOSDeferral.GetNoAccountEntriesMismatch('S3.i undone run', POSEntry."Document No.", DeferralTemplate."Deferral Account") +
            _LibPOSDeferral.GetNoRowsMismatch('S3.i undone run', POSEntry."Document No.") +
            _LibPOSDeferral.GetOpenScheduleMismatches('S3.i undone run', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts);

        // [GIVEN] D is unblocked and DEF2651 changes from 12 to 6 periods
        _LibPOSDeferral.SetGLAccountBlocked(DeferralTemplate."Deferral Account", false);
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate."No. of Periods" := 6;
        DeferralTemplate.Modify();

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The blocked run stopped on D and left the receipt Unposted with nothing posted, no row and the 12-month schedule of the first failed run
        Mismatches := BlockedRunMismatches;

        // [THEN] The receipt posts the 12 months of G1 from the schedule of the first failed run and leaves no row behind
        Mismatches += _LibPOSDeferral.GetPostedSaleMismatches('S3.i', POSEntry, Item."No.", DeferralTemplate."Deferral Account");
        _Assert.AreEqual('', Mismatches, 'S3.i: the run undone by the blocked deferral account keeps the first schedule, and the next repost posts its 12 months');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFailureWithoutSavedSchedule_WhenTemplateSetAndNightlyJobReposts_ThenFirstAttemptPostsDeferral()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NoScheduleLbl: Label 'The failed run of receipt %1 without a default template saves no schedule', Locked = true;
    begin
        // [SCENARIO] A run that finds no saved schedule is a first attempt: it creates the schedule from the item's new template and posts all of G1
        Initialize();

        // [GIVEN] A receipt of ITEM2651 without a default deferral template, whose first nightly run failed the line check and saved no schedule
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        Item."Default Deferral Template Code" := '';
        Item.Modify();
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        _Assert.IsFalse(_LibPOSDeferral.OpenScheduleExists(POSEntrySalesLine), StrSubstNo(NoScheduleLbl, POSEntry."Document No."));

        // [GIVEN] DEF2651 is set on the item and the failure cause is removed
        Item.Get(Item."No.");
        Item."Default Deferral Template Code" := _LibPOSDeferral.DEF2651Code();
        Item.Modify();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run creates the schedule from DEF2651, posts all of G1 and leaves no row behind
        _Assert.AreEqual('', _LibPOSDeferral.GetPostedSaleMismatches('S3.j', POSEntry, Item."No.", DeferralTemplate."Deferral Account"), 'S3.j: a run without a saved schedule is a first attempt and posts all of G1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFailureWithSkippedMonthsSchedule_WhenNightlyJobReposts_ThenExactlyTheSavedLinesPost()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        SkipMonths: Codeunit "NPR POS Deferral Skip Months";
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
        Mismatches: Text;
    begin
        // [SCENARIO] A repost posts exactly the 9 schedule lines that a customization created on the failed first run, with no entry for January, February or March
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose schedule a customization builds with 9 lines and no January to March, and whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        BindSubscription(SkipMonths);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);
        UnbindSubscription(SkipMonths);

        // [GIVEN] The failure cause is removed
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] D to R entries exist on exactly the 9 saved dates with their amounts, the initial pair is 350.00 from R to D, and the posted schedule holds the same 9 lines
        _LibPOSDeferral.GetS6Schedule(Dates, Amounts);
        _LibPOSDeferral.FindSalesLine(POSEntry, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
        Mismatches :=
            _LibPOSDeferral.GetStatusMismatch('S6.b', POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetDeferralGLEntryMismatches('S6.b', POSEntry."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", _LibPOSDeferral.SalePostingDate(), 350, 350, Dates, Amounts) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.b', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270101D) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.b', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270201D) +
            _LibPOSDeferral.GetNoEntryOnDateMismatch('S6.b', POSEntry."Document No.", DeferralTemplate."Deferral Account", 20270301D) +
            _LibPOSDeferral.GetPostedScheduleMismatches('S6.b', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetOpenScheduleGoneMismatch('S6.b', POSEntrySalesLine) +
            _LibPOSDeferral.GetNoRowsMismatch('S6.b', POSEntry."Document No.");
        _Assert.AreEqual('', Mismatches, 'S6.b: the repost posts exactly the schedule lines the customization saved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTemplateRemovedFromItemAndAccount_WhenNightlyJobReposts_ThenSalesPostWithoutDeferral()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        GLAccountPOSEntry: Record "NPR POS Entry";
        ItemPOSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] A repost after the default template is removed from the item, or from the G/L account, posts the sale with no deferral and keeps the open schedule
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and a receipt of GLDEF as a G/L Account line, whose first nightly run failed the line check
        SellItemAndGLAccountAndFailWithC1(DeferralTemplate, Item, GLAccount, ItemPOSEntry, GLAccountPOSEntry, C1);

        // [GIVEN] The default deferral template is removed from ITEM2651 and from GLDEF, and the failure cause is removed
        Item.Get(Item."No.");
        Item."Default Deferral Template Code" := '';
        Item.Modify();
        GLAccount.Get(GLAccount."No.");
        GLAccount."Default Deferral Template Code" := '';
        GLAccount.Modify();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipts again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Each sale posts 350.00 to revenue with no deferral entry, and its open schedule stays
        _Assert.AreEqual('',
            GetNoDeferralRepostMismatches('E1 item', ItemPOSEntry, Item."No.", DeferralTemplate."Deferral Account", '') +
            GetNoDeferralRepostMismatches('E1 G/L account', GLAccountPOSEntry, GLAccount."No.", DeferralTemplate."Deferral Account", ''),
            'E1: a repost without a default template posts no deferral and keeps the open schedule');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenItemAndAccountMovedToOtherTemplate_WhenNightlyJobReposts_ThenFirstSchedulePostsUnchanged()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        OtherDeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        GLAccountPOSEntry: Record "NPR POS Entry";
        ItemPOSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] A repost after the item, or the G/L account, moved to another template posts the first schedule unchanged with template DEF2651 and its deferral account
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and a receipt of GLDEF as a G/L Account line, whose first nightly run failed the line check
        SellItemAndGLAccountAndFailWithC1(DeferralTemplate, Item, GLAccount, ItemPOSEntry, GLAccountPOSEntry, C1);

        // [GIVEN] ITEM2651 and GLDEF move to template DEF6 with 6 periods and its own deferral account, and the failure cause is removed
        _LibPOSDeferral.CreateDeferralTemplate('DEF6', 6, OtherDeferralTemplate);
        Item.Get(Item."No.");
        Item."Default Deferral Template Code" := OtherDeferralTemplate."Deferral Code";
        Item.Modify();
        GLAccount.Get(GLAccount."No.");
        GLAccount."Default Deferral Template Code" := OtherDeferralTemplate."Deferral Code";
        GLAccount.Modify();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipts again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Each sale posts G1 to the deferral account of DEF2651 with DEF2651 on the posted schedule and the sales line, and nothing to the DEF6 account
        _Assert.AreEqual('',
            _LibPOSDeferral.GetPostedSaleMismatches('E2 item', ItemPOSEntry, Item."No.", DeferralTemplate."Deferral Account") +
            _LibPOSDeferral.GetNoAccountEntriesMismatch('E2 item', ItemPOSEntry."Document No.", OtherDeferralTemplate."Deferral Account") +
            _LibPOSDeferral.GetPostedSaleMismatches('E2 G/L account', GLAccountPOSEntry, GLAccount."No.", DeferralTemplate."Deferral Account") +
            _LibPOSDeferral.GetNoAccountEntriesMismatch('E2 G/L account', GLAccountPOSEntry."Document No.", OtherDeferralTemplate."Deferral Account"),
            'E2: the repost posts the first schedule with its own template DEF2651');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenDeferralAccountChanged_WhenNightlyJobReposts_ThenDeferralPostsToNewAccount()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryERM: Codeunit "Library - ERM";
        OldDeferralAccountNo: Code[20];
    begin
        // [SCENARIO] A repost after the deferral account of DEF2651 changed posts the saved deferral to the new account
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);

        // [GIVEN] The deferral account of DEF2651 changes from D to a new account, and the failure cause is removed
        OldDeferralAccountNo := DeferralTemplate."Deferral Account";
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate."Deferral Account" := LibraryERM.CreateGLAccountNo();
        DeferralTemplate.Modify();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] The receipt posts G1 to the new deferral account and nothing to D
        _Assert.AreEqual('',
            _LibPOSDeferral.GetPostedSaleMismatches('E3', POSEntry, Item."No.", DeferralTemplate."Deferral Account") +
            _LibPOSDeferral.GetNoAccountEntriesMismatch('E3', POSEntry."Document No.", OldDeferralAccountNo),
            'E3: the repost posts the deferral to the account the template has when the run posts');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFirstAttemptUndoneByBlockedAccount_WhenNightlyJobRetries_ThenRunIsUndoneAgain()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        UncompressedDeferralTemplate: Record "Deferral Template";
        UncompressedItem: Record Item;
        UncompressedPOSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        Mismatches: Text;
    begin
        // [SCENARIO] A retry that finds no saved schedule after a first attempt undone by a blocked deferral account is a first attempt and is undone again, under Per POS Entry and Uncompressed, leaving nothing of the run
        Initialize();

        // [GIVEN] A Per POS Entry receipt of ITEM2651 with the deferral account D blocked, whose first nightly run was undone by the hard error
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.SetGLAccountBlocked(DeferralTemplate."Deferral Account", true);
        asserterror _LibPOSDeferral.RunNightlyJob();
        AssertBlockedAccountError(DeferralTemplate."Deferral Account");

        // [WHEN] The nightly job retries the Per POS Entry receipt
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The retry stops on the blocked deferral account
        AssertBlockedAccountError(DeferralTemplate."Deferral Account");

        // [THEN] The receipt stays Unposted with no G/L entry on any date, no row and no open schedule of the run
        Mismatches := GetUndoneFirstAttemptMismatches('E12 Per POS Entry', POSEntry, Item."No.");

        // [GIVEN] An Uncompressed receipt of ITEM2651 with its deferral account blocked, whose first nightly run was undone by the hard error
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::Uncompressed);
        _LibPOSDeferral.CreateDEF2651(UncompressedDeferralTemplate);
        _LibPOSDeferral.CreateItem2651(UncompressedItem);
        _LibPOSDeferral.CreateSaleOfItem(UncompressedItem."No.", UncompressedPOSEntry);
        _LibPOSDeferral.SetGLAccountBlocked(UncompressedDeferralTemplate."Deferral Account", true);
        asserterror _LibPOSDeferral.RunNightlyJob();
        AssertBlockedAccountError(UncompressedDeferralTemplate."Deferral Account");

        // [WHEN] The nightly job retries the Uncompressed receipt
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The retry stops on the blocked deferral account
        AssertBlockedAccountError(UncompressedDeferralTemplate."Deferral Account");

        // [THEN] The receipt stays Unposted with no G/L entry on any date, no row and no open schedule of the run
        Mismatches += GetUndoneFirstAttemptMismatches('E12 Uncompressed', UncompressedPOSEntry, UncompressedItem."No.");
        _Assert.AreEqual('', Mismatches, 'E12: a run undone by a hard error leaves nothing of the run');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPerPeriodRegisterWithBlockedDeferralAccount_WhenNightlyJobRuns_ThenWholeRegisterIsUndone()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        Item2: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
        PostedDeferralHeader: Record "Posted Deferral Header";
        RegisterDocumentNo: Code[20];
        Mismatches: Text;
        PostedScheduleLbl: Label 'E12 Per POS Period: a posted deferral schedule of POS entry %1 line %2 of receipt %3 expected none, actual one; ', Locked = true;
    begin
        // [SCENARIO] Under Per POS Period a nightly run that a blocked deferral account stops is undone for the whole register: no receipt posts and nothing of the run remains
        Initialize();

        // [GIVEN] Register P1 under Per POS Period with receipt T1 of ITEM2651 and receipt T2 of ITEM2, and the deferral account D of DEF2651 blocked
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Period");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateItem2(Item2);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.CreateSaleOfItem(Item2."No.", POSEntry2);
        RegisterDocumentNo := _LibPOSDeferral.GetPeriodRegisterDocumentNo(POSEntry1);
        _LibPOSDeferral.SetGLAccountBlocked(DeferralTemplate."Deferral Account", true);

        // [WHEN] The nightly job posts the register
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run stops on the blocked deferral account
        AssertBlockedAccountError(DeferralTemplate."Deferral Account");

        // [THEN] T1 and T2 stay Unposted, no G/L entry and no row exists under T1, T2 or P1, and T1's sales line has no posted schedule
        _LibPOSDeferral.FindSalesLine(POSEntry1, Item."No.", POSEntrySalesLine);
        Mismatches :=
            _LibPOSDeferral.GetStatusMismatch('E12 Per POS Period', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetStatusMismatch('E12 Per POS Period', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('E12 Per POS Period', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('E12 Per POS Period', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch('E12 Per POS Period', RegisterDocumentNo) +
            _LibPOSDeferral.GetNoRowsMismatch('E12 Per POS Period', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('E12 Per POS Period', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('E12 Per POS Period', RegisterDocumentNo);
        if PostedDeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR POS Entry Sales Line", Format(POSEntrySalesLine."POS Entry No."), POSEntrySalesLine."Line No.") then
            Mismatches += StrSubstNo(PostedScheduleLbl, POSEntrySalesLine."POS Entry No.", POSEntrySalesLine."Line No.", POSEntry1."Document No.");
        _Assert.AreEqual('', Mismatches, 'E12: under Per POS Period a run undone by a hard error leaves nothing of the run for the whole register');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenJournalSourceCodeOnProfile_WhenNightlyJobReposts_ThenRunStopsWithoutSchedule()
    var
        BlankC1: Record "Default Dimension";
        C1: Record "Default Dimension";
        BlankDeferralTemplate: Record "Deferral Template";
        DeferralTemplate: Record "Deferral Template";
        BlankItem: Record Item;
        Item: Record Item;
        BlankPOSEntry: Record "NPR POS Entry";
        POSEntry: Record "NPR POS Entry";
        POSPostingProfile: Record "NPR POS Posting Profile";
        GeneralJournalSourceCode: Code[10];
        NoScheduleErr: Label 'You must create a deferral schedule if a deferral template is selected.', Locked = true;
    begin
        // [SCENARIO] A repost under a posting profile whose source code is the General Journal source code, or with both blank, stops with the no-schedule error and is undone
        Initialize();

        // [GIVEN] A receipt of ITEM2651 whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry);
        _LibPOSDeferral.FailWithC1(POSEntry, C1);

        // [GIVEN] The posting profile source code equals the General Journal source code, and the failure cause is removed
        _LibPOSDeferral.SetProfileSourceCodeToGeneralJournal();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipt again
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run stops with the error that no deferral schedule exists
        _Assert.ExpectedError(NoScheduleErr);

        // [THEN] The receipt stays Unposted with no G/L entry on any date and no row of the run
        _Assert.AreEqual('', GetStoppedRepostMismatches('E13 equal codes', POSEntry), 'E13: the stopped repost leaves nothing of the run when the profile source code equals the General Journal source code');

        // [GIVEN] A second receipt of ITEM2651 under a new posting profile whose first nightly run failed the line check
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(BlankDeferralTemplate);
        _LibPOSDeferral.CreateItem2651(BlankItem);
        _LibPOSDeferral.CreateSaleOfItem(BlankItem."No.", BlankPOSEntry);
        _LibPOSDeferral.FailWithC1(BlankPOSEntry, BlankC1);

        // [GIVEN] The posting profile source code and the General Journal source code are both blank, and the failure cause is removed
        _LibPOSDeferral.SetProfileSourceCode('');
        GeneralJournalSourceCode := _LibPOSDeferral.SetGeneralJournalSourceCode('');
        _LibPOSDeferral.RemoveFailureCause(BlankC1);

        // [WHEN] The nightly job posts the second receipt again
        asserterror _LibPOSDeferral.RunNightlyJob();

        // [THEN] The run stops with the error that no deferral schedule exists
        _Assert.ExpectedError(NoScheduleErr);

        // [THEN] The second receipt stays Unposted with no G/L entry on any date and no row of the run
        _LibPOSDeferral.SetGeneralJournalSourceCode(GeneralJournalSourceCode);
        _Assert.AreEqual('', GetStoppedRepostMismatches('E13 both blank', BlankPOSEntry), 'E13: the stopped repost leaves nothing of the run when both source codes are blank');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenScheduleTemplateDeleted_WhenNightlyJobReposts_ThenSalesPostWithoutDeferral()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        OtherDeferralTemplate: Record "Deferral Template";
        GLAccount: Record "G/L Account";
        Item: Record Item;
        GLAccountPOSEntry: Record "NPR POS Entry";
        ItemPOSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] A repost after the template of the saved schedule was deleted posts the sale with no deferral and keeps the open schedule
        Initialize();

        // [GIVEN] A receipt of ITEM2651 and a receipt of GLDEF as a G/L Account line, whose first nightly run failed the line check
        SellItemAndGLAccountAndFailWithC1(DeferralTemplate, Item, GLAccount, ItemPOSEntry, GLAccountPOSEntry, C1);

        // [GIVEN] ITEM2651 and GLDEF move to template DEF6, DEF2651 is deleted, and the failure cause is removed
        _LibPOSDeferral.CreateDeferralTemplate('DEF6', 6, OtherDeferralTemplate);
        Item.Get(Item."No.");
        Item."Default Deferral Template Code" := OtherDeferralTemplate."Deferral Code";
        Item.Modify();
        GLAccount.Get(GLAccount."No.");
        GLAccount."Default Deferral Template Code" := OtherDeferralTemplate."Deferral Code";
        GLAccount.Modify();
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate.Delete();
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [WHEN] The nightly job posts the receipts again
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] Each sale posts 350.00 to revenue with no deferral entry on D or on the DEF6 account, and its open schedule stays
        _Assert.AreEqual('',
            GetNoDeferralRepostMismatches('E15 item', ItemPOSEntry, Item."No.", DeferralTemplate."Deferral Account", OtherDeferralTemplate."Deferral Account") +
            GetNoDeferralRepostMismatches('E15 G/L account', GLAccountPOSEntry, GLAccount."No.", DeferralTemplate."Deferral Account", OtherDeferralTemplate."Deferral Account"),
            'E15: a repost whose schedule template no longer exists posts no deferral and keeps the open schedule');
    end;

    [MessageHandler]
    procedure ErrorCountMessageHandler(Message: Text[1024])
    var
        ErrorCountLbl: Label '%1 POS entries failed to post.', Locked = true;
    begin
        _Assert.AreEqual(StrSubstNo(ErrorCountLbl, 1), Message, 'S3.d: the nightly job reports the one receipt that failed its balance check');
    end;

    local procedure Initialize()
    begin
        if _IsInitialized then
            exit;
        _LibPOSDeferral.EnsureGlobalSetup();
        _IsInitialized := true;
        Commit();
    end;

    local procedure SellItemAndGLAccountAndFailWithC1(var DeferralTemplate: Record "Deferral Template"; var Item: Record Item; var GLAccount: Record "G/L Account"; var ItemPOSEntry: Record "NPR POS Entry"; var GLAccountPOSEntry: Record "NPR POS Entry"; var C1: Record "Default Dimension")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateGLDEF(GLAccount, Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", ItemPOSEntry);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", GLAccountPOSEntry);
        _LibPOSDeferral.ConvertSalesLineToGLAccount(GLAccountPOSEntry, GLAccount."No.");
        _LibPOSDeferral.FailWithC1(ItemPOSEntry, C1);
        _LibPOSDeferral.AssertUnpostedAfterFailedRun(GLAccountPOSEntry);
    end;

    local procedure AssertBlockedAccountError(GLAccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        _Assert.ExpectedTestFieldError(GLAccount.FieldCaption(Blocked), Format(false));
        _Assert.ExpectedError(GLAccountNo);
    end;

    local procedure GetNoDeferralRepostMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"; SalesLineNo: Code[20]; DeferralAccountNo: Code[20]; OtherDeferralAccountNo: Code[20]) Mismatches: Text
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Amounts: List of [Decimal];
        Dates: List of [Date];
        NoAmounts: List of [Decimal];
        NoDates: List of [Date];
    begin
        _LibPOSDeferral.FindSalesLine(POSEntry, SalesLineNo, POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        Mismatches :=
            _LibPOSDeferral.GetStatusMismatch(RowId, POSEntry."Entry No.", POSEntry."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetDeferralGLEntryMismatches(RowId, POSEntry."Document No.", _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine), DeferralAccountNo, _LibPOSDeferral.SalePostingDate(), 0, 350, NoDates, NoAmounts) +
            _LibPOSDeferral.GetOpenScheduleMismatches(RowId, POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts);
        if OtherDeferralAccountNo <> '' then
            Mismatches += _LibPOSDeferral.GetNoAccountEntriesMismatch(RowId, POSEntry."Document No.", OtherDeferralAccountNo);
    end;

    local procedure GetUndoneFirstAttemptMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"; ItemNo: Code[20]): Text
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        _LibPOSDeferral.FindSalesLine(POSEntry, ItemNo, POSEntrySalesLine);
        exit(
            GetStoppedRepostMismatches(RowId, POSEntry) +
            _LibPOSDeferral.GetOpenScheduleGoneMismatch(RowId, POSEntrySalesLine));
    end;

    local procedure GetStoppedRepostMismatches(RowId: Text; POSEntry: Record "NPR POS Entry"): Text
    begin
        exit(
            _LibPOSDeferral.GetStatusMismatch(RowId, POSEntry."Entry No.", POSEntry."Post Entry Status"::Unposted) +
            _LibPOSDeferral.GetNoGLEntriesAnyDateMismatch(RowId, POSEntry."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch(RowId, POSEntry."Document No."));
    end;

    local procedure GetJournalEventMismatches(RowId: Text; var JnlRecorder: Codeunit "NPR POS Deferral Jnl. Recorder"; RevenueAccountNo: Code[20]; PaymentAccountNo: Code[20]) Mismatches: Text
    var
        GenJournalLine: Record "Gen. Journal Line";
        NextGenJournalLine: Record "Gen. Journal Line";
        CheckAccounts: List of [Code[20]];
        InsertAccounts: List of [Code[20]];
        EventName: Text;
        NextEventName: Text;
        i: Integer;
        CheckEventTok: Label 'OnBeforeCheckAndPostGenJournal', Locked = true;
        InsertWithBinEventTok: Label 'OnAfterInsertFromPOSPostingBufferToGenJournal', Locked = true;
        CountLbl: Label '%1: journal event records expected %2, actual %3 [%4]; ', Locked = true;
        PairLbl: Label '%1: record %2 expected %3 then %4 for the same journal line, actual %5 then %6 [%7]; ', Locked = true;
        CheckLbl: Label '%1: record %2 expected %3, actual %4 [%5]; ', Locked = true;
        AccountsLbl: Label '%1: %2 expected the journal lines of accounts %3 and %4 once each [%5]; ', Locked = true;
    begin
        if JnlRecorder.GetRecordCount() <> 6 then
            exit(StrSubstNo(CountLbl, RowId, 6, JnlRecorder.GetRecordCount(), JnlRecorder.GetSequence()));
        for i := 1 to 4 do
            if i mod 2 = 1 then begin
                JnlRecorder.GetRecord(i, EventName, GenJournalLine);
                JnlRecorder.GetRecord(i + 1, NextEventName, NextGenJournalLine);
                if (EventName <> JnlRecorder.BufferLineEventName()) or (NextEventName <> InsertWithBinEventTok) or (GenJournalLine."Account No." <> NextGenJournalLine."Account No.") then
                    Mismatches += StrSubstNo(PairLbl, RowId, i, JnlRecorder.BufferLineEventName(), InsertWithBinEventTok, EventName, NextEventName, JnlRecorder.GetSequence());
                InsertAccounts.Add(GenJournalLine."Account No.");
            end;
        for i := 5 to 6 do begin
            JnlRecorder.GetRecord(i, EventName, GenJournalLine);
            if EventName <> CheckEventTok then
                Mismatches += StrSubstNo(CheckLbl, RowId, i, CheckEventTok, EventName, JnlRecorder.GetSequence());
            CheckAccounts.Add(GenJournalLine."Account No.");
        end;
        if not (InsertAccounts.Contains(RevenueAccountNo) and InsertAccounts.Contains(PaymentAccountNo)) then
            Mismatches += StrSubstNo(AccountsLbl, RowId, JnlRecorder.BufferLineEventName(), RevenueAccountNo, PaymentAccountNo, JnlRecorder.GetSequence());
        if not (CheckAccounts.Contains(RevenueAccountNo) and CheckAccounts.Contains(PaymentAccountNo)) then
            Mismatches += StrSubstNo(AccountsLbl, RowId, CheckEventTok, RevenueAccountNo, PaymentAccountNo, JnlRecorder.GetSequence());
    end;

    local procedure InsertMembershipEntryForSalesLine(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; ValidFromDate: Date)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.Init();
        MembershipEntry."Entry No." := 0;
        MembershipEntry."Receipt No." := POSEntrySalesLine."Document No.";
        MembershipEntry."Line No." := POSEntrySalesLine."Line No.";
        MembershipEntry."Valid From Date" := ValidFromDate;
        MembershipEntry.Insert();
    end;

    local procedure InsertMembershipEntryLinkForSalesLine(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; StartingDate: Date; EndingDate: Date)
    var
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
    begin
        MembershipEntryLink.Init();
        MembershipEntryLink."Entry No." := 0;
        MembershipEntryLink.Context := MembershipEntryLink.Context::NEW;
        MembershipEntryLink."Document Type" := Database::"NPR POS Entry Sales Line";
        MembershipEntryLink."Document No." := POSEntrySalesLine."Document No.";
        MembershipEntryLink."Document Line No." := POSEntrySalesLine."Line No.";
        MembershipEntryLink."Context Period Starting Date" := StartingDate;
        MembershipEntryLink."Context Period Ending Date" := EndingDate;
        MembershipEntryLink.Insert();
    end;
}
