codeunit 85491 "NPR SE CC Cash Reg. Exp. Tests"
{
    // [FEATURE] SKVFS 2021:16 journal export (COM-1503). Every test builds its own POS unit, so the export only sees that test's data.
    Subtype = Test;

    var
        _CleanCashSetup: Record "NPR CleanCash Setup";
        _Item: Record Item;
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit Assert;
        _LibrarySEJournalSchema: Codeunit "NPR Library SE Journal Schema";
        _ControlUnitId: Text[20];
        _SalespersonCode: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportedJournalValidatesAgainstSkatteverketSchema()
    var
        OriginalReceipt: Record "NPR CleanCash Trans. Request";
        ReturnReceipt: Record "NPR CleanCash Trans. Request";
        TrainingReceipt: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] A journal with every exported event type is valid against the official XSD
        Initialize();

        // [GIVEN] Sign-in, sale, return, receipt copy, training receipt, parked sale, X report, sign-out and Z report on one POS unit
        CreateAuditLogEntry(true, AtToday(075500T));
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080503T), '101', 2, 617.25, OriginalReceipt);
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterReturnReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(090000T), '102', -1, 617.25, ReturnReceipt);
        CreateReceiptCopy(OriginalReceipt, AtToday(093000T), '103');
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::ovning, AtToday(100000T), '104', 1, 100, TrainingReceipt);
        CreateParkedSale(AtToday(103000T), 125);
        CreateWorkshiftCheckpoint(false, AtToday(110000T), TrainingReceipt."POS Entry No." + 1);
        CreateAuditLogEntry(false, AtToday(113000T));
        CreateWorkshiftCheckpoint(true, AtToday(120000T), TrainingReceipt."POS Entry No." + 2);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The file validates against the Skatteverket schema
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SchemaValidationRejectsIncompleteJournal()
    var
        Document: XmlDocument;
    begin
        // [SCENARIO] The embedded schema actually checks content: a correctly namespaced journal without RegistreringLISTA is rejected

        // [GIVEN] A journal in the schema namespace that lacks required elements
        XmlDocument.ReadFrom(
            '<utrein:ExportAvDataFranJournalminneEnligtSKVFS2021-16 xmlns:utrein="' + _LibrarySEJournalSchema.InstansNamespace() + '" xmlns:utreko="' + _LibrarySEJournalSchema.KomponentNamespace() + '">' +
            '<utreko:BeteckningPaDetKassaregisterSomExportAvDataFranJournalminnetSkerIfran>01</utreko:BeteckningPaDetKassaregisterSomExportAvDataFranJournalminnetSkerIfran>' +
            '</utrein:ExportAvDataFranJournalminneEnligtSKVFS2021-16>', Document);

        // [WHEN] It is validated
        asserterror _LibrarySEJournalSchema.AssertMatchesSchema(Document);

        // [THEN] Validation fails and names the missing element
        _Assert.ExpectedError('TidpunktForNarExportAvDataFranJournalminnetSker');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptsAreExportedAsEventsInRegistreringLISTA()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] Receipts are events in RegistreringLISTA, not children of the Kassaregistersystemet header

        // [GIVEN] One sales receipt
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '201', 1, 100, CleanCashTransRequest);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The receipt is a Handelse with the register and the salesperson
        _Assert.AreEqual(1, CountNodes(Document, '/in:ExportAvDataFranJournalminneEnligtSKVFS2021-16/ko:RegistreringLISTA/ko:Handelse/ko:Kassakvitto'), 'Receipt must be a Handelse in RegistreringLISTA');
        _Assert.AreEqual(0, CountNodes(Document, '//ko:Kassaregistersystemet/ko:Kassakvitto'), 'Receipt must not be nested in Kassaregistersystemet');
        _Assert.AreEqual(_POSUnit."No.", NodeText(Document, '//ko:Handelse/ko:Kassabeteckning'), 'Kassabeteckning');
        _Assert.AreEqual(_SalespersonCode, NodeText(Document, '//ko:Handelse/ko:InloggadAnvandare'), 'InloggadAnvandare');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EventsAreExportedInChronologicalOrder()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
        NodeList: XmlNodeList;
        Node: XmlNode;
        PreviousTime: Text;
        CurrentTime: Text;
    begin
        // [SCENARIO] Events are ordered by registration time, not grouped by event type

        // [GIVEN] A receipt created before a sign-in that happened earlier in the day
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(100000T), '301', 1, 100, CleanCashTransRequest);
        CreateAuditLogEntry(true, AtToday(080000T));

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The sign-in comes first and times never go backwards
        SelectNodes(Document, '//ko:Handelse', NodeList);
        _Assert.AreEqual(2, NodeList.Count(), 'Number of events');
        NodeList.Get(1, Node);
        _Assert.AreEqual(1, CountNodes(Node, 'ko:InloggningIKassaregister'), 'First event must be the sign-in');
        foreach Node in NodeList do begin
            CurrentTime := NodeText(Node, 'ko:Registreringstidpunkt');
            _Assert.IsTrue(CurrentTime >= PreviousTime, StrSubstNo('Event at %1 is exported after %2', CurrentTime, PreviousTime));
            PreviousTime := CurrentTime;
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptCarriesControlUnitIdAndControlCode()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] COM-1505: the CleanCash unit id is the control unit number and the CleanCash code is the Kontrollkod

        // [GIVEN] A receipt confirmed by the CleanCash control unit
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '401', 1, 100, CleanCashTransRequest);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] Only the control unit alternatives are exported, with the right CleanCash values
        _Assert.AreEqual(_ControlUnitId, NodeText(Document, '//ko:Kassakvitto/ko:TillverkningsnummerForKontrollenheten'), 'TillverkningsnummerForKontrollenheten');
        _Assert.AreEqual(CleanCashTransRequest."CleanCash Code", NodeText(Document, '//ko:Kassakvitto/ko:Kontrollkod'), 'Kontrollkod');
        _Assert.AreEqual(0, CountNodes(Document, '//ko:Kassakvitto/ko:TillverkningsnummerForKontrollsystemet'), 'Only one of the control unit/control system alternatives may be exported');
        _Assert.AreEqual(0, CountNodes(Document, '//ko:Kassakvitto/ko:Avstamningskod'), 'Only one of the control code alternatives may be exported');
        _Assert.AreEqual(_ControlUnitId, NodeText(Document, '//ko:Kassaregistersystemet/ko:TillverkningsnummerForKontrollenheten'), 'Control unit on the cash register system');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TimestampsAndAmountsUseXmlSchemaFormats()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] Timestamps are xs:dateTime without fractions or zone, amounts are xs:decimal, both independent of the user's locale

        // [GIVEN] A receipt at 08:05:03 with a four-digit amount
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080503T), '501', 1, 1234.5, CleanCashTransRequest);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The values use the XML schema formats
        _Assert.AreEqual(Format(Today(), 0, '<Year4>-<Month,2>-<Day,2>') + 'T08:05:03', NodeText(Document, '//ko:Kassakvitto/ko:DatumOchKlockslagNarKvittoFramstalls'), 'Receipt timestamp');
        _Assert.AreEqual('1234.5', NodeText(Document, '//ko:Kassakvitto/ko:TotaltForsaljningsbeloppISvenskaKronor'), 'Receipt total');
        _Assert.AreEqual('25', NodeText(Document, '//ko:SaldArtikel/ko:MervardesskattesatsForSaldArtikel'), 'VAT rate');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptOnLastMinuteOfEndDateIsExported()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] COM-1345: the selected end date is included up to 23:59:59

        // [GIVEN] A receipt at 23:59 on the end date
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(235900T), '601', 1, 100, CleanCashTransRequest);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The receipt is included and the period ends at 23:59:59
        _Assert.AreEqual(1, CountNodes(Document, '//ko:Kassakvitto'), 'Receipt at 23:59 on the end date');
        _Assert.AreEqual(Format(Today(), 0, '<Year4>-<Month,2>-<Day,2>') + 'T23:59:59', NodeText(Document, '//ko:ValdSluttidpunktForExportAvDataFranJournalminnet'), 'Period end');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptReferencesTheZReportThatClosesIt()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        ZReport: Record "NPR POS Workshift Checkpoint";
        Document: XmlDocument;
    begin
        // [SCENARIO] The receipt's Z report number is the number of the Z report that closes its period, as printed on that report

        // [GIVEN] A receipt and the Z report that closes the day
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '701', 1, 100, CleanCashTransRequest);
        ZReport := CreateWorkshiftCheckpoint(true, AtToday(200000T), CleanCashTransRequest."POS Entry No." + 1);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The receipt and the Z report carry the same number
        _Assert.AreEqual(Format(ZReport."Entry No."), NodeText(Document, '//ko:Kassakvitto/ko:LopnummerForZDagrapportPaKvitto'), 'Z report number on the receipt');
        _Assert.AreEqual(Format(ZReport."Entry No."), NodeText(Document, '//ko:ZDagrapport/ko:LopnummerForZDagrapport'), 'Z report number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UncompletedZReportsAreNotExported()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] Only completed Z reports are exported. The first-start placeholder and a cancelled End of Day have no POS entry.

        // [GIVEN] The placeholder Z report of a new register, a cancelled End of Day and one receipt
        Initialize();
        CreateUncompletedZReport(AtToday(070000T), false);
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '751', 1, 100, CleanCashTransRequest);
        CreateUncompletedZReport(AtToday(200000T), true);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] No Z report is exported and the file is valid
        _Assert.AreEqual(0, CountNodes(Document, '//ko:ZDagrapport'), 'Uncompleted Z reports must not be exported');
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherOnlyReceiptIsExportedAsServiceArticle()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
    begin
        // [SCENARIO] CleanCash registers G/L, item, rounding and voucher lines, so a receipt without item lines still has articles

        // [GIVEN] A receipt for a gift voucher only
        Initialize();
        POSEntry := CreatePOSEntry(AtToday(080000T));
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Voucher, 'GIFT', 'Gift voucher', 1, 500, 0);
        AddPaymentLine(POSEntry, 'K', 500);
        CreateCleanCashRequest(POSEntry, Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '761', 500);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The voucher is a service article and the file is valid
        _Assert.AreEqual('TJANST', NodeText(Document, '//ko:Kassakvitto//ko:SaldArtikel/ko:TypAvArtikel'), 'Article type of the voucher');
        _Assert.AreEqual('Gift voucher', NodeText(Document, '//ko:Kassakvitto//ko:SaldArtikel/ko:Artikelnamn'), 'Article name of the voucher');
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EvenExchangeIsSettledByOffset()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
    begin
        // [SCENARIO] An even exchange has no payment lines. Each of its two receipts is settled against the other.

        // [GIVEN] One POS entry that returns an item for 299 and sells one for 299, split into a sales and a return request
        Initialize();
        POSEntry := CreatePOSEntry(AtToday(080000T));
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Item, _Item."No.", _Item.Description, 1, 299, 25);
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Item, _Item."No.", _Item.Description, -1, 299, 25);
        CreateCleanCashRequest(POSEntry, Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '771', 299);
        CreateCleanCashRequest(POSEntry, Enum::"NPR CleanCash Request Type"::RegisterReturnReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '772', -299);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] Each receipt has its own VAT and an offset payment for its own total, and the file is valid
        _Assert.AreEqual('59.8', NodeText(Document, '//ko:Kassakvitto/ko:MervardesskattPaForsaljningsbeloppet'), 'VAT of the sales receipt');
        _Assert.AreEqual('-59.8', NodeText(Document, '//ko:Returkvitto/ko:MervardesskattPaForsaljningsbeloppet'), 'VAT of the return receipt');
        _Assert.AreEqual('299', NodeText(Document, '//ko:Kassakvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''Kvittning'']/ko:ForsaljningssummaPerBetalningsmedel'), 'Offset on the sales receipt');
        _Assert.AreEqual('-299', NodeText(Document, '//ko:Returkvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''Kvittning'']/ko:ForsaljningssummaPerBetalningsmedel'), 'Offset on the return receipt');
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnevenExchangeDoesNotCountPaymentsTwice()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        Document: XmlDocument;
    begin
        // [SCENARIO] In an exchange the customer's payment belongs to one receipt only. The rest of each receipt is settled by offset.

        // [GIVEN] One POS entry that returns 100, sells 299 and is paid 199 by card
        Initialize();
        POSEntry := CreatePOSEntry(AtToday(080000T));
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Item, _Item."No.", _Item.Description, 1, 299, 25);
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Item, _Item."No.", _Item.Description, -1, 100, 25);
        AddPaymentLine(POSEntry, 'K', 199);
        CreateCleanCashRequest(POSEntry, Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '781', 299);
        CreateCleanCashRequest(POSEntry, Enum::"NPR CleanCash Request Type"::RegisterReturnReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '782', -100);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The card payment is on the sales receipt only and both receipts add up to their totals
        _Assert.AreEqual('199', NodeText(Document, '//ko:Kassakvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''K'']/ko:ForsaljningssummaPerBetalningsmedel'), 'Card payment on the sales receipt');
        _Assert.AreEqual('100', NodeText(Document, '//ko:Kassakvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''Kvittning'']/ko:ForsaljningssummaPerBetalningsmedel'), 'Offset on the sales receipt');
        _Assert.AreEqual(0, CountNodes(Document, '//ko:Returkvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''K'']'), 'The card payment must not be repeated on the return receipt');
        _Assert.AreEqual('-100', NodeText(Document, '//ko:Returkvitto//ko:TotalForsaljningssummaPerBetalningsmedel[ko:Betalningsmedel=''Kvittning'']/ko:ForsaljningssummaPerBetalningsmedel'), 'Offset on the return receipt');
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EverySignInAndSignOutIsASeparateEvent()
    var
        Document: XmlDocument;
    begin
        // [SCENARIO] Every sign-in and sign-out in the period is exported as its own event, not only the last pair

        // [GIVEN] Two sign-ins and one sign-out, and no receipts, so the control unit number comes from the CleanCash identity response
        Initialize();
        CreateIdentityResponse();
        CreateAuditLogEntry(true, AtToday(080000T));
        CreateAuditLogEntry(false, AtToday(120000T));
        CreateAuditLogEntry(true, AtToday(130000T));

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] Each one is a separate event, and none of them is reported as a register start or stop
        _Assert.AreEqual(2, CountNodes(Document, '//ko:Handelse/ko:InloggningIKassaregister[.=''JA'']'), 'Sign-in events');
        _Assert.AreEqual(1, CountNodes(Document, '//ko:Handelse/ko:UtloggningUrKassaregister[.=''JA'']'), 'Sign-out events');
        _Assert.AreEqual(0, CountNodes(Document, '//*[local-name()=''StartAvKassaregister'']'), 'A sign-in is not a register start');
        _Assert.AreEqual(0, CountNodes(Document, '//*[local-name()=''StoppAvKassaregister'']'), 'A sign-out is not a register stop');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptCopyReferencesItsOriginalReceipt()
    var
        OriginalReceipt: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] A receipt copy carries the original's number, time and control code

        // [GIVEN] A receipt at 08:00 and a copy of it at 09:00
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '801', 1, 100, OriginalReceipt);
        CreateReceiptCopy(OriginalReceipt, AtToday(090000T), '802');

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The copy references the original receipt
        _Assert.AreEqual('802', NodeText(Document, '//ko:KopiaAvKassakvitto/ko:LopnummerForKvittokopia'), 'Copy number');
        _Assert.AreEqual('801', NodeText(Document, '//ko:KopiaAvKassakvitto/ko:LopnummerPaOriginalkvitto'), 'Original receipt number');
        _Assert.AreEqual(Format(Today(), 0, '<Year4>-<Month,2>-<Day,2>') + 'T08:00:00', NodeText(Document, '//ko:KopiaAvKassakvitto/ko:DatumOchKlockslagNarOriginalkvittoFramstalldes'), 'Original receipt time');
        _Assert.AreEqual(OriginalReceipt."CleanCash Code", NodeText(Document, '//ko:KopiaAvKassakvitto/ko:KontrollkodForKvittotSomKopianAvser'), 'Control code of the original receipt');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReceiptCopyMadeTheNextDayIsInThatDaysJournal()
    var
        OriginalReceipt: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
        CopyTime: Text;
    begin
        // [SCENARIO] A copy is dated when it was made. CleanCash stores the original sale's time in Receipt DateTime for copies too.

        // [GIVEN] A receipt from yesterday and a copy of it made today at 09:30
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, CreateDateTime(Today() - 1, 080000T), '811', 1, 100, OriginalReceipt);
        CreateReceiptCopy(OriginalReceipt, AtToday(093000T), '812');

        // [WHEN] Today's journal is exported
        ExportJournal(Document);

        // [THEN] Only the copy is exported, dated at 09:30 today
        CopyTime := Format(Today(), 0, '<Year4>-<Month,2>-<Day,2>') + 'T09:30:00';
        _Assert.AreEqual(0, CountNodes(Document, '//ko:Kassakvitto'), 'The original receipt belongs to yesterday');
        _Assert.AreEqual(CopyTime, NodeText(Document, '//ko:KopiaAvKassakvitto/ko:DatumOchKlockslagNarKvittoFramstalls'), 'Time the copy was made');
        _Assert.AreEqual(CopyTime, NodeText(Document, '//ko:Handelse[ko:KopiaAvKassakvitto]/ko:Registreringstidpunkt'), 'Registration time of the copy');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReportCountsCopiesAndTrainingForItsOwnPeriod()
    var
        TrainingReceipt: Record "NPR CleanCash Trans. Request";
        XReport: Record "NPR POS Workshift Checkpoint";
        ZReport: Record "NPR POS Workshift Checkpoint";
        Document: XmlDocument;
    begin
        // [SCENARIO] An X report counts receipt copies and training receipts since the previous Z report, not over the export period

        // [GIVEN] A training receipt, a Z report, a second training receipt and an X report that recorded 3 receipt copies
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::ovning, AtToday(080000T), '821', 1, 100, TrainingReceipt);
        ZReport := CreateWorkshiftCheckpoint(true, AtToday(100000T), TrainingReceipt."POS Entry No." + 1);
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::ovning, AtToday(110000T), '822', 1, 100, TrainingReceipt);
        XReport := CreateWorkshiftCheckpoint(false, AtToday(120000T), TrainingReceipt."POS Entry No." + 1);
        XReport."Receipt Copies Count" := 3;
        XReport.Modify();

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The X report shows its own copy count and only the training receipt after the Z report
        _Assert.AreEqual('3', NodeText(Document, '//ko:XDagrapport/ko:AntalKvittokopior'), 'Receipt copies of the X report');
        _Assert.AreEqual('1', NodeText(Document, '//ko:XDagrapport/ko:AntalKvittonSomTagitsFramIOvningslage'), 'Training receipts since the previous Z report');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ParkedReturnKeepsUnfinishedSalesAmountValid()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] The schema does not allow a negative total for unfinished sales, which a parked return would otherwise give

        // [GIVEN] A receipt, a parked return of 125 and a Z report
        Initialize();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '831', 1, 100, CleanCashTransRequest);
        CreateParkedSale(AtToday(090000T), -125);
        CreateWorkshiftCheckpoint(true, AtToday(200000T), CleanCashTransRequest."POS Entry No." + 1);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The unfinished sales amount is the parked amount and the file is valid
        _Assert.AreEqual('125', NodeText(Document, '//ko:ZDagrapport/ko:TotaltBeloppAvOavslutadeForsaljningar'), 'Amount of unfinished sales');
        _LibrarySEJournalSchema.AssertMatchesSchema(Document);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemMasterRecordsAreNotExportedAsArticleRegistrations()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        Document: XmlDocument;
    begin
        // [SCENARIO] Creating an item in the Item master is not a cash register registration (see COM-1677)

        // [GIVEN] An item created today and one sales receipt
        Initialize();
        CreateItem();
        CreateReceipt(Enum::"NPR CleanCash Request Type"::RegisterSalesReceipt, Enum::"NPR CleanCash Receipt Type"::normal, AtToday(080000T), '901', 1, 100, CleanCashTransRequest);

        // [WHEN] The journal is exported
        ExportJournal(Document);

        // [THEN] The new item is not exported as a registration
        _Assert.AreEqual(0, CountNodes(Document, '//*[local-name()=''RegistreraArtikel'']'), 'Item master records must not be exported as RegistreraArtikel');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportFailsWhenControlUnitIsUnknown()
    var
        Document: XmlDocument;
    begin
        // [SCENARIO] Kassaregistersystemet requires the control unit serial number. A unit that never talked to CleanCash has none.

        // [GIVEN] A sign-in on a unit without any CleanCash request
        Initialize();
        CreateAuditLogEntry(true, AtToday(080000T));

        // [WHEN] The journal is exported
        asserterror ExportJournal(Document);

        // [THEN] The export stops and explains why
        _Assert.ExpectedError('control unit serial number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportWithoutRegistrationsFails()
    var
        Document: XmlDocument;
    begin
        // [SCENARIO] The schema requires at least one event, so an empty period is reported instead of producing an invalid file

        // [GIVEN] A POS unit without events in the period
        Initialize();

        // [WHEN] The journal is exported
        asserterror ExportJournal(Document);

        // [THEN] The export stops and explains why
        _Assert.ExpectedError('no registrations');
    end;

    local procedure Initialize()
    begin
        _SalespersonCode := 'SP01';
        _ControlUnitId := 'CCTESTUNIT0000017';

        _POSStore.Init();
        _POSStore.Code := NewCode();
        _POSStore.Name := 'Test Store';
        _POSStore.Address := 'Storgatan 1';
        _POSStore.City := 'Stockholm';
        _POSStore.Insert();

        _POSUnit.Init();
        _POSUnit."No." := NewCode();
        _POSUnit."POS Store Code" := _POSStore.Code;
        _POSUnit.Insert();

        _CleanCashSetup.Init();
        _CleanCashSetup.Register := _POSUnit."No.";
        _CleanCashSetup."Organization ID" := '5561234567';
        _CleanCashSetup."CleanCash Register No." := 'NPR-TEST-01';
        _CleanCashSetup.Insert();

        CreateItem();
    end;

    local procedure CreateItem()
    begin
        _Item.Init();
        _Item."No." := NewCode();
        _Item.Description := 'Bicycle';
        _Item.Type := _Item.Type::Inventory;
        _Item.Insert();
    end;

    local procedure CreateReceipt(RequestType: Enum "NPR CleanCash Request Type"; ReceiptType: Enum "NPR CleanCash Receipt Type"; ReceiptDateTime: DateTime; ReceiptId: Text[12]; Quantity: Decimal; UnitPrice: Decimal; var CleanCashTransRequest: Record "NPR CleanCash Trans. Request")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry := CreatePOSEntry(ReceiptDateTime);
        AddSalesLine(POSEntry, POSEntrySalesLine.Type::Item, _Item."No.", _Item.Description, Quantity, UnitPrice, 25);
        AddPaymentLine(POSEntry, 'K', Quantity * UnitPrice);
        CleanCashTransRequest := CreateCleanCashRequest(POSEntry, RequestType, ReceiptType, ReceiptDateTime, ReceiptId, Quantity * UnitPrice);
    end;

    local procedure CreatePOSEntry(EntryDateTime: DateTime) POSEntry: Record "NPR POS Entry"
    begin
        POSEntry.Init();
        POSEntry."POS Unit No." := _POSUnit."No.";
        POSEntry."POS Store Code" := _POSStore.Code;
        POSEntry."Entry Date" := DT2Date(EntryDateTime);
        POSEntry."Document Date" := DT2Date(EntryDateTime);
        POSEntry."Ending Time" := DT2Time(EntryDateTime);
        POSEntry."Salesperson Code" := _SalespersonCode;
        POSEntry.Insert();
    end;

    local procedure AddSalesLine(var POSEntry: Record "NPR POS Entry"; LineType: Option; No: Code[20]; Description: Text[100]; Quantity: Decimal; UnitPrice: Decimal; VATPct: Decimal)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        AmountExclVAT: Decimal;
        AmountInclVAT: Decimal;
    begin
        AmountInclVAT := Quantity * UnitPrice;
        AmountExclVAT := Round(AmountInclVAT / (1 + VATPct / 100), 0.01);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntrySalesLine.FindLast() then;
        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." += 10000;
        POSEntrySalesLine."POS Unit No." := _POSUnit."No.";
        POSEntrySalesLine.Type := LineType;
        POSEntrySalesLine."No." := No;
        POSEntrySalesLine.Description := Description;
        POSEntrySalesLine.Quantity := Quantity;
        POSEntrySalesLine."Unit of Measure Code" := 'PCS';
        POSEntrySalesLine."Unit Price" := UnitPrice;
        POSEntrySalesLine."VAT %" := VATPct;
        POSEntrySalesLine."Amount Incl. VAT" := AmountInclVAT;
        POSEntrySalesLine."Amount Excl. VAT" := AmountExclVAT;
        POSEntrySalesLine."POS Sale Line Created At" := CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time") - 60000;
        POSEntrySalesLine.Insert();

        // The entry's tax is the net of all its lines, as for a posted POS entry
        POSEntry."Tax Amount" += AmountInclVAT - AmountExclVAT;
        POSEntry.Modify();
    end;

    local procedure AddPaymentLine(POSEntry: Record "NPR POS Entry"; PaymentMethodCode: Code[10]; Amount: Decimal)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntryPaymentLine.FindLast() then;
        POSEntryPaymentLine.Init();
        POSEntryPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryPaymentLine."Line No." += 10000;
        POSEntryPaymentLine."POS Unit No." := _POSUnit."No.";
        POSEntryPaymentLine."POS Payment Method Code" := PaymentMethodCode;
        POSEntryPaymentLine."Amount (LCY)" := Amount;
        POSEntryPaymentLine.Insert();
    end;

    local procedure CreateCleanCashRequest(POSEntry: Record "NPR POS Entry"; RequestType: Enum "NPR CleanCash Request Type"; ReceiptType: Enum "NPR CleanCash Receipt Type"; RequestDateTime: DateTime; ReceiptId: Text[12]; ReceiptTotal: Decimal) CleanCashTransRequest: Record "NPR CleanCash Trans. Request"
    begin
        // As in production: Receipt DateTime is the POS entry's time, Request Datetime is when the request was made
        CleanCashTransRequest.Init();
        CleanCashTransRequest."POS Entry No." := POSEntry."Entry No.";
        CleanCashTransRequest."POS Unit No." := _POSUnit."No.";
        CleanCashTransRequest."Request Datetime" := RequestDateTime;
        CleanCashTransRequest."Request Send Status" := CleanCashTransRequest."Request Send Status"::COMPLETE;
        CleanCashTransRequest."Request Type" := RequestType;
        CleanCashTransRequest."Receipt Type" := ReceiptType;
        CleanCashTransRequest."Receipt DateTime" := CreateDateTime(POSEntry."Document Date", POSEntry."Ending Time");
        CleanCashTransRequest."Receipt Id" := ReceiptId;
        CleanCashTransRequest."Receipt Total" := ReceiptTotal;
        CleanCashTransRequest."Organisation No." := _CleanCashSetup."Organization ID";
        CleanCashTransRequest."Pos Id" := _CleanCashSetup."CleanCash Register No.";
        CleanCashTransRequest."CleanCash Unit Id" := _ControlUnitId;
        CleanCashTransRequest."CleanCash Code" := ControlCode(ReceiptId);
        CleanCashTransRequest.Insert();
    end;

    local procedure CreateReceiptCopy(OriginalReceipt: Record "NPR CleanCash Trans. Request"; CopyDateTime: DateTime; ReceiptId: Text[12])
    var
        CopyReceipt: Record "NPR CleanCash Trans. Request";
    begin
        // As in production: a copy keeps the original POS entry's Receipt DateTime and gets its own Request Datetime
        CopyReceipt := OriginalReceipt;
        CopyReceipt."Entry No." := 0;
        CopyReceipt."Receipt Type" := CopyReceipt."Receipt Type"::kopia;
        CopyReceipt."Request Datetime" := CopyDateTime;
        CopyReceipt."Receipt Id" := ReceiptId;
        CopyReceipt."CleanCash Code" := ControlCode(ReceiptId);
        CopyReceipt.Insert();
    end;

    local procedure CreateIdentityResponse()
    var
        CleanCashTransRequest: Record "NPR CleanCash Trans. Request";
        CleanCashTransResponse: Record "NPR CleanCash Trans. Response";
    begin
        CleanCashTransRequest.Init();
        CleanCashTransRequest."POS Unit No." := _POSUnit."No.";
        CleanCashTransRequest."Request Type" := CleanCashTransRequest."Request Type"::IdentityRequest;
        CleanCashTransRequest."Request Send Status" := CleanCashTransRequest."Request Send Status"::COMPLETE;
        CleanCashTransRequest.Insert();

        CleanCashTransResponse.Init();
        CleanCashTransResponse."Request Entry No." := CleanCashTransRequest."Entry No.";
        CleanCashTransResponse."Response No." := 1;
        CleanCashTransResponse."CleanCash Unit Id" := _ControlUnitId;
        CleanCashTransResponse.Insert();
    end;

    local procedure CreateWorkshiftCheckpoint(IsZReport: Boolean; CreatedAt: DateTime; POSEntryNo: Integer) POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"
    begin
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."POS Unit No." := _POSUnit."No.";
        POSWorkshiftCheckpoint."POS Entry No." := POSEntryNo;
        POSWorkshiftCheckpoint."Created At" := CreatedAt;
        if IsZReport then
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT
        else
            POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::XREPORT;
        POSWorkshiftCheckpoint."Direct Item Sales (LCY)" := 1234.5;
        POSWorkshiftCheckpoint."Direct Item Returns (LCY)" := -617.25;
        POSWorkshiftCheckpoint."Direct Item Net Sales (LCY)" := 617.25;
        POSWorkshiftCheckpoint."Receipts Count" := 2;
        POSWorkshiftCheckpoint."Direct Item Returns Line Count" := 1;
        POSWorkshiftCheckpoint.Insert();
        AddCheckpointTaxAndBin(POSWorkshiftCheckpoint);
    end;

    local procedure CreateUncompletedZReport(CreatedAt: DateTime; WithBinCheckpoint: Boolean)
    var
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        // The first-start placeholder has no bins. A cancelled End of Day keeps the bins counted before the cancel.
        // Neither has a POS entry, which only a confirmed balancing creates.
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."POS Unit No." := _POSUnit."No.";
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint."Created At" := CreatedAt;
        POSWorkshiftCheckpoint.Open := WithBinCheckpoint;
        POSWorkshiftCheckpoint.Insert();
        if WithBinCheckpoint then
            AddCheckpointTaxAndBin(POSWorkshiftCheckpoint);
    end;

    local procedure AddCheckpointTaxAndBin(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSPaymentBinCheckp: Record "NPR POS Payment Bin Checkp.";
        POSWorkshTaxCheckp: Record "NPR POS Worksh. Tax Checkp.";
    begin
        POSWorkshTaxCheckp.Init();
        POSWorkshTaxCheckp."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
        POSWorkshTaxCheckp."Tax %" := 25;
        POSWorkshTaxCheckp."Tax Amount" := 123.45;
        POSWorkshTaxCheckp.Insert();

        POSPaymentBinCheckp.Init();
        POSPaymentBinCheckp."Workshift Checkpoint Entry No." := POSWorkshiftCheckpoint."Entry No.";
        POSPaymentBinCheckp."Payment Method No." := 'K';
        POSPaymentBinCheckp."Calculated Amount Incl. Float" := 617.25;
        POSPaymentBinCheckp.Insert();
    end;

    local procedure CreateAuditLogEntry(IsSignIn: Boolean; LogTimestamp: DateTime)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.Init();
        if IsSignIn then
            POSAuditLog."Action Type" := POSAuditLog."Action Type"::SIGN_IN
        else
            POSAuditLog."Action Type" := POSAuditLog."Action Type"::SIGN_OUT;
        POSAuditLog."Active POS Unit No." := _POSUnit."No.";
        POSAuditLog."Acted on POS Unit No." := _POSUnit."No.";
        POSAuditLog."Active Salesperson Code" := _SalespersonCode;
        POSAuditLog."Log Timestamp" := LogTimestamp;
        POSAuditLog.Insert();
    end;

    local procedure CreateParkedSale(CreatedAt: DateTime; AmountInclVAT: Decimal)
    var
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
    begin
        POSSavedSaleEntry.Init();
        POSSavedSaleEntry."Register No." := _POSUnit."No.";
        POSSavedSaleEntry."Created at" := CreatedAt;
        POSSavedSaleEntry."Salesperson Code" := _SalespersonCode;
        POSSavedSaleEntry.Insert();

        POSSavedSaleLine.Init();
        POSSavedSaleLine."Quote Entry No." := POSSavedSaleEntry."Entry No.";
        POSSavedSaleLine."Line No." := 10000;
        POSSavedSaleLine."Line Type" := POSSavedSaleLine."Line Type"::Item;
        POSSavedSaleLine."No." := _Item."No.";
        POSSavedSaleLine.Description := _Item.Description;
        if AmountInclVAT < 0 then
            POSSavedSaleLine.Quantity := -1
        else
            POSSavedSaleLine.Quantity := 1;
        POSSavedSaleLine."Unit of Measure Code" := 'PCS';
        POSSavedSaleLine."Unit Price" := Abs(AmountInclVAT);
        POSSavedSaleLine."Amount Including VAT" := AmountInclVAT;
        POSSavedSaleLine.Amount := Round(AmountInclVAT / 1.25, 0.01);
        POSSavedSaleLine.Insert();
    end;

    local procedure ExportJournal(var Document: XmlDocument)
    var
        SECCCashRegExpMgt: Codeunit "NPR SE CC Cash Reg. Exp. Mgt.";
    begin
        SECCCashRegExpMgt.CreateCashRegisterJournal(Today(), Today(), _POSUnit."No.", Document);
    end;

    local procedure AtToday(TimeOfDay: Time): DateTime
    begin
        exit(CreateDateTime(Today(), TimeOfDay));
    end;

    local procedure ControlCode(ReceiptId: Text): Text[100]
    begin
        // CleanCash control codes are 59 characters long
        exit(CopyStr(PadStr('CC' + ReceiptId + '-', 59, 'A'), 1, 100));
    end;

    local procedure NewCode(): Code[10]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 10));
    end;

    local procedure NamespaceManager(NameTable: XmlNameTable) NamespaceManager: XmlNamespaceManager
    begin
        NamespaceManager.NameTable(NameTable);
        NamespaceManager.AddNamespace('in', _LibrarySEJournalSchema.InstansNamespace());
        NamespaceManager.AddNamespace('ko', _LibrarySEJournalSchema.KomponentNamespace());
    end;

    local procedure SelectNodes(Document: XmlDocument; XPath: Text; var NodeList: XmlNodeList)
    begin
        Document.SelectNodes(XPath, NamespaceManager(Document.NameTable()), NodeList);
    end;

    local procedure CountNodes(Document: XmlDocument; XPath: Text): Integer
    var
        NodeList: XmlNodeList;
    begin
        SelectNodes(Document, XPath, NodeList);
        exit(NodeList.Count());
    end;

    local procedure CountNodes(Node: XmlNode; XPath: Text): Integer
    var
        Document: XmlDocument;
        NodeList: XmlNodeList;
    begin
        Node.GetDocument(Document);
        Node.SelectNodes(XPath, NamespaceManager(Document.NameTable()), NodeList);
        exit(NodeList.Count());
    end;

    local procedure NodeText(Document: XmlDocument; XPath: Text): Text
    var
        Node: XmlNode;
    begin
        _Assert.IsTrue(Document.SelectSingleNode(XPath, NamespaceManager(Document.NameTable()), Node), StrSubstNo('Element %1 not found', XPath));
        exit(Node.AsXmlElement().InnerText());
    end;

    local procedure NodeText(Node: XmlNode; XPath: Text): Text
    var
        Document: XmlDocument;
        ChildNode: XmlNode;
    begin
        Node.GetDocument(Document);
        _Assert.IsTrue(Node.SelectSingleNode(XPath, NamespaceManager(Document.NameTable()), ChildNode), StrSubstNo('Element %1 not found', XPath));
        exit(ChildNode.AsXmlElement().InnerText());
    end;
}
