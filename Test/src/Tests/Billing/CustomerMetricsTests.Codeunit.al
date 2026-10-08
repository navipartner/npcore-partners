codeunit 85496 "NPR Customer Metrics Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryUtility: Codeunit "Library - Utility";
        _BusinessDateKeyTok: Label 'business_date', Locked = true;

    #region [Framework]

    [Test]
    procedure TrySendMetric_SendsOneEventUnderTheSyncRowSystemId()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        EventType: Enum "NPR Billing Event Type";
        Metadata: JsonObject;
        EventId: Guid;
        Quantity: Decimal;
        BusinessDate: Date;
        ErrorText: Text;
    begin
        BusinessDate := PrepareBusinessDate(1);
        MockMetric.SetValue(7, 'test_key', 'test_value');

        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'Sending the metric should succeed: ' + ErrorText);

        _Assert.IsTrue(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BusinessDate), 'A sync row must be stored for the metric and business date');

        _Assert.AreEqual(1, MockSender.EventCount(), 'Exactly one event must be sent for the metric and business date');
        MockSender.GetEvent(1, EventId, EventType, Quantity, Metadata);
        _Assert.AreEqual(MetricSync.SystemId, EventId, 'The event ID must be the SystemId of the sync row, so the event stays the same on a retry');
        _Assert.AreEqual(Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT.AsInteger(), EventType.AsInteger(), 'The event must carry the metric''s event type');
        _Assert.AreEqual(7, Quantity, 'The event must carry the calculated value');
        _Assert.AreEqual('test_value', GetMetadataText(Metadata, 'test_key'), 'The event must carry the metadata added by the metric');
        _Assert.AreEqual(Format(BusinessDate, 0, 9), GetMetadataText(Metadata, _BusinessDateKeyTok), 'The event must carry the business date, because the event timestamp is the registration time');
    end;

    [Test]
    procedure TrySendMetric_SameBusinessDateTwice_CalculatesAndSendsOnce()
    var
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        BusinessDate: Date;
        ErrorText: Text;
    begin
        BusinessDate := PrepareBusinessDate(2);
        MockMetric.SetValue(3, '', '');

        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'The first run should succeed: ' + ErrorText);
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'The second run should succeed: ' + ErrorText);

        _Assert.AreEqual(1, MockMetric.CalculateCount(), 'The metric must be calculated only once per business date');
        _Assert.AreEqual(1, MockSender.EventCount(), 'Only one event may be sent per metric and business date');
    end;

    [Test]
    procedure TrySendMetric_FailingRun_DoesNotRollBackOtherRuns()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        FailingMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        BeforeFailureDate: Date;
        FailureDate: Date;
        AfterFailureDate: Date;
        ErrorText: Text;
    begin
        BeforeFailureDate := PrepareBusinessDate(11);
        FailureDate := PrepareBusinessDate(12);
        AfterFailureDate := PrepareBusinessDate(13);
        MockMetric.SetValue(1, '', '');
        FailingMetric.SetFailure('Simulated metric failure');

        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BeforeFailureDate, ErrorText), 'The metric before the failure should succeed: ' + ErrorText);
        _Assert.IsFalse(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, FailingMetric, MockSender, FailureDate, ErrorText), 'The failing metric must report the failure');
        _Assert.IsTrue(StrPos(ErrorText, 'Simulated metric failure') > 0, 'The failure must return the metric''s error, got: ' + ErrorText);
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, AfterFailureDate, ErrorText), 'The metric after the failure should succeed: ' + ErrorText);

        _Assert.IsTrue(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BeforeFailureDate), 'The metric sent before the failure must not be rolled back');
        _Assert.IsTrue(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, AfterFailureDate), 'The metric sent after the failure must be stored');
        _Assert.IsFalse(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, FailureDate), 'The failed metric must not leave a sync row, so the next run tries again');
        _Assert.AreEqual(2, MockSender.EventCount(), 'Only the two successful metrics may be sent');
    end;

    [Test]
    procedure TrySendMetric_SenderFails_NextRunRetries()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        BusinessDate: Date;
        ErrorText: Text;
    begin
        BusinessDate := PrepareBusinessDate(21);
        MockMetric.SetValue(4, '', '');
        MockSender.SetFailure('Simulated sender failure');

        _Assert.IsFalse(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'A sender failure must be reported');

        _Assert.IsFalse(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BusinessDate), 'No sync row may be kept when the event could not be queued');

        MockSender.SetFailure('');
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'The next run should succeed: ' + ErrorText);

        _Assert.IsTrue(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BusinessDate), 'The next run must store the sync row');
        _Assert.AreEqual(2, MockMetric.CalculateCount(), 'The next run must calculate the metric again');
        _Assert.AreEqual(1, MockSender.EventCount(), 'The metric must be sent once');
    end;

    [Test]
    procedure TrySendMetric_OverlappingRunSentTheDate_EndsWithoutSending()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        BusinessDate: Date;
        ErrorText: Text;
    begin
        BusinessDate := PrepareBusinessDate(31);
        MockMetric.SetValue(2, '', '');
        MockMetric.SimulateOverlappingRun();

        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'The run that loses the race must end without an error: ' + ErrorText);

        _Assert.AreEqual(0, MockSender.EventCount(), 'Only the run that stored the sync row may send the event');
        _Assert.IsTrue(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BusinessDate), 'The sync row of the other run must be kept');
    end;

    [Test]
    procedure SendMetric_FirstRun_SendsOnlyYesterday()
    var
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        Yesterday: Date;
        FailedMetrics: Text;
    begin
        Yesterday := PrepareBusinessDate(100);
        MockMetric.SetValue(1, '', '');

        CustomerMetricsJQ.SendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, Yesterday, FailedMetrics);

        _Assert.AreEqual('', FailedMetrics, 'Sending the metric should succeed');
        _Assert.AreEqual(1, MockSender.EventCount(), 'The first run must send only yesterday, so a new install does not backfill history');
        AssertEventBusinessDate(MockSender, 1, Yesterday);
    end;

    [Test]
    procedure SendMetric_CatchesUpOnDatesMissedSinceTheFirstSentDate()
    var
        MockMetric: Codeunit "NPR Mock Customer Metric";
        FirstRunSender: Codeunit "NPR Mock Cust. Metric Sender";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        Yesterday: Date;
        ErrorText: Text;
        FailedMetrics: Text;
    begin
        Yesterday := PrepareBusinessDate(110);
        MockMetric.SetValue(1, '', '');
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, FirstRunSender, Yesterday - 3, ErrorText), 'The first run should succeed: ' + ErrorText);

        CustomerMetricsJQ.SendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, Yesterday, FailedMetrics);

        _Assert.AreEqual(3, MockSender.EventCount(), 'The run must send the two missed dates and yesterday');
        AssertEventBusinessDate(MockSender, 1, Yesterday - 2);
        AssertEventBusinessDate(MockSender, 3, Yesterday);
    end;

    [Test]
    procedure SendMetric_CatchesUpAtMost7Days()
    var
        MockMetric: Codeunit "NPR Mock Customer Metric";
        FirstRunSender: Codeunit "NPR Mock Cust. Metric Sender";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        Yesterday: Date;
        ErrorText: Text;
        FailedMetrics: Text;
    begin
        Yesterday := PrepareBusinessDate(150);
        MockMetric.SetValue(1, '', '');
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, FirstRunSender, Yesterday - 30, ErrorText), 'The first run should succeed: ' + ErrorText);

        CustomerMetricsJQ.SendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, Yesterday, FailedMetrics);

        _Assert.AreEqual(7, MockSender.EventCount(), 'The run must catch up on the 7 days ending yesterday and no further');
        AssertEventBusinessDate(MockSender, 1, Yesterday - 6);
        AssertEventBusinessDate(MockSender, 7, Yesterday);
    end;

    [Test]
    procedure SendMetric_FailingDate_DoesNotStopTheCatchUp()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        FirstRunSender: Codeunit "NPR Mock Cust. Metric Sender";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        Yesterday: Date;
        ErrorText: Text;
        FailedMetrics: Text;
    begin
        Yesterday := PrepareBusinessDate(130);
        MockMetric.SetValue(1, '', '');
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, FirstRunSender, Yesterday - 3, ErrorText), 'The first run should succeed: ' + ErrorText);
        MockMetric.SetFailureOn(Yesterday - 1, 'Simulated failure for one date');

        CustomerMetricsJQ.SendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, Yesterday, FailedMetrics);

        _Assert.IsTrue(StrPos(FailedMetrics, 'Simulated failure for one date') > 0, 'The failed date must be reported, got: ' + FailedMetrics);
        _Assert.AreEqual(2, MockSender.EventCount(), 'The dates before and after the failed one must still be sent');
        AssertEventBusinessDate(MockSender, 1, Yesterday - 2);
        AssertEventBusinessDate(MockSender, 2, Yesterday);
        _Assert.IsFalse(MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, Yesterday - 1), 'The failed date must stay unsent, so the next run tries it again');
    end;

    [Test]
    procedure CustomerMetricSender_QueuesBillingEvent()
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        CustomerMetricSender: Codeunit "NPR Customer Metric Sender";
        Metadata: JsonObject;
        QueuedMetadata: JsonObject;
        EventId: Guid;
    begin
        EventId := CreateGuid();
        Metadata.Add(_BusinessDateKeyTok, '2000-01-01');

        // Called directly instead of through TrySendMetric, so the test event is rolled back instead of committed and sent
        CustomerMetricSender.RegisterEvent(EventId, Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT, 5, Metadata);

        BillingQueueEntry.SetRange("Event ID", EventId);
        _Assert.AreEqual(1, BillingQueueEntry.Count(), 'Exactly one billing queue entry must carry the event ID');
        BillingQueueEntry.FindFirst();
        _Assert.AreEqual(Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT.AsInteger(), BillingQueueEntry."Feature ID", 'The queued event must carry the metric''s event type');
        _Assert.AreEqual(5, BillingQueueEntry.Quantity, 'The queued event must carry the value');
        QueuedMetadata.ReadFrom(BillingQueueEntry.GetMetadata());
        _Assert.AreEqual('2000-01-01', GetMetadataText(QueuedMetadata, _BusinessDateKeyTok), 'The queued event must carry the metadata');
    end;

    [Test]
    procedure CustomerMetricsJQ_RegistersProtectedDailyJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        DailyDateFormula: DateFormula;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Customer Metrics JQ");
        JobQueueEntry.DeleteAll(true);

        CustomerMetricsJQ.AddCustomerMetricsJob();

        _Assert.AreEqual(1, JobQueueEntry.Count(), 'Exactly one job queue entry must run the customer metrics job');
        JobQueueEntry.FindFirst();
        JobQueueEntry.TestField("Recurring Job", true);
        JobQueueEntry.TestField("NPR NP Protected Job", true);
        JobQueueEntry.TestField("Job Queue Category Code", CustomerMetricsJQ.JQCategoryCode());
        Evaluate(DailyDateFormula, '<1D>');
        _Assert.AreEqual(Format(DailyDateFormula), Format(JobQueueEntry."Next Run Date Formula"), 'The job must run once every 24 hours');
        _Assert.IsTrue(JobQueueEntry."Earliest Start Date/Time" > CurrentDateTime(), 'The first run must wait for the next run window, because a start in the past makes the dispatcher reschedule the job continuously');
        _Assert.AreEqual(JobQueueEntry."Starting Time", DT2Time(JobQueueEntry."Earliest Start Date/Time"), 'The first run must start when the run window opens');
    end;

    [Test]
    procedure CustomerMetric_ActivePOSUnits7D_IsSentAsPOSActiveUnits7DCount()
    var
        CustomerMetric: Interface "NPR ICustomer Metric";
    begin
        CustomerMetric := Enum::"NPR Customer Metric"::ActivePOSUnits7D;
        _Assert.AreEqual(Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT.AsInteger(), CustomerMetric.GetEventType().AsInteger(), 'Active POS Units (7 Days) must be sent as POS_ACTIVE_UNITS_7D_COUNT');
        _Assert.IsFalse(CustomerMetric.IsDelta(), 'Active POS Units (7 Days) is a full count, so missed dates must be caught up');
    end;

    [Test]
    procedure CustomerMetric_GLRevenue_IsADeltaSentAsGLRevenueAmountLCY()
    var
        CustomerMetric: Interface "NPR ICustomer Metric";
    begin
        CustomerMetric := Enum::"NPR Customer Metric"::GLRevenue;
        _Assert.AreEqual(Enum::"NPR Billing Event Type"::GL_REVENUE_AMOUNT_LCY.AsInteger(), CustomerMetric.GetEventType().AsInteger(), 'G/L Revenue must be sent as GL_REVENUE_AMOUNT_LCY');
        _Assert.IsTrue(CustomerMetric.IsDelta(), 'G/L Revenue is a delta, so missed dates must not be caught up');
    end;

    [Test]
    procedure SendMetric_DeltaMetric_SendsOnlyYesterday()
    var
        MockMetric: Codeunit "NPR Mock Customer Metric";
        FirstRunSender: Codeunit "NPR Mock Cust. Metric Sender";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        Yesterday: Date;
        ErrorText: Text;
        FailedMetrics: Text;
    begin
        Yesterday := PrepareBusinessDate(170);
        MockMetric.SetValue(1, '', '');
        MockMetric.SetDelta();
        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, FirstRunSender, Yesterday - 3, ErrorText), 'The first run should succeed: ' + ErrorText);

        CustomerMetricsJQ.SendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, Yesterday, FailedMetrics);

        _Assert.AreEqual(1, MockSender.EventCount(), 'A delta covers everything since its previous event, so only yesterday may be sent');
        AssertEventBusinessDate(MockSender, 1, Yesterday);
    end;

    [Test]
    procedure TrySendMetric_StoresTheSyncRowAsTheMetricLeftIt()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        MockMetric: Codeunit "NPR Mock Customer Metric";
        MockSender: Codeunit "NPR Mock Cust. Metric Sender";
        CustomerMetricsJQ: Codeunit "NPR Customer Metrics JQ";
        BusinessDate: Date;
        ErrorText: Text;
    begin
        BusinessDate := PrepareBusinessDate(41);
        MockMetric.SetValue(1, '', '');
        MockMetric.SetLastEntryNo(42);

        _Assert.IsTrue(CustomerMetricsJQ.TrySendMetric(Enum::"NPR Customer Metric"::ActivePOSUnits7D, MockMetric, MockSender, BusinessDate, ErrorText), 'Sending the metric should succeed: ' + ErrorText);

        MetricSync.Get(Enum::"NPR Customer Metric"::ActivePOSUnits7D, BusinessDate);
        _Assert.AreEqual(42, MetricSync."Last Entry No.", 'The sync row must keep the last entry no. the metric set, so the next delta starts after it');
    end;

    #endregion

    #region [Active POS units]

    [Test]
    procedure ActivePOSUnits_CountsUnitsWithASaleInTheLast7Days()
    var
        BusinessDate: Date;
        StoreCode: Code[10];
        POSUnitNo: Code[10];
        Expected: Decimal;
    begin
        BusinessDate := DMY2Date(15, 6, 2001);
        Expected := CalculateActivePOSUnits(BusinessDate);
        StoreCode := NewStoreCode();

        InsertSale(CreatePOSUnit(StoreCode), StoreCode, BusinessDate);
        Expected += 1;
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'A sale on the business date must count');

        InsertCreditSale(CreatePOSUnit(StoreCode), StoreCode, BusinessDate - 6);
        Expected += 1;
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'A Credit Sale 6 days before the business date must count');

        InsertSale(CreatePOSUnit(StoreCode), StoreCode, BusinessDate - 7);
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'A sale 7 days before the business date must not count');

        InsertSale(CreatePOSUnit(StoreCode), StoreCode, BusinessDate + 1);
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'A sale after the business date must not count');

        POSUnitNo := CreatePOSUnit(StoreCode);
        InsertSale(POSUnitNo, StoreCode, BusinessDate - 1);
        InsertSale(POSUnitNo, StoreCode, BusinessDate);
        Expected += 1;
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'A unit with several sales must count once');

        InsertSystemEntry(CreatePOSUnit(StoreCode), StoreCode, BusinessDate);
        InsertCancelledSale(CreatePOSUnit(StoreCode), StoreCode, BusinessDate);
        CreatePOSUnit(StoreCode);
        _Assert.AreEqual(Expected, CalculateActivePOSUnits(BusinessDate), 'System entries, other entry types and units without entries must not count');
    end;

    [Test]
    procedure ActivePOSUnits_CountsSalesMadeUnderAnotherStore()
    var
        BusinessDate: Date;
        Baseline: Decimal;
    begin
        BusinessDate := DMY2Date(15, 7, 2001);
        Baseline := CalculateActivePOSUnits(BusinessDate);

        InsertSale(CreatePOSUnit(NewStoreCode()), NewStoreCode(), BusinessDate - 2);

        _Assert.AreEqual(Baseline + 1, CalculateActivePOSUnits(BusinessDate), 'A unit must count for a sale made under another store, for example before the unit was moved to its current store');
    end;

    [Test]
    procedure ActivePOSUnits_OlderSaleInsertedAfterARecentOne_StillCountsTheUnit()
    var
        BusinessDate: Date;
        StoreCode: Code[10];
        POSUnitNo: Code[10];
        Baseline: Decimal;
    begin
        BusinessDate := DMY2Date(15, 8, 2001);
        Baseline := CalculateActivePOSUnits(BusinessDate);
        StoreCode := NewStoreCode();
        POSUnitNo := CreatePOSUnit(StoreCode);

        InsertSale(POSUnitNo, StoreCode, BusinessDate - 1);
        InsertSale(POSUnitNo, StoreCode, BusinessDate - 30);

        _Assert.AreEqual(Baseline + 1, CalculateActivePOSUnits(BusinessDate), 'A sale inside the 7 days must count even when an older sale, such as a late external sale, was inserted after it');
    end;

    #endregion

    #region [G/L revenue]

    [Test]
    procedure GLRevenue_CountsSaleEntriesOnIncomeStatementAccountsAsPositiveRevenue()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
        BalanceAccountNo: Code[20];
        LastEntryNo: Integer;
    begin
        StartGLRevenueAfterLastEntry(MetricSync);
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");
        BalanceAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Balance Sheet");

        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -100, Today(), '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, 30, Today(), '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Purchase, -50, Today(), '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::" ", -40, Today(), '', '');
        LastEntryNo := InsertGLEntry(BalanceAccountNo, Enum::"General Posting Type"::Sale, -70, Today(), '', '');

        _Assert.AreEqual(70, CalculateGLRevenue(MetricSync, Metadata), 'Only Sale entries on income statement accounts may count, with a credit as positive revenue');
        _Assert.AreEqual(LastEntryNo, MetricSync."Last Entry No.", 'The sync row must keep the last G/L entry, so the next event starts after it');
    end;

    [Test]
    procedure GLRevenue_LeavesOutYearEndClosingCompressionAndConsolidation()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        SourceCodeSetup: Record "Source Code Setup";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
    begin
        StartGLRevenueAfterLastEntry(MetricSync);
        SetCloseIncomeStatementAndCompressSourceCodes(SourceCodeSetup);
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");

        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -100, Today(), '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, 500, ClosingDate(Today()), SourceCodeSetup."Close Income Statement", '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -300, Today() - 400, SourceCodeSetup."Compress G/L", '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -200, Today(), '', NewBusinessUnitCode());

        _Assert.AreEqual(100, CalculateGLRevenue(MetricSync, Metadata), 'Year-end closing, date compression and consolidated entries must not count');
    end;

    [Test]
    procedure GLRevenue_ReversalOfAnAlreadySentEntry_ReducesTheNextEvent()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
        OriginalEntryNo: Integer;
    begin
        DeleteGLRevenueSyncRows();
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");
        OriginalEntryNo := InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -100, Today(), '', '');
        InsertSentGLRevenue(Today() - 1, OriginalEntryNo);

        MarkReversed(OriginalEntryNo, InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, 100, Today(), '', ''));
        InitGLRevenueSync(MetricSync, Today());

        _Assert.AreEqual(-100, CalculateGLRevenue(MetricSync, Metadata), 'The reversal of revenue that was already sent must reduce the next event, so the reported total cancels out');
    end;

    [Test]
    procedure GLRevenue_StartsAfterTheHighestSentEntryNo()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
        SentEntryNo: Integer;
    begin
        DeleteGLRevenueSyncRows();
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");
        SentEntryNo := InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -100, Today(), '', '');
        InsertSentGLRevenue(Today() - 2, SentEntryNo);
        InsertSentGLRevenue(Today() - 1, SentEntryNo - 1);
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -40, Today(), '', '');
        InitGLRevenueSync(MetricSync, Today());

        _Assert.AreEqual(40, CalculateGLRevenue(MetricSync, Metadata), 'Only entries after the highest sent entry no. may count, so no entry is sent twice');
    end;

    [Test]
    procedure GLRevenue_FirstEventStartsAtTheBusinessDate()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
        Baseline: Decimal;
    begin
        DeleteGLRevenueSyncRows();
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");
        InitGLRevenueSync(MetricSync, Today());
        Baseline := CalculateGLRevenue(MetricSync, Metadata);

        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -100, Today() - 30, '', '');

        _Assert.AreEqual(Baseline + 100, CalculateGLRevenue(MetricSync, Metadata), 'The first event must count the entries registered since the start of the business date, whatever their posting date');
        InitGLRevenueSync(MetricSync, Today() + 1);
        _Assert.AreEqual(0, CalculateGLRevenue(MetricSync, Metadata), 'The first event must not count entries registered before the business date');
    end;

    [Test]
    procedure GLRevenue_MetadataCarriesCurrencyCodeAndPostingDateRange()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Metadata: JsonObject;
        IncomeAccountNo: Code[20];
    begin
        StartGLRevenueAfterLastEntry(MetricSync);
        IncomeAccountNo := CreateGLAccount(Enum::"G/L Account Report Type"::"Income Statement");
        GeneralLedgerSetup.Get();

        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -10, Today() - 5, '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Sale, -10, Today() - 1, '', '');
        InsertGLEntry(IncomeAccountNo, Enum::"General Posting Type"::Purchase, -10, Today() - 9, '', '');
        CalculateGLRevenue(MetricSync, Metadata);

        _Assert.AreEqual(GeneralLedgerSetup."LCY Code", GetMetadataText(Metadata, 'currency'), 'The event must carry the local currency code');
        _Assert.AreEqual(Format(Today() - 5, 0, 9), GetMetadataText(Metadata, 'posting_date_from'), 'The posting date range must start at the earliest counted entry');
        _Assert.AreEqual(Format(Today() - 1, 0, 9), GetMetadataText(Metadata, 'posting_date_to'), 'The posting date range must end at the latest counted entry');
    end;

    [Test]
    procedure GLRevenue_NothingNewSinceTheLastEvent_SendsZeroAndKeepsThePosition()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        GLEntry: Record "G/L Entry";
        Metadata: JsonObject;
    begin
        StartGLRevenueAfterLastEntry(MetricSync);

        _Assert.AreEqual(0, CalculateGLRevenue(MetricSync, Metadata), 'With no new G/L entries the revenue must be zero');
        _Assert.AreEqual(GLEntry.GetLastEntryNo(), MetricSync."Last Entry No.", 'The next event must still start after the last sent entry');
        _Assert.IsFalse(Metadata.Contains('posting_date_from'), 'Without counted entries there is no posting date range');
    end;

    #endregion

    #region [Helpers]

    local procedure PrepareBusinessDate(Offset: Integer) BusinessDate: Date
    var
        MetricSync: Record "NPR Customer Metric Sync";
    begin
        // A date the daily job never uses
        BusinessDate := DMY2Date(1, 1, 2000) + Offset;
        // The catch-up starts at the first sent date, so sync rows of other tests must not be left
        MetricSync.DeleteAll();
        // TrySendMetric can isolate a failing metric only when no write transaction is open
        Commit();
    end;

    local procedure AssertEventBusinessDate(var MockSender: Codeunit "NPR Mock Cust. Metric Sender"; Index: Integer; BusinessDate: Date)
    var
        EventType: Enum "NPR Billing Event Type";
        Metadata: JsonObject;
        EventId: Guid;
        Quantity: Decimal;
    begin
        MockSender.GetEvent(Index, EventId, EventType, Quantity, Metadata);
        _Assert.AreEqual(Format(BusinessDate, 0, 9), GetMetadataText(Metadata, _BusinessDateKeyTok), StrSubstNo('Event %1 must be sent for business date %2', Index, Format(BusinessDate, 0, 9)));
    end;

    local procedure GetMetadataText(Metadata: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        if not Metadata.Get(KeyName, Token) then
            exit('');
        exit(Token.AsValue().AsText());
    end;

    local procedure CalculateActivePOSUnits(BusinessDate: Date): Decimal
    var
        MetricSync: Record "NPR Customer Metric Sync";
        ActivePOSUnitsMetric: Codeunit "NPR Active POS Units Metric";
        Metadata: JsonObject;
    begin
        MetricSync.Metric := Enum::"NPR Customer Metric"::ActivePOSUnits7D;
        MetricSync."Business Date" := BusinessDate;
        exit(ActivePOSUnitsMetric.Calculate(MetricSync, Metadata));
    end;

    local procedure CalculateGLRevenue(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
    var
        GLRevenueMetric: Codeunit "NPR GL Revenue Metric";
    begin
        Clear(Metadata);
        exit(GLRevenueMetric.Calculate(MetricSync, Metadata));
    end;

    local procedure StartGLRevenueAfterLastEntry(var MetricSync: Record "NPR Customer Metric Sync")
    var
        GLEntry: Record "G/L Entry";
    begin
        DeleteGLRevenueSyncRows();
        InsertSentGLRevenue(Today() - 1, GLEntry.GetLastEntryNo());
        InitGLRevenueSync(MetricSync, Today());
    end;

    local procedure InitGLRevenueSync(var MetricSync: Record "NPR Customer Metric Sync"; BusinessDate: Date)
    begin
        MetricSync.Init();
        MetricSync.Metric := Enum::"NPR Customer Metric"::GLRevenue;
        MetricSync."Business Date" := BusinessDate;
    end;

    local procedure InsertSentGLRevenue(BusinessDate: Date; LastEntryNo: Integer)
    var
        MetricSync: Record "NPR Customer Metric Sync";
    begin
        InitGLRevenueSync(MetricSync, BusinessDate);
        MetricSync."Last Entry No." := LastEntryNo;
        MetricSync.Insert();
    end;

    local procedure DeleteGLRevenueSyncRows()
    var
        MetricSync: Record "NPR Customer Metric Sync";
    begin
        MetricSync.SetRange(Metric, Enum::"NPR Customer Metric"::GLRevenue);
        MetricSync.DeleteAll();
    end;

    local procedure CreateGLAccount(IncomeBalance: Enum "G/L Account Report Type"): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Init();
        GLAccount."No." := CopyStr(_LibraryUtility.GenerateRandomCode(GLAccount.FieldNo("No."), Database::"G/L Account"), 1, MaxStrLen(GLAccount."No."));
        GLAccount."Income/Balance" := IncomeBalance;
        GLAccount.Insert();
        exit(GLAccount."No.");
    end;

    local procedure InsertGLEntry(GLAccountNo: Code[20]; GenPostingType: Enum "General Posting Type"; Amount: Decimal; PostingDate: Date; SourceCode: Code[10]; BusinessUnitCode: Code[20]): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := GLEntry.GetLastEntryNo() + 1;
        GLEntry."G/L Account No." := GLAccountNo;
        GLEntry."Gen. Posting Type" := GenPostingType;
        GLEntry.Amount := Amount;
        GLEntry."Posting Date" := PostingDate;
        GLEntry."Source Code" := SourceCode;
        GLEntry."Business Unit Code" := BusinessUnitCode;
        GLEntry.Insert();
        exit(GLEntry."Entry No.");
    end;

    local procedure MarkReversed(OriginalEntryNo: Integer; ReversalEntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Get(OriginalEntryNo);
        GLEntry.Reversed := true;
        GLEntry."Reversed by Entry No." := ReversalEntryNo;
        GLEntry.Modify();
        GLEntry.Get(ReversalEntryNo);
        GLEntry.Reversed := true;
        GLEntry."Reversed Entry No." := OriginalEntryNo;
        GLEntry.Modify();
    end;

    local procedure SetCloseIncomeStatementAndCompressSourceCodes(var SourceCodeSetup: Record "Source Code Setup")
    begin
        if not SourceCodeSetup.Get() then
            SourceCodeSetup.Insert();
        SourceCodeSetup."Close Income Statement" := CopyStr(_LibraryUtility.GenerateRandomCode(SourceCodeSetup.FieldNo("Close Income Statement"), Database::"Source Code Setup"), 1, MaxStrLen(SourceCodeSetup."Close Income Statement"));
        SourceCodeSetup."Compress G/L" := CopyStr(_LibraryUtility.GenerateRandomCode(SourceCodeSetup.FieldNo("Compress G/L"), Database::"Source Code Setup"), 1, MaxStrLen(SourceCodeSetup."Compress G/L"));
        SourceCodeSetup.Modify();
    end;

    local procedure NewBusinessUnitCode(): Code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        exit(CopyStr(_LibraryUtility.GenerateRandomCode(GLEntry.FieldNo("Business Unit Code"), Database::"G/L Entry"), 1, MaxStrLen(GLEntry."Business Unit Code")));
    end;

    local procedure NewStoreCode(): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        exit(CopyStr(_LibraryUtility.GenerateRandomCode(POSUnit.FieldNo("POS Store Code"), Database::"NPR POS Unit"), 1, MaxStrLen(POSUnit."POS Store Code")));
    end;

    local procedure CreatePOSUnit(StoreCode: Code[10]): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Init();
        POSUnit."No." := CopyStr(_LibraryUtility.GenerateRandomCode(POSUnit.FieldNo("No."), Database::"NPR POS Unit"), 1, MaxStrLen(POSUnit."No."));
        POSUnit."POS Store Code" := StoreCode;
        POSUnit.Insert();
        exit(POSUnit."No.");
    end;

    local procedure InsertSale(POSUnitNo: Code[10]; StoreCode: Code[10]; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        InsertPOSEntry(POSUnitNo, StoreCode, POSEntry."Entry Type"::"Direct Sale", false, EntryDate);
    end;

    local procedure InsertCreditSale(POSUnitNo: Code[10]; StoreCode: Code[10]; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        InsertPOSEntry(POSUnitNo, StoreCode, POSEntry."Entry Type"::"Credit Sale", false, EntryDate);
    end;

    local procedure InsertSystemEntry(POSUnitNo: Code[10]; StoreCode: Code[10]; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        InsertPOSEntry(POSUnitNo, StoreCode, POSEntry."Entry Type"::"Direct Sale", true, EntryDate);
    end;

    local procedure InsertCancelledSale(POSUnitNo: Code[10]; StoreCode: Code[10]; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        InsertPOSEntry(POSUnitNo, StoreCode, POSEntry."Entry Type"::"Cancelled Sale", false, EntryDate);
    end;

    local procedure InsertPOSEntry(POSUnitNo: Code[10]; StoreCode: Code[10]; EntryType: Integer; SystemEntry: Boolean; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Init();
        POSEntry."Entry No." := 0;
        POSEntry."POS Store Code" := StoreCode;
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Entry Type" := EntryType;
        POSEntry."System Entry" := SystemEntry;
        POSEntry."Entry Date" := EntryDate;
        POSEntry.Insert();
    end;

    #endregion
}
