codeunit 85395 "NPR Spfy TL Order Tests"
{
    // [FEATURE] Shopify Task List - order flow and POS entries on the queue: vanished-source policy, dispatch routing, and the forked send siblings
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _LibFulfillment: Codeunit "NPR Library - Spfy Fulfillment";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _SourceGoneLbl: Label 'The source record no longer exists. The request is no longer applicable.';
        _UnmappedKindTok: Label 'no send codeunit mapped', Locked = true;
        _CustomerlessTok: Label 'was posted without a customer number', Locked = true;
        _NotEligibleTok: Label 'is not eligible for synchronization', Locked = true;
        _CustomerNotSyncedTok: Label 'has not yet been synchronized with Shopify store', Locked = true;
        _FulfillmentCreateTok: Label 'fulfillmentCreate(', Locked = true;
        _TransactionCreateTok: Label 'TransactionCreate(', Locked = true;
        _OrderTransactionsTok: Label 'OrderTransactions(', Locked = true;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        // The binary router keys on the feature while the engine keys on the migration status: the raw enable stamps both.
        _Lib.SetTaskListFeatureEnabled(true);
        ClearRunContext();
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
    end;

    local procedure ClearRunContext()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearSendBoundary();
    end;

    local procedure Minutes(MinuteCount: Integer): Duration
    begin
        exit(MinuteCount * 60 * 1000);
    end;

    #region Fixtures
    local procedure CreateOrderStore(): Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Every order-flow area is set at insert: the SingleInstance integration mgt caches per-store area reads, so flags are never flipped afterwards.
        ShopifyStore.Init();
        ShopifyStore.Code := _Lib.NextCode('S', MaxStrLen(ShopifyStore.Code));
        ShopifyStore.Enabled := true;
        ShopifyStore."Sales Order Integration" := true;
        ShopifyStore."Send Order Fulfillments" := true;
        ShopifyStore."Send Payment Capture Requests" := true;
        ShopifyStore."Send Close Order Requets" := true;
        ShopifyStore."Send Order Ready for Pickup" := true;
        ShopifyStore."BC Customer Transactions" := true;
        // Refreshing payment lines from Shopify would turn stage 1 into an HTTP call; the capture scenarios need the offline branch.
        ShopifyStore."Get Payment Lines from Shopify" := ShopifyStore."Get Payment Lines from Shopify"::ON_ORDER_IMPORT;
        ShopifyStore.Insert(false);
        exit(ShopifyStore.Code);
    end;

    local procedure EnqueueTask(StoreCode: Code[20]; RecRef: RecordRef; RecId: RecordId; RecordValue: Text; Op: Enum "NPR Spfy Task Op"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, RecId, RecordValue, Op, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueTask(StoreCode: Code[20]; RecRef: RecordRef; RecId: RecordId; RecordValue: Text; Op: Enum "NPR Spfy Task Op"; LogDateTime: DateTime; NotBeforeDateTime: DateTime; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, RecId, RecordValue, Op, LogDateTime, NotBeforeDateTime,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure CreateShipmentTask(StoreCode: Code[20]; var SalesShipmentHeader: Record "Sales Shipment Header"; OrderId: Text; LineCount: Integer): BigInteger
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        RecRef: RecordRef;
        DocNo: Code[20];
        LineIndex: Integer;
    begin
        DocNo := _Lib.NextCode('SH', MaxStrLen(SalesShipmentHeader."No."));
        _LibFulfillment.CreateShipmentHeader(DocNo, SalesShipmentHeader);
        for LineIndex := 1 to LineCount do
            _LibFulfillment.CreateShipmentLine(DocNo, LineIndex * 10000, 2, CopyStr(Format(1000 + LineIndex), 1, 30), SalesShipmentLine);
        RecRef.GetTable(SalesShipmentHeader);
        exit(EnqueueTask(StoreCode, RecRef, SalesShipmentHeader.RecordId(), OrderId, "NPR Spfy Task Op"::Insert, CurrentDateTime()));
    end;

    local procedure ShipmentLineRecordId(DocNo: Code[20]; LineNo: Integer): RecordId
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.Get(DocNo, LineNo);
        exit(SalesShipmentLine.RecordId());
    end;

    local procedure CreateInvoiceWithPaymentLine(var SalesInvHeader: Record "Sales Invoice Header"; var PaymentLine: Record "NPR Magento Payment Line"; GatewayCode: Code[10])
    begin
        SalesInvHeader.Init();
        SalesInvHeader."No." := _Lib.NextCode('PI', MaxStrLen(SalesInvHeader."No."));
        SalesInvHeader.Insert(false);

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Invoice Header";
        PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        PaymentLine."Document No." := SalesInvHeader."No.";
        PaymentLine."Line No." := 10000;
        PaymentLine.Amount := 500;
        PaymentLine."Payment Gateway Code" := GatewayCode;
        PaymentLine."Date Captured" := 0D;
        PaymentLine.Insert(false);
        _Lib.AssignEntryID(PaymentLine.RecordId(), '777');
    end;

    local procedure ShopifyGatewayCode(): Code[10]
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
    begin
        // A shared utility on the frozen sender, not a send: it creates the SPFY-<CUR> gateway pair the capture path requires.
        exit(SpfyCapturePayment.ShopifyPaymentGateway('DKK'));
    end;

    local procedure NextPOSEntryNo(): Integer
    var
        POSEntry: Record "NPR POS Entry";
    begin
        if POSEntry.FindLast() then
            exit(POSEntry."Entry No." + 1);
        exit(1);
    end;

    local procedure CreatePOSEntry(CustomerNo: Code[20]; SaleAmount: Decimal; WithPositiveLine: Boolean) POSEntry: Record "NPR POS Entry"
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry.Init();
        POSEntry."Entry No." := NextPOSEntryNo();
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."Entry Date" := Today();
        POSEntry."Customer No." := CustomerNo;
        POSEntry."Amount Excl. Tax" := SaleAmount;
        POSEntry."System Entry" := false;
        POSEntry.Insert(false);

        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := 10000;
        POSEntrySalesLine.Type := POSEntrySalesLine.Type::Item;
        if WithPositiveLine then
            POSEntrySalesLine.Quantity := 1
        else
            POSEntrySalesLine.Quantity := 0;
        POSEntrySalesLine.Insert(false);
    end;

    local procedure CreateNpCsDocument(SalesOrderNo: Code[20]) NpCsDocument: Record "NPR NpCs Document"
    begin
        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument."From Document Type" := NpCsDocument."From Document Type"::Order;
        NpCsDocument."From Document No." := SalesOrderNo;
        NpCsDocument."Document Type" := NpCsDocument."Document Type"::Order;
        NpCsDocument."Document No." := SalesOrderNo;
        NpCsDocument.Insert(false);
    end;

    local procedure AssignStoreCode(RecId: RecordId; StoreCode: Code[20])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(RecId, "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    local procedure MockFulfillmentOrders(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; FoIds: List of [Text])
    begin
        MockClient.AddResponse('fulfillmentOrders(after', _LibFulfillment.ResponseFulfillmentOrders(FoIds));
    end;

    local procedure MockFulfillmentOrderLine(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; FoId: Text; FoLineId: Text[30]; OrderLineId: Text[30]; LocationId: Text)
    var
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        _LibFulfillment.AddBufferLine(TempLines, FoLineId, 2, OrderLineId);
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/' + FoId, _LibFulfillment.ResponseFulfillmentOrderLines(TempLines, LocationId));
    end;

    local procedure MockOrderTransactionsEmpty(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client")
    begin
        MockClient.AddResponse(_OrderTransactionsTok, '{"data":{"order":{"transactions":[]}}}');
    end;

    local procedure MockCaptureStatus(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; Status: Text)
    begin
        MockClient.AddResponse(
            _TransactionCreateTok,
            StrSubstNo('{"data":{"orderCapture":{"transaction":{"id":"gid://shopify/OrderTransaction/555","status":"%1"},"userErrors":[]}}}', Status));
    end;
    #endregion

    #region Readbacks
    local procedure DispatchForReal(EntryNo: BigInteger; var ErrorText: Text): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
    begin
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        SpfyTask.Get(EntryNo);
        exit(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText));
    end;

    local procedure GetTask(EntryNo: BigInteger; var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask.Get(EntryNo);
    end;

    local procedure AssertTask(EntryNo: BigInteger; ExpectedState: Enum "NPR Spfy Task State"; ExpectedAttempts: Integer; FailureMsg: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _Assert.IsTrue(SpfyTask.State = ExpectedState, StrSubstNo('%1: expected state %2 but found %3 with %4 attempt(s)', FailureMsg, ExpectedState, SpfyTask.State, SpfyTask.Attempts));
        _Assert.AreEqual(ExpectedAttempts, SpfyTask.Attempts, StrSubstNo('%1: attempts', FailureMsg));
    end;

    local procedure ResponseText(EntryNo: BigInteger): Text
    var
        SpfyTask: Record "NPR Spfy Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.CalcFields(Response);
        if not SpfyTask.Response.HasValue() then
            exit('');
        SpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    local procedure FulfillmentEntryCount(BCRecordID: RecordId): Integer
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.SetRange("BC Record ID", BCRecordID);
        exit(SpfyFulfillmentEntry.Count());
    end;

    local procedure FulfillmentEntryFulfillmentId(BCRecordID: RecordId): Text[30]
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.SetRange("BC Record ID", BCRecordID);
        if SpfyFulfillmentEntry.FindFirst() then
            exit(SpfyFulfillmentEntry."Fulfillment ID");
    end;

    local procedure PendingTaskCountForRecord(TableNo: Integer; RecId: RecordId): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange("Record ID", RecId);
        SpfyTask.SetRange(State, SpfyTask.State::Pending);
        exit(SpfyTask.Count());
    end;

    local procedure FindPendingTaskForRecord(TableNo: Integer; RecId: RecordId; var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.Reset();
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange("Record ID", RecId);
        SpfyTask.SetRange(State, SpfyTask.State::Pending);
        exit(SpfyTask.FindLast());
    end;

    local procedure NcTaskCount(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        exit(NcTask.Count());
    end;

    local procedure RescheduleClaimedTask(EntryNo: BigInteger; LogDateTime: DateTime; NotBeforeDateTime: DateTime; var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask."Log Date" := LogDateTime;
        SpfyTask."Not Before Date-Time" := NotBeforeDateTime;
        SpfyTask.Modify(false);
        Commit();
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The rescheduled stage-2 task must be claimable');
    end;

    local procedure AssertNotBeforeNear(ActualNotBefore: DateTime; ExpectedNotBefore: DateTime; FailureMsg: Text)
    begin
        _Assert.IsTrue(
            (ActualNotBefore >= ExpectedNotBefore - 10000) and (ActualNotBefore <= ExpectedNotBefore + 10000),
            StrSubstNo('%1: expected a not-before time near %2 but found %3', FailureMsg, ExpectedNotBefore, ActualNotBefore));
    end;
    #endregion

    #region Engine - vanished source policy
    [Test]
    procedure GivenHardGetKindsWhoseSourceIsGone_WhenCycleRuns_ThenCompletedNotApplicableWithoutDispatch()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesInvHeader: Record "Sales Invoice Header";
        POSEntry: Record "NPR POS Entry";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        ShipmentTaskEntryNo: BigInteger;
        ReceiptTaskEntryNo: BigInteger;
        InvoiceTaskEntryNo: BigInteger;
        POSEntryTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A shipment, a return receipt, a posted invoice and a POS entry task whose source row is gone are each completed as no longer applicable, without spending an attempt and without reaching a send codeunit.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateOrderStore();

        // [GIVEN] One task per hard-Get order-flow kind, each pointing at a row that was never inserted.
        SalesShipmentHeader."No." := _Lib.NextCode('SH', MaxStrLen(SalesShipmentHeader."No."));
        RecRef.GetTable(SalesShipmentHeader);
        ShipmentTaskEntryNo := EnqueueTask(StoreCode, RecRef, SalesShipmentHeader.RecordId(), '5001', "NPR Spfy Task Op"::Insert, AtDateTime);

        ReturnReceiptHeader."No." := _Lib.NextCode('RR', MaxStrLen(ReturnReceiptHeader."No."));
        RecRef.GetTable(ReturnReceiptHeader);
        ReceiptTaskEntryNo := EnqueueTask(StoreCode, RecRef, ReturnReceiptHeader.RecordId(), '5002', "NPR Spfy Task Op"::Insert, AtDateTime);

        SalesInvHeader."No." := _Lib.NextCode('PI', MaxStrLen(SalesInvHeader."No."));
        RecRef.GetTable(SalesInvHeader);
        InvoiceTaskEntryNo := EnqueueTask(StoreCode, RecRef, SalesInvHeader.RecordId(), '5501', "NPR Spfy Task Op"::Insert, AtDateTime);

        POSEntry."Entry No." := NextPOSEntryNo();
        RecRef.GetTable(POSEntry);
        POSEntryTaskEntryNo := EnqueueTask(StoreCode, RecRef, POSEntry.RecordId(), Format(POSEntry."Entry No."), "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Each of the four kinds is closed as no longer applicable instead of being handed to a send codeunit that would only fail on the missing row.
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(ShipmentTaskEntryNo), 'A fulfillment task whose posted shipment is gone must be closed as no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(ReceiptTaskEntryNo), 'A fulfillment task whose return receipt is gone must be closed as no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(InvoiceTaskEntryNo), 'A capture stage-1 task whose posted invoice is gone must be closed as no longer applicable');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(POSEntryTaskEntryNo), 'A POS entry task whose entry is gone must be closed as no longer applicable');
        AssertTask(ShipmentTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'The posted shipment task must be completed without spending an attempt');
        AssertTask(ReceiptTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'The return receipt task must be completed without spending an attempt');
        AssertTask(InvoiceTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'The posted invoice task must be completed without spending an attempt');
        AssertTask(POSEntryTaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'The POS entry task must be completed without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'No hard-Get task with a vanished source may reach the send boundary');
    end;

    [Test]
    procedure GivenExemptKindsWhoseSourceIsGone_WhenCycleRuns_ThenTheyStillDispatch()
    var
        SalesHeader: Record "Sales Header";
        NpCsDocument: Record "NPR NpCs Document";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        CloseOrderTaskEntryNo: BigInteger;
        PickupTaskEntryNo: BigInteger;
        CaptureTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A close-order delete, a ready-for-pickup send and a payment capture still dispatch when their source row is gone, because each send owns that outcome itself.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateOrderStore();

        // [GIVEN] A close-order delete, a ready-for-pickup send and a payment capture, none of whose source rows exist.
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(SalesHeader."No."));
        RecRef.GetTable(SalesHeader);
        CloseOrderTaskEntryNo := EnqueueTask(StoreCode, RecRef, SalesHeader.RecordId(), '5502', "NPR Spfy Task Op"::Delete, AtDateTime);

        NpCsDocument."Entry No." := 999999;
        RecRef.GetTable(NpCsDocument);
        PickupTaskEntryNo := EnqueueTask(StoreCode, RecRef, NpCsDocument.RecordId(), '5503', "NPR Spfy Task Op"::Insert, AtDateTime);

        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := PaymentLine."Document Type"::Order;
        PaymentLine."Document No." := _Lib.NextCode('SO', MaxStrLen(PaymentLine."Document No."));
        PaymentLine."Line No." := 10000;
        RecRef.GetTable(PaymentLine);
        CaptureTaskEntryNo := EnqueueTask(StoreCode, RecRef, PaymentLine.RecordId(), '5501', "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] All three are handed to the send code, which owns the outcome: a close order never needs its header, a pickup send does not need its document, and a capture re-resolves a moved line itself.
        _Assert.AreEqual(3, _BndMock.DispatchCount(), 'All three exempt kinds must reach the send boundary although their source rows are gone');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(CloseOrderTaskEntryNo), 'A close-order delete must not be closed as no longer applicable');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(PickupTaskEntryNo), 'A ready-for-pickup send must not be closed as no longer applicable');
        _Assert.AreNotEqual(_SourceGoneLbl, ResponseText(CaptureTaskEntryNo), 'A payment capture must not be closed as no longer applicable');
        GetTask(CloseOrderTaskEntryNo, SpfyTask);
        _Assert.IsFalse(SpfyTask.State = SpfyTask.State::Waiting, 'A close-order delete must not be parked as waiting');
        GetTask(PickupTaskEntryNo, SpfyTask);
        _Assert.IsFalse(SpfyTask.State = SpfyTask.State::Waiting, 'A ready-for-pickup send must not be parked as waiting');
        GetTask(CaptureTaskEntryNo, SpfyTask);
        _Assert.IsFalse(SpfyTask.State = SpfyTask.State::Waiting, 'A payment capture must not be parked as waiting');
    end;
    #endregion

    #region Production boundary
    [Test]
    procedure ProductionBoundaryRoutesAllSevenOrderFlowTables()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        NpCsDocument: Record "NPR NpCs Document";
        PaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        RecRef: RecordRef;
        StoreCode: Code[20];
        ReceiptDocNo: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] The production send boundary routes each of the seven order-flow tables to its own sibling, proven per kind by where the dispatch lands rather than by the boundary map.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateOrderStore();

        // [GIVEN] A posted shipment task on a store that cannot reach Shopify.
        TaskEntryNo := CreateShipmentTask(StoreCode, SalesShipmentHeader, '5001', 1);

        // [WHEN] The production boundary is handed it.
        // [THEN] It fails inside the fulfillment sibling, which proves the dispatch reached it rather than the unmapped branch.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A posted shipment task must fail inside the send codeunit');
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A posted shipment task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreNotEqual('', ErrorText, 'A posted shipment task that cannot reach Shopify must report why');

        // [GIVEN] A return receipt task.
        ReceiptDocNo := _Lib.NextCode('RR', MaxStrLen(ReturnReceiptHeader."No."));
        _LibFulfillment.CreateReturnReceiptHeader(ReceiptDocNo, ReturnReceiptHeader);
        _LibFulfillment.CreateReturnReceiptLine(ReceiptDocNo, 10000, 2, '1001', ReturnReceiptLine);
        RecRef.GetTable(ReturnReceiptHeader);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, ReturnReceiptHeader.RecordId(), '5002', "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] Same shape: declined by the fulfillment sibling, not by the boundary map.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A return receipt task must fail inside the send codeunit');
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A return receipt task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreNotEqual('', ErrorText, 'A return receipt task that cannot reach Shopify must report why');

        // [GIVEN] A close-order delete whose sales header is already gone, as it always is by the time the task runs.
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(SalesHeader."No."));
        RecRef.GetTable(SalesHeader);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, SalesHeader.RecordId(), '5502', "NPR Spfy Task Op"::Delete, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] It reaches the close-order sibling and fails at the Shopify call.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A close-order task must fail inside the send codeunit');
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A close-order task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreNotEqual('', ErrorText, 'A close-order task that cannot reach Shopify must report why');

        // [GIVEN] A ready-for-pickup task.
        NpCsDocument := CreateNpCsDocument(_Lib.NextCode('SO', MaxStrLen(SalesHeader."No.")));
        RecRef.GetTable(NpCsDocument);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, NpCsDocument.RecordId(), '5503', "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] It reaches the pickup sibling and fails at the fulfillment order query.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A ready-for-pickup task must fail inside the send codeunit');
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A ready-for-pickup task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreNotEqual('', ErrorText, 'A ready-for-pickup task that cannot reach Shopify must report why');

        // [GIVEN] A stage-2 capture task whose payment line cannot be resolved.
        PaymentLine."Document Table No." := Database::"Sales Invoice Header";
        PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        PaymentLine."Document No." := _Lib.NextCode('PI', MaxStrLen(PaymentLine."Document No."));
        PaymentLine."Line No." := 10000;
        RecRef.GetTable(PaymentLine);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, PaymentLine.RecordId(), '5501', "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] It reaches the capture sibling, which raises on the unresolvable line.
        _Assert.IsFalse(DispatchForReal(TaskEntryNo, ErrorText), 'A payment line task must fail inside the send codeunit');
        _Assert.AreEqual(0, StrPos(ErrorText, _UnmappedKindTok), StrSubstNo('A payment line task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
        _Assert.AreNotEqual('', ErrorText, 'A payment line task that cannot be resolved must report why');

        // [GIVEN] A POS entry task for an entry posted without a customer.
        POSEntry := CreatePOSEntry('', 120, true);
        RecRef.GetTable(POSEntry);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, POSEntry.RecordId(), Format(POSEntry."Entry No."), "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] The POS entry sibling completes it unsent, so a successful dispatch is what proves the routing.
        _Assert.IsTrue(DispatchForReal(TaskEntryNo, ErrorText), StrSubstNo('A POS entry task without a customer must complete unsent: %1', ErrorText));
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), _CustomerlessTok) > 0, StrSubstNo('The POS entry task must record the missing customer, but recorded: %1', ResponseText(TaskEntryNo)));

        // [GIVEN] A stage-1 capture task on a posted invoice with no capturable payment lines.
        SalesInvHeader.Init();
        SalesInvHeader."No." := _Lib.NextCode('PI', MaxStrLen(SalesInvHeader."No."));
        SalesInvHeader.Insert(false);
        RecRef.GetTable(SalesInvHeader);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, SalesInvHeader.RecordId(), '5501', "NPR Spfy Task Op"::Insert, AtDateTime);

        // [WHEN] The production boundary is handed it.
        // [THEN] Stage 1 finds nothing to schedule and completes cleanly, so a successful dispatch is what proves the routing.
        _Assert.IsTrue(DispatchForReal(TaskEntryNo, ErrorText), StrSubstNo('A posted invoice task with no capturable payment lines must complete: %1', ErrorText));
        _Assert.AreEqual('', ErrorText, 'A posted invoice task with nothing to capture must not report an error');
    end;
    #endregion

    #region Fulfillment sibling
    [Test]
    procedure GivenShipmentAtOneLocation_WhenFulfillmentSiblingRuns_ThenOneMutationAndEntriesSaved()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SpfyTask: Record "NPR Spfy Task";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Task Send Fulfillment";
        FoIds: List of [Text];
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        SendRequest: Text;
    begin
        // [SCENARIO] A posted shipment whose lines all sit at one location sends one fulfillment mutation and persists one fulfillment entry per shipment line with the Shopify fulfillment id.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A posted shipment with two Shopify-mapped lines, all covered by one fulfillment order at one location.
        TaskEntryNo := CreateShipmentTask(StoreCode, SalesShipmentHeader, '5001', 2);
        FoIds.Add('9001');
        MockFulfillmentOrders(MockClient, FoIds);
        _LibFulfillment.AddBufferLine(TempLines, '7001', 2, '1001');
        _LibFulfillment.AddBufferLine(TempLines, '7002', 2, '1002');
        MockClient.AddResponse('fulfillmentOrder(id:', _LibFulfillment.ResponseFulfillmentOrderLines(TempLines, '100'));
        MockClient.AddResponse(_FulfillmentCreateTok, _LibFulfillment.ResponseFulfillmentCreate(''));

        // [WHEN] The fulfillment sibling runs against the mocked Shopify.
        GetTask(TaskEntryNo, SpfyTask);
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(SpfyTask);

        // [THEN] One mutation carries both fulfillment-order lines.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining(_FulfillmentCreateTok), 'A single-location shipment must produce exactly one fulfillmentCreate mutation');
        SendRequest := MockClient.GetRequestContaining(_FulfillmentCreateTok);
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7001'), StrSubstNo('The mutation must carry the first fulfillment-order line, but the request was: %1', SendRequest));
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7002'), StrSubstNo('The mutation must carry the second fulfillment-order line, but the request was: %1', SendRequest));

        // [THEN] One fulfillment entry per shipment line is persisted with the Shopify fulfillment id.
        _Assert.AreEqual(1, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 10000)), 'One fulfillment entry expected for the first shipment line');
        _Assert.AreEqual(1, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 20000)), 'One fulfillment entry expected for the second shipment line');
        _Assert.AreEqual('999', FulfillmentEntryFulfillmentId(ShipmentLineRecordId(SalesShipmentHeader."No.", 10000)), 'The saved entry must carry the Shopify fulfillment id returned by fulfillmentCreate');
    end;

    [Test]
    procedure GivenThreeLocationsMixedFailures_WhenFulfillmentSiblingRuns_ThenSucceededLocationSavedAndTransportTextRaised()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Task Send Fulfillment";
        FoIds: List of [Text];
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        RaisedText: Text;
    begin
        // [SCENARIO] A shipment split over three locations keeps the entries of the location that succeeded, saves nothing for the two that failed, and raises a text carrying both failures, so a retry re-sends only what is outstanding.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A shipment split over three locations where the first succeeds, the second is rejected by Shopify and the third cannot be reached.
        TaskEntryNo := CreateShipmentTask(StoreCode, SalesShipmentHeader, '5001', 3);
        FoIds.Add('9001');
        FoIds.Add('9002');
        FoIds.Add('9003');
        MockFulfillmentOrders(MockClient, FoIds);
        MockFulfillmentOrderLine(MockClient, '9001', '7001', '1001', '100');
        MockFulfillmentOrderLine(MockClient, '9002', '7002', '1002', '200');
        MockFulfillmentOrderLine(MockClient, '9003', '7003', '1003', '300');
        MockClient.AddResponse(_FulfillmentCreateTok, 'FulfillmentOrderLineItem/7001', _LibFulfillment.ResponseFulfillmentCreate(''));
        MockClient.AddResponse(_FulfillmentCreateTok, 'FulfillmentOrderLineItem/7002', _LibFulfillment.ResponseFulfillmentCreate('Insufficient inventory'));
        MockClient.AddFailure(_FulfillmentCreateTok, 'FulfillmentOrderLineItem/7003');

        // [WHEN] The fulfillment sibling runs.
        GetTask(TaskEntryNo, SpfyTask);
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(SpfyTask);
        RaisedText := GetLastErrorText();

        // [THEN] The succeeded location keeps its committed entries and the failed ones save nothing, so a retry re-sends only what is still outstanding.
        _Assert.AreEqual(3, MockClient.CountRequestsContaining(_FulfillmentCreateTok), 'Every location must be attempted even after an earlier one failed');
        _Assert.AreEqual(1, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 10000)), 'The succeeded location must keep its committed fulfillment entry');
        _Assert.AreEqual(0, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 20000)), 'The rejected location must not have entries saved');
        _Assert.AreEqual(0, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 30000)), 'The unreachable location must not have entries saved');

        // [THEN] A transport failure raises, and the raised text carries the diagnostics of both failing locations.
        _Assert.IsTrue(StrPos(RaisedText, 'Location 300') > 0, StrSubstNo('The raised text must identify the unreachable location, but was: %1', RaisedText));
        _Assert.IsTrue(StrPos(RaisedText, 'Location 200: Insufficient inventory') > 0, StrSubstNo('The raised text must carry the rejected location''s Shopify message, but was: %1', RaisedText));
    end;

    [Test]
    procedure GivenUserErrorOnlyFailure_WhenFulfillmentSiblingRuns_ThenErrorIsBlankAndDiagnosticsPersistedInResponse()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Task Send Fulfillment";
        FoIds: List of [Text];
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        PersistedResponse: Text;
    begin
        // [SCENARIO] A fulfillment Shopify rejects with a userError alone retries with a blank error text and keeps its diagnostics in the task response, so it produces no error telemetry.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A one-location shipment that Shopify rejects with a userError and nothing else.
        TaskEntryNo := CreateShipmentTask(StoreCode, SalesShipmentHeader, '5001', 1);
        FoIds.Add('9001');
        MockFulfillmentOrders(MockClient, FoIds);
        MockFulfillmentOrderLine(MockClient, '9001', '7001', '1001', '100');
        MockClient.AddResponse(_FulfillmentCreateTok, _LibFulfillment.ResponseFulfillmentCreate('Insufficient inventory'));

        // [WHEN] The fulfillment sibling runs.
        GetTask(TaskEntryNo, SpfyTask);
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(SpfyTask);

        // [THEN] A userError-only failure stays out of the error channel: the task retries, but the diagnostics live in the response.
        _Assert.AreEqual('', GetLastErrorText(), 'A userError-only failure must not raise a message, so it produces no error telemetry');
        PersistedResponse := ResponseText(TaskEntryNo);
        _Assert.IsTrue(StrPos(PersistedResponse, 'Location 100: Insufficient inventory') > 0, StrSubstNo('The persisted response must carry the rejected location''s Shopify message, but was: %1', PersistedResponse));
        _Assert.AreEqual(0, FulfillmentEntryCount(ShipmentLineRecordId(SalesShipmentHeader."No.", 10000)), 'A rejected location must not have entries saved');
    end;
    #endregion

    #region Capture sibling
    [Test]
    procedure GivenPendingCapture_WhenCaptureSiblingRunsTwice_ThenBackoffIsFiveMinutesThenDoubled()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyTask: Record "NPR Spfy Task";
        BackoffTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        CapturePayment: Codeunit "NPR Spfy Task Capture Payment";
        RecRef: RecordRef;
        StoreCode: Code[20];
        FirstRunAt: DateTime;
        SecondRunAt: DateTime;
        TaskEntryNo: BigInteger;
        BackoffTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A capture Shopify reports as pending re-enqueues one follow-up five minutes out, and a second pending report doubles that delay, so a stuck capture backs off.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A claimed stage-2 capture task for a Shopify payment line, with no earlier delay to double.
        CreateInvoiceWithPaymentLine(SalesInvHeader, PaymentLine, ShopifyGatewayCode());
        RecRef.GetTable(PaymentLine);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, PaymentLine.RecordId(), '5501', "NPR Spfy Task Op"::Insert, CurrentDateTime(), 0DT, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The stage-2 task must be claimable');
        MockOrderTransactionsEmpty(MockClient);
        MockCaptureStatus(MockClient, 'PENDING');

        // [WHEN] The capture sibling runs and Shopify reports the capture pending.
        CapturePayment.SetGraphQLClient(MockClient);
        FirstRunAt := CurrentDateTime();
        CapturePayment.Run(SpfyTask);

        // [THEN] The same line is re-enqueued once, five minutes out, on the new queue only.
        _Assert.AreEqual(1, PendingTaskCountForRecord(Database::"NPR Magento Payment Line", PaymentLine.RecordId()), 'A pending capture must re-enqueue exactly one follow-up for the payment line');
        _Assert.IsTrue(FindPendingTaskForRecord(Database::"NPR Magento Payment Line", PaymentLine.RecordId(), BackoffTask), 'The follow-up capture must be readable');
        AssertNotBeforeNear(BackoffTask."Not Before Date-Time", FirstRunAt + Minutes(5), 'A first pending capture must fall back to the five minute floor');
        _Assert.AreEqual(0, NcTaskCount(), 'A pending capture must not create a legacy queue row');
        BackoffTaskEntryNo := BackoffTask."Entry No.";

        // [GIVEN] That follow-up has now waited its five minutes and is dispatched in turn.
        Clear(CapturePayment);
        SecondRunAt := CurrentDateTime();
        RescheduleClaimedTask(BackoffTaskEntryNo, SecondRunAt, SecondRunAt + Minutes(5), BackoffTask);

        // [WHEN] The capture sibling runs again and Shopify reports pending again.
        CapturePayment.SetGraphQLClient(MockClient);
        CapturePayment.Run(BackoffTask);

        // [THEN] The delay of the dispatched row is doubled, so a stuck capture backs off instead of hammering Shopify.
        _Assert.AreEqual(1, PendingTaskCountForRecord(Database::"NPR Magento Payment Line", PaymentLine.RecordId()), 'A second pending capture must re-enqueue exactly one follow-up for the payment line');
        _Assert.IsTrue(FindPendingTaskForRecord(Database::"NPR Magento Payment Line", PaymentLine.RecordId(), BackoffTask), 'The second follow-up capture must be readable');
        AssertNotBeforeNear(BackoffTask."Not Before Date-Time", CurrentDateTime() + Minutes(10), 'A repeat pending capture must double the delay of the dispatched row');
        _Assert.AreEqual(0, NcTaskCount(), 'A repeat pending capture must not create a legacy queue row');
    end;

    [Test]
    procedure GivenMovedPaymentLine_WhenCaptureSiblingRuns_ThenRecordIdRepointedAndPersisted()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        OrderPaymentLine: Record "NPR Magento Payment Line";
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        CapturePayment: Codeunit "NPR Spfy Task Capture Payment";
        RecRef: RecordRef;
        OrderLineRecId: RecordId;
        StoreCode: Code[20];
        SalesOrderNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A capture task whose payment line moved to the posted invoice is re-pointed at the moved line and the new id survives the failing send, so the retry addresses the line that exists.
        Initialize();
        StoreCode := CreateOrderStore();
        SalesOrderNo := _Lib.NextCode('SO', MaxStrLen(SalesInvHeader."Order No."));

        // [GIVEN] A capture task enqueued against the payment line of a sales order.
        OrderPaymentLine.Init();
        OrderPaymentLine."Document Table No." := Database::"Sales Header";
        OrderPaymentLine."Document Type" := OrderPaymentLine."Document Type"::Order;
        OrderPaymentLine."Document No." := SalesOrderNo;
        OrderPaymentLine."Line No." := 10000;
        OrderPaymentLine.Amount := 500;
        OrderPaymentLine."Payment Gateway Code" := ShopifyGatewayCode();
        OrderPaymentLine.Insert(false);
        OrderLineRecId := OrderPaymentLine.RecordId();
        RecRef.GetTable(OrderPaymentLine);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, OrderLineRecId, '5501', "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [GIVEN] The order is posted, so the line moves to the posted invoice and the id the task holds no longer resolves.
        SalesInvHeader.Init();
        SalesInvHeader."No." := _Lib.NextCode('PI', MaxStrLen(SalesInvHeader."No."));
        SalesInvHeader."Order No." := SalesOrderNo;
        SalesInvHeader.Insert(false);
        InvoicePaymentLine.Init();
        InvoicePaymentLine."Document Table No." := Database::"Sales Invoice Header";
        InvoicePaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        InvoicePaymentLine."Document No." := SalesInvHeader."No.";
        InvoicePaymentLine."Line No." := 10000;
        InvoicePaymentLine.Amount := 500;
        InvoicePaymentLine."Payment Gateway Code" := ShopifyGatewayCode();
        InvoicePaymentLine.Insert(false);
        OrderPaymentLine.Delete(false);
        _Lib.AssignEntryID(InvoicePaymentLine.RecordId(), '777');

        MockOrderTransactionsEmpty(MockClient);
        MockClient.AddFailure(_TransactionCreateTok);

        // [WHEN] The capture sibling runs and the Shopify capture then fails.
        GetTask(TaskEntryNo, SpfyTask);
        CapturePayment.SetGraphQLClient(MockClient);
        asserterror CapturePayment.Run(SpfyTask);
        _Assert.IsTrue(MockClient.CountRequestsContaining(_TransactionCreateTok) > 0, 'The run must fail at the mocked capture mutation, not before it');

        // [THEN] The re-resolved line was persisted before the failure, so the retry addresses the moved line instead of the vanished one.
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(InvoicePaymentLine.RecordId(), SpfyTask."Record ID", 'The capture task must be re-pointed at the payment line as it now sits on the posted invoice');
        _Assert.AreNotEqual(OrderLineRecId, SpfyTask."Record ID", 'The capture task must not keep the sales order line id it was enqueued with');
    end;

    [Test]
    procedure GivenSucceededCapture_WhenCaptureSiblingRuns_ThenChargeIdStampedAndNoFollowUp()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        CapturePayment: Codeunit "NPR Spfy Task Capture Payment";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A capture Shopify reports as succeeded stamps the transaction id and the capture date on the payment line and queues no follow-up.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A claimed stage-2 capture task for a Shopify payment line that has not been captured yet.
        CreateInvoiceWithPaymentLine(SalesInvHeader, PaymentLine, ShopifyGatewayCode());
        RecRef.GetTable(PaymentLine);
        TaskEntryNo := EnqueueTask(StoreCode, RecRef, PaymentLine.RecordId(), '5501', "NPR Spfy Task Op"::Insert, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(_SpfyTaskQueue.ClaimSingle(SpfyTask), 'The stage-2 task must be claimable');
        MockOrderTransactionsEmpty(MockClient);
        MockCaptureStatus(MockClient, 'SUCCESS');

        // [WHEN] The capture sibling runs and Shopify reports the capture succeeded.
        CapturePayment.SetGraphQLClient(MockClient);
        CapturePayment.Run(SpfyTask);

        // [THEN] The line carries the Shopify transaction id as its charge id and counts as captured, so nothing captures it a second time.
        PaymentLine.Find();
        _Assert.AreEqual('555', PaymentLine."Charge ID", 'A succeeded capture must record the Shopify transaction id as the charge id');
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'A succeeded capture must stamp the capture date on the payment line');
        _Assert.IsFalse(PaymentLine."Capture Requested", 'A succeeded capture must not leave the line marked as only requested');
        _Assert.AreEqual(0, PendingTaskCountForRecord(Database::"NPR Magento Payment Line", PaymentLine.RecordId()), 'A succeeded capture must not re-enqueue a follow-up for the payment line');
        _Assert.AreEqual(0, NcTaskCount(), 'A succeeded capture must not create a legacy queue row');
    end;
    #endregion

    #region Ready for pickup sibling
    [Test]
    procedure GivenPickupTask_WhenSiblingRuns_ThenEventRaisedAfterBackfillBeforeFulfillmentOrderQuery()
    var
        NpCsDocument: Record "NPR NpCs Document";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ReadyForPickup: Codeunit "NPR Spfy Task Ready For Pickup";
        PickupEventSub: Codeunit "NPR Spfy TL Pickup Event Sub";
        RecRef: RecordRef;
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A pickup send raises its event after the store code is backfilled and before the fulfillment order query, so a subscriber can refuse the send before anything reaches Shopify.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A pickup task whose store code has to be backfilled from the document's assigned store.
        NpCsDocument := CreateNpCsDocument(_Lib.NextCode('SO', 20));
        AssignStoreCode(NpCsDocument.RecordId(), StoreCode);
        RecRef.GetTable(NpCsDocument);
        TaskEntryNo := EnqueueTask('', RecRef, NpCsDocument.RecordId(), '5503', "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [WHEN] A subscriber that refuses the send is bound and the pickup sibling runs.
        PickupEventSub.SetRaiseError(true);
        BindSubscription(PickupEventSub);
        GetTask(TaskEntryNo, SpfyTask);
        Commit();
        ReadyForPickup.SetGraphQLClient(MockClient);
        asserterror ReadyForPickup.Run(SpfyTask);
        _Assert.ExpectedError(PickupEventSub.RefusalText());
        UnbindSubscription(PickupEventSub);

        // [THEN] The subscriber was handed the backfilled store and the Shopify order id, so it can decide before anything is sent.
        _Assert.IsTrue(PickupEventSub.Raised(), 'The pickup send must raise the event before it contacts Shopify');
        _Assert.AreEqual(StoreCode, PickupEventSub.RaisedShopifyStoreCode(), 'The event must carry the store code backfilled from the document');
        _Assert.AreEqual('5503', PickupEventSub.RaisedShopifyOrderId(), 'The event must carry the Shopify order id the task was enqueued with');
        _Assert.AreEqual(NpCsDocument."Document No.", PickupEventSub.DocumentNo(), 'The event must carry the resolved pickup document');

        // [THEN] Nothing reached Shopify, and the backfill is still unpersisted, which pins the event ahead of the fulfillment order query.
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A subscriber that refuses the send must stop it before the fulfillment order query');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Store Code", 'The backfilled store code must not be persisted before the send, which is what places the event ahead of it');
    end;
    #endregion

    #region POS entry sibling
    [Test]
    procedure GivenIneligiblePOSEntries_WhenPOSEntrySiblingRuns_ThenUnsentCompletionsAndNotSyncedError()
    var
        CustomerlessPOSEntry: Record "NPR POS Entry";
        ZeroQuantityPOSEntry: Record "NPR POS Entry";
        UnsyncedCustomerPOSEntry: Record "NPR POS Entry";
        SyncedCustomer: Record Customer;
        UnsyncedCustomer: Record Customer;
        SyncedCustomerLink: Record "NPR Spfy Store-Customer Link";
        UnsyncedCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        RecRef: RecordRef;
        StoreCode: Code[20];
        CustomerlessTaskEntryNo: BigInteger;
        ZeroQuantityTaskEntryNo: BigInteger;
        UnsyncedCustomerTaskEntryNo: BigInteger;
        RaisedText: Text;
    begin
        // [SCENARIO] A customerless POS entry and one with no positive sales line each complete unsent with the reason on the task, while an entry whose customer is not yet synced errors so it retries.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A POS entry posted without a customer.
        CustomerlessPOSEntry := CreatePOSEntry('', 120, true);
        RecRef.GetTable(CustomerlessPOSEntry);
        CustomerlessTaskEntryNo := EnqueueTask(StoreCode, RecRef, CustomerlessPOSEntry.RecordId(), Format(CustomerlessPOSEntry."Entry No."), "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [WHEN] The POS entry sibling runs.
        GetTask(CustomerlessTaskEntryNo, SpfyTask);
        SendPOSEntry.SetGraphQLClient(MockClient);
        SendPOSEntry.Run(SpfyTask);

        // [THEN] It completes unsent with the reason on the task.
        _Assert.IsTrue(StrPos(ResponseText(CustomerlessTaskEntryNo), _CustomerlessTok) > 0, StrSubstNo('A customerless POS entry must record why it was not sent, but recorded: %1', ResponseText(CustomerlessTaskEntryNo)));

        // [GIVEN] A POS entry for a synced customer whose only sales line has no positive quantity.
        _Lib.CreateCustomerWithLink(SyncedCustomer, SyncedCustomerLink, StoreCode, true, true);
        _Lib.AssignEntryID(SyncedCustomerLink.RecordId(), 'C1');
        ZeroQuantityPOSEntry := CreatePOSEntry(SyncedCustomer."No.", 120, false);
        RecRef.GetTable(ZeroQuantityPOSEntry);
        ZeroQuantityTaskEntryNo := EnqueueTask(StoreCode, RecRef, ZeroQuantityPOSEntry.RecordId(), Format(ZeroQuantityPOSEntry."Entry No."), "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [WHEN] The POS entry sibling runs.
        Clear(SendPOSEntry);
        GetTask(ZeroQuantityTaskEntryNo, SpfyTask);
        SendPOSEntry.SetGraphQLClient(MockClient);
        SendPOSEntry.Run(SpfyTask);

        // [THEN] Shopify only accepts positive quantities, so the entry completes unsent rather than failing forever.
        _Assert.IsTrue(StrPos(ResponseText(ZeroQuantityTaskEntryNo), _NotEligibleTok) > 0, StrSubstNo('A POS entry with no positive line must record why it was not sent, but recorded: %1', ResponseText(ZeroQuantityTaskEntryNo)));

        // [GIVEN] A POS entry for a customer whose link has not been synced to Shopify yet.
        _Lib.CreateCustomerWithLink(UnsyncedCustomer, UnsyncedCustomerLink, StoreCode, true, true);
        UnsyncedCustomerPOSEntry := CreatePOSEntry(UnsyncedCustomer."No.", 120, true);
        RecRef.GetTable(UnsyncedCustomerPOSEntry);
        UnsyncedCustomerTaskEntryNo := EnqueueTask(StoreCode, RecRef, UnsyncedCustomerPOSEntry.RecordId(), Format(UnsyncedCustomerPOSEntry."Entry No."), "NPR Spfy Task Op"::Insert, CurrentDateTime());

        // [WHEN] The POS entry sibling runs.
        Clear(SendPOSEntry);
        GetTask(UnsyncedCustomerTaskEntryNo, SpfyTask);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);
        RaisedText := GetLastErrorText();

        // [THEN] It errors instead of completing, so it retries once the customer task has landed.
        _Assert.IsTrue(StrPos(RaisedText, _CustomerNotSyncedTok) > 0, StrSubstNo('A POS entry for an unsynced customer must report the missing customer sync, but reported: %1', RaisedText));
        _Assert.AreEqual(0, MockClient.RequestCount(), 'None of the ineligible POS entries may reach Shopify');
    end;
    #endregion
}
