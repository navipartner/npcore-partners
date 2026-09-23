codeunit 85461 "NPR Spfy TL Inv&Price Tests"
{
    // [FEATURE] Shopify Task List - inventory levels, item prices and location activation on the queue: dispatch routing, preconditions, scheduling
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _SourceGoneLbl: Label 'The source record no longer exists. The request is no longer applicable.';
        _WaitingForInventoryItemLbl: Label 'Awaiting inventory item sync';
        _WaitingForLocationActivationLbl: Label 'Awaiting Shopify location activation';
        _WaitingForVariantLbl: Label 'Awaiting variant sync';
        _UnmappedKindTok: Label 'no send codeunit mapped', Locked = true;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        // The activation ensure routes through the binary router, which keys on the feature, while the engine keys on the migration status: both must be on here.
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

    local procedure DropSendBoundaryMock()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        // Initialize() injects the mock; a test that must reach the real request preparation has to drop it explicitly.
        SpfyTaskRunContext.ClearSendBoundary();
    end;

    local procedure Hours(HourCount: Integer): Duration
    begin
        exit(HourCount * 60 * 60 * 1000);
    end;

    local procedure Minutes(MinuteCount: Integer): Duration
    begin
        exit(MinuteCount * 60 * 1000);
    end;

    local procedure SetLastCycleAt(StoreCode: Code[20]; AtDateTime: DateTime)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        if not SpfyDataSyncPointer.Get(StoreCode) then begin
            SpfyDataSyncPointer.Init();
            SpfyDataSyncPointer."Shopify Store Code" := StoreCode;
            SpfyDataSyncPointer.Insert(false);
        end;
        SpfyDataSyncPointer."Last Task List Cycle At" := AtDateTime;
        SpfyDataSyncPointer.Modify(false);
    end;

    local procedure CreateInventoryStore(): Code[20]
    begin
        exit(_Lib.CreateStore(true, true, false, false, false));
    end;

    local procedure CreatePriceStore(): Code[20]
    begin
        exit(_Lib.CreateStore(true, false, true, false, false));
    end;

    local procedure SeedInventoryLevel(var InventoryLevel: Record "NPR Spfy Inventory Level"; StoreCode: Code[20]; ItemNo: Code[20]; ShopifyLocationId: Text[30]; Qty: Decimal)
    begin
        InventoryLevel.Init();
        InventoryLevel."Shopify Store Code" := StoreCode;
        InventoryLevel."Shopify Location ID" := ShopifyLocationId;
        InventoryLevel."Item No." := ItemNo;
        InventoryLevel."Variant Code" := '';
        InventoryLevel.Inventory := Qty;
        InventoryLevel."Last Updated at" := CurrentDateTime();
        InventoryLevel.Insert(false);
    end;

    local procedure SeedLocationInvItem(StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20]; Activated: Boolean; AutoActivationDisabled: Boolean)
    begin
        SeedVariantLocationInvItem(StoreCode, ShopifyLocationId, ItemNo, '', Activated, AutoActivationDisabled);
    end;

    local procedure ActivateLocationInvItem(StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20])
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        LocationInvItem.Get(StoreCode, ShopifyLocationId, ItemNo, '');
        LocationInvItem.Activated := true;
        LocationInvItem.Modify(false);
    end;

    local procedure GetLocationInvItem(var LocationInvItem: Record "NPR Spfy Inv Item Location"; StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20]): Boolean
    begin
        exit(LocationInvItem.Get(StoreCode, ShopifyLocationId, ItemNo, ''));
    end;

    local procedure AssignInventoryItemID(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), "NPR Spfy ID Type"::"Inventory Item ID", CopyStr('gid://ii/' + ItemNo, 1, 30), false);
    end;

    local procedure AssignVariantID(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    begin
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), CopyStr('gid://v/' + ItemNo, 1, 30));
    end;

    local procedure EnqueueInventoryLevelTask(StoreCode: Code[20]; InventoryLevel: Record "NPR Spfy Inventory Level"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InventoryLevel);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, InventoryLevel.RecordId(), SpfyItemMgt.GetProductVariantSku(InventoryLevel."Item No.", InventoryLevel."Variant Code"),
            "NPR Spfy Task Op"::Modify, InventoryLevel."Last Updated at", 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueItemPriceTask(StoreCode: Code[20]; ItemPrice: Record "NPR Spfy Item Price"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemPrice);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, ItemPrice.RecordId(), SpfyItemMgt.GetProductVariantSku(ItemPrice."Item No.", ItemPrice."Variant Code"),
            "NPR Spfy Task Op"::Modify, CurrentDateTime(), CreateDateTime(ItemPrice."Starting Date", 0T), "NPR Spfy Reuse Delayed NC Task"::No, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueActivationTask(StoreCode: Code[20]; LocationInvItem: Record "NPR Spfy Inv Item Location"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LocationInvItem);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, LocationInvItem.RecordId(), SpfyItemMgt.GetProductVariantSku(LocationInvItem."Item No.", LocationInvItem."Variant Code"),
            "NPR Spfy Task Op"::Insert, CurrentDateTime() + 1000, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueVariantTask(StoreCode: Code[20]; ItemVariant: Record "Item Variant"; TaskType: Enum "NPR Spfy Task Op"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemVariant);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, ItemVariant.RecordId(), SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code),
            TaskType, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
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

    local procedure TaskCount(TableNo: Integer): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.Count());
    end;

    local procedure TypedTaskCount(TableNo: Integer; TaskType: Enum "NPR Spfy Task Op"): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.SetRange(Type, TaskType);
        exit(SpfyTask.Count());
    end;

    local procedure NcTaskCount(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        exit(NcTask.Count());
    end;

    #region Dispatch routing and grouping
    [Test]
    procedure GivenReadyInventoryLevelTasks_WhenCycleRuns_ThenOneTemporaryBatchDispatch()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        LocationIndex: Integer;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] Ready inventory levels of one store travel to Shopify as a single grouped temporary call carrying every one of them, and each level task completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);

        // [GIVEN] Three ready inventory levels of one store, each at an already activated location.
        for LocationIndex := 1 to 3 do begin
            _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
            SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, LocationIndex);
            SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
            TaskEntryNos.Add(EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime));
        end;

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The three levels travel to Shopify as one grouped call.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The inventory levels of one store must travel as a single grouped call');
        _Assert.IsTrue(_BndMock.LastDispatchWasTemporary(), 'An inventory level group must be handed over as a temporary record set');
        _Assert.AreEqual(Database::"NPR Spfy Inventory Level", _BndMock.LastDispatchTableNo(), 'The grouped call must carry the inventory level table');
        _Assert.AreEqual(3, _BndMock.DispatchedRowCount(), 'Every ready inventory level of the store must join the group');
        for LocationIndex := 1 to 3 do
            AssertTask(TaskEntryNos.Get(LocationIndex), "NPR Spfy Task State"::Completed, 1, StrSubstNo('Inventory level task %1 must be sent', LocationIndex));
    end;

    [Test]
    procedure GivenReadyItemPriceTasks_WhenCycleRuns_ThenOneTemporaryBatchDispatch()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTask: BigInteger;
        SecondTask: BigInteger;
    begin
        // [SCENARIO] Ready item prices of one store travel to Shopify as a single grouped temporary call carrying every one of them, and each price task completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(FirstItem, SpfyStoreItemLink, StoreCode);
        AssignVariantID(FirstItem."No.", '', StoreCode);
        _Lib.CreateSyncedItemWithLink(SecondItem, SpfyStoreItemLink, StoreCode);
        AssignVariantID(SecondItem."No.", '', StoreCode);

        // [GIVEN] Two prices of one store that have already started.
        _Lib.CreateItemPrice(ItemPrice, FirstItem."No.", StoreCode, 100, Today());
        FirstTask := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);
        _Lib.CreateItemPrice(ItemPrice, SecondItem."No.", StoreCode, 200, Today());
        SecondTask := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The two prices travel to Shopify as one grouped call.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The prices of one store must travel as a single grouped call');
        _Assert.IsTrue(_BndMock.LastDispatchWasTemporary(), 'A price group must be handed over as a temporary record set');
        _Assert.AreEqual(Database::"NPR Spfy Item Price", _BndMock.LastDispatchTableNo(), 'The grouped call must carry the item price table');
        _Assert.AreEqual(2, _BndMock.DispatchedRowCount(), 'Every ready price of the store must join the group');
        AssertTask(FirstTask, "NPR Spfy Task State"::Completed, 1, 'The first price task must be sent');
        AssertTask(SecondTask, "NPR Spfy Task State"::Completed, 1, 'The second price task must be sent');
    end;

    [Test]
    procedure GivenMixedKindsInOneCycle_ThenSeparateDispatchPerTableAndSingleForActivation()
    var
        VariantItem: Record Item;
        LevelItem: Record Item;
        PriceItem: Record Item;
        ActivationItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemVariant: Record "Item Variant";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ItemPrice: Record "NPR Spfy Item Price";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        StoreCode: Code[20];
        LevelLocationId: Text[30];
        ActivationLocationId: Text[30];
        AtDateTime: DateTime;
        DispatchIndex: Integer;
        SingleDispatchCount: Integer;
        GroupedTableNos: List of [Integer];
    begin
        // [SCENARIO] A cycle holding one task of each kind gives every batchable kind its own grouped call per table and sends the location activation alone as a single record.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, true, true, false, false);

        // [GIVEN] One ready task of each phase-one and phase-two kind, all preconditions met.
        _Lib.CreateSyncedItemWithLink(VariantItem, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + VariantItem."No.", 1, 30));
        _Lib.CreateItemVariant(ItemVariant, VariantItem."No.");
        EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Modify, AtDateTime);

        _Lib.CreateSyncedItemWithLink(LevelItem, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(LevelItem."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, LevelLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, LevelItem."No.", LevelLocationId, 5);
        SeedLocationInvItem(StoreCode, LevelLocationId, LevelItem."No.", true, false);
        EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        _Lib.CreateSyncedItemWithLink(PriceItem, SpfyStoreItemLink, StoreCode);
        AssignVariantID(PriceItem."No.", '', StoreCode);
        _Lib.CreateItemPrice(ItemPrice, PriceItem."No.", StoreCode, 100, Today());
        EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        _Lib.CreateSyncedItemWithLink(ActivationItem, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(ActivationItem."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ActivationLocationId);
        SeedLocationInvItem(StoreCode, ActivationLocationId, ActivationItem."No.", false, false);
        GetLocationInvItem(LocationInvItem, StoreCode, ActivationLocationId, ActivationItem."No.");
        EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Each batchable kind gets its own grouped call and the activation travels alone.
        _Assert.AreEqual(4, _BndMock.DispatchCount(), 'Each task kind of the cycle must reach the send boundary in its own call');
        for DispatchIndex := 1 to 4 do
            if _BndMock.DispatchWasTemporaryAt(DispatchIndex) then begin
                _Assert.AreEqual(1, _BndMock.DispatchRowCountAt(DispatchIndex), StrSubstNo('Grouped call %1 must carry exactly the one task of its kind', DispatchIndex));
                GroupedTableNos.Add(_BndMock.DispatchTableNoAt(DispatchIndex));
            end else begin
                SingleDispatchCount += 1;
                _Assert.AreEqual(Database::"NPR Spfy Inv Item Location", _BndMock.DispatchTableNoAt(DispatchIndex), 'The only single-record call must be the location activation');
            end;
        _Assert.AreEqual(1, SingleDispatchCount, 'Exactly one call must be a single-record call');
        _Assert.AreEqual(3, GroupedTableNos.Count(), 'The three batchable kinds must each travel as their own group');
        _Assert.IsTrue(GroupedTableNos.Contains(Database::"Item Variant"), 'The variant task must travel as a group of its own table');
        _Assert.IsTrue(GroupedTableNos.Contains(Database::"NPR Spfy Inventory Level"), 'The inventory level task must travel as a group of its own table');
        _Assert.IsTrue(GroupedTableNos.Contains(Database::"NPR Spfy Item Price"), 'The price task must travel as a group of its own table');
    end;

    [Test]
    procedure GivenSingleInventoryLevelTask_WhenProcessedManually_ThenBatchOfOneDispatches()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A single inventory level task processed manually still travels as a temporary group of one and completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] An operator asks for the single level task to be processed now.
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskProcessor.ProcessTaskManually(SpfyTask, false);

        // [THEN] A group of one is a valid bulk call - nothing special-cases it.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A single level task must still be dispatched');
        _Assert.IsTrue(_BndMock.LastDispatchWasTemporary(), 'A level group of one must still travel as a temporary work list');
        _Assert.AreEqual(1, _BndMock.LastDispatchRowCount(), 'A level group of one must carry exactly one row');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A manually processed level task must complete');
    end;

    [Test]
    procedure GivenSendPresentsOnlySomeOfAGroup_WhenCycleRuns_ThenProcessorLeavesTheRestUntouchedPending()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        LocationIndex: Integer;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] Levels the send never presented stay untouched Pending with no attempt and no failure response, and are sent on their first attempt by the next cycle.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        for LocationIndex := 1 to 3 do begin
            _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
            SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, LocationIndex);
            SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
            TaskEntryNos.Add(EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime));
        end;

        // [GIVEN] The send consumes only the first level and still reports success, so the rest are never presented.
        _BndMock.SetSilentDropAfterNRows(1);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] A row the send never presented is charged nothing: no attempt, no response.
        AssertTask(TaskEntryNos.Get(1), "NPR Spfy Task State"::Completed, 1, 'The level the send did present must stay sent');
        AssertTask(TaskEntryNos.Get(2), "NPR Spfy Task State"::Pending, 0, 'A level the send never presented must stay untouched Pending');
        AssertTask(TaskEntryNos.Get(3), "NPR Spfy Task State"::Pending, 0, 'Every level the send never presented must stay untouched Pending');
        _Assert.AreEqual('', ResponseText(TaskEntryNos.Get(2)), 'An unpresented level must not record a failure it did not have');

        // [THEN] The next cycle sends the skipped levels on their first attempt.
        _BndMock.SetSilentDropAfterNRows(0);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));
        AssertTask(TaskEntryNos.Get(2), "NPR Spfy Task State"::Completed, 1, 'An unpresented level must be sent on the next cycle at its first attempt');
        AssertTask(TaskEntryNos.Get(3), "NPR Spfy Task State"::Completed, 1, 'Every unpresented level must be sent on the next cycle at its first attempt');
    end;

    [Test]
    procedure GivenConcurrentWaitingRoundTripMidDispatch_WhenCycleRuns_ThenDeclinedRowIsSpared()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        LocationIndex: Integer;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] A row another session parks Waiting and releases mid-dispatch is left Pending with no attempt burned and no failure response, while its group-mate completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        for LocationIndex := 1 to 2 do begin
            _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
            SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, LocationIndex);
            SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
            TaskEntryNos.Add(EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime));
        end;

        // [GIVEN] Another session parks the second task Waiting mid-dispatch and releases it after the send.
        _BndMock.SetWaitingRoundTripForEntry(TaskEntryNos.Get(2));

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The presented-but-declined row is spared: no attempt burned, no failure recorded.
        AssertTask(TaskEntryNos.Get(1), "NPR Spfy Task State"::Completed, 1, 'The task consumed by the dispatch must complete normally');
        AssertTask(TaskEntryNos.Get(2), "NPR Spfy Task State"::Pending, 0, 'A row parked and released by a concurrent session must be left Pending, not charged');
        GetTask(TaskEntryNos.Get(2), SpfyTask);
        SpfyTask.CalcFields(Response);
        _Assert.IsFalse(SpfyTask.Response.HasValue(), 'A spared row must not carry a failure response');
    end;
    #endregion

    #region Precondition - inventory item
    [Test]
    procedure GivenNoInventoryItemId_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An inventory level whose variant has no Shopify inventory item waits without spending an attempt or reaching the send boundary, keeping the blocker label as its reason and the failed lookup in its response.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);

        // [GIVEN] The variant has never been sent to Shopify, so it has no inventory item there.
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The level is deferred, not attempted, and the failed lookup is recorded, not masked as a missing inventory item.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level without a Shopify inventory item must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred level must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Reason" <> '', 'The task must record why it is waiting');
        // The test container has no Shopify endpoint, so the first-dispatch live lookup fails: the stable label stays the reason and the error goes to the response.
        _Assert.AreEqual(_WaitingForInventoryItemLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        SpfyTask.CalcFields(Response);
        _Assert.IsTrue(SpfyTask.Response.HasValue(), 'A failed inventory item lookup must store the full error for Show Response');
    end;

    [Test]
    procedure GivenWaitingOnInventoryItemId_WhenIdAssigned_ThenNextCycleSends()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level waiting for its Shopify inventory item keeps waiting while the item is missing and is sent exactly once on a fresh attempt after the id is assigned.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);

        // [GIVEN] A level already parked because its variant had no inventory item in Shopify.
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForInventoryItemLbl, AtDateTime);

        // [WHEN] A cycle runs while the inventory item is still missing.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The level keeps waiting: only a met precondition may release it.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level whose inventory item is still missing must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A level whose inventory item is still missing must never reach the send boundary');

        // [WHEN] The variant reaches Shopify and the next cycle runs.
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The waiting level is released and sent on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting level must be sent once its inventory item exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released level must be sent exactly once');
    end;

    [Test]
    procedure GivenSyncDisabledItemWithoutInventoryItemId_WhenCycleRuns_ThenLevelDispatchesInsteadOfWaiting()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level of a sync-disabled item is dispatched to the send boundary instead of being parked on a Shopify inventory item lookup.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateItem(Item);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);

        // [GIVEN] A level whose item has no Shopify inventory item and whose store link is sync-disabled.
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The level is dispatched instead of parked for a day on a lookup it should never have paid for.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A level of a sync-disabled item must be dispatched so the send can fail it fast, not parked on a Shopify lookup');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A level of a sync-disabled item must reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'No Shopify lookup may be attempted for a sync-disabled item');
    end;
    #endregion

    #region Precondition - location activation
    [Test]
    procedure GivenInactiveLocation_WhenCycleRuns_ThenWaitingAndActivationTaskEnqueued()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level at an unactivated location waits without spending an attempt and queues exactly one location activation task, in the new queue only.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);

        // [GIVEN] The location has not been activated in Shopify yet.
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The level waits and the activation it needs is queued exactly once, in the new queue.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level at an unactivated location must wait without spending an attempt');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForLocationActivationLbl, SpfyTask."Waiting Reason", 'The task must record that it waits for the location activation');
        _Assert.AreEqual(1, TypedTaskCount(Database::"NPR Spfy Inv Item Location", "NPR Spfy Task Op"::Insert), 'Exactly one location activation task must be queued');
        _Assert.AreEqual(0, NcTaskCount(), 'The activation must be queued in the new queue, never in the legacy one');
    end;

    [Test]
    procedure GivenNoLocationRecord_WhenCycleRuns_ThenRecordCreatedAndActivationTaskEnqueued()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level at a location with no activation record has that record created by the precondition check, waits without spending an attempt, and queues exactly one activation task.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);

        // [GIVEN] The variant has never been looked at for this location, so no activation record exists.
        _Assert.IsFalse(GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No."), 'The fixture must start without an activation record');
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The activation record is created and its activation task queued once.
        _Assert.IsTrue(GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No."), 'The missing activation record must be created by the precondition check');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level at a location that was never activated must wait without spending an attempt');
        _Assert.AreEqual(1, TypedTaskCount(Database::"NPR Spfy Inv Item Location", "NPR Spfy Task Op"::Insert), 'Exactly one location activation task must be queued');
    end;

    [Test]
    procedure GivenAutoActivationDisabledLocation_WhenCycleRuns_ThenLevelTaskDispatchesNotWaiting()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level whose location has auto-activation disabled is dispatched rather than deferred and never gets an activation task.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);

        // [GIVEN] The merchant deliberately switched auto-activation off for this location.
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, true);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The level is handed to the send code, which owns the documented skip - it is never parked as waiting.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A level whose location has auto-activation disabled must be dispatched rather than deferred');
        _Assert.AreEqual(0, TaskCount(Database::"NPR Spfy Inv Item Location"), 'A location with auto-activation disabled must never get an activation task');
    end;

    [Test]
    procedure GivenWaitingOnActivation_WhenLocationActivated_ThenNextCycleSends()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level waiting for its location activation keeps waiting while the location is inactive and is sent exactly once on a fresh attempt after it is activated.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);

        // [GIVEN] A level already parked because its location was not activated in Shopify.
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForLocationActivationLbl, AtDateTime);

        // [WHEN] A cycle runs while the location is still not activated.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The level keeps waiting: only a met precondition may release it.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level whose location is still not activated must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A level whose location is still not activated must never reach the send boundary');

        // [WHEN] The activation reaches Shopify and the next cycle runs.
        ActivateLocationInvItem(StoreCode, ShopifyLocationId, Item."No.");
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The waiting level is released and sent on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting level must be sent once its location is activated');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released level must be sent exactly once');
    end;

    [Test]
    procedure GivenWaitingOnActivation_WhenReevaluatedNextCycle_ThenNoSecondActivationTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ActivationTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        FirstActivationEntryNo: BigInteger;
    begin
        // [SCENARIO] Re-evaluating a waiting level on a later cycle keeps it waiting and does not queue its location activation a second time.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [GIVEN] The first cycle's activation task is closed, because a still-open one would absorb a re-fired ensure and hide it from the count below.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        ActivationTask.SetRange("Table No.", Database::"NPR Spfy Inv Item Location");
        ActivationTask.FindFirst();
        FirstActivationEntryNo := ActivationTask."Entry No.";
        if ActivationTask.State <> ActivationTask.State::Completed then
            _SpfyTaskQueue.CancelUnsentTask(FirstActivationEntryNo, 'Closed by the test so a re-fired ensure cannot be absorbed');

        // [WHEN] The next cycle re-evaluates the same waiting level.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] Re-evaluating a waiting level must not queue the activation a second time.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The level must still be waiting for its location activation');
        _Assert.AreEqual(1, TaskCount(Database::"NPR Spfy Inv Item Location"), 'A re-evaluated waiting level must not queue a second activation task');
        ActivationTask.FindFirst();
        _Assert.AreEqual(FirstActivationEntryNo, ActivationTask."Entry No.", 'The single activation task must still be the one ensured by the first cycle');
    end;

    [Test]
    procedure GivenWaitingLevel_WhenBlockerChanges_ThenWaitingReasonFollows()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A waiting level whose first blocker clears while another remains records the blocker it is actually waiting for now.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [GIVEN] The level parks on the first blocker: it has no Shopify inventory item yet.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A level without an inventory item must wait');

        // [WHEN] That blocker clears but the location is still inactive.
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The recorded reason names the blocker it is actually waiting for now.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The level must still wait for its location activation');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForLocationActivationLbl, SpfyTask."Waiting Reason", 'A changed blocker must be reflected in the recorded waiting reason');
    end;

    [Test]
    procedure GivenActivationTaskWithoutInventoryItem_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An activation task whose variant has no Shopify inventory item waits without spending an attempt or reaching the send boundary, keeping the blocker label as its reason and the failed lookup in its response.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [GIVEN] An activation task for a variant that has no inventory item in Shopify yet.
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No.");
        TaskEntryNo := EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The activation is deferred, not attempted: sent now it would complete unsent and leave the location inactive for good.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'An activation without a Shopify inventory item must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred activation must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Reason" <> '', 'The task must record why it is waiting');
        // The test container has no Shopify endpoint, so the first-dispatch live lookup fails: the stable label stays the reason and the error goes to the response.
        _Assert.AreEqual(_WaitingForInventoryItemLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        SpfyTask.CalcFields(Response);
        _Assert.IsTrue(SpfyTask.Response.HasValue(), 'A failed inventory item lookup must store the full error for Show Response');
    end;

    [Test]
    procedure GivenWaitingActivation_WhenInventoryItemAssigned_ThenNextCycleSends()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An activation waiting for its Shopify inventory item keeps waiting while the item is missing and is then sent exactly once, alone, as a single-record call.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No.");

        // [GIVEN] An activation already parked because its variant had no inventory item in Shopify.
        TaskEntryNo := EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForInventoryItemLbl, AtDateTime);

        // [WHEN] A cycle runs while the inventory item is still missing.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The activation keeps waiting.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'An activation whose inventory item is still missing must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'An activation whose inventory item is still missing must never reach the send boundary');

        // [WHEN] The variant reaches Shopify and the next cycle runs.
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The waiting activation is released and sent alone on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting activation must be sent once its inventory item exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released activation must be sent exactly once');
        _Assert.IsFalse(_BndMock.LastDispatchWasTemporary(), 'An activation is a single-record kind, not a batch');
    end;

    [Test]
    procedure GivenLevelAndActivationBothWaiting_WhenInventoryItemAssigned_ThenActivationSendsAndLevelWaitsOnIt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        LevelEntryNo: BigInteger;
        ActivationEntryNo: BigInteger;
    begin
        // [SCENARIO] When the inventory item arrives, the parked activation is released and sent while the level moves on to wait for that activation without queueing a second one.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No.");

        // [GIVEN] A level and its activation, both parked because the variant has no inventory item in Shopify yet.
        LevelEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);
        ActivationEntryNo := EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(LevelEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The level must wait for the inventory item');
        AssertTask(ActivationEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The activation must wait for the inventory item');

        // [WHEN] The variant reaches Shopify and the next cycle runs.
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The activation is released and sent; the level moves on to wait for that activation, and no duplicate activation is queued.
        AssertTask(ActivationEntryNo, "NPR Spfy Task State"::Completed, 1, 'The released activation must be sent');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'Only the activation may reach the send boundary in this cycle');
        AssertTask(LevelEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The level must now wait for the location activation');
        GetTask(LevelEntryNo, SpfyTask);
        _Assert.AreEqual(_WaitingForLocationActivationLbl, SpfyTask."Waiting Reason", 'The level must record the activation as its blocker');
        _Assert.AreEqual(1, TaskCount(Database::"NPR Spfy Inv Item Location"), 'The waiting level must not queue a second activation while one exists');
    end;

    [Test]
    procedure GivenAgedLevelWaitingOnActivation_WhenThresholdReached_ThenQuarantinedWithoutNewActivationTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        ActivationTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        WaitingSince: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level waiting on its location activation past the aging threshold is quarantined without the aged pass leaving a replacement activation task behind.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [GIVEN] A level parked on its location activation, whose activation task has since ended without activating.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'The level must wait for its location activation');
        ActivationTask.SetRange("Table No.", Database::"NPR Spfy Inv Item Location");
        ActivationTask.FindFirst();
        _SpfyTaskQueue.CancelUnsentTask(ActivationTask."Entry No.", 'Closed by the test so the aged pass could queue a replacement');

        // The stored waiting time is the anchor: the database rounds date-times, so the threshold has to be measured from what it actually kept.
        GetTask(TaskEntryNo, SpfyTask);
        WaitingSince := SpfyTask."Waiting Since";

        // [WHEN] The level reaches the aging threshold.
        SetLastCycleAt(StoreCode, WaitingSince + Hours(24));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, WaitingSince + Hours(24));

        // [THEN] The level is quarantined and the pass that gives up on it does not leave an orphan activation task behind.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 0, 'An aged level must be quarantined');
        _Assert.AreEqual(1, TaskCount(Database::"NPR Spfy Inv Item Location"), 'The aged pass must not queue a replacement activation task for a level it quarantines');
    end;
    #endregion

    #region Precondition - variant for prices
    [Test]
    procedure GivenPriceWithoutVariantId_WhenCycleRuns_ThenWaitingWithoutAttempt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A price whose variant has never reached Shopify waits without spending an attempt or reaching the send boundary, keeping the blocker label as its reason and the failed lookup in its response.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A started price for a variant that has never been sent to Shopify.
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today());
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The price is deferred, not attempted: sent now it would burn its attempts on a variant that cannot be priced yet.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A price without a Shopify variant must wait without spending an attempt');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A deferred price must never reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.IsTrue(SpfyTask."Waiting Reason" <> '', 'The task must record why it is waiting');
        // The test container has no Shopify endpoint, so the first-dispatch live lookup fails: the stable label stays the reason and the error goes to the response.
        _Assert.AreEqual(_WaitingForVariantLbl, SpfyTask."Waiting Reason", 'The stable blocker label must be the waiting reason; the lookup error belongs in the response');
        SpfyTask.CalcFields(Response);
        _Assert.IsTrue(SpfyTask.Response.HasValue(), 'A failed variant lookup must store the full error for Show Response');
    end;

    [Test]
    procedure GivenWaitingPrice_WhenVariantIdAssigned_ThenNextCycleSends()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A price waiting for its Shopify variant keeps waiting while the variant is missing and is sent exactly once on the price table after the variant id is assigned.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today());

        // [GIVEN] A price already parked because its variant had no Shopify variant id.
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        _SpfyTaskQueue.SetWaiting(SpfyTask, _WaitingForVariantLbl, AtDateTime);

        // [WHEN] A cycle runs while the variant is still missing.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));

        // [THEN] The price keeps waiting.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Waiting, 0, 'A price whose variant is still missing must keep waiting');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A price whose variant is still missing must never reach the send boundary');

        // [WHEN] The variant reaches Shopify and the next cycle runs.
        AssignVariantID(Item."No.", '', StoreCode);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The waiting price is released and sent on a single fresh attempt.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A waiting price must be sent once its variant exists in Shopify');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The released price must be sent exactly once');
        _Assert.AreEqual(Database::"NPR Spfy Item Price", _BndMock.LastDispatchTableNo(), 'The released call must carry the item price table');
    end;

    [Test]
    procedure GivenSyncDisabledItemWithoutVariantId_WhenCycleRuns_ThenPriceDispatchesInsteadOfWaiting()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A price of a sync-disabled item is dispatched to the send boundary instead of being parked on a Shopify variant lookup.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateItem(Item);

        // [GIVEN] A started price whose variant has no Shopify id and whose item store link is sync-disabled.
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today());
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The price is dispatched instead of parked for a day on a lookup it should never have paid for.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A price of a sync-disabled item must be dispatched so the send can fail it fast, not parked on a Shopify lookup');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'A price of a sync-disabled item must reach the send boundary');
        GetTask(TaskEntryNo, SpfyTask);
        _Assert.AreEqual('', SpfyTask."Waiting Reason", 'No Shopify lookup may be attempted for a sync-disabled item');
    end;
    #endregion

    #region Price scheduling
    [Test]
    procedure GivenTwoStartDates_WhenEnqueuedWithExactReuse_ThenTwoTasks_AndSameDateMerges()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstStartDate: Date;
        SecondStartDate: Date;
    begin
        // [SCENARIO] Each distinct price start date gets its own task under exact reuse, while an identical start date is absorbed by the pending task scheduled at that date.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        // Anchored to Today: the dedup lookback floor is midnight of the previous REAL day, and the container work date differs from the real date.
        FirstStartDate := Today();
        SecondStartDate := CalcDate('<+1M>', Today());

        // [GIVEN] A price that starts today.
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, FirstStartDate);
        EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);
        _Assert.AreEqual(1, TaskCount(Database::"NPR Spfy Item Price"), 'The first price start date must create its own task');

        // [WHEN] The same price row gets a second start date.
        ItemPrice."Starting Date" := SecondStartDate;
        ItemPrice.Modify(false);
        EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [THEN] Each distinct start date keeps its own task.
        _Assert.AreEqual(2, TaskCount(Database::"NPR Spfy Item Price"), 'A second price start date must get its own task under exact reuse');

        // [WHEN] The same start date is requested again. [THEN] it merges into the pending task.
        EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);
        _Assert.AreEqual(2, TaskCount(Database::"NPR Spfy Item Price"), 'An identical start date must be absorbed by the pending task');
        _Assert.AreEqual(CreateDateTime(SecondStartDate, 0T), LastTaskNotBefore(Database::"NPR Spfy Item Price"), 'The second task must be scheduled at its own start date');
    end;

    local procedure LastTaskNotBefore(TableNo: Integer): DateTime
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        SpfyTask.FindLast();
        exit(SpfyTask."Not Before Date-Time");
    end;

    [Test]
    procedure GivenFutureStartDate_WhenCycleRunsBeforeAndAfter_ThenAttemptedOnlyAfter()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A price that only starts tomorrow is not attempted by today's cycle and is sent exactly once by the first cycle after its start date.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignVariantID(Item."No.", '', StoreCode);

        // [GIVEN] A price that only starts tomorrow.
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today() + 1);
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [WHEN] Today's cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The price is not attempted before its start date.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A price that has not started must not be attempted');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A price that has not started must never reach the send boundary');

        // [WHEN] The first cycle after the start date runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Hours(25));

        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A price must be sent by the first cycle after its start date');
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The started price must be sent exactly once');
    end;
    #endregion

    #region Vanished sources
    [Test]
    procedure GivenDeletedInventoryLevelRow_WhenCycleRuns_ThenCompletesNoLongerApplicable()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A level task whose level row was deleted is closed as no longer applicable, with that reason recorded and no send attempted.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [GIVEN] The level row is gone before the cycle reaches its task.
        InventoryLevel.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The task is closed as no longer applicable instead of being sent or retried.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A level task whose level row is gone must be closed');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'The level task must record why it is no longer applicable');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A vanished level must never reach the send boundary');
    end;

    [Test]
    procedure GivenDeletedItemPriceRow_WhenCycleRuns_ThenCompletesNoLongerApplicable()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A price task whose price row was deleted is closed as no longer applicable, with that reason recorded and no send attempted.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreatePriceStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today());
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, AtDateTime);

        // [GIVEN] The price row is gone before the cycle reaches its task.
        ItemPrice.Delete(false);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The task is closed as no longer applicable instead of burning a retry.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A price task whose price row is gone must be closed');
        _Assert.AreEqual(_SourceGoneLbl, ResponseText(TaskEntryNo), 'The price task must record why it is no longer applicable');
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'A vanished price must never reach the send boundary');
    end;
    #endregion

    #region Retry ladder
    [Test]
    procedure GivenFailingInventoryLevelBatch_WhenThreeCyclesRun_ThenQuarantined()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        DispatchesBeforeQuarantine: Integer;
        FailureText: Text;
    begin
        // [SCENARIO] An inventory level whose send keeps failing stays Pending through two attempts, is quarantined on the third with the last error visible, and is never selected again.
        Initialize();
        AtDateTime := CurrentDateTime();
        FailureText := 'throttled';
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(Item."No.", '', StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", true, false);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);
        _BndMock.QueueOutcome(TaskEntryNo, false, FailureText);

        // [WHEN] The send fails three times.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A failed level must stay Pending for another attempt');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(1));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A level must still be retryable after two failures');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(2));

        // [THEN] The third failure quarantines it with the error visible, and later cycles leave it alone.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'The third failure must quarantine the level task');
        _Assert.AreEqual(FailureText, ResponseText(TaskEntryNo), 'A quarantined level must keep the last error visible');
        DispatchesBeforeQuarantine := _BndMock.DispatchCount();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(3));
        _Assert.AreEqual(DispatchesBeforeQuarantine, _BndMock.DispatchCount(), 'A quarantined level must not be selected again');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A quarantined level must stay quarantined');
    end;

    [Test]
    procedure GivenSyncDisabledItemInLevelBatch_WhenCycleRuns_ThenItFailsAloneAndGroupMatesUnaffected()
    var
        BadItem: Record Item;
        GoodItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        BadTask: BigInteger;
        GoodTask: BigInteger;
    begin
        // [SCENARIO] A level whose item is sync-disabled fails alone with the real cause named in its response while its healthy group-mate still completes.
        Initialize();
        DropSendBoundaryMock();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [GIVEN] A level task whose item's store link is sync-disabled (set directly - Validate would raise the delete-capture outbox).
        _Lib.CreateSyncedItemWithLink(BadItem, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(BadItem."No.", '', StoreCode);
        SeedInventoryLevel(InventoryLevel, StoreCode, BadItem."No.", ShopifyLocationId, 3);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, BadItem."No.", true, false);
        BadTask := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);
        SpfyStoreItemLink."Sync. to this Store" := false;
        SpfyStoreItemLink."Synchronization Is Enabled" := false;
        SpfyStoreItemLink.Modify(false);

        // [GIVEN] A healthy group-mate whose location has auto-activation disabled, so it completes without any HTTP call.
        _Lib.CreateSyncedItemWithLink(GoodItem, SpfyStoreItemLink, StoreCode);
        AssignInventoryItemID(GoodItem."No.", '', StoreCode);
        SeedInventoryLevel(InventoryLevel, StoreCode, GoodItem."No.", ShopifyLocationId, 5);
        SeedLocationInvItem(StoreCode, ShopifyLocationId, GoodItem."No.", false, true);
        GoodTask := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, AtDateTime);

        // [WHEN] The cycle dispatches the group through the production boundary.
        Commit();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The unsyncable task fails alone with its own reason; the group-mate is untouched by it.
        AssertTask(BadTask, "NPR Spfy Task State"::Pending, 1, 'The sync-disabled item''s level task must fail alone');
        _Assert.IsTrue(StrPos(ResponseText(BadTask), 'integration is not enabled') > 0, StrSubstNo('The failure must name the real cause, got: %1', ResponseText(BadTask)));
        AssertTask(GoodTask, "NPR Spfy Task State"::Completed, 1, 'A healthy group-mate must complete despite the unsyncable sibling');
    end;

    [Test]
    procedure GivenProductLookupFailsForAnItemInVariantBatch_WhenCycleRuns_ThenAllItsRowsFailTogetherAndGroupMatesProceed()
    var
        BadItem: Record Item;
        GoodItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemVariant: Record "Item Variant";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstBadTask: BigInteger;
        SecondBadTask: BigInteger;
        GoodTask: BigInteger;
    begin
        // [SCENARIO] A failed Shopify product lookup charges every variant row of that item in the same cycle with the same reason, and the group-mate behind it is still processed in that cycle.
        Initialize();
        DropSendBoundaryMock();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();

        // [GIVEN] Two variant removals of an item with no Shopify product ID, so the send has to look the product up and the lookup fails.
        _Lib.CreateSyncedItemWithLink(BadItem, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, BadItem."No.");
        FirstBadTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);
        _Lib.CreateItemVariant(ItemVariant, BadItem."No.");
        SecondBadTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);

        // [GIVEN] A variant removal of a second item behind them in the same group, whose store link is sync-disabled.
        _Lib.CreateItem(GoodItem);
        _Lib.CreateItemLink(SpfyStoreItemLink, GoodItem."No.", StoreCode, false, false);
        _Lib.CreateItemVariant(ItemVariant, GoodItem."No.");
        GoodTask := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);

        // [WHEN] The cycle dispatches the variant group through the production boundary.
        Commit();
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Both rows of the item whose lookup failed are charged one attempt and carry the same reason.
        AssertTask(FirstBadTask, "NPR Spfy Task State"::Pending, 1, 'The first variant row of the item with the failed lookup must be charged');
        AssertTask(SecondBadTask, "NPR Spfy Task State"::Pending, 1, 'The second variant row of the item with the failed lookup must be charged in the same cycle');
        _Assert.IsTrue(ResponseText(FirstBadTask) <> '', 'The failed lookup must leave its reason on the first variant row');
        _Assert.AreEqual(ResponseText(FirstBadTask), ResponseText(SecondBadTask), 'Every variant row of the item must carry the same lookup failure');

        // [THEN] The group-mate behind the failed item is dispatched in the same cycle and fails with its own reason.
        AssertTask(GoodTask, "NPR Spfy Task State"::Pending, 1, 'A group-mate behind the item with the failed lookup must still be processed in the same cycle');
        _Assert.IsTrue(StrPos(ResponseText(GoodTask), 'integration is not enabled') > 0, StrSubstNo('The group-mate must fail with its own reason, got: %1', ResponseText(GoodTask)));
    end;
    #endregion

    #region Production boundary map
    [Test]
    procedure ProductionBoundaryRoutesPhase2KindsToTheItemsSibling()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] The production send boundary routes inventory level, item price and location activation work to the items and inventory send codeunit rather than to the unmapped branch.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [WHEN] The production boundary is handed an empty inventory level group.
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        TempSpfyTaskWork."Table No." := Database::"NPR Spfy Inventory Level";
        TempSpfyTaskWork."Store Code" := StoreCode;

        // [THEN] It reaches the items and inventory send codeunit rather than the unmapped branch.
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('An inventory level group must be routed to a send codeunit: %1', ErrorText));

        // [WHEN] The production boundary is handed an empty price group.
        Commit();
        Clear(TempSpfyTaskWork);
        TempSpfyTaskWork."Table No." := Database::"NPR Spfy Item Price";
        TempSpfyTaskWork."Store Code" := StoreCode;

        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A price group must be routed to a send codeunit: %1', ErrorText));

        // [GIVEN] An activation task whose location record was deleted after it was queued.
        SeedLocationInvItem(StoreCode, ShopifyLocationId, Item."No.", false, false);
        GetLocationInvItem(LocationInvItem, StoreCode, ShopifyLocationId, Item."No.");
        TaskEntryNo := EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);
        LocationInvItem.Delete(false);
        GetTask(TaskEntryNo, SpfyTask);
        Commit();

        // [WHEN] The production boundary is handed that activation task.
        // [THEN] It fails inside the send codeunit, which proves the dispatch reached it rather than the unmapped branch.
        _Assert.IsFalse(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText), 'An activation task whose location is gone must fail inside the send codeunit');
        _Assert.IsTrue(StrPos(ErrorText, _UnmappedKindTok) = 0, StrSubstNo('An activation task must be mapped to a send codeunit, but the boundary reported: %1', ErrorText));
    end;

    [Test]
    procedure GivenActivationPrepareFails_WhenDispatchedForReal_ThenLocationNotMarkedActivated()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] An activation whose request preparation is skipped completes the call gracefully but leaves the location unmarked, because no request was ever sent.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        ItemVariant.Blocked := true;
        ItemVariant.Modify(false);

        // [GIVEN] An activation task whose request preparation cannot succeed: its variant is blocked.
        LocationInvItem.Init();
        LocationInvItem."Shopify Store Code" := StoreCode;
        LocationInvItem."Shopify Location ID" := ShopifyLocationId;
        LocationInvItem."Item No." := Item."No.";
        LocationInvItem."Variant Code" := ItemVariant.Code;
        LocationInvItem.Insert(false);
        TaskEntryNo := EnqueueActivationTask(StoreCode, LocationInvItem, AtDateTime);
        GetTask(TaskEntryNo, SpfyTask);
        Commit();

        // [WHEN] The task is dispatched through the production boundary, so the real send code runs and skips the request.
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(SpfyTask, ErrorText), StrSubstNo('A skipped activation preparation must complete the call gracefully: %1', ErrorText));

        // [THEN] The location is not marked as activated in Shopify: no request was ever sent.
        LocationInvItem.Get(StoreCode, ShopifyLocationId, Item."No.", ItemVariant.Code);
        _Assert.IsFalse(LocationInvItem.Activated, 'A location whose activation request was never sent must not be marked Activated');
    end;

    [Test]
    procedure GivenExpiredRunDeadline_WhenVariantGroupIsDispatched_ThenNoRowIsPreparedOrCharged()
    var
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A variant group handed to the send codeunit after the run budget is spent stops before the next request preparation and leaves the rows it never reached for the following cycle.
        Initialize();
        StoreCode := CreateInventoryStore();

        // [GIVEN] A variant removal whose preparation would charge the row with its own reason the moment the walk reaches it.
        TaskEntryNo := SeedVariantDeleteOfSyncDisabledItem(StoreCode, TempSpfyTaskWork);

        // [GIVEN] A run whose deadline has already passed.
        SpfyTaskRunContext.SetRunDeadline(CurrentDateTime() - Minutes(1));

        // [WHEN] The group is dispatched through the production boundary.
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A walk stopped by the run deadline must not fail the dispatch: %1', ErrorText));

        // [THEN] The unreached row is left exactly as the cycle found it: pending, unattempted and without a response.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A row the expired run never prepared must not be charged an attempt');
        _Assert.AreEqual('', ResponseText(TaskEntryNo), 'A row the expired run never prepared must carry no response');
    end;

    [Test]
    procedure GivenNoRunDeadline_WhenVariantGroupIsDispatched_ThenTheWalkStillPreparesItsRows()
    var
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A variant group dispatched outside a deadline-bounded run is prepared as before, because an unset deadline never reads as expired.
        Initialize();
        StoreCode := CreateInventoryStore();

        // [GIVEN] The same variant removal, dispatched with no run deadline set at all.
        TaskEntryNo := SeedVariantDeleteOfSyncDisabledItem(StoreCode, TempSpfyTaskWork);

        // [WHEN] The group is dispatched through the production boundary.
        Commit();
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A dispatch outside a deadline-bounded run must not fail: %1', ErrorText));

        // [THEN] The walk ran: the row is charged one attempt and carries the preparation's own reason.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A dispatch without a run deadline must still prepare and charge its rows');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), 'integration is not enabled') > 0, StrSubstNo('The prepared row must carry its own reason, got: %1', ResponseText(TaskEntryNo)));
    end;

    [Test]
    procedure GivenVariantRowsThatAllFail_WhenTheRunBudgetIsSpent_ThenTheWalkStopsAfterFiftyRows()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        VariantIndex: Integer;
        LastTaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A variant group whose rows all fail hands control back to the caller after fifty rows, so a run budget spent meanwhile leaves the rows behind them for the next cycle.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := CreateInventoryStore();

        // [GIVEN] One item with fifty-one variant rows that all take the failing path: its store link is sync-disabled, so not one row of the item can be prepared.
        _Lib.CreateItem(Item);
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        for VariantIndex := 1 to 51 do begin
            _Lib.CreateItemVariant(ItemVariant, Item."No.");
            LastTaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, AtDateTime);
            GetTask(LastTaskEntryNo, SpfyTask);
            TempSpfyTaskWork := SpfyTask;
            TempSpfyTaskWork.Insert();
        end;

        // [GIVEN] A run whose budget is spent the moment it writes its first row outcome.
        _BndMock.SetExpireRunDeadlineOnTaskWrite(true);

        // [WHEN] The group is dispatched through the production boundary.
        // A direct dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A walk stopped by the run deadline must not fail the dispatch: %1', ErrorText));
        _BndMock.SetExpireRunDeadlineOnTaskWrite(false);

        // [THEN] Only the fifty rows of the first preparation were charged: the walk handed control back before the spent budget stopped the run.
        SpfyTask.SetRange("Table No.", Database::"Item Variant");
        SpfyTask.SetFilter(Attempts, '>%1', 0);
        _Assert.AreEqual(50, SpfyTask.Count(), 'A request preparation whose rows all fail must still hand control back after 50 rows instead of walking the whole item');

        // [THEN] The row behind those fifty is left exactly as the cycle found it.
        AssertTask(LastTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A row the stopped run never prepared must not be charged an attempt');
        _Assert.AreEqual('', ResponseText(LastTaskEntryNo), 'A row the stopped run never prepared must carry no response');
    end;

    [Test]
    procedure GivenExpiredRunDeadline_WhenInventoryLevelGroupIsDispatched_ThenNoRowIsPreparedOrCharged()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] An inventory level group handed to the send codeunit after the run budget is spent stops before the next request preparation and leaves the rows it never reached for the following cycle.
        Initialize();
        StoreCode := CreateInventoryStore();
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [GIVEN] A level whose preparation would charge the row with its own reason the moment the walk reaches it: its item store link is sync-disabled.
        _Lib.CreateItem(Item);
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        SeedInventoryLevel(InventoryLevel, StoreCode, Item."No.", ShopifyLocationId, 3);
        TaskEntryNo := EnqueueInventoryLevelTask(StoreCode, InventoryLevel, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);
        TempSpfyTaskWork := SpfyTask;
        TempSpfyTaskWork.Insert();

        // [GIVEN] A run whose deadline has already passed.
        SpfyTaskRunContext.SetRunDeadline(CurrentDateTime() - Minutes(1));

        // [WHEN] The group is dispatched through the production boundary.
        Commit();
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A level walk stopped by the run deadline must not fail the dispatch: %1', ErrorText));

        // [THEN] The unreached row is left exactly as the cycle found it: pending, unattempted and without a response.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A level row the expired run never prepared must not be charged an attempt');
        _Assert.AreEqual('', ResponseText(TaskEntryNo), 'A level row the expired run never prepared must carry no response');
    end;

    [Test]
    procedure GivenExpiredRunDeadline_WhenItemPriceGroupIsDispatched_ThenNoRowIsPreparedOrCharged()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        SpfyTask: Record "NPR Spfy Task";
        TempSpfyTaskWork: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        SpfyTaskSendBndImpl: Codeunit "NPR Spfy Task Send Bnd Impl";
        StoreCode: Code[20];
        TaskEntryNo: BigInteger;
        ErrorText: Text;
    begin
        // [SCENARIO] A price group handed to the send codeunit after the run budget is spent stops before the next request preparation and leaves the rows it never reached for the following cycle.
        Initialize();
        StoreCode := CreatePriceStore();

        // [GIVEN] A started price whose preparation would charge the row with its own reason the moment the walk reaches it: its item store link is sync-disabled.
        _Lib.CreateItem(Item);
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, Today());
        TaskEntryNo := EnqueueItemPriceTask(StoreCode, ItemPrice, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);
        TempSpfyTaskWork := SpfyTask;
        TempSpfyTaskWork.Insert();

        // [GIVEN] A run whose deadline has already passed.
        SpfyTaskRunContext.SetRunDeadline(CurrentDateTime() - Minutes(1));

        // [WHEN] The group is dispatched through the production boundary.
        Commit();
        _Assert.IsTrue(SpfyTaskSendBndImpl.Dispatch(TempSpfyTaskWork, ErrorText), StrSubstNo('A price walk stopped by the run deadline must not fail the dispatch: %1', ErrorText));

        // [THEN] The unreached row is left exactly as the cycle found it: pending, unattempted and without a response.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A price row the expired run never prepared must not be charged an attempt');
        _Assert.AreEqual('', ResponseText(TaskEntryNo), 'A price row the expired run never prepared must carry no response');
    end;

    local procedure SeedVariantDeleteOfSyncDisabledItem(StoreCode: Code[20]; var TempSpfyTaskWork: Record "NPR Spfy Task" temporary): BigInteger
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTask: Record "NPR Spfy Task";
        TaskEntryNo: BigInteger;
    begin
        // A sync-disabled link makes the preparation charge the row without any Shopify call, so whether the walk reached it is visible on the row itself.
        _Lib.CreateItem(Item);
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, false, false);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        TaskEntryNo := EnqueueVariantTask(StoreCode, ItemVariant, "NPR Spfy Task Op"::Delete, CurrentDateTime());
        GetTask(TaskEntryNo, SpfyTask);
        TempSpfyTaskWork := SpfyTask;
        TempSpfyTaskWork.Insert();
        exit(TaskEntryNo);
    end;
    #endregion
    #region A gone inventory item resets the location activation cache
    [Test]
    procedure GivenActivatedLocations_WhenVariantDeleteResetsThem_ThenOnlyThatVariantsRowsGo()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyTaskSendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
    begin
        // [SCENARIO] A completed variant delete clears every location activation row of that variant in that store, sparing a pending activation, the item-level row and the same variant in another store.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        OtherStoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        // [GIVEN] The variant is activated at two locations, one of them merchant-deactivated.
        SeedVariantLocationInvItem(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code, true, false);
        SeedVariantLocationInvItem(StoreCode, 'LOC-2', Item."No.", ItemVariant.Code, false, true);
        // [GIVEN] Rows the reset must NOT touch: a pending activation (it may already be the re-created variant's), the item-level row, and the same variant in another store.
        SeedVariantLocationInvItem(StoreCode, 'LOC-3', Item."No.", ItemVariant.Code, false, false);
        SeedVariantLocationInvItem(StoreCode, 'LOC-1', Item."No.", '', true, false);
        SeedVariantLocationInvItem(OtherStoreCode, 'LOC-1', Item."No.", ItemVariant.Code, true, false);

        // [WHEN] The variant's delete completed in this store: its inventory item is gone, so the activations are stale.
        VariantLink(SpfyStoreItemVariantLink, Item."No.", ItemVariant.Code, StoreCode);
        SpfyTaskSendItemsInv.ClearLocationActivations(SpfyStoreItemVariantLink);

        // [THEN] Every location row of that variant in that store is gone; the others stay.
        _Assert.IsFalse(LocationInvItem.Get(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code), 'The activated location row must be removed so the re-created variant activates again');
        _Assert.IsFalse(LocationInvItem.Get(StoreCode, 'LOC-2', Item."No.", ItemVariant.Code), 'A merchant-deactivated location row must be removed too: the inventory item it described no longer exists');
        _Assert.IsTrue(LocationInvItem.Get(StoreCode, 'LOC-3', Item."No.", ItemVariant.Code), 'A pending activation row must survive: it carries no state of the old inventory item');
        _Assert.IsTrue(LocationInvItem.Get(StoreCode, 'LOC-1', Item."No.", ''), 'The item-level location row must be left alone');
        _Assert.IsTrue(LocationInvItem.Get(OtherStoreCode, 'LOC-1', Item."No.", ItemVariant.Code), 'The same variant in another store must be left alone');
    end;

    [Test]
    procedure GivenActivatedLocations_WhenProductDeleteResetsThem_ThenTheItemsStaleRowsInThatStoreGo()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTaskSendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
    begin
        // [SCENARIO] A completed product delete clears the stale location activation rows of every variant of that item in that store, sparing a pending activation and another store.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        OtherStoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        SeedVariantLocationInvItem(StoreCode, 'LOC-1', Item."No.", '', true, false);
        SeedVariantLocationInvItem(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code, false, true);
        SeedVariantLocationInvItem(StoreCode, 'LOC-2', Item."No.", ItemVariant.Code, false, false);
        SeedVariantLocationInvItem(OtherStoreCode, 'LOC-1', Item."No.", ItemVariant.Code, true, false);

        // [WHEN] The product's delete completed in this store (item-type link => every variant, the blank one included).
        SpfyTaskSendItemsInv.ClearLocationActivations(SpfyStoreItemLink);

        _Assert.IsFalse(LocationInvItem.Get(StoreCode, 'LOC-1', Item."No.", ''), 'The blank-variant location row must go with the product');
        _Assert.IsFalse(LocationInvItem.Get(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code), 'Every variant location row must go with the product');
        _Assert.IsTrue(LocationInvItem.Get(StoreCode, 'LOC-2', Item."No.", ItemVariant.Code), 'A pending activation row must survive the product delete too');
        _Assert.IsTrue(LocationInvItem.Get(OtherStoreCode, 'LOC-1', Item."No.", ItemVariant.Code), 'Another store is untouched');
    end;

    [Test]
    procedure GivenActivatedLocation_WhenOnlyVariantIdsAreCleared_ThenTheCacheSurvives()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyTaskSendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Clearing a variant's Shopify ids on a live product removes the ids but keeps the location activation cache and the merchant's deactivation.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        // [GIVEN] A merchant deactivated this variant at a location of a product that still exists in Shopify.
        SeedVariantLocationInvItem(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code, false, true);
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), "NPR Spfy ID Type"::"Entry ID", 'gid://var/1', false);
        AssignInventoryItemID(Item."No.", ItemVariant.Code, StoreCode);

        // [WHEN] Update Sync. Status re-maps the ids: it clears them without a delete.
        VariantLink(SpfyStoreItemVariantLink, Item."No.", ItemVariant.Code, StoreCode);
        SpfyTaskSendItemsInv.ClearVariantShopifyIDs(SpfyStoreItemVariantLink);

        // [THEN] The ids are gone but the merchant's deactivation is kept: the inventory item still exists.
        _Assert.AreEqual('', SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID"), 'The inventory item id must be cleared');
        _Assert.IsTrue(LocationInvItem.Get(StoreCode, 'LOC-1', Item."No.", ItemVariant.Code), 'Clearing ids on a live product must not touch the activation cache');
        _Assert.IsTrue(LocationInvItem."Auto-Activation Disabled", 'The merchant deactivation must survive an id re-map');
    end;

    local procedure VariantLink(var SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link"; ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := StoreCode;
    end;

    local procedure SeedVariantLocationInvItem(StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20]; VariantCode: Code[10]; Activated: Boolean; AutoActivationDisabled: Boolean)
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        LocationInvItem.Init();
        LocationInvItem."Shopify Store Code" := StoreCode;
        LocationInvItem."Shopify Location ID" := ShopifyLocationId;
        LocationInvItem."Item No." := ItemNo;
        LocationInvItem."Variant Code" := VariantCode;
        LocationInvItem.Activated := Activated;
        LocationInvItem."Auto-Activation Disabled" := AutoActivationDisabled;
        LocationInvItem.Insert(false);
    end;
    #endregion
}
