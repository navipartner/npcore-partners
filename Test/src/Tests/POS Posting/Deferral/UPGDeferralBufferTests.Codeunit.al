// [FEATURE] [POS Posting] [Upgrade] [Deferral]
codeunit 85612 "NPR UPG Deferral Buffer Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        _Assert: Codeunit Assert;
        _LibPOSDeferral: Codeunit "NPR Library POS Deferral";
        _IsInitialized: Boolean;
        _SubscriberMode: Option Off,Observe,Fail;
        _ObservedSalesRows: List of [Integer];
        _ObservedTagSet: List of [Boolean];
        _FailedSends: Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLeftoverRowsOfReceiptsAndOtherDocuments_WhenUpgradeRemovesSalesRows_ThenNoSalesRowRemainsAndPurchaseRowIsUnchanged()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntry3: Record "NPR POS Entry";
        LibraryUtility: Codeunit "Library - Utility";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        DeletedReceiptNo: Code[20];
        InvoiceNo: Code[20];
        RevenueAccountNo: Code[20];
        GLRowsBefore: Text;
        Mismatches: Text;
        PurchaseRowsBefore: Text;
        NoPurchaseRowLbl: Label 'The Purchase row numbered %1 must exist before the upgrade', Locked = true;
        NoGLRowLbl: Label 'The G/L row numbered %1 must exist before the upgrade', Locked = true;
        PurchaseRowLbl: Label 'S8.b: the Purchase row of %1 expected [%2], actual [%3]; ', Locked = true;
        GLRowLbl: Label 'S8.b: the G/L row of %1 expected [%2], actual [%3]; ', Locked = true;
    begin
        // [SCENARIO] The upgrade removes every Sales row of table 1706, of posted and unposted receipts, of another document and of a receipt whose POS entry is gone, and leaves Purchase and G/L rows unchanged
        Initialize();

        // [GIVEN] 13 old rows each of posted receipt T1, with absorbed invoice amounts, and of unposted receipts T2 and T3
        CreateReceiptsWithOldRows(DeferralTemplate, Item, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);

        // [GIVEN] A Sales row of document I9, a Purchase row and a G/L row numbered like T1, and 13 rows of receipt T9 whose POS entry no longer exists
        InvoiceNo := LibraryUtility.GenerateGUID();
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, InvoiceNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -100, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -123.45, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -67.89, false);
        DeletedReceiptNo := LibraryUtility.GenerateGUID();
        _LibPOSDeferral.InsertOldRowsOfFailedRun(DeletedReceiptNo, 1, RevenueAccountNo, DeferralTemplate."Deferral Account", 1, 0);
        PurchaseRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.");
        GLRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.");
        _Assert.AreNotEqual('', PurchaseRowsBefore, StrSubstNo(NoPurchaseRowLbl, POSEntry1."Document No."));
        _Assert.AreNotEqual('', GLRowsBefore, StrSubstNo(NoGLRowLbl, POSEntry1."Document No."));

        // [WHEN] The upgrade removes the leftover Sales rows
        UPGPOSEntryPosting.DeleteSalesDeferralPostingBufferRows();

        // [THEN] No Sales row of T1, T2, T3, I9 or T9 remains, and the Purchase and G/L rows numbered like T1 are unchanged
        Mismatches :=
            _LibPOSDeferral.GetNoRowsMismatch('S8.a', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S8.a', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S8.a', POSEntry3."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S8.b', InvoiceNo) +
            _LibPOSDeferral.GetNoRowsMismatch('S8.f', DeletedReceiptNo);
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.") <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, POSEntry1."Document No.", PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No."));
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.") <> GLRowsBefore then
            Mismatches += StrSubstNo(GLRowLbl, POSEntry1."Document No.", GLRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No."));
        _Assert.AreEqual('', Mismatches, 'S8.a, S8.b, S8.f: the upgrade removes every Sales row and keeps the Purchase and G/L rows');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUpgradeRemovedOldRows_WhenNightlyJobPostsUnpostedReceipt_ThenReceiptPostsItsOwnDeferral()
    var
        C1: Record "Default Dimension";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntry3: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        RevenueAccountNo: Code[20];
        Amounts: List of [Decimal];
        Dates: List of [Date];
        Mismatches: Text;
    begin
        // [SCENARIO] An unposted receipt whose old rows the upgrade removed keeps the open schedule of its failed run through the upgrade and posts its own deferral G1 from it under its own number
        Initialize();

        // [GIVEN] Posted receipt T1 and receipts T2 and T3, whose nightly run failed the line check and saved the schedule of T2's sales line, then the failure cause is removed
        CreateReceipts(DeferralTemplate, Item, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);
        _LibPOSDeferral.FailWithC1(POSEntry2, C1);
        _LibPOSDeferral.RemoveFailureCause(C1);

        // [GIVEN] 13 old rows each of T1, T2 and T3
        InsertOldRowsOfReceipts(DeferralTemplate, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);

        // [GIVEN] The upgrade removes the leftover Sales rows and keeps T2's open schedule with DEF2651 and the 12 months of G1
        RemoveUpgradeTag(GetRemoveLeftoverRowsTag());
        SentryCapture.Start();
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        SentryCapture.Stop();
        _LibPOSDeferral.FindSalesLine(POSEntry2, Item."No.", POSEntrySalesLine);
        _LibPOSDeferral.GetG1Schedule(1, Dates, Amounts);
        Mismatches := _LibPOSDeferral.GetOpenScheduleMismatches('S8.d after the upgrade', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts);

        // [GIVEN] DEF2651 changes from 12 to 6 periods
        DeferralTemplate.Get(_LibPOSDeferral.DEF2651Code());
        DeferralTemplate."No. of Periods" := 6;
        DeferralTemplate.Modify();

        // [WHEN] The nightly job posts T2
        _LibPOSDeferral.RunNightlyJob();

        // [THEN] T2's open schedule survived the upgrade, T2 posts G1 under T2 with its 12-month posted schedule, and no row of T2 remains
        _Assert.AreEqual('', Mismatches +
            _LibPOSDeferral.GetStatusMismatch('S8.d', POSEntry2."Entry No.", POSEntry2."Post Entry Status"::Posted) +
            _LibPOSDeferral.GetG1Mismatches('S8.d', POSEntry2."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetG1EntryMismatches('S8.d', POSEntry2."Document No.", RevenueAccountNo, DeferralTemplate."Deferral Account", 1) +
            _LibPOSDeferral.GetPostedScheduleMismatches('S8.d', POSEntrySalesLine, _LibPOSDeferral.DEF2651Code(), Dates, Amounts) +
            _LibPOSDeferral.GetNoRowsMismatch('S8.d', POSEntry2."Document No."),
            'S8.d: after the upgrade an unposted receipt posts its own deferral');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUpgradeRemovedOldRows_WhenUpgradeRunsSecondTime_ThenNothingChanges()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntry3: Record "NPR POS Entry";
        LibraryUtility: Codeunit "Library - Utility";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        UpgradeTag: Codeunit "Upgrade Tag";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        RevenueAccountNo: Code[20];
        SentinelNo: Code[20];
        RemoveLeftoverRowsTag: Code[250];
        Mismatches: Text;
        PurchaseRowsBefore: Text;
        SentinelRowsBefore: Text;
        StepPayloadsLbl: Label 'S8.e: payloads of the second run expected 0, actual %1; ', Locked = true;
        NoSentinelRowLbl: Label 'S8.e: the Sales sentinel row numbered %1 must exist before the second run', Locked = true;
        TagLbl: Label 'S8.e: the upgrade tag %1 expected set after the first run, actual not set; ', Locked = true;
        PurchaseRowLbl: Label 'S8.e %1: the Purchase row of %2 expected [%3], actual [%4]; ', Locked = true;
        SentinelRowLbl: Label 'S8.e: the Sales sentinel row of %1 after the second run expected [%2], actual [%3]; ', Locked = true;
    begin
        // [SCENARIO] A second run of the tag-guarded upgrade step changes nothing: a Sales row written after the first run stays and the Purchase row stays unchanged
        Initialize();

        // [GIVEN] 13 old rows each of posted receipt T1 and unposted receipts T2 and T3, a Purchase row numbered like T1, and no upgrade tag of the step for the current company
        CreateReceiptsWithOldRows(DeferralTemplate, Item, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -123.45, false);
        PurchaseRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.");
        RemoveLeftoverRowsTag := GetRemoveLeftoverRowsTag();
        RemoveUpgradeTag(RemoveLeftoverRowsTag);

        // [GIVEN] The upgrade step ran once under capture, removed the Sales rows of T1, T2 and T3, kept the Purchase row and set its tag
        SentryCapture.Start();
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        SentryCapture.Stop();
        Mismatches :=
            _LibPOSDeferral.GetNoRowsMismatch('S8.e first run', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S8.e first run', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('S8.e first run', POSEntry3."Document No.");
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.") <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, 'first run', POSEntry1."Document No.", PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No."));
        if not UpgradeTag.HasUpgradeTag(RemoveLeftoverRowsTag) then
            Mismatches += StrSubstNo(TagLbl, RemoveLeftoverRowsTag);

        // [GIVEN] A Sales sentinel row of a new document is written after the first run
        SentinelNo := LibraryUtility.GenerateGUID();
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, SentinelNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -100, false);
        SentinelRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, SentinelNo);
        _Assert.AreNotEqual('', SentinelRowsBefore, StrSubstNo(NoSentinelRowLbl, SentinelNo));

        // [GIVEN] Sentry payloads are captured
        SentryCapture.Start();

        // [WHEN] The upgrade step runs a second time
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        SentryCapture.Stop();

        // [THEN] The first run removed the Sales rows, kept the Purchase row and set the tag, and the second run sends no event and keeps the sentinel row and the Purchase row unchanged
        if CountStepPayloads(SentryCapture, 'S8.e') <> 0 then
            Mismatches += StrSubstNo(StepPayloadsLbl, CountStepPayloads(SentryCapture, 'S8.e'));
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, SentinelNo) <> SentinelRowsBefore then
            Mismatches += StrSubstNo(SentinelRowLbl, SentinelNo, SentinelRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, SentinelNo));
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.") <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, 'second run', POSEntry1."Document No.", PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No."));
        _Assert.AreEqual('', Mismatches, 'S8.e: the guarded upgrade step runs once and a second run changes nothing');
    end;

    #region Modified row classification

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCreatedAndModifiedTimes_WhenUpgradeClassifiesRow_ThenOnlyALaterModifiedTimeOfACreatedRowIsModified()
    var
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        CreatedAt: DateTime;
    begin
        // [SCENARIO] A row is modified only when it has a created time and its modified time is later, with no threshold
        // [GIVEN] A row created at 2026-10-13 23:00:00.000
        CreatedAt := GetCreatedAt();

        // [WHEN] The upgrade classifies the row with different modified times
        // [THEN] The same time and an earlier time are not modified, one millisecond later is modified
        _Assert.AreEqual(false, UPGPOSEntryPosting.IsModifiedAfterCreation(CreatedAt, CreatedAt), GetClassificationMessage('F1.1', CreatedAt, CreatedAt, false));
        _Assert.AreEqual(true, UPGPOSEntryPosting.IsModifiedAfterCreation(CreatedAt, CreatedAt + 1), GetClassificationMessage('F1.2', CreatedAt, CreatedAt + 1, true));
        _Assert.AreEqual(false, UPGPOSEntryPosting.IsModifiedAfterCreation(CreatedAt, CreatedAt - 1), GetClassificationMessage('F1.3', CreatedAt, CreatedAt - 1, false));

        // [THEN] A row with no created time is not modified, whatever its modified time
        _Assert.AreEqual(false, UPGPOSEntryPosting.IsModifiedAfterCreation(0DT, CreatedAt), GetClassificationMessage('F1.4', 0DT, CreatedAt, false));
    end;

    #endregion

    #region Sentry evidence before the delete

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLeftoverSalesRowsOfThreeReceipts_WhenUpgradeRemovesThem_ThenTransactionAndOneErrorPartAreSentBeforeDelete()
    var
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        POSEntry1: Record "NPR POS Entry";
        POSEntry2: Record "NPR POS Entry";
        POSEntry3: Record "NPR POS Entry";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Sentry: Codeunit "NPR Sentry";
        Subscriber: Codeunit "NPR UPG Deferral Buffer Tests";
        UpgradeTag: Codeunit "Upgrade Tag";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        RevenueAccountNo: Code[20];
        StepTransactions: JsonArray;
        ErrorTraceIds: List of [Text];
        ErrorValues: List of [Text];
        ExpectedLines: List of [Text];
        GLRowsBefore: Text;
        Mismatches: Text;
        PurchaseRowsBefore: Text;
        ModifiedRows: Integer;
        SalesRows: Integer;
        i: Integer;
        FixtureLbl: Label 'F2.1: the fixture holds 39 Sales rows of 3 documents in table 1706 before the upgrade, actual %1 rows of %2 documents', Locked = true;
        RowsOfDocumentTok: Label '%1,13,', Locked = true;
        ObservationCountLbl: Label 'F2.1: sends of the step observed expected 2 (the transaction and one error), actual %1; ', Locked = true;
        ObservedRowsLbl: Label 'F2.1: Sales rows of table 1706 at send %1 expected 39, actual %2; ', Locked = true;
        ObservedTagLbl: Label 'F2.1: the upgrade tag at send %1 expected absent, actual set; ', Locked = true;
        PurchaseRowLbl: Label 'F2.1: the Purchase row of %1 expected [%2], actual [%3]; ', Locked = true;
        GLRowLbl: Label 'F2.1: the G/L row of %1 expected [%2], actual [%3]; ', Locked = true;
        TagNotSetLbl: Label 'F2.1: the upgrade tag %1 expected set after the step, actual not set; ', Locked = true;
    begin
        // [SCENARIO] Before the upgrade deletes the Sales rows of table 1706 it sends one transaction with the row counts and one error, part 1 of 1, with one line per document, while every row still exists
        Initialize();

        // [GIVEN] Table 1706 holds no Sales row and the upgrade tag of the step is absent
        PrepareStepRun();

        // [GIVEN] 13 old rows each of receipts T1, T2 and T3, and a Purchase row and a G/L row numbered like T1
        CreateReceiptsWithOldRows(DeferralTemplate, Item, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -123.45, false);
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.", 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountNo, DeferralTemplate."Deferral Account", -67.89, false);
        PurchaseRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.");
        GLRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.");

        // [GIVEN] The expected header numbers and document lines, read from the timestamps of the fixture's Sales rows by the key of the step
        GetExpectedDocumentLines(ExpectedLines, SalesRows, ModifiedRows);
        _Assert.IsTrue((SalesRows = 39) and (ExpectedLines.Count() = 3), StrSubstNo(FixtureLbl, SalesRows, ExpectedLines.Count()));

        // [GIVEN] Sentry payloads are captured and every send of the step is observed
        SentryCapture.Start();
        BindSubscription(Subscriber);
        Subscriber.ResetRecorded();
        Subscriber.SetObserveMode();

        // [WHEN] The upgrade step removes the leftover Sales rows
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        Subscriber.SetOffMode();
        UnbindSubscription(Subscriber);
        SentryCapture.Stop();

        // [THEN] The step sent one transaction with the tags deferral.sales_rows and deferral.modified_rows, and one error, part 1 of 1, whose header and every document line match the fixture, T1, T2 and T3 with 13 rows each
        GetStepPayloads(SentryCapture, 'F2.1', StepTransactions, ErrorValues, ErrorTraceIds);
        Mismatches := GetStepTransactionMismatches('F2.1', StepTransactions, SalesRows, ModifiedRows);
        Mismatches += GetStepErrorMismatches('F2.1', ErrorValues, ExpectedLines, SalesRows, ModifiedRows, 1);
        Mismatches += GetDocumentLineMismatch('F2.1', ErrorValues, StrSubstNo(RowsOfDocumentTok, POSEntry1."Document No."));
        Mismatches += GetDocumentLineMismatch('F2.1', ErrorValues, StrSubstNo(RowsOfDocumentTok, POSEntry2."Document No."));
        Mismatches += GetDocumentLineMismatch('F2.1', ErrorValues, StrSubstNo(RowsOfDocumentTok, POSEntry3."Document No."));

        // [THEN] At each send all 39 Sales rows still existed and the upgrade tag was absent
        if Subscriber.ObservationCount() <> 2 then
            Mismatches += StrSubstNo(ObservationCountLbl, Subscriber.ObservationCount());
        for i := 1 to Subscriber.ObservationCount() do begin
            if Subscriber.GetObservedSalesRows(i) <> 39 then
                Mismatches += StrSubstNo(ObservedRowsLbl, i, Subscriber.GetObservedSalesRows(i));
            if Subscriber.GetObservedTagSet(i) then
                Mismatches += StrSubstNo(ObservedTagLbl, i);
        end;

        // [THEN] After the step no Sales row of T1, T2 or T3 remains, the Purchase and G/L rows are unchanged and the upgrade tag is set
        Mismatches +=
            _LibPOSDeferral.GetNoRowsMismatch('F2.1', POSEntry1."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('F2.1', POSEntry2."Document No.") +
            _LibPOSDeferral.GetNoRowsMismatch('F2.1', POSEntry3."Document No.");
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No.") <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, POSEntry1."Document No.", PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, POSEntry1."Document No."));
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No.") <> GLRowsBefore then
            Mismatches += StrSubstNo(GLRowLbl, POSEntry1."Document No.", GLRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::"G/L", POSEntry1."Document No."));
        if not UpgradeTag.HasUpgradeTag(GetRemoveLeftoverRowsTag()) then
            Mismatches += StrSubstNo(TagNotSetLbl, GetRemoveLeftoverRowsTag());
        _Assert.AreEqual('', Mismatches, 'F2.1: the step sends the row counts and one line per document before it deletes the Sales rows');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Given51Documents_WhenUpgradeRemovesTheirRows_ThenTwoErrorPartsListFiftyAndOneDocumentsInKeyOrder()
    var
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        StepTransactions: JsonArray;
        ErrorTraceIds: List of [Text];
        ErrorValues: List of [Text];
        ExpectedLines: List of [Text];
        Mismatches: Text;
        ModifiedRows: Integer;
        SalesRows: Integer;
        i: Integer;
        FixtureLbl: Label 'F2.2: the fixture holds 102 Sales rows of 51 documents in table 1706 before the upgrade, actual %1 rows of %2 documents', Locked = true;
    begin
        // [SCENARIO] The step splits 51 documents into error part 1 of 2 with 50 document lines and part 2 of 2 with 1 line, in document number order, not in the order the rows were written
        Initialize();

        // [GIVEN] Table 1706 holds no Sales row and the upgrade tag of the step is absent
        PrepareStepRun();

        // [GIVEN] Two Sales rows each of 51 documents, written from D-51 down to D-01, so parts are counted by documents, not by rows
        for i := 51 downto 1 do begin
            InsertSalesRow(GetIndexedDocumentNo(i), 1);
            InsertSalesRow(GetIndexedDocumentNo(i), 2);
        end;

        // [GIVEN] The expected header numbers and document lines, read from the timestamps of the fixture's Sales rows by the key of the step
        GetExpectedDocumentLines(ExpectedLines, SalesRows, ModifiedRows);
        _Assert.IsTrue((SalesRows = 102) and (ExpectedLines.Count() = 51), StrSubstNo(FixtureLbl, SalesRows, ExpectedLines.Count()));

        // [GIVEN] Sentry payloads are captured
        SentryCapture.Start();

        // [WHEN] The upgrade step removes the leftover Sales rows
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        SentryCapture.Stop();

        // [THEN] One transaction and two errors: part 1 of 2 lists D-01 to D-50 and part 2 of 2 lists D-51, each line equal to the fixture's values
        GetStepPayloads(SentryCapture, 'F2.2', StepTransactions, ErrorValues, ErrorTraceIds);
        Mismatches := GetStepTransactionMismatches('F2.2', StepTransactions, SalesRows, ModifiedRows);
        Mismatches += GetStepErrorMismatches('F2.2', ErrorValues, ExpectedLines, SalesRows, ModifiedRows, 2);
        Mismatches += GetPartLinesMismatch('F2.2', ErrorValues, 1, 50, GetIndexedDocumentNo(1) + ',', GetIndexedDocumentNo(50) + ',');
        Mismatches += GetPartLinesMismatch('F2.2', ErrorValues, 2, 1, GetIndexedDocumentNo(51) + ',', GetIndexedDocumentNo(51) + ',');
        _Assert.AreEqual('', Mismatches, 'F2.2: 51 documents are sent in two error parts in document number order');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenNoSalesRowAndOnePurchaseRow_WhenUpgradeRuns_ThenNoEventIsSentAndTagIsSet()
    var
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Subscriber: Codeunit "NPR UPG Deferral Buffer Tests";
        UpgradeTag: Codeunit "Upgrade Tag";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        PurchaseNo: Code[20];
        Mismatches: Text;
        PurchaseRowsBefore: Text;
        StepPayloadsLbl: Label 'F2.6: payloads of the step expected 0, actual %1, sends observed %2; ', Locked = true;
        PurchaseRowLbl: Label 'F2.6: the Purchase row of %1 expected [%2], actual [%3]; ', Locked = true;
        TagNotSetLbl: Label 'F2.6: the upgrade tag %1 expected set after the step, actual not set; ', Locked = true;
    begin
        // [SCENARIO] With no Sales row in table 1706 the step sends no event, sets its tag and leaves the Purchase row unchanged
        Initialize();

        // [GIVEN] Table 1706 holds no Sales row and the upgrade tag of the step is absent
        PrepareStepRun();

        // [GIVEN] One Purchase row
        PurchaseNo := InsertPurchaseRow();
        PurchaseRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo);

        // [GIVEN] Sentry payloads are captured and every send of the step is observed
        SentryCapture.Start();
        BindSubscription(Subscriber);
        Subscriber.ResetRecorded();
        Subscriber.SetObserveMode();

        // [WHEN] The upgrade step runs
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        Subscriber.SetOffMode();
        UnbindSubscription(Subscriber);
        SentryCapture.Stop();

        // [THEN] No payload of the step, the upgrade tag is set and the Purchase row is unchanged
        if (CountStepPayloads(SentryCapture, 'F2.6') <> 0) or (Subscriber.ObservationCount() <> 0) then
            Mismatches += StrSubstNo(StepPayloadsLbl, CountStepPayloads(SentryCapture, 'F2.6'), Subscriber.ObservationCount());
        if not UpgradeTag.HasUpgradeTag(GetRemoveLeftoverRowsTag()) then
            Mismatches += StrSubstNo(TagNotSetLbl, GetRemoveLeftoverRowsTag());
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo) <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, PurchaseNo, PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo));
        _Assert.AreEqual('', Mismatches, 'F2.6: no Sales row means no event, and the step still sets its tag');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSentrySendFails_WhenUpgradeRemovesSalesRows_ThenRowsAreDeletedAndTagIsSet()
    var
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Subscriber: Codeunit "NPR UPG Deferral Buffer Tests";
        UpgradeTag: Codeunit "Upgrade Tag";
        UPGPOSEntryPosting: Codeunit "NPR UPG POS Entry Posting";
        PurchaseNo: Code[20];
        Mismatches: Text;
        PurchaseRowsBefore: Text;
        SalesNoTok: Label 'F-2651', Locked = true;
        NoSalesRowLbl: Label 'F2.9: the Sales rows of %1 must exist before the step', Locked = true;
        FailedSendsLbl: Label 'F2.9: failed sends of the step expected at least 1, actual %1; ', Locked = true;
        SalesRowsLbl: Label 'F2.9: Sales rows of table 1706 after the step expected 0, actual %1; ', Locked = true;
        PurchaseRowLbl: Label 'F2.9: the Purchase row of %1 expected [%2], actual [%3]; ', Locked = true;
        TagNotSetLbl: Label 'F2.9: the upgrade tag %1 expected set after the step, actual not set; ', Locked = true;
    begin
        // [SCENARIO] When sending the Sentry event fails the step still returns without an error, deletes every Sales row and sets its tag
        Initialize();

        // [GIVEN] Table 1706 holds no Sales row and the upgrade tag of the step is absent
        PrepareStepRun();

        // [GIVEN] Two Sales rows of document F-2651 and one Purchase row
        InsertSalesRow(SalesNoTok, 1);
        InsertSalesRow(SalesNoTok, 2);
        PurchaseNo := InsertPurchaseRow();
        PurchaseRowsBefore := _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo);
        _Assert.AreNotEqual('', _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Sales, SalesNoTok), StrSubstNo(NoSalesRowLbl, SalesNoTok));

        // [GIVEN] A scope left by earlier code is flushed into the capture, and every send of the step fails with an error
        SentryCapture.Start();
        SentryCapture.Stop();
        BindSubscription(Subscriber);
        Subscriber.ResetRecorded();
        Subscriber.SetFailMode();

        // [WHEN] The upgrade step removes the leftover Sales rows
        UPGPOSEntryPosting.RemoveLeftoverSalesDeferralRows();
        Subscriber.SetOffMode();
        UnbindSubscription(Subscriber);

        // The failed send leaves the scope queued; flush it into the capture so no later code sends it
        SentryCapture.Start();
        SentryCapture.Stop();

        // [THEN] The step tried to send at least once, no Sales row remains, the Purchase row is unchanged and the upgrade tag is set
        if Subscriber.FailedSendCount() < 1 then
            Mismatches += StrSubstNo(FailedSendsLbl, Subscriber.FailedSendCount());
        if CountAllSalesRows() <> 0 then
            Mismatches += StrSubstNo(SalesRowsLbl, CountAllSalesRows());
        if _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo) <> PurchaseRowsBefore then
            Mismatches += StrSubstNo(PurchaseRowLbl, PurchaseNo, PurchaseRowsBefore, _LibPOSDeferral.GetRowsSnapshot(Enum::"Deferral Document Type"::Purchase, PurchaseNo));
        if not UpgradeTag.HasUpgradeTag(GetRemoveLeftoverRowsTag()) then
            Mismatches += StrSubstNo(TagNotSetLbl, GetRemoveLeftoverRowsTag());
        _Assert.AreEqual('', Mismatches, 'F2.9: a failed Sentry send does not stop the delete or the tag');
    end;

    #endregion

    local procedure Initialize()
    begin
        if _IsInitialized then
            exit;
        _LibPOSDeferral.EnsureGlobalSetup();
        _IsInitialized := true;
        Commit();
    end;

    local procedure CreateReceiptsWithOldRows(var DeferralTemplate: Record "Deferral Template"; var Item: Record Item; var POSEntry1: Record "NPR POS Entry"; var POSEntry2: Record "NPR POS Entry"; var POSEntry3: Record "NPR POS Entry"; var RevenueAccountNo: Code[20])
    begin
        CreateReceipts(DeferralTemplate, Item, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);
        InsertOldRowsOfReceipts(DeferralTemplate, POSEntry1, POSEntry2, POSEntry3, RevenueAccountNo);
    end;

    local procedure CreateReceipts(var DeferralTemplate: Record "Deferral Template"; var Item: Record Item; var POSEntry1: Record "NPR POS Entry"; var POSEntry2: Record "NPR POS Entry"; var POSEntry3: Record "NPR POS Entry"; var RevenueAccountNo: Code[20])
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        _LibPOSDeferral.CreatePOSFixture(POSPostingProfile."Posting Compression"::"Per POS Entry");
        _LibPOSDeferral.CreateDEF2651(DeferralTemplate);
        _LibPOSDeferral.CreateItem2651(Item);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry1);
        _LibPOSDeferral.RunNightlyJob();
        _Assert.AreEqual('', _LibPOSDeferral.GetStatusMismatch('fixture', POSEntry1."Entry No.", POSEntry1."Post Entry Status"::Posted), 'The fixture receipt T1 is posted');
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry2);
        _LibPOSDeferral.CreateSaleOfItem(Item."No.", POSEntry3);
        _LibPOSDeferral.FindSalesLine(POSEntry1, Item."No.", POSEntrySalesLine);
        RevenueAccountNo := _LibPOSDeferral.GetSalesAccount(POSEntrySalesLine);
    end;

    local procedure InsertOldRowsOfReceipts(DeferralTemplate: Record "Deferral Template"; POSEntry1: Record "NPR POS Entry"; POSEntry2: Record "NPR POS Entry"; POSEntry3: Record "NPR POS Entry"; RevenueAccountNo: Code[20])
    var
        RowCountLbl: Label 'The fixture writes 13 old rows of receipt %1, actual %2', Locked = true;
    begin
        _LibPOSDeferral.InsertOldRowsOfFailedRun(POSEntry1."Document No.", 1, RevenueAccountNo, DeferralTemplate."Deferral Account", 1, 10);
        _LibPOSDeferral.InsertOldRowsOfFailedRun(POSEntry2."Document No.", 1, RevenueAccountNo, DeferralTemplate."Deferral Account", 1, 0);
        _LibPOSDeferral.InsertOldRowsOfFailedRun(POSEntry3."Document No.", 1, RevenueAccountNo, DeferralTemplate."Deferral Account", 1, 0);
        _Assert.AreEqual(13, _LibPOSDeferral.CountDeferralBufferRows(POSEntry1."Document No."), StrSubstNo(RowCountLbl, POSEntry1."Document No.", _LibPOSDeferral.CountDeferralBufferRows(POSEntry1."Document No.")));
        _Assert.AreEqual(13, _LibPOSDeferral.CountDeferralBufferRows(POSEntry2."Document No."), StrSubstNo(RowCountLbl, POSEntry2."Document No.", _LibPOSDeferral.CountDeferralBufferRows(POSEntry2."Document No.")));
        _Assert.AreEqual(13, _LibPOSDeferral.CountDeferralBufferRows(POSEntry3."Document No."), StrSubstNo(RowCountLbl, POSEntry3."Document No.", _LibPOSDeferral.CountDeferralBufferRows(POSEntry3."Document No.")));
    end;

    local procedure RemoveUpgradeTag(Tag: Code[250])
    var
        UpgradeTags: RecordRef;
    begin
        // Table 9999 "Upgrade Tags" is internal to the System Application: field 1 is Tag, field 3 is Company
        UpgradeTags.Open(9999);
        UpgradeTags.Field(1).SetRange(Tag);
        UpgradeTags.Field(3).SetRange(CompanyName());
        if not UpgradeTags.IsEmpty() then
            UpgradeTags.DeleteAll();
        UpgradeTags.Close();
    end;

    local procedure GetRemoveLeftoverRowsTag(): Code[250]
    var
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        RemoveLeftoverRowsStepTok: Label 'RemoveLeftoverSalesDeferralRows', Locked = true;
    begin
        exit(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR UPG POS Entry Posting", RemoveLeftoverRowsStepTok));
    end;

    local procedure PrepareStepRun()
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        if not DeferralPostingBuffer.IsEmpty() then
            DeferralPostingBuffer.DeleteAll();
        RemoveUpgradeTag(GetRemoveLeftoverRowsTag());
    end;

    local procedure CountAllSalesRows(): Integer
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
    begin
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        exit(DeferralPostingBuffer.Count());
    end;

    local procedure InsertSalesRow(DocumentNo: Code[20]; DeferralLineNo: Integer)
    var
        RevenueAccountTok: Label 'G2651REV', Locked = true;
        DeferralAccountTok: Label 'G2651DEF', Locked = true;
    begin
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Sales, DocumentNo, DeferralLineNo, _LibPOSDeferral.SalePostingDate(), RevenueAccountTok, DeferralAccountTok, -100, false);
    end;

    local procedure InsertPurchaseRow() PurchaseNo: Code[20]
    var
        LibraryUtility: Codeunit "Library - Utility";
        RevenueAccountTok: Label 'G2651REV', Locked = true;
        DeferralAccountTok: Label 'G2651DEF', Locked = true;
    begin
        PurchaseNo := LibraryUtility.GenerateGUID();
        _LibPOSDeferral.InsertDeferralBufferRow(Enum::"Deferral Document Type"::Purchase, PurchaseNo, 1, _LibPOSDeferral.SalePostingDate(), RevenueAccountTok, DeferralAccountTok, -123.45, false);
    end;

    local procedure GetIndexedDocumentNo(Index: Integer): Code[20]
    begin
        if Index < 10 then
            exit(CopyStr('D-0' + Format(Index, 0, 9), 1, 20));
        exit(CopyStr('D-' + Format(Index, 0, 9), 1, 20));
    end;

    local procedure GetCreatedAt(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(13, 10, 2026), 230000T));
    end;

    local procedure GetClassificationMessage(RowId: Text; CreatedAt: DateTime; ModifiedAt: DateTime; Expected: Boolean): Text
    var
        ClassificationLbl: Label '%1: IsModifiedAfterCreation(CreatedAt [%2], ModifiedAt [%3]) expected %4', Locked = true;
    begin
        exit(StrSubstNo(ClassificationLbl, RowId, Format(CreatedAt, 0, 9), Format(ModifiedAt, 0, 9), Expected));
    end;

    local procedure GetExpectedDocumentLines(var ExpectedLines: List of [Text]; var SalesRows: Integer; var ModifiedRows: Integer)
    var
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        DocumentNo: Code[20];
        CreatedAt: DateTime;
        ModifiedAt: DateTime;
        HasDocument: Boolean;
        DocumentModifiedRows: Integer;
        DocumentRows: Integer;
    begin
        Clear(ExpectedLines);
        SalesRows := 0;
        ModifiedRows := 0;
        DeferralPostingBuffer.SetCurrentKey("Deferral Doc. Type", "Document No.", "Deferral Line No.");
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", Enum::"Deferral Document Type"::Sales);
        if not DeferralPostingBuffer.FindSet() then
            exit;
        repeat
            if HasDocument and (DeferralPostingBuffer."Document No." <> DocumentNo) then begin
                ExpectedLines.Add(GetDocumentLine(DocumentNo, DocumentRows, DocumentModifiedRows, CreatedAt, ModifiedAt));
                HasDocument := false;
            end;
            if not HasDocument then begin
                DocumentNo := DeferralPostingBuffer."Document No.";
                DocumentRows := 0;
                DocumentModifiedRows := 0;
                CreatedAt := 0DT;
                ModifiedAt := 0DT;
                HasDocument := true;
            end;
            DocumentRows += 1;
            SalesRows += 1;
            if (DeferralPostingBuffer.SystemCreatedAt <> 0DT) and (DeferralPostingBuffer.SystemModifiedAt > DeferralPostingBuffer.SystemCreatedAt) then begin
                DocumentModifiedRows += 1;
                ModifiedRows += 1;
            end;
            if (DeferralPostingBuffer.SystemCreatedAt <> 0DT) and ((CreatedAt = 0DT) or (DeferralPostingBuffer.SystemCreatedAt < CreatedAt)) then
                CreatedAt := DeferralPostingBuffer.SystemCreatedAt;
            if DeferralPostingBuffer.SystemModifiedAt > ModifiedAt then
                ModifiedAt := DeferralPostingBuffer.SystemModifiedAt;
        until DeferralPostingBuffer.Next() = 0;
        ExpectedLines.Add(GetDocumentLine(DocumentNo, DocumentRows, DocumentModifiedRows, CreatedAt, ModifiedAt));
    end;

    local procedure GetDocumentLine(DocumentNo: Code[20]; DocumentRows: Integer; DocumentModifiedRows: Integer; CreatedAt: DateTime; ModifiedAt: DateTime): Text
    var
        DocumentLineTok: Label '%1,%2,%3,%4,%5', Locked = true;
    begin
        exit(StrSubstNo(DocumentLineTok, DocumentNo, Format(DocumentRows, 0, 9), Format(DocumentModifiedRows, 0, 9), Format(CreatedAt, 0, 9), Format(ModifiedAt, 0, 9)));
    end;

    local procedure GetExpectedPartText(ExpectedLines: List of [Text]; SalesRows: Integer; ModifiedRows: Integer; PartNo: Integer; PartCount: Integer): Text
    var
        Part: TextBuilder;
        LastIndex: Integer;
        i: Integer;
        HeaderTok: Label 'The upgrade deletes %1 leftover Sales rows of %2 documents from the Deferral Posting Buffer, %3 rows modified after creation, part %4 of %5. The deferral posting bug fixed in CORE-2651 left these rows.', Locked = true;
        ColumnsTok: Label 'Document No.,Grouped Rows,Modified Rows,Created At,Last Modified At', Locked = true;
    begin
        Part.Append(StrSubstNo(HeaderTok, Format(SalesRows, 0, 9), Format(ExpectedLines.Count(), 0, 9), Format(ModifiedRows, 0, 9), Format(PartNo, 0, 9), Format(PartCount, 0, 9)));
        Part.AppendLine();
        Part.Append(ColumnsTok);
        LastIndex := PartNo * GetPartSize();
        if LastIndex > ExpectedLines.Count() then
            LastIndex := ExpectedLines.Count();
        for i := (PartNo - 1) * GetPartSize() + 1 to LastIndex do begin
            Part.AppendLine();
            Part.Append(ExpectedLines.Get(i));
        end;
        exit(Part.ToText());
    end;

    local procedure GetPartSize(): Integer
    begin
        exit(50);
    end;

    local procedure GetStepTransactionName(): Text
    var
        StepTransactionTok: Label 'Deferral Posting Buffer cleanup', Locked = true;
    begin
        exit(StepTransactionTok);
    end;

    local procedure GetStepErrorPrefix(): Text
    var
        StepErrorPrefixTok: Label 'The upgrade deletes ', Locked = true;
    begin
        exit(StepErrorPrefixTok);
    end;

    local procedure GetStepPayloads(var SentryCapture: Codeunit "NPR Library - Sentry Capture"; RowId: Text; var StepTransactions: JsonArray; var ErrorValues: List of [Text]; var ErrorTraceIds: List of [Text])
    var
        Payload: JsonObject;
        ErrorValue: Text;
        i: Integer;
        StepErrorFrameLbl: Label '%1: every step error carries the fixed call-stack frame', Locked = true;
    begin
        Clear(StepTransactions);
        Clear(ErrorValues);
        Clear(ErrorTraceIds);
        for i := 1 to SentryCapture.PayloadCount() do begin
            Payload := ParsePayload(SentryCapture.GetPayload(i), RowId);
            if GetTopLevelMember(Payload, 'transaction') = GetStepTransactionName() then
                StepTransactions.Add(Payload)
            else
                if GetExceptionValue(Payload, ErrorValue) then
                    if ErrorValue.StartsWith(GetStepErrorPrefix()) then begin
                        _Assert.AreEqual(GetStepErrorFrame(), GetExceptionFirstFrame(Payload), StrSubstNo(StepErrorFrameLbl, RowId));
                        ErrorValues.Add(ErrorValue);
                        ErrorTraceIds.Add(GetExceptionTraceId(Payload));
                    end;
        end;
    end;

    local procedure GetStepErrorFrame(): Text
    var
        StepErrorFrameTok: Label 'NPR UPG POS Entry Posting(RemoveLeftoverSalesDeferralRows)', Locked = true;
    begin
        exit(StepErrorFrameTok);
    end;

    local procedure GetExceptionFirstFrame(Payload: JsonObject): Text
    var
        FrameToken: JsonToken;
        FunctionToken: JsonToken;
        Value: Text;
    begin
        if not Payload.SelectToken('$.exception.values[0].stacktrace.frames[0]', FrameToken) then
            exit('');
        if not FrameToken.IsObject() then
            exit('');
        if not FrameToken.AsObject().Get('function', FunctionToken) then
            exit('');
        if GetValueText(FunctionToken, Value) then
            exit(Value);
        exit('');
    end;

    local procedure CountStepPayloads(var SentryCapture: Codeunit "NPR Library - Sentry Capture"; RowId: Text): Integer
    var
        StepTransactions: JsonArray;
        ErrorTraceIds: List of [Text];
        ErrorValues: List of [Text];
    begin
        GetStepPayloads(SentryCapture, RowId, StepTransactions, ErrorValues, ErrorTraceIds);
        exit(StepTransactions.Count() + ErrorValues.Count());
    end;

    local procedure ParsePayload(PayloadText: Text; RowId: Text) Payload: JsonObject
    var
        NotJsonLbl: Label '%1: a captured Sentry payload is not a JSON object: %2', Locked = true;
    begin
        _Assert.IsTrue(Payload.ReadFrom(PayloadText), StrSubstNo(NotJsonLbl, RowId, CopyStr(PayloadText, 1, 250)));
    end;

    local procedure GetTopLevelMember(Payload: JsonObject; MemberKey: Text): Text
    var
        ValueToken: JsonToken;
        Value: Text;
    begin
        if Payload.Get(MemberKey, ValueToken) then
            if GetValueText(ValueToken, Value) then
                exit(Value);
        exit('');
    end;

    local procedure GetSectionMember(Payload: JsonObject; Section: Text; MemberKey: Text; var Value: Text): Boolean
    var
        SectionToken: JsonToken;
        ValueToken: JsonToken;
    begin
        if not Payload.Get(Section, SectionToken) then
            exit(false);
        if not SectionToken.IsObject() then
            exit(false);
        if not SectionToken.AsObject().Get(MemberKey, ValueToken) then
            exit(false);
        exit(GetValueText(ValueToken, Value));
    end;

    local procedure GetValueText(ValueToken: JsonToken; var Value: Text): Boolean
    begin
        if not ValueToken.IsValue() then
            exit(false);
        if ValueToken.AsValue().IsNull() then
            exit(false);
        Value := ValueToken.AsValue().AsText();
        exit(true);
    end;

    local procedure GetExceptionValue(Payload: JsonObject; var Value: Text): Boolean
    var
        ExceptionToken: JsonToken;
        ExceptionValueToken: JsonToken;
        ValuesToken: JsonToken;
        ValueToken: JsonToken;
    begin
        if not Payload.Get('exception', ExceptionToken) then
            exit(false);
        if not ExceptionToken.IsObject() then
            exit(false);
        if not ExceptionToken.AsObject().Get('values', ValuesToken) then
            exit(false);
        if not ValuesToken.IsArray() then
            exit(false);
        if not ValuesToken.AsArray().Get(0, ExceptionValueToken) then
            exit(false);
        if not ExceptionValueToken.IsObject() then
            exit(false);
        if not ExceptionValueToken.AsObject().Get('value', ValueToken) then
            exit(false);
        exit(GetValueText(ValueToken, Value));
    end;

    local procedure GetExceptionTraceId(Payload: JsonObject): Text
    var
        ContextsToken: JsonToken;
        TraceIdToken: JsonToken;
        TraceToken: JsonToken;
        TraceId: Text;
    begin
        if not Payload.Get('contexts', ContextsToken) then
            exit('');
        if not ContextsToken.IsObject() then
            exit('');
        if not ContextsToken.AsObject().Get('trace', TraceToken) then
            exit('');
        if not TraceToken.IsObject() then
            exit('');
        if not TraceToken.AsObject().Get('trace_id', TraceIdToken) then
            exit('');
        if GetValueText(TraceIdToken, TraceId) then
            exit(TraceId);
        exit('');
    end;

    local procedure GetMemberMismatch(RowId: Text; PayloadName: Text; Payload: JsonObject; Section: Text; MemberKey: Text; Expected: Text): Text
    var
        Value: Text;
        MissingLbl: Label '%1: %2 payload %3.%4 expected [%5], actual missing; ', Locked = true;
        ValueLbl: Label '%1: %2 payload %3.%4 expected [%5], actual [%6]; ', Locked = true;
    begin
        if not GetSectionMember(Payload, Section, MemberKey, Value) then
            exit(StrSubstNo(MissingLbl, RowId, PayloadName, Section, MemberKey, Expected));
        if Value <> Expected then
            exit(StrSubstNo(ValueLbl, RowId, PayloadName, Section, MemberKey, Expected, Value));
    end;

    local procedure GetTagAbsentMismatch(RowId: Text; Payload: JsonObject; TagKey: Text): Text
    var
        Value: Text;
        PresentLbl: Label '%1: step transaction tag %2 expected absent, actual [%3]; ', Locked = true;
    begin
        if GetSectionMember(Payload, 'tags', TagKey, Value) then
            exit(StrSubstNo(PresentLbl, RowId, TagKey, Value));
    end;

    local procedure GetStepTransactionMismatches(RowId: Text; StepTransactions: JsonArray; SalesRows: Integer; ModifiedRows: Integer) Mismatches: Text
    var
        Transaction: JsonObject;
        TransactionToken: JsonToken;
        DataToken: JsonToken;
        TransactionCountLbl: Label '%1: step transactions named [%2] expected 1, actual %3; ', Locked = true;
        DataLbl: Label '%1: step transaction member data expected absent, actual present; ', Locked = true;
    begin
        if StepTransactions.Count() <> 1 then
            Mismatches += StrSubstNo(TransactionCountLbl, RowId, GetStepTransactionName(), StepTransactions.Count());
        if not StepTransactions.Get(0, TransactionToken) then
            exit;
        Transaction := TransactionToken.AsObject();
        Mismatches += GetMemberMismatch(RowId, 'step transaction', Transaction, 'tags', 'deferral.sales_rows', Format(SalesRows, 0, 9));
        Mismatches += GetMemberMismatch(RowId, 'step transaction', Transaction, 'tags', 'deferral.modified_rows', Format(ModifiedRows, 0, 9));
        Mismatches += GetTagAbsentMismatch(RowId, Transaction, 'deferral.cleanup');
        Mismatches += GetTagAbsentMismatch(RowId, Transaction, 'deferral.event');
        Mismatches += GetTagAbsentMismatch(RowId, Transaction, 'deferral.has_modified_rows');
        Mismatches += GetTagAbsentMismatch(RowId, Transaction, 'deferral.batch');
        if Transaction.Get('data', DataToken) then
            Mismatches += StrSubstNo(DataLbl, RowId);
    end;

    local procedure GetStepErrorMismatches(RowId: Text; ErrorValues: List of [Text]; ExpectedLines: List of [Text]; SalesRows: Integer; ModifiedRows: Integer; ExpectedPartCount: Integer) Mismatches: Text
    var
        Expected: Text;
        PartCount: Integer;
        PartNo: Integer;
        FixturePartsLbl: Label '%1: the fixture of %2 documents makes %3 parts of 50, the test expects %4; ', Locked = true;
        ErrorCountLbl: Label '%1: step errors expected %2, actual %3; ', Locked = true;
    begin
        PartCount := (ExpectedLines.Count() + GetPartSize() - 1) div GetPartSize();
        if PartCount <> ExpectedPartCount then
            Mismatches += StrSubstNo(FixturePartsLbl, RowId, ExpectedLines.Count(), PartCount, ExpectedPartCount);
        if ErrorValues.Count() <> ExpectedPartCount then
            Mismatches += StrSubstNo(ErrorCountLbl, RowId, ExpectedPartCount, ErrorValues.Count());
        for PartNo := 1 to ErrorValues.Count() do
            if PartNo <= ExpectedPartCount then begin
                Expected := GetExpectedPartText(ExpectedLines, SalesRows, ModifiedRows, PartNo, ExpectedPartCount);
                if ErrorValues.Get(PartNo) <> Expected then
                    Mismatches += GetTextDiff(RowId, PartNo, Expected, ErrorValues.Get(PartNo));
            end;
    end;

    local procedure GetTextDiff(RowId: Text; PartNo: Integer; Expected: Text; Actual: Text): Text
    var
        ActualLines: List of [Text];
        ExpectedLines: List of [Text];
        ActualLine: Text;
        ExpectedLine: Text;
        LineCount: Integer;
        LineNo: Integer;
        LineCountLbl: Label '%1: step error %2 lines expected %3, actual %4; ', Locked = true;
        LineLbl: Label '%1: step error %2 line %3 expected [%4], actual [%5]; ', Locked = true;
        WholeTextLbl: Label '%1: step error %2 expected [%3], actual [%4]; ', Locked = true;
    begin
        ExpectedLines := SplitLines(Expected);
        ActualLines := SplitLines(Actual);
        LineCount := ExpectedLines.Count();
        if ActualLines.Count() > LineCount then
            LineCount := ActualLines.Count();
        for LineNo := 1 to LineCount do begin
            ExpectedLine := '';
            ActualLine := '';
            if LineNo <= ExpectedLines.Count() then
                ExpectedLine := ExpectedLines.Get(LineNo);
            if LineNo <= ActualLines.Count() then
                ActualLine := ActualLines.Get(LineNo);
            if ExpectedLine <> ActualLine then
                exit(StrSubstNo(LineCountLbl, RowId, PartNo, ExpectedLines.Count(), ActualLines.Count()) + StrSubstNo(LineLbl, RowId, PartNo, LineNo, ExpectedLine, ActualLine));
        end;
        exit(StrSubstNo(WholeTextLbl, RowId, PartNo, Expected, Actual));
    end;

    local procedure SplitLines(Value: Text): List of [Text]
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Value.Replace(TypeHelper.CRLFSeparator(), TypeHelper.LFSeparator()).Split(TypeHelper.LFSeparator()));
    end;

    local procedure GetDocumentLineMismatch(RowId: Text; ErrorValues: List of [Text]; Prefix: Text): Text
    var
        Lines: List of [Text];
        ErrorValue: Text;
        Matches: Integer;
        LineNo: Integer;
        PrefixLbl: Label '%1: document lines that start with [%2] expected 1, actual %3; ', Locked = true;
    begin
        foreach ErrorValue in ErrorValues do begin
            Lines := SplitLines(ErrorValue);
            for LineNo := 3 to Lines.Count() do
                if Lines.Get(LineNo).StartsWith(Prefix) then
                    Matches += 1;
        end;
        if Matches <> 1 then
            exit(StrSubstNo(PrefixLbl, RowId, Prefix, Matches));
    end;

    local procedure GetPartLinesMismatch(RowId: Text; ErrorValues: List of [Text]; PartNo: Integer; ExpectedLineCount: Integer; FirstPrefix: Text; LastPrefix: Text): Text
    var
        Lines: List of [Text];
        NoPartLbl: Label '%1: step error %2 expected, actual %3 step errors; ', Locked = true;
        LineCountLbl: Label '%1: document lines of step error %2 expected %3, actual %4; ', Locked = true;
        FirstLineLbl: Label '%1: first document line of step error %2 expected to start with [%3], actual [%4]; ', Locked = true;
        LastLineLbl: Label '%1: last document line of step error %2 expected to start with [%3], actual [%4]; ', Locked = true;
    begin
        if PartNo > ErrorValues.Count() then
            exit(StrSubstNo(NoPartLbl, RowId, PartNo, ErrorValues.Count()));
        Lines := SplitLines(ErrorValues.Get(PartNo));
        if Lines.Count() - 2 <> ExpectedLineCount then
            exit(StrSubstNo(LineCountLbl, RowId, PartNo, ExpectedLineCount, Lines.Count() - 2));
        if not Lines.Get(3).StartsWith(FirstPrefix) then
            exit(StrSubstNo(FirstLineLbl, RowId, PartNo, FirstPrefix, Lines.Get(3)));
        if not Lines.Get(Lines.Count()).StartsWith(LastPrefix) then
            exit(StrSubstNo(LastLineLbl, RowId, PartNo, LastPrefix, Lines.Get(Lines.Count())));
    end;

    internal procedure ResetRecorded()
    begin
        Clear(_ObservedSalesRows);
        Clear(_ObservedTagSet);
        _FailedSends := 0;
    end;

    internal procedure SetObserveMode()
    begin
        _SubscriberMode := _SubscriberMode::Observe;
    end;

    internal procedure SetFailMode()
    begin
        _SubscriberMode := _SubscriberMode::Fail;
    end;

    internal procedure SetOffMode()
    begin
        _SubscriberMode := _SubscriberMode::Off;
    end;

    internal procedure ObservationCount(): Integer
    begin
        exit(_ObservedSalesRows.Count());
    end;

    internal procedure GetObservedSalesRows(Index: Integer): Integer
    begin
        exit(_ObservedSalesRows.Get(Index));
    end;

    internal procedure GetObservedTagSet(Index: Integer): Boolean
    begin
        exit(_ObservedTagSet.Get(Index));
    end;

    internal procedure FailedSendCount(): Integer
    begin
        exit(_FailedSends);
    end;

    local procedure IsStepPayload(PayloadJson: Text): Boolean
    var
        Payload: JsonObject;
        ErrorValue: Text;
    begin
        if not Payload.ReadFrom(PayloadJson) then
            exit(false);
        if GetTopLevelMember(Payload, 'transaction') = GetStepTransactionName() then
            exit(true);
        if GetExceptionValue(Payload, ErrorValue) then
            exit(ErrorValue.StartsWith(GetStepErrorPrefix()));
        exit(false);
    end;

    // No assertion here: the Sentry send swallows errors, so the test asserts on what this records
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sentry Transaction", 'OnBeforeSendSentryPayload', '', false, false)]
    local procedure OnBeforeSendSentryPayload(PayloadJson: Text)
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SendFailedErr: Label 'The test fails the Sentry send of the deferral buffer cleanup.', Locked = true;
    begin
        if _SubscriberMode = _SubscriberMode::Off then
            exit;
        if not IsStepPayload(PayloadJson) then
            exit;
        case _SubscriberMode of
            _SubscriberMode::Observe:
                begin
                    _ObservedSalesRows.Add(CountAllSalesRows());
                    _ObservedTagSet.Add(UpgradeTag.HasUpgradeTag(GetRemoveLeftoverRowsTag()));
                end;
            _SubscriberMode::Fail:
                begin
                    _FailedSends += 1;
                    Error(SendFailedErr);
                end;
        end;
    end;
}
