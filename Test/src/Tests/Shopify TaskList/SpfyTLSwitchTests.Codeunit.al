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

    local procedure CreateInventoryLevel(var Item: Record Item; var SpfyInventoryLevel: Record "NPR Spfy Inventory Level"; StoreCode: Code[20]; var ShopifyLocationId: Text[30]; LastUpdatedAt: DateTime)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SpfyInventoryLevel.Init();
        SpfyInventoryLevel."Shopify Store Code" := StoreCode;
        SpfyInventoryLevel."Shopify Location ID" := ShopifyLocationId;
        SpfyInventoryLevel."Item No." := Item."No.";
        SpfyInventoryLevel."Variant Code" := '';
        SpfyInventoryLevel.Inventory := 5;
        SpfyInventoryLevel."Last Updated at" := LastUpdatedAt;
        SpfyInventoryLevel.Insert(false);
    end;

    // Without an already activated location the inventory handler ALSO enqueues an activation task, and "exactly one task" stops holding.
    local procedure ActivateInventoryLocation(StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20])
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        LocationInvItem.Init();
        LocationInvItem."Shopify Store Code" := StoreCode;
        LocationInvItem."Shopify Location ID" := ShopifyLocationId;
        LocationInvItem."Item No." := ItemNo;
        LocationInvItem."Variant Code" := '';
        LocationInvItem.Activated := true;
        LocationInvItem.Insert(false);
    end;

    local procedure DisableAutoActivation(StoreCode: Code[20]; ShopifyLocationId: Text[30]; ItemNo: Code[20])
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        LocationInvItem.Init();
        LocationInvItem."Shopify Store Code" := StoreCode;
        LocationInvItem."Shopify Location ID" := ShopifyLocationId;
        LocationInvItem."Item No." := ItemNo;
        LocationInvItem."Variant Code" := '';
        LocationInvItem."Auto-Activation Disabled" := true;
        LocationInvItem.Insert(false);
    end;

    local procedure AssertNcPriceIntent(ExpectedRecId: RecordId; ExpectedRecordValue: Text; ExpectedStoreCode: Code[20]; ExpectedNotBefore: DateTime; SeamName: Text)
    var
        NcTask: Record "NPR Nc Task";
    begin
        // The shared intent helper hard-asserts a blank not-before time, and a price schedules one.
        _Assert.IsTrue(FindNcTask(Database::"NPR Spfy Item Price", NcTask), StrSubstNo('%1: the legacy queue must hold the task', SeamName));
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, StrSubstNo('%1: expected task type Modify but found %2', SeamName, NcTask.Type));
        _Assert.AreEqual(Database::"NPR Spfy Item Price", NcTask."Table No.", StrSubstNo('%1: source table', SeamName));
        _Assert.AreEqual(ExpectedRecId, NcTask."Record ID", StrSubstNo('%1: source record id', SeamName));
        _Assert.AreEqual(ExpectedRecordValue, NcTask."Record Value", StrSubstNo('%1: record value', SeamName));
        _Assert.AreEqual(ExpectedStoreCode, NcTask."Store Code", StrSubstNo('%1: store code', SeamName));
        _Assert.AreEqual(ExpectedNotBefore, NcTask."Not Before Date-Time", StrSubstNo('%1: the price must be scheduled at its start date', SeamName));
        _Assert.AreNotEqual(0DT, NcTask."Log Date", StrSubstNo('%1: the log date must be stamped', SeamName));
        _Assert.IsFalse(NcTask.Processed, StrSubstNo('%1: a fresh task must be unprocessed', SeamName));
    end;

    local procedure AssertSpfyPriceIntent(ExpectedRecId: RecordId; ExpectedRecordValue: Text; ExpectedStoreCode: Code[20]; ExpectedNotBefore: DateTime; SeamName: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        _Assert.IsTrue(FindSpfyTask(Database::"NPR Spfy Item Price", SpfyTask), StrSubstNo('%1: the new queue must hold the task', SeamName));
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, StrSubstNo('%1: expected task type Modify but found %2', SeamName, SpfyTask.Type));
        _Assert.AreEqual(Database::"NPR Spfy Item Price", SpfyTask."Table No.", StrSubstNo('%1: source table', SeamName));
        _Assert.AreEqual(ExpectedRecId, SpfyTask."Record ID", StrSubstNo('%1: source record id', SeamName));
        _Assert.AreEqual(ExpectedRecordValue, SpfyTask."Record Value", StrSubstNo('%1: record value', SeamName));
        _Assert.AreEqual(ExpectedStoreCode, SpfyTask."Store Code", StrSubstNo('%1: store code', SeamName));
        _Assert.AreEqual(ExpectedNotBefore, SpfyTask."Not Before Date-Time", StrSubstNo('%1: the price must be scheduled at its start date', SeamName));
        _Assert.AreNotEqual(0DT, SpfyTask."Log Date", StrSubstNo('%1: the log date must be stamped', SeamName));
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, StrSubstNo('%1: a fresh task must be waiting to be sent', SeamName));
    end;

    local procedure AssertLogDateWithinWindow(ActualLogDate: DateTime; EnqueuedAt: DateTime; SeamName: Text)
    begin
        // The activation seam stamps its log date a short moment ahead of now.
        _Assert.IsTrue(
            (ActualLogDate >= EnqueuedAt) and (ActualLogDate <= EnqueuedAt + 10000),
            StrSubstNo('%1: the log date %2 must fall in the short delay window that starts at %3', SeamName, ActualLogDate, EnqueuedAt));
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

    [Test]
    procedure GivenFeatureOff_WhenInventoryLevelChanges_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        NcTask: Record "NPR Nc Task";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        LastUpdatedAt: DateTime;
    begin
        // [SCENARIO] An inventory level change with the task list off creates one content-correct legacy level task stamped with the level's last updated time and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        LastUpdatedAt := CreateDateTime(Today(), 080000T);
        CreateInventoryLevel(Item, SpfyInventoryLevel, StoreCode, ShopifyLocationId, LastUpdatedAt);
        ActivateInventoryLocation(StoreCode, ShopifyLocationId, Item."No.");

        // [WHEN] An inventory level changes while the task list is off.
        _Lib.DispatchModify(SpfyInventoryLevel);

        // [THEN] The legacy queue holds one content-correct level task and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Inventory Level"), 'One legacy inventory level task must be created for the level change');
        AssertNcIntent(Database::"NPR Spfy Inventory Level", DummyNcTask.Type::Modify, SpfyInventoryLevel.RecordId(), Item."No.", StoreCode, 'Inventory level');
        _Assert.IsTrue(FindNcTask(Database::"NPR Spfy Inventory Level", NcTask), 'The legacy level task must be readable');
        _Assert.AreEqual(LastUpdatedAt, NcTask."Log Date", 'The level task log date must be the level''s last updated time');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No level task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenInventoryLevelChanges_ThenContentCorrectSpfyTaskOnly()
    var
        Item: Record Item;
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        LastUpdatedAt: DateTime;
    begin
        // [SCENARIO] An inventory level change with the task list on creates one content-correct new-queue level task stamped with the level's last updated time and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        LastUpdatedAt := CreateDateTime(Today(), 080000T);
        CreateInventoryLevel(Item, SpfyInventoryLevel, StoreCode, ShopifyLocationId, LastUpdatedAt);
        ActivateInventoryLocation(StoreCode, ShopifyLocationId, Item."No.");
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] An inventory level changes while the task list is on.
        _Lib.DispatchModify(SpfyInventoryLevel);

        // [THEN] The new queue holds one content-correct level task and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Spfy Inventory Level"), 'One new-queue inventory level task must be created for the level change');
        AssertSpfyIntent(Database::"NPR Spfy Inventory Level", "NPR Spfy Task Op"::Modify, SpfyInventoryLevel.RecordId(), Item."No.", StoreCode, 'Inventory level');
        _Assert.IsTrue(FindSpfyTask(Database::"NPR Spfy Inventory Level", SpfyTask), 'The new-queue level task must be readable');
        _Assert.AreEqual(LastUpdatedAt, SpfyTask."Log Date", 'The level task log date must be the level''s last updated time');
        _Assert.AreEqual(0, NcTaskCount(), 'A level change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenItemPriceChanges_ThenContentCorrectNcTaskOnly_AndExactReuseSchedules()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        FirstStartDate: Date;
        SecondStartDate: Date;
    begin
        // [SCENARIO] A price change with the task list off creates one legacy price task scheduled at its start date, gives a later start date its own task and lets an identical one be absorbed, and never reaches the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, true, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        // Anchored to Today: the legacy dedup lookback floor is midnight of the previous REAL day, and the container work date differs from the real date.
        FirstStartDate := Today();
        SecondStartDate := CalcDate('<+1M>', Today());
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, FirstStartDate);

        // [WHEN] A price that starts today changes while the task list is off.
        _Lib.DispatchModify(ItemPrice);

        // [THEN] One legacy price task scheduled at the price start date.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Item Price"), 'One legacy price task must be created for the price change');
        AssertNcPriceIntent(ItemPrice.RecordId(), Item."No.", StoreCode, CreateDateTime(FirstStartDate, 0T), 'Item price');

        // [WHEN] The same price row gets a later start date.
        ItemPrice."Starting Date" := SecondStartDate;
        ItemPrice.Modify(false);
        _Lib.DispatchModify(ItemPrice);

        // [THEN] Each distinct start date keeps its own legacy task.
        _Assert.AreEqual(2, NcTaskCount(Database::"NPR Spfy Item Price"), 'A second price start date must get its own legacy task under exact reuse');
        AssertNcPriceIntent(ItemPrice.RecordId(), Item."No.", StoreCode, CreateDateTime(SecondStartDate, 0T), 'Item price rescheduled');

        // [WHEN] The same start date arrives again. [THEN] the pending task absorbs it.
        _Lib.DispatchModify(ItemPrice);
        _Assert.AreEqual(2, NcTaskCount(Database::"NPR Spfy Item Price"), 'An identical start date must be absorbed by the pending legacy task');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No price task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenItemPriceChanges_ThenContentCorrectSpfyTaskOnly_AndExactReuseSchedules()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        StoreCode: Code[20];
        FirstStartDate: Date;
        SecondStartDate: Date;
    begin
        // [SCENARIO] A price change with the task list on creates one new-queue price task scheduled at its start date, gives a later start date its own task and lets an identical one be absorbed, and never reaches the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, true, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        FirstStartDate := Today();
        SecondStartDate := CalcDate('<+1M>', Today());
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, FirstStartDate);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A price that starts today changes while the task list is on.
        _Lib.DispatchModify(ItemPrice);

        // [THEN] One new-queue price task scheduled at the price start date.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Spfy Item Price"), 'One new-queue price task must be created for the price change');
        AssertSpfyPriceIntent(ItemPrice.RecordId(), Item."No.", StoreCode, CreateDateTime(FirstStartDate, 0T), 'Item price');

        // [WHEN] The same price row gets a later start date.
        ItemPrice."Starting Date" := SecondStartDate;
        ItemPrice.Modify(false);
        _Lib.DispatchModify(ItemPrice);

        // [THEN] Each distinct start date keeps its own new-queue task.
        _Assert.AreEqual(2, SpfyTaskCount(Database::"NPR Spfy Item Price"), 'A second price start date must get its own new-queue task under exact reuse');
        AssertSpfyPriceIntent(ItemPrice.RecordId(), Item."No.", StoreCode, CreateDateTime(SecondStartDate, 0T), 'Item price rescheduled');

        // [WHEN] The same start date arrives again. [THEN] the pending task absorbs it.
        _Lib.DispatchModify(ItemPrice);
        _Assert.AreEqual(2, SpfyTaskCount(Database::"NPR Spfy Item Price"), 'An identical start date must be absorbed by the pending new-queue task');
        _Assert.AreEqual(0, NcTaskCount(), 'A price change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenLocationActivationEnqueues_ThenContentCorrectNcTaskOnly()
    var
        Item: Record Item;
        DisabledItem: Record Item;
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        DisabledInventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        NcTask: Record "NPR Nc Task";
        DummyNcTask: Record "NPR Nc Task";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        DisabledLocationId: Text[30];
        EnqueuedAt: DateTime;
    begin
        // [SCENARIO] A location activation enqueued with the task list off creates one content-correct legacy activation task keyed on the location record and nothing in the new queue, and a location whose auto-activation the merchant disabled adds no task at all.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        CreateInventoryLevel(Item, SpfyInventoryLevel, StoreCode, ShopifyLocationId, CurrentDateTime());
        EnqueuedAt := CurrentDateTime();

        // [WHEN] The activation seam enqueues while the task list is off.
        _Assert.IsTrue(SpfyInvLocationAct.CreateNcTaskActivateInvLocation(SpfyInventoryLevel, true), 'The activation seam must create a task');

        // [THEN] One legacy activation task keyed on the location record, stamped a short moment ahead.
        LocationInvItem.Get(StoreCode, ShopifyLocationId, Item."No.", '');
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Inv Item Location"), 'One legacy activation task must be created');
        AssertNcIntent(Database::"NPR Spfy Inv Item Location", DummyNcTask.Type::Insert, LocationInvItem.RecordId(), Item."No.", StoreCode, 'Location activation');
        _Assert.IsTrue(FindNcTask(Database::"NPR Spfy Inv Item Location", NcTask), 'The legacy activation task must be readable');
        AssertLogDateWithinWindow(NcTask."Log Date", EnqueuedAt, 'Location activation');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No activation task may be created in the new queue while the feature is off');

        // [WHEN] A location whose auto-activation the merchant switched off is enqueued.
        CreateInventoryLevel(DisabledItem, DisabledInventoryLevel, StoreCode, DisabledLocationId, CurrentDateTime());
        DisableAutoActivation(StoreCode, DisabledLocationId, DisabledItem."No.");
        _Assert.IsFalse(SpfyInvLocationAct.CreateNcTaskActivateInvLocation(DisabledInventoryLevel, true), 'A location with auto-activation disabled must not be activated');

        // [THEN] No further task is created in either queue.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Inv Item Location"), 'A location with auto-activation disabled must not add a legacy task');
        _Assert.AreEqual(0, SpfyTaskCount(), 'A location with auto-activation disabled must not add a new-queue task');
    end;

    [Test]
    procedure GivenFeatureOn_WhenLocationActivationEnqueues_ThenContentCorrectSpfyTaskOnly()
    var
        Item: Record Item;
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyTask: Record "NPR Spfy Task";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        EnqueuedAt: DateTime;
    begin
        // [SCENARIO] A location activation enqueued with the task list on creates one content-correct new-queue activation task keyed on the location record and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        CreateInventoryLevel(Item, SpfyInventoryLevel, StoreCode, ShopifyLocationId, CurrentDateTime());
        _Lib.SetTaskListFeatureEnabled(true);
        EnqueuedAt := CurrentDateTime();

        // [WHEN] The same activation seam enqueues while the task list is on.
        _Assert.IsTrue(SpfyInvLocationAct.CreateNcTaskActivateInvLocation(SpfyInventoryLevel, true), 'The activation seam must create a task');

        // [THEN] The shared producer routes whole: one content-correct new-queue activation and nothing in the legacy queue.
        LocationInvItem.Get(StoreCode, ShopifyLocationId, Item."No.", '');
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Spfy Inv Item Location"), 'One new-queue activation task must be created');
        AssertSpfyIntent(Database::"NPR Spfy Inv Item Location", "NPR Spfy Task Op"::Insert, LocationInvItem.RecordId(), Item."No.", StoreCode, 'Location activation');
        _Assert.IsTrue(FindSpfyTask(Database::"NPR Spfy Inv Item Location", SpfyTask), 'The new-queue activation task must be readable');
        AssertLogDateWithinWindow(SpfyTask."Log Date", EnqueuedAt, 'Location activation');
        _Assert.AreEqual(0, NcTaskCount(), 'An activation must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenStoreCustomerLinkChanges_ThenContentCorrectNcTaskOnly()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A customer change with the task list off creates one content-correct legacy customer task keyed on the customer and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);

        // [WHEN] A synced customer's payload changes while the task list is off.
        _Lib.DispatchModify(SpfyStoreCustomerLink);

        // [THEN] The legacy queue holds one content-correct customer task keyed on the customer, and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::Customer), 'One legacy customer task must be created for the customer change');
        AssertNcIntent(Database::Customer, DummyNcTask.Type::Modify, Customer.RecordId(), Customer."No.", StoreCode, 'Customer');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No customer task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenStoreCustomerLinkChanges_ThenContentCorrectSpfyTaskOnly()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A customer change with the task list on creates one content-correct new-queue customer task and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A synced customer's payload changes while the task list is on.
        _Lib.DispatchModify(SpfyStoreCustomerLink);

        // [THEN] The new queue holds one content-correct customer task, and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::Customer), 'One new-queue customer task must be created for the customer change');
        AssertSpfyIntent(Database::Customer, "NPR Spfy Task Op"::Modify, Customer.RecordId(), Customer."No.", StoreCode, 'Customer');
        _Assert.AreEqual(0, NcTaskCount(), 'A customer change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenMetafieldChanges_ThenContentCorrectNcTaskOnly()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A metafield change with the task list off creates one content-correct legacy metafield task keyed on the owner link and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId(), 'switch fence value');

        // [WHEN] A metafield of that customer changes while the task list is off.
        _Lib.DispatchModify(SpfyEntityMetafield);

        // [THEN] The legacy queue holds one metafield task keyed on the OWNER LINK, and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR Spfy Entity Metafield"), 'One legacy metafield task must be created for the metafield change');
        AssertNcIntent(Database::"NPR Spfy Entity Metafield", DummyNcTask.Type::Modify, SpfyStoreCustomerLink.RecordId(), Customer."No.", StoreCode, 'Entity Metafield');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No metafield task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenMetafieldChanges_ThenContentCorrectSpfyTaskOnly()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A metafield change with the task list on creates one content-correct new-queue metafield task keyed on the owner link and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId(), 'switch fence value');
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A metafield of that customer changes while the task list is on.
        _Lib.DispatchModify(SpfyEntityMetafield);

        // [THEN] The new queue holds one metafield task keyed on the OWNER LINK, and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Spfy Entity Metafield"), 'One new-queue metafield task must be created for the metafield change');
        AssertSpfyIntent(Database::"NPR Spfy Entity Metafield", "NPR Spfy Task Op"::Modify, SpfyStoreCustomerLink.RecordId(), Customer."No.", StoreCode, 'Entity Metafield');
        _Assert.AreEqual(0, NcTaskCount(), 'A metafield change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenSyncedVoucherEndingDateChanges_ThenContentCorrectNcTaskOnly()
    var
        Voucher: Record "NPR NpRv Voucher";
        DummyNcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A synced voucher's ending date change with the task list off creates one content-correct legacy voucher task and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        SpfySyncStateMgt.SeedVoucherBaseline(Voucher, StoreCode);

        // [WHEN] A synced voucher's ending date changes while the task list is off.
        Voucher."Ending Date" := CreateDateTime(CalcDate('<+2M>', WorkDate()), 120000T);
        Voucher.Modify(false);
        _Lib.DispatchModify(Voucher);

        // [THEN] The legacy queue holds one content-correct voucher task and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR NpRv Voucher"), 'One legacy voucher task must be created for the ending date change');
        AssertNcIntent(Database::"NPR NpRv Voucher", DummyNcTask.Type::Modify, Voucher.RecordId(), Voucher."No.", StoreCode, 'Voucher ending date');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No voucher task may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenSyncedVoucherEndingDateChanges_ThenContentCorrectSpfyTaskOnly()
    var
        Voucher: Record "NPR NpRv Voucher";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A synced voucher's ending date change with the task list on creates one content-correct new-queue voucher task and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        SpfySyncStateMgt.SeedVoucherBaseline(Voucher, StoreCode);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A synced voucher's ending date changes while the task list is on.
        Voucher."Ending Date" := CreateDateTime(CalcDate('<+2M>', WorkDate()), 120000T);
        Voucher.Modify(false);
        _Lib.DispatchModify(Voucher);

        // [THEN] The new queue holds one content-correct voucher task and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpRv Voucher"), 'One new-queue voucher task must be created for the ending date change');
        AssertSpfyIntent(Database::"NPR NpRv Voucher", "NPR Spfy Task Op"::Modify, Voucher.RecordId(), Voucher."No.", StoreCode, 'Voucher ending date');
        _Assert.AreEqual(0, NcTaskCount(), 'A voucher change must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenEntryOnUnsyncedLiveVoucher_ThenNcInsertOnVoucherAndNcModifyOnEntry()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A balance entry on a voucher with no gift card, with the task list off, creates the legacy create on the voucher and the legacy balance update on the entry, both keyed on the voucher no.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);

        // [WHEN] A balance entry appears on a voucher with no gift card while the task list is off.
        _Lib.DispatchModify(VoucherEntry);

        // [THEN] The legacy queue holds the create on the voucher and the balance update on the entry, both keyed on the voucher no.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR NpRv Voucher"), 'One legacy gift card create must be created for the first entry');
        AssertNcIntent(Database::"NPR NpRv Voucher", DummyNcTask.Type::Insert, Voucher.RecordId(), Voucher."No.", StoreCode, 'Voucher gift card create');
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR NpRv Voucher Entry"), 'One legacy balance update must be created for the entry');
        AssertNcIntent(Database::"NPR NpRv Voucher Entry", DummyNcTask.Type::Modify, VoucherEntry.RecordId(), Voucher."No.", StoreCode, 'Voucher entry balance');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No voucher pair may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenEntryOnUnsyncedLiveVoucher_ThenSpfyInsertOnVoucherAndSpfyModifyOnEntry()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The same balance entry with the task list on creates that pair in the new queue and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);
        InsertVoucherEntry(VoucherEntry, Voucher, false);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A balance entry appears on a voucher with no gift card while the task list is on.
        _Lib.DispatchModify(VoucherEntry);

        // [THEN] The new queue holds the same pair and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpRv Voucher"), 'One new-queue gift card create must be created for the first entry');
        AssertSpfyIntent(Database::"NPR NpRv Voucher", "NPR Spfy Task Op"::Insert, Voucher.RecordId(), Voucher."No.", StoreCode, 'Voucher gift card create');
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpRv Voucher Entry"), 'One new-queue balance update must be created for the entry');
        AssertSpfyIntent(Database::"NPR NpRv Voucher Entry", "NPR Spfy Task Op"::Modify, VoucherEntry.RecordId(), Voucher."No.", StoreCode, 'Voucher entry balance');
        _Assert.AreEqual(0, NcTaskCount(), 'A voucher pair must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFeatureOff_WhenFreshArchiveDetected_ThenContentCorrectNcTaskOnly()
    var
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A fresh archival with the task list off creates one legacy deactivation carrying the archived record and the original voucher no, and nothing in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        ArchiveVoucher(ArchVoucher, Voucher, false);

        // [WHEN] A fresh archival is detected while the task list is off.
        _Lib.DispatchModify(ArchVoucher);

        // [THEN] The legacy queue holds one deactivation carrying the archived record and the original voucher no.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR NpRv Arch. Voucher"), 'One legacy deactivation must be created for the fresh archive');
        AssertNcIntent(Database::"NPR NpRv Arch. Voucher", DummyNcTask.Type::Modify, ArchVoucher.RecordId(), Voucher."No.", StoreCode, 'Archived voucher deactivation');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No deactivation may be created in the new queue while the feature is off');
    end;

    [Test]
    procedure GivenFeatureOn_WhenFreshArchiveDetected_ThenContentCorrectSpfyTaskOnly()
    var
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The same fresh archival with the task list on creates one new-queue deactivation and nothing in the legacy queue.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        ArchiveVoucher(ArchVoucher, Voucher, false);
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] The same fresh archival is detected while the task list is on.
        _Lib.DispatchModify(ArchVoucher);

        // [THEN] The new queue holds the one deactivation and the legacy queue holds nothing.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpRv Arch. Voucher"), 'One new-queue deactivation must be created for the fresh archive');
        AssertSpfyIntent(Database::"NPR NpRv Arch. Voucher", "NPR Spfy Task Op"::Modify, ArchVoucher.RecordId(), Voucher."No.", StoreCode, 'Archived voucher deactivation');
        _Assert.AreEqual(0, NcTaskCount(), 'A deactivation must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenFulfillmentProducerShape_WhenFeatureOffThenOn_ThenNcThenSpfyTaskOnly()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        DummyNcTask: Record "NPR Nc Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
    begin
        // [SCENARIO] A posted shipment for a Shopify order goes to the legacy queue while the task list is off and to the new queue once it is on, never to both.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A posted shipment for a Shopify order. The posting subscriber that builds this task is local, so the seam is exercised through the router call it makes.
        SalesShipmentHeader.Init();
        SalesShipmentHeader."No." := _Lib.NextCode('SH', MaxStrLen(SalesShipmentHeader."No."));
        SalesShipmentHeader.Insert(false);
        RecRef.GetTable(SalesShipmentHeader);

        // [WHEN] The fulfillment is enqueued while the task list is off.
        EnqueueOrderFlowTask(StoreCode, RecRef, '5001', DummyNcTask.Type::Insert, DummyNcTask);

        // [THEN] The legacy queue holds the fulfillment and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"Sales Shipment Header"), 'One legacy fulfillment must be created while the feature is off');
        AssertNcIntent(Database::"Sales Shipment Header", DummyNcTask.Type::Insert, SalesShipmentHeader.RecordId(), '5001', StoreCode, 'Fulfillment');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No fulfillment may be created in the new queue while the feature is off');

        // [WHEN] The task list is switched on and the same fulfillment is enqueued.
        _Lib.SetTaskListFeatureEnabled(true);
        EnqueueOrderFlowTask(StoreCode, RecRef, '5001', DummyNcTask.Type::Insert, DummyNcTask);

        // [THEN] The new queue holds the same intent and the legacy queue does not grow.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Sales Shipment Header"), 'One new-queue fulfillment must be created while the feature is on');
        AssertSpfyIntent(Database::"Sales Shipment Header", "NPR Spfy Task Op"::Insert, SalesShipmentHeader.RecordId(), '5001', StoreCode, 'Fulfillment');
        _Assert.AreEqual(1, NcTaskCount(), 'A fulfillment must never also reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenReadyForPickupConfirmed_WhenFeatureOffThenOn_ThenNcThenSpfyTaskOnly()
    var
        SalesHeader: Record "Sales Header";
        UnlinkedSalesHeader: Record "Sales Header";
        NpCsDocument: Record "NPR NpCs Document";
        QuoteNpCsDocument: Record "NPR NpCs Document";
        UnlinkedNpCsDocument: Record "NPR NpCs Document";
        DummyNcTask: Record "NPR Nc Task";
        SpfyOrdReadyForPickup: Codeunit "NPR Spfy Ord Ready For Pickup";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A confirmed collect document notifies through the legacy queue while the task list is off and through the new queue once it is on, and an unhandled or unlinked document notifies through neither.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A collect document confirmed against a Shopify-linked sales order.
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(SalesHeader."No."));
        _Lib.AssignEntryID(SalesHeader.RecordId(), '5503');
        AssignStoreCode(SalesHeader.RecordId(), StoreCode);
        CreateNpCsDocument(NpCsDocument, SalesHeader."No.", "NPR NpCs Document Type"::Order);

        // [WHEN] The collect confirmation runs while the task list is off.
        SpfyOrdReadyForPickup.ScheduleOrderReadyForPickup(NpCsDocument);

        // [THEN] The legacy queue holds the pickup notification and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR NpCs Document"), 'One legacy pickup notification must be created while the feature is off');
        AssertNcIntent(Database::"NPR NpCs Document", DummyNcTask.Type::Insert, NpCsDocument.RecordId(), '5503', StoreCode, 'Ready for pickup');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No pickup notification may be created in the new queue while the feature is off');

        // [WHEN] The task list is switched on and the same confirmation runs.
        _Lib.SetTaskListFeatureEnabled(true);
        SpfyOrdReadyForPickup.ScheduleOrderReadyForPickup(NpCsDocument);

        // [THEN] The new queue holds the same intent and the legacy queue does not grow.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpCs Document"), 'One new-queue pickup notification must be created while the feature is on');
        AssertSpfyIntent(Database::"NPR NpCs Document", "NPR Spfy Task Op"::Insert, NpCsDocument.RecordId(), '5503', StoreCode, 'Ready for pickup');
        _Assert.AreEqual(1, NcTaskCount(), 'A pickup notification must never also reach the legacy queue while the feature is on');

        // [WHEN] A document shape the integration does not handle is confirmed.
        CreateNpCsDocument(QuoteNpCsDocument, SalesHeader."No.", "NPR NpCs Document Type"::Quote);
        SpfyOrdReadyForPickup.ScheduleOrderReadyForPickup(QuoteNpCsDocument);

        // [THEN] It exits silently rather than notifying Shopify about a document it cannot resolve.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpCs Document"), 'A collect document that is not an order or a posted invoice must not be enqueued');

        // [WHEN] A confirmed order that was never linked to Shopify is confirmed.
        UnlinkedSalesHeader."Document Type" := UnlinkedSalesHeader."Document Type"::Order;
        UnlinkedSalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(UnlinkedSalesHeader."No."));
        CreateNpCsDocument(UnlinkedNpCsDocument, UnlinkedSalesHeader."No.", "NPR NpCs Document Type"::Order);
        SpfyOrdReadyForPickup.ScheduleOrderReadyForPickup(UnlinkedNpCsDocument);

        // [THEN] It exits silently too: there is no Shopify order to notify about.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR NpCs Document"), 'An order with no Shopify id must not be enqueued');
    end;

    [Test]
    procedure GivenCloseOrderProducer_WhenFeatureOffThenOn_ThenNcDeleteThenSpfyDeleteOnly()
    var
        SalesHeader: Record "Sales Header";
        UninvoicedSalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        DummyNcTask: Record "NPR Nc Task";
        SpfyCloseOrder: Codeunit "NPR Spfy Close Order";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Deleting an invoiced Shopify order enqueues the close in the legacy queue while the task list is off and in the new queue once it is on, and an order that was never invoiced enqueues nothing.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A Shopify-linked sales order that has been invoiced. The page-open gate that guards the delete trigger is UI state and is out of reach here.
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(SalesHeader."No."));
        SalesHeader.Insert(false);
        _Lib.AssignEntryID(SalesHeader.RecordId(), '5502');
        AssignStoreCode(SalesHeader.RecordId(), StoreCode);
        SalesInvHeader.Init();
        SalesInvHeader."No." := _Lib.NextCode('PI', MaxStrLen(SalesInvHeader."No."));
        SalesInvHeader."Order No." := SalesHeader."No.";
        SalesInvHeader.Insert(false);

        // [WHEN] The order is deleted while the task list is off.
        SpfyCloseOrder.InitSendCloseRequestTaskBeforeDeleteSalesHeader(SalesHeader);

        // [THEN] The legacy queue holds a delete carrying the order that is about to disappear.
        _Assert.AreEqual(1, NcTaskCount(Database::"Sales Header"), 'One legacy close order must be created while the feature is off');
        AssertNcIntent(Database::"Sales Header", DummyNcTask.Type::Delete, SalesHeader.RecordId(), '5502', StoreCode, 'Close order');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No close order may be created in the new queue while the feature is off');

        // [WHEN] The task list is switched on and the same delete runs.
        _Lib.SetTaskListFeatureEnabled(true);
        SpfyCloseOrder.InitSendCloseRequestTaskBeforeDeleteSalesHeader(SalesHeader);

        // [THEN] The new queue holds the same delete and the legacy queue does not grow.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Sales Header"), 'One new-queue close order must be created while the feature is on');
        AssertSpfyIntent(Database::"Sales Header", "NPR Spfy Task Op"::Delete, SalesHeader.RecordId(), '5502', StoreCode, 'Close order');
        _Assert.AreEqual(1, NcTaskCount(), 'A close order must never also reach the legacy queue while the feature is on');

        // [WHEN] A Shopify-linked order that was never invoiced is deleted.
        UninvoicedSalesHeader.Init();
        UninvoicedSalesHeader."Document Type" := UninvoicedSalesHeader."Document Type"::Order;
        UninvoicedSalesHeader."No." := _Lib.NextCode('SO', MaxStrLen(UninvoicedSalesHeader."No."));
        UninvoicedSalesHeader.Insert(false);
        _Lib.AssignEntryID(UninvoicedSalesHeader.RecordId(), '5504');
        AssignStoreCode(UninvoicedSalesHeader.RecordId(), StoreCode);
        SpfyCloseOrder.InitSendCloseRequestTaskBeforeDeleteSalesHeader(UninvoicedSalesHeader);

        // [THEN] Nothing is enqueued: closing an order Shopify never saw invoiced would be wrong.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Sales Header"), 'An order with no posted invoice must not be enqueued');
    end;

    [Test]
    procedure GivenInvoiceCaptureStage1_WhenFeatureOffThenOn_ThenNcStage1_ThenSpfyStage1AndStage2Rows()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        GatewaylessPaymentLine: Record "NPR Magento Payment Line";
        SpfyTask: Record "NPR Spfy Task";
        DummyNcTask: Record "NPR Nc Task";
        RecRef: RecordRef;
        StoreCode: Code[20];
        LegacyNcTaskCount: Integer;
        ErrorText: Text;
    begin
        // [SCENARIO] A posted invoice enqueues stage 1 in the legacy queue while the task list is off, and once it is on stage 1 lands in the new queue and creates exactly one stage-2 row, for the capturable line only.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] A posted invoice with one capturable Shopify payment line and one line that has no gateway at all.
        CreateInvoiceWithPaymentLine(SalesInvHeader, PaymentLine, StoreCode);
        GatewaylessPaymentLine.Init();
        GatewaylessPaymentLine."Document Table No." := Database::"Sales Invoice Header";
        GatewaylessPaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        GatewaylessPaymentLine."Document No." := SalesInvHeader."No.";
        GatewaylessPaymentLine."Line No." := 20000;
        GatewaylessPaymentLine.Amount := 250;
        GatewaylessPaymentLine.Insert(false);
        _Lib.AssignEntryID(GatewaylessPaymentLine.RecordId(), '778');
        RecRef.GetTable(SalesInvHeader);

        // [WHEN] The posting seam enqueues the capture while the task list is off.
        EnqueueOrderFlowTask(StoreCode, RecRef, '5501', DummyNcTask.Type::Insert, DummyNcTask);

        // [THEN] The legacy queue holds stage 1 and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"Sales Invoice Header"), 'One legacy capture stage 1 must be created while the feature is off');
        AssertNcIntent(Database::"Sales Invoice Header", DummyNcTask.Type::Insert, SalesInvHeader.RecordId(), '5501', StoreCode, 'Capture stage 1');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No capture may be created in the new queue while the feature is off');
        LegacyNcTaskCount := NcTaskCount();

        // [WHEN] The task list is switched on and the same capture is enqueued and then dispatched.
        _Lib.SetTaskListFeatureEnabled(true);
        EnqueueOrderFlowTask(StoreCode, RecRef, '5501', DummyNcTask.Type::Insert, DummyNcTask);
        _Assert.AreEqual(1, SpfyTaskCount(Database::"Sales Invoice Header"), 'One new-queue capture stage 1 must be created while the feature is on');
        AssertSpfyIntent(Database::"Sales Invoice Header", "NPR Spfy Task Op"::Insert, SalesInvHeader.RecordId(), '5501', StoreCode, 'Capture stage 1');
        _Assert.IsTrue(FindSpfyTask(Database::"Sales Invoice Header", SpfyTask), 'The new-queue capture stage 1 must be readable');
        _Assert.IsTrue(DispatchForReal(SpfyTask."Entry No.", ErrorText), StrSubstNo('Capture stage 1 must schedule its follow-ups without failing: %1', ErrorText));

        // [THEN] Stage 1 creates exactly one stage-2 row, in the new queue, for the line that can actually be captured.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR Magento Payment Line"), 'Stage 1 must create exactly one stage-2 capture, skipping the line with no payment gateway');
        AssertSpfyIntent(Database::"NPR Magento Payment Line", "NPR Spfy Task Op"::Insert, PaymentLine.RecordId(), '5501', StoreCode, 'Capture stage 2');
        _Assert.AreEqual(LegacyNcTaskCount, NcTaskCount(), 'Neither capture stage may reach the legacy queue while the feature is on');
    end;

    [Test]
    procedure GivenEligiblePOSEntry_WhenFeatureOffThenOn_ThenNcThenSpfyTaskOnly_AndWatermarkAdvances()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        POSEntry: Record "NPR POS Entry";
        CustomerlessPOSEntry: Record "NPR POS Entry";
        TempSpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer" temporary;
        DummyNcTask: Record "NPR Nc Task";
        SpfyPOSEntryExportMgt: Codeunit "NPR Spfy POS Entry Export Mgt.";
        StoreCode: Code[20];
        WatermarkAfterEligibleEntry: BigInteger;
    begin
        // [SCENARIO] An eligible POS entry exports through the legacy queue while the task list is off and through the new queue once it is on, advancing the watermark both times, while a customerless entry enqueues nothing and leaves it.
        Initialize();
        StoreCode := CreateOrderStore();

        // [GIVEN] An eligible POS entry for a customer synced to the store, and the export watermark still at zero.
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        CreatePOSEntry(POSEntry, Customer."No.", 120);
        TempSpfyExportPointerBuffer.Add(StoreCode, 0D, 0);
        FilterCustomerLinks(SpfyStoreCustomerLink, Customer."No.", TempSpfyExportPointerBuffer);

        // [WHEN] The export walks the entry while the task list is off.
        SpfyPOSEntryExportMgt.ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] The legacy queue holds the export and the new queue holds nothing.
        _Assert.AreEqual(1, NcTaskCount(Database::"NPR POS Entry"), 'One legacy POS entry export must be created while the feature is off');
        AssertNcIntent(Database::"NPR POS Entry", DummyNcTask.Type::Insert, POSEntry.RecordId(), Format(POSEntry."Entry No."), StoreCode, 'POS entry export');
        _Assert.AreEqual(0, SpfyTaskCount(), 'No POS entry export may be created in the new queue while the feature is off');

        // [THEN] The watermark moved to the exported entry, so the hourly scan does not re-read it.
        TempSpfyExportPointerBuffer.Get(StoreCode);
        _Assert.AreEqual(POSEntry.SystemRowVersion, TempSpfyExportPointerBuffer."New Last POS Entry Row Version", 'An eligible, linked POS entry must advance the export watermark');
        WatermarkAfterEligibleEntry := TempSpfyExportPointerBuffer."New Last POS Entry Row Version";

        // [WHEN] The task list is switched on and the export walks the same entry.
        _Lib.SetTaskListFeatureEnabled(true);
        FilterCustomerLinks(SpfyStoreCustomerLink, Customer."No.", TempSpfyExportPointerBuffer);
        SpfyPOSEntryExportMgt.ProcessPOSEntry(POSEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] The new queue holds the same intent and the legacy queue does not grow.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR POS Entry"), 'One new-queue POS entry export must be created while the feature is on');
        AssertSpfyIntent(Database::"NPR POS Entry", "NPR Spfy Task Op"::Insert, POSEntry.RecordId(), Format(POSEntry."Entry No."), StoreCode, 'POS entry export');
        _Assert.AreEqual(1, NcTaskCount(), 'A POS entry export must never also reach the legacy queue while the feature is on');

        // [WHEN] The export walks an entry that was posted without a customer.
        CreatePOSEntry(CustomerlessPOSEntry, '', 120);
        FilterCustomerLinks(SpfyStoreCustomerLink, Customer."No.", TempSpfyExportPointerBuffer);
        SpfyPOSEntryExportMgt.ProcessPOSEntry(CustomerlessPOSEntry, SpfyStoreCustomerLink, TempSpfyExportPointerBuffer);

        // [THEN] Nothing is enqueued and the watermark stays put, so the entry is simply re-read next hour.
        _Assert.AreEqual(1, SpfyTaskCount(Database::"NPR POS Entry"), 'An ineligible POS entry must not be enqueued');
        TempSpfyExportPointerBuffer.Get(StoreCode);
        _Assert.AreEqual(WatermarkAfterEligibleEntry, TempSpfyExportPointerBuffer."New Last POS Entry Row Version", 'An ineligible POS entry must not advance the export watermark');
    end;

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
        // Refreshing payment lines from Shopify would turn capture stage 1 into an HTTP call.
        ShopifyStore."Get Payment Lines from Shopify" := ShopifyStore."Get Payment Lines from Shopify"::ON_ORDER_IMPORT;
        ShopifyStore.Insert(false);
        exit(ShopifyStore.Code);
    end;

    local procedure EnqueueOrderFlowTask(StoreCode: Code[20]; RecRef: RecordRef; RecordValue: Text; TaskType: Option; var NcTask: Record "NPR Nc Task"): Boolean
    var
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
    begin
        // The router caches a sticky TRUE per instance (an ON verdict is never re-evaluated), so each enqueue uses a fresh local instance.
        exit(SpfyScheduleSend.InitNcTask(StoreCode, RecRef, RecordValue, TaskType, NcTask));
    end;

    local procedure AssignStoreCode(RecId: RecordId; StoreCode: Code[20])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(RecId, "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    local procedure CreateNpCsDocument(var NpCsDocument: Record "NPR NpCs Document"; SalesOrderNo: Code[20]; DocumentType: Enum "NPR NpCs Document Type")
    begin
        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument."From Document Type" := NpCsDocument."From Document Type"::Order;
        NpCsDocument."From Document No." := SalesOrderNo;
        NpCsDocument."Document Type" := DocumentType;
        NpCsDocument."Document No." := SalesOrderNo;
        NpCsDocument.Insert(false);
    end;

    local procedure CreateInvoiceWithPaymentLine(var SalesInvHeader: Record "Sales Invoice Header"; var PaymentLine: Record "NPR Magento Payment Line"; StoreCode: Code[20])
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
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
        // A shared utility on the frozen sender, not a send: it creates the SPFY-<CUR> gateway pair a capturable line requires.
        PaymentLine."Payment Gateway Code" := SpfyCapturePayment.ShopifyPaymentGateway('DKK');
        PaymentLine."Date Captured" := 0D;
        PaymentLine.Insert(false);
        _Lib.AssignEntryID(PaymentLine.RecordId(), '777');
        AssignStoreCode(SalesInvHeader.RecordId(), StoreCode);
    end;

    local procedure CreatePOSEntry(var POSEntry: Record "NPR POS Entry"; CustomerNo: Code[20]; SaleAmount: Decimal)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        LastPOSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Init();
        if LastPOSEntry.FindLast() then
            POSEntry."Entry No." := LastPOSEntry."Entry No." + 1
        else
            POSEntry."Entry No." := 1;
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
        POSEntrySalesLine.Quantity := 1;
        POSEntrySalesLine.Insert(false);
        // The row version is what the export watermark tracks, and it is only stamped once the row is on disk.
        POSEntry.Get(POSEntry."Entry No.");
    end;

    local procedure FilterCustomerLinks(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; CustomerNo: Code[20]; var SpfyExportPointerBuffer: Record "NPR Spfy Export Pointer Buffer")
    begin
        SpfyStoreCustomerLink.Reset();
        SpfyStoreCustomerLink.SetCurrentKey("Sync. to this Store");
        SpfyStoreCustomerLink.SetRange("Sync. to this Store", true);
        SpfyStoreCustomerLink.SetRange(Type, SpfyStoreCustomerLink.Type::Customer);
        SpfyStoreCustomerLink.SetFilter("Shopify Store Code", SpfyExportPointerBuffer.GetSpfyStoreFilter());
        SpfyStoreCustomerLink.SetRange("No.", CustomerNo);
    end;

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

    local procedure InsertVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; InitiatedInShopify: Boolean)
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry.Amount := 100;
        VoucherEntry."Spfy Initiated in Shopify" := InitiatedInShopify;
        VoucherEntry.Insert(false);
    end;

    local procedure ArchiveVoucher(var ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher"; DeleteLive: Boolean)
    begin
        ArchVoucher.Init();
        ArchVoucher."No." := _Lib.NextCode('AR', MaxStrLen(ArchVoucher."No."));
        ArchVoucher."Arch. No." := Voucher."No.";
        ArchVoucher."Voucher Type" := Voucher."Voucher Type";
        ArchVoucher.Insert(false);
        if DeleteLive then
            Voucher.Delete(false);
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
