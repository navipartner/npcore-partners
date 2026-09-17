codeunit 85284 "NPR Spfy RowVer Entity Tests"
{
    // [FEATURE] Shopify RowVersion change detection - per-entity detection flows: Items, Inventory Levels, Customers, Item Prices, Vouchers, Metafields (real DB)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
    end;

    #region Items
    [Test]
    procedure GivenSeededItem_WhenCostOrNoiseChanges_ThenOnlyRealCostChangeCreatesTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Only a real item cost change creates a cost task and advances the cost facet; noise-only edits and unchanged re-polls create nothing, and a further change while the task is still pending advances the facet without duplicating the task.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Last Direct Cost" := 10;
        Item.Modify(false);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreCode);

        // [WHEN] Only ignored bookkeeping fields change. [THEN] no task (rowversion bump absorbed).
        Item."Cost is Adjusted" := true;
        Item."Last Date Modified" := WorkDate();
        Item.Modify(false);
        _Lib.DispatchModify(Item);
        _Assert.AreEqual(0, _Lib.TaskCount(), 'A noise-only Item change must not create a task');

        // [WHEN] The cost really changes. [THEN] exactly one cost task, no product task, facet advanced.
        Item."Last Direct Cost" := 12;
        Item.Modify(false);
        _Lib.DispatchModify(Item);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Inventory Buffer"), 'A cost change must create exactly one cost-sync task');
        _Assert.AreEqual(0, _Lib.TaskCount(Database::Item), 'A cost change must not create a product task');
        _Assert.AreEqual('12', _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemCost'), 'The cost facet must advance in the same run');

        // [WHEN] Detection re-runs with no further change. [THEN] no-op.
        _Lib.DispatchModify(Item);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Inventory Buffer"), 'An unchanged facet must not re-create a task');

        // [WHEN] The cost changes again while the first task is still pending (deduped by the NC layer).
        Item."Last Direct Cost" := 14;
        Item.Modify(false);
        _Lib.DispatchModify(Item);
        // [THEN] The baseline still advances so the send transmits current state and the next poll is quiet.
        _Assert.AreEqual('14', _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemCost'), 'The facet must advance even when the task is deduped into a pending one');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Inventory Buffer"), 'The pending task is reused, not duplicated');
    end;

    [Test]
    procedure GivenCategoryChange_ThenTagsSyncRemovesOldFromBaselineAndAddsNew()
    var
        Item: Record Item;
        Item2: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Link2: Record "NPR Spfy Store-Item Link";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        CategoryA: Code[20];
        CategoryB: Code[20];
    begin
        // [SCENARIO] Changing an item's category removes the previously synced category tag and adds the new one, while an item with no category baseline only gets the new tag added.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CategoryA := _Lib.CreateItemCategory('Old category tag');
        CategoryB := _Lib.CreateItemCategory('New category tag');

        // [GIVEN] A synced item whose baseline holds the last-synced category A.
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Item Category Code" := CategoryA;
        Item.Modify(false);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreCode);

        // [WHEN] The category changes to B.
        Item."Item Category Code" := CategoryB;
        Item.Modify(false);
        _Lib.DispatchModify(Item);

        // [THEN] The tags sync removes the OLD category (from Sync State, not xRec) and adds the new one.
        TagUpdateRequest.SetRange("BC Record ID", SpfyStoreItemLink.RecordId());
        TagUpdateRequest.SetRange("Tag Value", 'Old category tag');
        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::Remove);
        _Assert.AreEqual(1, TagUpdateRequest.Count(), 'The old category tag must be removed');
        TagUpdateRequest.SetRange("Tag Value", 'New category tag');
        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::"Add");
        _Assert.AreEqual(1, TagUpdateRequest.Count(), 'The new category tag must be added');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Tag Update Request"), 'One tags-sync task must be created');
        _Assert.AreEqual(Format(CategoryB), _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemCategoryCode'), 'The category facet must advance');

        // [GIVEN] An item with NO category baseline (first sync / version-invalidated).
        _Lib.CreateSyncedItemWithLink(Item2, Link2, StoreCode);
        Item2."Item Category Code" := CategoryB;
        Item2.Modify(false);
        _Lib.DispatchModify(Item2);

        // [THEN] Only the new tag is added - there is no old category to remove.
        TagUpdateRequest.Reset();
        TagUpdateRequest.SetRange("BC Record ID", Link2.RecordId());
        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::Remove);
        _Assert.AreEqual(0, TagUpdateRequest.Count(), 'A missing baseline must add the new tag without removing anything');
        TagUpdateRequest.SetRange(Type, TagUpdateRequest.Type::"Add");
        _Assert.AreEqual(1, TagUpdateRequest.Count(), 'The new tag must still be added');
    end;

    [Test]
    procedure GivenStoreItemLink_WhenEachPayloadFieldChanges_ThenTaskFiresButExcludedFieldsDoNot()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Each product payload field on a store-item link creates a product task when it changes, while a change to an excluded write-back field creates none.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);

        // [WHEN] Each field the product send transmits changes. [THEN] each fires a product task (drift guard).
        SpfyStoreItemLink."Shopify Name" := 'Drift name';
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::Item), 'Shopify Name must be a detected payload field');

        _Lib.MarkAllTasksProcessed();
        SpfyStoreItemLink.SetShopifyDescription('Drift description');
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(2, _Lib.TaskCount(Database::Item), 'Shopify Description (BLOB) must be a detected payload field');

        _Lib.MarkAllTasksProcessed();
        SpfyStoreItemLink.Vendor := 'Drift vendor';
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(3, _Lib.TaskCount(Database::Item), 'Vendor must be a detected payload field');

        // [WHEN] Only excluded (send-computed / write-back) fields change. [THEN] no task.
        _Lib.MarkAllTasksProcessed();
        SpfyStoreItemLink."Shopify Status" := SpfyStoreItemLink."Shopify Status"::ACTIVE;
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(3, _Lib.TaskCount(Database::Item), 'Shopify Status must not be part of the product payload hash');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GivenFirstSyncLink_ThenFullInitialPushFires_AndRepushAfterUnsyncResync()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        TotalBefore: Integer;
    begin
        // [SCENARIO] A first sync pushes the product, its cost and its category tags regardless of hashes, the post-send write-back does not echo a task, and re-ticking sync after an unsync runs the full initial push again.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);
        Item."Item Category Code" := _Lib.CreateItemCategory('First sync tag');
        Item."Last Direct Cost" := 10;
        Item.Modify(false);

        // [GIVEN] Sync just ticked (Sync=true, Enabled=false) with no baseline.
        _Lib.CreateItemLink(SpfyStoreItemLink, Item."No.", StoreCode, true, false);

        // [WHEN] Detection processes the link. [THEN] the full initial push fires regardless of hashes.
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::Item, DummyNcTask.Type::Insert), 'First sync must schedule a product Insert');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Inventory Buffer"), 'First sync must push the cost');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Tag Update Request"), 'First sync must push the category tags');

        // [GIVEN] The send completed (write-back enables synchronization and advances the baseline).
        SpfyStoreItemLink."Synchronization Is Enabled" := true;
        SpfyStoreItemLink.Modify(false);
        SpfySyncStateMgt.AdvanceStoreItemLinkBaseline(SpfyStoreItemLink);
        _Lib.MarkAllTasksProcessed();

        // [THEN] The write-back re-poll converges: no echo task.
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(0, _Lib.TaskCountTyped(Database::Item, DummyNcTask.Type::Modify), 'The post-send write-back must not echo a new task');

        // [WHEN] The item row changes without its cost or category changing (a posting touching the item).
        Item.Find();
        Item.Description := 'Renamed after first sync';
        Item.Modify(false);
        _Lib.DispatchModify(Item);

        // [THEN] The first sync already sent cost and tags: neither echoes, and the item baseline carries what was sent.
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Inventory Buffer"), 'An item change without a cost change must not push the cost again after the first sync');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Tag Update Request"), 'An item change without a category change must not push the tags again after the first sync');
        _Assert.AreEqual('10', _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemCost'), 'The first sync must record the sent cost in the item baseline');

        // [WHEN] The item is unsynced (poll emits no send task for the leaving entity)...
        TotalBefore := _Lib.TaskCount();
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Assert.AreEqual(TotalBefore, _Lib.TaskCount(), 'The unsync transition must not produce a poll send task');

        // ...the remote delete completes (write-back clears the enabled flag), and sync is re-ticked.
        SpfyStoreItemLink."Synchronization Is Enabled" := false;
        SpfyStoreItemLink.Modify(false);
        SpfyStoreItemLink.Validate("Sync. to this Store", true);
        SpfyStoreItemLink.Modify(true);
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] The full initial push fires again - not suppressed by the stale baseline.
        _Assert.AreEqual(2, _Lib.TaskCountTyped(Database::Item, DummyNcTask.Type::Insert), 'Re-enabling sync must run the full initial push again');
        _Assert.AreEqual(2, _Lib.TaskCount(Database::"Inventory Buffer"), 'Re-sync must push the cost again');

        _Lib.ConsumeConfirm();   // the unsync Confirm above fires only when GuiAllowed() is true
    end;

    [Test]
    procedure GivenVariantModifRows_ThenOpTypeResolvesPerStoreFromAssignedID()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Variant2: Record "Item Variant";
        LinkA: Record "NPR Spfy Store-Item Link";
        LinkB: Record "NPR Spfy Store-Item Link";
        ModifA: Record "NPR Spfy Item Variant Modif.";
        ModifB: Record "NPR Spfy Item Variant Modif.";
        ModifNA: Record "NPR Spfy Item Variant Modif.";
        DummyNcTask: Record "NPR Nc Task";
        StoreA: Code[20];
        StoreB: Code[20];
    begin
        // [SCENARIO] A variant's operation resolves per store from that store's own assigned Shopify id - Modify where one exists, Insert where none does - and a not-available variant without an id is skipped.
        Initialize();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, LinkA, StoreA);
        _Lib.CreateItemLink(LinkB, Item."No.", StoreB, true, true);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        // [GIVEN] The variant has an assigned Shopify variant ID for store A only.
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreA), 'gid://var/A');
        _Lib.CreateVariantModif(ModifA, Item."No.", ItemVariant.Code, StoreA, false);
        _Lib.CreateVariantModif(ModifB, Item."No.", ItemVariant.Code, StoreB, false);

        // [WHEN] Store A's per-store row is processed (no baseline exists yet).
        _Lib.DispatchModify(ModifA);
        // [THEN] Modify - resolved from the assigned ID, never from Sync State presence.
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"Item Variant", DummyNcTask.Type::Modify), 'An assigned ID must resolve Modify even with no baseline');
        _Assert.AreEqual(1, _Lib.TaskCountForStore(Database::"Item Variant", StoreA), 'The Modify must target store A');

        // [WHEN] Store B's row is processed (no assigned ID for B).
        _Lib.DispatchModify(ModifB);
        // [THEN] Insert - the same variant diverges per store, keyed by each store's own assigned ID.
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"Item Variant", DummyNcTask.Type::Insert), 'A missing assigned ID must resolve Insert');
        _Assert.AreEqual(1, _Lib.TaskCountForStore(Database::"Item Variant", StoreB), 'The Insert must target store B');

        // [WHEN] A Not-Available row with no assigned ID is processed. [THEN] nothing to do.
        _Lib.CreateItemVariant(Variant2, Item."No.");
        _Lib.CreateVariantModif(ModifNA, Item."No.", Variant2.Code, StoreA, true);
        _Lib.DispatchModify(ModifNA);
        _Assert.AreEqual(2, _Lib.TaskCount(Database::"Item Variant"), 'A not-available variant with no Shopify identity must be skipped');
    end;

    [Test]
    procedure GivenVariantPayloadChange_ThenModifyOnceAndRepollNoOp_NewVariantInserts()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Variant2: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyNcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A changed variant is re-sent once as a Modify, an identical re-poll is suppressed by the hash, and a brand-new variant is scheduled as an Insert.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), 'gid://var/1');
        SpfySyncStateMgt.SeedItemVariantBaseline(ItemVariant);

        // [WHEN] A payload field changes. [THEN] one Modify task and the variant hash advances.
        ItemVariant.Description := 'Changed description';
        ItemVariant.Modify(false);
        _Lib.DispatchModify(ItemVariant);
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"Item Variant", DummyNcTask.Type::Modify), 'A changed variant must be re-sent as Modify');

        // [WHEN] Detection re-runs on the identical record. [THEN] suppressed by the hash.
        _Lib.DispatchModify(ItemVariant);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Item Variant"), 'An identical re-save must not re-send');

        // [WHEN] A brand-new variant (no assigned ID anywhere) is detected. [THEN] Insert.
        _Lib.CreateItemVariant(Variant2, Item."No.");
        _Lib.DispatchModify(Variant2);
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"Item Variant", DummyNcTask.Type::Insert), 'A new variant must be scheduled as Insert');
    end;
    #endregion

    #region Inventory
    [Test]
    procedure GivenSkuSafetyStockChange_WhenCycleRuns_ThenPointRecalcAndSameCycleSendTask()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SKU: Record "Stockkeeping Unit";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        LocationCode: Code[10];
        ShopifyLocationId: Text[30];
        SendTasksBefore: Integer;
    begin
        // [SCENARIO] A new SKU safety stock is recomputed into the inventory level and sent within the same detection cycle, and a following cycle with nothing changed sends nothing.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationCode := _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        _Lib.RunDetection();
        _Assert.AreEqual(0, _Lib.TaskCount(Database::"NPR Spfy Inventory Level"), 'The registration cycle must not send anything');

        // [WHEN] An SKU safety stock appears and one detection cycle runs.
        SKU.Init();
        SKU."Location Code" := LocationCode;
        SKU."Item No." := Item."No.";
        SKU."Variant Code" := '';
        SKU."NPR Spfy Safety Stock Quantity" := 4;
        SKU.Insert(false);
        _Lib.RunDetection();

        // [THEN] The point key is recomputed and the send goes out THE SAME cycle (send table polled last).
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", ''), 'The inventory level row must be materialized');
        _Assert.AreEqual(-4, SpfyInventoryLevel.Inventory, 'The level must reflect stock minus safety stock');
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR Spfy Inventory Level", Item."No."), 'Exactly one send task, created in the same cycle as the recompute');
        _Lib.FindLastTask(Database::"NPR Spfy Inventory Level", NcTask);
        _Assert.IsTrue(NcTask."Log Date" = SpfyInventoryLevel."Last Updated at", 'The send task log date must be the level''s Last Updated at');
        _Assert.AreEqual('4', _Lib.Facet(Database::"Stockkeeping Unit", SKU.SystemId, '', 'skuSafetyStock'), 'The SKU safety facet must be stored');

        // [WHEN] Another cycle runs with nothing changed. [THEN] no re-send (recompute left qty unchanged).
        SendTasksBefore := _Lib.TaskCount(Database::"NPR Spfy Inventory Level");
        _Lib.RunDetection();
        _Assert.AreEqual(SendTasksBefore, _Lib.TaskCount(Database::"NPR Spfy Inventory Level"), 'A no-change recompute must not enqueue a send');
    end;

    [Test]
    procedure GivenOpenSalesLine_WhenMovedChangedAndDeleted_ThenOldAndNewKeysRecalced()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SalesLine: Record "Sales Line";
        LevelA: Record "NPR Spfy Inventory Level";
        LevelB: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        LocationA: Code[10];
        LocationB: Code[10];
        LocIdA: Text[30];
        LocIdB: Text[30];
        TasksForABefore: Integer;
    begin
        // [SCENARIO] An open sales line reduces its location's inventory level; moving it recomputes both the abandoned and the new location, a quantity-only change recomputes only the current one, and deleting the line recomputes its key and drops the facet.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationA := _Lib.CreateLocationWithLink(StoreCode, LocIdA);
        LocationB := _Lib.CreateLocationWithLink(StoreCode, LocIdB);
        _Lib.RunDetection();

        // [WHEN] An open order line appears at location A.
        _Lib.CreateSalesOrderLine(SalesLine, Item."No.", '', LocationA, 5);
        _Lib.RunDetection();
        _Assert.AreEqual(Format(LocationA), _Lib.Facet(Database::"Sales Line", SalesLine.SystemId, '', 'salesLineLocationCode'), 'The move-key facet must hold location A');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelA, StoreCode, LocIdA, Item."No.", ''), 'Level A must be materialized');
        _Assert.AreEqual(-5, LevelA.Inventory, 'Level A must subtract the outstanding quantity');

        // [WHEN] The line moves to location B.
        SalesLine."Location Code" := LocationB;
        SalesLine.Modify(false);
        _Lib.RunDetection();

        // [THEN] BOTH the abandoned key (A, from Sync State) and the new key (B) are recomputed.
        _Assert.AreEqual(Format(LocationB), _Lib.Facet(Database::"Sales Line", SalesLine.SystemId, '', 'salesLineLocationCode'), 'The move-key facet must advance to location B');
        LevelA.Get(StoreCode, LocIdA, Item."No.", '');
        _Assert.AreEqual(0, LevelA.Inventory, 'Location A must be recomputed back to zero (not left stale)');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelB, StoreCode, LocIdB, Item."No.", ''), 'Level B must be materialized');
        _Assert.AreEqual(-5, LevelB.Inventory, 'Location B must carry the moved outstanding quantity');

        // [WHEN] Only the quantity changes (same key). [THEN] only the current key is recomputed.
        TasksForABefore := _Lib.TaskCountForRecordId(Database::"NPR Spfy Inventory Level", LevelA.RecordId());
        SalesLine."Outstanding Qty. (Base)" := 3;
        SalesLine.Modify(false);
        _Lib.RunDetection();
        LevelB.Get(StoreCode, LocIdB, Item."No.", '');
        _Assert.AreEqual(-3, LevelB.Inventory, 'The current key must be recomputed on a quantity change');
        _Assert.AreEqual(TasksForABefore, _Lib.TaskCountForRecordId(Database::"NPR Spfy Inventory Level", LevelA.RecordId()), 'The unchanged old key must not be re-sent on a quantity-only change');

        // [WHEN] The line is deleted (non-posting delete - no polled row remains).
        SalesLine.Delete(false);
        // [THEN] The delete subscriber recomputes the gone key immediately and drops the facet.
        LevelB.Get(StoreCode, LocIdB, Item."No.", '');
        _Assert.AreEqual(0, LevelB.Inventory, 'The delete subscriber must recompute the line''s key');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"Sales Line", SalesLine.SystemId, ''), 'The move-key facet must be removed on delete');
    end;

    [Test]
    procedure GivenItemSafetyStockOnInventoryOnlyStore_ThenStructuralRecalcWithoutItemsTasks()
    var
        Item: Record Item;
        Item2: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Link2: Record "NPR Spfy Store-Item Link";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
    begin
        // [SCENARIO] An item safety stock change on an inventory-only store recomputes the inventory level and stores its facet without any cost or tag task, a later drop to zero is still detected against the seeded baseline, and an unseeded item whose safety stock is already zero is skipped.
        Initialize();
        // [GIVEN] A store with Items DISABLED but Inventory Levels ENABLED.
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Item Category Code" := _Lib.CreateItemCategory('Inventory-only tag');
        Item."Last Direct Cost" := 10;
        Item.Modify(false);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [WHEN] The item-level safety stock changes.
        Item."NPR Spfy Safety Stock Quantity" := 6;
        Item.Modify(false);
        _Lib.DispatchModify(Item);

        // [THEN] The STRUCTURAL recompute runs and the facet persists, while the Items-gated cost/category facets stay untouched for this store.
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", ''), 'The safety change must trigger the structural recompute');
        _Assert.AreEqual(-6, SpfyInventoryLevel.Inventory, 'The level must include the item-level safety stock');
        _Assert.AreEqual('6', _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemSafetyStock'), 'The safety facet must be persisted');
        _Assert.AreEqual(0, _Lib.TaskCount(Database::"Inventory Buffer"), 'No cost task may fire while Items is disabled for the store');
        _Assert.AreEqual(0, _Lib.TaskCount(Database::"NPR Spfy Tag Update Request"), 'No tags task may fire while Items is disabled for the store');

        // [WHEN] The safety drops to zero against the SEEDED baseline. [THEN] detected.
        Item."NPR Spfy Safety Stock Quantity" := 0;
        Item.Modify(false);
        _Lib.DispatchModify(Item);
        SpfyInventoryLevel.Get(StoreCode, ShopifyLocationId, Item."No.", '');
        _Assert.AreEqual(0, SpfyInventoryLevel.Inventory, 'A seeded baseline must detect the drop to zero');
        _Assert.AreEqual('0', _Lib.Facet(Database::Item, Item.SystemId, StoreCode, 'itemSafetyStock'), 'The safety facet must advance to zero');

        // [GIVEN] An UNSEEDED item whose safety is already zero: the empty baseline reads as zero too.
        _Lib.CreateSyncedItemWithLink(Item2, Link2, StoreCode);
        Item2."Description 2" := 'noise';
        Item2.Modify(false);
        // [WHEN] It is polled. [THEN] zero-vs-zero compares equal - deliberately no recompute, no facet.
        _Lib.DispatchModify(Item2);
        _Assert.IsFalse(_Lib.HasBaseline(Database::Item, Item2.SystemId, StoreCode), 'An unseeded zero-safety item must be silently skipped (seeding is load-bearing)');
        _Assert.AreEqual(0, _Lib.InventoryLevelCount(Item2."No."), 'No structural recompute may fire for the unseeded zero-safety item');
    end;

    [Test]
    procedure GivenTransferLine_WhenTransitChangesAndFromLocationMoves_ThenAllAffectedKeysRecalced()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        TransferLine: Record "Transfer Line";
        LevelA: Record "NPR Spfy Inventory Level";
        LevelB: Record "NPR Spfy Inventory Level";
        LevelC: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        LocationA: Code[10];
        LocationB: Code[10];
        LocationC: Code[10];
        LocIdA: Text[30];
        LocIdB: Text[30];
        LocIdC: Text[30];
    begin
        // [SCENARIO] An open transfer line adjusts the inventory levels of both of its locations, a quantity-in-transit change is detected, and moving the from-location recomputes the abandoned location as well as the new one.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.SetStoreIncludeTransferOrders(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationA := _Lib.CreateLocationWithLink(StoreCode, LocIdA);
        LocationB := _Lib.CreateLocationWithLink(StoreCode, LocIdB);
        LocationC := _Lib.CreateLocationWithLink(StoreCode, LocIdC);

        // [WHEN] An open transfer line A->B appears.
        _Lib.CreateTransferLine(TransferLine, Item."No.", '', LocationA, LocationB, 5, 0);
        _Lib.DispatchModify(TransferLine);
        _Assert.AreEqual(Format(LocationA), _Lib.Facet(Database::"Transfer Line", TransferLine.SystemId, '', 'transferLineFromCode'), 'The move-key facet must hold the from-location');
        _Assert.AreEqual(Format(LocationB), _Lib.Facet(Database::"Transfer Line", TransferLine.SystemId, '', 'transferLineToCode'), 'The move-key facet must hold the to-location');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelA, StoreCode, LocIdA, Item."No.", ''), 'The from-location level must be materialized');
        _Assert.AreEqual(-5, LevelA.Inventory, 'The from-location must subtract the outstanding shipment quantity');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelB, StoreCode, LocIdB, Item."No.", ''), 'The to-location level must be materialized');
        _Assert.AreEqual(5, LevelB.Inventory, 'The to-location must add the outstanding receipt quantity');

        // [WHEN] ONLY the quantity in transit changes (shipped-not-received; outstanding unchanged).
        TransferLine."Qty. in Transit (Base)" := 3;
        TransferLine.Modify(false);
        _Lib.DispatchModify(TransferLine);

        // [THEN] The transit-only change is detected (mandatory tracked field) and the keys recomputed.
        _Assert.AreEqual('3', _Lib.Facet(Database::"Transfer Line", TransferLine.SystemId, '', 'transferLineQtyInTransit'), 'The transit facet must advance');
        LevelB.Get(StoreCode, LocIdB, Item."No.", '');
        _Assert.AreEqual(8, LevelB.Inventory, 'The to-location must include the quantity in transit');

        // [WHEN] The from-location moves A->C.
        TransferLine."Transfer-from Code" := LocationC;
        TransferLine.Modify(false);
        _Lib.DispatchModify(TransferLine);

        // [THEN] Both the old (A) and the new (C) from-keys are recomputed; A is not left stale.
        _Assert.AreEqual(Format(LocationC), _Lib.Facet(Database::"Transfer Line", TransferLine.SystemId, '', 'transferLineFromCode'), 'The from facet must advance to the new location');
        LevelA.Get(StoreCode, LocIdA, Item."No.", '');
        _Assert.AreEqual(0, LevelA.Inventory, 'The abandoned from-location must be recomputed back to zero');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelC, StoreCode, LocIdC, Item."No.", ''), 'The new from-location level must be materialized');
        _Assert.AreEqual(-5, LevelC.Inventory, 'The new from-location must carry the outstanding shipment quantity');
    end;

    [Test]
    procedure GivenItemLedgerEntryInsert_ThenItsKeyRecalcedWithoutAnyBaseline()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemLedgerEntry: Record "Item Ledger Entry";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        StoreCode: Code[20];
        LocationCode: Code[10];
        ShopifyLocationId: Text[30];
    begin
        // [SCENARIO] A new item ledger entry recomputes its own inventory key without creating any task and without keeping a baseline for the entry itself.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationCode := _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);

        // [WHEN] A new item ledger entry is detected.
        _Lib.InsertItemLedgerEntry(ItemLedgerEntry, Item."No.", '', LocationCode, 7);
        _Assert.IsFalse(_Lib.DispatchModify(ItemLedgerEntry), 'The ILE handler recomputes only - it never creates a task itself');

        // [THEN] Its (item, variant, location) key is recomputed; the send signal is the level bump.
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", ''), 'The ledger entry must recompute its inventory key');
        _Assert.AreEqual(7, SpfyInventoryLevel.Inventory, 'The level must reflect the posted quantity');
        // [THEN] No per-ILE Sync State row is kept (the table would grow unbounded; recompute is idempotent).
        _Assert.IsFalse(_Lib.HasBaseline(Database::"Item Ledger Entry", ItemLedgerEntry.SystemId, ''), 'An ILE must never get a Sync State baseline');
        _Assert.AreEqual(0, _Lib.TaskCount(Database::"Item Ledger Entry"), 'No task may ever be keyed on the ledger entry itself');
    end;

    [Test]
    procedure GivenSteadySyncedLink_ThenStructuralRecalcGatedToTransitionsAndVariantPath()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
    begin
        // [SCENARIO] A steady-state link edit produces its product task without running the structural inventory recompute, while a sync-state transition and a newly added variant each do materialize the inventory rows.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);

        // [WHEN] A steady-state (synced, non-structural) link edit is processed.
        SpfyStoreItemLink."Shopify Name" := 'Renamed product';
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] The ordinary product task fires, but NO structural recompute (no level rows written).
        _Assert.AreEqual(1, _Lib.TaskCount(Database::Item), 'The steady-state edit must still produce the product task');
        _Assert.AreEqual(0, _Lib.InventoryLevelCount(Item."No."), 'A steady-state link edit must not run the structural recompute');

        // [WHEN] The link is in a sync-state transition (Sync <> Synchronization Is Enabled).
        SpfyStoreItemLink."Synchronization Is Enabled" := false;
        SpfyStoreItemLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] The structural recompute runs and materializes the level rows.
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", ''), 'A sync transition must run the structural recompute');

        // [GIVEN] Steady state again. [WHEN] A structural event arrives via its own path (variant added).
        SpfyStoreItemLink."Synchronization Is Enabled" := true;
        SpfyStoreItemLink.Modify(false);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.DispatchModify(ItemVariant);

        // [THEN] The gate does not drop it: the variant path converges the inventory-row shape.
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", ItemVariant.Code), 'A new variant must get its inventory rows via the variant path despite the gate');
    end;
    #endregion

    #region Customers
    [Test]
    procedure GivenCustomerLink_WhenEachPayloadFieldChanges_ThenDetected_AndMirrorFieldsSuppressed()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        NcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Every hashed customer payload field re-sends the customer when it changes, bookkeeping mirror fields are suppressed, and the address-updated flag force-sends even with an unchanged hash.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        SpfySyncStateMgt.SeedStoreCustomerLinkBaseline(SpfyStoreCustomerLink);

        // [WHEN] Only bookkeeping/mirror fields change. [THEN] the hash suppresses the echo.
        SpfyStoreCustomerLink."Marketing State Updated in BC" := true;
        SpfyStoreCustomerLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        _Assert.AreEqual(0, _Lib.TaskCount(Database::Customer), 'A bookkeeping-only link change must not re-send the customer');

        // [WHEN] A real payload field changes. [THEN] one Modify task keyed on the Customer.
        SpfyStoreCustomerLink."E-Mail" := 'changed@example.com';
        SpfyStoreCustomerLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::Customer, Customer."No."), 'A changed e-mail must re-send the customer');
        _Lib.FindLastTask(Database::Customer, NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, 'A synced customer change must be a Modify');

        // [THEN] Every other hashed payload field is covered by the drift guard.
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("First Name"), 'DriftFirst');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("Last Name"), 'DriftLast');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("Phone No."), '+4512345678');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo(Address), 'Drift street 1');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("Address 2"), 'Drift floor 2');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo(City), 'Driftville');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo(County), 'Driftshire');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("Post Code"), '9999');
        AssertCustomerLinkFieldDetected(SpfyStoreCustomerLink, SpfyStoreCustomerLink.FieldNo("Country/Region Code"), 'XX');

        // [WHEN] The marketing state changes (hashed enum field).
        AssertMarketingStateDetected(SpfyStoreCustomerLink);

        // [WHEN] The address-updated flag is raised with an unchanged hash. [THEN] it force-sends.
        _Lib.MarkAllTasksProcessed();
        SpfyStoreCustomerLink."Address Updated in BC" := true;
        SpfyStoreCustomerLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::Customer, NcTask.Type::Modify) - CountProcessedModifies(), 'The Address Updated in BC flag must bypass the hash suppression');
    end;

    [Test]
    procedure GivenCustomerLinkFlags_ThenOpTypeResolves_AndWritebackAdvanceStopsTheEcho()
    var
        CustomerI: Record Customer;
        CustomerD: Record Customer;
        CustomerN: Record Customer;
        LinkInsert: Record "NPR Spfy Store-Customer Link";
        LinkDisable: Record "NPR Spfy Store-Customer Link";
        LinkNone: Record "NPR Spfy Store-Customer Link";
        DummyNcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A customer link's sync flags resolve its operation - a first sync is an Insert past the hash, while a sync-disable and a fully unsynced link emit nothing - and the post-send baseline advance is feature-gated and stops the write-back echo.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, true, false);

        // [GIVEN] A first sync (Sync=true, Enabled=false) whose baseline coincidentally matches.
        _Lib.CreateCustomerWithLink(CustomerI, LinkInsert, StoreCode, true, false);
        SpfySyncStateMgt.SeedStoreCustomerLinkBaseline(LinkInsert);
        // [WHEN] Processed. [THEN] Insert - a first sync always proceeds past the hash.
        _Lib.DispatchModify(LinkInsert);
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::Customer, DummyNcTask.Type::Insert), 'A first customer sync must resolve Insert and bypass the hash');

        // [GIVEN] A sync-disable transition (Sync=false, Enabled=true).
        _Lib.CreateCustomerWithLink(CustomerD, LinkDisable, StoreCode, false, true);
        _Lib.DispatchModify(LinkDisable);
        // [THEN] The poll emits NOTHING - the remote delete is owned by the write-path outbox.
        _Assert.AreEqual(0, _Lib.TaskCountTyped(Database::Customer, DummyNcTask.Type::Delete), 'A sync-disable must not produce a poll Delete task');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::Customer), 'A sync-disable must not fall through to Modify');

        // [GIVEN] Both flags off. [THEN] nothing.
        _Lib.CreateCustomerWithLink(CustomerN, LinkNone, StoreCode, false, false);
        _Lib.DispatchModify(LinkNone);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::Customer), 'A fully unsynced link must produce nothing');

        // [GIVEN] The feature is OFF. [WHEN] the send write-back advance runs. [THEN] it no-ops (legacy path unaffected).
        _Lib.SetFeatureEnabled(false);
        SpfySyncStateMgt.AdvanceStoreCustomerLinkBaseline(LinkDisable);
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Store-Customer Link", LinkDisable.SystemId, StoreCode), 'The baseline advance must be feature-gated off');

        // [GIVEN] Feature ON and a completed send that wrote Shopify''s response back into the link.
        _Lib.SetFeatureEnabled(true);
        LinkInsert."First Name" := 'From Shopify';
        LinkInsert."Synchronization Is Enabled" := true;
        LinkInsert.Modify(false);
        SpfySyncStateMgt.AdvanceStoreCustomerLinkBaseline(LinkInsert);
        _Lib.MarkAllTasksProcessed();
        // [WHEN] The next poll sees the bumped rowversion. [THEN] no echo.
        _Lib.DispatchModify(LinkInsert);
        _Assert.AreEqual(0, CountUnprocessedCustomerTasks(), 'The post-send baseline advance must stop the write-back echo');
    end;

    local procedure AssertCustomerLinkFieldDetected(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link"; FieldNo: Integer; NewValue: Text)
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        PreviousHash: Text;
        NewHash: Text;
    begin
        // NC dedup absorbs repeat tasks, so the per-field detection signal is the baseline-hash advance (only written when the handler saw the change).
        PreviousHash := _Lib.Facet(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", 'storeCustomerLinkHash');
        RecRef.GetTable(SpfyStoreCustomerLink);
        FRef := RecRef.Field(FieldNo);
        FRef.Value(NewValue);
        RecRef.Modify(false);
        RecRef.SetTable(SpfyStoreCustomerLink);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        NewHash := _Lib.Facet(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", 'storeCustomerLinkHash');
        _Assert.AreNotEqual(PreviousHash, NewHash, StrSubstNo('Payload field %1 must be part of the customer hash (silent-miss drift guard)', FRef.Caption()));
    end;

    local procedure AssertMarketingStateDetected(var SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        PreviousHash: Text;
        NewHash: Text;
    begin
        PreviousHash := _Lib.Facet(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", 'storeCustomerLinkHash');
        SpfyStoreCustomerLink."E-mail Marketing State" := SpfyStoreCustomerLink."E-mail Marketing State"::SUBSCRIBED;
        SpfyStoreCustomerLink.Modify(false);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        NewHash := _Lib.Facet(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, SpfyStoreCustomerLink."Shopify Store Code", 'storeCustomerLinkHash');
        _Assert.AreNotEqual(PreviousHash, NewHash, 'The e-mail marketing state must be part of the customer hash');
    end;

    local procedure CountProcessedModifies(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", Database::Customer);
        NcTask.SetRange(Type, NcTask.Type::Modify);
        NcTask.SetRange(Processed, true);
        exit(NcTask.Count());
    end;

    local procedure CountUnprocessedCustomerTasks(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", Database::Customer);
        NcTask.SetRange(Processed, false);
        exit(NcTask.Count());
    end;
    #endregion

    #region Item Prices
    [Test]
    procedure GivenItemPriceChange_ThenDeferredModifyTaskForEnabledStoreOnly()
    var
        Item: Record Item;
        ItemB: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LinkB: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        ItemPriceB: Record "NPR Spfy Item Price";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        DisabledStoreCode: Code[20];
        StartingDate: Date;
    begin
        // [SCENARIO] An item price change creates one Modify task for its own store, deferred to the price's starting date and keeping no baseline, while a price on a store with prices disabled is skipped.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, true, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        StartingDate := CalcDate('<+10D>', WorkDate());
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 99, StartingDate);
        ItemPrice.Find();

        // [WHEN] The polled price row is dispatched.
        _Lib.DispatchModify(ItemPrice);

        // [THEN] Exactly one Modify task keyed on the price row, deferred to the price's starting date.
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR Spfy Item Price", Item."No."), 'One price task keyed on the variant SKU');
        _Lib.FindLastTask(Database::"NPR Spfy Item Price", NcTask);
        _Assert.IsTrue(NcTask."Not Before Date-Time" = CreateDateTime(StartingDate, 0T), 'A future-dated price must not be sent before its starting date');
        _Assert.IsTrue(NcTask."Log Date" = ItemPrice.SystemModifiedAt, 'The task log date must be the price row''s SystemModifiedAt');
        _Assert.AreEqual(StoreCode, NcTask."Store Code", 'The task must target the price row''s own store');
        // [THEN] No Sync State baseline is kept for Item Price - the value-gate is the suppression.
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Item Price", ItemPrice.SystemId, StoreCode), 'Item Price must not keep a Sync State baseline');

        // [GIVEN] A price row on a store with Item Prices disabled (another store keeps the area alive).
        DisabledStoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(ItemB, LinkB, DisabledStoreCode);
        _Lib.CreateItemPrice(ItemPriceB, ItemB."No.", DisabledStoreCode, 50, WorkDate());
        // [WHEN] It is dispatched. [THEN] the per-store gate skips it.
        _Lib.DispatchModify(ItemPriceB);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Item Price"), 'A price on a Prices-disabled store must not be sent');
    end;
    #endregion

    #region Vouchers
    [Test]
    procedure GivenVouchers_ThenOnlyProvenEndingDateChangeSends_AndUnbaselinedAdoptWithoutSending()
    var
        Voucher: Record "NPR NpRv Voucher";
        SyncedVoucher: Record "NPR NpRv Voucher";
        UnsyncedVoucher: Record "NPR NpRv Voucher";
        NcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        NewEndingDate: Date;
    begin
        // [SCENARIO] Only a voucher Ending Date change is sent and advances its date facet; other field changes send nothing, and a voucher with no baseline adopts one without sending.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        SpfySyncStateMgt.SeedVoucherBaseline(Voucher, StoreCode);

        // [WHEN] The Ending Date changes against the known baseline.
        NewEndingDate := CalcDate('<+2M>', WorkDate());
        Voucher."Ending Date" := CreateDateTime(NewEndingDate, 120000T);
        Voucher.Modify(false);
        _Lib.DispatchModify(Voucher);

        // [THEN] One Modify task keyed on the voucher; the date facet advances.
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR NpRv Voucher", Voucher."No."), 'An Ending Date change must send');
        _Lib.FindLastTask(Database::"NPR NpRv Voucher", NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, 'The voucher push must be a Modify');
        _Assert.AreEqual(Format(NewEndingDate, 0, 9), _Lib.Facet(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode, 'voucherEndingDate'), 'The date facet must advance');

        // [WHEN] Only a non-date field changes. [THEN] no task.
        _Lib.MarkAllTasksProcessed();
        Voucher.Description := 'Changed description';
        Voucher.Modify(false);
        _Lib.DispatchModify(Voucher);
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR NpRv Voucher", Voucher."No."), 'A non-date voucher change must never send');

        // [GIVEN] A synced voucher with NO baseline (restored/reset). [WHEN] polled.
        _Lib.CreateVoucherFixture(SyncedVoucher, StoreCode, true);
        _Lib.DispatchModify(SyncedVoucher);
        // [THEN] It adopts its baseline WITHOUT sending (matches the legacy Data Log skip-on-Insert).
        _Assert.AreEqual(0, _Lib.TaskCountForValue(Database::"NPR NpRv Voucher", SyncedVoucher."No."), 'An unbaselined voucher must adopt without sending');
        _Assert.IsTrue(_Lib.HasBaseline(Database::"NPR NpRv Voucher", SyncedVoucher.SystemId, StoreCode), 'The adopted baseline must be written');

        // [GIVEN] A not-yet-synced voucher with no baseline. [THEN] same: skip and adopt.
        _Lib.CreateVoucherFixture(UnsyncedVoucher, StoreCode, false);
        _Lib.DispatchModify(UnsyncedVoucher);
        _Assert.AreEqual(0, _Lib.TaskCountForValue(Database::"NPR NpRv Voucher", UnsyncedVoucher."No."), 'Voucher creation rides the balance-entry path, never the voucher poll');
        _Assert.IsTrue(_Lib.HasBaseline(Database::"NPR NpRv Voucher", UnsyncedVoucher.SystemId, StoreCode), 'The baseline must still be written to avoid re-evaluation churn');
    end;

    [Test]
    procedure GivenVoucherEntriesAndArchive_ThenInsertOnFirstEntry_ModifyAfter_AndArchDeactivatesOnce()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry1: Record "NPR NpRv Voucher Entry";
        VoucherEntry2: Record "NPR NpRv Voucher Entry";
        VoucherEntry3: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        DummyNcTask: Record "NPR Nc Task";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The first balance entry on an unsynced voucher creates the gift card and sends the balance, later entries only send the balance, a Shopify-initiated entry is never echoed back, and archiving the voucher fires exactly one deactivation.
        Initialize();
        StoreCode := _Lib.CreateStore(false, false, false, false, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, false);

        // [WHEN] A balance entry appears on a voucher with no assigned gift card ID.
        InsertVoucherEntry(VoucherEntry1, Voucher, false);
        _Lib.DispatchModify(VoucherEntry1);
        // [THEN] Two tasks: the gift-card Insert plus the balance Modify, both keyed on the voucher no.
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"NPR NpRv Voucher", DummyNcTask.Type::Insert), 'A first entry on an unsynced voucher must create the gift card');
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR NpRv Voucher Entry", Voucher."No."), 'The balance entry must be sent as Modify');

        // [WHEN] The voucher has its assigned ID and another entry appears.
        _Lib.MarkAllTasksProcessed();
        _Lib.AssignEntryID(Voucher.RecordId(), CopyStr('gid://gc/' + Voucher."No.", 1, 30));
        InsertVoucherEntry(VoucherEntry2, Voucher, false);
        _Lib.DispatchModify(VoucherEntry2);
        // [THEN] Only the balance Modify - no second Insert.
        _Assert.AreEqual(1, _Lib.TaskCountTyped(Database::"NPR NpRv Voucher", DummyNcTask.Type::Insert), 'An assigned gift card must not be re-inserted');
        _Assert.AreEqual(2, _Lib.TaskCount(Database::"NPR NpRv Voucher Entry"), 'The new balance entry must be sent');

        // [WHEN] A Shopify-originated issue entry appears. [THEN] it is never echoed back.
        InsertVoucherEntry(VoucherEntry3, Voucher, true);
        _Lib.DispatchModify(VoucherEntry3);
        _Assert.AreEqual(2, _Lib.TaskCount(Database::"NPR NpRv Voucher Entry"), 'A Shopify-initiated entry must not sync back');

        // [WHEN] The voucher is archived (fresh arch row, not yet disabled at Shopify).
        ArchVoucher.Init();
        ArchVoucher."No." := _Lib.NextCode('AR', 20);
        ArchVoucher."Arch. No." := Voucher."No.";
        ArchVoucher."Voucher Type" := Voucher."Voucher Type";
        ArchVoucher.Insert(false);
        _Lib.DispatchModify(ArchVoucher);
        // [THEN] One deactivation task keyed on the original voucher no.
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR NpRv Arch. Voucher", Voucher."No."), 'A fresh archive must fire one deactivation');
        _Lib.FindLastTask(Database::"NPR NpRv Arch. Voucher", NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, 'The deactivation is a Modify');

        // [WHEN] The send writes back "Disabled at Shopify" and re-bumps the row.
        _Lib.MarkAllTasksProcessed();
        ArchVoucher."Disabled at Shopify" := true;
        ArchVoucher.Modify(false);
        _Lib.DispatchModify(ArchVoucher);
        // [THEN] No re-fire.
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR NpRv Arch. Voucher"), 'The write-back re-bump must not re-fire the deactivation');
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
    #endregion

    #region Metafields
    [Test]
    procedure GivenMetafieldEdits_ThenValueChangeFires_MirrorFieldsAndIneligibleOwnersDoNot()
    var
        Item: Record Item;
        Item2: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Link2: Record "NPR Spfy Store-Item Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        Metafield2: Record "NPR Spfy Entity Metafield";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        DisabledStoreCode: Code[20];
    begin
        // [SCENARIO] A metafield value edit creates a send task while the Shopify-owned version id write-back does not, and a metafield whose owner store has items disabled neither sends nor advances its baseline.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'v1');
        SpfySyncStateMgt.SeedEntityMetafieldBaseline(SpfyEntityMetafield);

        // [WHEN] The BLOB value changes. [THEN] the blob-aware hash detects it and a task is created.
        SpfyEntityMetafield.SetMetafieldValue('v2');
        SpfyEntityMetafield.Modify(false);
        _Lib.DispatchModify(SpfyEntityMetafield);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Entity Metafield"), 'A metafield value edit must create a send task');

        // [WHEN] Only the Shopify-owned mirror field changes. [THEN] no echo.
        _Lib.MarkAllTasksProcessed();
        SpfyEntityMetafield."Metafield Value Version ID" := 'ver-2';
        SpfyEntityMetafield.Modify(false);
        _Lib.DispatchModify(SpfyEntityMetafield);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Entity Metafield"), 'The value version ID write-back must not re-send');

        // [GIVEN] A metafield whose owner store has the Items area disabled.
        DisabledStoreCode := _Lib.CreateStore(false, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item2, Link2, DisabledStoreCode);
        _Lib.CreateMetafield(Metafield2, Database::"NPR Spfy Store-Item Link", Link2.RecordId(), 'unsent value');
        // [WHEN] It is polled. [THEN] no task AND the baseline is NOT advanced (no silent miss when enabled later).
        _Lib.DispatchModify(Metafield2);
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"NPR Spfy Entity Metafield"), 'An ineligible owner must not create a task');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Entity Metafield", Metafield2.SystemId, ''), 'An ineligible owner must not advance the baseline');
    end;

    [Test]
    procedure GivenMetafieldMappingRemoval_ThenPollOwnerKeepsTombstone_OffPollOwnerHardDeletes()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        ClearSet: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Removing metafield values keeps an empty-value tombstone row while its owner is on the rowversion poll, and hard-deletes the rows when the owner is not.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'to be deleted');
        SpfyEntityMetafield."Metafield Value Version ID" := 'ver-1';
        SpfyEntityMetafield.Modify(false);

        // [WHEN] The delete path runs while the owner is on the rowversion poll (feature on).
        ClearSet.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        ClearSet.SetRange("BC Record ID", SpfyStoreItemLink.RecordId());
        SpfyMetafieldMgt.ClearEntityMetafieldValuesAsTombstones(ClearSet);

        // [THEN] The row survives as an empty-value tombstone so the poll can send metafieldsDelete.
        SpfyEntityMetafield.Get(SpfyEntityMetafield."Entry No.");
        _Assert.AreEqual('', SpfyEntityMetafield.GetMetafieldValue(true), 'The tombstone must hold an empty value');
        _Assert.AreEqual('', SpfyEntityMetafield."Metafield Value Version ID", 'The tombstone must clear the value version ID');

        // [WHEN] The same path runs with the feature off (owner not on the poll).
        _Lib.SetFeatureEnabled(false);
        ClearSet.SetRange("BC Record ID", SpfyStoreItemLink.RecordId());
        SpfyMetafieldMgt.ClearEntityMetafieldValuesAsTombstones(ClearSet);
        // [THEN] Byte-for-byte legacy mode: the rows are hard-deleted.
        _Assert.IsFalse(SpfyEntityMetafield.Get(SpfyEntityMetafield."Entry No."), 'Off the poll, the legacy hard delete must run');
    end;
    #endregion

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
