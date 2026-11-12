codeunit 85626 "NPR Spfy Variant Rename Tests"
{
    // [FEATURE] Shopify item variant rename - the variant's Shopify identity, its change producers, its inventory levels and Shopify read-backs follow the new code
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _BndSeam: Codeunit "NPR Spfy RowVer Boundary Seam";
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndBound: Boolean;
        _LegacyQueuedResponses: List of [Text];
        _LegacyReadBackResponse: Text;

    local procedure Initialize()
    begin
        Clear(_LegacyQueuedResponses);
        _Lib.ResetState(_BndSeam, _BndBound);
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
    end;

    [Test]
    procedure GivenVariantSyncedToTwoStores_WhenCodeRenamed_ThenShopifyIdentityFollowsTheNewCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        LinkA: Record "NPR Spfy Store-Item Link";
        LinkB: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreA: Code[20];
        StoreB: Code[20];
        OldCode: Code[10];
        NewCode: Code[10];
        ProductId: Text[30];
        VariantIdA: Text[30];
        VariantIdB: Text[30];
        InventoryItemIdA: Text[30];
        InventoryItemIdB: Text[30];
    begin
        // [SCENARIO] Renaming the code of a variant synced to two stores, one of them disabled, moves its Shopify ids and variant metafield to the new code in every store and replaces a leftover filed under the new code; the next poll re-sends it once as a Modify of the new SKU; a product read-back that still reports the old SKU leaves the ids on the renamed variant.
        Initialize();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, LinkA, StoreA);
        _Lib.CreateItemLink(LinkB, Item."No.", StoreB, true, true);
        ProductId := NewShopifyId();
        _Lib.AssignEntryID(LinkA.RecordId(), ProductId);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;
        NewCode := NewVariantCode();
        VariantIdA := NewShopifyId();
        VariantIdB := NewShopifyId();
        InventoryItemIdA := NewShopifyId();
        InventoryItemIdB := NewShopifyId();

        // [GIVEN] Shopify ids in both stores, a variant metafield in store B, a leftover metafield already filed under the new code, and a seeded payload baseline.
        AssignVariantIds(Item."No.", OldCode, StoreA, VariantIdA, InventoryItemIdA);
        AssignVariantIds(Item."No.", OldCode, StoreB, VariantIdB, InventoryItemIdB);
        CreateVariantMetafield(Item."No.", OldCode, StoreB, 'Variant metafield value');
        CreateVariantMetafield(Item."No.", NewCode, StoreB, 'Leftover metafield value');
        SpfySyncStateMgt.SeedItemVariantBaseline(ItemVariant);

        // [GIVEN] Store B is disabled and the variant table is tracked from here on.
        _Lib.DisableStore(StoreB);
        _Lib.RegisterTable(Database::"Item Variant");

        // [WHEN] The variant code is renamed.
        ItemVariant.Rename(Item."No.", NewCode);

        // [THEN] Both Shopify ids live under the new code in both stores, the disabled one included, and none is left under the old code.
        AssertVariantIds(Item."No.", NewCode, StoreA, VariantIdA, InventoryItemIdA, 'Store A, new code');
        AssertVariantIds(Item."No.", OldCode, StoreA, '', '', 'Store A, old code');
        AssertVariantIds(Item."No.", NewCode, StoreB, VariantIdB, InventoryItemIdB, 'Disabled store B, new code');
        AssertVariantIds(Item."No.", OldCode, StoreB, '', '', 'Disabled store B, old code');

        // [THEN] The variant metafield moved and replaced the leftover, and none is left under the old code.
        _Assert.AreEqual('Variant metafield value;', VariantMetafieldValues(Item."No.", NewCode, StoreB), 'The variant metafield must move to the new code and replace the leftover');
        _Assert.AreEqual('', VariantMetafieldValues(Item."No.", OldCode, StoreB), 'No variant metafield may stay under the old code');

        // [WHEN] The variant table is polled.
        _Lib.PollTable(Database::"Item Variant");

        // [THEN] The rename bumped the row version and is re-sent once, as a Modify of the new SKU for the enabled store.
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Item Variant"), 'The polled rename must produce exactly one variant task');
        _Lib.FindLastTask(Database::"Item Variant", NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, StrSubstNo('The renamed variant must be re-sent as a Modify, but the task type is %1', NcTask.Type));
        _Assert.AreEqual(Format(ItemVariant.RecordId()), Format(NcTask."Record ID"), 'The task must target the renamed variant');
        _Assert.AreEqual(VariantSku(Item."No.", NewCode), NcTask."Record Value", 'The task must carry the new SKU');
        _Assert.AreEqual(StoreA, NcTask."Store Code", 'Only the enabled store may get the task');

        // [WHEN] Shopify's product read-back still reports the renamed variant under its old SKU.
        RunTaskListProductReadBack(StoreA, ProductId, VariantSku(Item."No.", OldCode), VariantIdA, InventoryItemIdA);

        // [THEN] No id lands on the item's blank-variant key and the renamed variant keeps its ids.
        AssertVariantIds(Item."No.", '', StoreA, '', '', 'Blank-variant key after the read-back');
        AssertVariantIds(Item."No.", NewCode, StoreA, VariantIdA, InventoryItemIdA, 'Store A, new code after the read-back');
    end;

    [Test]
    procedure GivenSyncedVariant_WhenRenameWouldStrandItsShopifyVariant_ThenRenameIsRefused()
    var
        Item: Record Item;
        OtherItem: Record Item;
        MovedVariant: Record "Item Variant";
        StockOnlyMovedVariant: Record "Item Variant";
        BlockedVariant: Record "Item Variant";
        NotAvailableVariant: Record "Item Variant";
        LoggedDeleteVariant: Record "Item Variant";
        DeleteTaskVariant: Record "Item Variant";
        CleanVariant: Record "Item Variant";
        StockOnlyBlockedVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StockOnlyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        StoreCode: Code[20];
        StockOnlyStoreCode: Code[20];
        OldCode: Code[10];
        NewCode: Code[10];
        CleanCode: Code[10];
        TaskTargetCode: Code[10];
        LogTargetCode: Code[10];
        StockOnlyVariantId: Text[30];
    begin
        // [SCENARIO] A variant that has a Shopify variant id or a Shopify inventory item id cannot move to another item. A variant that has a Shopify variant id cannot be renamed while its own removal from Shopify is pending (blocked, not available in the store, a delete waiting in the deletion log, or a Shopify delete task still queued), or into a code whose earlier variant's removal is still pending. Each case is refused with its own reason. A blocked variant whose id sits only in a store that does not sync items can be renamed, because no removal ever runs there.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        StockOnlyStoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateItemLink(StockOnlyStoreItemLink, Item."No.", StockOnlyStoreCode, true, true);
        _Lib.CreateItem(OtherItem);
        CreateSyncedVariant(MovedVariant, Item."No.", StoreCode);
        CreateSyncedVariant(BlockedVariant, Item."No.", StoreCode);
        CreateSyncedVariant(NotAvailableVariant, Item."No.", StoreCode);
        CreateSyncedVariant(LoggedDeleteVariant, Item."No.", StoreCode);
        CreateSyncedVariant(DeleteTaskVariant, Item."No.", StoreCode);
        CreateSyncedVariant(CleanVariant, Item."No.", StoreCode);
        CleanCode := CleanVariant.Code;
        TaskTargetCode := NewVariantCode();
        LogTargetCode := NewVariantCode();

        // [GIVEN] A variant that holds only its Shopify inventory item id, in the store that syncs stock only.
        _Lib.CreateItemVariant(StockOnlyMovedVariant, Item."No.");
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(Item."No.", StockOnlyMovedVariant.Code, StockOnlyStoreCode), "NPR Spfy ID Type"::"Inventory Item ID", NewShopifyId(), false);

        // [GIVEN] Each of the next variants has exactly one pending removal: blocked, not available in the store, a quarantined delete in the deletion log, or an unprocessed Shopify delete task under its SKU.
        BlockedVariant.Blocked := true;
        BlockedVariant.Modify(false);
        RemoveLoggedDeletes(BlockedVariant);
        _Lib.CreateVariantModif(SpfyItemVariantModif, Item."No.", NotAvailableVariant.Code, StoreCode, true);
        RemoveLoggedDeletes(NotAvailableVariant);
        LogQuarantinedDelete(LoggedDeleteVariant, StoreCode);
        InsertUnprocessedDeleteTask(Item."No.", DeleteTaskVariant.Code, StoreCode);

        // [GIVEN] The removal of earlier variants is still pending under two free codes: a Shopify Task List delete task for one, a pending deletion log entry for the other.
        InsertOpenSpfyDeleteTask(VariantSku(Item."No.", TaskTargetCode), StoreCode);
        _Lib.InsertPendingDelete(Database::"Item Variant", Item."No.", LogTargetCode, '', StoreCode, NewShopifyId());
        Commit();

        // [WHEN] A variant with a Shopify variant id is moved to another item. [THEN] The move is refused.
        asserterror MovedVariant.Rename(OtherItem."No.", MovedVariant.Code);
        _Assert.ExpectedError(MoveRefusedText(Item."No.", MovedVariant.Code));

        // [WHEN] A variant with only a Shopify inventory item id is moved to another item. [THEN] The move is refused.
        asserterror StockOnlyMovedVariant.Rename(OtherItem."No.", StockOnlyMovedVariant.Code);
        _Assert.ExpectedError(MoveRefusedText(Item."No.", StockOnlyMovedVariant.Code));

        // [WHEN] The blocked variant's code is renamed. [THEN] The rename is refused because its removal is pending.
        OldCode := BlockedVariant.Code;
        asserterror BlockedVariant.Rename(Item."No.", NewVariantCode());
        _Assert.ExpectedError(RemovalPendingText(Item."No.", OldCode, StoreCode));

        // [WHEN] The not-available variant's code is renamed. [THEN] The rename is refused because its removal is pending.
        OldCode := NotAvailableVariant.Code;
        asserterror NotAvailableVariant.Rename(Item."No.", NewVariantCode());
        _Assert.ExpectedError(RemovalPendingText(Item."No.", OldCode, StoreCode));

        // [WHEN] The code of the variant with a quarantined delete is renamed. [THEN] The rename is refused because its removal is pending.
        OldCode := LoggedDeleteVariant.Code;
        asserterror LoggedDeleteVariant.Rename(Item."No.", NewVariantCode());
        _Assert.ExpectedError(RemovalPendingText(Item."No.", OldCode, StoreCode));

        // [WHEN] The code of the variant with a queued delete task is renamed. [THEN] The rename is refused because its removal is pending.
        OldCode := DeleteTaskVariant.Code;
        asserterror DeleteTaskVariant.Rename(Item."No.", NewVariantCode());
        _Assert.ExpectedError(RemovalPendingText(Item."No.", OldCode, StoreCode));

        // [WHEN] A variant with nothing pending is renamed into the code with the earlier variant's delete task. [THEN] The rename is refused.
        asserterror CleanVariant.Rename(Item."No.", TaskTargetCode);
        _Assert.ExpectedError(EarlierRemovalPendingText(Item."No.", CleanCode, TaskTargetCode, StoreCode));

        // [WHEN] It is renamed into the code with the earlier variant's pending deletion log entry. [THEN] The rename is refused.
        CleanVariant.Get(Item."No.", CleanCode);
        asserterror CleanVariant.Rename(Item."No.", LogTargetCode);
        _Assert.ExpectedError(EarlierRemovalPendingText(Item."No.", CleanCode, LogTargetCode, StoreCode));

        // [GIVEN] A blocked variant whose Shopify variant id sits only in the store that syncs stock but not items, so blocking it logged a delete that the store can never send.
        _Lib.CreateItemVariant(StockOnlyBlockedVariant, Item."No.");
        StockOnlyVariantId := NewShopifyId();
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", StockOnlyBlockedVariant.Code, StockOnlyStoreCode), StockOnlyVariantId);
        StockOnlyBlockedVariant.Blocked := true;
        StockOnlyBlockedVariant.Modify(false);
        SpfyDeletionLog.SetRange("Table No.", Database::"Item Variant");
        SpfyDeletionLog.SetRange("Entity System Id", StockOnlyBlockedVariant.SystemId);
        SpfyDeletionLog.SetRange("Shopify Store Code", StockOnlyStoreCode);
        SpfyDeletionLog.SetRange(Status, SpfyDeletionLog.Status::Pending);
        _Assert.IsFalse(SpfyDeletionLog.IsEmpty(), 'Blocking the variant must log a pending delete for the stock-only store');

        // [WHEN] Its code is renamed. [THEN] The rename goes through and the Shopify variant id follows the new code.
        NewCode := NewVariantCode();
        StockOnlyBlockedVariant.Rename(Item."No.", NewCode);
        _Assert.AreEqual(StockOnlyVariantId, SpfyAssignedIDMgt.GetAssignedShopifyID(_Lib.VariantLinkRecordId(Item."No.", NewCode, StockOnlyStoreCode), "NPR Spfy ID Type"::"Entry ID"), 'A blocked variant in a store that does not sync items must be renameable, with its Shopify id moved');
    end;

    [Test]
    procedure GivenRenamedSyncedVariant_WhenDataLogRenamePairIsProcessed_ThenOneModifyAndItsStockIsResent()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        DeleteEntry: Record "NPR Data Log Record";
        RenameEntry: Record "NPR Data Log Record";
        AwayDeleteEntry: Record "NPR Data Log Record";
        AwayRenameEntry: Record "NPR Data Log Record";
        BackDeleteEntry: Record "NPR Data Log Record";
        BackRenameEntry: Record "NPR Data Log Record";
        NcTask: Record "NPR Nc Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
        OldRecId: RecordId;
        NewRecId: RecordId;
        AwayRecId: RecordId;
        NewCode: Code[10];
    begin
        // [SCENARIO] With the legacy Data Log producer active, a variant rename reaches Shopify as one Modify of the renamed variant under its new SKU, never as an Insert or a Delete, and the variant's stock is queued again under the new SKU. Renaming it away and straight back before the queue runs never deletes it from Shopify.
        Initialize();

        // [GIVEN] RowVersion detection is off, so Data Log is the active change producer, and a variant synced to a store that also syncs inventory.
        _Lib.SetFeatureEnabled(false);
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        AssignVariantIds(Item."No.", ItemVariant.Code, StoreCode, NewShopifyId(), NewShopifyId());

        // [GIVEN] An inventory level for the variant at the linked location.
        SpfyInventoryLevel.Init();
        SpfyInventoryLevel."Shopify Store Code" := StoreCode;
        SpfyInventoryLevel."Shopify Location ID" := ShopifyLocationId;
        SpfyInventoryLevel."Item No." := Item."No.";
        SpfyInventoryLevel."Variant Code" := ItemVariant.Code;
        SpfyInventoryLevel.Insert(false);
        OldRecId := ItemVariant.RecordId();

        // [GIVEN] The variant code is renamed and Data Log has written its rename pair: a Delete of the old key, then a Rename to the new key.
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);
        InsertDataLogRenamePair(OldRecId, ItemVariant.RecordId(), DeleteEntry, RenameEntry);

        // [WHEN] The legacy producer processes both entries in log order.
        SpfyItemMgt.ProcessDataLogRecord(DeleteEntry);
        SpfyItemMgt.ProcessDataLogRecord(RenameEntry);

        // [THEN] Exactly one variant task: a Modify of the renamed variant under its new SKU.
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Item Variant"), 'The rename pair must produce exactly one variant task');
        _Lib.FindLastTask(Database::"Item Variant", NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, StrSubstNo('The rename must be sent as a Modify, but the task type is %1', NcTask.Type));
        _Assert.AreEqual(Format(ItemVariant.RecordId()), Format(NcTask."Record ID"), 'The task must target the renamed variant');
        _Assert.AreEqual(VariantSku(Item."No.", NewCode), NcTask."Record Value", 'The task must carry the new SKU');

        // [THEN] The variant's stock is queued again under the new SKU, for the inventory level that now carries the new code.
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::"NPR Spfy Inventory Level", VariantSku(Item."No.", NewCode)), 'The renamed variant''s stock must be queued again under the new SKU');
        SpfyInventoryLevel."Variant Code" := NewCode;
        _Assert.IsTrue(SpfyInventoryLevel.Find(), 'The inventory level must follow the renamed variant');
        _Assert.AreEqual(1, _Lib.TaskCountForRecordId(Database::"NPR Spfy Inventory Level", SpfyInventoryLevel.RecordId()), 'The stock task must point at the inventory level under the new code');

        // [GIVEN] Before the queue runs again, the code is renamed away and straight back, so Data Log holds a Delete entry for a key that exists again.
        NewRecId := ItemVariant.RecordId();
        ItemVariant.Rename(Item."No.", NewVariantCode());
        AwayRecId := ItemVariant.RecordId();
        InsertDataLogRenamePair(NewRecId, AwayRecId, AwayDeleteEntry, AwayRenameEntry);
        ItemVariant.Rename(Item."No.", NewCode);
        InsertDataLogRenamePair(AwayRecId, NewRecId, BackDeleteEntry, BackRenameEntry);

        // [WHEN] The legacy producer processes the four entries in log order.
        SpfyItemMgt.ProcessDataLogRecord(AwayDeleteEntry);
        SpfyItemMgt.ProcessDataLogRecord(AwayRenameEntry);
        SpfyItemMgt.ProcessDataLogRecord(BackDeleteEntry);
        SpfyItemMgt.ProcessDataLogRecord(BackRenameEntry);

        // [THEN] No Delete is queued for the variant that came back, and the queued Modify is still the only variant task.
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Item Variant"), 'Renaming away and back must not queue another variant task');
        _Lib.FindLastTask(Database::"Item Variant", NcTask);
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Modify, StrSubstNo('Renaming away and back must never delete the variant from Shopify, but the last task type is %1', NcTask.Type));
    end;

    [Test]
    procedure GivenOpenSalesLineOnRenamedVariant_WhenLinePolled_ThenNoInventoryLevelUnderTheOldCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SalesLine: Record "Sales Line";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        LeftoverInventoryLevel: Record "NPR Spfy Inventory Level";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        LocationCode: Code[10];
        ShopifyLocationId: Text[30];
        OldCode: Code[10];
        NewCode: Code[10];
        LeftoverCode: Code[10];
    begin
        // [SCENARIO] Polling an open sales line that the rename carried to the new code recalculates the new code's inventory level and creates none under the old code; renaming the variant into a code with a leftover Shopify inventory level succeeds and keeps the variant's own level.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationCode := _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;

        // [GIVEN] An open sales order line for the variant whose inventory baseline holds the old code, and the sales line table tracked from here on.
        _Lib.CreateSalesOrderLine(SalesLine, Item."No.", OldCode, LocationCode, 5);
        SpfySyncStateMgt.SetSalesLineInvKey(SalesLine);
        _Lib.RegisterTable(Database::"Sales Line");

        // [GIVEN] The variant code is renamed, which carries the sales line to the new code.
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);

        // [WHEN] The sales line table is polled.
        _Lib.PollTable(Database::"Sales Line");

        // [THEN] No inventory level exists under the old code, and the new code's level carries the outstanding quantity.
        _Assert.IsFalse(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", OldCode), 'No inventory level may be created under the old variant code');
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", NewCode), 'The renamed variant must get its inventory level');
        _Assert.AreEqual(-5, SpfyInventoryLevel.Inventory, 'The renamed variant''s level must subtract the outstanding quantity');

        // [GIVEN] A leftover Shopify inventory level already filed under another code, from a variant deleted long ago.
        LeftoverCode := NewVariantCode();
        LeftoverInventoryLevel.Init();
        LeftoverInventoryLevel."Shopify Store Code" := StoreCode;
        LeftoverInventoryLevel."Shopify Location ID" := ShopifyLocationId;
        LeftoverInventoryLevel."Item No." := Item."No.";
        LeftoverInventoryLevel."Variant Code" := LeftoverCode;
        LeftoverInventoryLevel.Inventory := 999;
        LeftoverInventoryLevel.Insert(false);

        // [WHEN] The variant is renamed into that code.
        ItemVariant.Rename(Item."No.", LeftoverCode);

        // [THEN] The rename succeeds and the variant's own level replaced the leftover.
        _Assert.IsTrue(_Lib.GetInventoryLevel(SpfyInventoryLevel, StoreCode, ShopifyLocationId, Item."No.", LeftoverCode), 'The variant''s level must move to the code it was renamed into');
        _Assert.AreEqual(-5, SpfyInventoryLevel.Inventory, 'The variant''s own level must replace the leftover one');
    end;

    [Test]
    [HandlerFunctions('LegacyProductReadBackHandler')]
    procedure GivenShopifyStillHasTheOldSku_WhenItemIsRelinkedOrReadBack_ThenTheRenamedVariantKeepsItsShopifyIds()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ReusedCodeVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        StoreCode: Code[20];
        OldCode: Code[10];
        NewCode: Code[10];
        ProductId: Text[30];
        VariantId: Text[30];
        InventoryItemId: Text[30];
        OldSku: Text;
    begin
        // [SCENARIO] While Shopify still shows the renamed variant under its old SKU, re-linking the item from Shopify, the SKU lookup for a new variant that reuses the old code, and a legacy product read-back (the products webhook path) all leave the Shopify ids on the renamed variant.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        PrepareLegacyShopifyCall(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        ProductId := NewShopifyId();
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), ProductId);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;
        OldSku := VariantSku(Item."No.", OldCode);
        VariantId := NewShopifyId();
        InventoryItemId := NewShopifyId();
        AssignVariantIds(Item."No.", OldCode, StoreCode, VariantId, InventoryItemId);

        // [GIVEN] The variant code is renamed, and Shopify still reports the variant under the old SKU.
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);
        MockClient.AddResponse(StrSubstNo('sku:%1"', Item."No."), ProductLookupResponse(ProductId));
        MockClient.AddResponse(StrSubstNo('sku:%1"', OldSku), VariantLookupResponse(ProductId, VariantId, InventoryItemId));
        MockClient.AddResponse('GetProduct', ProductResponse(ProductId, OldSku, VariantId, InventoryItemId));
        SendItemsInv.SetGraphQLClient(MockClient);

        // [WHEN] The item is re-linked from Shopify, which clears the variant ids and reads the product back.
        ShopifyStore.SetRange(Code, StoreCode);
        SendItemsInv.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false, false);

        // [THEN] The renamed variant gets its ids back and the blank-variant key stays empty.
        AssertVariantIds(Item."No.", NewCode, StoreCode, VariantId, InventoryItemId, 'Renamed variant after the re-link');
        AssertVariantIds(Item."No.", '', StoreCode, '', '', 'Blank-variant key after the re-link');

        // [GIVEN] A new variant reuses the old code.
        CreateVariantWithCode(ReusedCodeVariant, Item."No.", OldCode);

        // [WHEN] Its Shopify variant id is looked up by SKU.
        // [THEN] The id that belongs to the renamed variant is not handed to it.
        _Assert.AreEqual('', SendItemsInv.GetShopifyVariantID(VariantLink(Item."No.", OldCode, StoreCode), false), 'A SKU lookup must not hand out a Shopify variant id that belongs to another variant');

        // [WHEN] The legacy codeunit reads the product back, as the products webhook does, while Shopify still reports the old SKU.
        _LegacyReadBackResponse := ProductResponse(ProductId, OldSku, VariantId, InventoryItemId);
        RunLegacyProductReadBack(StoreCode, ProductId);

        // [THEN] The ids stay on the renamed variant; neither the blank-variant key nor the variant that reuses the old code gets them.
        AssertVariantIds(Item."No.", NewCode, StoreCode, VariantId, InventoryItemId, 'Renamed variant after the legacy read-back');
        AssertVariantIds(Item."No.", '', StoreCode, '', '', 'Blank-variant key after the legacy read-back');
        AssertVariantIds(Item."No.", OldCode, StoreCode, '', '', 'Variant reusing the old code after the legacy read-back');
    end;

    [Test]
    [HandlerFunctions('LegacyProductReadBackHandler')]
    procedure GivenStockOnlyStore_WhenNewVariantReusesRenamedCode_ThenStockLookupTakesNoInventoryItemTheRenamedVariantHolds()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ReusedCodeVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SendItemsInventory: Codeunit "NPR Spfy Send Items&Inventory";
        StoreCode: Code[20];
        OldCode: Code[10];
        InventoryItemId: Text[30];
    begin
        // [SCENARIO] In a store that syncs stock but not items, a variant often holds only the Shopify inventory item id that its first stock send found by SKU. After its code is renamed, Shopify still has the old SKU, so a new variant that reuses the old code finds the same Shopify variant by SKU. The lookup must not hand it the inventory item the renamed variant holds, or both variants send their stock to one Shopify variant.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        PrepareLegacyShopifyCall(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;
        InventoryItemId := NewShopifyId();

        // [GIVEN] The variant holds only its Shopify inventory item id, and its code is renamed.
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(Item."No.", OldCode, StoreCode), "NPR Spfy ID Type"::"Inventory Item ID", InventoryItemId, false);
        ItemVariant.Rename(Item."No.", NewVariantCode());

        // [GIVEN] A new variant reuses the old code, and Shopify still reports the renamed variant under the old SKU.
        CreateVariantWithCode(ReusedCodeVariant, Item."No.", OldCode);
        _LegacyReadBackResponse := VariantLookupResponse(NewShopifyId(), NewShopifyId(), InventoryItemId);

        // [WHEN] The stock send for the new variant looks up its Shopify inventory item by SKU.
        // [THEN] It does not get the inventory item that belongs to the renamed variant.
        _Assert.AreEqual('', SendItemsInventory.GetShopifyInventoryItemID(VariantLink(Item."No.", OldCode, StoreCode), false), 'A SKU lookup must not hand out a Shopify inventory item id that belongs to another variant');
    end;

    [Test]
    [HandlerFunctions('LegacyProductReadBackHandler')]
    procedure GivenStockOnlyStore_WhenReadBackStillShowsTheOldSkuOfARenamedVariant_ThenTheRenamedVariantKeepsItsShopifyIds()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ReusedCodeVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        OldCode: Code[10];
        NewCode: Code[10];
        ProductId: Text[30];
        VariantId: Text[30];
        InventoryItemId: Text[30];
    begin
        // [SCENARIO] In a store that syncs stock but not items, Shopify keeps the old SKU of a renamed variant, the item often has no Shopify product id stored, and the variant often holds only its Shopify inventory item id. A product read-back (the products webhook path) must still give the Shopify variant to the renamed variant, matched by that inventory item id, also when a new variant now uses the old code. Otherwise the renamed variant stops sending stock, or two variants end up on one Shopify variant.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        PrepareLegacyShopifyCall(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;
        ProductId := NewShopifyId();
        VariantId := NewShopifyId();
        InventoryItemId := NewShopifyId();

        // [GIVEN] The item has no Shopify product id, the variant holds only its Shopify inventory item id, its code is renamed, and a new variant reuses the old code.
        AssignInventoryItemId(Item."No.", OldCode, StoreCode, InventoryItemId);
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);
        CreateVariantWithCode(ReusedCodeVariant, Item."No.", OldCode);

        // [WHEN] The legacy codeunit reads the product back, as the products webhook does, while Shopify still reports the old SKU.
        _LegacyReadBackResponse := ProductResponse(ProductId, VariantSku(Item."No.", OldCode), VariantId, InventoryItemId);
        RunLegacyProductReadBack(StoreCode, ProductId);

        // [THEN] The renamed variant holds the Shopify ids; neither the variant that reuses the old code nor the blank-variant key gets them.
        AssertVariantIds(Item."No.", NewCode, StoreCode, VariantId, InventoryItemId, 'Renamed variant after the read-back');
        AssertVariantIds(Item."No.", OldCode, StoreCode, '', '', 'Variant reusing the old code after the read-back');
        AssertVariantIds(Item."No.", '', StoreCode, '', '', 'Blank-variant key after the read-back');
    end;

    [Test]
    [HandlerFunctions('LegacyProductReadBackHandler')]
    procedure GivenStockOnlyVariantWithOnlyItsInventoryItemId_WhenRenamedAndItemRelinked_ThenTheRenamedVariantKeepsItsShopifyIds()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        SendItemsInventory: Codeunit "NPR Spfy Send Items&Inventory";
        StoreCode: Code[20];
        NewCode: Code[10];
        ProductId: Text[30];
        VariantId: Text[30];
        InventoryItemId: Text[30];
        OldSku: Text;
    begin
        // [SCENARIO] In a store that syncs stock but not items, a variant often holds only its Shopify inventory item id. Re-linking the item from Shopify clears the variant ids and reads the product back. After a rename, Shopify still shows the old SKU, so the re-link must give the Shopify variant back to the renamed variant by its inventory item id, through the Task List codeunit and the legacy one.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        PrepareLegacyShopifyCall(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldSku := VariantSku(Item."No.", ItemVariant.Code);
        ProductId := NewShopifyId();
        VariantId := NewShopifyId();
        InventoryItemId := NewShopifyId();

        // [GIVEN] The variant holds only its Shopify inventory item id, and its code is renamed.
        AssignInventoryItemId(Item."No.", ItemVariant.Code, StoreCode, InventoryItemId);
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);
        ShopifyStore.SetRange(Code, StoreCode);

        // [WHEN] The item is re-linked from Shopify through the Task List codeunit.
        MockClient.AddResponse(StrSubstNo('sku:%1"', Item."No."), ProductLookupResponse(ProductId));
        MockClient.AddResponse('GetProduct', ProductResponse(ProductId, OldSku, VariantId, InventoryItemId));
        SendItemsInv.SetGraphQLClient(MockClient);
        SendItemsInv.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false, false);

        // [THEN] The renamed variant holds the Shopify ids and the blank-variant key stays empty.
        AssertVariantIds(Item."No.", NewCode, StoreCode, VariantId, InventoryItemId, 'Renamed variant after the Task List re-link');
        AssertVariantIds(Item."No.", '', StoreCode, '', '', 'Blank-variant key after the Task List re-link');

        // [GIVEN] The variant again holds only its Shopify inventory item id.
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(_Lib.VariantLinkRecordId(Item."No.", NewCode, StoreCode), "NPR Spfy ID Type"::"Entry ID");

        // [WHEN] The item is re-linked from Shopify through the legacy codeunit.
        _LegacyQueuedResponses.Add(ProductLookupResponse(ProductId));
        _LegacyReadBackResponse := ProductResponse(ProductId, OldSku, VariantId, InventoryItemId);
        SendItemsInventory.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false, false);

        // [THEN] The renamed variant holds the Shopify ids and the blank-variant key stays empty.
        AssertVariantIds(Item."No.", NewCode, StoreCode, VariantId, InventoryItemId, 'Renamed variant after the legacy re-link');
        AssertVariantIds(Item."No.", '', StoreCode, '', '', 'Blank-variant key after the legacy re-link');
    end;

    [Test]
    procedure GivenShopifyVariantsSharingOneInventoryItem_WhenReadBack_ThenNoVariantTakesAnotherShopifyVariantId()
    var
        Item: Record Item;
        VariantA: Record "Item Variant";
        VariantB: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        StoreCode: Code[20];
        ProductId: Text[30];
        VariantIdA: Text[30];
        VariantIdB: Text[30];
        SharedInventoryItemId: Text[30];
    begin
        // [SCENARIO] In Shopify several variants can share one inventory item. A read-back that meets a Shopify variant matching a BC variant only by that shared inventory item, while the BC variant already holds another Shopify variant id, must not give the new Shopify variant id to it.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        ProductId := NewShopifyId();
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), ProductId);
        _Lib.CreateItemVariant(VariantA, Item."No.");
        _Lib.CreateItemVariant(VariantB, Item."No.");
        VariantIdA := NewShopifyId();
        VariantIdB := NewShopifyId();
        SharedInventoryItemId := NewShopifyId();

        // [GIVEN] Variant A holds Shopify variant id A and the shared inventory item.
        AssignVariantIds(Item."No.", VariantA.Code, StoreCode, VariantIdA, SharedInventoryItemId);

        // [WHEN] The read-back reports Shopify variant B, under variant B's SKU, with the shared inventory item.
        RunTaskListProductReadBack(StoreCode, ProductId, VariantSku(Item."No.", VariantB.Code), VariantIdB, SharedInventoryItemId);

        // [THEN] Variant A keeps Shopify variant id A, and variant B gets Shopify variant id B.
        _Assert.AreEqual(VariantIdA, AssignedShopifyVariantId(Item."No.", VariantA.Code, StoreCode), 'Variant A must keep its own Shopify variant id');
        _Assert.AreEqual(VariantIdB, AssignedShopifyVariantId(Item."No.", VariantB.Code, StoreCode), 'Variant B must get the Shopify variant its SKU names');
    end;

    [Test]
    procedure GivenBlockedVariantWhileItsStoreIsSwitchedOff_WhenCodeRenamed_ThenItsPendingShopifyDeleteFollowsTheNewCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
        StoreCode: Code[20];
        NewCode: Code[10];
    begin
        // [SCENARIO] While a store is switched off, the Shopify delete of a variant blocked in that store waits in the deletion log, and the variant code can be renamed. The waiting delete must follow the new code. Otherwise, once the store is switched on again, the delete is built for a variant that no longer exists and the blocked variant stays on sale in Shopify.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        CreateSyncedVariant(ItemVariant, Item."No.", StoreCode);

        // [GIVEN] The variant is blocked, which logs a pending Shopify delete, and then the store is switched off.
        ItemVariant.Blocked := true;
        ItemVariant.Modify(false);
        SpfyDeletionLog.SetRange("Table No.", Database::"Item Variant");
        SpfyDeletionLog.SetRange("Entity System Id", ItemVariant.SystemId);
        SpfyDeletionLog.SetRange(Status, SpfyDeletionLog.Status::Pending);
        _Assert.IsTrue(SpfyDeletionLog.FindFirst(), 'Blocking the synced variant must log a pending Shopify delete');
        _Lib.DisableStore(StoreCode);

        // [WHEN] The variant code is renamed.
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);

        // [THEN] The pending delete points at the new code.
        SpfyDeletionLog.FindFirst();
        _Assert.AreEqual(NewCode, SpfyDeletionLog."Variant Code", 'The pending Shopify delete must follow the renamed variant');
    end;

    [Test]
    [HandlerFunctions('LegacyProductReadBackHandler')]
    procedure GivenStockOnlyStore_WhenStockSendFindsVariantBySku_ThenOldSkuOrderAfterRenameLandsOnTheRenamedVariant()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ReusedCodeVariant: Record "Item Variant";
        ResolvedItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        InventoryLocation: Record "NPR Spfy Inv Item Location";
        NcTask: Record "NPR Nc Task";
        SendItemsInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        StoreCode: Code[20];
        OldCode: Code[10];
        NewCode: Code[10];
        VariantId: Text[30];
        InventoryItemId: Text[30];
        FoundInventoryItemId: Text[30];
        Sku: Text;
    begin
        // [SCENARIO] In a store that syncs stock but not items, a variant's first stock send finds it by SKU and keeps only the Shopify inventory item id. A Shopify variant id would make the variant impossible to delete in BC, because a store that does not sync items never sends the removal. Once the variant is renamed, an order that still carries the old SKU must land on the renamed variant through that inventory item id, because its stock is the one sent to that Shopify variant. That holds also when a new variant now uses the old code.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        PrepareLegacyShopifyCall(StoreCode);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        OldCode := ItemVariant.Code;
        VariantId := NewShopifyId();
        InventoryItemId := NewShopifyId();

        // [GIVEN] The variant has no Shopify ids yet, and Shopify has it under its SKU.
        _LegacyReadBackResponse := VariantLookupResponse(NewShopifyId(), VariantId, InventoryItemId);
        InventoryLocation."Shopify Store Code" := StoreCode;
        InventoryLocation."Item No." := Item."No.";
        InventoryLocation."Variant Code" := OldCode;

        // [WHEN] Its first stock send looks up the Shopify inventory item.
        _Assert.IsTrue(SendItemsInventory.ValidateInventoryItem(NcTask, InventoryLocation, FoundInventoryItemId), 'The stock send must find the variant''s Shopify inventory item by SKU');

        // [THEN] The variant keeps only the Shopify inventory item id.
        AssertVariantIds(Item."No.", OldCode, StoreCode, '', InventoryItemId, 'Variant after its first stock send');

        // [WHEN] The variant is renamed, and an order that still carries the old SKU is imported.
        NewCode := NewVariantCode();
        ItemVariant.Rename(Item."No.", NewCode);
        _Assert.IsTrue(SpfyItemMgt.ParseItemForDocumentImport(StoreCode, OrderLine(VariantSku(Item."No.", OldCode), VariantId, InventoryItemId), ResolvedItemVariant, Sku), 'The order line must resolve');

        // [THEN] The order line lands on the renamed variant.
        _Assert.AreEqual(NewCode, ResolvedItemVariant.Code, 'An order with the old SKU must land on the renamed variant');

        // [WHEN] A new variant now uses the old code, and the same order line is imported.
        CreateVariantWithCode(ReusedCodeVariant, Item."No.", OldCode);
        _Assert.IsTrue(SpfyItemMgt.ParseItemForDocumentImport(StoreCode, OrderLine(VariantSku(Item."No.", OldCode), VariantId, InventoryItemId), ResolvedItemVariant, Sku), 'The order line must resolve with the old code reused');

        // [THEN] The order line still lands on the renamed variant.
        _Assert.AreEqual(NewCode, ResolvedItemVariant.Code, 'An order with the old SKU must land on the renamed variant also when a new variant uses the old code');
    end;

    [HttpClientHandler]
    procedure LegacyProductReadBackHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        Response.HttpStatusCode := 200;
        if _LegacyQueuedResponses.Count() > 0 then begin
            Response.Content.WriteFrom(_LegacyQueuedResponses.Get(1));
            _LegacyQueuedResponses.RemoveAt(1);
        end else
            Response.Content.WriteFrom(_LegacyReadBackResponse);
        exit(false);
    end;

    local procedure CreateSyncedVariant(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; StoreCode: Code[20])
    begin
        _Lib.CreateItemVariant(ItemVariant, ItemNo);
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, ItemVariant.Code, StoreCode), NewShopifyId());
    end;

    local procedure CreateVariantWithCode(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; VariantCode: Code[10])
    begin
        ItemVariant.Init();
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := VariantCode;
        ItemVariant."NPR Variety 1 Value" := 'W';
        ItemVariant.Insert(false);
    end;

    local procedure AssignVariantIds(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; ShopifyVariantId: Text[30]; ShopifyInventoryItemId: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), ShopifyVariantId);
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemId, false);
    end;

    local procedure AssertVariantIds(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; ExpectedVariantId: Text; ExpectedInventoryItemId: Text; Context: Text)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        VariantLinkRecId: RecordId;
    begin
        VariantLinkRecId := _Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode);
        _Assert.AreEqual(ExpectedVariantId, SpfyAssignedIDMgt.GetAssignedShopifyID(VariantLinkRecId, "NPR Spfy ID Type"::"Entry ID"), StrSubstNo('%1: Shopify variant id', Context));
        _Assert.AreEqual(ExpectedInventoryItemId, SpfyAssignedIDMgt.GetAssignedShopifyID(VariantLinkRecId, "NPR Spfy ID Type"::"Inventory Item ID"), StrSubstNo('%1: Shopify inventory item id', Context));
    end;

    local procedure AssignInventoryItemId(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; ShopifyInventoryItemId: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAssignedIDMgt.AssignShopifyID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), "NPR Spfy ID Type"::"Inventory Item ID", ShopifyInventoryItemId, false);
    end;

    local procedure AssignedShopifyVariantId(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]): Text
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(_Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), "NPR Spfy ID Type"::"Entry ID"));
    end;

    local procedure MoveRefusedText(ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        MoveRefusedTok: Label 'You cannot move item %1 variant %2 to another item', Locked = true;
    begin
        exit(StrSubstNo(MoveRefusedTok, ItemNo, VariantCode));
    end;

    local procedure RemovalPendingText(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]): Text
    var
        RemovalPendingTok: Label 'You cannot rename item %1 variant %2 while its removal from Shopify store %3 is pending', Locked = true;
    begin
        exit(StrSubstNo(RemovalPendingTok, ItemNo, VariantCode, StoreCode));
    end;

    local procedure EarlierRemovalPendingText(ItemNo: Code[20]; VariantCode: Code[10]; TargetCode: Code[10]; StoreCode: Code[20]): Text
    var
        EarlierRemovalPendingTok: Label 'You cannot rename item %1 variant %2 to %3 while the removal of an earlier variant %3 from Shopify store %4 is pending', Locked = true;
    begin
        exit(StrSubstNo(EarlierRemovalPendingTok, ItemNo, VariantCode, TargetCode, StoreCode));
    end;

    local procedure RemoveLoggedDeletes(ItemVariant: Record "Item Variant")
    var
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
    begin
        SpfyDeletionLog.SetRange("Table No.", Database::"Item Variant");
        SpfyDeletionLog.SetRange("Entity System Id", ItemVariant.SystemId);
        SpfyDeletionLog.DeleteAll(false);
    end;

    local procedure LogQuarantinedDelete(ItemVariant: Record "Item Variant"; StoreCode: Code[20])
    var
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
    begin
        SpfyDeletionLog.Init();
        SpfyDeletionLog."Table No." := Database::"Item Variant";
        SpfyDeletionLog."Item No." := ItemVariant."Item No.";
        SpfyDeletionLog."Variant Code" := ItemVariant.Code;
        SpfyDeletionLog."Entity System Id" := ItemVariant.SystemId;
        SpfyDeletionLog."Shopify Store Code" := StoreCode;
        SpfyDeletionLog."Shopify ID Type" := "NPR Spfy ID Type"::"Entry ID";
        SpfyDeletionLog."Shopify ID" := AssignedShopifyVariantId(ItemVariant."Item No.", ItemVariant.Code, StoreCode);
        SpfyDeletionLog.Status := SpfyDeletionLog.Status::Quarantined;
        SpfyDeletionLog.Insert(true);
    end;

    local procedure InsertOpenSpfyDeleteTask(Sku: Text; StoreCode: Code[20])
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Init();
        SpfyTask.Type := SpfyTask.Type::Delete;
        SpfyTask."Table No." := Database::"Item Variant";
        SpfyTask."Record Value" := CopyStr(Sku, 1, MaxStrLen(SpfyTask."Record Value"));
        SpfyTask."Store Code" := StoreCode;
        SpfyTask.Insert(false);
    end;

    local procedure CreateVariantMetafield(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; MetafieldValue: Text)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", _Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode), MetafieldValue);
        SpfyEntityMetafield."Owner Type" := SpfyEntityMetafield."Owner Type"::PRODUCTVARIANT;
        SpfyEntityMetafield.Modify(false);
    end;

    local procedure VariantMetafieldValues(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]) MetafieldValues: Text
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        SpfyEntityMetafield.SetRange("Table No.", Database::"NPR Spfy Store-Item Link");
        SpfyEntityMetafield.SetRange("BC Record ID", _Lib.VariantLinkRecordId(ItemNo, VariantCode, StoreCode));
        if SpfyEntityMetafield.FindSet() then
            repeat
                MetafieldValues += SpfyEntityMetafield.GetMetafieldValue(true) + ';';
            until SpfyEntityMetafield.Next() = 0;
    end;

    local procedure InsertUnprocessedDeleteTask(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    var
        ItemVariant: Record "Item Variant";
        NcTask: Record "NPR Nc Task";
    begin
        ItemVariant.Get(ItemNo, VariantCode);
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask.Type := NcTask.Type::Delete;
        NcTask."Table No." := Database::"Item Variant";
        NcTask."Record ID" := ItemVariant.RecordId();
        NcTask."Record Value" := CopyStr(VariantSku(ItemNo, VariantCode), 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Store Code" := StoreCode;
        NcTask.Insert(false);
    end;

    local procedure InsertDataLogRenamePair(OldRecId: RecordId; NewRecId: RecordId; var DeleteEntry: Record "NPR Data Log Record"; var RenameEntry: Record "NPR Data Log Record")
    begin
        DeleteEntry.Init();
        DeleteEntry."Entry No." := 0;
        DeleteEntry."Record ID" := OldRecId;
        DeleteEntry."Table ID" := OldRecId.TableNo();
        DeleteEntry."Type of Change" := DeleteEntry."Type of Change"::Delete;
        DeleteEntry.Insert(false);

        RenameEntry.Init();
        RenameEntry."Entry No." := 0;
        RenameEntry."Record ID" := NewRecId;
        RenameEntry."Old Record ID" := OldRecId;
        RenameEntry."Table ID" := NewRecId.TableNo();
        RenameEntry."Type of Change" := RenameEntry."Type of Change"::Rename;
        RenameEntry.Insert(false);
    end;

    local procedure RunTaskListProductReadBack(StoreCode: Code[20]; ShopifyProductId: Text[30]; Sku: Text; ShopifyVariantId: Text[30]; ShopifyInventoryItemId: Text[30])
    var
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
    begin
        MockClient.AddResponse('GetProduct', ProductResponse(ShopifyProductId, Sku, ShopifyVariantId, ShopifyInventoryItemId));
        SendItemsInv.SetGraphQLClient(MockClient);
        SpfyTask."Store Code" := StoreCode;
        SpfyTask.Type := SpfyTask.Type::Modify;
        SendItemsInv.RetrieveShopifyProductAndUpdateItemWithDataFromShopify(SpfyTask, ShopifyProductId, false, false);
    end;

    local procedure PrepareLegacyShopifyCall(StoreCode: Code[20])
    var
        ShopifyStore: Record "NPR Spfy Store";
        LibraryEntria: Codeunit "NPR Library - Entria";
    begin
        LibraryEntria.SetHttpClientRequestsAllowed(true);
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Shopify Url" := 'https://zzcore465.myshopify.com';
        ShopifyStore."Shopify Access Token" := 'zz-token';
        ShopifyStore.Modify(false);
        _Lib.EnableStore(StoreCode);
    end;

    local procedure RunLegacyProductReadBack(StoreCode: Code[20]; ShopifyProductId: Text[30])
    var
        NcTask: Record "NPR Nc Task";
        SendItemsInventory: Codeunit "NPR Spfy Send Items&Inventory";
    begin
        NcTask."Store Code" := StoreCode;
        NcTask.Type := NcTask.Type::Modify;
        SendItemsInventory.RetrieveShopifyProductAndUpdateItemWithDataFromShopify(NcTask, ShopifyProductId, false, false);
    end;

    local procedure ProductResponse(ShopifyProductId: Text[30]; Sku: Text; ShopifyVariantId: Text[30]; ShopifyInventoryItemId: Text[30]): Text
    var
        ProductResponseTok: Label '{"data":{"product":{"id":"gid://shopify/Product/%1","title":"","status":"ACTIVE","descriptionHtml":"","vendor":"","hasOnlyDefaultVariant":false,"variants":{"pageInfo":{"hasNextPage":false},"edges":[{"cursor":"CURSOR1","node":{"id":"gid://shopify/ProductVariant/%2","sku":"%3","barcode":"","selectedOptions":[],"inventoryPolicy":"DENY","inventoryItem":{"id":"gid://shopify/InventoryItem/%4","tracked":true}}}]}}}}', Locked = true;
    begin
        exit(StrSubstNo(ProductResponseTok, ShopifyProductId, ShopifyVariantId, Sku, ShopifyInventoryItemId));
    end;

    local procedure ProductLookupResponse(ShopifyProductId: Text[30]): Text
    var
        ProductLookupResponseTok: Label '{"data":{"productVariants":{"edges":[{"node":{"product":{"id":"gid://shopify/Product/%1"}}}]}}}', Locked = true;
    begin
        exit(StrSubstNo(ProductLookupResponseTok, ShopifyProductId));
    end;

    local procedure VariantLookupResponse(ShopifyProductId: Text[30]; ShopifyVariantId: Text[30]; ShopifyInventoryItemId: Text[30]): Text
    var
        VariantLookupResponseTok: Label '{"data":{"productVariants":{"edges":[{"node":{"id":"gid://shopify/ProductVariant/%2","product":{"id":"gid://shopify/Product/%1"},"inventoryItem":{"id":"gid://shopify/InventoryItem/%3"}}}]}}}', Locked = true;
    begin
        exit(StrSubstNo(VariantLookupResponseTok, ShopifyProductId, ShopifyVariantId, ShopifyInventoryItemId));
    end;

    local procedure OrderLine(Sku: Text; ShopifyVariantId: Text[30]; ShopifyInventoryItemId: Text[30]) LineToken: JsonToken
    var
        OrderLineTok: Label '{"sku":"%1","variant":{"id":"gid://shopify/ProductVariant/%2","inventoryItem":{"id":"gid://shopify/InventoryItem/%3"}}}', Locked = true;
    begin
        LineToken.ReadFrom(StrSubstNo(OrderLineTok, Sku, ShopifyVariantId, ShopifyInventoryItemId));
    end;

    local procedure VariantLink(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]) SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link"
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemNo;
        SpfyStoreItemVariantLink."Variant Code" := VariantCode;
        SpfyStoreItemVariantLink."Shopify Store Code" := StoreCode;
    end;

    local procedure NewShopifyId(): Text[30]
    begin
        exit(_Lib.NextCode('SID', 20));
    end;

    local procedure NewVariantCode(): Code[10]
    var
        ItemVariant: Record "Item Variant";
    begin
        exit(CopyStr(_Lib.NextCode('R', MaxStrLen(ItemVariant.Code)), 1, MaxStrLen(ItemVariant.Code)));
    end;

    local procedure VariantSku(ItemNo: Code[20]; VariantCode: Code[10]): Text
    begin
        exit(ItemNo + '_' + VariantCode);
    end;
}
