codeunit 85315 "NPR Spfy TL Switch Tests"
{
    // [FEATURE] Shopify Task List - the destination fence: which queue a change lands in, and that it never lands in both
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _ReactivationCancelLbl: Label 'Cancelled: the entity was reactivated in Business Central before the delete was sent to Shopify.', Locked = true;

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
    end;

    local procedure NcTaskCount(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        exit(NcTask.Count());
    end;

    local procedure NcTaskCount(TableNo: Integer): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        exit(NcTask.Count());
    end;

    local procedure SpfyTaskCount(): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        exit(SpfyTask.Count());
    end;

    local procedure SpfyTaskCount(TableNo: Integer): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.Count());
    end;

    local procedure FindNcTask(TableNo: Integer; var NcTask: Record "NPR Nc Task"): Boolean
    begin
        NcTask.Reset();
        NcTask.SetRange("Table No.", TableNo);
        exit(NcTask.FindLast());
    end;

    local procedure AssertNcIntent(TableNo: Integer; ExpectedType: Option; ExpectedRecId: RecordId; ExpectedRecordValue: Text; ExpectedStoreCode: Code[20]; SeamName: Text)
    var
        NcTask: Record "NPR Nc Task";
    begin
        _Assert.IsTrue(FindNcTask(TableNo, NcTask), StrSubstNo('%1: the legacy queue must hold the task', SeamName));
        _Assert.IsTrue(NcTask.Type = ExpectedType, StrSubstNo('%1: expected task type %2 but found %3', SeamName, ExpectedType, NcTask.Type));
        _Assert.AreEqual(TableNo, NcTask."Table No.", StrSubstNo('%1: source table', SeamName));
        _Assert.AreEqual(ExpectedRecId, NcTask."Record ID", StrSubstNo('%1: source record id', SeamName));
        _Assert.AreEqual(ExpectedRecordValue, NcTask."Record Value", StrSubstNo('%1: record value', SeamName));
        _Assert.AreEqual(ExpectedStoreCode, NcTask."Store Code", StrSubstNo('%1: store code', SeamName));
        _Assert.AreEqual(0DT, NcTask."Not Before Date-Time", StrSubstNo('%1: an unscheduled seam must leave the not-before time blank', SeamName));
        _Assert.AreNotEqual(0DT, NcTask."Log Date", StrSubstNo('%1: the log date must be stamped', SeamName));
        _Assert.IsFalse(NcTask.Processed, StrSubstNo('%1: a fresh task must be unprocessed', SeamName));
    end;

    local procedure FindSpfyTask(TableNo: Integer; var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.Reset();
        SpfyTask.SetRange("Table No.", TableNo);
        exit(SpfyTask.FindLast());
    end;

    local procedure AssertSpfyIntent(TableNo: Integer; ExpectedType: Enum "NPR Spfy Task Op"; ExpectedRecId: RecordId; ExpectedRecordValue: Text; ExpectedStoreCode: Code[20]; SeamName: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _Assert.IsTrue(FindSpfyTask(TableNo, SpfyTask), StrSubstNo('%1: the new queue must hold the task', SeamName));
        _Assert.IsTrue(SpfyTask.Type = ExpectedType, StrSubstNo('%1: expected task type %2 but found %3', SeamName, ExpectedType, SpfyTask.Type));
        _Assert.AreEqual(TableNo, SpfyTask."Table No.", StrSubstNo('%1: source table', SeamName));
        _Assert.AreEqual(ExpectedRecId, SpfyTask."Record ID", StrSubstNo('%1: source record id', SeamName));
        _Assert.AreEqual(ExpectedRecordValue, SpfyTask."Record Value", StrSubstNo('%1: record value', SeamName));
        _Assert.AreEqual(ExpectedStoreCode, SpfyTask."Store Code", StrSubstNo('%1: store code', SeamName));
        _Assert.AreEqual(0DT, SpfyTask."Not Before Date-Time", StrSubstNo('%1: an unscheduled seam must leave the not-before time blank', SeamName));
        _Assert.AreNotEqual(0DT, SpfyTask."Log Date", StrSubstNo('%1: the log date must be stamped', SeamName));
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, StrSubstNo('%1: a fresh task must be waiting to be sent', SeamName));
    end;

    local procedure PseudoInventoryBufferRecordId(ItemNo: Code[20]): RecordId
    var
        InventoryBuffer: Record "Inventory Buffer";
    begin
        // The cost seam deliberately keys its task on an uninserted buffer row, so the expected id has to be built the same way.
        InventoryBuffer."Item No." := ItemNo;
        exit(InventoryBuffer.RecordId());
    end;

    local procedure CreateItemWithCost(var Item: Record Item; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; StoreCode: Code[20]; LastDirectCost: Decimal)
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Last Direct Cost" := LastDirectCost;
        Item.Modify(false);
    end;

    local procedure CreateItemWithCategory(var Item: Record Item; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; StoreCode: Code[20]; CategoryDescription: Text[100])
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Item Category Code" := _Lib.CreateItemCategory(CategoryDescription);
        Item.Modify(false);
    end;

    local procedure EnqueueThroughRouter(StoreCode: Code[20]; Item: Record Item; TaskType: Option; LogDateTime: DateTime; NotBeforeDateTime: DateTime; ReuseExistingDelayed: Enum "NPR Spfy Reuse Delayed NC Task"; var NcTask: Record "NPR Nc Task"): Boolean
    var
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        exit(SpfyScheduleSend.InitNcTask(StoreCode, RecRef, Item.RecordId(), Item."No.", TaskType, LogDateTime, NotBeforeDateTime, ReuseExistingDelayed, NcTask));
    end;

    local procedure EnqueueThroughConvenienceOverload(StoreCode: Code[20]; Item: Record Item; TaskType: Option; var NcTask: Record "NPR Nc Task"): Boolean
    var
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        exit(SpfyScheduleSend.InitNcTask(StoreCode, RecRef, Item."No.", TaskType, NcTask));
    end;

    local procedure SeedNewQueueTask(StoreCode: Code[20]; Item: Record Item): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        SpfyTaskQueue.Enqueue(StoreCode, RecRef, Item.RecordId(), Item."No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, CurrentDateTime(), SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure NewQueueTaskState(EntryNo: BigInteger): Enum "NPR Spfy Task State"
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        exit(SpfyTask.State);
    end;

    local procedure MigrationStatus(): Integer
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        exit(ShopifySetup."Task List Migration Status");
    end;

    local procedure MigrationStartedAt(): DateTime
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        exit(ShopifySetup."Task List Migr. Started At");
    end;

    #region NC Task coexistence — DELETE at NC phase-out
    [Test]
    procedure GivenFeatureOff_WhenItemChanges_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] An item change with the task list off creates one content-correct legacy product task and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [WHEN] A synced item's product payload changes while the task list is off.
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] The legacy queue holds one content-correct product task and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'One legacy product task must be created for the item change');
        AssertNcIntent(Database::Item, DummyNcTask.Type::Modify, Item.RecordId(), Item."No.", StoreCode, 'Item');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenItemChanges_ThenNoNcTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] An item change with the task list on creates one content-correct new-queue product task and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A synced item's product payload changes while the task list is on.
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] The new queue holds one content-correct product task, and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::Item), 'One new-queue product task must be created for the item change');
        AssertSpfyIntent(Database::Item, "NPR Spfy Task Op"::Modify, Item.RecordId(), Item."No.", StoreCode, 'Item');
        _Assert.AreEqual(0, NcTaskCount(), 'An item change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenItemVariantChanges_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        InsertVariant: Record "Item Variant";
        ModifyVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] With the task list off each variant change gets its own legacy task, resolving to an insert for a variant Shopify has never seen and a modify for one it knows, and nothing reaches the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(InsertVariant, Item."No.");
        _Lib.CreateItemVariant(ModifyVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ModifyVariant.Code, StoreCode), 'gid://var/known');

        // [WHEN] A variant Shopify has never seen changes.
        _Lib.DispatchModify(InsertVariant);

        // [THEN] The legacy task resolves to an Insert and carries the variant SKU and identity.
        AssertNcIntent(Database::"Item Variant", DummyNcTask.Type::Insert, InsertVariant.RecordId(), Item."No." + '_' + InsertVariant.Code, StoreCode, 'Item Variant insert');

        // [WHEN] A variant that already has a Shopify id changes.
        _Lib.DispatchModify(ModifyVariant);

        // [THEN] The legacy task resolves to a Modify for the same store.
        AssertNcIntent(Database::"Item Variant", DummyNcTask.Type::Modify, ModifyVariant.RecordId(), Item."No." + '_' + ModifyVariant.Code, StoreCode, 'Item Variant modify');
        _Assert.AreEqual(2, NcTaskCount(Database::"Item Variant"), 'Each variant must get its own legacy task');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No variant task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenItemVariantChanges_ThenNoNcTask()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A variant change with the task list on creates one new-queue task resolving to an insert for a variant Shopify has never seen, and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A variant changes while the task list is on.
        _Lib.DispatchModify(ItemVariant);

        // [THEN] The new-queue task resolves to an Insert for a variant Shopify has never seen and carries its SKU and identity.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Item Variant"), 'One new-queue variant task must be created for the variant change');
        AssertSpfyIntent(Database::"Item Variant", "NPR Spfy Task Op"::Insert, ItemVariant.RecordId(), Item."No." + '_' + ItemVariant.Code, StoreCode, 'Item Variant');
        _Assert.AreEqual(0, NcTaskCount(), 'A variant change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenCostChanges_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A cost change with the task list off creates one legacy cost task keyed on the synthetic buffer record and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateItemWithCost(Item, SpfyStoreItemLink, StoreCode, 17.5);

        // [WHEN] The item cost changes while the task list is off.
        _Lib.DispatchModify(Item);

        // [THEN] One legacy cost task keyed on the synthetic inventory buffer record id.
        _Assert.AreEqual(1, NcTaskCount(Database::"Inventory Buffer"), 'One legacy cost task must be created for the cost change');
        AssertNcIntent(Database::"Inventory Buffer", DummyNcTask.Type::Modify, PseudoInventoryBufferRecordId(Item."No."), Item."No.", StoreCode, 'Inventory Buffer cost');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No cost task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenCostChanges_ThenNoNcTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A cost change with the task list on creates one new-queue cost task keyed on the synthetic buffer record and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateItemWithCost(Item, SpfyStoreItemLink, StoreCode, 17.5);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] The item cost changes while the task list is on.
        _Lib.DispatchModify(Item);

        // [THEN] One new-queue cost task keyed on the synthetic inventory buffer record id.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Inventory Buffer"), 'One new-queue cost task must be created for the cost change');
        AssertSpfyIntent(Database::"Inventory Buffer", "NPR Spfy Task Op"::Modify, PseudoInventoryBufferRecordId(Item."No."), Item."No.", StoreCode, 'Inventory Buffer cost');
        _Assert.AreEqual(0, NcTaskCount(), 'A cost change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenCategoryChanges_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A category change with the task list off creates one legacy tags task keyed on the store-item link, and a further change reuses it instead of duplicating it.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateItemWithCategory(Item, SpfyStoreItemLink, StoreCode, 'Switch fence category');

        // [WHEN] The item category changes while the task list is off.
        _Lib.DispatchModify(Item);

        // [THEN] One legacy tags task keyed on the store-item link, not on the tag request itself.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Tag Update Request"), 'One legacy tags task must be created for the category change');
        AssertNcIntent(Database::"NPR Spfy Tag Update Request", DummyNcTask.Type::Modify, SpfyStoreItemLink.RecordId(), Item."No.", StoreCode, 'Tag Update Request');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No tags task may be created in the new queue while the feature is off');

        // [WHEN] The category changes again while the first tags task is still unprocessed.
        Item."Item Category Code" := _Lib.CreateItemCategory('Switch fence category two');
        Item.Modify(false);
        _Lib.DispatchModify(Item);

        // [THEN] The pending legacy task is reused, not duplicated.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Tag Update Request"), 'A second category change must reuse the unprocessed legacy tags task');
    end;

    [Test]
    procedure GivenFeatureOn_WhenCategoryChanges_ThenNoNcTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A category change with the task list on creates one new-queue tags task keyed on the store-item link and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateItemWithCategory(Item, SpfyStoreItemLink, StoreCode, 'Switch fence category on');
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] The item category changes while the task list is on.
        _Lib.DispatchModify(Item);

        // [THEN] One new-queue tags task keyed on the store-item link, not on the tag request itself.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Spfy Tag Update Request"), 'One new-queue tags task must be created for the category change');
        AssertSpfyIntent(Database::"NPR Spfy Tag Update Request", "NPR Spfy Task Op"::Modify, SpfyStoreItemLink.RecordId(), Item."No.", StoreCode, 'Tag Update Request');
        _Assert.AreEqual(0, NcTaskCount(), 'A category change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenSeamSchedulesExplicitly_ThenLegacyTaskKeepsScheduleAndReuseRules()
    var
        ExactItem: Record Item;
        LaterItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        LogDateTime: DateTime;
        NotBeforeDateTime: DateTime;
    begin
        // [SCENARIO] An explicitly scheduled update with the task list off keeps its op, log date and start time in the legacy queue, follows the exact and later reuse rules, and never reaches the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(ExactItem, SpfyStoreItemLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(LaterItem, SpfyStoreItemLink, StoreCode);
        // Anchored to Today: the legacy dedup lookback floor is midnight of the previous REAL day, and the container work date differs from the real date.
        LogDateTime := CreateDateTime(Today(), 080000T);
        NotBeforeDateTime := CreateDateTime(Today() + 1, 220000T);

        // [WHEN] A seam schedules an update for a specific time with exact reuse.
        _Assert.IsTrue(EnqueueThroughRouter(StoreCode, ExactItem, NcTask.Type::Insert, LogDateTime, NotBeforeDateTime, "NPR Spfy Reuse Delayed NC Task"::No, NcTask), 'The explicitly scheduled update must create a legacy task');

        // [THEN] The legacy row keeps the requested op, log date and start time verbatim.
        _Assert.IsTrue(FindNcTask(Database::Item, NcTask), 'The explicitly scheduled legacy task must exist');
        _Assert.AreEqual(NcTask.Type::Insert, NcTask.Type, 'The requested op must be preserved');
        _Assert.AreEqual(LogDateTime, NcTask."Log Date", 'The explicit log date must be preserved');
        _Assert.AreEqual(NotBeforeDateTime, NcTask."Not Before Date-Time", 'The explicit not-before time must be preserved');

        // [WHEN] The same time is requested again under exact reuse. [THEN] the existing task is reused.
        _Assert.IsFalse(EnqueueThroughRouter(StoreCode, ExactItem, NcTask.Type::Insert, LogDateTime, NotBeforeDateTime, "NPR Spfy Reuse Delayed NC Task"::No, NcTask), 'An identical start time must be absorbed under exact reuse');
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'Exact reuse must not duplicate the legacy task');

        // [WHEN] A different start time is requested for the same entity under exact reuse.
        _Assert.IsTrue(EnqueueThroughRouter(StoreCode, ExactItem, NcTask.Type::Insert, LogDateTime, NotBeforeDateTime + 1000, "NPR Spfy Reuse Delayed NC Task"::No, NcTask), 'A different start time must create its own legacy task under exact reuse');
        _Assert.AreEqual(2, NcTaskCount(Database::Item), 'Exact reuse must key on the start time');

        // [WHEN] An earlier start time meets a later queued task under later-reuse.
        _Assert.IsTrue(EnqueueThroughRouter(StoreCode, LaterItem, NcTask.Type::Modify, 0DT, NotBeforeDateTime, "NPR Spfy Reuse Delayed NC Task"::Later, NcTask), 'The first later-reuse request must create a legacy task');
        _Assert.IsFalse(EnqueueThroughRouter(StoreCode, LaterItem, NcTask.Type::Modify, 0DT, NotBeforeDateTime - 1000, "NPR Spfy Reuse Delayed NC Task"::Later, NcTask), 'A task queued for a later time must absorb an earlier request');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No explicitly scheduled task may reach the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOffAndOn_WhenSeamEnqueues_ThenReturnDtoMirrorsCreatedRow()
    var
        LegacyItem: Record Item;
        NewQueueItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        PersistedNcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The record an enqueue hands back mirrors the row it persisted, in whichever queue the task list setting sent it to.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(LegacyItem, SpfyStoreItemLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(NewQueueItem, SpfyStoreItemLink, StoreCode);

        // [WHEN] The convenience overload enqueues while the task list is off.
        _Assert.IsTrue(EnqueueThroughConvenienceOverload(StoreCode, LegacyItem, NcTask.Type::Modify, NcTask), 'The legacy enqueue must create a task');

        // [THEN] The returned record mirrors the persisted legacy row field for field.
        _Assert.IsTrue(PersistedNcTask.Get(NcTask."Entry No."), 'The returned entry number must identify the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask.Type, NcTask.Type, 'The returned op must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Table No.", NcTask."Table No.", 'The returned source table must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Record ID", NcTask."Record ID", 'The returned record id must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Record Value", NcTask."Record Value", 'The returned record value must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Store Code", NcTask."Store Code", 'The returned store code must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Log Date", NcTask."Log Date", 'The returned log date must match the persisted legacy row');
        _Assert.AreEqual(PersistedNcTask."Not Before Date-Time", NcTask."Not Before Date-Time", 'The returned not-before time must match the persisted legacy row');

        // [WHEN] The same overload enqueues while the task list is on.
        _Lib.SetTaskListFeatureEnabled(true);
        _Assert.IsTrue(EnqueueThroughConvenienceOverload(StoreCode, NewQueueItem, NcTask.Type::Modify, NcTask), 'The new-queue enqueue must create a task');

        // [THEN] The same return record mirrors the new-queue row instead.
        _Assert.IsTrue(SpfyTask.Get(NcTask."Entry No."), 'The returned entry number must identify the persisted new-queue row');
        _Assert.IsTrue(NcTask.Type = SpfyTask.Type.AsInteger(), 'The returned op must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Table No.", NcTask."Table No.", 'The returned source table must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Record ID", NcTask."Record ID", 'The returned record id must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Record Value", NcTask."Record Value", 'The returned record value must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Store Code", NcTask."Store Code", 'The returned store code must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Log Date", NcTask."Log Date", 'The returned log date must match the new-queue row');
        _Assert.AreEqual(SpfyTask."Not Before Date-Time", NcTask."Not Before Date-Time", 'The returned not-before time must match the new-queue row');
    end;

    [Test]
    procedure GivenLegacyRowsExist_WhenFeatureOnEnqueues_ThenReturnedEntryNoIsQueueRelative()
    var
        LegacyItem: Record Item;
        NewQueueItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] With rows in both queues the entry number handed back resolves only in the queue that created it, and the entity enqueued with the task list on gets no legacy row at all.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(LegacyItem, SpfyStoreItemLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(NewQueueItem, SpfyStoreItemLink, StoreCode);

        // [GIVEN] The legacy queue already holds rows, so entry numbers exist in both tables.
        _Assert.IsTrue(EnqueueThroughConvenienceOverload(StoreCode, LegacyItem, NcTask.Type::Modify, NcTask), 'The legacy queue must be seeded');

        // [WHEN] The same seam enqueues once the task list is on.
        _Lib.SetTaskListFeatureEnabled(true);
        _Assert.IsTrue(EnqueueThroughConvenienceOverload(StoreCode, NewQueueItem, NcTask.Type::Modify, NcTask), 'The new-queue enqueue must create a task');

        // [THEN] The returned number is only meaningful in the queue that created it.
        _Assert.IsTrue(SpfyTask.Get(NcTask."Entry No."), 'The returned entry number must resolve in the new queue');
        _Assert.AreEqual(NewQueueItem."No.", SpfyTask."Record Value", 'The returned entry number must resolve to the entity that was enqueued');
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'The new-queue enqueue must not add a legacy row');
        _Assert.AreEqual(0, NcTaskCount(Database::Item, NewQueueItem."No."), 'The entity enqueued in the new queue must have no legacy row at all');
    end;

    [Test]
    procedure GivenFeatureOff_WhenDeleteDrains_ThenNcProvenanceStampedAlone()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
        NcTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A delete draining with the task list off creates a content-correct legacy delete, stamps only the legacy provenance field, and is cancelled and defused when the entity is reactivated.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::Item, Item."No.", '', '', StoreCode, 'gid://prod/switch');

        // [WHEN] The outbox row drains while the task list is off.
        _Lib.DrainDeleteRow(DeleteEntryNo);

        // [THEN] A content-correct legacy delete is created and only the legacy provenance field is stamped.
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'The drain must create one legacy delete task');
        AssertNcIntent(Database::Item, DummyNcTask.Type::Delete, Item.RecordId(), Item."No.", StoreCode, 'Product delete');
        _Assert.AreEqual(0, SpfyTaskCount(), 'The drain must not create a new-queue task while the feature is off');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The drained outbox row must be marked processed');
        _Assert.IsTrue(DeletionLog."Spfy Task Entry No." = 0, 'The new-queue provenance field must stay empty on a legacy drain');
        _Assert.IsTrue(FindNcTask(Database::Item, DummyNcTask), 'The legacy delete task must be readable');
        NcTaskEntryNo := DummyNcTask."Entry No.";
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = NcTaskEntryNo, StrSubstNo('The outbox row must reference the persisted legacy entry number %1 but referenced %2', NcTaskEntryNo, DeletionLog."NC Task Entry No."));
        _Assert.IsTrue(_Lib.TaskLinkedToDeletionLog(DeleteEntryNo), 'The outbox row must resolve to the task it produced');

        // [WHEN] The entity is reactivated before the delete is sent.
        AssertReactivationCancels(DeleteEntryNo, Database::Item, StoreCode);
    end;

    local procedure AssertReactivationCancels(DeleteEntryNo: BigInteger; EntityTableNo: Integer; StoreCode: Code[20])
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
    begin
        DeletionLog.Get(DeleteEntryNo);
        SpfyDeletionLogMgt.CancelDeleteForEntity(EntityTableNo, StoreCode, DeletionLog."Entity System Id");
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'A reactivation must cancel the unsent delete');
        _Assert.IsTrue(_Lib.TaskIsDefused(DeleteEntryNo), 'A reactivation must defuse the unsent legacy delete task');
    end;

    [Test]
    procedure GivenSameNumberedNewQueueTask_WhenLegacyDeleteIsCancelled_ThenNewQueueRowUntouched()
    var
        LiveItem: Record Item;
        DeletedItem: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
        NewQueueEntryNo: BigInteger;
    begin
        // [SCENARIO] A cancellation that follows a legacy pointer never touches a same-numbered new-queue task and leaves the outbox row processed.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(LiveItem, SpfyStoreItemLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(DeletedItem, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A live new-queue task, and an outbox row whose legacy pointer carries that same entry number.
        NewQueueEntryNo := SeedNewQueueTask(StoreCode, LiveItem);
        _Assert.IsTrue(NewQueueEntryNo <> 0, 'The new-queue task must be created');
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::Item, DeletedItem."No.", '', '', StoreCode, 'gid://prod/collision');
        SpfyDeletionLogMgt.MarkProcessed(DeleteEntryNo, NewQueueEntryNo, "NPR Spfy Task Dest Queue"::"Nc Task");
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = NewQueueEntryNo, 'The legacy provenance field must carry the colliding entry number');
        _Assert.IsTrue(DeletionLog."Spfy Task Entry No." = 0, 'The new-queue provenance field must stay empty');

        // [WHEN] The deleted entity is reactivated, so the cancel follows the legacy pointer.
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::Item, StoreCode, DeletionLog."Entity System Id");

        // [THEN] The same-numbered new-queue task is left alone, and the outbox row stays processed because its legacy pointer resolves to nothing.
        _Assert.IsTrue(NewQueueTaskState(NewQueueEntryNo) = "NPR Spfy Task State"::Pending, 'A legacy cancellation must never touch a same-numbered new-queue task');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'A cancel whose legacy task cannot be found must leave the outbox row alone rather than cross into the new queue');
        _Assert.IsFalse(_Lib.TaskLinkedToDeletionLog(DeleteEntryNo), 'The legacy pointer must not resolve to a task in either queue');
    end;

    [Test]
    procedure GivenFeatureOn_WhenDeleteDrains_ThenNoNcTaskAndNoNcProvenance()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
    begin
        // [SCENARIO] A delete draining with the task list on creates a content-correct new-queue delete, stamps only the new-queue provenance field and leaves the legacy queue empty.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::Item, Item."No.", '', '', StoreCode, 'gid://prod/on');
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] The outbox row drains while the task list is on.
        _Lib.DrainDeleteRow(DeleteEntryNo);

        // [THEN] A content-correct new-queue delete is created and only the new-queue provenance field is stamped.
        _Assert.AreEqual(1, SpfyTaskCount(Database::Item), 'The drain must create one new-queue delete task');
        AssertSpfyIntent(Database::Item, "NPR Spfy Task Op"::Delete, Item.RecordId(), Item."No.", StoreCode, 'Product delete');
        _Assert.AreEqual(0, NcTaskCount(), 'A drained delete must never also reach the legacy queue while the feature is on');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The drained outbox row must be marked processed');
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = 0, 'The legacy provenance field must stay empty while the feature is on');
        _Assert.IsTrue(FindSpfyTask(Database::Item, SpfyTask), 'The new-queue delete task must be readable');
        _Assert.IsTrue(DeletionLog."Spfy Task Entry No." = SpfyTask."Entry No.", StrSubstNo('The outbox row must reference the persisted new-queue entry number %1 but referenced %2', SpfyTask."Entry No.", DeletionLog."Spfy Task Entry No."));
        _Assert.IsTrue(_Lib.TaskLinkedToDeletionLog(DeleteEntryNo), 'The outbox row must resolve to the task it produced');
    end;

    [Test]
    procedure GivenFeatureOn_WhenDrainedDeleteIsStillUnsent_ThenItCountsAsOutstanding()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
    begin
        // [SCENARIO] A drained delete counts as outstanding until the new-queue task it produced has been sent.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::Item, Item."No.", '', '', StoreCode, 'gid://prod/outstanding');
        _Lib.SetTaskListFeatureEnabled(true);
        _Lib.DrainDeleteRow(DeleteEntryNo);
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog."Spfy Task Entry No." <> 0, 'The drain must stamp the new-queue provenance field before the outstanding check means anything');

        // [WHEN] The delete has been handed to the new queue but not sent yet.
        // [THEN] It still counts as outstanding, so a post-send read-back cannot cancel it by resetting a flag.
        _Assert.IsTrue(SpfyDeletionLogMgt.HasOutstandingDelete(Database::Item, StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://prod/outstanding'), 'An unsent new-queue delete task must count as outstanding');

        // [WHEN] The new-queue task has been sent.
        SpfyTask.Get(DeletionLog."Spfy Task Entry No.");
        SpfyTask.State := SpfyTask.State::Completed;
        SpfyTask.Modify(false);

        // [THEN] Nothing is outstanding any more.
        _Assert.IsFalse(SpfyDeletionLogMgt.HasOutstandingDelete(Database::Item, StoreCode, "NPR Spfy ID Type"::"Entry ID", 'gid://prod/outstanding'), 'A sent new-queue delete task must not count as outstanding');
    end;

    [Test]
    procedure GivenFeatureOn_WhenDeletedEntityIsReactivated_ThenTheNewQueueTaskIsCancelled()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
        SpfyTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Reactivating an entity cancels the unsent delete and completes the new-queue task it created, recording the reactivation as the reason.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::Item, Item."No.", '', '', StoreCode, 'gid://prod/reactivated');
        _Lib.SetTaskListFeatureEnabled(true);
        _Lib.DrainDeleteRow(DeleteEntryNo);
        DeletionLog.Get(DeleteEntryNo);
        SpfyTaskEntryNo := DeletionLog."Spfy Task Entry No.";
        _Assert.IsTrue(SpfyTaskEntryNo <> 0, 'The drain must stamp the new-queue provenance field before the cancel can follow it');

        // [WHEN] The entity is reactivated before the delete is sent.
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::Item, StoreCode, DeletionLog."Entity System Id");

        // [THEN] The cancel follows the new-queue pointer and defuses the task it actually created.
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'A reactivation must cancel the unsent delete');
        SpfyTask.Get(SpfyTaskEntryNo);
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Completed, 'A reactivation must complete the unsent new-queue delete task');
        _Assert.AreNotEqual(0DT, SpfyTask."Completed At", 'A cancelled new-queue delete task must be stamped as completed');
        _Assert.AreEqual(_ReactivationCancelLbl, SpfyTaskResponseText(SpfyTaskEntryNo), 'The cancelled new-queue task must record the reactivation as its reason');
        _Assert.IsTrue(_Lib.TaskIsDefused(DeleteEntryNo), 'A reactivation must defuse the unsent new-queue delete task');
    end;

    local procedure SpfyTaskResponseText(EntryNo: BigInteger): Text
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

    [Test]
    procedure GivenFeatureOff_WhenSwitchedOn_ThenOnlyTheNewQueueReceivesFurtherChanges()
    var
        LegacyItem: Record Item;
        NewQueueItem: Record Item;
        LegacyLink: Record "NPR Spfy Store-Item Link";
        NewQueueLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Once the task list is switched on only the new queue receives further changes and the legacy row from before is left untouched.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(LegacyItem, LegacyLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(NewQueueItem, NewQueueLink, StoreCode);

        // [GIVEN] A change recorded while the task list is off.
        _Lib.DispatchModify(LegacyLink);
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'The change before the switch must land in the legacy queue');
        _Assert.AreEqual(0, SpfyTaskCount(), 'The change before the switch must not land in the new queue');

        // [WHEN] The task list is switched on and another change arrives.
        _Lib.SetTaskListFeatureEnabled(true);
        _Lib.DispatchModify(NewQueueLink);

        // [THEN] Only the new queue grows, and the legacy row from before is left where it is.
        _Assert.AreEqual(1, SpfyTaskCount(Database::Item), 'The change after the switch must land in the new queue');
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'The change after the switch must not add a legacy row');
        _Assert.AreEqual(1, NcTaskCount(Database::Item, LegacyItem."No."), 'The pre-switch legacy row must be left untouched');
    end;

    [Test]
    procedure GivenFeatureOn_WhenSwitchedOffByTheHarness_ThenOnlyTheLegacyQueueReceivesFurtherChanges()
    var
        NewQueueItem: Record Item;
        LegacyItem: Record Item;
        NewQueueLink: Record "NPR Spfy Store-Item Link";
        LegacyLink: Record "NPR Spfy Store-Item Link";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Once the task list is switched back off only the legacy queue receives further changes and the migration stamps are cleared.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(NewQueueItem, NewQueueLink, StoreCode);
        _Lib.CreateSyncedItemWithLink(LegacyItem, LegacyLink, StoreCode);

        // [GIVEN] A change recorded while the task list is on.
        _Lib.SetTaskListFeatureEnabled(true);
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, 'Enabling the task list must stamp the migration as completed');
        _Lib.DispatchModify(NewQueueLink);
        _Assert.AreEqual(1, SpfyTaskCount(Database::Item), 'The change before the switch must land in the new queue');

        // [WHEN] The task list is switched back off and another change arrives.
        _Lib.SetTaskListFeatureEnabled(false);
        _Lib.DispatchModify(LegacyLink);

        // [THEN] Only the legacy queue grows, and the harness reset leaves no migration stamp behind.
        _Assert.AreEqual(1, NcTaskCount(Database::Item), 'The change after the switch must land in the legacy queue');
        _Assert.AreEqual(1, SpfyTaskCount(Database::Item), 'The change after the switch must not add a new-queue row');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::NotStarted, 'The feature-off harness write must clear the migration status stamp');
        _Assert.AreEqual(0DT, MigrationStartedAt(), 'The feature-off harness write must clear the migration start-time stamp');
    end;
    #endregion

    local procedure NcTaskCount(TableNo: Integer; RecordValue: Code[20]): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        NcTask.SetRange("Record Value", RecordValue);
        exit(NcTask.Count());
    end;
}
