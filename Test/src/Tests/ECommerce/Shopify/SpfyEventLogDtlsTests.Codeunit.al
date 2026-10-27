codeunit 85548 "NPR Spfy Event Log Dtls Tests"
{
    // [Feature] Shopify event log details panel
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _StoreCodeLbl: Label 'SPFYDETAIL', Locked = true;

    [Test]
    procedure BuildDetails_SalesDocFailedOnProcessedEntry_ReportsEcomErrorNotEntryError()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        StepToken: JsonToken;
        StepState: Text;
        ShopifyId: Text[30];
        HeaderErrorLbl: Label 'Customer SPFY-DETAIL-T1 is blocked.', Locked = true;
    begin
        // [SCENARIO] The log entry finished its own work, but the ecommerce document failed to create its sales
        // document. The panel must show that as an ecommerce document error, not as an error on the entry itself.
        ShopifyId := '928500000001';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] an ecommerce document whose sales document creation failed
        LibrarySpfyImport.CreateInvoicedEcomDocument(_StoreCodeLbl, ShopifyId, EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Error;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::Pending;
        EcomSalesHeader."Last Error Message" := HeaderErrorLbl;
        EcomSalesHeader.Modify();

        // [GIVEN] a processed log entry for the same order, carrying no error of its own
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Processed, 0);
        LogEntry."Last Error Message" := '';
        LogEntry.Modify();

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the entry is neither in error nor postponed
        _Assert.IsFalse(GetBoolean(Details, 'hasError'), 'A processed entry must not be reported as an error.');
        _Assert.IsFalse(GetBoolean(Details, 'isPostponed'), 'A processed entry must not be reported as postponed.');

        // [THEN] the ecommerce document error carries the header message and the sales document step failed
        _Assert.IsTrue(StrPos(GetText(Details, 'ecomError'), HeaderErrorLbl) > 0, 'The ecommerce document error must carry the header''s error message.');
        _Assert.AreEqual('failed', GetStepState(Details, 'salesDoc'), 'A sales document that failed to be created must be shown as a failed step.');

        // [THEN] every step has a label and a known state
        foreach StepToken in GetSteps(Details) do begin
            _Assert.AreNotEqual('', GetText(StepToken.AsObject(), 'label'), 'Every step must carry a label.');
            StepState := GetText(StepToken.AsObject(), 'state');
            _Assert.IsTrue(StepState in ['done', 'failed', 'partial', 'pending'], StrSubstNo('Step state ''%1'' is not one of done, failed, partial, pending.', StepState));
        end;
    end;

    [Test]
    procedure BuildDetails_PostponedEntry_IsNotReportedAsError()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        StepToken: JsonToken;
        ShopifyId: Text[30];
        PostponedReasonLbl: Label 'Waiting for the related entries of this order to be processed.', Locked = true;
    begin
        // [SCENARIO] A postponed entry is waiting on purpose. The panel must show it as postponed, not as failed.
        ShopifyId := '928500000002';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] a postponed log entry that carries the postponement reason
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Postponed, 0);
        LogEntry."Last Error Message" := PostponedReasonLbl;
        LogEntry.Modify();

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the entry is postponed, not in error
        _Assert.IsFalse(GetBoolean(Details, 'hasError'), 'A postponed entry must not be reported as an error.');
        _Assert.IsTrue(GetBoolean(Details, 'isPostponed'), 'A postponed entry must be reported as postponed.');
        _Assert.AreEqual(Format("NPR SpfyEventLogProcessStatus"::Postponed), GetText(Details, 'processingStatus'), 'The processing status must be the formatted Postponed value.');

        // [THEN] no step is shown as failed
        foreach StepToken in GetSteps(Details) do
            _Assert.AreNotEqual('failed', GetText(StepToken.AsObject(), 'state'), StrSubstNo('Step ''%1'' must not fail for a postponed entry.', GetText(StepToken.AsObject(), 'key')));
    end;

    [Test]
    procedure BuildDetails_PartiallyInvoicedDocument_MarksPostedStepPartial()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A sales document that was only partly posted is shown as partially posted, not as posted.
        ShopifyId := '928500000003';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] an ecommerce document whose sales document was created and partially invoiced
        LibrarySpfyImport.CreateInvoicedEcomDocument(_StoreCodeLbl, ShopifyId, EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::"Partially Invoiced";
        EcomSalesHeader.Modify();
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the posted step is partial
        _Assert.AreEqual('partial', GetStepState(Details, 'posted'), 'A partially invoiced sales document must be shown as a partial posted step.');
    end;

    [Test]
    procedure BuildDetails_PartiallyCapturedVirtualItems_MarksCapturePartialWithoutEcomError()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A partial capture on a document with virtual items is shown on the capture step. A document
        // with virtual items that is not posted yet is not an error, so no ecommerce document error is shown.
        ShopifyId := '928500000004';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] a created ecommerce document with virtual items, partially captured, not posted, without errors
        LibrarySpfyImport.CreateInvoicedEcomDocument(_StoreCodeLbl, ShopifyId, EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::Pending;
        EcomSalesHeader."Virtual Items Exist" := true;
        EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::"Partially Processed";
        EcomSalesHeader."Last Error Message" := '';
        EcomSalesHeader."Last Capture Error Message" := '';
        EcomSalesHeader.Modify();
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the capture step is partial and there is no ecommerce document error
        _Assert.AreEqual('partial', GetStepState(Details, 'capture'), 'A partially processed capture must be shown as a partial capture step.');
        _Assert.AreEqual('', GetText(Details, 'ecomError'), 'A document without error messages must not show an ecommerce document error.');
    end;

    [Test]
    procedure BuildDetails_ErrorDateInThePast_ReportsTheStoredErrorDate()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ErrorDate: Date;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The error date shown is the one stored on the entry, not the current date.
        ShopifyId := '928500000005';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);
        ErrorDate := CalcDate('<-10D>', Today());

        // [GIVEN] a failed log entry whose last error happened ten days ago
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Error, 1);
        LogEntry."Last Error Date" := ErrorDate;
        LogEntry."Process Retry Count" := 2;
        LogEntry.Modify();

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the error date is the stored date
        _Assert.AreEqual(Format(ErrorDate), GetText(Details, 'errorAt'), 'The error date must be the date stored on the entry.');
    end;

    [Test]
    procedure BuildDetails_ThreeDecimalStoreCurrency_FormatsAmountWithCurrencyPrecision()
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        OriginalShowCurrency: Enum "Show Currency";
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Amounts use the amount precision of their currency: the store currency for the SCY amount,
        // the G/L Setup for the LCY amount.
        ShopifyId := '928500000020';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);
        GeneralLedgerSetup.Get();

        // [GIVEN] G/L Setup shows currency codes, so a format with a currency symbol would add one
        OriginalShowCurrency := GeneralLedgerSetup."Show Currency";
        GeneralLedgerSetup."Show Currency" := GeneralLedgerSetup."Show Currency"::"LCY and FCY Currency Code";
        GeneralLedgerSetup.Modify();

        // [GIVEN] a store currency with three amount decimal places
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Decimal Places", '3:3');
        Currency."ISO Code" := 'XTS';
        Currency.Modify(true);

        // [GIVEN] a log entry with amounts in that currency and in LCY
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry."Amount (SCY)" := 1234.567;
        LogEntry."Store Currency Code" := Currency.Code;
        LogEntry."Amount (LCY)" := 1234.567;
        LogEntry.Modify();

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // Restore before asserting; Modify also clears the cached setup in codeunit "Amount Auto Format".
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Show Currency" := OriginalShowCurrency;
        GeneralLedgerSetup.Modify();

        // [THEN] the SCY amount has three decimals and the currency code suffix
        _Assert.AreEqual(
            Format(1234.567, 0, '<Precision,3:3><Standard Format,0>') + ' ' + Currency.Code,
            GetText(Details, 'amountSCY'),
            'The SCY amount must be formatted with the store currency precision, followed by the currency code.');
        // [THEN] the LCY amount uses the G/L Setup precision and has no suffix
        _Assert.AreEqual(
            Format(1234.567, 0, '<Precision,' + GeneralLedgerSetup."Amount Decimal Places" + '><Standard Format,0>'),
            GetText(Details, 'amountLCY'),
            'The LCY amount must be formatted with the G/L Setup amount precision, without a currency code.');
    end;

    [Test]
    procedure BuildDetails_StoreCurrencyWithoutCurrencyRecord_UsesLcyPrecision()
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ExpectedAmount: Text;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Shopify stores the LCY code as the store currency code, with no Currency record behind it.
        // The SCY amount then uses the G/L Setup precision, also when the details are built again.
        ShopifyId := '928500000021';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("LCY Code");

        // [GIVEN] no Currency record for the LCY code
        if Currency.Get(GeneralLedgerSetup."LCY Code") then
            Currency.Delete();

        // [GIVEN] a log entry whose store currency code is the LCY code
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry."Amount (SCY)" := 1234.567;
        LogEntry."Store Currency Code" := GeneralLedgerSetup."LCY Code";
        LogEntry.Modify();
        ExpectedAmount := Format(1234.567, 0, '<Precision,' + GeneralLedgerSetup."Amount Decimal Places" + '><Standard Format,0>') + ' ' + GeneralLedgerSetup."LCY Code";

        // [WHEN] the details are built twice
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the SCY amount uses the G/L Setup precision, followed by the LCY code
        _Assert.AreEqual(ExpectedAmount, GetText(Details, 'amountSCY'), 'The first SCY amount must be formatted with the G/L Setup amount precision, followed by the LCY code.');

        Details := SpfyEventLogDetails.BuildDetails(LogEntry);
        _Assert.AreEqual(ExpectedAmount, GetText(Details, 'amountSCY'), 'The second SCY amount must be formatted with the G/L Setup amount precision, followed by the LCY code.');
    end;

    [Test]
    procedure BuildDetails_ErrorWithoutEcomDocument_FailsEcomDocStep()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An entry that failed before the ecommerce document was created fails on the ecommerce
        // document step. The completed step stays pending, so the failure is shown once.
        ShopifyId := '928500000006';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] a failed log entry and no ecommerce document
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Error, 1);

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the entry is in error, the ecommerce document step failed and the completed step is pending
        _Assert.IsTrue(GetBoolean(Details, 'hasError'), 'A failed entry must be reported as an error.');
        _Assert.AreEqual('failed', GetStepState(Details, 'ecomDoc'), 'Without an ecommerce document the failure belongs on the ecommerce document step.');
        _Assert.AreEqual('pending', GetStepState(Details, 'completed'), 'Without an ecommerce document the completed step must stay pending.');
    end;

    [Test]
    procedure BuildDetails_ErrorAfterEcomDocumentCreated_FailsCompletedStep()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An entry that failed after the ecommerce document was created fails on the completed step.
        // The ecommerce document step stays done.
        ShopifyId := '928500000007';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] a created ecommerce document and a failed log entry for the same order
        LibrarySpfyImport.CreateInvoicedEcomDocument(_StoreCodeLbl, ShopifyId, EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Error, 1);

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the ecommerce document step is done and the completed step failed
        _Assert.AreEqual('done', GetStepState(Details, 'ecomDoc'), 'An existing ecommerce document must be shown as a done step.');
        _Assert.AreEqual('failed', GetStepState(Details, 'completed'), 'A failure after the ecommerce document exists belongs on the completed step.');
    end;

    [Test]
    procedure BuildDetails_ProcessedWithoutEcomDocument_ShowsSingleCompletedStep()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        Steps: JsonArray;
        StepToken: JsonToken;
    begin
        // [SCENARIO] Some entries finish without creating an ecommerce document. The panel shows a single done
        // step for them instead of a pipeline that never started.
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] a processed log entry without an error and no ecommerce document
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, '928500000011', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Processed, 0);
        LogEntry."Last Error Message" := '';
        LogEntry.Modify();

        // [WHEN] the details are built
        Details := SpfyEventLogDetails.BuildDetails(LogEntry);

        // [THEN] the entry is not in error and the only step is the done step for completion without a document
        _Assert.IsFalse(GetBoolean(Details, 'hasError'), 'A processed entry must not be reported as an error.');
        Steps := GetSteps(Details);
        _Assert.AreEqual(1, Steps.Count(), 'A processed entry without an ecommerce document must show exactly one step.');
        Steps.Get(0, StepToken);
        _Assert.AreEqual('noEcomDoc', GetText(StepToken.AsObject(), 'key'), 'The only step must be the step for completion without an ecommerce document.');
        _Assert.AreEqual('done', GetText(StepToken.AsObject(), 'state'), 'The step for completion without an ecommerce document must be done.');
        _Assert.AreNotEqual('', GetText(StepToken.AsObject(), 'label'), 'The step for completion without an ecommerce document must carry a label.');
    end;

    [Test]
    procedure SetOrderHistoryFilter_ReturnsAllStatusesOfSameOrderOnly()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        OpenEntry: Record "NPR Spfy Event Log Entry";
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        CancelledEntry: Record "NPR Spfy Event Log Entry";
        OrderEvents: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        OpenFound: Boolean;
        ClosedFound: Boolean;
        CancelledFound: Boolean;
        ShopifyId: Text[30];
        OtherStoreCodeLbl: Label 'SPFYDETAIL2', Locked = true;
    begin
        // [SCENARIO] The order history holds every entry of the same Shopify order, whatever its document status,
        // and nothing from other orders, other stores, returns or other entry types.
        ShopifyId := '928500000008';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);
        LibrarySpfyImport.CreateStore(OtherStoreCodeLbl);

        // [GIVEN] an open, a closed and a cancelled entry of the same order
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(CancelledEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());

        // [GIVEN] entries of another order, of the same order in another store, of a return and of another entry type
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, '928500000099', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, OtherStoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry.Type := LogEntry.Type::" ";
        LogEntry.Modify();

        // [WHEN] the order history filter is set from the open entry
        SpfyEventLogMgt.SetOrderHistoryFilter(OpenEntry, OrderEvents);

        // [THEN] exactly the open, closed and cancelled entries of the order are included
        _Assert.AreEqual(3, OrderEvents.Count(), 'The order history must hold the three entries of the same order and nothing else.');
        OrderEvents.FindSet();
        repeat
            case OrderEvents."Entry No." of
                OpenEntry."Entry No.":
                    OpenFound := true;
                ClosedEntry."Entry No.":
                    ClosedFound := true;
                CancelledEntry."Entry No.":
                    CancelledFound := true;
                else
                    _Assert.Fail(StrSubstNo('Entry %1 does not belong to the order history.', OrderEvents."Entry No."));
            end;
        until OrderEvents.Next() = 0;
        _Assert.IsTrue(OpenFound, 'The open entry must be in the order history.');
        _Assert.IsTrue(ClosedFound, 'The closed entry must be in the order history.');
        _Assert.IsTrue(CancelledFound, 'The cancelled entry must be in the order history.');
    end;

    [Test]
    procedure BuildDetails_OlderEntry_ReportsPositionInOrder()
    var
        OpenEntry: Record "NPR Spfy Event Log Entry";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] For an older entry the panel shows its position in the order history, ordered by entry number.
        // Event Date-Time decreases on purpose, so the order must follow Entry No.
        ShopifyId := '928500000009';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] an open, a closed and a cancelled entry of the same order, registered in that order
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime() - 1000);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime() - 2000);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime() - 3000);

        // [WHEN] the details of the open entry are built
        Details := SpfyEventLogDetails.BuildDetails(OpenEntry);

        // [THEN] it is event 1 of 3
        _Assert.AreEqual(3, GetInteger(Details, 'orderEventCount'), 'The order has three entries.');
        _Assert.AreEqual(1, GetInteger(Details, 'orderEventIndex'), 'The open entry was registered first.');
    end;

    [Test]
    procedure BuildDetails_LatestEntry_IsLastEventOfOrder()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The newest entry of an order is shown as the last event of the order history.
        ShopifyId := '928500000010';
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] an open and a closed entry of the same order
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, _StoreCodeLbl, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        // [WHEN] the details of the closed entry are built
        Details := SpfyEventLogDetails.BuildDetails(ClosedEntry);

        // [THEN] it is event 2 of 2
        _Assert.AreEqual(2, GetInteger(Details, 'orderEventCount'), 'The order has two entries.');
        _Assert.AreEqual(2, GetInteger(Details, 'orderEventIndex'), 'The closed entry was registered last.');
    end;

    [Test]
    procedure BuildDetails_BlankShopifyId_ReportsNoHistory()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        FirstEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDetails: Codeunit "NPR Spfy Event Log Details";
        Details: JsonObject;
    begin
        // [SCENARIO] Entries without a Shopify ID do not belong to an order, so no order history is reported.
        LibrarySpfyImport.CreateStore(_StoreCodeLbl);

        // [GIVEN] two entries of the same store and document type without a Shopify ID
        LibrarySpfyImport.InsertOrderLogEntry(FirstEntry, _StoreCodeLbl, '', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, _StoreCodeLbl, '', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        // [WHEN] the details of the first entry are built
        Details := SpfyEventLogDetails.BuildDetails(FirstEntry);

        // [THEN] there is no order history
        _Assert.AreEqual(0, GetInteger(Details, 'orderEventCount'), 'An entry without a Shopify ID has no order history.');
        _Assert.AreEqual(0, GetInteger(Details, 'orderEventIndex'), 'An entry without a Shopify ID has no position in an order history.');
    end;

    local procedure GetSteps(Details: JsonObject): JsonArray
    var
        StepsToken: JsonToken;
    begin
        _Assert.IsTrue(Details.Get('steps', StepsToken), 'The details must contain the steps array.');
        exit(StepsToken.AsArray());
    end;

    local procedure GetStepState(Details: JsonObject; StepKey: Text): Text
    var
        StepToken: JsonToken;
    begin
        foreach StepToken in GetSteps(Details) do
            if GetText(StepToken.AsObject(), 'key') = StepKey then
                exit(GetText(StepToken.AsObject(), 'state'));
        _Assert.Fail(StrSubstNo('Step ''%1'' is missing from the details.', StepKey));
    end;

    local procedure GetText(JObject: JsonObject; PropertyKey: Text): Text
    var
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(JObject.Get(PropertyKey, ValueToken), StrSubstNo('Property ''%1'' is missing.', PropertyKey));
        exit(ValueToken.AsValue().AsText());
    end;

    local procedure GetBoolean(JObject: JsonObject; PropertyKey: Text): Boolean
    var
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(JObject.Get(PropertyKey, ValueToken), StrSubstNo('Property ''%1'' is missing.', PropertyKey));
        exit(ValueToken.AsValue().AsBoolean());
    end;

    local procedure GetInteger(JObject: JsonObject; PropertyKey: Text): Integer
    var
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(JObject.Get(PropertyKey, ValueToken), StrSubstNo('Property ''%1'' is missing.', PropertyKey));
        exit(ValueToken.AsValue().AsInteger());
    end;
}
