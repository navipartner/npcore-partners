codeunit 85515 "NPR DE DSFINVK Export Tests"
{
    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit Assert;
        _Initialized: Boolean;
        _VATProdPostingGroupTxt: Label 'DSFVK-PROD', Locked = true;
        _VATBusPostingGroupTxt: Label 'DSFVK-BUS', Locked = true;
        _VATIdentifierTxt: Label 'DSFVK19', Locked = true;
        _POSUnitNoTxt: Label 'DSFVKTEST', Locked = true;
        _POSUnitATxt: Label 'DSFVKA', Locked = true;
        _POSUnitBTxt: Label 'DSFVKB', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineAmountsPerVatIdHoldOnlyThatLine()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        Lines: JsonArray;
        LineAmounts: List of [Decimal];
        LineAmountsPerVatId: JsonArray;
        LineToken: JsonToken;
        LineInclVatSum: Decimal;
        LineIndex: Integer;
    begin
        // [Scenario] A DE receipt with several sales lines is exported to DSFinV-K. Each line's
        //            business_case.amounts_per_vat_id maps to that line's Bonpos_USt record, so it
        //            must carry only that line's amounts - not a running total of the receipt.

        // [GIVEN] a fiscalized POS entry with three sales lines on the same VAT rate
        LineAmounts.Add(10);
        LineAmounts.Add(20);
        LineAmounts.Add(30);
        CreateFiscalizedPOSEntry(DSFINVKClosing, LineAmounts);

        // [WHEN] the DSFinV-K cash point closing document is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] each line has exactly one VAT entry holding that line's own gross amount
        Lines := GetSingleTransactionData(DSFINVKJson).GetArray('lines');
        _Assert.AreEqual(LineAmounts.Count(), Lines.Count(), 'One DSFinV-K line per sales line expected.');
        for LineIndex := 1 to Lines.Count() do begin
            Lines.Get(LineIndex - 1, LineToken);
            LineAmountsPerVatId := LineToken.AsObject().GetObject('business_case').GetArray('amounts_per_vat_id');
            _Assert.AreEqual(1, LineAmountsPerVatId.Count(), StrSubstNo('Line %1 must carry only its own VAT entry.', LineIndex));
            _Assert.AreEqual(LineAmounts.Get(LineIndex), GetInclVat(LineAmountsPerVatId, 0), StrSubstNo('Line %1 incl_vat must equal its own amount.', LineIndex));
            LineInclVatSum += GetInclVat(LineAmountsPerVatId, 0);
        end;

        // [THEN] the line amounts reconcile with the transaction's VAT breakdown
        _Assert.AreEqual(GetInclVat(GetSingleTransactionData(DSFINVKJson).GetArray('amounts_per_vat_id'), 0), LineInclVatSum, 'Sum of line incl_vat must equal the transaction incl_vat.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosingExcludesOtherPOSUnitTransactions()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        ExportIds: List of [Text];
        ClosingDate: Date;
    begin
        // [Scenario] Two German POS units sell on the same day and unit A runs its Z-report.
        //            A Cash Point Closing belongs to one cash register (client_id), so unit B's
        //            receipt must not be reported in unit A's closing.

        // [GIVEN] one fiscalized sale on unit A and one on unit B on the same day
        ClosingDate := DMY2Date(16, 3, 2003);
        ResetPOSUnit(_POSUnitATxt);
        ResetPOSUnit(_POSUnitBTxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A1', 10);
        InsertFiscalizedEntry(_POSUnitBTxt, ClosingDate, 'DSFVK-B1', 20);

        // [GIVEN] unit A's Z-report closing
        InitClosing(DSFINVKClosing, _POSUnitATxt, ClosingDate, InsertZReport(_POSUnitATxt, ClosingDate));

        // [WHEN] the DSFinV-K cash point closing document is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] only unit A's receipt is reported, and the head range spans only that receipt
        ExportIds := GetTransactionExportIds(DSFINVKJson);
        _Assert.AreEqual(1, ExportIds.Count(), 'Only the closing unit''s transaction may be exported.');
        _Assert.AreEqual('DSFVK-A1', ExportIds.Get(1), 'Wrong transaction exported.');
        _Assert.AreEqual('DSFVK-A1', GetHeadText(DSFINVKJson, 'first_transaction_export_id'), 'first_transaction_export_id must belong to the closing unit.');
        _Assert.AreEqual('DSFVK-A1', GetHeadText(DSFINVKJson, 'last_transaction_export_id'), 'last_transaction_export_id must belong to the closing unit.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosingCoversTransactionsSincePreviousZReport()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        ExportIds: List of [Text];
        FirstDay: Date;
        SecondDay: Date;
    begin
        // [Scenario] A Cash Point Closing covers every receipt since the register's previous
        //            closing - also when the shift runs past midnight - and nothing before it.

        // [GIVEN] a sale closed by an earlier Z-report on day 1
        FirstDay := DMY2Date(17, 3, 2003);
        SecondDay := FirstDay + 1;
        ResetPOSUnit(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, FirstDay, 'DSFVK-A1', 10);
        InsertZReport(_POSUnitATxt, FirstDay);

        // [GIVEN] a late sale on day 1 and a sale after midnight, then the next Z-report on day 2
        InsertFiscalizedEntry(_POSUnitATxt, FirstDay, 'DSFVK-A2', 20);
        InsertFiscalizedEntry(_POSUnitATxt, SecondDay, 'DSFVK-A3', 30);
        InitClosing(DSFINVKClosing, _POSUnitATxt, SecondDay, InsertZReport(_POSUnitATxt, SecondDay));

        // [WHEN] the DSFinV-K cash point closing document for the second Z-report is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] exactly the two receipts after the previous Z-report are reported
        ExportIds := GetTransactionExportIds(DSFINVKJson);
        _Assert.AreEqual(2, ExportIds.Count(), 'The closing must hold every receipt since the previous Z-report.');
        _Assert.AreEqual('DSFVK-A2', ExportIds.Get(1), 'First transaction of the closing is wrong.');
        _Assert.AreEqual('DSFVK-A3', ExportIds.Get(2), 'Last transaction of the closing is wrong.');
        _Assert.AreEqual('DSFVK-A2', GetHeadText(DSFINVKJson, 'first_transaction_export_id'), 'first_transaction_export_id is wrong.');
        _Assert.AreEqual('DSFVK-A3', GetHeadText(DSFINVKJson, 'last_transaction_export_id'), 'last_transaction_export_id is wrong.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosingIgnoresCancelledZReport()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        ExportIds: List of [Text];
        ClosingDate: Date;
    begin
        // [Scenario] A Z-report is started and cancelled between two real Z-reports. The cancelled
        //            one leaves an open ZREPORT checkpoint without a balancing entry. It is not a
        //            closing, so the next closing must still start after the previous real Z-report
        //            and must not re-report receipts that an earlier closing already covered.

        // [GIVEN] a sale closed by a real Z-report
        ClosingDate := DMY2Date(23, 3, 2003);
        ResetPOSUnit(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A1', 10);
        InsertZReport(_POSUnitATxt, ClosingDate);

        // [GIVEN] a sale, a cancelled Z-report, another sale and the next real Z-report
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A2', 20);
        InsertCancelledZReport(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A3', 30);
        InitClosing(DSFINVKClosing, _POSUnitATxt, ClosingDate, InsertZReport(_POSUnitATxt, ClosingDate));

        // [WHEN] the DSFinV-K cash point closing document for the last Z-report is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] exactly the receipts after the previous real Z-report are reported
        ExportIds := GetTransactionExportIds(DSFINVKJson);
        _Assert.AreEqual(2, ExportIds.Count(), 'A cancelled Z-report must not move the start of the closing.');
        _Assert.AreEqual('DSFVK-A2', ExportIds.Get(1), 'First transaction of the closing is wrong.');
        _Assert.AreEqual('DSFVK-A3', ExportIds.Get(2), 'Last transaction of the closing is wrong.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosingIgnoresZReportCheckpointWithoutBalancingEntry()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        ExportIds: List of [Text];
        ClosingDate: Date;
    begin
        // [Scenario] Setting a payment bin float (and the first-time checkpoint) inserts a closed
        //            ZREPORT checkpoint with POS Entry No. 0. It does not close any receipts, so
        //            the next closing must still start after the previous real Z-report instead
        //            of re-reporting the register's whole history.

        // [GIVEN] a sale closed by a real Z-report
        ClosingDate := DMY2Date(26, 3, 2003);
        ResetPOSUnit(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A1', 10);
        InsertZReport(_POSUnitATxt, ClosingDate);

        // [GIVEN] a sale, a bin float checkpoint, another sale and the next real Z-report
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A2', 20);
        InsertZReportCheckpointWithoutBalancingEntry(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A3', 30);
        InitClosing(DSFINVKClosing, _POSUnitATxt, ClosingDate, InsertZReport(_POSUnitATxt, ClosingDate));

        // [WHEN] the DSFinV-K cash point closing document for the last Z-report is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] exactly the receipts after the previous real Z-report are reported
        ExportIds := GetTransactionExportIds(DSFINVKJson);
        _Assert.AreEqual(2, ExportIds.Count(), 'A checkpoint without a balancing entry must not move the start of the closing.');
        _Assert.AreEqual('DSFVK-A2', ExportIds.Get(1), 'First transaction of the closing is wrong.');
        _Assert.AreEqual('DSFVK-A3', ExportIds.Get(2), 'Last transaction of the closing is wrong.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosingHeadCarriesBusinessDate()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEFiskalyDSFINVK: Codeunit "NPR DE Fiskaly DSFINVK";
        DSFINVKJson: JsonObject;
        ClosingDate: Date;
    begin
        // [Scenario] fiskaly exports "by business date" fall back to the submission date when
        //            head.business_date is missing, so the closing must state its business day.

        // [GIVEN] a Z-report closing with one sale
        ClosingDate := DMY2Date(19, 3, 2003);
        ResetPOSUnit(_POSUnitATxt);
        InsertFiscalizedEntry(_POSUnitATxt, ClosingDate, 'DSFVK-A1', 10);
        InitClosing(DSFINVKClosing, _POSUnitATxt, ClosingDate, InsertZReport(_POSUnitATxt, ClosingDate));

        // [WHEN] the DSFinV-K cash point closing document is created
        _Assert.IsTrue(DEFiskalyDSFINVK.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing), GetLastErrorText());

        // [THEN] head.business_date is the closing date
        _Assert.AreEqual(Format(ClosingDate, 0, 9), GetHeadText(DSFINVKJson, 'business_date'), 'head.business_date must be the closing date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ZReportClosingDateComesFromBalancingEntry()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        BusinessDate: Date;
        ZReportEntryNo: Integer;
    begin
        // [Scenario] The operator's WorkDate differs from the day the Z-report is posted on.
        //            The closing must be stamped with the posted business day, not the WorkDate.
        Initialize();

        // [GIVEN] a Z-report balancing entry posted on the business day, and a WorkDate one day later
        BusinessDate := DMY2Date(20, 3, 2003);
        ZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);
        WorkDate(BusinessDate + 1);

        // [WHEN] the DE end-of-workshift handling runs for the Z-report
        DEAuditMgt.DoEndWorkshiftDeFiscaly(_POSUnit."No.", true, ZReportEntryNo);
        WorkDate(Today());

        // [THEN] the closing carries the balancing entry's date
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        DSFINVKClosing.SetRange("POS Entry No.", ZReportEntryNo);
        _Assert.IsTrue(DSFINVKClosing.FindFirst(), 'A DSFinV-K closing must exist for the Z-report.');
        _Assert.AreEqual(BusinessDate, DSFINVKClosing."Closing Date", 'Closing Date must be the Z-report''s business day.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SecondZReportOnSameDayGetsItsOwnClosing()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        BusinessDate: Date;
        FirstZReportEntryNo: Integer;
        SecondZReportEntryNo: Integer;
    begin
        // [Scenario] A register runs two Z-reports on one day. Each Z-report is a Cash Point
        //            Closing with its own consecutive number, otherwise the receipts between
        //            them never reach any closing.
        Initialize();

        // [GIVEN] two Z-reports on the same day
        BusinessDate := DMY2Date(21, 3, 2003);
        WorkDate(BusinessDate);
        FirstZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);
        DEAuditMgt.DoEndWorkshiftDeFiscaly(_POSUnit."No.", true, FirstZReportEntryNo);

        // [WHEN] the second Z-report is handled
        SecondZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);
        DEAuditMgt.DoEndWorkshiftDeFiscaly(_POSUnit."No.", true, SecondZReportEntryNo);
        WorkDate(Today());

        // [THEN] each Z-report has its own closing, numbered consecutively
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        _Assert.AreEqual(2, DSFINVKClosing.Count(), 'Each Z-report must create its own DSFinV-K closing.');
        DSFINVKClosing.SetRange("POS Entry No.", SecondZReportEntryNo);
        _Assert.IsTrue(DSFINVKClosing.FindFirst(), 'The second Z-report must have a closing.');
        _Assert.AreEqual(2, DSFINVKClosing."DSFINVK Closing No.", 'The second closing must be number 2.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JobParameterStringCreatesClosingForRequestedUnitAndDate()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        JobQueueEntry: Record "Job Queue Entry";
        BusinessDate: Date;
        ZReportEntryNo: Integer;
    begin
        // [Scenario] The DSFinV-K job is started with the parameter "<POS unit>;<date>" to create
        //            a missing closing. The closing must be for that unit and that date.
        Initialize();

        // [GIVEN] a Z-report on the requested day and a WorkDate on a different day
        BusinessDate := DMY2Date(22, 3, 2003);
        ZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);
        WorkDate(BusinessDate + 1);

        // [WHEN] the job runs with the unit and date as parameter
        JobQueueEntry."Parameter String" := StrSubstNo('%1;%2', _POSUnit."No.", Format(BusinessDate));
        Codeunit.Run(Codeunit::"NPR DE Fiskaly DSFINVK Job", JobQueueEntry);
        WorkDate(Today());

        // [THEN] the closing is for the requested unit, Z-report and date
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        _Assert.IsTrue(DSFINVKClosing.FindFirst(), 'The job must create a closing for the requested POS unit.');
        _Assert.AreEqual(ZReportEntryNo, DSFINVKClosing."POS Entry No.", 'The closing must point at the Z-report balancing entry.');
        _Assert.AreEqual(BusinessDate, DSFINVKClosing."Closing Date", 'The closing must be for the requested date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JobParameterStringClosesZReportNotXReport()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        JobQueueEntry: Record "Job Queue Entry";
        BusinessDate: Date;
        ZReportEntryNo: Integer;
    begin
        // [Scenario] An X-report also posts a Balancing entry. The closing is bounded by its POS
        //            Entry No., so the job must bound it by the Z-report, otherwise the sales after
        //            the X-report fall out of the closing.
        Initialize();

        // [GIVEN] an X-report and then a Z-report on the requested day
        BusinessDate := DMY2Date(24, 3, 2003);
        InsertXReport(_POSUnit."No.", BusinessDate);
        ZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);

        // [WHEN] the job runs with the unit and date as parameter
        JobQueueEntry."Parameter String" := StrSubstNo('%1;%2', _POSUnit."No.", Format(BusinessDate));
        Codeunit.Run(Codeunit::"NPR DE Fiskaly DSFINVK Job", JobQueueEntry);

        // [THEN] the only closing points at the Z-report balancing entry
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        _Assert.AreEqual(1, DSFINVKClosing.Count(), 'The X-report must not get a closing of its own.');
        DSFINVKClosing.FindFirst();
        _Assert.AreEqual(ZReportEntryNo, DSFINVKClosing."POS Entry No.", 'The closing must point at the Z-report balancing entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JobParameterStringCreatesMissingClosingForSecondZReport()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        JobQueueEntry: Record "Job Queue Entry";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        BusinessDate: Date;
        SecondZReportEntryNo: Integer;
    begin
        // [Scenario] A register runs two Z-reports on one day, and only the first one got its
        //            closing. Running the job for that day must create the missing closing instead
        //            of stopping at the first closing it finds for the date.
        Initialize();

        // [GIVEN] two Z-reports on the same day, only the first one has a closing
        BusinessDate := DMY2Date(25, 3, 2003);
        DEAuditMgt.DoEndWorkshiftDeFiscaly(_POSUnit."No.", true, InsertZReport(_POSUnit."No.", BusinessDate));
        SecondZReportEntryNo := InsertZReport(_POSUnit."No.", BusinessDate);

        // [WHEN] the job runs with the unit and date as parameter
        JobQueueEntry."Parameter String" := StrSubstNo('%1;%2', _POSUnit."No.", Format(BusinessDate));
        Codeunit.Run(Codeunit::"NPR DE Fiskaly DSFINVK Job", JobQueueEntry);

        // [THEN] the second Z-report has its own closing
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        _Assert.AreEqual(2, DSFINVKClosing.Count(), 'The job must create the missing closing of the second Z-report.');
        DSFINVKClosing.SetRange("POS Entry No.", SecondZReportEntryNo);
        _Assert.IsTrue(DSFINVKClosing.FindFirst(), 'The second Z-report must have a closing.');
        _Assert.AreEqual(2, DSFINVKClosing."DSFINVK Closing No.", 'The second closing must be number 2.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JobParameterStringWithoutZReportCreatesNoClosing()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        JobQueueEntry: Record "Job Queue Entry";
        BusinessDate: Date;
    begin
        // [Scenario] The job is run for a day on which the register sold but ran no Z-report,
        //            e.g. a shift running past midnight. Those receipts belong to the next
        //            Z-report's closing, so a closing for the day would report them twice.
        Initialize();

        // [GIVEN] a sale on the requested day and no Z-report
        BusinessDate := DMY2Date(27, 3, 2003);
        InsertFiscalizedEntry(_POSUnit."No.", BusinessDate, 'DSFVK-J1', 10);

        // [WHEN] the job runs with the unit and date as parameter
        JobQueueEntry."Parameter String" := StrSubstNo('%1;%2', _POSUnit."No.", Format(BusinessDate));
        Codeunit.Run(Codeunit::"NPR DE Fiskaly DSFINVK Job", JobQueueEntry);

        // [THEN] no closing is created
        DSFINVKClosing.SetRange("POS Unit No.", _POSUnit."No.");
        _Assert.RecordIsEmpty(DSFINVKClosing);
    end;

    local procedure Initialize()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        LibraryDEFiscal: Codeunit "NPR Library DE Fiscal";
    begin
        if not _Initialized then begin
            LibraryDEFiscal.CreatePOSUnit(_POSUnit, POSStore, POSPostingProfile);
            LibraryDEFiscal.CreateAuditProfileSetup(POSAuditProfile, _POSUnit);
            _Initialized := true;
        end;

        ResetPOSUnit(_POSUnit."No.");
        Commit();
    end;

    local procedure ResetPOSUnit(POSUnitNo: Code[10])
    var
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSEntry.SetRange("POS Unit No.", POSUnitNo);
        POSEntry.DeleteAll();
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", POSUnitNo);
        POSWorkshiftCheckpoint.DeleteAll();
        DSFINVKClosing.SetRange("POS Unit No.", POSUnitNo);
        DSFINVKClosing.DeleteAll();

        if not DEPOSUnitAuxInfo.Get(POSUnitNo) then begin
            DEPOSUnitAuxInfo.Init();
            DEPOSUnitAuxInfo."POS Unit No." := POSUnitNo;
            DEPOSUnitAuxInfo.Insert();
        end;
    end;

    local procedure InitClosing(var DSFINVKClosing: Record "NPR DSFINVK Closing"; POSUnitNo: Code[10]; ClosingDate: Date; ZReportEntryNo: Integer)
    begin
        DSFINVKClosing.Init();
        DSFINVKClosing."DSFINVK Closing No." := 1;
        DSFINVKClosing."POS Unit No." := POSUnitNo;
        DSFINVKClosing."Closing Date" := ClosingDate;
        DSFINVKClosing."POS Entry No." := ZReportEntryNo;
    end;

    local procedure InsertZReport(POSUnitNo: Code[10]; EntryDate: Date): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSEntry.Init();
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Entry Date" := EntryDate;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
        POSEntry.Insert();

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint."Created At" := CreateDateTime(EntryDate, 220000T);
        POSWorkshiftCheckpoint.Insert();

        exit(POSEntry."Entry No.");
    end;

    local procedure InsertXReport(POSUnitNo: Code[10]; EntryDate: Date)
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSEntry.Init();
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Entry Date" := EntryDate;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
        POSEntry.Insert();

        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint."Created At" := CreateDateTime(EntryDate, 120000T);
        POSWorkshiftCheckpoint.Insert();
    end;

    local procedure InsertCancelledZReport(POSUnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint.Open := true;
        POSWorkshiftCheckpoint.Insert();
    end;

    local procedure InsertZReportCheckpointWithoutBalancingEntry(POSUnitNo: Code[10])
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := POSUnitNo;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint."POS Entry No." := 0;
        POSWorkshiftCheckpoint.Insert();
    end;

    local procedure InsertFiscalizedEntry(POSUnitNo: Code[10]; EntryDate: Date; FiscalNo: Code[20]; Amount: Decimal)
    var
        LineAmounts: List of [Decimal];
    begin
        LineAmounts.Add(Amount);
        InsertFiscalizedEntry(POSUnitNo, EntryDate, FiscalNo, LineAmounts);
    end;

    local procedure InsertFiscalizedEntry(POSUnitNo: Code[10]; EntryDate: Date; FiscalNo: Code[20]; LineAmounts: List of [Decimal])
    var
        DEAuditLog: Record "NPR DE POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        LineAmount: Decimal;
        TotalAmount: Decimal;
        LineNo: Integer;
    begin
        EnsureVATMapper();

        foreach LineAmount in LineAmounts do
            TotalAmount += LineAmount;

        POSEntry.Init();
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Entry Date" := EntryDate;
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."Fiscal No." := FiscalNo;
        POSEntry."Amount Incl. Tax" := TotalAmount;
        POSEntry.Insert();

        DEAuditLog.Init();
        DEAuditLog."POS Entry No." := POSEntry."Entry No.";
        DEAuditLog."Transaction ID" := CreateGuid();
        DEAuditLog."Client ID" := CreateGuid();
        DEAuditLog."Start Time" := CreateDateTime(EntryDate, 100000T);
        DEAuditLog."Finish Time" := CreateDateTime(EntryDate, 100100T);
        DEAuditLog.Insert();

        foreach LineAmount in LineAmounts do begin
            LineNo += 10000;
            POSEntrySalesLine.Init();
            POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
            POSEntrySalesLine."Line No." := LineNo;
            POSEntrySalesLine.Type := POSEntrySalesLine.Type::Item;
            POSEntrySalesLine."No." := 'DSFVK-ITEM';
            POSEntrySalesLine.Quantity := 1;
            POSEntrySalesLine."Unit Price" := LineAmount;
            POSEntrySalesLine."VAT Prod. Posting Group" := _VATProdPostingGroupTxt;
            POSEntrySalesLine."VAT Bus. Posting Group" := _VATBusPostingGroupTxt;
            POSEntrySalesLine."Amount Incl. VAT (LCY)" := LineAmount;
            POSEntrySalesLine."Amount Excl. VAT (LCY)" := Round(LineAmount / 1.19);
            POSEntrySalesLine.Insert();
        end;

        POSEntryTaxLine.Init();
        POSEntryTaxLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryTaxLine."VAT Identifier" := _VATIdentifierTxt;
        POSEntryTaxLine."Amount Including Tax" := TotalAmount;
        POSEntryTaxLine."Tax Base Amount" := Round(TotalAmount / 1.19);
        POSEntryTaxLine."Tax Amount" := TotalAmount - POSEntryTaxLine."Tax Base Amount";
        POSEntryTaxLine.Insert();
    end;

    local procedure EnsureVATMapper()
    var
        VATPostGroupMapper: Record "NPR VAT Post. Group Mapper";
    begin
        if not VATPostGroupMapper.Get(_VATProdPostingGroupTxt, _VATBusPostingGroupTxt) then begin
            VATPostGroupMapper.Init();
            VATPostGroupMapper."VAT Prod. Pos. Group" := _VATProdPostingGroupTxt;
            VATPostGroupMapper."VAT Bus. Posting Group" := _VATBusPostingGroupTxt;
            VATPostGroupMapper.Insert();
        end;
        VATPostGroupMapper."VAT Identifier" := _VATIdentifierTxt;
        VATPostGroupMapper."DSFINVK ID" := 1;
        VATPostGroupMapper.Modify();
    end;

    local procedure CreateFiscalizedPOSEntry(var DSFINVKClosing: Record "NPR DSFINVK Closing"; LineAmounts: List of [Decimal])
    var
        ClosingDate: Date;
    begin
        // A closing without a Z-report entry is scoped by its POS unit and date.
        ClosingDate := DMY2Date(15, 3, 2003);
        ResetPOSUnit(_POSUnitNoTxt);
        InsertFiscalizedEntry(_POSUnitNoTxt, ClosingDate, 'DSFVK-0001', LineAmounts);
        InitClosing(DSFINVKClosing, _POSUnitNoTxt, ClosingDate, 0);
    end;

    local procedure GetTransactionExportIds(DSFINVKJson: JsonObject) ExportIds: List of [Text]
    var
        TransactionToken: JsonToken;
    begin
        foreach TransactionToken in DSFINVKJson.GetArray('transactions') do
            ExportIds.Add(TransactionToken.AsObject().GetObject('head').GetText('transaction_export_id'));
    end;

    local procedure GetHeadText(DSFINVKJson: JsonObject; PropertyName: Text): Text
    var
        HeadToken: JsonToken;
        PropertyToken: JsonToken;
    begin
        DSFINVKJson.Get('head', HeadToken);
        _Assert.IsTrue(HeadToken.AsObject().Get(PropertyName, PropertyToken), StrSubstNo('head.%1 is missing.', PropertyName));
        exit(PropertyToken.AsValue().AsText());
    end;

    local procedure GetSingleTransactionData(DSFINVKJson: JsonObject): JsonObject
    var
        Transactions: JsonArray;
        TransactionToken: JsonToken;
    begin
        Transactions := DSFINVKJson.GetArray('transactions');
        _Assert.AreEqual(1, Transactions.Count(), 'Exactly one exported transaction expected.');
        Transactions.Get(0, TransactionToken);
        exit(TransactionToken.AsObject().GetObject('data'));
    end;

    local procedure GetInclVat(AmountsPerVatId: JsonArray; Index: Integer) InclVat: Decimal
    var
        AmountToken: JsonToken;
    begin
        AmountsPerVatId.Get(Index, AmountToken);
        Evaluate(InclVat, AmountToken.AsObject().GetText('incl_vat'), 9);
    end;
}
