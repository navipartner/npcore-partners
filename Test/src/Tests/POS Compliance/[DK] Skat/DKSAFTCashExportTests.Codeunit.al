codeunit 85488 "NPR DK SAF-T Cash Export Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryDKFiscal: Codeunit "NPR Library DK Fiscal";
        _LibraryERM: Codeunit "Library - ERM";
        _LibraryInventory: Codeunit "NPR Library - Inventory";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryUtility: Codeunit "Library - Utility";
        _ConfirmReplies: List of [Boolean];
        _ExpectedConfirmQuestions: List of [Text];
        _GenerateImmediatelyQstTxt: Label 'did not schedule the SAF-T file generation', Locked = true;
        _RestartCompletedExportQstTxt: Label 'restart the export to get a new SAF-T file', Locked = true;
        _SAFTNamespaceTxt: Label 'urn:StandardAuditFile-Taxation-CashRegister:DK', Locked = true;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportOverMultipleMonthsProducesOneCompleteXmlFile()
    var
        Item: Record Item;
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        Root: XmlElement;
        Nodes: XmlNodeList;
        StartingDate: Date;
        EndingDate: Date;
    begin
        // [SCENARIO] SKAT technical description v2.0 requires one complete XML file for the requested period.
        Initialize();

        // [GIVEN] A POS unit with fiscal cash transactions in two different months and an item in master data
        StartingDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));
        EndingDate := CalcDate('<CM+1M>', StartingDate);
        CreatePOSStoreAndUnit(POSStore, POSUnit);
        CreateFiscalPOSEntry(POSStore.Code, POSUnit."No.", StartingDate + 4, 'DKFISC-1', 125);
        CreateFiscalPOSEntry(POSStore.Code, POSUnit."No.", EndingDate - 2, 'DKFISC-2', 250);
        _LibraryInventory.CreateItem(Item);
        CreateExportHeader(SAFTExportHeader, StartingDate, EndingDate, false);

        // [WHEN] The export is run in the foreground and the user confirms immediate generation
        EnqueueConfirm(_GenerateImmediatelyQstTxt, true);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] Exactly one export line exists and the export completed
        SAFTExportHeader.Find();
        _Assert.AreEqual(SAFTExportHeader.Status::Completed, SAFTExportHeader.Status, 'The export must complete.');
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        _Assert.AreEqual(1, SAFTExportLine.Count(), 'The export must produce exactly one SAF-T file.');
        SAFTExportLine.FindFirst();
        _Assert.AreEqual(SAFTExportLine.Status::Completed, SAFTExportLine.Status, 'The export line must complete.');
        _Assert.AreEqual(StartingDate, SAFTExportLine."Starting Date", 'The single file must start on the requested starting date.');
        _Assert.AreEqual(EndingDate, SAFTExportLine."Ending Date", 'The single file must end on the requested ending date.');

        // [THEN] The file holds header, master data and both months' transactions in one auditfile document
        ReadExportedXml(SAFTExportLine, Document, NamespaceManager);
        Document.GetRoot(Root);
        _Assert.AreEqual('auditfile', Root.LocalName(), 'The root element must be auditfile.');
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:header'), 'The file must contain one header.');
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:company'), 'The file must contain one company.');
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, StrSubstNo('/s:auditfile/s:company/s:articles/s:article[s:artID=''%1'']', Item."No.")),
            'Master data (articles) must be in the same file as the transactions.');

        Document.SelectNodes(
            StrSubstNo('/s:auditfile/s:company/s:location/s:cashregister[s:registerID=''%1'']/s:cashtransaction/s:transID', POSUnit."No."),
            NamespaceManager, Nodes);
        _Assert.AreEqual(2, Nodes.Count(), 'Transactions from both months must be in the same file.');
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '//s:cashtransaction[s:transID=''DKFISC-1'']'), 'The first month transaction must be exported.');
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '//s:cashtransaction[s:transID=''DKFISC-2'']'), 'The second month transaction must be exported.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestartingLegacySplitExportReplacesFilesWithOneFile()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
    begin
        // [SCENARIO] An export generated by the old logic (master data + per-month files) is regenerated as one file.
        Initialize();

        // [GIVEN] A completed export with three legacy lines
        CreateLegacySplitExport(SAFTExportHeader, 3);

        // [WHEN] The export is restarted and the user confirms both the restart and immediate generation
        EnqueueConfirm(_RestartCompletedExportQstTxt, true);
        EnqueueConfirm(_GenerateImmediatelyQstTxt, true);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] Only one line remains and it holds a generated file
        VerifySingleGeneratedFile(SAFTExportHeader, 'Restarting must replace the split files with one SAF-T file.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DownloadOfLegacySplitExportIsRefused()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    begin
        // [SCENARIO] Split files from the old logic cannot be downloaded, because SKAT does not accept them.
        Initialize();

        // [GIVEN] A completed export with two legacy lines
        CreateLegacySplitExport(SAFTExportHeader, 2);

        // [WHEN] The file is downloaded
        asserterror SAFTExportMgt.DownloadSAFTFile(SAFTExportHeader);

        // [THEN] The user is told to restart the export
        _Assert.ExpectedError('Restart the export to generate a single SAF-T file.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DownloadOfLegacyMasterDataOnlyExportIsRefused()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    begin
        // [SCENARIO] An old split export over a period without POS entries has only the master-data line. It is not a complete journal.
        Initialize();

        // [GIVEN] A completed export with only the legacy master-data line
        CreateLegacySplitExport(SAFTExportHeader, 1);

        // [WHEN] The file is downloaded
        asserterror SAFTExportMgt.DownloadSAFTFile(SAFTExportHeader);

        // [THEN] The user is told the export holds only master data and must be restarted
        _Assert.ExpectedError('contains only master data');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestartActionOnLegacyDownloadErrorRegeneratesOneFile()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
        RestartError: ErrorInfo;
    begin
        // [SCENARIO] The Restart export action on the legacy download error regenerates the export as one file.
        Initialize();

        // [GIVEN] A completed export with two legacy lines, and the error raised when downloading it
        CreateLegacySplitExport(SAFTExportHeader, 2);
        RestartError.RecordId := SAFTExportHeader.RecordId();

        // [WHEN] The user chooses the Restart export action and confirms both questions
        EnqueueConfirm(_RestartCompletedExportQstTxt, true);
        EnqueueConfirm(_GenerateImmediatelyQstTxt, true);
        SAFTExportMgt.RestartExportFromErrorInfo(RestartError);

        // [THEN] The export now holds one generated file
        VerifySingleGeneratedFile(SAFTExportHeader, 'The Restart export action must regenerate the export as one SAF-T file.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DownloadWithoutGeneratedFileIsRefused()
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    begin
        // [SCENARIO] Downloading before the file is generated gives a clear error.
        Initialize();

        // [GIVEN] An export that was never started
        CreateExportHeader(SAFTExportHeader, WorkDate(), WorkDate(), false);

        // [WHEN] The file is downloaded
        asserterror SAFTExportMgt.DownloadSAFTFile(SAFTExportHeader);

        // [THEN] No file is available
        _Assert.ExpectedError('No SAF-T file has been generated.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BackgroundExportSchedulesOneDanishGeneratorTask()
    var
        ScheduledTask: Record "Scheduled Task";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
    begin
        // [SCENARIO] A background export schedules one task running the Danish generator, not the Norwegian one.
        Initialize();

        // [GIVEN] An export set to run in the background in the future, so no confirmation is asked
        CreateExportHeader(SAFTExportHeader, DMY2Date(1, 1, Date2DMY(WorkDate(), 3)), DMY2Date(31, 12, Date2DMY(WorkDate(), 3)), true);
        SAFTExportHeader."Earliest Start Date/Time" := CreateDateTime(Today() + 30, 0T);
        SAFTExportHeader.Modify();

        // [WHEN] The export is started
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] One line is scheduled with the Danish generator codeunit
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        _Assert.AreEqual(1, SAFTExportLine.Count(), 'A background export must create one line.');
        SAFTExportLine.FindFirst();
        _Assert.IsTrue(ScheduledTask.Get(SAFTExportLine."Task ID"), 'A task must be scheduled for the export line.');
        _Assert.AreEqual(Codeunit::"NPR DK Gen. SAF-T Cash File", ScheduledTask."Run Codeunit", 'The task must run the Danish SAF-T generator.');
        _Assert.AreEqual(Codeunit::"NPR DK SAF-T Exp. Err. Handler", ScheduledTask."Failure Codeunit", 'The task must use the Danish error handler.');

        // [CLEANUP]
        TaskScheduler.CancelTask(SAFTExportLine."Task ID");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FileNameMarksTheOnlyFile()
    var
        SAFTXMLHelper: Codeunit "NPR DK SAF-T XML Helper";
    begin
        // [SCENARIO] SKAT file naming: the file number must be 1_1 because output is always a single file.
        _Assert.AreEqual(
            'SAF-T Cash Register_12345678_20260515234556_1_1.xml',
            SAFTXMLHelper.GetFilePath('12345678', CreateDateTime(DMY2Date(15, 5, 2026), 234556T), 1, 1),
            'The file name must follow the SKAT naming standard for a single file.');
        _Assert.AreEqual(
            'SAF-T Cash Register_12345678_20260515090507_1_1.xml',
            SAFTXMLHelper.GetFilePath('12345678', CreateDateTime(DMY2Date(15, 5, 2026), 090507T), 1, 1),
            'The hour in the file name must be zero-padded to two digits.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashSaleCarriesTransactionTypeEmployeeAndFlags()
    var
        POSEntry: Record "NPR POS Entry";
        Salesperson: Record "Salesperson/Purchaser";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        TransactionXPath: Text;
        TransType: Text;
    begin
        // [SCENARIO] SKAT technical description v2.0 section 6.1: transType, empID, voidTransaction and trainingID are mandatory.
        // transType must be declared in basics with basicType 11 and a predefined transaction code (code list v1.3.0 section 2.3).
        Initialize();

        // [GIVEN] A cash sale made by a salesperson
        _LibraryPOSMasterData.CreateSalespersonForPOSUsage(Salesperson);
        CreateFiscalSale(POSEntry, 'DKCT-CASH', Salesperson.Code, 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type is declared in basics as a cash sale (11001)
        TransactionXPath := TransactionXPathFor(POSEntry);
        TransType := SelectText(Document, NamespaceManager, TransactionXPath + '/s:transType');
        AssertBasic(Document, NamespaceManager, TransType, '11', '11001');

        // [THEN] The employee is the salesperson, and the sale is neither cancelled nor a training sale
        _Assert.AreEqual(Salesperson.Code, SelectText(Document, NamespaceManager, TransactionXPath + '/s:empID'), 'empID must be the salesperson of the sale.');
        _Assert.AreEqual('false', SelectText(Document, NamespaceManager, TransactionXPath + '/s:voidTransaction'), 'A completed sale is not cancelled.');
        _Assert.AreEqual('false', SelectText(Document, NamespaceManager, TransactionXPath + '/s:trainingID'), 'The POS has no training mode, so no sale is a training sale.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReturnSaleIsReportedAsReturnPayment()
    var
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] A sale that only returns goods and pays the customer back is transaction code 11006 (Return payment).
        Initialize();

        // [GIVEN] A sale with only a returned item
        CreateFiscalSale(POSEntry, 'DKCT-RET', '', -125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), -1, -125, -100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Return payment
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11006');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleWithSoldAndReturnedItemsIsReportedAsCashSaleAndReturn()
    var
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] A sale that both sells and returns goods is transaction code 11016 (Cash sale and return).
        Initialize();

        // [GIVEN] A sale with one sold and one returned item
        CreateFiscalSale(POSEntry, 'DKCT-MIX', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 2, 250, 200);
        AddItemLine(POSEntry, 20000, CreateItemNo(), -1, -125, -100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Cash sale and return
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11016');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditSaleIsReportedAsCreditSale()
    var
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] A POS sale to a customer account is transaction code 11002 (Credit sale).
        Initialize();

        // [GIVEN] A credit sale
        CreateFiscalSale(POSEntry, 'DKCT-CRED', '', 125);
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Credit Sale";
        POSEntry.Modify();
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Credit sale
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11002');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesLinesAreExportedAsTransactionLines()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        LineXPath: Text;
        ItemNo: Code[20];
    begin
        // [SCENARIO] SKAT technical description v2.0 section 6.2: each receipt line is a ctLine with article, quantity, amounts and VAT.
        Initialize();

        // [GIVEN] A sale with an item line and a comment line
        ItemNo := CreateItemNo();
        CreateFiscalSale(POSEntry, 'DKCT-LINES', '', 250);
        AddItemLine(POSEntry, 10000, ItemNo, 2, 250, 200);
        AddSalesLine(POSEntry, 20000, SalesLine.Type::Comment, '', 0, 0, 0, 'Thank you');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] Only the item line is a ctLine, since the comment carries no amount
        LineXPath := TransactionXPathFor(POSEntry) + '/s:ctLine';
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, LineXPath), 'Only lines with an article must be exported as ctLine.');

        // [THEN] The line references the transaction and holds the article, quantity and amounts
        _Assert.AreEqual(Format(POSEntry."Entry No."), SelectText(Document, NamespaceManager, LineXPath + '/s:nr'), 'ctLine nr must reference the cashtransaction nr.');
        _Assert.AreEqual('10000', SelectText(Document, NamespaceManager, LineXPath + '/s:lineID'), 'lineID must be the line number.');
        _Assert.AreEqual(ItemNo, SelectText(Document, NamespaceManager, LineXPath + '/s:artID'), 'artID must be the item number.');
        _Assert.AreEqual('2', SelectText(Document, NamespaceManager, LineXPath + '/s:qnt'), 'qnt must be the line quantity.');
        _Assert.AreEqual('250', SelectText(Document, NamespaceManager, LineXPath + '/s:lineAmntIn'), 'lineAmntIn must be the amount including VAT.');
        _Assert.AreEqual('200', SelectText(Document, NamespaceManager, LineXPath + '/s:lineAmntEx'), 'lineAmntEx must be the amount excluding VAT.');
        _Assert.AreEqual('C', SelectText(Document, NamespaceManager, LineXPath + '/s:amntTp'), 'A sold line increases revenue and must be C.');
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, LineXPath + '/s:lineType'), '05', '');

        // [THEN] The line VAT is reported
        _Assert.AreEqual('25', SelectText(Document, NamespaceManager, LineXPath + '/s:vat/s:vatPerc'), 'vatPerc must be the line VAT %.');
        _Assert.AreEqual('50', SelectText(Document, NamespaceManager, LineXPath + '/s:vat/s:vatAmnt'), 'vatAmnt must be the line VAT amount.');
        _Assert.AreEqual('200', SelectText(Document, NamespaceManager, LineXPath + '/s:vat/s:vatBasAmnt'), 'vatBasAmnt must be the line amount excluding VAT.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReturnedLineIsDebit()
    var
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        LineXPath: Text;
    begin
        // [SCENARIO] A returned line decreases revenue, so it is amntTp D with positive amounts and quantity (the sign is carried by amntTp).
        Initialize();

        // [GIVEN] A sale with a returned item
        CreateFiscalSale(POSEntry, 'DKCT-RETLN', '', -125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), -1, -125, -100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The line is a debit with absolute amounts
        LineXPath := TransactionXPathFor(POSEntry) + '/s:ctLine';
        _Assert.AreEqual('D', SelectText(Document, NamespaceManager, LineXPath + '/s:amntTp'), 'A returned line must be D.');
        _Assert.AreEqual('125', SelectText(Document, NamespaceManager, LineXPath + '/s:lineAmntIn'), 'The amount sign is carried by amntTp.');
        _Assert.AreEqual('1', SelectText(Document, NamespaceManager, LineXPath + '/s:qnt'), 'The quantity sign is carried by amntTp.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonItemLineReferencesAnExportedArticle()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        ArticleXPath: Text;
        ArtID: Text;
    begin
        // [SCENARIO] SKAT's validation script (v1.0.9) requires artID on every sale line, and every artID must exist in articles.
        Initialize();

        // [GIVEN] A sale of a gift voucher, which is not an item
        CreateFiscalSale(POSEntry, 'DKCT-VOUCH', '', 100);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::Voucher, 'DKGIFTVOUCHER', 1, 100, 100, 'Gift voucher');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The line references the voucher number, and that reference is an article
        ArtID := SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:ctLine/s:artID');
        _Assert.IsTrue(ArtID.Contains('DKGIFTVOUCHER'), 'artID must identify the voucher number.');
        ArticleXPath := StrSubstNo('/s:auditfile/s:company/s:articles/s:article[s:artID=''%1'']', ArtID);
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, ArticleXPath), 'Every artID used in a ctLine must be exported as exactly one article.');
        _Assert.AreEqual('Gift voucher', SelectText(Document, NamespaceManager, ArticleXPath + '/s:artDesc'), 'The article description must be the line description.');
        _Assert.AreEqual(
            Format(POSEntry."Entry Date", 0, 9), SelectText(Document, NamespaceManager, ArticleXPath + '/s:dateOfEntry'),
            'dateOfEntry is mandatory in the XSD and must be the date the article was first sold.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonItemLineNumberDoesNotCollideWithAnItemNumber()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        ItemNo: Code[20];
        ArtID: Text;
    begin
        // [SCENARIO] PR review: G/L, customer and voucher numbers share the artID space with item numbers, so equal numbers must not produce two articles with the same artID.
        Initialize();

        // [GIVEN] An item, and a sale of a G/L account line whose number equals that item number
        ItemNo := CreateItemNo();
        CreateFiscalSale(POSEntry, 'DKCT-COLL', '', 100);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::"G/L Account", ItemNo, 1, 100, 100, 'Service fee');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The item keeps its own single article, and the G/L line references a different one
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, StrSubstNo('/s:auditfile/s:company/s:articles/s:article[s:artID=''%1'']', ItemNo)),
            'An artID must identify exactly one article.');
        ArtID := SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:ctLine/s:artID');
        _Assert.AreNotEqual(ItemNo, ArtID, 'A G/L line must not reference the article of an item with the same number.');
        _Assert.AreEqual(
            'Service fee', SelectText(Document, NamespaceManager, StrSubstNo('/s:auditfile/s:company/s:articles/s:article[s:artID=''%1'']/s:artDesc', ArtID)),
            'The G/L line must reference its own article.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ArticleDateIsTheEarliestSaleInThePeriod()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        EarlierPOSEntry: Record "NPR POS Entry";
        LaterPOSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        ArtID: Text;
    begin
        // [SCENARIO] PR review: entries are exported per store and POS unit, so the first entry the export reaches is not always the earliest sale.
        Initialize();

        // [GIVEN] The same voucher sold today and, in an entry created afterwards, yesterday
        CreatePOSStoreAndUnit(POSStore, POSUnit);
        CreateFiscalPOSEntry(POSStore.Code, POSUnit."No.", WorkDate(), 'DKCT-DATE2', 100);
        FindFiscalEntry(LaterPOSEntry, 'DKCT-DATE2');
        AddSalesLine(LaterPOSEntry, 10000, SalesLine.Type::Voucher, 'DKVOUCHERDATE', 1, 100, 100, 'Gift voucher');
        CreateFiscalPOSEntry(POSStore.Code, POSUnit."No.", WorkDate() - 1, 'DKCT-DATE1', 100);
        FindFiscalEntry(EarlierPOSEntry, 'DKCT-DATE1');
        AddSalesLine(EarlierPOSEntry, 10000, SalesLine.Type::Voucher, 'DKVOUCHERDATE', 1, 100, 100, 'Gift voucher');

        // [WHEN] The SAF-T file is exported for both days
        RunExportForPeriod(WorkDate() - 1, WorkDate(), Document, NamespaceManager);

        // [THEN] The article's dateOfEntry is the earlier sale
        ArtID := SelectText(Document, NamespaceManager, TransactionXPathFor(EarlierPOSEntry) + '/s:ctLine/s:artID');
        _Assert.AreEqual(
            Format(WorkDate() - 1, 0, 9),
            SelectText(Document, NamespaceManager, StrSubstNo('/s:auditfile/s:company/s:articles/s:article[s:artID=''%1'']/s:dateOfEntry', ArtID)),
            'dateOfEntry must be the earliest sale of the article in the period.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EFTPaymentFallsBackToTheAuthorisationNumber()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: the External Terminal integration only stores the authorisation number, which is the terminal reference printed on the receipt.
        Initialize();

        // [GIVEN] A card payment whose EFT transaction only has an authorisation number
        CreatePaymentMethod(EFTPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        CreateFiscalSale(POSEntry, 'DKCT-AUTH', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(POSEntry, 10000, EFTPaymentMethod.Code, 125);
        CreateEFTTransaction(EFTTransactionRequest, POSEntry, 10000);
        EFTTransactionRequest."Authorisation Number" := 'AUTH-123456';
        EFTTransactionRequest.Modify();

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The authorisation number is the payment reference
        _Assert.AreEqual(
            'AUTH-123456', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:payment/s:paymentRefID'),
            'paymentRefID must fall back to the authorisation number.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentMappedToMobilePayCarriesItsReference()
    var
        DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MobilePayPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: whether paymentRefID is required follows the SKAT code (12002, 12003, 12011), not the POS processing type.
        Initialize();

        // [GIVEN] A non-EFT payment method mapped to MobilePay, with a terminal transaction for the payment
        CreatePaymentMethod(MobilePayPaymentMethod, Enum::"NPR Payment Processing Type"::CHECK);
        DKPOSPaymMethMapping."POS Payment Method Code" := MobilePayPaymentMethod.Code;
        DKPOSPaymMethMapping."SAF-T Payment Type" := DKPOSPaymMethMapping."SAF-T Payment Type"::"Mobile Phone App";
        DKPOSPaymMethMapping.Insert();
        CreateFiscalSale(POSEntry, 'DKCT-MOBILE', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(POSEntry, 10000, MobilePayPaymentMethod.Code, 125);
        CreateEFTTransaction(EFTTransactionRequest, POSEntry, 10000);
        EFTTransactionRequest."External Transaction ID" := 'MOBILEPAY-777';
        EFTTransactionRequest.Modify();

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The MobilePay payment carries its reference
        _Assert.AreEqual(
            'MOBILEPAY-777', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:payment/s:paymentRefID'),
            'A payment reported as 12011 must carry paymentRefID.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashRoundingDoesNotTurnACashSaleIntoAReturn()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: POS Create Entry inserts rounding lines with reversed sign, so rounding a sale down adds a negative line. That is not a returned item.
        Initialize();

        // [GIVEN] A sale of an item at 100.25 paid with 100.00 in cash, with a -0.25 rounding line
        CreateFiscalSale(POSEntry, 'DKCT-ROUND', '', 100);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 100.25, 80.2);
        AddSalesLine(POSEntry, 20000, SalesLine.Type::Rounding, '', -1, -0.25, -0.25, 'Rounding');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction is still a cash sale
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11001');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashRoundingDoesNotTurnAReturnIntoASale()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: a pure return with a positive rounding line must stay a Return payment (11006).
        Initialize();

        // [GIVEN] A return of an item at 100.25 refunded with 100.50 in cash, with a +0.25 rounding line
        CreateFiscalSale(POSEntry, 'DKCT-RETRND', '', -100.5);
        AddItemLine(POSEntry, 10000, CreateItemNo(), -1, -100.25, -80.2);
        AddSalesLine(POSEntry, 20000, SalesLine.Type::Rounding, '', 1, 0.25, 0.25, 'Rounding');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction is still a return payment
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11006');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleSignedOutsideTheExportPeriodKeepsItsSignature()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: the audit log timestamp is the signing time, which can fall outside the export period (sales around midnight, time zones).
        // The signature of every exported transaction must still be found.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] A sale dated 10 days ago whose audit log entry was signed now
        WorkDate(CalcDate('<-10D>', Today()));
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-SIGNDAY');

        // [WHEN] The SAF-T file is exported for the sale's date
        RunExport(Document, NamespaceManager);
        WorkDate(OriginalWorkDate);

        // [THEN] The transaction carries its signature and certificate
        _Assert.AreNotEqual('', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:signature'), 'The signature must be exported.');
        _Assert.AreNotEqual('', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:certificateData'), 'The certificate must be exported.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SpecialCharactersAreEscapedOnlyOnce()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: text was XML-escaped by the helper and again by the XML writer, so SKAT read 'Salt &amp;amp; Pepper'.
        Initialize();

        // [GIVEN] A sale of an item whose line description contains '&' and '<'
        CreateFiscalSale(POSEntry, 'DKCT-ESC', '', 125);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::Item, CreateItemNo(), 1, 125, 100, 'Salt & Pepper <XL>');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The description reads back exactly as entered
        _Assert.AreEqual(
            'Salt & Pepper <XL>', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:ctLine/s:cashTransLineDescr'),
            'Text must be escaped exactly once.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeletingAPaymentMethodDeletesItsDKMapping()
    var
        DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        // [SCENARIO] BCQuality review: a mapping left behind by a deleted payment method would be applied to a new method that reuses the code.
        Initialize();

        // [GIVEN] An EFT payment method mapped to Dankort
        CreatePaymentMethod(POSPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        DKPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
        DKPOSPaymMethMapping."SAF-T Payment Type" := DKPOSPaymMethMapping."SAF-T Payment Type"::"Debit Card";
        DKPOSPaymMethMapping.Insert();

        // [WHEN] The payment method is deleted
        POSPaymentMethod.Delete(true);

        // [THEN] Its mapping is deleted too
        _Assert.IsFalse(DKPOSPaymMethMapping.Get(POSPaymentMethod.Code), 'The DK mapping of a deleted payment method must be deleted.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLinesAreReportedWithTheMappedMeansOfPayment()
    var
        DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
        CashPaymentMethod: Record "NPR POS Payment Method";
        DankortPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        Salesperson: Record "Salesperson/Purchaser";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        PaymentXPath: Text;
    begin
        // [SCENARIO] SKAT technical description v2.0 section 6.8: each means of payment is a payment element, declared in basics with basicType 12.
        Initialize();

        // [GIVEN] A cash payment method and an EFT payment method mapped to Dankort
        CreatePaymentMethod(CashPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
        CreatePaymentMethod(DankortPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        DKPOSPaymMethMapping."POS Payment Method Code" := DankortPaymentMethod.Code;
        DKPOSPaymMethMapping."SAF-T Payment Type" := DKPOSPaymMethMapping."SAF-T Payment Type"::"Debit Card";
        DKPOSPaymMethMapping.Insert();

        // [GIVEN] A sale paid partly in cash and partly by Dankort
        _LibraryPOSMasterData.CreateSalespersonForPOSUsage(Salesperson);
        CreateFiscalSale(POSEntry, 'DKCT-PAY', Salesperson.Code, 250);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 2, 250, 200);
        AddPaymentLine(POSEntry, 10000, CashPaymentMethod.Code, 50);
        AddPaymentLine(POSEntry, 20000, DankortPaymentMethod.Code, 200);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] Both payments are reported with amount and employee
        _Assert.AreEqual(2, CountNodes(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:payment'), 'Each payment line must be a payment element.');
        PaymentXPath := StrSubstNo('%1/s:payment[s:paymentType=''%2'']', TransactionXPathFor(POSEntry), DankortPaymentMethod.Code);
        _Assert.AreEqual('200', SelectText(Document, NamespaceManager, PaymentXPath + '/s:paidAmnt'), 'paidAmnt must be the paid amount.');
        _Assert.AreEqual(Salesperson.Code, SelectText(Document, NamespaceManager, PaymentXPath + '/s:empID'), 'The payment empID must be the salesperson.');

        // [THEN] The mapped method is Dankort (12002), and the unmapped cash method falls back to Cash (12001)
        AssertBasic(Document, NamespaceManager, DankortPaymentMethod.Code, '12', '12002');
        AssertBasic(Document, NamespaceManager, CashPaymentMethod.Code, '12', '12001');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnmappedEFTPaymentMethodIsReportedAsCreditCard()
    var
        EFTPaymentMethod: Record "NPR POS Payment Method";
        VoucherPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] Without a DK mapping, the means of payment is derived from the processing type.
        Initialize();

        // [GIVEN] An unmapped EFT and an unmapped voucher payment method
        CreatePaymentMethod(EFTPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        CreatePaymentMethod(VoucherPaymentMethod, Enum::"NPR Payment Processing Type"::VOUCHER);

        // [GIVEN] A sale paid with both
        CreateFiscalSale(POSEntry, 'DKCT-NOMAP', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(POSEntry, 10000, EFTPaymentMethod.Code, 100);
        AddPaymentLine(POSEntry, 20000, VoucherPaymentMethod.Code, 25);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] EFT falls back to Credit card (12003) and voucher to Gift token (12005)
        AssertBasic(Document, NamespaceManager, EFTPaymentMethod.Code, '12', '12003');
        AssertBasic(Document, NamespaceManager, VoucherPaymentMethod.Code, '12', '12005');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EFTPaymentCarriesTheTerminalTransactionID()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] Code list changelog v1.5.0: paymentRefID is mandatory for integrated card and mobile payments (12002, 12003, 12011).
        Initialize();

        // [GIVEN] A sale paid by an integrated card terminal
        CreatePaymentMethod(EFTPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        CreateFiscalSale(POSEntry, 'DKCT-EFT', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(POSEntry, 10000, EFTPaymentMethod.Code, 125);
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Sales Ticket No." := POSEntry."Document No.";
        EFTTransactionRequest."Register No." := POSEntry."POS Unit No.";
        EFTTransactionRequest."Sales Line No." := 10000;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Transaction ID" := 'DKTERMINAL-4711';
        EFTTransactionRequest.Insert(true);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The payment carries the terminal's transaction ID
        _Assert.AreEqual(
            'DKTERMINAL-4711', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:payment/s:paymentRefID'),
            'paymentRefID must be the transaction ID from the payment terminal.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SignedTransactionCarriesThePublicSigningCertificate()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        CertificateData: Text;
        CR: Char;
        LF: Char;
    begin
        // [SCENARIO] Digital-signature guide v1.5.2 section 1.5.2: certificateData holds the OCES3 certificate without private key, as PEM X.509.
        Initialize();

        // [GIVEN] DK fiscalization with a signing certificate and a signed sale
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-SIGN');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] certificateData is the public certificate in PEM format
        CertificateData := SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:certificateData');
        _Assert.IsTrue(CertificateData.StartsWith('-----BEGIN CERTIFICATE-----'), 'certificateData must start with the PEM header.');
        CR := 13;
        LF := 10;
        CertificateData := DelChr(CertificateData, '=', Format(CR) + Format(LF));
        _Assert.AreEqual(
            '-----BEGIN CERTIFICATE-----' + _LibraryDKFiscal.GetRSA3072TestCertPublicDER() + '-----END CERTIFICATE-----', CertificateData,
            'certificateData must be the public part of the signing certificate.');
        _Assert.AreNotEqual('', SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:signature'), 'The signed sale must carry its signature.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashTransactionElementsFollowTheSchemaSequence()
    var
        CashPaymentMethod: Record "NPR POS Payment Method";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        VATPostingSetup: Record "VAT Posting Setup";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        TransactionXPath: Text;
    begin
        // [SCENARIO] SKAT XSD v1.0.4 declares the cashtransaction, ctLine, vat and payment children as xsd:sequence, so their order is part of validity.
        Initialize();

        // [GIVEN] A signed cash sale with an item line and a cash payment
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        _LibraryPOSMasterData.CreateSalespersonForPOSUsage(Salesperson);
        CreatePaymentMethod(CashPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
        CreateVATPostingSetup(VATPostingSetup, 25);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-ORDER');
        POSEntry."Salesperson Code" := Salesperson.Code;
        POSEntry.Modify();
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, VATPostingSetup);
        AddPaymentLine(POSEntry, 10000, CashPaymentMethod.Code, 125);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] Every element appears in the order of the XSD sequence
        TransactionXPath := TransactionXPathFor(POSEntry);
        _Assert.AreEqual(
            'nr,transID,transType,transAmntIn,transAmntEx,amntTp,empID,transDate,transTime,ctLine,payment,signature,keyVersion,certificateData,voidTransaction,trainingID',
            ChildNames(Document, NamespaceManager, TransactionXPath), 'The cashtransaction children must follow the XSD sequence.');
        _Assert.AreEqual(
            'nr,lineID,lineType,artID,qnt,lineAmntIn,lineAmntEx,amntTp,cashTransLineDescr,vat',
            ChildNames(Document, NamespaceManager, TransactionXPath + '/s:ctLine'), 'The ctLine children must follow the XSD sequence.');
        _Assert.AreEqual(
            'vatCode,vatPerc,vatAmnt,vatAmntTp,vatBasAmnt',
            ChildNames(Document, NamespaceManager, TransactionXPath + '/s:ctLine/s:vat'), 'The ctLine vat children must follow the XSD sequence.');
        _Assert.AreEqual(
            'paymentType,paidAmnt,empID',
            ChildNames(Document, NamespaceManager, TransactionXPath + '/s:payment'), 'The payment children must follow the XSD sequence.');
        _Assert.AreEqual(
            'vatCode,dateOfEntry,vatDesc,standardVatCode',
            ChildNames(Document, NamespaceManager, VatCodeDetailXPath(VATPostingSetup."VAT Identifier")), 'The vatCodeDetail children must follow the XSD sequence.');
        _Assert.AreEqual(
            'periodNumber,periodDesc,startDatePeriod,startTimePeriod,endDatePeriod,endTimePeriod',
            ChildNames(Document, NamespaceManager, '/s:auditfile/s:company/s:periods/s:period'), 'The period children must follow the XSD sequence.');

        // [THEN] vatCodeDetails and periods come between generalLedger and employees in company
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:company/s:generalLedger/following-sibling::*[1][self::s:vatCodeDetails]'),
            'vatCodeDetails must directly follow generalLedger in company.');
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:company/s:vatCodeDetails/following-sibling::*[1][self::s:periods]'),
            'periods must directly follow vatCodeDetails in company.');
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:company/s:periods/following-sibling::*[1][self::s:employees]'),
            'employees must directly follow periods in company.');

        // [THEN] basics comes between articles and location in company
        _Assert.AreEqual(
            1, CountNodes(Document, NamespaceManager, '/s:auditfile/s:company/s:articles/following-sibling::*[1][self::s:basics]'),
            'basics must directly follow articles in company.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EachCodeIsDeclaredOnceInBasics()
    var
        CashPaymentMethod: Record "NPR POS Payment Method";
        FirstPOSEntry: Record "NPR POS Entry";
        SecondPOSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        BasicIDs: List of [Text];
        Nodes: XmlNodeList;
        Node: XmlNode;
        BasicID: Text;
    begin
        // [SCENARIO] SKAT's validation script rejects duplicate basicIDs across all basicTypes.
        Initialize();

        // [GIVEN] Two cash sales of the same kind, paid in cash
        CreatePaymentMethod(CashPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
        CreateFiscalSale(FirstPOSEntry, 'DKCT-DUP1', '', 125);
        AddItemLine(FirstPOSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(FirstPOSEntry, 10000, CashPaymentMethod.Code, 125);
        CreateFiscalSale(SecondPOSEntry, 'DKCT-DUP2', '', 125);
        AddItemLine(SecondPOSEntry, 10000, CreateItemNo(), 1, 125, 100);
        AddPaymentLine(SecondPOSEntry, 10000, CashPaymentMethod.Code, 125);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] No basicID is declared twice
        Document.SelectNodes('/s:auditfile/s:company/s:basics/s:basic/s:basicID', NamespaceManager, Nodes);
        _Assert.AreNotEqual(0, Nodes.Count(), 'basics must be exported.');
        foreach Node in Nodes do begin
            BasicID := Node.AsXmlElement().InnerText();
            _Assert.IsFalse(BasicIDs.Contains(BasicID), StrSubstNo('basicID ''%1'' is declared more than once.', BasicID));
            BasicIDs.Add(BasicID);
        end;

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VATCodeOfEachLineIsDeclaredInVatCodeDetails()
    var
        POSEntry: Record "NPR POS Entry";
        StandardVATPostingSetup: Record "VAT Posting Setup";
        ZeroVATPostingSetup: Record "VAT Posting Setup";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        StandardDetailXPath: Text;
        ZeroDetailXPath: Text;
    begin
        // [SCENARIO] SKAT technical description v1.3 sections 3.10-3.11: vatCodeDetails is mandatory and maps every vatCode used on a line to a standard VAT code.
        Initialize();

        // [GIVEN] A sale with a 25 % line and a 0 % line, each posted with its own VAT posting setup
        CreateVATPostingSetup(StandardVATPostingSetup, 25);
        CreateVATPostingSetup(ZeroVATPostingSetup, 0);
        CreateFiscalSale(POSEntry, 'DKVAT-CODES', '', 175);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, StandardVATPostingSetup);
        AddItemLine(POSEntry, 20000, CreateItemNo(), 1, 50, 50);
        SetLineVAT(POSEntry, 20000, ZeroVATPostingSetup);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] Each ctLine carries the VAT identifier of its line as vatCode
        _Assert.AreEqual(
            StandardVATPostingSetup."VAT Identifier", SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:ctLine[s:lineID=''10000'']/s:vat/s:vatCode'),
            'The 25 % line must carry its VAT identifier as vatCode.');
        _Assert.AreEqual(
            ZeroVATPostingSetup."VAT Identifier", SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:ctLine[s:lineID=''20000'']/s:vat/s:vatCode'),
            'The 0 % line must carry its VAT identifier as vatCode.');

        // [THEN] Each vatCode is declared in vatCodeDetails with its first use, the setup description and SKAT's standard code (1 = 25 %, 0 = 0 %)
        StandardDetailXPath := VatCodeDetailXPath(StandardVATPostingSetup."VAT Identifier");
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, StandardDetailXPath), 'The 25 % vatCode must be declared once in vatCodeDetails.');
        _Assert.AreEqual(Format(WorkDate(), 0, 9), SelectText(Document, NamespaceManager, StandardDetailXPath + '/s:dateOfEntry'), 'dateOfEntry must be the date the code was first used.');
        _Assert.AreEqual(StandardVATPostingSetup.Description, SelectText(Document, NamespaceManager, StandardDetailXPath + '/s:vatDesc'), 'vatDesc must be the VAT posting setup description.');
        _Assert.AreEqual('1', SelectText(Document, NamespaceManager, StandardDetailXPath + '/s:standardVatCode'), 'A 25 % code must map to standard VAT code 1.');

        ZeroDetailXPath := VatCodeDetailXPath(ZeroVATPostingSetup."VAT Identifier");
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, ZeroDetailXPath), 'The 0 % vatCode must be declared once in vatCodeDetails.');
        _Assert.AreEqual('0', SelectText(Document, NamespaceManager, ZeroDetailXPath + '/s:standardVatCode'), 'A 0 % code must map to standard VAT code 0.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VATCodeUsedOnSeveralDaysIsDeclaredOnceWithItsFirstUse()
    var
        EarlierPOSEntry: Record "NPR POS Entry";
        LaterPOSEntry: Record "NPR POS Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        DetailXPath: Text;
    begin
        // [SCENARIO] SKAT technical description v1.3 section 3.11: dateOfEntry is the first use of the code, and a code is declared once.
        Initialize();

        // [GIVEN] The same VAT code used on a sale today and, on another POS unit, on a sale yesterday
        CreateVATPostingSetup(VATPostingSetup, 25);
        CreateFiscalSale(LaterPOSEntry, 'DKVAT-LATER', '', 125);
        AddItemLine(LaterPOSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(LaterPOSEntry, 10000, VATPostingSetup);
        CreateFiscalSale(EarlierPOSEntry, 'DKVAT-EARLIER', '', 125);
        EarlierPOSEntry."Entry Date" := WorkDate() - 1;
        EarlierPOSEntry.Modify();
        AddItemLine(EarlierPOSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(EarlierPOSEntry, 10000, VATPostingSetup);

        // [WHEN] Both days are exported
        RunExportForPeriod(WorkDate() - 1, WorkDate(), Document, NamespaceManager);

        // [THEN] The code is declared once, dated on its first use
        DetailXPath := VatCodeDetailXPath(VATPostingSetup."VAT Identifier");
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, DetailXPath), 'A vatCode used on several lines must be declared once.');
        _Assert.AreEqual(Format(WorkDate() - 1, 0, 9), SelectText(Document, NamespaceManager, DetailXPath + '/s:dateOfEntry'), 'dateOfEntry must be the earliest use in the export.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VATCodeWithoutSetupDescriptionIsDescribedByItsCode()
    var
        POSEntry: Record "NPR POS Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: vatDesc is mandatory in vatCodeDetail, but the VAT posting setup description is optional and often blank.
        // A blank description dropped vatDesc from the file.
        Initialize();

        // [GIVEN] A sale whose line uses a VAT posting setup without a description
        CreateVATPostingSetup(VATPostingSetup, 25);
        VATPostingSetup.Description := '';
        VATPostingSetup.Modify();
        CreateFiscalSale(POSEntry, 'DKVAT-NODESC', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, VATPostingSetup);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The vatCode is described by the code itself
        _Assert.AreEqual(
            VATPostingSetup."VAT Identifier", SelectText(Document, NamespaceManager, VatCodeDetailXPath(VATPostingSetup."VAT Identifier") + '/s:vatDesc'),
            'vatDesc must fall back to the vatCode when the VAT posting setup has no description.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportPeriodIsReportedAsCalendarMonthPeriods()
    var
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        StartingDate: Date;
        EndingDate: Date;
        PeriodXPath: Text;
    begin
        // [SCENARIO] SKAT technical description v1.3 sections 3.12-3.13: periods is mandatory and lists the periods the audit file covers.
        Initialize();

        // [GIVEN] An export from the middle of January to the middle of February
        StartingDate := DMY2Date(15, 1, Date2DMY(WorkDate(), 3));
        EndingDate := DMY2Date(10, 2, Date2DMY(WorkDate(), 3));

        // [WHEN] The SAF-T file is exported
        RunExportForPeriod(StartingDate, EndingDate, Document, NamespaceManager);

        // [THEN] There is one period per calendar month, cut to the export dates and covering whole days
        PeriodXPath := '/s:auditfile/s:company/s:periods/s:period';
        _Assert.AreEqual(2, CountNodes(Document, NamespaceManager, PeriodXPath), 'Each calendar month in the export must be one period.');

        _Assert.AreEqual('1', SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:periodNumber'), 'The first period must be number 1.');
        _Assert.AreNotEqual('', SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:periodDesc'), 'A period must have a description.');
        _Assert.AreEqual(Format(StartingDate, 0, 9), SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:startDatePeriod'), 'The first period must start on the export starting date.');
        _Assert.AreEqual('00:00:00', SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:startTimePeriod'), 'A period must start at the beginning of the day.');
        _Assert.AreEqual(Format(CalcDate('<CM>', StartingDate), 0, 9), SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:endDatePeriod'), 'The first period must end on the last day of January.');
        _Assert.AreEqual('23:59:59', SelectText(Document, NamespaceManager, PeriodXPath + '[1]/s:endTimePeriod'), 'A period must end at the end of the day.');

        _Assert.AreEqual('2', SelectText(Document, NamespaceManager, PeriodXPath + '[2]/s:periodNumber'), 'The second period must be number 2.');
        _Assert.AreEqual(Format(DMY2Date(1, 2, Date2DMY(WorkDate(), 3)), 0, 9), SelectText(Document, NamespaceManager, PeriodXPath + '[2]/s:startDatePeriod'), 'The second period must start on the first day of February.');
        _Assert.AreEqual(Format(EndingDate, 0, 9), SelectText(Document, NamespaceManager, PeriodXPath + '[2]/s:endDatePeriod'), 'The last period must end on the export ending date.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CashRoundingIsReportedInTheRoundingElement()
    var
        CashPaymentMethod: Record "NPR POS Payment Method";
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        TransactionXPath: Text;
    begin
        // [SCENARIO] PR review: SKAT XSD v1.0.4 and technical description v2.0 section 6.7 record rounding in its own rounding element.
        // As a ctLine the rounding counted as revenue, and the ctLines no longer added up to transAmntIn.
        Initialize();

        // [GIVEN] A sale of an item at 99.95 paid with 100.00 in cash, with a 0.05 rounding line
        CreatePaymentMethod(CashPaymentMethod, Enum::"NPR Payment Processing Type"::CASH);
        CreateFiscalSale(POSEntry, 'DKCT-RNDEL', '', 99.95);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 99.95, 79.96);
        AddSalesLine(POSEntry, 20000, SalesLine.Type::Rounding, '', 1, 0.05, 0.05, 'Rounding');
        AddPaymentLine(POSEntry, 10000, CashPaymentMethod.Code, 100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] Only the item is a ctLine, and the rounding amount is in the rounding element between the lines and the payment
        TransactionXPath := TransactionXPathFor(POSEntry);
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, TransactionXPath + '/s:ctLine'), 'A rounding line must not be exported as a ctLine.');
        _Assert.AreEqual('0.05', SelectText(Document, NamespaceManager, TransactionXPath + '/s:rounding/s:roundingAmnt'), 'roundingAmnt must be the rounding amount.');
        _Assert.IsTrue(
            ChildNames(Document, NamespaceManager, TransactionXPath).Contains('ctLine,rounding,payment'),
            'The rounding element must follow the ctLines and precede the payments, as in the XSD sequence.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayoutFromTheDrawerIsReportedAsOutPayment()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: code list v1.3.0 has 11010 (Out Payment) for money the company takes out of the drawer. It is not a return.
        Initialize();

        // [GIVEN] A payout of 2000 from the drawer
        CreateFiscalSale(POSEntry, 'DKCT-PAYOUT', '', -2000);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::Payout, 'PAYOUTACC', -1, -2000, -2000, 'Payout');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Out Payment
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11010');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayInToTheDrawerIsReportedAsInPayment()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: code list v1.3.0 has 11011 (In Payment) for money the company puts into the drawer. It is not a sale.
        Initialize();

        // [GIVEN] A pay-in of 500 to the drawer posted to a G/L account
        CreateFiscalSale(POSEntry, 'DKCT-PAYIN', '', 500);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::"G/L Account", 'PAYINACC', 1, 500, 500, 'Pay-in');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to In Payment
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11011');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CustomerPaymentOnAccountIsReportedAsReceivingPayment()
    var
        SalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: code list v1.3.0 has 11005 (Receiving payment) for a customer paying into their account. It is not a sale.
        Initialize();

        // [GIVEN] A customer paying 300 on account
        CreateFiscalSale(POSEntry, 'DKCT-ONACC', '', 300);
        AddSalesLine(POSEntry, 10000, SalesLine.Type::Customer, 'CUSTDEP', 1, 300, 300, 'Customer deposit');

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Receiving payment
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11005');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditSaleWithAReturnedItemIsReportedAsCreditSaleAndReturn()
    var
        POSEntry: Record "NPR POS Entry";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
    begin
        // [SCENARIO] PR review: code list v1.3.0 has 11017 (Credit sale and return), the credit counterpart of 11016.
        Initialize();

        // [GIVEN] A credit sale that sells one item and takes another back
        CreateFiscalSale(POSEntry, 'DKCT-CREDRET', '', 125);
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Credit Sale";
        POSEntry.Modify();
        AddItemLine(POSEntry, 10000, CreateItemNo(), 2, 250, 200);
        AddItemLine(POSEntry, 20000, CreateItemNo(), -1, -125, -100);

        // [WHEN] The SAF-T file is exported
        RunExport(Document, NamespaceManager);

        // [THEN] The transaction type maps to Credit sale and return
        AssertBasic(Document, NamespaceManager, SelectText(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:transType'), '11', '11017');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnsignedTransactionIsReportedBeforeTheExport()
    var
        POSUnit: Record "NPR POS Unit";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
        ExportDate: Date;
    begin
        // [SCENARIO] PR review: signature guideline v1.5.2 section 2.3 requires a signature on every exported cashtransaction, and the XSD makes signature mandatory.
        // A fiscal sale on a DK unit without a signature (e.g. a credit sale) made the export complete with a file SKAT rejects.
        Initialize();

        // [GIVEN] A fiscal sale on a DK fiscal POS unit that was never signed, on a day no other test uses
        ExportDate := CalcDate('<-40D>', WorkDate());
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateFiscalPOSEntry(POSUnit."POS Store Code", POSUnit."No.", ExportDate, 'DKCT-NOSIGN', 125);

        // [WHEN] The export is started for that day and the user declines to export a file that will not pass SKAT's validation
        CreateExportHeader(SAFTExportHeader, ExportDate, ExportDate, false);
        EnqueueConfirm('DKCT-NOSIGN has no digital signature', false);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] The user was warned about the unsigned sale, and no file was generated
        AssertAllConfirmsRaised();
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        _Assert.IsTrue(SAFTExportLine.IsEmpty(), 'No SAF-T file must be generated when the user declines.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MissingTerminalReferenceIsReportedBeforeTheExport()
    var
        DankortPaymentMethod: Record "NPR POS Payment Method";
        DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        NamespaceManager: XmlNamespaceManager;
        Document: XmlDocument;
        ExportDate: Date;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: technical description v2.0 section 6.8 makes paymentRefID mandatory for integrated 12002, 12003 and 12011 payments.
        // Without a reference the element was silently dropped.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] A signed sale on a DK fiscal POS unit, paid by Dankort with no terminal transaction on record, on a day no other test uses
        ExportDate := CalcDate('<-50D>', OriginalWorkDate);
        WorkDate(ExportDate);
        CreatePaymentMethod(DankortPaymentMethod, Enum::"NPR Payment Processing Type"::EFT);
        DKPOSPaymMethMapping."POS Payment Method Code" := DankortPaymentMethod.Code;
        DKPOSPaymMethMapping."SAF-T Payment Type" := DKPOSPaymMethMapping."SAF-T Payment Type"::"Debit Card";
        DKPOSPaymMethMapping.Insert();
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-NOREF');
        AddPaymentLine(POSEntry, 10000, DankortPaymentMethod.Code, 125);

        // [WHEN] The export is started, the user is warned about the missing reference and chooses to export anyway
        EnqueueConfirm('DKCT-NOREF has a ' + DankortPaymentMethod.Code + ' payment without', true);
        RunExport(Document, NamespaceManager);
        WorkDate(OriginalWorkDate);

        // [THEN] The file is still generated with the payment
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, TransactionXPathFor(POSEntry) + '/s:payment'), 'The payment must still be exported.');

        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TransactionSignedWithAReplacedCertificateIsReportedBeforeTheExport()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
        ExportDate: Date;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: certificateData is mandatory in the XSD, and only the current certificate is stored.
        // A sale signed before the certificate was replaced was exported without certificateData and nothing told the user.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] A sale signed on a DK fiscal POS unit, after which the signing certificate is replaced, on a day no other test uses
        ExportDate := CalcDate('<-60D>', OriginalWorkDate);
        WorkDate(ExportDate);
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-OLDCERT');
        WorkDate(OriginalWorkDate);
        _LibraryDKFiscal.StoreExistingRSA2048SigningCertificate();

        // [WHEN] The export is started for that day and the user declines
        CreateExportHeader(SAFTExportHeader, ExportDate, ExportDate, false);
        EnqueueConfirm('DKCT-OLDCERT was signed with a certificate', false);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] The user was warned about the sale whose certificate cannot be exported
        AssertAllConfirmsRaised();

        // Later tests in this codeunit export sales signed with the original certificate.
        DKAuditMgt.SetSigningCertificate(_LibraryDKFiscal.GetRSA3072TestCert());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VATCodeUsedForZeroRatedAndVATLiableLinesIsReportedBeforeTheExport()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        StandardVATPostingSetup: Record "VAT Posting Setup";
        ZeroVATPostingSetup: Record "VAT Posting Setup";
        ExportDate: Date;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: Business Central only keeps one VAT % per VAT identifier within a VAT business posting group.
        // An identifier set up at 25 % in one group and 0 % in another got the standard VAT code of whichever line was read first.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] One VAT identifier set up at 25 % in one VAT business posting group and at 0 % in another
        CreateVATPostingSetup(StandardVATPostingSetup, 25);
        CreateVATPostingSetup(ZeroVATPostingSetup, 0);
        ZeroVATPostingSetup."VAT Identifier" := StandardVATPostingSetup."VAT Identifier";
        ZeroVATPostingSetup.Modify();

        // [GIVEN] A signed sale on a DK fiscal POS unit with a line under each setup, on a day no other test uses
        ExportDate := CalcDate('<-70D>', OriginalWorkDate);
        WorkDate(ExportDate);
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-MIXEDVAT');
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, StandardVATPostingSetup);
        AddItemLine(POSEntry, 20000, CreateItemNo(), 1, 50, 50);
        SetLineVAT(POSEntry, 20000, ZeroVATPostingSetup);
        WorkDate(OriginalWorkDate);

        // [WHEN] The export is started for that day and the user declines
        CreateExportHeader(SAFTExportHeader, ExportDate, ExportDate, false);
        EnqueueConfirm(StandardVATPostingSetup."VAT Identifier" + ' is used for both zero-rated and VAT-liable lines', false);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] The user was warned that the identifier cannot be mapped to one standard VAT code
        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VATCodeUsedAtTwoRatesOnAUnitWithoutDKAuditIsReportedBeforeTheExport()
    var
        POSEntry: Record "NPR POS Entry";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        StandardVATPostingSetup: Record "VAT Posting Setup";
        ZeroVATPostingSetup: Record "VAT Posting Setup";
        ExportDate: Date;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: the file holds the fiscal sales of every POS unit, but the VAT code check only looked at DK audited units.
        // A unit without the DK audit profile could make the export map an identifier to the wrong standard VAT code without a warning.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] One VAT identifier set up at 25 % in one VAT business posting group and at 0 % in another
        CreateVATPostingSetup(StandardVATPostingSetup, 25);
        CreateVATPostingSetup(ZeroVATPostingSetup, 0);
        ZeroVATPostingSetup."VAT Identifier" := StandardVATPostingSetup."VAT Identifier";
        ZeroVATPostingSetup.Modify();

        // [GIVEN] A fiscal sale on a POS unit without the DK audit profile, with a line under each setup, on a day no other test uses
        ExportDate := CalcDate('<-80D>', OriginalWorkDate);
        WorkDate(ExportDate);
        CreateFiscalSale(POSEntry, 'DKCT-NODKVAT', '', 125);
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, StandardVATPostingSetup);
        AddItemLine(POSEntry, 20000, CreateItemNo(), 1, 50, 50);
        SetLineVAT(POSEntry, 20000, ZeroVATPostingSetup);
        WorkDate(OriginalWorkDate);

        // [WHEN] The export is started for that day and the user declines
        CreateExportHeader(SAFTExportHeader, ExportDate, ExportDate, false);
        EnqueueConfirm(StandardVATPostingSetup."VAT Identifier" + ' is used for both zero-rated and VAT-liable lines', false);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] The user was warned that the identifier cannot be mapped to one standard VAT code
        AssertAllConfirmsRaised();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineWithoutVATIdentifierIsReportedBeforeTheExport()
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        VATPostingSetup: Record "VAT Posting Setup";
        ExportDate: Date;
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] PR review: VAT Identifier is optional on VAT Posting Setup and is copied onto POS lines as it is.
        // A line without one was exported without vatCode, and when no line had one the mandatory vatCodeDetails section was left out without a warning.
        Initialize();
        OriginalWorkDate := WorkDate();

        // [GIVEN] A VAT posting setup without a VAT identifier
        CreateVATPostingSetup(VATPostingSetup, 25);
        VATPostingSetup."VAT Identifier" := '';
        VATPostingSetup.Modify();

        // [GIVEN] A signed sale on a DK fiscal POS unit with a line under that setup, on a day no other test uses
        ExportDate := CalcDate('<-90D>', OriginalWorkDate);
        WorkDate(ExportDate);
        _LibraryDKFiscal.CreateDKAuditSetup(POSUnit);
        CreateSignedFiscalSale(POSUnit, POSEntry, 'DKCT-NOVATID');
        AddItemLine(POSEntry, 10000, CreateItemNo(), 1, 125, 100);
        SetLineVAT(POSEntry, 10000, VATPostingSetup);
        WorkDate(OriginalWorkDate);

        // [WHEN] The export is started for that day and the user declines
        CreateExportHeader(SAFTExportHeader, ExportDate, ExportDate, false);
        EnqueueConfirm(VATPostingSetup."VAT Prod. Posting Group" + ' have no ', false);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);

        // [THEN] The user was warned that the lines cannot be given a VAT code
        AssertAllConfirmsRaised();
    end;

    local procedure FindFiscalEntry(var POSEntry: Record "NPR POS Entry"; FiscalNo: Code[20])
    begin
        POSEntry.SetRange("Fiscal No.", FiscalNo);
        POSEntry.FindLast();
        POSEntry."Document No." := FiscalNo;
        POSEntry.Modify();
    end;

    local procedure CreateEFTTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSEntry: Record "NPR POS Entry"; SalesLineNo: Integer)
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Sales Ticket No." := POSEntry."Document No.";
        EFTTransactionRequest."Register No." := POSEntry."POS Unit No.";
        EFTTransactionRequest."Sales Line No." := SalesLineNo;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest.Insert(true);
    end;

    local procedure CreateFiscalSale(var POSEntry: Record "NPR POS Entry"; FiscalNo: Code[20]; SalespersonCode: Code[20]; AmountInclTax: Decimal)
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        CreatePOSStoreAndUnit(POSStore, POSUnit);
        CreateFiscalPOSEntry(POSStore.Code, POSUnit."No.", WorkDate(), FiscalNo, AmountInclTax);
        POSEntry.SetRange("Fiscal No.", FiscalNo);
        POSEntry.FindLast();
        POSEntry."Document No." := FiscalNo;
        POSEntry."Salesperson Code" := SalespersonCode;
        POSEntry.Modify();
    end;

    local procedure CreateSignedFiscalSale(POSUnit: Record "NPR POS Unit"; var POSEntry: Record "NPR POS Entry"; FiscalNo: Code[20])
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSSession: Codeunit "NPR POS Session";
    begin
        // An earlier POS test codeunit can leave its POS session open, and the audit log would then read that session's sale.
        POSSession.ClearAll();
        Clear(POSSession);

        CreateFiscalPOSEntry(POSUnit."POS Store Code", POSUnit."No.", WorkDate(), FiscalNo, 125);
        POSEntry.SetRange("Fiscal No.", FiscalNo);
        POSEntry.FindLast();
        POSEntry."Document No." := FiscalNo;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry.Modify();

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId(), POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSUnit."No.", '', '');
    end;

    local procedure AddItemLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; AmountInclVAT: Decimal; AmountExclVAT: Decimal)
    var
        SalesLine: Record "NPR POS Entry Sales Line";
    begin
        AddSalesLine(POSEntry, LineNo, SalesLine.Type::Item, ItemNo, Qty, AmountInclVAT, AmountExclVAT, 'Test item');
    end;

    local procedure AddSalesLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; LineType: Option Comment,"G/L Account",Item,Customer,Voucher,Payout,Rounding; No: Code[20]; Qty: Decimal; AmountInclVAT: Decimal; AmountExclVAT: Decimal; LineDescription: Text[100])
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := LineNo;
        POSEntrySalesLine."POS Store Code" := POSEntry."POS Store Code";
        POSEntrySalesLine."POS Unit No." := POSEntry."POS Unit No.";
        POSEntrySalesLine."Document No." := POSEntry."Document No.";
        POSEntrySalesLine.Type := LineType;
        POSEntrySalesLine."No." := No;
        POSEntrySalesLine.Description := LineDescription;
        POSEntrySalesLine.Quantity := Qty;
        POSEntrySalesLine."Amount Incl. VAT (LCY)" := AmountInclVAT;
        POSEntrySalesLine."Amount Excl. VAT (LCY)" := AmountExclVAT;
        POSEntrySalesLine."Amount Incl. VAT" := AmountInclVAT;
        POSEntrySalesLine."Amount Excl. VAT" := AmountExclVAT;
        if AmountExclVAT <> 0 then
            POSEntrySalesLine."VAT %" := Round((AmountInclVAT - AmountExclVAT) / AmountExclVAT * 100, 0.01);
        POSEntrySalesLine."VAT Base Amount" := AmountExclVAT;
        POSEntrySalesLine.Insert();
    end;

    local procedure AddPaymentLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; POSPaymentMethodCode: Code[10]; AmountLCY: Decimal)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.Init();
        POSEntryPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryPaymentLine."Line No." := LineNo;
        POSEntryPaymentLine."POS Store Code" := POSEntry."POS Store Code";
        POSEntryPaymentLine."POS Unit No." := POSEntry."POS Unit No.";
        POSEntryPaymentLine."Document No." := POSEntry."Document No.";
        POSEntryPaymentLine."POS Payment Method Code" := POSPaymentMethodCode;
        POSEntryPaymentLine.Amount := AmountLCY;
        POSEntryPaymentLine."Amount (LCY)" := AmountLCY;
        POSEntryPaymentLine."Payment Amount" := AmountLCY;
        POSEntryPaymentLine.Insert();
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; VATPct: Decimal)
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        _LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        _LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        _LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        // Its own code, so the tests tell the exported VAT identifier apart from the VAT product posting group.
        VATPostingSetup."VAT Identifier" := _LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), Database::"VAT Posting Setup");
        VATPostingSetup."VAT %" := VATPct;
        VATPostingSetup.Description := CopyStr('DK SAF-T test VAT ' + Format(VATPct), 1, MaxStrLen(VATPostingSetup.Description));
        VATPostingSetup.Modify();
    end;

    local procedure SetLineVAT(POSEntry: Record "NPR POS Entry"; LineNo: Integer; VATPostingSetup: Record "VAT Posting Setup")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.Get(POSEntry."Entry No.", LineNo);
        POSEntrySalesLine."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        POSEntrySalesLine."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        POSEntrySalesLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
        POSEntrySalesLine."VAT %" := VATPostingSetup."VAT %";
        POSEntrySalesLine.Modify();
    end;

    local procedure VatCodeDetailXPath(VATCode: Code[20]): Text
    begin
        exit(StrSubstNo('/s:auditfile/s:company/s:vatCodeDetails/s:vatCodeDetail[s:vatCode=''%1'']', VATCode));
    end;

    local procedure CreatePaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; ProcessingType: Enum "NPR Payment Processing Type")
    begin
        _LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, '', ProcessingType);
        POSPaymentMethod."Processing Type" := ProcessingType;
        POSPaymentMethod.Modify();
    end;

    local procedure CreateItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        _LibraryInventory.CreateItem(Item);
        exit(Item."No.");
    end;

    local procedure RunExport(var Document: XmlDocument; var NamespaceManager: XmlNamespaceManager)
    begin
        RunExportForPeriod(WorkDate(), WorkDate(), Document, NamespaceManager);
    end;

    local procedure RunExportForPeriod(StartingDate: Date; EndingDate: Date; var Document: XmlDocument; var NamespaceManager: XmlNamespaceManager)
    var
        SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header";
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
    begin
        CreateExportHeader(SAFTExportHeader, StartingDate, EndingDate, false);
        EnqueueConfirm(_GenerateImmediatelyQstTxt, true);
        Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", SAFTExportHeader);
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        SAFTExportLine.FindFirst();
        _Assert.AreEqual(SAFTExportLine.Status::Completed, SAFTExportLine.Status, 'The export line must complete.');
        ReadExportedXml(SAFTExportLine, Document, NamespaceManager);
    end;

    local procedure TransactionXPathFor(POSEntry: Record "NPR POS Entry"): Text
    begin
        exit(StrSubstNo('//s:cashtransaction[s:transID=''%1'']', POSEntry."Fiscal No."));
    end;

    local procedure SelectText(Document: XmlDocument; NamespaceManager: XmlNamespaceManager; XPath: Text): Text
    var
        Node: XmlNode;
    begin
        _Assert.IsTrue(Document.SelectSingleNode(XPath, NamespaceManager, Node), StrSubstNo('No element matches %1.', XPath));
        exit(Node.AsXmlElement().InnerText());
    end;

    local procedure ChildNames(Document: XmlDocument; NamespaceManager: XmlNamespaceManager; XPath: Text) Names: Text
    var
        Node: XmlNode;
        Child: XmlNode;
        PreviousName: Text;
    begin
        // Repeated elements (several ctLine or payment) are listed once, since only the order between different elements matters.
        _Assert.IsTrue(Document.SelectSingleNode(XPath, NamespaceManager, Node), StrSubstNo('No element matches %1.', XPath));
        foreach Child in Node.AsXmlElement().GetChildElements() do
            if Child.AsXmlElement().LocalName() <> PreviousName then begin
                PreviousName := Child.AsXmlElement().LocalName();
                if Names <> '' then
                    Names += ',';
                Names += PreviousName;
            end;
    end;

    local procedure AssertBasic(Document: XmlDocument; NamespaceManager: XmlNamespaceManager; BasicID: Text; ExpectedBasicType: Text; ExpectedPredefinedBasicID: Text)
    var
        BasicXPath: Text;
    begin
        _Assert.AreNotEqual('', BasicID, 'The code that must be declared in basics is empty.');
        BasicXPath := StrSubstNo('/s:auditfile/s:company/s:basics/s:basic[s:basicID=''%1'']', BasicID);
        _Assert.AreEqual(1, CountNodes(Document, NamespaceManager, BasicXPath), StrSubstNo('Code ''%1'' must be declared once in basics.', BasicID));
        _Assert.AreEqual(ExpectedBasicType, SelectText(Document, NamespaceManager, BasicXPath + '/s:basicType'), StrSubstNo('Wrong basicType for code ''%1''.', BasicID));
        if ExpectedPredefinedBasicID <> '' then
            _Assert.AreEqual(
                ExpectedPredefinedBasicID, SelectText(Document, NamespaceManager, BasicXPath + '/s:predefinedBasicID'),
                StrSubstNo('Wrong predefinedBasicID for code ''%1''.', BasicID));
        _Assert.AreNotEqual('', SelectText(Document, NamespaceManager, BasicXPath + '/s:basicDesc'), StrSubstNo('Code ''%1'' must have a basicDesc.', BasicID));
    end;

    local procedure Initialize()
    begin
        Clear(_ExpectedConfirmQuestions);
        Clear(_ConfirmReplies);
        EnsureDKFiscalizationSetup();
    end;

    local procedure EnsureDKFiscalizationSetup()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
    begin
        if not DKFiscalizationSetup.Get() then begin
            DKFiscalizationSetup.Init();
            DKFiscalizationSetup.Insert();
        end;
        DKFiscalizationSetup."SAF-T Contact No." := 'DKSAFTTEST';
        DKFiscalizationSetup."SAF-T Audit File Sender" := '';
        DKFiscalizationSetup.Modify();
    end;

    local procedure EnqueueConfirm(ExpectedQuestion: Text; Reply: Boolean)
    begin
        _ExpectedConfirmQuestions.Add(ExpectedQuestion);
        _ConfirmReplies.Add(Reply);
    end;

    local procedure AssertAllConfirmsRaised()
    begin
        _Assert.AreEqual(0, _ExpectedConfirmQuestions.Count(), 'Not every expected confirmation was raised.');
    end;

    local procedure CreateExportHeader(var SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header"; StartingDate: Date; EndingDate: Date; RunInBackground: Boolean)
    begin
        SAFTExportHeader.Init();
        SAFTExportHeader.Insert(true);
        SAFTExportHeader."Starting Date" := StartingDate;
        SAFTExportHeader."Ending Date" := EndingDate;
        SAFTExportHeader."Parallel Processing" := RunInBackground;
        SAFTExportHeader.Modify();
    end;

    local procedure CreateLegacySplitExport(var SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header"; NoOfLines: Integer)
    var
        LineNo: Integer;
    begin
        CreateExportHeader(SAFTExportHeader, WorkDate(), WorkDate(), false);
        for LineNo := 1 to NoOfLines do
            InsertLegacyLine(SAFTExportHeader, LineNo, LineNo = 1);
        SAFTExportHeader.Status := SAFTExportHeader.Status::Completed;
        SAFTExportHeader.Modify();
    end;

    local procedure InsertLegacyLine(SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header"; LineNo: Integer; MasterData: Boolean)
    var
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
        OutStr: OutStream;
    begin
        SAFTExportLine.Init();
        SAFTExportLine.ID := SAFTExportHeader.ID;
        SAFTExportLine."Line No." := LineNo;
        SAFTExportLine.Status := SAFTExportLine.Status::Completed;
#pragma warning disable AL0432
        SAFTExportLine."Master Data" := MasterData;
#pragma warning restore AL0432
        SAFTExportLine."Starting Date" := SAFTExportHeader."Starting Date";
        SAFTExportLine."Ending Date" := SAFTExportHeader."Ending Date";
        SAFTExportLine."SAF-T File".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText('<auditfile/>');
        SAFTExportLine.Insert();
    end;

    local procedure CreatePOSStoreAndUnit(var POSStore: Record "NPR POS Store"; var POSUnit: Record "NPR POS Unit")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
    begin
        _LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        _LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        _LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
        _LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
    end;

    local procedure CreateFiscalPOSEntry(POSStoreCode: Code[10]; POSUnitNo: Code[10]; EntryDate: Date; FiscalNo: Code[20]; AmountInclTax: Decimal)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        // No library helper creates a finished fiscal POS entry without running a full POS sale.
        POSEntry.Init();
        POSEntry."POS Store Code" := POSStoreCode;
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."Entry Date" := EntryDate;
        POSEntry."Starting Time" := 120000T;
        POSEntry."Fiscal No." := FiscalNo;
        POSEntry."Amount Incl. Tax" := AmountInclTax;
        POSEntry."Amount Excl. Tax" := Round(AmountInclTax / 1.25);
        POSEntry.Insert();
    end;

    local procedure VerifySingleGeneratedFile(SAFTExportHeader: Record "NPR DK SAF-T Cash Exp. Header"; CountErrorMsg: Text)
    var
        SAFTExportLine: Record "NPR DK SAF-T Cash Export Line";
    begin
        SAFTExportLine.SetRange(ID, SAFTExportHeader.ID);
        _Assert.AreEqual(1, SAFTExportLine.Count(), CountErrorMsg);
        SAFTExportLine.SetAutoCalcFields("SAF-T File");
        SAFTExportLine.FindFirst();
        _Assert.AreEqual(SAFTExportLine.Status::Completed, SAFTExportLine.Status, 'The regenerated line must complete.');
        _Assert.IsTrue(SAFTExportLine."SAF-T File".HasValue(), 'The regenerated line must hold the SAF-T file.');
    end;

    local procedure ReadExportedXml(SAFTExportLine: Record "NPR DK SAF-T Cash Export Line"; var Document: XmlDocument; var NamespaceManager: XmlNamespaceManager)
    var
        InStr: InStream;
    begin
        SAFTExportLine.CalcFields("SAF-T File");
        _Assert.IsTrue(SAFTExportLine."SAF-T File".HasValue(), 'The export line must hold the SAF-T file.');
        SAFTExportLine."SAF-T File".CreateInStream(InStr, TextEncoding::UTF8);
        _Assert.IsTrue(XmlDocument.ReadFrom(InStr, Document), 'The SAF-T file must be well-formed XML.');
        NamespaceManager.NameTable(Document.NameTable());
        NamespaceManager.AddNamespace('s', _SAFTNamespaceTxt);
    end;

    local procedure CountNodes(Document: XmlDocument; NamespaceManager: XmlNamespaceManager; XPath: Text): Integer
    var
        Nodes: XmlNodeList;
    begin
        Document.SelectNodes(XPath, NamespaceManager, Nodes);
        exit(Nodes.Count());
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        ExpectedQuestion: Text;
    begin
        _Assert.AreNotEqual(0, _ExpectedConfirmQuestions.Count(), StrSubstNo('Unexpected confirmation: ''%1''.', Question));
        ExpectedQuestion := _ExpectedConfirmQuestions.Get(1);
        _Assert.IsTrue(StrPos(Question, ExpectedQuestion) > 0, StrSubstNo('Unexpected confirmation. Expected it to contain ''%1'' but got ''%2''.', ExpectedQuestion, Question));
        Reply := _ConfirmReplies.Get(1);
        _ExpectedConfirmQuestions.RemoveAt(1);
        _ConfirmReplies.RemoveAt(1);
    end;
}
