codeunit 85528 "NPR Spfy TL POS Return Tests"
{
    // [FEATURE] Shopify Task List - POS return lines: eligibility, origin resolution, the waiting precondition and the refund step
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _ReturnResolver: Codeunit "NPR Spfy POS Return Resolver";
        _GLRoundingPrecision: Decimal;
        _GLRoundingPrecisionSaved: Boolean;
        _ServerErrorCalls: Integer;

    local procedure Initialize()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SpfyTask: Record "NPR Spfy Task";
        LcyCodeLbl: Label 'ZZLCY', Locked = true;
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        // The refund step compares the store currency, derived from the LCY, with the mock order's currency; a blank LCY would compare blanks.
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then begin
            GeneralLedgerSetup."LCY Code" := LcyCodeLbl;
            GeneralLedgerSetup.Modify();
        end;
        // A test may change the rounding precision; every test starts from the company's own.
        if not _GLRoundingPrecisionSaved then begin
            _GLRoundingPrecision := GeneralLedgerSetup."Amount Rounding Precision";
            _GLRoundingPrecisionSaved := true;
        end;
        if GeneralLedgerSetup."Amount Rounding Precision" <> _GLRoundingPrecision then begin
            GeneralLedgerSetup."Amount Rounding Precision" := _GLRoundingPrecision;
            GeneralLedgerSetup.Modify();
        end;
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetTaskListFeatureEnabled(true);
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
    end;

    #region Fixtures
    local procedure CreateStore(): Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.Init();
        ShopifyStore.Code := _Lib.NextCode('S', MaxStrLen(ShopifyStore.Code));
        ShopifyStore.Enabled := true;
        ShopifyStore."Sales Order Integration" := true;
        ShopifyStore."BC Customer Transactions" := true;
        ShopifyStore.Insert(false);
        exit(ShopifyStore.Code);
    end;

    local procedure CreateSyncedCustomer(StoreCode: Code[20]) CustomerNo: Code[20]
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.AssignEntryID(SpfyStoreCustomerLink.RecordId(), 'C' + Customer."No.");
        exit(Customer."No.");
    end;

    local procedure CreatePOSEntry(CustomerNo: Code[20]; EntryDate: Date) POSEntry: Record "NPR POS Entry"
    begin
        POSEntry.Init();
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry."Entry Date" := EntryDate;
        POSEntry."Customer No." := CustomerNo;
        POSEntry."Document No." := _Lib.NextCode('T', MaxStrLen(POSEntry."Document No."));
        POSEntry."System Entry" := false;
        POSEntry.Insert(true);
    end;

    local procedure AddLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; LineType: Option; ItemNo: Code[20]; VariantCode: Code[10]; Qty: Decimal; AmountInclVAT: Decimal; Description: Text[100]) POSEntrySalesLine: Record "NPR POS Entry Sales Line"
    begin
        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := LineNo;
        POSEntrySalesLine."Document No." := POSEntry."Document No.";
        POSEntrySalesLine.Type := LineType;
        POSEntrySalesLine."No." := ItemNo;
        POSEntrySalesLine."Variant Code" := VariantCode;
        POSEntrySalesLine.Quantity := Qty;
        POSEntrySalesLine."Amount Incl. VAT" := AmountInclVAT;
        if Qty <> 0 then
            POSEntrySalesLine."Unit Price" := Abs(AmountInclVAT / Qty);
        POSEntrySalesLine.Description := Description;
        POSEntrySalesLine.Insert(true);
        AddToEntryTotals(POSEntry."Entry No.", AmountInclVAT);
    end;

    // A posted entry carries its totals; the sale eligibility rule reads them, so the fixture keeps them in step with the lines.
    local procedure AddToEntryTotals(POSEntryNo: Integer; AmountInclVAT: Decimal)
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSEntryNo);
        POSEntry."Amount Incl. Tax" += AmountInclVAT;
        POSEntry."Amount Excl. Tax" += Round(AmountInclVAT / 1.25, 0.01);
        POSEntry.Modify(false);
    end;

    local procedure AddItemLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; AmountInclVAT: Decimal) POSEntrySalesLine: Record "NPR POS Entry Sales Line"
    begin
        POSEntrySalesLine := AddLine(POSEntry, LineNo, POSEntrySalesLine.Type::Item, ItemNo, '', Qty, AmountInclVAT, 'Item ' + ItemNo);
    end;

    local procedure LinkReturnLine(var ReturnLine: Record "NPR POS Entry Sales Line"; OriginalLine: Record "NPR POS Entry Sales Line")
    begin
        ReturnLine."Orig.POS Entry S.Line SystemId" := OriginalLine.SystemId;
        ReturnLine."Return Sale Sales Ticket No." := OriginalLine."Document No.";
        ReturnLine.Modify(false);
    end;

    local procedure LinkRecordId(POSEntryNo: Integer; StoreCode: Code[20]): RecordId
    var
        SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link";
    begin
        SpfyStorePOSEntryLink."POS Entry No." := POSEntryNo;
        SpfyStorePOSEntryLink."Shopify Store Code" := StoreCode;
        exit(SpfyStorePOSEntryLink.RecordId());
    end;

    local procedure MarkSent(POSEntryNo: Integer; StoreCode: Code[20]; ShopifyOrderId: Text[30])
    begin
        _Lib.AssignEntryID(LinkRecordId(POSEntryNo, StoreCode), ShopifyOrderId);
    end;

    local procedure SetHighWaterMarkAtLatest(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        POSEntry: Record "NPR POS Entry";
    begin
        ShopifyStore.Get(StoreCode);
        POSEntry.SetCurrentKey(SystemRowVersion);
        POSEntry.FindLast();
        ShopifyStore.SetLastPOSRowVersion(POSEntry.SystemRowVersion);
    end;

    local procedure SetHighWaterMarkAtLatestOrZero(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        POSEntry: Record "NPR POS Entry";
    begin
        ShopifyStore.Get(StoreCode);
        POSEntry.SetCurrentKey(SystemRowVersion);
        if POSEntry.FindLast() then
            ShopifyStore.SetLastPOSRowVersion(POSEntry.SystemRowVersion)
        else
            ShopifyStore.SetLastPOSRowVersion(0);
    end;

    local procedure AddPaymentLine(POSEntry: Record "NPR POS Entry"; LineNo: Integer; PaymentMethodCode: Code[10]; Amount: Decimal)
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.Init();
        POSEntryPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryPaymentLine."Line No." := LineNo;
        POSEntryPaymentLine."POS Payment Method Code" := PaymentMethodCode;
        POSEntryPaymentLine."Amount (Sales Currency)" := Amount;
        POSEntryPaymentLine.Insert(false);
    end;

    local procedure OrderTransactions(OrderRequest: Text; var Transactions: JsonArray): Boolean
    var
        Request: JsonObject;
        TransactionsToken: JsonToken;
    begin
        Request.ReadFrom(OrderRequest);
        if not Request.SelectToken('variables.order.transactions', TransactionsToken) then
            exit(false);
        Transactions := TransactionsToken.AsArray();
        exit(true);
    end;

    local procedure AssertSingleTransaction(OrderRequest: Text; ExpectedKind: Text; ExpectedGateway: Text; ExpectedAmount: Decimal)
    var
        Transactions: JsonArray;
        Transaction: JsonToken;
        Value: JsonToken;
    begin
        _Assert.IsTrue(OrderTransactions(OrderRequest, Transactions), 'The order carries transactions: ' + OrderRequest);
        _Assert.AreEqual(1, Transactions.Count(), 'One transaction: ' + OrderRequest);
        Transactions.Get(0, Transaction);
        Transaction.SelectToken('kind', Value);
        _Assert.AreEqual(ExpectedKind, Value.AsValue().AsText(), 'Transaction kind');
        Transaction.SelectToken('gateway', Value);
        _Assert.AreEqual(ExpectedGateway, Value.AsValue().AsText(), 'Transaction gateway');
        Transaction.SelectToken('amountSet.shopMoney.amount', Value);
        _Assert.AreEqual(ExpectedAmount, Value.AsValue().AsDecimal(), 'Transaction amount');
    end;

    local procedure AssertTransactionsByGateway(OrderRequest: Text; Gateway1: Text; Amount1: Decimal; Gateway2: Text; Amount2: Decimal)
    var
        Transactions: JsonArray;
        Transaction: JsonToken;
        Value: JsonToken;
        AmountByGateway: Dictionary of [Text, Decimal];
    begin
        _Assert.IsTrue(OrderTransactions(OrderRequest, Transactions), 'The order carries transactions: ' + OrderRequest);
        _Assert.AreEqual(2, Transactions.Count(), 'Two transactions: ' + OrderRequest);
        foreach Transaction in Transactions do begin
            Transaction.SelectToken('kind', Value);
            _Assert.AreEqual('SALE', Value.AsValue().AsText(), 'Transaction kind');
            Transaction.SelectToken('amountSet.shopMoney.amount', Value);
            AmountByGateway.Set(GatewayOf(Transaction), Value.AsValue().AsDecimal());
        end;
        _Assert.IsTrue(AmountByGateway.ContainsKey(Gateway1), Gateway1 + ': ' + OrderRequest);
        _Assert.IsTrue(AmountByGateway.ContainsKey(Gateway2), Gateway2 + ': ' + OrderRequest);
        _Assert.AreEqual(Amount1, AmountByGateway.Get(Gateway1), Gateway1);
        _Assert.AreEqual(Amount2, AmountByGateway.Get(Gateway2), Gateway2);
    end;

    local procedure GatewayOf(Transaction: JsonToken): Text
    var
        Value: JsonToken;
    begin
        Transaction.SelectToken('gateway', Value);
        exit(Value.AsValue().AsText());
    end;

    local procedure CreateItem() ItemNo: Code[20]
    var
        Item: Record Item;
    begin
        _Lib.CreateItem(Item);
        exit(Item."No.");
    end;

    local procedure EnqueuePOSEntryTask(StoreCode: Code[20]; POSEntry: Record "NPR POS Entry"): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(POSEntry);
        _SpfyTaskQueue.Enqueue(StoreCode, RecRef, POSEntry.RecordId(), Format(POSEntry."Entry No."), "NPR Spfy Task Op"::Insert, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, CurrentDateTime(), SpfyTask);
        exit(SpfyTask."Entry No.");
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

    local procedure CreateReturnReason(Description: Text[100]) ReasonCode: Code[10]
    var
        ReturnReason: Record "Return Reason";
    begin
        ReasonCode := CopyStr(_Lib.NextCode('RR', MaxStrLen(ReturnReason.Code)), 1, MaxStrLen(ReturnReason.Code));
        ReturnReason.Init();
        ReturnReason.Code := ReasonCode;
        ReturnReason.Description := Description;
        ReturnReason.Insert();
    end;

    local procedure ExpectedNoteMarker(ReturnEntry: Record "NPR POS Entry"): Text
    begin
        exit('POS Return ' + Format(ReturnEntry."Entry No.") + '/' + ReturnEntry."Document No.");
    end;

    // A currency no company has as its LCY, so a currency test never depends on the container's LCY.
    local procedure ForeignCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        Currency.Init();
        Currency.Code := 'ZZFX';
        Currency."ISO Code" := 'XTS';
        if Currency.Insert() then;
        exit(Currency.Code);
    end;

    local procedure CreatePaymentMethod(MethodCode: Code[10]; Description: Text[50])
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSPaymentMethod.Get(MethodCode) then
            POSPaymentMethod.Delete(false);
        POSPaymentMethod.Init();
        POSPaymentMethod.Code := MethodCode;
        POSPaymentMethod.Description := Description;
        POSPaymentMethod.Insert(false);
    end;

    local procedure SetPaymentLineDescription(POSEntryNo: Integer; LineNo: Integer; Description: Text[100])
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntryPaymentLine.Get(POSEntryNo, LineNo);
        POSEntryPaymentLine.Description := Description;
        POSEntryPaymentLine.Modify(false);
    end;

    local procedure Occurrences(Value: Text; Pattern: Text) MatchCount: Integer
    var
        Position: Integer;
    begin
        Position := StrPos(Value, Pattern);
        while Position > 0 do begin
            MatchCount += 1;
            Value := CopyStr(Value, Position + StrLen(Pattern));
            Position := StrPos(Value, Pattern);
        end;
    end;
    #endregion

    #region Resolver
    [Test]
    procedure GivenReturnLineWithSentOriginal_WhenResolved_ThenCaseIsLinkedWithTargetOrderId()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line linked to a POS sale that has a Shopify order id in the store resolves as Linked with that order as its target.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A sent original sale and a return of one of its lines.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 2, 400);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved for the store.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The single row is Linked and targets the original's Shopify order with the absolute quantity and amount.
        _Assert.AreEqual(1, TempReturnLineBuf.Count(), 'One return line expected');
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Linked, 'Case must be Linked');
        _Assert.AreEqual('18943015682268', TempReturnLineBuf."Target Shopify Order ID", 'Target order');
        _Assert.AreEqual(OriginalEntry."Entry No.", TempReturnLineBuf."Original POS Entry No.", 'Original entry');
        _Assert.AreEqual(1, TempReturnLineBuf.Quantity, 'Quantity is the absolute value');
        _Assert.AreEqual(200, TempReturnLineBuf."Amount Incl. VAT", 'Amount is the absolute value');
        _Assert.IsTrue(TempReturnLineBuf."Is Item Line", 'Item line flag');
    end;

    [Test]
    procedure GivenReturnLineWithEligibleUnsentOriginal_WhenResolved_ThenCaseIsPending()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original sale is eligible for the store, has no Shopify order id and sits above the store's row-version mark resolves as Pending.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] The store's mark is taken before the original is posted, so the scheduler has not reached it.
        SetHighWaterMarkAtLatestOrZero(StoreCode);
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Pending and names the original.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Pending, 'Case must be Pending');
        _Assert.AreEqual(OriginalEntry."Entry No.", TempReturnLineBuf."Original POS Entry No.", 'Original entry');
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalHasUnfinishedTask_WhenResolved_ThenCaseIsPending()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original sale is below the store's row-version mark but still has an unfinished task resolves as Pending, because the open task wins over the mark.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] An original with an open task, and the mark moved past it.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        EnqueuePOSEntryTask(StoreCode, OriginalEntry);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        SetHighWaterMarkAtLatest(StoreCode);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Pending.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Pending, 'An open task for the original must keep the line Pending');
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalIsBeforeCutOffDate_WhenResolved_ThenCaseIsUnlinkedWithCutOffReason()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original sale was posted before the store's historical cut-off date resolves as Unlinked, because that sale will never be sent.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A cut-off date after the original's entry date.
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Historical Data Cut-Off Date" := Today();
        ShopifyStore.Modify(false);
        OriginalEntry := CreatePOSEntry(CustomerNo, CalcDate('<-1Y>', Today()));
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason names the original and the cut-off date field by its caption.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, 'Case must be Unlinked');
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", Format(OriginalEntry."Entry No.")) > 0, 'Reason must name the original');
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'before the store''s ' + ShopifyStore.FieldCaption("Historical Data Cut-Off Date")) > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalCustomerIsNotSyncedToStore_WhenResolved_ThenCaseIsUnlinked()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original sale belongs to a customer that is not synced to the store resolves as Unlinked.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();

        // [GIVEN] A customer whose store link has Sync. to this Store off.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, false, true);
        OriginalEntry := CreatePOSEntry(Customer."No.", Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        ReturnEntry := CreatePOSEntry(Customer."No.", Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason names the link's sync field by its caption.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, 'Case must be Unlinked');
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", SpfyStoreCustomerLink.FieldCaption("Sync. to this Store") + ' is not set') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWithoutOriginFields_WhenResolved_ThenCaseIsUnlinked()
    var
        ReturnEntry: Record "NPR POS Entry";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] A manually keyed negative line with no origin resolves as Unlinked with the "not linked" reason.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A return entry whose line has no original.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked with the not-linked reason.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, 'Case must be Unlinked');
        _Assert.AreEqual('The line is not linked to a POS sale.', TempReturnLineBuf."Unlinked Reason", 'Reason');
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalWasSkippedAsHistorical_WhenResolved_ThenCaseIsUnlinked()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original sale is below the store's row-version mark, has no task and no Shopify order id resolves as Unlinked, because the scheduler has passed it.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] An original with no task and the mark moved past it.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        SetHighWaterMarkAtLatest(StoreCode);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, 'Case must be Unlinked once the mark has passed the original');
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'passed it without sending it') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenNonItemReturnLine_WhenResolved_ThenItemFlagIsFalseAndTitleIsDescription()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] A non-item return line resolves with the item flag off and the title the sale sync sent, so the sender can match it by title.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent original with a G/L account line and a return of it.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 1, 225, 'Deposit');
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -1, -225, 'Deposit');
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Linked, not an item line, titled by the description.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Linked, 'Case must be Linked');
        _Assert.IsFalse(TempReturnLineBuf."Is Item Line", 'Not an item line');
        _Assert.AreEqual('Deposit', TempReturnLineBuf."Line Title", 'Title');
    end;

    [Test]
    procedure GivenReturnOfNonItemLineWithoutDescription_WhenResolved_ThenTitleIsTheOneTheSaleSent()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        SentTitle: Text;
    begin
        // [SCENARIO] A non-item line without a description is sent to Shopify under a fallback title, and its return carries that same title so the sender can match it.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent original with a G/L account line without a description, and a return of it without a description.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 1, 225, '');
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -1, -225, '');
        LinkReturnLine(ReturnLine, OriginalLine);
        SentTitle := SpfyPOSEntryExportMgt.GetLineItemTitle(OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Linked and titled with the title the sale sent, which is not blank.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Linked, 'Case must be Linked');
        _Assert.AreNotEqual('', SentTitle, 'The sale sends a fallback title');
        _Assert.AreEqual(SentTitle, TempReturnLineBuf."Line Title", 'Title');
    end;

    [Test]
    procedure GivenReturnLineKeyedAtAnotherUnitPrice_WhenResolved_ThenItIsMatchedOnTheOriginalUnitPrice()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] A return line is matched against the line item the sale sent, so its unit price comes from the original line even when the return was keyed at another price.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent original with a G/L account line of 100 and a return of it keyed at 90.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 1, 100, 'Deposit');
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -1, -90, 'Deposit');
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row carries the original unit price 100, while the amount to refund stays the 90 the POS paid back.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(100, TempReturnLineBuf."Unit Price", 'Unit price of the original line');
        _Assert.AreEqual(90, TempReturnLineBuf."Amount Incl. VAT", 'Amount of the return line');
    end;

    [Test]
    procedure GivenDiscountedNonItemOriginalLine_WhenResolved_ThenItCarriesThePricesTheSaleSentForIt()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] A return of a discounted non-item line carries the line item prices the sale sent for the original line, on the original entry's VAT basis, beside the original unit price that older orders carry.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent original with prices including VAT and a G/L account line of 3 units at 60 discounted to 170, which the sale sends as 1 x 56.66 and 2 x 56.67.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalEntry."Prices Including VAT" := true;
        OriginalEntry.Modify(false);
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 3, 170, 'Deposit');
        OriginalLine."Amount Excl. VAT" := 136;
        OriginalLine."Unit Price" := 60;
        OriginalLine.Modify(false);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');

        // [GIVEN] A return of the whole line on an entry with prices excluding VAT.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -3, -170, 'Deposit');
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row carries both line item prices and the original unit price.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(56.66, TempReturnLineBuf."Line Item Price", 'First line item price');
        _Assert.AreEqual(56.67, TempReturnLineBuf."Line Item Price 2", 'Second line item price');
        _Assert.AreEqual(60, TempReturnLineBuf."Unit Price", 'Original unit price');
    end;

    [Test]
    procedure GivenFractionalReturnQuantity_WhenResolved_ThenItRoundsUpLikeTheSaleSentIt()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A fractional return quantity rounds up to whole units, the way the sale part sends a fractional quantity, so 0.4 is refunded as one unit.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A sent original of 2.4 units and a return of 0.4 of them.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 2.4, 240);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -0.4, -40);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row asks for one unit.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(1, TempReturnLineBuf.Quantity, 'Quantity in whole units');
    end;
    #endregion

    #region Eligibility
    [Test]
    procedure GivenReturnOnlyEntry_WhenEligibilityIsChecked_ThenItIsEligibleWithReturnsAndNotForTheFrozenSender()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        EligibleWithReturns: Boolean;
        EligibleWithoutReturns: Boolean;
        EligibleUnderOldRule: Boolean;
    begin
        // [SCENARIO] A POS entry with only negative lines is eligible when returns are included and stays ineligible under the old rule the frozen sender uses.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return-only entry with a negative total.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        ReturnEntry.Get(ReturnEntry."Entry No.");

        // [WHEN] Both rules are evaluated.
        EligibleWithReturns := SpfyPOSEntryExportMgt.IsEligibleForSync(ReturnEntry, true);
        EligibleWithoutReturns := SpfyPOSEntryExportMgt.IsEligibleForSync(ReturnEntry, false);
        EligibleUnderOldRule := SpfyPOSEntryExportMgt.IsEligibleForSync(ReturnEntry);

        // [THEN] Only the rule with returns accepts it.
        _Assert.IsTrue(EligibleWithReturns, 'Eligible with returns');
        _Assert.IsFalse(EligibleWithoutReturns, 'Not eligible without returns');
        _Assert.IsFalse(EligibleUnderOldRule, 'The old rule is unchanged');
    end;

    [Test]
    procedure GivenEqualValueExchange_WhenEligibilityIsChecked_ThenItIsEligibleWithReturns()
    var
        ExchangeEntry: Record "NPR POS Entry";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        ItemNo: Code[20];
        Eligible: Boolean;
    begin
        // [SCENARIO] An exchange with a zero total is eligible when returns are included, because eligibility is now line-based.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();

        // [GIVEN] One positive and one negative line of equal value.
        ExchangeEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(ExchangeEntry, 10000, ItemNo, 1, 200);
        AddItemLine(ExchangeEntry, 20000, ItemNo, -1, -200);
        ExchangeEntry.Get(ExchangeEntry."Entry No.");

        // [WHEN] The rule with returns is evaluated.
        Eligible := SpfyPOSEntryExportMgt.IsEligibleForSync(ExchangeEntry, true);

        // [THEN] It accepts the entry.
        _Assert.IsTrue(Eligible, 'Equal-value exchange must be eligible');
    end;

    [Test]
    procedure GivenReturnOnlyEntryAndInactiveTaskQueue_WhenSchedulerRuns_ThenNoTaskIsCreated()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        NcTask: Record "NPR Nc Task";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] With the Task List inactive the scheduler leaves a return-only entry alone, so the frozen Nc Task sender never receives it.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        _Lib.SetTaskListFeatureEnabled(false);

        // [GIVEN] A return-only entry and a pointer buffer for the store.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TempSpfyExportPointerBuffer.Add(StoreCode, 0D, 0);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
        SpfyStoreCustomerLink.SetRange("Shopify Store Code", StoreCode);
        NcTask.DeleteAll(false);

        // [WHEN] The scheduler processes the entry.
        SpfyPOSEntryExportMgt.ProcessPOSEntry(ReturnEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] No Nc task was created.
        NcTask.SetRange("Record ID", ReturnEntry.RecordId());
        _Assert.IsTrue(NcTask.IsEmpty(), 'No task for a return-only entry on the legacy queue');
    end;

    [Test]
    procedure GivenReturnOnlyEntryAndActiveTaskQueue_WhenSchedulerRuns_ThenATaskIsCreated()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        SpfyTask: Record "NPR Spfy Task";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        TaskCreated: Boolean;
    begin
        // [SCENARIO] With the Task List active the scheduler creates a task for a return-only entry.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A return-only entry and a pointer buffer for the store.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TempSpfyExportPointerBuffer.Add(StoreCode, 0D, 0);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
        SpfyStoreCustomerLink.SetRange("Shopify Store Code", StoreCode);

        // [WHEN] The scheduler processes the entry.
        TaskCreated := SpfyPOSEntryExportMgt.ProcessPOSEntry(ReturnEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] A Spfy task for the entry exists.
        _Assert.IsTrue(TaskCreated, 'A task must be created');
        SpfyTask.SetRange("Record ID", ReturnEntry.RecordId());
        _Assert.IsFalse(SpfyTask.IsEmpty(), 'Task List task for the return entry');
    end;

    [Test]
    procedure GivenReturnOnlyEntryWhoseTaskCompleted_WhenSchedulerSeesItAgain_ThenNoSecondTaskIsCreated()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        SpfyTask: Record "NPR Spfy Task";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        TaskCreated: Boolean;
    begin
        // [SCENARIO] A return-only entry never gets a Shopify order of its own, so once its task has run, a later change to the entry (posting) does not queue it again; Send Again is the way to rerun it.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A return-only entry whose Task List task has completed, and a pointer buffer for the store.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        SpfyTask.Get(EnqueuePOSEntryTask(StoreCode, ReturnEntry));
        SpfyTask.State := SpfyTask.State::Completed;
        SpfyTask.Modify();
        TempSpfyExportPointerBuffer.Add(StoreCode, 0D, 0);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
        SpfyStoreCustomerLink.SetRange("Shopify Store Code", StoreCode);

        // [WHEN] The scheduler processes the entry again.
        TaskCreated := SpfyPOSEntryExportMgt.ProcessPOSEntry(ReturnEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] No task is created and the entry still has its one task.
        _Assert.IsFalse(TaskCreated, 'No second task');
        SpfyTask.Reset();
        SpfyTask.SetRange("Record ID", ReturnEntry.RecordId());
        _Assert.AreEqual(1, SpfyTask.Count(), 'One task for the return entry');
    end;

    [Test]
    procedure GivenExchangeEntryWhoseTaskCompletedWithoutAnOrder_WhenSchedulerSeesItAgain_ThenANewTaskIsCreated()
    var
        ExchangeEntry: Record "NPR POS Entry";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        SpfyTask: Record "NPR Spfy Task";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        TaskCreated: Boolean;
    begin
        // [SCENARIO] Only a return-only entry is marked as handled by its task; an entry with sale lines is queued again while it has no Shopify order, as any sale is.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] An exchange entry without a Shopify order whose Task List task has completed, and a pointer buffer for the store.
        ExchangeEntry := CreatePOSEntry(CustomerNo, Today());
        AddItemLine(ExchangeEntry, 10000, CreateItem(), -1, -200);
        AddItemLine(ExchangeEntry, 20000, CreateItem(), 1, 300);
        ExchangeEntry.Get(ExchangeEntry."Entry No.");
        SpfyTask.Get(EnqueuePOSEntryTask(StoreCode, ExchangeEntry));
        SpfyTask.State := SpfyTask.State::Completed;
        SpfyTask.Modify();
        TempSpfyExportPointerBuffer.Add(StoreCode, 0D, 0);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
        SpfyStoreCustomerLink.SetRange("Shopify Store Code", StoreCode);

        // [WHEN] The scheduler processes the entry again.
        TaskCreated := SpfyPOSEntryExportMgt.ProcessPOSEntry(ExchangeEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] A second task is created.
        _Assert.IsTrue(TaskCreated, 'A new task');
        SpfyTask.Reset();
        SpfyTask.SetRange("Record ID", ExchangeEntry.RecordId());
        _Assert.AreEqual(2, SpfyTask.Count(), 'Two tasks for the exchange entry');
    end;
    #endregion

    #region Waiting
    [Test]
    procedure GivenPendingReturnTask_WhenCycleRuns_ThenTaskWaitsWithOriginalSaleReasonAndZeroAttempts()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        ReturnTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A return task whose original sale still has an unfinished task waits with the original-sale reason and spends no attempt.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] An original with an open task and a return of it with its own task; the boundary mock fails every dispatch so the original stays open.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        EnqueuePOSEntryTask(StoreCode, OriginalEntry);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnTaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        _BndMock.SetWholeCallFailure('simulated dispatch failure');
        Commit();

        // [WHEN] A store cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, CurrentDateTime());

        // [THEN] The return task is Waiting with the original-sale reason and no attempt.
        SpfyTask.Get(ReturnTaskEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Waiting, StrSubstNo('Expected Waiting, found %1', SpfyTask.State));
        _Assert.AreEqual('Awaiting the original POS sale''s Shopify order', SpfyTask."Waiting Reason", 'Waiting reason');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'No attempt spent while waiting');
    end;

    [Test]
    procedure GivenWaitingReturnTask_WhenOriginalGetsItsOrderId_ThenNextCycleDispatchesIt()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        OriginalTaskEntryNo: BigInteger;
        ReturnTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Once the original sale has its Shopify order id and no open task, the waiting return task is released and dispatched on the next cycle.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A return task left Waiting behind an open original task.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        OriginalTaskEntryNo := EnqueuePOSEntryTask(StoreCode, OriginalEntry);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnTaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        _BndMock.SetWholeCallFailure('simulated dispatch failure');
        Commit();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, CurrentDateTime());
        SpfyTask.Get(ReturnTaskEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Waiting, 'Precondition: the return task waits');

        // [GIVEN] The original is sent: its order id is assigned and its task completed.
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        SpfyTask.Get(OriginalTaskEntryNo);
        _SpfyTaskQueue.CompleteNoLongerApplicable(SpfyTask, 'sent by the test');
        _BndMock.Reset();
        Commit();

        // [WHEN] The next cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, CurrentDateTime() + 60000);

        // [THEN] The return task reached the boundary and is no longer waiting.
        _Assert.IsTrue(_BndMock.DispatchCount() > 0, 'The return task must have been dispatched');
        SpfyTask.Get(ReturnTaskEntryNo);
        _Assert.IsFalse(SpfyTask.State = SpfyTask.State::Waiting, 'The return task must have left Waiting');
    end;
    #endregion

    #region Sender
    [Test]
    procedure GivenReturnOnlyEntryWithUnlinkedLine_WhenSiblingRuns_ThenNoRequestAndSummaryResponse()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A return-only entry whose line is not linked to a POS sale in Shopify completes unsent with a response naming the line and the reason, and nothing reaches Shopify.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return-only entry with a manual negative line and its task.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        SendPOSEntry.Run(SpfyTask);

        // [THEN] No request was sent and the response names line 10000 as not linked.
        _Assert.AreEqual(0, MockClient.RequestCount(), 'Nothing may reach Shopify');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 10000: not sent. The line is not linked to a POS sale.') > 0, StrSubstNo('Unexpected response: %1', ResponseText(TaskEntryNo)));
    end;

    [Test]
    procedure GivenReturnOnlyEntryForUnsyncedCustomer_WhenSiblingRuns_ThenCustomerNotSyncedErrorAndNoRequest()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        ReturnEntry: Record "NPR POS Entry";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A return-only entry whose customer is not yet synced errors with the existing customer-not-synced message, so it retries, and nothing reaches Shopify.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A customer link without a Shopify id and a return entry for it.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        ReturnEntry := CreatePOSEntry(Customer."No.", Today());
        AddItemLine(ReturnEntry, 10000, CreateItem(), -1, -200);
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The customer-not-synced error is raised and no request was sent.
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'has not yet been synchronized with Shopify store') > 0, GetLastErrorText());
        _Assert.AreEqual(0, MockClient.RequestCount(), 'Nothing may reach Shopify');
    end;

    [Test]
    procedure GivenZeroQuantityOnlyEntry_WhenSiblingRuns_ThenNotEligibleResponseUnchanged()
    var
        POSEntry: Record "NPR POS Entry";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A POS entry whose only line has quantity zero still completes unsent with the existing not-eligible response.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An entry with one zero-quantity line.
        POSEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(POSEntry, 10000, CreateItem(), 0, 0);
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, POSEntry);
        Commit();

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        SendPOSEntry.Run(SpfyTask);

        // [THEN] The not-eligible response is written and nothing was sent.
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'is not eligible for synchronization') > 0, ResponseText(TaskEntryNo));
        _Assert.AreEqual(0, MockClient.RequestCount(), 'Nothing may reach Shopify');
    end;
    #endregion

    #region Matching
    local procedure OrderJson(LineItemsJson: Text; RefundsJson: Text): Text
    begin
        exit('{"data":{"order":{"id":"gid://shopify/Order/18943015682268","presentmentCurrencyCode":"' + StoreCurrency() + '","lineItems":{"nodes":[' + LineItemsJson + ']},"refunds":[' + RefundsJson + ']}}}');
    end;

    local procedure StoreCurrency(): Code[3]
    var
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
    begin
        // The same derivation the sender uses for a store without a currency code: the LCY's ISO code.
        exit(SpfyPaymentGatewayHdlr.CurrencyISOCode(''));
    end;

    local procedure LineItemJson(Id: Text; Sku: Text; Title: Text; Refundable: Integer; VariantId: Text; UnitPrice: Text): Text
    var
        VariantPart: Text;
    begin
        if VariantId = '' then
            VariantPart := '"variant":null'
        else
            VariantPart := '"variant":{"id":"gid://shopify/ProductVariant/' + VariantId + '"}';
        exit('{"id":"gid://shopify/LineItem/' + Id + '","sku":"' + Sku + '","title":"' + Title + '","refundableQuantity":' + Format(Refundable) + ',' + VariantPart + ',"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + UnitPrice + '"}}}');
    end;

    local procedure BufRow(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; LineNo: Integer; IsItem: Boolean; ItemNo: Code[20]; VariantCode: Code[10]; Qty: Integer; Title: Text; UnitPrice: Decimal)
    begin
        ReturnLineBuf.Init();
        ReturnLineBuf."POS Entry No." := 1;
        ReturnLineBuf."Line No." := LineNo;
        ReturnLineBuf."Return Case" := ReturnLineBuf."Return Case"::Linked;
        ReturnLineBuf."Target Shopify Order ID" := '18943015682268';
        ReturnLineBuf."Is Item Line" := IsItem;
        ReturnLineBuf."Item No." := ItemNo;
        ReturnLineBuf."Variant Code" := VariantCode;
        ReturnLineBuf.Quantity := Qty;
        ReturnLineBuf."Line Title" := CopyStr(Title, 1, MaxStrLen(ReturnLineBuf."Line Title"));
        ReturnLineBuf."Unit Price" := UnitPrice;
        ReturnLineBuf.Insert();
    end;

    [Test]
    procedure GivenItemLineWithAssignedVariantId_WhenMatched_ThenLineItemIsFoundByVariantId()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] An item return line whose variant has a Shopify id is matched to the line item carrying that variant id, limited to its refundable quantity.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] An order with two line items, the second carrying variant 555 with one refundable unit, and a return of two units.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'OTHER', 'Other', 1, '111', '10.00') + ',' + LineItemJson('2', 'X', 'Item', 1, '555', '200.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 2, 'Item', 200);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] One unit is refunded on line item 2.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(1, TempReturnLineBuf."Refund Quantity", 'Capped by refundable quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/2', 1, '', 0);
    end;

    [Test]
    procedure GivenItemLineWithoutVariantId_WhenMatched_ThenLineItemIsFoundBySku()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
        Sku: Text;
    begin
        // [SCENARIO] An item return line without an assigned variant id is matched by the SKU the sale sync sends.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        Sku := SpfyItemMgt.GetProductVariantSku(ItemNo, '');

        // [GIVEN] An order whose line item carries that SKU and no variant.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('7', Sku, 'Item', 3, '', '50.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 2, 'Item', 50);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] Two units are refunded on line item 7.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(2, TempReturnLineBuf."Refund Quantity", 'Full quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/7', 2, '', 0);
    end;

    [Test]
    procedure GivenNonItemLine_WhenMatched_ThenLineItemIsFoundByTitleAndUnitPrice()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
    begin
        // [SCENARIO] A non-item return line is matched by title, and among equal titles by original unit price.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] Two line items titled Deposit at different prices and a return of the 225.00 one.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('3', '', 'Deposit', 1, '', '100.00') + ',' + LineItemJson('4', '', 'Deposit', 1, '', '225.00'), ''));
        BufRow(TempReturnLineBuf, 10000, false, '6100', '', 1, 'Deposit', 225);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] One unit is refunded on line item 4.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(1, TempReturnLineBuf."Refund Quantity", 'Quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/4', 1, '', 0);
    end;

    [Test]
    procedure GivenSameVariantOnTwoLineItems_WhenMatched_ThenQuantityIsConsumedLineByLine()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] Two return lines of the same variant consume the order's refundable quantity line item by line item, so no unit is refunded twice.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] Two line items of variant 555 with one refundable unit each and two return lines of one unit.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'X', 'Item', 1, '555', '200.00') + ',' + LineItemJson('2', 'X', 'Item', 1, '555', '200.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 1, 'Item', 200);
        BufRow(TempReturnLineBuf, 20000, true, ItemNo, '', 1, 'Item', 200);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] Each row refunds one unit, one on each line item.
        TempReturnLineBuf.Get(1, 10000);
        _Assert.AreEqual(1, TempReturnLineBuf."Refund Quantity", 'First row');
        TempReturnLineBuf.Get(1, 20000);
        _Assert.AreEqual(1, TempReturnLineBuf."Refund Quantity", 'Second row');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/1', 1, 'gid://shopify/LineItem/2', 1);
    end;

    [Test]
    procedure GivenSameVariantOnTwoLineItems_WhenTheLargerLineIsReturned_ThenTheLineItemCoveringItWholeIsTaken()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line is refunded in full on the line item that covers its whole quantity, even when an earlier line item of the same variant has fewer units left.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] Line item 1 of variant 555 with one refundable unit, line item 2 of the same variant with two, and a return of two units.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'X', 'Item', 1, '555', '200.00') + ',' + LineItemJson('2', 'X', 'Item', 2, '555', '200.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 2, 'Item', 200);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] Both units are refunded on line item 2.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(2, TempReturnLineBuf."Refund Quantity", 'Full quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/2', 2, '', 0);
    end;

    [Test]
    procedure GivenNoSingleLineItemCoversTheReturn_WhenMatched_ThenTheQuantityIsTakenFromEveryMatchingLineItem()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] When no single line item has the whole returned quantity left, the return takes what is left on every line item of the same variant.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] Two line items of variant 555 with one refundable unit each and a return of two units.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'X', 'Item', 1, '555', '200.00') + ',' + LineItemJson('2', 'X', 'Item', 1, '555', '200.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 2, 'Item', 200);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] Both units are refunded, one on each line item.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(2, TempReturnLineBuf."Refund Quantity", 'Full quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/1', 1, 'gid://shopify/LineItem/2', 1);
    end;

    [Test]
    procedure GivenNonItemLineSentAsTwoLineItems_WhenTheWholeLineIsReturned_ThenBothLineItemsAreRefunded()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
    begin
        // [SCENARIO] A discounted non-item line the sale sent as two line items one cent apart is matched on those prices, not on the original unit price, and a return of the whole line takes both.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] Line items Deposit 2 x 45.33 and Deposit 1 x 45.34, and a return of 3 units of an original priced 60 before discount.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('3', '', 'Deposit', 2, '', '45.33') + ',' + LineItemJson('4', '', 'Deposit', 1, '', '45.34'), ''));
        BufRow(TempReturnLineBuf, 10000, false, '6100', '', 3, 'Deposit', 60);
        TempReturnLineBuf."Line Item Price" := 45.33;
        TempReturnLineBuf."Line Item Price 2" := 45.34;
        TempReturnLineBuf.Modify();

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] All 3 units are refunded, 2 on line item 3 and 1 on line item 4.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(3, TempReturnLineBuf."Refund Quantity", 'Full quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/3', 2, 'gid://shopify/LineItem/4', 1);
    end;

    [Test]
    procedure GivenItemLineSentAsTwoLineItems_WhenOneUnitIsReturned_ThenItIsRefundedOnOneLineItem()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return of one unit of an item line the sale sent as two line items of the same variant is refunded on one of them.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] Line items of variant 555 at 2 x 45.33 and 1 x 45.34, and a return of 1 unit.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'X', 'Item', 2, '555', '45.33') + ',' + LineItemJson('2', 'X', 'Item', 1, '555', '45.34'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 1, 'Item', 60);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] One unit is refunded on line item 1.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(1, TempReturnLineBuf."Refund Quantity", 'Quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/1', 1, '', 0);
    end;

    [Test]
    procedure GivenItemLineSentAsTwoLineItems_WhenTheWholeLineIsReturned_ThenBothLineItemsAreRefunded()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return of all units of an item line the sale sent as two line items of the same variant takes both line items.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] Line items of variant 555 at 2 x 45.33 and 1 x 45.34, and a return of 3 units.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'X', 'Item', 2, '555', '45.33') + ',' + LineItemJson('2', 'X', 'Item', 1, '555', '45.34'), ''));
        BufRow(TempReturnLineBuf, 10000, true, ItemNo, '', 3, 'Item', 60);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] All 3 units are refunded, 2 on line item 1 and 1 on line item 2.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(3, TempReturnLineBuf."Refund Quantity", 'Full quantity');
        AssertLineItemQuantities(LineItemQuantities, 'gid://shopify/LineItem/1', 2, 'gid://shopify/LineItem/2', 1);
    end;

    local procedure AssertLineItemQuantities(LineItemQuantities: Dictionary of [Text, Integer]; LineItemID1: Text; Quantity1: Integer; LineItemID2: Text; Quantity2: Integer)
    var
        ExpectedCount: Integer;
    begin
        ExpectedCount := 1;
        _Assert.IsTrue(LineItemQuantities.ContainsKey(LineItemID1), LineItemID1);
        _Assert.AreEqual(Quantity1, LineItemQuantities.Get(LineItemID1), LineItemID1);
        if LineItemID2 <> '' then begin
            ExpectedCount := 2;
            _Assert.IsTrue(LineItemQuantities.ContainsKey(LineItemID2), LineItemID2);
            _Assert.AreEqual(Quantity2, LineItemQuantities.Get(LineItemID2), LineItemID2);
        end;
        _Assert.AreEqual(ExpectedCount, LineItemQuantities.Count(), 'Line items refunded');
    end;

    [Test]
    procedure GivenNoMatchingLineItem_WhenMatched_ThenRefundQuantityStaysZero()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        LineItemQuantities: Dictionary of [Text, Integer];
        StoreCode: Code[20];
    begin
        // [SCENARIO] A return line with no matching line item keeps a zero refund quantity and refunds no line item.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An order whose only line item is unrelated.
        OrderResponse.ReadFrom(OrderJson(LineItemJson('1', 'OTHER', 'Other', 1, '111', '10.00'), ''));
        BufRow(TempReturnLineBuf, 10000, true, CreateItem(), '', 1, 'Item', 200);

        // [WHEN] The buffer is matched.
        SpfyPOSRefundRequest.MatchLineItems(OrderResponse, TempReturnLineBuf, StoreCode, LineItemQuantities);

        // [THEN] Nothing was matched.
        TempReturnLineBuf.FindFirst();
        _Assert.AreEqual(0, TempReturnLineBuf."Refund Quantity", 'No quantity');
        _Assert.AreEqual(0, LineItemQuantities.Count(), 'No line item');
    end;

    [Test]
    procedure GivenRefundNotesWithReasons_WhenMarkerSearched_ThenOnlyTheMarkerFollowedByAColonMatches()
    var
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        FoundRefundId: Text;
        FoundAmount: Decimal;
    begin
        // [SCENARIO] A refund whose note is the marker followed by a colon and any reasons is found; a note whose marker only starts with the same characters is not.
        Initialize();

        // [GIVEN] An order with an unrelated refund, a refund of another entry whose marker extends this one, and this entry's refund with a reason.
        OrderResponse.ReadFrom(OrderJson('', '{"id":"gid://shopify/Refund/1","note":"something else"},{"id":"gid://shopify/Refund/3","note":"POS Return 13/T10: Damaged"},{"id":"gid://shopify/Refund/2","note":"POS Return 13/T1: Wrong size"}'));

        // [WHEN] The marker of POS entry 13, document T1, is searched.
        FoundRefundId := SpfyPOSRefundRequest.FindRefundByNote(OrderResponse, 'POS Return 13/T1', FoundAmount);

        // [THEN] Refund 2 is returned, not refund 3.
        _Assert.AreEqual('2', FoundRefundId, 'Marker with reasons found');
    end;

    [Test]
    procedure GivenRefundNoteWithoutReasons_WhenMarkerSearched_ThenOnlyTheExactNoteMatches()
    var
        SpfyPOSRefundRequest: Codeunit "NPR Spfy POS Refund Request";
        OrderResponse: JsonToken;
        FoundRefundId: Text;
        FoundAmount: Decimal;
    begin
        // [SCENARIO] A refund whose note is exactly the marker is found; a note that continues the marker without a colon is not.
        Initialize();

        // [GIVEN] An order with a refund whose note continues the marker and one whose note is the marker alone.
        OrderResponse.ReadFrom(OrderJson('', '{"id":"gid://shopify/Refund/5","note":"POS Return 14/T2 extra"},{"id":"gid://shopify/Refund/4","note":"POS Return 14/T2"}'));

        // [WHEN] The marker of POS entry 14, document T2, is searched.
        FoundRefundId := SpfyPOSRefundRequest.FindRefundByNote(OrderResponse, 'POS Return 14/T2', FoundAmount);

        // [THEN] Refund 4 is returned.
        _Assert.AreEqual('4', FoundRefundId, 'Exact marker found');
    end;

    [Test]
    procedure GivenRefundedLinesWithReturnReasons_WhenRefundNoteIsBuilt_ThenItListsTheDistinctReasonsInLineOrder()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        DamagedCode: Code[10];
        WrongSizeCode: Code[10];
        NoDescriptionCode: Code[10];
        NotRefundedCode: Code[10];
        Note: Text;
    begin
        // [SCENARIO] The refund note is the marker followed by the distinct return reasons of the refunded lines in line order, using the reason's description or its code when the description is blank; lines without a reason or without a refund quantity add nothing.
        Initialize();

        // [GIVEN] Return reasons with and without a description.
        DamagedCode := CreateReturnReason('Damaged');
        WrongSizeCode := CreateReturnReason('Wrong size');
        NoDescriptionCode := CreateReturnReason('');
        NotRefundedCode := CreateReturnReason('Not refunded');

        // [GIVEN] Refunded lines with Damaged, Wrong size, Damaged again, a reason without description and no reason, and an unrefunded line with its own reason.
        AddReasonRow(TempReturnLineBuf, 10000, DamagedCode, 1);
        AddReasonRow(TempReturnLineBuf, 20000, WrongSizeCode, 1);
        AddReasonRow(TempReturnLineBuf, 30000, DamagedCode, 2);
        AddReasonRow(TempReturnLineBuf, 40000, NoDescriptionCode, 1);
        AddReasonRow(TempReturnLineBuf, 50000, '', 1);
        AddReasonRow(TempReturnLineBuf, 60000, NotRefundedCode, 0);

        // [WHEN] The refund note is built for marker 'POS Return 13/T1'.
        Note := _ReturnResolver.RefundNote('POS Return 13/T1', TempReturnLineBuf, '');

        // [THEN] It lists Damaged, Wrong size and the bare code once each, in line order.
        _Assert.AreEqual('POS Return 13/T1: Damaged, Wrong size, ' + NoDescriptionCode, Note, 'Refund note');
    end;

    [Test]
    procedure GivenRefundedLinesWithoutReturnReasons_WhenRefundNoteIsBuilt_ThenItIsTheMarkerAlone()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        Note: Text;
    begin
        // [SCENARIO] A refund whose lines carry no return reason gets the marker alone as its note, with no trailing colon.
        Initialize();

        // [GIVEN] Two refunded lines without a return reason.
        AddReasonRow(TempReturnLineBuf, 10000, '', 1);
        AddReasonRow(TempReturnLineBuf, 20000, '', 1);

        // [WHEN] The refund note is built for marker 'POS Return 13/T1'.
        Note := _ReturnResolver.RefundNote('POS Return 13/T1', TempReturnLineBuf, '');

        // [THEN] The note is the marker.
        _Assert.AreEqual('POS Return 13/T1', Note, 'Refund note');
    end;

    [Test]
    procedure GivenReasonsAndAPaymentMethod_WhenRefundNoteIsBuilt_ThenThePaymentMethodFollowsTheReasons()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        Note: Text;
    begin
        // [SCENARIO] Shopify records every refund on the original sale's gateway, so the note says how the money went back, after the return reasons.
        Initialize();

        // [GIVEN] A refunded line with the return reason Damaged.
        AddReasonRow(TempReturnLineBuf, 10000, CreateReturnReason('Damaged'), 1);

        // [WHEN] The refund note is built for marker 'POS Return 13/T1', paid back as Voucher.
        Note := _ReturnResolver.RefundNote('POS Return 13/T1', TempReturnLineBuf, 'Voucher');

        // [THEN] The payment method follows the reason.
        _Assert.AreEqual('POS Return 13/T1: Damaged; paid back as Voucher', Note, 'Refund note');
    end;

    [Test]
    procedure GivenNoReasonsAndTwoPaymentMethods_WhenRefundNoteIsBuilt_ThenThePaymentMethodsFollowTheMarker()
    var
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        Note: Text;
    begin
        // [SCENARIO] Without return reasons the payment methods follow the marker and a colon, so a retry still finds the refund by its marker.
        Initialize();

        // [GIVEN] A refunded line without a return reason.
        AddReasonRow(TempReturnLineBuf, 10000, '', 1);

        // [WHEN] The refund note is built for marker 'POS Return 13/T1', paid back as Cash and Voucher.
        Note := _ReturnResolver.RefundNote('POS Return 13/T1', TempReturnLineBuf, 'Cash, Voucher');

        // [THEN] The payment methods follow the marker.
        _Assert.AreEqual('POS Return 13/T1: paid back as Cash, Voucher', Note, 'Refund note');
    end;

    [Test]
    procedure GivenPaymentLinesInAndOut_WhenPaidBackAsIsRead_ThenItNamesTheMethodsThatHandedMoneyBackOnBalance()
    var
        POSEntry: Record "NPR POS Entry";
        PaidBackAs: Text;
    begin
        // [SCENARIO] A method hands money back when its lines net below zero, so change on an over-tender does not count; each such method is named once, in line order, by the payment method's description or its code, never by the line's own description, which can carry a voucher or card number.
        Initialize();

        // [GIVEN] Payment methods ZZCASH and ZZCV with descriptions, ZZCARD without one.
        CreatePaymentMethod('ZZCASH', 'Cash');
        CreatePaymentMethod('ZZCV', 'Credit voucher');
        CreatePaymentMethod('ZZCARD', '');

        // [GIVEN] An entry with 100 tendered in cash and 30 change, two credit voucher lines handed out carrying the voucher number, and a card line handed out carrying card digits.
        POSEntry := CreatePOSEntry('', Today());
        AddPaymentLine(POSEntry, 10000, 'ZZCASH', 100);
        AddPaymentLine(POSEntry, 20000, 'ZZCASH', -30);
        AddPaymentLine(POSEntry, 30000, 'ZZCV', -150);
        AddPaymentLine(POSEntry, 40000, 'ZZCARD', -40);
        AddPaymentLine(POSEntry, 50000, 'ZZCV', -10);
        SetPaymentLineDescription(POSEntry."Entry No.", 20000, 'Change');
        SetPaymentLineDescription(POSEntry."Entry No.", 30000, '2807000105357 Credit Voucher');
        SetPaymentLineDescription(POSEntry."Entry No.", 40000, 'Visa: 12345678');

        // [WHEN] The methods the money went back with are read.
        PaidBackAs := _ReturnResolver.PaidBackAs(POSEntry);

        // [THEN] They are the credit voucher and the card, named by their payment methods, and cash is left out because it nets to 70 paid in.
        _Assert.AreEqual('Credit voucher, ZZCARD', PaidBackAs, 'Paid back as');
    end;

    local procedure AddReasonRow(var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; LineNo: Integer; ReasonCode: Code[10]; RefundQty: Integer)
    begin
        BufRow(ReturnLineBuf, LineNo, true, 'ITEM', '', 2, 'Item', 100);
        ReturnLineBuf."Return Reason Code" := ReasonCode;
        ReturnLineBuf."Refund Quantity" := RefundQty;
        ReturnLineBuf.Modify();
    end;
    #endregion

    #region Refund step
    local procedure SuggestJson(Amount: Text; MaxRefundable: Text): Text
    begin
        exit('{"data":{"order":{"suggestedRefund":{"amountSet":{"presentmentMoney":{"amount":"' + Amount + '"}},"suggestedTransactions":[{"gateway":"NPRetail.POS.CASH","amountSet":{"presentmentMoney":{"amount":"' + Amount + '"}},"maximumRefundableSet":{"presentmentMoney":{"amount":"' + MaxRefundable + '"}},"parentTransaction":{"id":"gid://shopify/OrderTransaction/20818714263772"}}]}}}}');
    end;

    local procedure RefundCreatedJson(RefundId: Text; Amount: Text): Text
    begin
        exit('{"data":{"refundCreate":{"userErrors":[],"refund":{"id":"gid://shopify/Refund/' + RefundId + '","totalRefundedSet":{"presentmentMoney":{"amount":"' + Amount + '"}}}}}}');
    end;

    local procedure RefundRefusedJson(Message: Text): Text
    begin
        exit('{"data":{"refundCreate":{"userErrors":[{"field":null,"message":"' + Message + '"}],"refund":null}}}');
    end;

    local procedure SetApiVersion(Version: Text[10])
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifySetup.Get();
        ShopifySetup."Shopify Api Version" := Version;
        ShopifySetup.Modify(false);
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    // A sent original with one item line of variant 555 and a return of one unit, both for the same synced customer; returns the return entry and its task.
    local procedure CreateLinkedReturn(StoreCode: Code[20]; var ReturnEntry: Record "NPR POS Entry"; var ItemNo: Code[20]) TaskEntryNo: BigInteger
    begin
        exit(CreateLinkedReturn(StoreCode, -200, ReturnEntry, ItemNo));
    end;

    local procedure CreateLinkedReturn(StoreCode: Code[20]; ReturnAmountInclVAT: Decimal; var ReturnEntry: Record "NPR POS Entry"; var ItemNo: Code[20]) TaskEntryNo: BigInteger
    var
        OriginalEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        CustomerNo: Code[20];
    begin
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 2, 400);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, ReturnAmountInclVAT);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();
    end;

    local procedure MockOrder(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; Refundable: Integer)
    begin
        MockClient.AddResponse('PosReturnOrder', OrderJson(LineItemJson('2', 'X', 'Item', Refundable, '555', '200.00'), ''));
    end;

    local procedure RunSibling(TaskEntryNo: BigInteger; var MockClient: Codeunit "NPR Spfy Mock GraphQL Client")
    var
        SpfyTask: Record "NPR Spfy Task";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
    begin
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        SendPOSEntry.Run(SpfyTask);
    end;

    [Test]
    procedure GivenLinkedReturnLine_WhenSiblingRuns_ThenRefundCreateCarriesLineItemQuantityNoRestockAndPosAmount()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A linked return line produces one refundCreate on the original order with the matched line item, the returned quantity, no restock and a REFUND transaction for the POS amount, and the refund is recorded.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A sent original, a linked return of one unit, and Shopify answers for the order, the suggestion and the refund.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1112858460380', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The refund request carries line item 2, quantity 1, NO_RESTOCK, the note marker and a 200.00 REFUND transaction on the parent, and the refund is recorded.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"lineItemId":"gid://shopify/LineItem/2"'), Request);
        _Assert.IsTrue(Request.Contains('"quantity":1'), Request);
        _Assert.IsTrue(Request.Contains('"restockType":"NO_RESTOCK"'), Request);
        _Assert.IsTrue(Request.Contains('"note":"' + ExpectedNoteMarker(ReturnEntry) + '"'), Request);
        _Assert.IsTrue(Request.Contains('"kind":"REFUND"'), Request);
        _Assert.IsTrue(Request.Contains('"parentId":"gid://shopify/OrderTransaction/20818714263772"'), Request);
        _Assert.IsTrue(Request.Contains('"amount":"200.00"'), Request);
        _Assert.IsTrue(Request.Contains('"gateway":"NPRetail.POS.CASH"'), Request);
        _Assert.IsFalse(Request.Contains('@idempotent'), 'No directive below 2026-04');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('orderCreate('), 'No order for a return-only entry');
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refund row');
        _Assert.AreEqual('1112858460380', SpfyPOSEntryRefund."Shopify Refund ID", 'Refund id');
        _Assert.AreEqual(200, SpfyPOSEntryRefund."Refunded Amount", 'Refunded amount');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Refund 1112858460380 created on order 18943015682268') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenLineItemWithRealShopifyId_WhenSiblingRuns_ThenRefundCreateCarriesTheWholeId()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A Shopify line item id of 14 digits, as real orders carry, is sent back whole in both the suggestion and the refund; it is never cut to fit a field.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return whose Shopify order line item has a 14-digit id, and answers for the suggestion and the refund.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockClient.AddResponse('PosReturnOrder', OrderJson(LineItemJson('13623541432483', 'X', 'Item', 2, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Both requests name the whole line item id.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"lineItemId":"gid://shopify/LineItem/13623541432483"'), Request);
        Request := MockClient.GetRequestContaining('PosReturnSuggest');
        _Assert.IsTrue(Request.Contains('"lineItemId":"gid://shopify/LineItem/13623541432483"'), Request);
    end;

    [Test]
    procedure GivenApiVersion202604_WhenRefundIsSent_ThenMutationCarriesIdempotentKey()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] On API version 2026-04 or later the refund mutation carries the @idempotent directive with a key variable.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-04');

        // [GIVEN] A linked return and the Shopify answers.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The mutation carries the directive and a key, and is not resent on a server error.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('@idempotent(key: $key)'), Request);
        _Assert.IsTrue(Request.Contains('"key":"'), Request);
        _Assert.IsFalse(MockClient.ResendOnServerErrorFor('refundCreate('), 'Refund must not be resent on a server error');
    end;

    [Test]
    procedure GivenRefundableQuantityBelowReturnedQuantity_WhenSiblingRuns_ThenRefundIsCappedAndRemainderReported()
    var
        ReturnEntry: Record "NPR POS Entry";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A return of two units against a line item with one refundable unit refunds one unit and reports the remainder as not sent.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return raised to two units and a Shopify order with one refundable unit.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        ReturnLine.Get(ReturnEntry."Entry No.", 10000);
        ReturnLine.Quantity := -2;
        ReturnLine."Amount Incl. VAT" := -400;
        ReturnLine.Modify(false);
        Commit();
        MockOrder(MockClient, 1);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] One unit is refunded for 200.00 and the response says one unit of two was refunded.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"quantity":1'), Request);
        _Assert.IsTrue(Request.Contains('"amount":"200.00"'), Request);
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'quantity 1 of 2') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenPosAmountAboveMaximumRefundable_WhenSiblingRuns_ThenTransactionIsCappedAndShortfallReported()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] When the POS amount exceeds what the order's transactions can still refund, the transaction is capped at that maximum and the shortfall is reported.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return of 200.00 and a Shopify order with only 150.00 left to refund.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '150.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '150.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The transaction is 150.00 and the response names the 50.00 shortfall.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"amount":"150.00"'), Request);
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'short by 50') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenRefundAlreadyRecorded_WhenSiblingRunsAgain_ThenNoSecondRefundCreateIsSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A group whose refund is already recorded in BC is skipped: no order query, no refund, and the task completes.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return whose refund row already exists.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        SpfyPOSEntryRefund.Store(StoreCode, ReturnEntry."Entry No.", '18943015682268', '999', 200, StoreCurrency());
        Commit();

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing reached Shopify and the response names the recorded refund.
        _Assert.AreEqual(0, MockClient.RequestCount(), 'No request for a recorded refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Refund 999 already recorded for order 18943015682268') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenLinkedReturnLineWithReturnReason_WhenSiblingRuns_ThenRefundNoteNamesTheReason()
    var
        ReturnEntry: Record "NPR POS Entry";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] The return reason of a POS return line reaches Shopify as the refund note, after the entry's marker.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A sent original and a linked return of one unit whose line carries the return reason Damaged.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        ReturnLine.Get(ReturnEntry."Entry No.", 10000);
        ReturnLine."Return Reason Code" := CreateReturnReason('Damaged');
        ReturnLine.Modify(false);
        Commit();

        // [GIVEN] Shopify answers for the order, the suggestion and the refund.
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1112858460380', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The refund note is the marker followed by the reason.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"note":"' + ExpectedNoteMarker(ReturnEntry) + ': Damaged"'), Request);
    end;

    [Test]
    procedure GivenReturnPaidBackWithACreditVoucher_WhenSiblingRuns_ThenRefundNoteNamesTheVoucher()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A return paid back with a credit voucher is refunded on the original sale's gateway, and the refund note says it was paid back as a voucher.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return of one unit paid back with a credit voucher line of -200 whose description carries the voucher number, and Shopify answers for the order, the suggestion and the refund.
        CreatePaymentMethod('ZZCV', 'Credit voucher');
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        AddPaymentLine(ReturnEntry, 10000, 'ZZCV', -200);
        SetPaymentLineDescription(ReturnEntry."Entry No.", 10000, '2807000105357 Credit Voucher');
        Commit();
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The refund note names the voucher's payment method after the marker, the voucher number is not sent, and the transaction stays on the sale's gateway.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"note":"' + ExpectedNoteMarker(ReturnEntry) + ': paid back as Credit voucher"'), Request);
        _Assert.IsFalse(Request.Contains('2807000105357'), Request);
        _Assert.IsTrue(Request.Contains('"gateway":"NPRetail.POS.CASH"'), Request);
    end;

    [Test]
    procedure GivenRefundWithGroupNoteAlreadyOnOrder_WhenSiblingRuns_ThenItIsAdoptedAndNoRefundCreateIsSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A refund that already exists on the Shopify order with this entry's note marker is adopted, whatever reasons follow the marker: its id is recorded and no refundCreate is sent.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and a Shopify order already carrying a refund with the marker and a reason text that no longer matches any reason in BC.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockClient.AddResponse('PosReturnOrder', OrderJson(LineItemJson('2', 'X', 'Item', 1, '555', '200.00'), '{"id":"gid://shopify/Refund/4242","note":"' + ExpectedNoteMarker(ReturnEntry) + ': A reason renamed since","totalRefundedSet":{"presentmentMoney":{"amount":"200.00"}}}'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Only the order query went out, the refund is recorded with id 4242 and its amount, and the response says adopted.
        _Assert.AreEqual(1, MockClient.RequestCount(), 'Only the order query');
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refund row');
        _Assert.AreEqual('4242', SpfyPOSEntryRefund."Shopify Refund ID", 'Adopted id');
        _Assert.AreEqual(200, SpfyPOSEntryRefund."Refunded Amount", 'Adopted amount read from Shopify');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Adopted refund 4242 on order 18943015682268') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenOrderMissingInShopify_WhenSiblingRuns_ThenTaskErrorsNamingTheOrderAndNothingRecorded()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When Shopify answers the order query with no order (deleted, or not readable by the app), the task fails naming the order instead of completing with a wrong reason.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return whose Shopify order no longer exists.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockClient.AddResponse('PosReturnOrder', '{"data":{"order":null}}');

        // [WHEN] The POS entry sibling runs.
        asserterror RunSibling(TaskEntryNo, MockClient);

        // [THEN] The error names the order, nothing else was requested and no refund is recorded.
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Shopify order 18943015682268 was not found') > 0, GetLastErrorText());
        _Assert.AreEqual(1, MockClient.RequestCount(), 'Only the order query');
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'No refund row');
    end;

    [Test]
    procedure GivenTwoLinesCoveredByARecordedRefund_WhenSiblingRunsAgain_ThenEachLineIsReportedAsCovered()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] On a rerun after the refund was recorded, each line is reported as not sent again because the entry already has a refund on that order; the group total is not shown as if it were each line's amount.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A sent sale of two lines of 100, a return of both lines, and a refund of 200 already recorded for the group.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 100);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -100);
        LinkReturnLine(ReturnLine, OriginalLine);
        OriginalLine := AddItemLine(OriginalEntry, 20000, ItemNo, 1, 100);
        ReturnLine := AddItemLine(ReturnEntry, 20000, ItemNo, -1, -100);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        SpfyPOSEntryRefund.Store(StoreCode, ReturnEntry."Entry No.", '18943015682268', '999', 200, StoreCurrency());
        Commit();

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing reached Shopify, both lines read as not sent again because of the refund on that order, and no line claims the 200 as its own amount.
        _Assert.AreEqual(0, MockClient.RequestCount(), 'No request for a recorded refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 10000: not sent again, the entry already has a refund on Shopify order 18943015682268') > 0, ResponseText(TaskEntryNo));
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 20000: not sent again, the entry already has a refund on Shopify order 18943015682268') > 0, ResponseText(TaskEntryNo));
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), 'amount 200'), ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenSaleWithAPayInLine_WhenSiblingRuns_ThenItIsSentAsAPlainSale()
    var
        SaleEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A pay-in line (type Payout, quantity -1) on a customer sale is not a return line: the sale keeps its payment-line transactions and nothing is reported as not linked.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A sale of 200 with a pay-in line of 20 on quantity -1, paid 220 in cash.
        SaleEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(SaleEntry, 10000, ItemNo, 1, 200);
        AddLine(SaleEntry, 20000, POSEntrySalesLine.Type::Payout, '6100', '', -1, 20, 'Pay-in');
        AddPaymentLine(SaleEntry, 10000, 'CASH', 220);
        SaleEntry.Get(SaleEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, SaleEntry);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/781"}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order is paid by the cash line and the response says nothing about unlinked lines.
        AssertSingleTransaction(MockClient.GetRequestContaining('orderCreate('), 'SALE', 'NPRetail.POS.CASH', 220);
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), 'not linked'), ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenSaleWithAPayInOrPayOutToAGLAccount_WhenSiblingRuns_ThenItIsSentAsAPlainSale()
    var
        SaleEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A pay-in or pay-out to an account whose posting type is not Purchase is posted as a G/L Account line; on quantity -1 without an origin it is not a return line, so the sale keeps its payment-line transactions.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A sale of 200 with a G/L Account pay-in or pay-out line of 20 on quantity -1, paid 220 in cash.
        SaleEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(SaleEntry, 10000, ItemNo, 1, 200);
        AddLine(SaleEntry, 20000, POSEntrySalesLine.Type::"G/L Account", '6100', '', -1, 20, 'Pay-out');
        AddPaymentLine(SaleEntry, 10000, 'CASH', 220);
        SaleEntry.Get(SaleEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, SaleEntry);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/782"}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order is paid by the cash line and the response says nothing about unlinked lines.
        AssertSingleTransaction(MockClient.GetRequestContaining('orderCreate('), 'SALE', 'NPRetail.POS.CASH', 220);
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), 'not linked'), ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenReversedGLAccountLine_WhenResolved_ThenItIsALinkedReturnLine()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
    begin
        // [SCENARIO] A G/L Account line on quantity -1 that carries the origin of a sold line is a reversal, not a pay-out, so it stays a return line.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent sale with a G/L Account line of 20, and a return of that line linked to it.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 1, 20, 'Service fee');
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -1, -20, 'Service fee');
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The line is a Linked return line.
        _Assert.AreEqual(1, TempReturnLineBuf.Count(), 'One return line');
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Linked, StrSubstNo('Expected Linked, found %1', TempReturnLineBuf."Return Case"));
    end;

    [Test]
    procedure GivenReturnOfADiscountedNonItemLine_WhenSiblingRuns_ThenRefundCreateCarriesBothLineItemsTheSaleSent()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A return of a discounted non-item line is refunded on the two line items the sale sent for it, for the amount the POS paid back.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');
        CustomerNo := CreateSyncedCustomer(StoreCode);

        // [GIVEN] A sent original with prices excluding VAT and a G/L account line of 3 units at 60 discounted to 136 excl. VAT (170 incl.), which the sale sends as 2 x 45.33 and 1 x 45.34.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", '6100', '', 3, 170, 'Deposit');
        OriginalLine."Amount Excl. VAT" := 136;
        OriginalLine."Unit Price" := 60;
        OriginalLine.Modify(false);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');

        // [GIVEN] A linked return of the whole line, and Shopify answers for the order, the suggestion and the refund.
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::"G/L Account", '6100', '', -3, -170, 'Deposit');
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();
        MockClient.AddResponse('PosReturnOrder', OrderJson(LineItemJson('3', '', 'Deposit', 2, '', '45.33') + ',' + LineItemJson('4', '', 'Deposit', 1, '', '45.34'), ''));
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('170.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '170.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] One refund is sent with 2 units on line item 3, 1 unit on line item 4, and the 170 the POS paid back.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('refundCreate('), 'One refund');
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"lineItemId":"gid://shopify/LineItem/3","quantity":2'), Request);
        _Assert.IsTrue(Request.Contains('"lineItemId":"gid://shopify/LineItem/4","quantity":1'), Request);
        _Assert.IsTrue(Request.Contains('"amount":"170.00"'), Request);
    end;

    [Test]
    procedure GivenShopifyRefusesTheRefund_WhenSiblingRuns_ThenTaskErrorsWithUserErrorAndNothingRecorded()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A refund Shopify refuses with a user error makes the task fail with that text in the response, so it retries, and nothing is recorded.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and a refusal from Shopify.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundRefusedJson('Refund amount is greater than net payment received'));

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The error names the refusal, the response reports the line as not sent with Shopify's message as plain text, and no refund row exists.
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Shopify refused the refund') > 0, GetLastErrorText());
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 10000: not sent. Shopify refused the refund on order 18943015682268: Refund amount is greater than net payment received') > 0, ResponseText(TaskEntryNo));
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), 'Line 10000: refund on Shopify order'), ResponseText(TaskEntryNo));
        _Assert.AreEqual(0, StrPos(ResponseText(TaskEntryNo), '"message"'), ResponseText(TaskEntryNo));
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'No refund row');
    end;

    [Test]
    procedure GivenExchangeWithLinkedReturnLine_WhenSiblingRuns_ThenOrderCreateThenRefundCreateAndBothIdsRecorded()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        OrderRequest: Text;
    begin
        // [SCENARIO] An exchange sends an orderCreate for its positive line, paid by one SALE transaction for the line's full value since the refunded return funds it, then a refundCreate on the original order, and both ids are recorded.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return entry with an added positive line, and Shopify answers for the order creation, the order query, the suggestion and the refund.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        AddItemLine(ReturnEntry, 20000, ItemNo, 1, 200);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/777"}}}}');
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order was created first with the positive line only, then the refund, both ids are stored, and the response names the new order and the refund.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('orderCreate('), 'One order');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('refundCreate('), 'One refund');
        _Assert.IsTrue(MockClient.IndexOfRequestContaining('orderCreate(') < MockClient.IndexOfRequestContaining('refundCreate('), 'The order is created before the refund');
        OrderRequest := MockClient.GetRequestContaining('orderCreate(');
        _Assert.IsTrue(StrPos(OrderRequest, '"quantity":1') > 0, 'The positive line is in the order: ' + OrderRequest);
        _Assert.AreEqual(0, StrPos(OrderRequest, '"quantity":-1'), 'The return line is not in the order: ' + OrderRequest);
        AssertSingleTransaction(OrderRequest, 'SALE', 'NPRetail.POS.EXCHANGE', 200);
        _Assert.AreEqual('777', SpfyAssignedIDMgt.GetAssignedShopifyID(LinkRecordId(ReturnEntry."Entry No.", StoreCode), "NPR Spfy ID Type"::"Entry ID"), 'Order id');
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refund row');
        _Assert.AreEqual(1, StrPos(ResponseText(TaskEntryNo), 'Shopify order 777 holds'), ResponseText(TaskEntryNo));
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Refund 1 created on order 18943015682268') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenExchangeWithLinkedAndUnlinkedReturnLines_WhenSiblingRuns_ThenOrderSaleIsPositiveLinesLessTheUnlinkedReturns()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Only the returns refunded on their original order fund the new order: its SALE transaction is the positive lines' value less the returns that are not sent.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] An exchange with a linked return of 200, an unlinked manual return of 50, a positive line of 300 and 50 paid in cash; Shopify answers every call.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        AddItemLine(ReturnEntry, 20000, ItemNo, -1, -50);
        AddItemLine(ReturnEntry, 30000, ItemNo, 1, 300);
        AddPaymentLine(ReturnEntry, 10000, 'CASH', 50);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/778"}}}}');
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The new order is paid by one SALE of 250 (300 less the unlinked 50), and the linked return is refunded.
        AssertSingleTransaction(MockClient.GetRequestContaining('orderCreate('), 'SALE', 'NPRetail.POS.EXCHANGE', 250);
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('refundCreate('), 'One refund');
    end;

    [Test]
    procedure GivenExchangeWhoseReturnsAreAllUnlinkedAndCashWentOut_WhenSiblingRuns_ThenOrderCarriesNoTransactions()
    var
        ExchangeEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        Transactions: JsonArray;
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An exchange whose returns are not sent and whose net total is negative creates its order without any transaction, never with a refund transaction on a new order.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A positive line of 60, an unlinked manual return of 100 and 40 paid out in cash.
        ExchangeEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(ExchangeEntry, 10000, ItemNo, 1, 60);
        AddItemLine(ExchangeEntry, 20000, ItemNo, -1, -100);
        AddPaymentLine(ExchangeEntry, 10000, 'CASH', -40);
        ExchangeEntry.Get(ExchangeEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ExchangeEntry);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/779"}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] One order was created without transactions and nothing was refunded.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('orderCreate('), 'One order');
        _Assert.IsFalse(OrderTransactions(MockClient.GetRequestContaining('orderCreate('), Transactions), 'No transactions on the order: ' + MockClient.GetRequestContaining('orderCreate('));
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
    end;

    [Test]
    procedure GivenSaleWithAnUnlinkedReturnPaidByCard_WhenSiblingRuns_ThenOrderTransactionsComeFromThePaymentLines()
    var
        SaleEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A sale whose return lines are not refunded on any original order, and where no money went back to the customer, is paid by its payment lines as before, not by an exchange SALE.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A positive line of 150, an unlinked manual return of 50 and 100 paid by card.
        SaleEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(SaleEntry, 10000, ItemNo, 1, 150);
        AddItemLine(SaleEntry, 20000, ItemNo, -1, -50);
        AddPaymentLine(SaleEntry, 10000, 'CARD', 100);
        SaleEntry.Get(SaleEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, SaleEntry);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/781"}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order carries one SALE of 100 by card and nothing is refunded.
        AssertSingleTransaction(MockClient.GetRequestContaining('orderCreate('), 'SALE', 'NPRetail.POS.CARD', 100);
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
    end;

    [Test]
    procedure GivenSaleWithoutReturnLines_WhenSiblingRuns_ThenOrderTransactionsComeFromThePaymentLines()
    var
        SaleEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A sale without return lines is sent as before: its transactions are the payment lines summed per payment method.
        Initialize();
        StoreCode := CreateStore();
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] A sale of 200 paid with two cash lines of 120 and 30 and a card line of 50.
        SaleEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        AddItemLine(SaleEntry, 10000, ItemNo, 1, 200);
        AddPaymentLine(SaleEntry, 10000, 'CASH', 120);
        AddPaymentLine(SaleEntry, 20000, 'CARD', 50);
        AddPaymentLine(SaleEntry, 30000, 'CASH', 30);
        SaleEntry.Get(SaleEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, SaleEntry);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/780"}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order carries one SALE per method: 150 by cash and 50 by card.
        AssertTransactionsByGateway(MockClient.GetRequestContaining('orderCreate('), 'NPRetail.POS.CASH', 150, 'NPRetail.POS.CARD', 50);
    end;

    [Test]
    procedure GivenSalePartAlreadySent_WhenSiblingRunsAgain_ThenOnlyTheRefundStepRuns()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An exchange whose order was created on an earlier attempt skips orderCreate on the retry and still refunds.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] An exchange entry already carrying its Shopify order id.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        AddItemLine(ReturnEntry, 20000, ItemNo, 1, 200);
        MarkSent(ReturnEntry."Entry No.", StoreCode, '777');
        Commit();
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] No orderCreate went out and the refund was recorded.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('orderCreate('), 'No second order');
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refund row');
    end;

    [Test]
    procedure GivenTwoLinkedGroupsAndSecondRefundFails_WhenSiblingRuns_ThenFirstRefundIsKeptAndTaskRetries()
    var
        OriginalEntry2: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine2: Record "NPR POS Entry Sales Line";
        ReturnLine2: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] With two original orders, a transport failure on the second refund keeps the first refund recorded and errors the task so it retries only the second.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return plus a second linked line from another sent original (order 999), with the second refund failing in transport.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        OriginalEntry2 := CreatePOSEntry(ReturnEntry."Customer No.", Today());
        OriginalLine2 := AddItemLine(OriginalEntry2, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry2."Entry No.", StoreCode, '999');
        ReturnLine2 := AddItemLine(ReturnEntry, 20000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine2, OriginalLine2);
        Commit();
        MockClient.AddResponse('PosReturnOrder', 'Order/18943015682268', OrderJson(LineItemJson('2', 'X', 'Item', 2, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnOrder', 'Order/999', OrderJson(LineItemJson('9', 'X', 'Item', 1, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', 'Order/18943015682268', RefundCreatedJson('1', '200.00'));
        MockClient.AddFailure('refundCreate(', 'Order/999');

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The first refund is recorded and the second is not.
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'First refund kept');
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '999'), 'Second refund not recorded');
    end;

    [Test]
    procedure GivenReturnLineStillPendingWhenSent_WhenSiblingRuns_ThenTaskFailsAndNothingIsSent()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        ReturnTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A return whose original became pending after the task's precondition was checked is not completed without its refund: the task fails, sends nothing, and is retried later.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');

        // [GIVEN] An original with an open task and no Shopify order yet, and a return of it with its own task.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        EnqueuePOSEntryTask(StoreCode, OriginalEntry);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        ReturnTaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();

        // [WHEN] The return's sibling runs directly, as if the precondition had passed a moment earlier.
        SpfyTask.Get(ReturnTaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The task fails naming the waiting line and no request reached Shopify.
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'still to be sent to Shopify') > 0, GetLastErrorText());
        _Assert.AreEqual(0, MockClient.RequestCount(), 'Nothing sent while the original is pending');
    end;

    [Test]
    procedure GivenCurrencyWithoutDecimals_WhenAPartlyRefundableLineIsRefunded_ThenTheAmountIsSentInWholeUnits()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReturnEntry: Record "NPR POS Entry";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A refund in a currency without decimals is rounded and sent in whole units, also when only part of the returned quantity can be refunded.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A local currency rounded to whole units and a return of three units for 100 against a line item with one refundable unit.
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Amount Rounding Precision" := 1;
        GeneralLedgerSetup.Modify();
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        ReturnLine.Get(ReturnEntry."Entry No.", 10000);
        ReturnLine.Quantity := -3;
        ReturnLine."Amount Incl. VAT" := -100;
        ReturnLine.Modify(false);
        Commit();
        MockOrder(MockClient, 1);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('33', '400'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '33'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] One unit is refunded for 33, written without decimals.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"amount":"33"'), Request);
        _Assert.IsFalse(Request.Contains('33.33'), Request);
    end;

    [Test]
    procedure GivenFirstOfTwoGroupsRefused_WhenSiblingRuns_ThenSecondRefundIsStillCreatedAndTaskErrors()
    var
        OriginalEntry2: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine2: Record "NPR POS Entry Sales Line";
        ReturnLine2: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        ItemNo: Code[20];
        ErrorText: Text;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When Shopify refuses the refund on one original order, the refunds on the entry's other original orders are still created, and the task then fails with an error that names the refused order and keeps the whole summary.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return plus a second linked line from another sent original (order 999); Shopify refuses the refund on the first order, which is processed first.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        OriginalEntry2 := CreatePOSEntry(ReturnEntry."Customer No.", Today());
        OriginalLine2 := AddItemLine(OriginalEntry2, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry2."Entry No.", StoreCode, '999');
        ReturnLine2 := AddItemLine(ReturnEntry, 20000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine2, OriginalLine2);
        Commit();
        MockClient.AddResponse('PosReturnOrder', 'Order/18943015682268', OrderJson(LineItemJson('2', 'X', 'Item', 2, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnOrder', 'Order/999', OrderJson(LineItemJson('9', 'X', 'Item', 1, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', 'Order/18943015682268', RefundRefusedJson('Refund amount is greater than net payment received'));
        MockClient.AddResponse('refundCreate(', 'Order/999', RefundCreatedJson('2', '200.00'));

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The refund on order 999 is recorded, the refused one is not, and the error names the refused order.
        ErrorText := GetLastErrorText();
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '999'), 'Refund on the second order created');
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refused refund not recorded');
        _Assert.IsTrue(StrPos(ErrorText, 'Shopify refused the refund on order 18943015682268') = 1, ErrorText);
        // [THEN] The error also carries the refund created on order 999 and the line that was not sent, since the queue keeps the error text as the task response.
        _Assert.IsTrue(StrPos(ErrorText, 'Refund 2 created on order 999') > 0, ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'Line 10000: not sent.') > 0, ErrorText);
    end;

    [Test]
    procedure GivenReturnEntryInAnotherCurrencyThanTheStore_WhenSiblingRuns_ThenLineIsReportedAndNothingIsSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A return entry in another currency than the Shopify store's is not refunded and its order is not even read; the line is reported with the currency reason.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return entry in a foreign currency against a sale in the store currency.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        ReturnEntry."Currency Code" := ForeignCurrency();
        ReturnEntry.Modify(false);
        Commit();
        MockOrder(MockClient, 2);

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing was sent to Shopify and the response names the entry's currency.
        _Assert.AreEqual(0, MockClient.RequestCount(), 'No request');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'The POS entry is in ZZFX') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenNothingLeftToRefundOnOrder_WhenSiblingRuns_ThenNoRefundCreateAndLinesReported()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When the order's transactions have nothing left to refund, no refundCreate is sent at all, because a refund without a transaction books a refund discrepancy in Shopify, and the lines are reported with that reason.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and a Shopify order whose suggested transaction has a zero maximum refundable amount.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '0.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] No refund request went out, nothing is recorded, and the response says the order has no payment left to refund.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund without a transaction');
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'No refund row');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'no payment left to refund') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenNoSuggestedTransactions_WhenSiblingRuns_ThenNoRefundCreateAndLinesReported()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When Shopify suggests no parent transaction at all (an order created without a sale transaction), no refundCreate is sent and the lines are reported.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and a suggested refund with an empty transaction list.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', '{"data":{"order":{"suggestedRefund":{"amountSet":{"presentmentMoney":{"amount":"200.00"}},"suggestedTransactions":[]}}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] No refund request went out and the response says the order has no payment left to refund.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund without a transaction');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'no payment left to refund') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenOrderCurrencyDiffersFromStoreCurrency_WhenSiblingRuns_ThenLineIsReportedAndNoRefundSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An order presented in a currency other than the store's is not refunded until multi-currency refunds have been verified against Shopify; the line is reported with that reason.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A store, a sent sale and a linked return all in the local currency, and a Shopify order presented in another currency.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockClient.AddResponse('PosReturnOrder', '{"data":{"order":{"id":"gid://shopify/Order/18943015682268","presentmentCurrencyCode":"XTS","lineItems":{"nodes":[' + LineItemJson('2', 'X', 'Item', 2, '555', '200.00') + ']},"refunds":[]}}}');

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The order was read, no refund was sent, and the response names the order's currency against the store's.
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('PosReturnOrder'), 'Order read');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'The Shopify order currency XTS differs from the store currency') > 0, ResponseText(TaskEntryNo));
    end;
    #endregion

    [Test]
    procedure GivenLinkedReturnLineWithZeroAmount_WhenSiblingRuns_ThenLineIsReportedAsNothingToRefundAndNoRefundSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A linked return of a free item has nothing to refund: the line is reported as such, no suggestion is asked for and no refund is sent.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return line with a zero amount, and Shopify answers the order query and a suggestion.
        TaskEntryNo := CreateLinkedReturn(StoreCode, 0, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('0.00', '400.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing was suggested or refunded, and the response says the line has no amount to refund.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('PosReturnSuggest'), 'No suggestion for nothing');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'has no amount to refund') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenNoRefundableLineItemOnTheOrder_WhenSiblingRuns_ThenLineIsReportedAsNotMatchedAndNoRefundSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When the original order has no line item left to refund for a linked return line, the line is reported as not matched and no suggestion or refund is asked for.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and a Shopify order whose matching line item has nothing left to refund.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 0);

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing was suggested or refunded, and the response names the line as not matched.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('PosReturnSuggest'), 'No suggestion');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 10000: not sent. No line item on the Shopify order matches this line') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenLinkedReturnLineWithAPositiveAmount_WhenSiblingRuns_ThenLineIsReportedAsNothingToRefundAndNoRefundSent()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A linked return line with a positive amount (a negative-priced line taken back) is money the customer pays, so there is nothing to refund: the line is reported as such and no suggestion or refund is asked for.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return line of quantity -1 for +10, and Shopify answers the order query and a suggestion.
        TaskEntryNo := CreateLinkedReturn(StoreCode, 10, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('0.00', '400.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Nothing was suggested or refunded, and the response says the line has no amount to refund.
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('PosReturnSuggest'), 'No suggestion for a negative amount');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('refundCreate('), 'No refund');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'has no amount to refund') > 0, ResponseText(TaskEntryNo));
    end;

    #region Resolver: currencies and originals
    local procedure ResolveReturnOf(OriginalEntry: Record "NPR POS Entry"; OriginalLine: Record "NPR POS Entry Sales Line"; StoreCode: Code[20]; var TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary)
    var
        ReturnEntry: Record "NPR POS Entry";
        ReturnLine: Record "NPR POS Entry Sales Line";
    begin
        ReturnEntry := CreatePOSEntry(OriginalEntry."Customer No.", Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, OriginalLine."No.", -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalIsASystemEntry_WhenResolved_ThenTheReasonSaysItIsNotEligible()
    var
        OriginalEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
    begin
        // [SCENARIO] A return of a sale the scheduler never sends because it is not eligible (a system entry) is Unlinked, and the reason says so.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An unsent original sale marked as a system entry.
        OriginalEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, CreateItem(), 1, 200);
        OriginalEntry.Get(OriginalEntry."Entry No.");
        OriginalEntry."System Entry" := true;
        OriginalEntry.Modify(false);

        // [WHEN] A return of its line is resolved.
        ResolveReturnOf(OriginalEntry, OriginalLine, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason says the original is not eligible, naming the System Entry field by its caption.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'it is not eligible for Shopify: it is a ' + OriginalEntry.FieldCaption("System Entry")) > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalHasNoSaleLines_WhenResolved_ThenTheReasonSaysSo()
    var
        OriginalEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
    begin
        // [SCENARIO] A return linked to a line of an entry without sale lines (itself a return) is Unlinked, and the reason says the original has no sale lines.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An unsent original entry whose only line is a return line.
        OriginalEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, CreateItem(), -1, -200);

        // [WHEN] A return linked to that line is resolved.
        ResolveReturnOf(OriginalEntry, OriginalLine, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason says the original has no sale lines.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'it has no sale lines') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalCustomerHasNoStoreLink_WhenResolved_ThenTheReasonSaysTheCustomerIsNotLinked()
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        OriginalEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
    begin
        // [SCENARIO] A return of a sale whose customer has no link to the Shopify store is Unlinked, and the reason says the customer is not linked.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An unsent original sale to a customer without a store link.
        OriginalEntry := CreatePOSEntry(CopyStr(_Lib.NextCode('ZC', 20), 1, 20), Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, CreateItem(), 1, 200);

        // [WHEN] A return of its line is resolved.
        ResolveReturnOf(OriginalEntry, OriginalLine, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason names the missing store-customer link by its table caption.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'its customer has no ' + SpfyStoreCustomerLink.TableCaption()) > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalIsInAnotherCurrencyThanTheStore_WhenResolved_ThenCaseIsUnlinkedWithTheCurrencyReason()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return of a sale made in another currency than the Shopify store's is Unlinked already when resolved, so the sale part never counts it as funding a new order.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A store in the local currency, a sent sale in a foreign currency, and a return of its line in the local currency.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalEntry."Currency Code" := ForeignCurrency();
        OriginalEntry.Modify(false);
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason names the original sale's currency.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'is in ZZFX while the Shopify store uses') > 0, TempReturnLineBuf."Unlinked Reason");
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'The original POS sale') = 1, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnEntryInAnotherCurrencyThanTheStore_WhenResolved_ThenCaseIsUnlinkedWithTheCurrencyReason()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return keyed in another currency than the Shopify store's is Unlinked already when resolved, even when its original sale is in the store currency, so the sale part never counts it as funding a new order.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A sent sale in the store currency and a return of its line keyed in a foreign currency.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnEntry."Currency Code" := ForeignCurrency();
        ReturnEntry.Modify(false);
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and the reason names the return entry's currency.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'The POS entry is in ZZFX') = 1, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginIsAnotherItem_WhenResolved_ThenCaseIsUnlinkedAndTheOtherItemIsNotRefunded()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLineA: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemA: Code[20];
        ItemB: Code[20];
    begin
        // [SCENARIO] A return line whose origin points at a line of another item (Import Posted Invoice links by line number) is Unlinked, so the other item's Shopify line item is never refunded.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemA := CreateItem();
        ItemB := CreateItem();

        // [GIVEN] A sent sale of item A, and a return of item B whose origin points at A's line.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLineA := AddItemLine(OriginalEntry, 10000, ItemA, 1, 200);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemB, -1, -300);
        LinkReturnLine(ReturnLine, OriginalLineA);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The line is Unlinked and the reason says its origin is another line.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'does not match') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginIsAnotherVariant_WhenResolved_ThenCaseIsUnlinked()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose origin is the same item in another variant is Unlinked, because the match keys come from the original line.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A sent sale of the item in variant V1, and a return of variant V2 whose origin points at the V1 line.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::Item, ItemNo, 'V1', 1, 200, 'Item ' + ItemNo);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddLine(ReturnEntry, 10000, ReturnLine.Type::Item, ItemNo, 'V2', -1, -200, 'Item ' + ItemNo);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The line is Unlinked with the mismatch reason.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'does not match') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginIsALineOfAnotherType_WhenResolved_ThenCaseIsUnlinked()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose origin is a line of another type with the same number (a G/L account numbered like the item) is Unlinked.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A sent sale with a G/L Account line numbered like the item, and an item return whose origin points at that line.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddLine(OriginalEntry, 10000, OriginalLine.Type::"G/L Account", ItemNo, '', 1, 200, 'Fee');
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The line is Unlinked with the mismatch reason.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'does not match') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenCustomerEntryWithOnlyAPayInOrPayOutToAGLAccount_WhenEligibilityIsChecked_ThenItIsNotEligible()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        Eligible: Boolean;
    begin
        // [SCENARIO] A customer entry whose only line is a pay-in or pay-out to a G/L account (quantity -1, no origin) has no return lines, so it is never queued as a return-only entry.
        Initialize();

        // [GIVEN] A customer entry with a single G/L Account line of 20 on quantity -1 and no origin.
        POSEntry := CreatePOSEntry(CreateSyncedCustomer(CreateStore()), Today());
        AddLine(POSEntry, 10000, POSEntrySalesLine.Type::"G/L Account", '6100', '', -1, 20, 'Pay-out');
        POSEntry.Get(POSEntry."Entry No.");

        // [WHEN] The entry's eligibility is checked.
        Eligible := SpfyPOSEntryExportMgt.IsEligibleForSync(POSEntry, true);

        // [THEN] It is not eligible, since the line is no return line and there is no sale line.
        _Assert.IsFalse(Eligible, 'Not eligible');
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalLineWasDeleted_WhenResolved_ThenCaseIsUnlinkedBecauseTheOriginalIsGone()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return line whose original POS sales line no longer exists resolves as Unlinked with the "no longer exists" reason.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] A return line linked to a sent sale's line, and that line deleted afterwards.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        OriginalLine.Delete(false);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked with the original-gone reason.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.AreEqual('The original POS sales line no longer exists.', TempReturnLineBuf."Unlinked Reason", 'Reason');
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalTaskWasCancelled_WhenResolved_ThenCaseIsUnlinkedAndTheReasonSaysTheTaskWasClosed()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return of a sale whose Shopify task was cancelled resolves as Unlinked, with a reason saying the scheduler passed the sale because its task was closed without sending.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] An original sale whose task was cancelled after the scheduler passed it, and a return of its line.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        if _SpfyTaskQueue.CancelUnsentTask(EnqueuePOSEntryTask(StoreCode, OriginalEntry), 'Cancelled by the test') then;
        SetHighWaterMarkAtLatest(StoreCode);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Unlinked and its reason says the task was closed without sending.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Unlinked, StrSubstNo('Expected Unlinked, found %1', TempReturnLineBuf."Return Case"));
        _Assert.IsTrue(StrPos(TempReturnLineBuf."Unlinked Reason", 'closed without sending') > 0, TempReturnLineBuf."Unlinked Reason");
    end;

    [Test]
    procedure GivenReturnLineWhoseOriginalIsAQueuedZeroTotalExchange_WhenResolved_ThenCaseIsPending()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        TempReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary;
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] A return of a line from an equal-value exchange that is still queued resolves as Pending, because the scheduler sends such an entry on the Task List even though its total is zero.
        Initialize();
        StoreCode := CreateStore();
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();

        // [GIVEN] An original exchange with a zero total and an open task, and a return of its positive line.
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 1, 200);
        AddItemLine(OriginalEntry, 20000, ItemNo, -1, -200);
        EnqueuePOSEntryTask(StoreCode, OriginalEntry);
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);

        // [WHEN] The return entry is resolved.
        _ReturnResolver.Resolve(ReturnEntry, StoreCode, TempReturnLineBuf);

        // [THEN] The row is Pending, not Unlinked.
        TempReturnLineBuf.FindFirst();
        _Assert.IsTrue(TempReturnLineBuf."Return Case" = TempReturnLineBuf."Return Case"::Pending, StrSubstNo('Expected Pending, found %1 (%2)', TempReturnLineBuf."Return Case", TempReturnLineBuf."Unlinked Reason"));
    end;
    #endregion

    #region Refund step: resends, merged lines and rounding
    [Test]
    procedure GivenLinkedReturn_WhenRefundIsSent_ThenOnlyTheRefundIsNotResentOnAServerError()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] The refund mutation is sent without the client's resend on a server error, because Shopify may already have created the refund and a resend would refund again; the order and suggestion queries keep the resend.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return and the Shopify answers.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The refund went out without the resend, and both queries with it.
        _Assert.IsFalse(MockClient.ResendOnServerErrorFor('refundCreate('), 'Refund must not be resent on a server error');
        _Assert.IsTrue(MockClient.ResendOnServerErrorFor('PosReturnOrder'), 'Order query keeps the resend');
        _Assert.IsTrue(MockClient.ResendOnServerErrorFor('PosReturnSuggest'), 'Suggestion query keeps the resend');
    end;

    [Test]
    procedure GivenTwoReturnLinesOfOneShopifyLineItem_WhenSiblingRuns_ThenTheLineItemIsSentOnceWithBothUnits()
    var
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] Two return lines that match the same Shopify line item are sent as one refund line with their quantities added, in both the suggestion and the refund.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A sent sale of two units on one line, a return entry with two one-unit lines linked to it, and the Shopify answers.
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 2, 400);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnLine := AddItemLine(ReturnEntry, 20000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('400.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '400.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] Each request names the line item once with quantity 2, and the refund carries both lines' amount.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.AreEqual(1, Occurrences(Request, '"lineItemId":"gid://shopify/LineItem/2"'), Request);
        _Assert.IsTrue(Request.Contains('"quantity":2'), Request);
        _Assert.IsTrue(Request.Contains('"amount":"400.00"'), Request);
        Request := MockClient.GetRequestContaining('PosReturnSuggest');
        _Assert.AreEqual(1, Occurrences(Request, '"lineItemId":"gid://shopify/LineItem/2"'), Request);
        _Assert.IsTrue(Request.Contains('"quantity":2'), Request);
    end;

    [Test]
    procedure GivenThreeDecimalCurrency_WhenShopifyRefundsLessThanRequested_ThenTheShortfallIsReported()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] In a currency with three decimals, a refund a few thousandths short of the POS amount is reported as short, not as refunded in full.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A local currency rounded to three decimals, a return of one unit for 10, and an order that can pay back only 9.996.
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup.Modify();
        TaskEntryNo := CreateLinkedReturn(StoreCode, -10, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('10.000', '9.996'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '9.996'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The response reports the refund as short.
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'short by') > 0, ResponseText(TaskEntryNo));
    end;

    [Test]
    procedure GivenCapWithMoreDecimalsThanTheCurrency_WhenRefundIsCapped_ThenTheAmountIsRoundedDownWithinTheCap()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] When Shopify's maximum refundable amount has more decimals than the POS currency, the capped amount is rounded down, so the refund never asks for more than the order can pay back.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A local currency rounded to whole units, a return of one unit for 2000, and an order that can pay back only 1234.50.
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Amount Rounding Precision" := 1;
        GeneralLedgerSetup.Modify();
        TaskEntryNo := CreateLinkedReturn(StoreCode, -2000, ReturnEntry, ItemNo);
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('2000', '1234.50'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '1234'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The REFUND transaction asks for 1234, not 1235.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"amount":"1234"'), Request);
        _Assert.IsFalse(Request.Contains('"amount":"1235"'), Request);
    end;

    [Test]
    procedure GivenFirstOfTwoOrdersMissingInShopify_WhenSiblingRuns_ThenSecondRefundIsStillCreatedAndTaskErrors()
    var
        OriginalEntry2: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine2: Record "NPR POS Entry Sales Line";
        ReturnLine2: Record "NPR POS Entry Sales Line";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendPOSEntry: Codeunit "NPR Spfy Task Send POS Entry";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] When one original order no longer exists in Shopify, the refunds on the entry's other original orders are still created, its lines are reported as not sent, and the task then fails naming the missing order.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A linked return plus a second linked line from another sent original (order 999); Shopify no longer has the first order, which is processed first.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        OriginalEntry2 := CreatePOSEntry(ReturnEntry."Customer No.", Today());
        OriginalLine2 := AddItemLine(OriginalEntry2, 10000, ItemNo, 1, 200);
        MarkSent(OriginalEntry2."Entry No.", StoreCode, '999');
        ReturnLine2 := AddItemLine(ReturnEntry, 20000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine2, OriginalLine2);
        Commit();
        MockClient.AddResponse('PosReturnOrder', 'Order/18943015682268', '{"data":{"order":null}}');
        MockClient.AddResponse('PosReturnOrder', 'Order/999', OrderJson(LineItemJson('9', 'X', 'Item', 1, '555', '200.00'), ''));
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', 'Order/999', RefundCreatedJson('2', '200.00'));

        // [WHEN] The POS entry sibling runs.
        SpfyTask.Get(TaskEntryNo);
        SendPOSEntry.SetGraphQLClient(MockClient);
        asserterror SendPOSEntry.Run(SpfyTask);

        // [THEN] The refund on order 999 is recorded, the missing order's line is reported as not sent, and the error names the missing order.
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '999'), 'Refund on the second order created');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'Line 10000: not sent. Shopify order 18943015682268 was not found') > 0, ResponseText(TaskEntryNo));
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Shopify order 18943015682268 was not found') > 0, GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'read_all_orders') > 0, GetLastErrorText());
    end;

    [Test]
    procedure GivenStoreAndEntriesInTheSameForeignCurrency_WhenSiblingRuns_ThenTheRefundIsSentInThatCurrencyAndPrecision()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        OriginalEntry: Record "NPR POS Entry";
        ReturnEntry: Record "NPR POS Entry";
        OriginalLine: Record "NPR POS Entry Sales Line";
        ReturnLine: Record "NPR POS Entry Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
        Request: Text;
    begin
        // [SCENARIO] A store whose currency is not the local one refunds a return made in that currency, in that currency and with that currency's rounding precision.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] A currency rounded to whole units, a store, a sent sale and its return all in it, and a Shopify order presented in it.
        Currency.Init();
        Currency.Code := 'ZZF0';
        Currency."ISO Code" := 'XXX';
        Currency."Amount Rounding Precision" := 1;
        if not Currency.Insert() then
            Currency.Modify();
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Currency Code" := Currency.Code;
        ShopifyStore.Modify(false);
        CustomerNo := CreateSyncedCustomer(StoreCode);
        ItemNo := CreateItem();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, '', StoreCode), '555');
        OriginalEntry := CreatePOSEntry(CustomerNo, Today());
        OriginalEntry."Currency Code" := Currency.Code;
        OriginalEntry.Modify(false);
        OriginalLine := AddItemLine(OriginalEntry, 10000, ItemNo, 2, 400);
        MarkSent(OriginalEntry."Entry No.", StoreCode, '18943015682268');
        ReturnEntry := CreatePOSEntry(CustomerNo, Today());
        ReturnEntry."Currency Code" := Currency.Code;
        ReturnEntry.Modify(false);
        ReturnLine := AddItemLine(ReturnEntry, 10000, ItemNo, -1, -200);
        LinkReturnLine(ReturnLine, OriginalLine);
        ReturnEntry.Get(ReturnEntry."Entry No.");
        TaskEntryNo := EnqueuePOSEntryTask(StoreCode, ReturnEntry);
        Commit();
        MockClient.AddResponse('PosReturnOrder', '{"data":{"order":{"id":"gid://shopify/Order/18943015682268","presentmentCurrencyCode":"XXX","lineItems":{"nodes":[' + LineItemJson('2', 'X', 'Item', 2, '555', '200') + ']},"refunds":[]}}}');
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200', '400'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The refund is sent in the store's currency, with the amount in whole units.
        Request := MockClient.GetRequestContaining('refundCreate(');
        _Assert.IsTrue(Request.Contains('"currency":"XXX"'), Request);
        _Assert.IsTrue(Request.Contains('"amount":"200"'), Request);
        _Assert.IsFalse(Request.Contains('"amount":"200.00"'), Request);
    end;

    [Test]
    procedure GivenExchangeWithAReversedNegativeLine_WhenSiblingRuns_ThenTheLineAddsToTheSale()
    var
        ReturnEntry: Record "NPR POS Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        ItemNo: Code[20];
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A negative-quantity line with a positive amount (a negative-priced line taken back) keeps its sign, so in an exchange it adds to the new order's SALE instead of reducing it.
        Initialize();
        StoreCode := CreateStore();
        SetApiVersion('2026-01');

        // [GIVEN] An exchange with a linked return of 200, an unlinked line of quantity -1 for +10, a positive line of 300 and 110 paid in cash; Shopify answers every call.
        TaskEntryNo := CreateLinkedReturn(StoreCode, ReturnEntry, ItemNo);
        AddItemLine(ReturnEntry, 20000, ItemNo, -1, 10);
        AddItemLine(ReturnEntry, 30000, ItemNo, 1, 300);
        AddPaymentLine(ReturnEntry, 10000, 'CASH', 110);
        Commit();
        MockClient.AddResponse('orderCreate(', '{"data":{"orderCreate":{"userErrors":[],"order":{"id":"gid://shopify/Order/778"}}}}');
        MockOrder(MockClient, 2);
        MockClient.AddResponse('PosReturnSuggest', SuggestJson('200.00', '400.00'));
        MockClient.AddResponse('refundCreate(', RefundCreatedJson('1', '200.00'));

        // [WHEN] The POS entry sibling runs.
        RunSibling(TaskEntryNo, MockClient);

        // [THEN] The new order is paid by one SALE of 310, so the two orders net to the 110 paid in cash.
        AssertSingleTransaction(MockClient.GetRequestContaining('orderCreate('), 'SALE', 'NPRetail.POS.EXCHANGE', 310);
    end;
    #endregion

    #region HTTP layer
    local procedure PrepareShopifyRequest(var SpfyTask: Record "NPR Spfy Task")
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        LibraryEntria: Codeunit "NPR Library - Entria";
        Variables: JsonObject;
    begin
        // A sandbox blocks HttpClient requests unless they are allowed for the app; the handler then never reaches Send.
        LibraryEntria.SetHttpClientRequestsAllowed(true);
        ShopifyStore.Get(CreateStore());
        ShopifyStore."Shopify Url" := 'https://zzcore435.myshopify.com';
        ShopifyStore."Shopify Access Token" := 'zz-token';
        ShopifyStore.Modify(false);
        SpfyTask.Init();
        SpfyTask."Store Code" := ShopifyStore.Code;
        SpfyCommunicationHandler.CompleteGraphQLRequest('query { shop { id } }', Variables, SpfyTask);
        _ServerErrorCalls := 0;
    end;

    [HttpClientHandler]
    procedure ShopifyServerErrorHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        _ServerErrorCalls += 1;
        Response.HttpStatusCode := 503;
        Response.ReasonPhrase := 'Service Unavailable';
        Response.Content.WriteFrom('<html><body>Service Unavailable</body></html>');
        exit(false);
    end;

    [Test]
    [HandlerFunctions('ShopifyServerErrorHandler')]
    procedure GivenShopifyAnswersAServerError_WhenARequestIsSentWithoutTheResend_ThenItGoesOutOnceAndTheErrorNamesTheStatus()
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
        Response: JsonToken;
        Sent: Boolean;
    begin
        // [SCENARIO] Through the real client and handler, a request sent without the resend on a server error goes out once, and the failure names the status even though the body is an HTML page.
        Initialize();

        // [GIVEN] A store with a shop address and a token, a request body, and Shopify answering 503 with an HTML page.
        PrepareShopifyRequest(SpfyTask);

        // [WHEN] The request is executed without the resend.
        Sent := SpfyGraphQLClient.ExecuteRequest(SpfyTask, false, false, Response);

        // [THEN] It failed after one call, and the error names the status.
        _Assert.IsFalse(Sent, 'The request failed');
        _Assert.AreEqual(1, _ServerErrorCalls, 'Calls to Shopify');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '503') > 0, GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('ShopifyServerErrorHandler')]
    procedure GivenShopifyAnswersAServerError_WhenARequestIsSentWithTheResend_ThenItGoesOutThreeTimes()
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
        Response: JsonToken;
        Sent: Boolean;
    begin
        // [SCENARIO] Every other request keeps the resend: on a server error the real handler sends it three times before it fails.
        Initialize();

        // [GIVEN] A store with a shop address and a token, a request body, and Shopify answering 503 every time.
        PrepareShopifyRequest(SpfyTask);

        // [WHEN] The request is executed with the default resend.
        Sent := SpfyGraphQLClient.ExecuteRequest(SpfyTask, false, Response);

        // [THEN] It failed after three calls.
        _Assert.IsFalse(Sent, 'The request failed');
        _Assert.AreEqual(3, _ServerErrorCalls, 'Calls to Shopify');
    end;
    #endregion

    #region Guards
    [Test]
    procedure GivenPosSourcedOrder_WhenImportEligibilityIsChecked_ThenItIsNotEligible()
    var
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        PosOrderEligible: Boolean;
        WebOrderEligible: Boolean;
    begin
        // [SCENARIO] Orders created by the POS sync carry the NPRetailPOS source name, which the ecommerce order import refuses, so refunds made on them are never imported back on that path (the legacy return poll has its own test).
        Initialize();

        // [WHEN] The import eligibility gate is asked about the source name the POS sync writes and about a web order.
        PosOrderEligible := SpfyOrderMgt.EligibleSourceName('NPRetailPOS');
        WebOrderEligible := SpfyOrderMgt.EligibleSourceName('web');

        // [THEN] It refuses NPRetailPOS and accepts an ordinary web order.
        _Assert.IsFalse(PosOrderEligible, 'POS-sourced orders must not be imported');
        _Assert.IsTrue(WebOrderEligible, 'Web orders are imported');
    end;

    [Test]
    procedure GivenStoreWithRecordedRefunds_WhenTheStoreIsDeleted_ThenItsRefundRowsAreDeleted()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Deleting a Shopify store removes the POS entry refunds recorded for it, so a store re-created under the same code does not skip refunds as already recorded.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A refund row recorded for the store.
        SpfyPOSEntryRefund.Store(StoreCode, 1, '18943015682268', '999', 200, StoreCurrency());

        // [WHEN] The store is deleted.
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] No refund row of the store remains.
        SpfyPOSEntryRefund.SetRange("Shopify Store Code", StoreCode);
        _Assert.IsTrue(SpfyPOSEntryRefund.IsEmpty(), 'Refund rows of a deleted store are removed');
    end;
    #endregion

    #region Sync state
    [Test]
    procedure GivenReturnEntryWithRecordedRefund_WhenSyncStateIsRead_ThenItIsSynced()
    var
        ReturnEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        StoreCode: Code[20];
        IsSynced: Boolean;
    begin
        // [SCENARIO] A return entry without a Shopify order of its own counts as synced with Shopify once a refund is recorded for it.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return entry with no Shopify order and a refund recorded on the original sale's order.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        SpfyPOSEntryRefund.Store(StoreCode, ReturnEntry."Entry No.", '18943015682268', '4242', 200, StoreCurrency());

        // [WHEN] Its sync state is read.
        IsSynced := ReturnEntry.IsSyncedToShopify();

        // [THEN] It is synced.
        _Assert.IsTrue(IsSynced, 'A return with a recorded refund is synced');
    end;

    [Test]
    procedure GivenReturnEntryWithoutRefundOrOrder_WhenSyncStateIsRead_ThenItIsNotSynced()
    var
        ReturnEntry: Record "NPR POS Entry";
        OtherEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        StoreCode: Code[20];
        IsSynced: Boolean;
    begin
        // [SCENARIO] A return entry that has neither a Shopify order nor a recorded refund is not synced, even when another entry has a refund.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return entry with nothing sent, and another entry with a recorded refund.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        OtherEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        SpfyPOSEntryRefund.Store(StoreCode, OtherEntry."Entry No.", '18943015682268', '4242', 200, StoreCurrency());

        // [WHEN] The return entry's sync state is read.
        IsSynced := ReturnEntry.IsSyncedToShopify();

        // [THEN] It is not synced.
        _Assert.IsFalse(IsSynced, 'A return with nothing sent is not synced');
    end;

    [Test]
    procedure GivenReturnEntryWithRecordedRefund_WhenSyncDetailsAreShown_ThenTheRefundsPageListsOnlyItsRefunds()
    var
        ReturnEntry: Record "NPR POS Entry";
        OtherEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        RefundsPage: TestPage "NPR Spfy POS Entry Refunds";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Drilling down on the sync state of a return entry opens the Refunds page filtered to that entry, showing the original sale's Shopify order.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return entry with a refund on order 18943015682268, and another entry with a refund on another order.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        OtherEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        SpfyPOSEntryRefund.Store(StoreCode, ReturnEntry."Entry No.", '18943015682268', '4242', 200, StoreCurrency());
        SpfyPOSEntryRefund.Store(StoreCode, OtherEntry."Entry No.", '18943015699999', '4343', 100, StoreCurrency());
        RefundsPage.Trap();

        // [WHEN] The sync details of the return entry are shown.
        ReturnEntry.ShowShopifySyncDetails();

        // [THEN] The Refunds page lists the return entry's refund only.
        _Assert.IsTrue(RefundsPage.First(), 'One refund listed');
        _Assert.AreEqual('18943015682268', RefundsPage."Shopify Order ID".Value(), 'Original sale order');
        _Assert.AreEqual('4242', RefundsPage."Shopify Refund ID".Value(), 'Refund id');
        _Assert.IsFalse(RefundsPage.Next(), 'Only the return entry''s refund');
        RefundsPage.Close();
    end;

    [Test]
    procedure GivenSaleEntryWithoutRefunds_WhenSyncDetailsAreShown_ThenTheShopifyOrderLinksPageOpens()
    var
        SaleEntry: Record "NPR POS Entry";
        LinksPage: TestPage "NPR Spfy Store-POS Entry Links";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Drilling down on the sync state of an entry without refunds opens the Shopify order links, which show the entry's own Shopify order.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A sale entry sent to Shopify as order 18943015682268.
        SaleEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        MarkSent(SaleEntry."Entry No.", StoreCode, '18943015682268');
        LinksPage.Trap();

        // [WHEN] The sync details of the sale entry are shown.
        SaleEntry.ShowShopifySyncDetails();

        // [THEN] The Shopify order links page shows the order for the store.
        _Assert.IsTrue(LinksPage.FindFirstField("Shopify Store Code", StoreCode), 'Store row');
        _Assert.AreEqual('18943015682268', LinksPage."Shopify Order ID".Value(), 'Own Shopify order');
        LinksPage.Close();
    end;

    [Test]
    procedure GivenExchangeEntryWithOwnOrderAndRefund_WhenSyncDetailsAreShown_ThenTheShopifyOrderLinksPageOpens()
    var
        ExchangeEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        LinksPage: TestPage "NPR Spfy Store-POS Entry Links";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Drilling down on the sync state of an exchange, which has its own Shopify order and a refund on the original's order, opens the order links, where its own order shows and its refunds are one action away.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] An exchange entry sent as order 780 with a refund recorded on the original order 18943015682268.
        ExchangeEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        MarkSent(ExchangeEntry."Entry No.", StoreCode, '780');
        SpfyPOSEntryRefund.Store(StoreCode, ExchangeEntry."Entry No.", '18943015682268', '4242', 200, StoreCurrency());
        LinksPage.Trap();

        // [WHEN] The sync details of the exchange entry are shown.
        ExchangeEntry.ShowShopifySyncDetails();

        // [THEN] The Shopify order links page shows the exchange's own order.
        _Assert.IsTrue(LinksPage.FindFirstField("Shopify Store Code", StoreCode), 'Store row');
        _Assert.AreEqual('780', LinksPage."Shopify Order ID".Value(), 'Own Shopify order');
        LinksPage.Close();
    end;

    [Test]
    procedure GivenReturnEntryWithRecordedRefund_WhenEntryIsDeleted_ThenItsRefundRowsAreRemoved()
    var
        ReturnEntry: Record "NPR POS Entry";
        OtherEntry: Record "NPR POS Entry";
        SpfyPOSEntryRefund: Record "NPR Spfy POS Entry Refund";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Deleting a POS entry, as the retention policy does, removes the entry's refund rows and keeps those of other entries.
        Initialize();
        StoreCode := CreateStore();

        // [GIVEN] A return entry and another entry, each with a recorded refund.
        ReturnEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        OtherEntry := CreatePOSEntry(CreateSyncedCustomer(StoreCode), Today());
        SpfyPOSEntryRefund.Store(StoreCode, ReturnEntry."Entry No.", '18943015682268', '4242', 200, StoreCurrency());
        SpfyPOSEntryRefund.Store(StoreCode, OtherEntry."Entry No.", '18943015699999', '4343', 100, StoreCurrency());

        // [WHEN] The return entry is deleted with its triggers.
        ReturnEntry.Delete(true);

        // [THEN] Its refund row is gone and the other entry's row remains.
        _Assert.IsFalse(SpfyPOSEntryRefund.Find(StoreCode, ReturnEntry."Entry No.", '18943015682268'), 'Refund row of the deleted entry removed');
        _Assert.IsTrue(SpfyPOSEntryRefund.Find(StoreCode, OtherEntry."Entry No.", '18943015699999'), 'Other entry keeps its refund row');
    end;
    #endregion
}
