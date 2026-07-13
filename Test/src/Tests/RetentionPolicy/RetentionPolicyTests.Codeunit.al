#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 85241 "NPR Retention Policy Tests"
{
    // [FEATURE] NPR Retention Policy
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        Initialized: Boolean;
        Assert: Codeunit Assert;
        JobQueueManagement: Codeunit "NPR Job Queue Management";

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure BasicRetentionPolicyWithExpiredRecord()
    // [SCENARIO] Application of a basic retention policy with no/simple field filters containing expired record to be deleted
    var
        RetentionPolicyLogEntry: Record "NPR Retention Policy Log Entry";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        ReferenceDateTime: DateTime;
        ReferenceDate: Date;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Retention Policy Log Entry"
        Initialize();
        RetentionPolicyLogEntry.DeleteAll();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Retention Policy Log Entry";
        RetentionPolicy.Insert();

        // [GIVEN] "NPR Retention Policy Log Entry" Record
        InsertRetentionPolicyLogEntryRecord(1);

        // [GIVEN] Expiring reference DateTime
        ReferenceDate := CalcDate('<+7M>', DT2Date(CurrentDateTime()));
        ReferenceDateTime := CreateDateTime(ReferenceDate, DT2Time(CurrentDateTime())) + JobQueueManagement.DaysToDuration(1);

        // [WHEN] Retention Policy is applied
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        // [THEN] The expired record is deleted
        Assert.IsTrue(RetentionPolicyLogEntry.IsEmpty(),
                      'Expired "NPR Retention Policy Log Entry" record should be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure BasicRetentionPolicyWithNonExpiredRecord()
    // [SCENARIO] Application of a basic retention policy with no/simple field filters containing non-expired record to be kept
    var
        RetentionPolicyLogEntry: Record "NPR Retention Policy Log Entry";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        ReferenceDateTime: DateTime;
        ReferenceDate: Date;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Retention Policy Log Entry"
        Initialize();
        RetentionPolicyLogEntry.DeleteAll();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Retention Policy Log Entry";
        RetentionPolicy.Insert();


        // [GIVEN] "NPR Retention Policy Log Entry" Record
        InsertRetentionPolicyLogEntryRecord(1);

        // [GIVEN] Non-expiring reference DateTime
        ReferenceDate := CalcDate('<+1M>', DT2Date(CurrentDateTime()));
        ReferenceDateTime := CreateDateTime(ReferenceDate, DT2Time(CurrentDateTime())) - JobQueueManagement.DaysToDuration(1);

        // [WHEN] Retention Policy is applied
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        // [THEN] The expired record is preserved
        Assert.IsTrue(not RetentionPolicyLogEntry.IsEmpty(),
                      'Non-expired "NPR Retention Policy Log Entry" record should be preserved.');
    end;


    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure DataLogRetentionPolicyWithExpiredEntries()
    // [SCENARIO] Application of Data Log Record retention policy on expired data log entries
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        TableID: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] Data Log Setup for a specific table ID
        TableID := Database::Customer;
        CreateDataLogSetup(TableID, JobQueueManagement.DaysToDuration(1));

        // [GIVEN] Data Log content
        InsertDataLogRecord(TableID, 1);
        InsertDataLogField(TableID, 1);
        InsertDataLogProcessingEntry(TableID, 1);

        // [WHEN] Retention Policy is applied at an expiring DateTime
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(10));

        // [THEN] Data Log content is deleted
        DataLogRecord.SetRange("Table ID", TableID);
        Assert.IsTrue(DataLogRecord.IsEmpty(), 'Expired Data Log Record entries should be deleted.');

        DataLogField.SetRange("Table ID", TableID);
        Assert.IsTrue(DataLogField.IsEmpty(), 'Expired Data Log Field entries should be deleted.');

        DataLogProcessingEntry.SetRange("Table Number", TableID);
        Assert.IsTrue(DataLogProcessingEntry.IsEmpty(), 'Expired Data Log Processing entries should be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure DataLogRetentionPolicyWithNonExpiredEntries()
    // [SCENARIO] Application of Data Log Record retention policy on non-expired data log entries
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        TableID: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] Data Log Setup for a specific table ID
        TableID := Database::Customer;
        CreateDataLogSetup(TableID, JobQueueManagement.DaysToDuration(10));

        // [GIVEN] Data Log content
        InsertDataLogRecord(TableID, 1);
        InsertDataLogField(TableID, 1);
        InsertDataLogProcessingEntry(TableID, 1);

        // [WHEN] Retention Policy is applied at a non-expiring DateTime
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(1));

        // [THEN] Data Log content is preserved
        DataLogRecord.SetRange("Table ID", TableID);
        Assert.IsTrue(not DataLogRecord.IsEmpty(), 'Expired Data Log Record entries should not be deleted.');

        DataLogField.SetRange("Table ID", TableID);
        Assert.IsTrue(not DataLogField.IsEmpty(), 'Expired Data Log Field entries should not be deleted.');

        DataLogProcessingEntry.SetRange("Table Number", TableID);
        Assert.IsTrue(not DataLogProcessingEntry.IsEmpty(), 'Expired Data Log Processing entries should not be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure DataLogRetentionPolicyExpiredEntriesIsolation()
    // [SCENARIO] Application of Data Log Record retention policy on 2 tables contaning both expired and non-expired data log entries
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        RetentionPolicy: Record "NPR Retention Policy";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        ExpiringTableID: Integer;
        NonExpiringTableID: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] Data Log Setup for a specific table ID with a 40 day retention period
        ExpiringTableID := Database::Customer;
        CreateDataLogSetup(ExpiringTableID, JobQueueManagement.DaysToDuration(40));

        // [GIVEN] Data Log Setup for a specific table ID with a 50 day retention period
        NonExpiringTableID := Database::Vendor;
        CreateDataLogSetup(NonExpiringTableID, JobQueueManagement.DaysToDuration(50));

        // [GIVEN] Table-specific Data Log content
        InsertDataLogRecord(ExpiringTableID, 1);
        InsertDataLogField(ExpiringTableID, 1);
        InsertDataLogProcessingEntry(ExpiringTableID, 1);

        InsertDataLogRecord(NonExpiringTableID, 2);
        InsertDataLogField(NonExpiringTableID, 2);
        InsertDataLogProcessingEntry(NonExpiringTableID, 2);

        // [WHEN] Retention Policy is applied after 45 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(45));

        // [THEN] The expiring Data Log content is deleted, but non-expiring Data Log content is preserved
        DataLogRecord.SetRange("Table ID", ExpiringTableID);
        Assert.IsTrue(DataLogRecord.IsEmpty(), 'Expired Data Log Record entries should be deleted.');

        DataLogField.SetRange("Table ID", ExpiringTableID);
        Assert.IsTrue(DataLogField.IsEmpty(), 'Expired Data Log Field entries should be deleted.');

        DataLogProcessingEntry.SetRange("Table Number", ExpiringTableID);
        Assert.IsTrue(DataLogProcessingEntry.IsEmpty(), 'Expired Data Log Processing entries should be deleted.');

        DataLogRecord.SetRange("Table ID", NonExpiringTableID);
        Assert.IsTrue(not DataLogRecord.IsEmpty(), 'Non-expired Data Log Record entries should not be deleted.');

        DataLogField.SetRange("Table ID", NonExpiringTableID);
        Assert.IsTrue(not DataLogField.IsEmpty(), 'Non-expired Data Log Field entries should not be deleted.');

        DataLogProcessingEntry.SetRange("Table Number", NonExpiringTableID);
        Assert.IsTrue(not DataLogProcessingEntry.IsEmpty(), 'Non-expired Data Log Processing entries should not be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure DataLogRetentionPolicyDeletesAcrossMultipleBatches()
    // [SCENARIO] Data Log retention drains the whole expired backlog even when it spans several delete batches, while preserving another table's non-expired entries
    var
        DataLogField: Record "NPR Data Log Field";
        RetentionPolicy: Record "NPR Retention Policy";
        DataLogSubMgt: Codeunit "NPR Data Log Sub. Mgt.";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        ExpiringTableID: Integer;
        NonExpiringTableID: Integer;
        ExpiredEntryCount: Integer;
        i: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] An expiring table (40 day retention) and a non-expiring table (50 day retention)
        ExpiringTableID := Database::Customer;
        CreateDataLogSetup(ExpiringTableID, JobQueueManagement.DaysToDuration(40));
        NonExpiringTableID := Database::Vendor;
        CreateDataLogSetup(NonExpiringTableID, JobQueueManagement.DaysToDuration(50));

        // [GIVEN] More expired entries than one batch (derived from BatchSize() so it stays multi-batch if retuned),
        // plus a non-expiring guard row at the lowest Entry No. 1 - inside the first batch window, so the
        // preservation assertion also catches a table-filter regression in the boundary-filtered branch. Expiring
        // entries start at 2 because "Entry No." is the whole primary key and must not collide with the guard's 1.
        ExpiredEntryCount := DataLogSubMgt.BatchSize() * 5 div 2;  // 2.5 batches
        InsertDataLogField(NonExpiringTableID, 1);
        for i := 1 to ExpiredEntryCount do
            InsertDataLogField(ExpiringTableID, i + 1);

        // [WHEN] Retention Policy is applied after 45 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(45));

        // [THEN] The entire expired backlog is deleted across all delete batches
        DataLogField.SetRange("Table ID", ExpiringTableID);
        Assert.IsTrue(DataLogField.IsEmpty(), 'All expired Data Log Field entries should be deleted, even when spanning multiple delete batches.');

        // [THEN] Non-expired entries of another table are preserved
        DataLogField.SetRange("Table ID", NonExpiringTableID);
        Assert.IsTrue(not DataLogField.IsEmpty(), 'Non-expired Data Log Field entries should be preserved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure DataLogRetentionPolicyDeletesExactMultipleOfBatchSize()
    // [SCENARIO] Data Log retention drains a backlog that is an exact multiple of the delete batch size, exercising the empty-FindSet loop exit
    var
        DataLogField: Record "NPR Data Log Field";
        RetentionPolicy: Record "NPR Retention Policy";
        DataLogSubMgt: Codeunit "NPR Data Log Sub. Mgt.";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        EntryNoBase: BigInteger;
        TableID: Integer;
        ExpiredEntryCount: Integer;
        i: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] Data Log Setup for a specific table ID
        TableID := Database::Customer;
        CreateDataLogSetup(TableID, JobQueueManagement.DaysToDuration(40));

        // [GIVEN] Exactly BatchSize expired entries, so the backlog is an exact multiple of the batch size and the
        // loop exits via its empty-FindSet branch (the partial-final-batch path is covered by the multi-batch test).
        // Entry No. values are seeded above 2^31 so the BigInteger boundary path is exercised at production
        // magnitudes - a boundary narrowed to Integer would pass small-value tests but fail mid-run in production.
        EntryNoBase := 2000000000; // < 2^31 (fits an Integer literal)...
        EntryNoBase += EntryNoBase; // ...doubled to 4,000,000,000 in BigInteger arithmetic
        ExpiredEntryCount := DataLogSubMgt.BatchSize();
        for i := 1 to ExpiredEntryCount do
            InsertDataLogField(TableID, EntryNoBase + i);

        // [WHEN] Retention Policy is applied after 45 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(45));

        // [THEN] The entire backlog is deleted
        DataLogField.SetRange("Table ID", TableID);
        Assert.IsTrue(DataLogField.IsEmpty(), 'All expired Data Log Field entries should be deleted when the backlog is an exact multiple of the batch size.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure ExceedingDataLogRetentionPolicy()
    // [SCENARIO] Application of Data Log Record retention policy on both table-specific and orphaned data log entries exceeding 90 day retention period
    var
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        TableID: Integer;
    begin
        // [GIVEN] Default Retention Policy for table "NPR Data Log Record"
        Initialize();
        InitializeDataLogData();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Data Log Record";
        RetentionPolicy.Insert();

        // [GIVEN] Data Log Setup for a specific table ID with a 100 day retention period
        TableID := Database::Customer;
        CreateDataLogSetup(TableID, JobQueueManagement.DaysToDuration(100));

        // [GIVEN] Data Log content
        InsertDataLogRecord(TableID, 1);
        InsertDataLogField(TableID, 1);
        InsertDataLogProcessingEntry(TableID, 1);

        // [GIVEN] Data Log content without a concrete table specified
        TableID := 0;
        InsertDataLogRecord(TableID, 2);
        InsertDataLogField(TableID, 2);
        InsertDataLogProcessingEntry(TableID, 2);


        // [WHEN] Retention Policy is applied after 95 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(95));

        // [THEN] Both table-specific and orphaned Data Log content is deleted
        DataLogRecord.SetRange("Table ID", TableID);
        Assert.IsTrue(DataLogRecord.IsEmpty(), 'Expired Data Log Record entries should be deleted.');

        DataLogField.SetRange("Table ID", TableID);
        Assert.IsTrue(DataLogField.IsEmpty(), 'Expired Data Log Field entries should be deleted.');

        DataLogProcessingEntry.SetRange("Table Number", TableID);
        Assert.IsTrue(DataLogProcessingEntry.IsEmpty(), 'Expired Data Log Processing entries should be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure NcTaskDefaultRetentionPolicy()
    // [SCENARIO] Application of a retention policy for "NPR Nc Task" table
    var
        NcTask: Record "NPR Nc Task";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
    begin
        // [GIVEN] Default Retention Policy for table "NPR Nc Task"
        Initialize();
        NcTask.DeleteAll(true);
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Nc Task";
        RetentionPolicy.Insert();

        // [GIVEN] "NPR Nc Task" records with various Processed and "Process Error" values
        InsertNcTaskRecord(1, false, false);
        InsertNcTaskRecord(2, true, false);
        InsertNcTaskRecord(3, false, true);
        InsertNcTaskRecord(4, true, true);

        // [WHEN] Retention Policy is applied after 15 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(15));

        // [THEN] The default retention policy is applied succesfully
        NcTask.SetRange("Entry No.", 1);
        Assert.IsTrue(not NcTask.IsEmpty(), 'NcTask with Processed = true & "Process Error" = true should not be deleted.');

        NcTask.SetRange("Entry No.", 2);
        Assert.IsTrue(NcTask.IsEmpty(), 'NcTask with Processed = true & "Process Error" = true should be deleted.');

        NcTask.SetRange("Entry No.", 3);
        Assert.IsTrue(not NcTask.IsEmpty(), 'NcTask with Processed = true & "Process Error" = true should not be deleted.');

        NcTask.SetRange("Entry No.", 4);
        Assert.IsTrue(NcTask.IsEmpty(), 'NcTask with Processed = true & "Process Error" = true should be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure NcKitchenOrdertRetentionPolicy()
    // [SCENARIO] Application of a retention policy for "NPR NPRE Kitchen Order" table
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
    begin
        // [GIVEN] Default Retention Policy for table "NPR NPRE Kitchen Order"
        Initialize();
        KitchenOrder.DeleteAll(true);
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR NPRE Kitchen Order";
        RetentionPolicy.Insert();

        // [GIVEN] "NPR NPRE Kitchen Order" records with various "On Hold" and "Order Status" values
        InsertKitchenOrderRecord(1, true, KitchenOrder."Order Status"::Finished);

        InsertKitchenOrderRecord(2, false, KitchenOrder."Order Status"::"Ready for Serving");
        InsertKitchenOrderRecord(3, false, KitchenOrder."Order Status"::Planned);

        InsertKitchenOrderRecord(4, false, KitchenOrder."Order Status"::Finished);
        InsertKitchenOrderRecord(5, false, KitchenOrder."Order Status"::Cancelled);

        InsertKitchenOrderRecord(6, false, KitchenOrder."Order Status"::"In-Production");
        InsertKitchenOrderRecord(7, false, KitchenOrder."Order Status"::Released);

        // [WHEN] Retention Policy is applied after 15 days
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime() + JobQueueManagement.DaysToDuration(15));

        // [THEN] The default retention policy is applied succesfully
        KitchenOrder.SetRange("Order ID", 1);
        Assert.IsTrue(not KitchenOrder.IsEmpty(), 'Kitchen Order with "On Hold" = true should never be deleted.');

        KitchenOrder.SetRange("Order ID", 2);
        Assert.IsTrue(not KitchenOrder.IsEmpty(), 'Kitchen Order with "On Hold" = false & "Order Status" = "Ready for Serving" should not be deleted.');

        KitchenOrder.SetRange("Order ID", 3);
        Assert.IsTrue(not KitchenOrder.IsEmpty(), 'Kitchen Order with "On Hold" = false & "Order Status" = "Planned" should not be deleted.');

        KitchenOrder.SetRange("Order ID", 4);
        Assert.IsTrue(KitchenOrder.IsEmpty(), 'Kitchen Order with "On Hold" = false & "Order Status" = "Finished" should be deleted.');

        KitchenOrder.SetRange("Order ID", 5);
        Assert.IsTrue(KitchenOrder.IsEmpty(), 'Kitchen Order with "On Hold" = false & "Order Status" = "Cancelled" should be deleted.');

        KitchenOrder.SetRange("Order ID", 6);
        Assert.IsTrue(not KitchenOrder.IsEmpty(), 'Kitchen Order with "Order Status" = "In-Production" should never be deleted.');

        KitchenOrder.SetRange("Order ID", 7);
        Assert.IsTrue(not KitchenOrder.IsEmpty(), 'Kitchen Order with "Order Status" = "Released" should never be deleted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::InheritFromTestCodeunit)]
    procedure IRLFiscalizationRetentionPolicy()
    // [SCENARIO] Application of retention policies for IRL Fiscalization affected tables
    var
        RetentionPolicy: Record "NPR Retention Policy";
        ExchangeLabelIRetentionPolicy: Interface "NPR IRetention Policy V2";
        NpGpPOSSalesEntryIRetentionPolicy: Interface "NPR IRetention Policy V2";
        TaxFreeVoucherIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSEntryIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSEntryTaxLineIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSPeriodRegisterIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSEntrySalesLineIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSEntryPaymentLineIRetentionPolicy: Interface "NPR IRetention Policy V2";
        POSBalancingLineIRetentionPolicy: Interface "NPR IRetention Policy V2";
        ReferenceDateTime: DateTime;
        ReferenceDate: Date;
    begin
        // [GIVEN] Default Retention Policies for IRL Fiscalization affected tables
        Initialize();
        SetupIRLFiscalization();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy.Insert();

        ExchangeLabelIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR Exchange Label";
        NpGpPOSSalesEntryIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR NpGp POS Sales Entry";
        TaxFreeVoucherIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR Tax Free Voucher";
        POSEntryIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Entry";
        POSEntryTaxLineIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Entry Tax Line";
        POSPeriodRegisterIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Period Register";
        POSEntrySalesLineIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Entry Sales Line";
        POSEntryPaymentLineIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Entry Payment Line";
        POSBalancingLineIRetentionPolicy := RetentionPolicy."Implementation V2"::"NPR POS Balancing Line";

        // [GIVEN] IRL Fiscalization affected table records
        InitializeIRLFiscalizationData();

        // [GIVEN] Expiring reference DateTime
        ReferenceDate := CalcDate('<+66M>', DT2Date(CurrentDateTime())); //5.5 years
        ReferenceDateTime := CreateDateTime(ReferenceDate, DT2Time(CurrentDateTime())) + JobQueueManagement.DaysToDuration(1);

        // [WHEN] Retention Policies are applied
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Exchange Label";
        RetentionPolicy.Modify();
        ExchangeLabelIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR NpGp POS Sales Entry";
        RetentionPolicy.Modify();
        NpGpPOSSalesEntryIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Tax Free Voucher";
        RetentionPolicy.Modify();
        TaxFreeVoucherIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Entry";
        RetentionPolicy.Modify();
        POSEntryIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Entry Tax Line";
        RetentionPolicy.Modify();
        POSEntryTaxLineIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Period Register";
        RetentionPolicy.Modify();
        POSPeriodRegisterIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Entry Sales Line";
        RetentionPolicy.Modify();
        POSEntrySalesLineIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Entry Payment Line";
        RetentionPolicy.Modify();
        POSEntryPaymentLineIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR POS Balancing Line";
        RetentionPolicy.Modify();
        POSBalancingLineIRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);

        // [THEN] Records are preserved
        Assert.TableIsNotEmpty(Database::"NPR Exchange Label");
        Assert.TableIsNotEmpty(Database::"NPR NpGp POS Sales Entry");
        Assert.TableIsNotEmpty(Database::"NPR Tax Free Voucher");
        Assert.TableIsNotEmpty(Database::"NPR POS Entry");
        Assert.TableIsNotEmpty(Database::"NPR POS Entry Tax Line");
        Assert.TableIsNotEmpty(Database::"NPR POS Period Register");
        Assert.TableIsNotEmpty(Database::"NPR POS Entry Sales Line");
        Assert.TableIsNotEmpty(Database::"NPR POS Entry Payment Line");
        Assert.TableIsNotEmpty(Database::"NPR POS Balancing Line");
    end;

    local procedure Initialize()
    var
        RetentionPolicy: Record "NPR Retention Policy";
        RetentionPolicyLogEntry: Record "NPR Retention Policy Log Entry";
    begin
        if Initialized then
            exit;

        RetentionPolicy.DeleteAll();
        RetentionPolicyLogEntry.DeleteAll();

        Initialized := true;
        Commit();
    end;

    local procedure InsertRetentionPolicyLogEntryRecord(EntryNo: Integer)
    var
        RetentionPolicyLogEntry: Record "NPR Retention Policy Log Entry";
    begin
        RetentionPolicyLogEntry.Init();
        RetentionPolicyLogEntry."Entry No." := EntryNo;
        RetentionPolicyLogEntry.Insert();
    end;

    local procedure InitializeDataLogData()
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogRecord: Record "NPR Data Log Record";
        DataLogField: Record "NPR Data Log Field";
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
    begin
        DataLogSetup.DeleteAll(true);
        DataLogRecord.DeleteAll();
        DataLogField.DeleteAll();
        DataLogProcessingEntry.DeleteAll();
    end;

    local procedure CreateDataLogSetup(TableID: Integer; KeepLogFor: Duration)
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
    begin
        DataLogSetup.Init();
        DataLogSetup."Table ID" := TableID;
        DataLogSetup."Keep Log for" := KeepLogFor;
        DataLogSetup.Insert();
    end;

    local procedure InsertDataLogRecord(TableID: Integer; EntryNo: BigInteger)
    var
        DataLogRecord: Record "NPR Data Log Record";
    begin
        DataLogRecord.Init();
        DataLogRecord."Entry No." := EntryNo;
        DataLogRecord."Table ID" := TableID;
        DataLogRecord.Insert();
    end;

    local procedure InsertDataLogField(TableID: Integer; EntryNo: BigInteger)
    var
        DataLogField: Record "NPR Data Log Field";
    begin
        DataLogField.Init();
        DataLogField."Entry No." := EntryNo;
        DataLogField."Table ID" := TableID;
        DataLogField."Log Date" := CurrentDateTime();
        DataLogField.Insert();
    end;

    local procedure InsertDataLogProcessingEntry(TableID: Integer; EntryNo: BigInteger)
    var
        DataLogProcessingEntry: Record "NPR Data Log Processing Entry";
    begin
        DataLogProcessingEntry.Init();
        DataLogProcessingEntry."Entry No." := EntryNo;
        DataLogProcessingEntry."Table Number" := TableID;
        DataLogProcessingEntry.Insert();
    end;

    local procedure InsertNcTaskRecord(EntryNo: Integer; Processed: Boolean; ProcessError: Boolean)
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := EntryNo;
        NcTask.Processed := Processed;
        NcTask."Process Error" := ProcessError;
        NcTask.Insert();
    end;

    local procedure InsertKitchenOrderRecord(OrderId: Integer; OnHold: Boolean; OrderStatus: Enum "NPR NPRE Kitchen Order Status")
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
        KitchenOrder.Init();
        KitchenOrder."Order ID" := OrderId;
        KitchenOrder."On Hold" := OnHold;
        KitchenOrder."Order Status" := OrderStatus;
        KitchenOrder.Insert();
    end;

    local procedure SetupIRLFiscalization()
    var
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
    begin
        IRLFiscalizationSetup.DeleteAll();
        IRLFiscalizationSetup.Init();
        IRLFiscalizationSetup."IRL Ret. Policy Extended" := true;
        IRLFiscalizationSetup.Insert();
    end;

    local procedure InitializeIRLFiscalizationData()
    var
        ExchangeLabel: Record "NPR Exchange Label";
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        POSEntry: Record "NPR POS Entry";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSBalancingLine: Record "NPR POS Balancing Line";
    begin
        ExchangeLabel.DeleteAll();
        NpGpPOSSalesEntry.DeleteAll();
        TaxFreeVoucher.DeleteAll();
        POSEntry.DeleteAll(true);
        POSEntryTaxLine.DeleteAll();
        POSPeriodRegister.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSBalancingLine.DeleteAll();

        ExchangeLabel.Init();
        ExchangeLabel."Batch No." := 1;
        ExchangeLabel.Insert();

        NpGpPOSSalesEntry.Init();
        NpGpPOSSalesEntry."Entry No." := 1;
        NpGpPOSSalesEntry.Insert();

        TaxFreeVoucher.Init();
        TaxFreeVoucher."Entry No." := 1;
        TaxFreeVoucher.Insert();

        POSEntry.Init();
        POSEntry."Entry No." := 1;
        POSEntry.Insert();

        POSEntryTaxLine.Init();
        POSEntryTaxLine."POS Entry No." := '1';
        POSEntryTaxLine.Insert();

        POSPeriodRegister.Init();
        POSPeriodRegister."No." := '1';
        POSPeriodRegister.Insert();

        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := '1';
        POSEntrySalesLine.Insert();

        POSEntryPaymentLine.Init();
        POSEntryPaymentLine."POS Entry No." := '1';
        POSEntryPaymentLine.Insert();

        POSBalancingLine.Init();
        POSBalancingLine."POS Entry No." := '1';
        POSBalancingLine.Insert();
    end;
}
#endif