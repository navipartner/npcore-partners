codeunit 85288 "NPR Spfy RowVer Resync Tests"
{
    // [FEATURE] Shopify RowVersion change detection - re-sync / drift-recovery tooling: per-table reset policy + administrative flows (real DB)
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

    #region Table Policy
    [Test]
    procedure GetTablePolicy_BaselineResetTables()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        Reset: Enum "NPR Spfy Resync Table Policy";
    begin
        // [SCENARIO] Every baseline-backed table resolves to the Baseline Reset re-sync policy.
        // [GIVEN] The baseline-backed tables. [THEN] each maps to Baseline Reset.
        Reset := "NPR Spfy Resync Table Policy"::"Baseline Reset";
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::Item) = Reset, 'Item');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Item Variant") = Reset, 'Item Variant');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Store-Item Link") = Reset, 'Store-Item Link');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Item Variant Modif.") = Reset, 'Variant Modif.');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Entity Metafield") = Reset, 'Entity Metafield');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Store-Customer Link") = Reset, 'Store-Customer Link');
    end;

    [Test]
    procedure GetTablePolicy_MarkOnlyTables()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        MarkOnly: Enum "NPR Spfy Resync Table Policy";
    begin
        // [SCENARIO] Move-key trigger tables and baseline-less polled tables resolve to the Mark-Only Requeue re-sync policy.
        MarkOnly := "NPR Spfy Resync Table Policy"::"Mark-Only Requeue";
        // Move-key trigger tables keep their baseline so a re-scan heals the abandoned location.
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Sales Line") = MarkOnly, 'Sales Line must be Mark-Only');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Transfer Line") = MarkOnly, 'Transfer Line must be Mark-Only');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Stockkeeping Unit") = MarkOnly, 'SKU must be Mark-Only');
        // Baseline-less polled tables.
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Item Reference") = MarkOnly, 'Item Reference');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Inventory Level") = MarkOnly, 'Inventory Level');
    end;

    [Test]
    procedure GetTablePolicy_ItemLedgerEntryFastForwardOnly()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
    begin
        // [SCENARIO] The Item Ledger Entry resolves to the Fast-Forward Only re-sync policy.
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"Item Ledger Entry") = "NPR Spfy Resync Table Policy"::"Fast-Forward Only", 'ILE must be Fast-Forward Only');
    end;

    [Test]
    procedure GetTablePolicy_BlockedTables()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        Blocked: Enum "NPR Spfy Resync Table Policy";
    begin
        // [SCENARIO] The voucher tables and the Item Price resolve to the Blocked re-sync policy.
        Blocked := "NPR Spfy Resync Table Policy"::Blocked;
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR NpRv Voucher") = Blocked, 'Voucher');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR NpRv Voucher Entry") = Blocked, 'Voucher Entry');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR NpRv Arch. Voucher") = Blocked, 'Arch. Voucher');
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::"NPR Spfy Item Price") = Blocked, 'Item Price');
    end;

    [Test]
    procedure GetTablePolicy_UnknownTableDefaultsMarkOnly()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
    begin
        // [SCENARIO] A table that is not in the policy map falls back to the safe Mark-Only Requeue policy.
        // A table not in the policy map falls back to the safe Mark-Only default.
        _Assert.IsTrue(SpfyResyncMgt.GetTablePolicy(Database::Currency) = "NPR Spfy Resync Table Policy"::"Mark-Only Requeue", 'Unmapped table must default to Mark-Only');
    end;
    #endregion

    #region Administrative Flows
    [Test]
    procedure GivenFullResync_ThenBaselinesClearedMarksReset_IleAndVouchersUntouched()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        Voucher: Record "NPR NpRv Voucher";
        SalesLine: Record "Sales Line";
        ResyncRun: Record "NPR Spfy Resync Run";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        StoreCode: Code[20];
        PreviewBaselines: Integer;
        PreviewMarks: Integer;
    begin
        // [SCENARIO] A full re-sync clears every baseline-backed table and resets its mark, keeps the move-key baselines of mark-only tables, leaves ledger-entry and voucher tracking untouched, and completes with the counts its dry-run preview promised.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, true, true);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.CreateVariantModif(SpfyItemVariantModif, Item."No.", ItemVariant.Code, StoreCode, false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'v1');
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);
        _Lib.CreateSalesOrderLine(SalesLine, Item."No.", '', '', 5);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreCode);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);
        SpfySyncStateMgt.SeedItemVariantBaseline(ItemVariant);
        SpfySyncStateMgt.SeedItemVariantModifBaseline(SpfyItemVariantModif);
        SpfySyncStateMgt.SeedEntityMetafieldBaseline(SpfyEntityMetafield);
        SpfySyncStateMgt.SeedStoreCustomerLinkBaseline(SpfyStoreCustomerLink);
        SpfySyncStateMgt.SeedVoucherBaseline(Voucher, StoreCode);
        SpfySyncStateMgt.SetSalesLineInvKey(SalesLine);
        _Lib.RegisterEnabledTables();
        _Lib.SetMark(Database::"Item Ledger Entry", 777777);
        _Lib.SetMark(Database::"NPR NpRv Voucher", 555);

        // [WHEN] The dry-run preview and then the full re-sync execute.
        ResyncRun.Init();
        ResyncRun.Scope := ResyncRun.Scope::"Full Resync";
        SpfyResyncMgt.PreviewRunCounts(ResyncRun, PreviewBaselines, PreviewMarks);
        _Lib.RunBulkResync(ResyncRun);

        // [THEN] Every baseline-backed table is cleared and its mark reset to 0.
        _Assert.IsFalse(_Lib.HasBaseline(Database::Item, Item.SystemId, StoreCode), 'Item baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, StoreCode), 'Link baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"Item Variant", ItemVariant.SystemId, ''), 'Variant baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, StoreCode), 'Variant modif baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, ''), 'Metafield baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.SystemId, StoreCode), 'Customer link baseline must be cleared');
        _Assert.IsTrue(_Lib.GetMark(Database::Item) = 0, 'Item mark must reset to 0');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") = 0, 'Link mark must reset to 0');
        _Assert.IsTrue(_Lib.GetMark(Database::"Sales Line") = 0, 'Sales Line mark must reset to 0 (mark-only requeue)');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Inventory Level") = 0, 'Inventory Level mark must reset to 0');

        // [THEN] Mark-only trigger tables KEEP their move-key baselines - a re-scan can heal a moved location.
        _Assert.IsTrue(_Lib.HasBaseline(Database::"Sales Line", SalesLine.SystemId, ''), 'The sales line move-key baseline must be KEPT (mark-only requeue)');

        // [THEN] The ILE mark is left completely untouched - not reset and not fast-forwarded.
        _Assert.IsTrue(_Lib.GetMark(Database::"Item Ledger Entry") = 777777, 'The ILE mark must be left untouched by a full re-sync');

        // [THEN] Voucher detection state is never touched.
        _Assert.IsTrue(_Lib.HasBaseline(Database::"NPR NpRv Voucher", Voucher.SystemId, StoreCode), 'Voucher baselines must never be cleared');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR NpRv Voucher") = 555, 'Voucher marks must never be reset');

        // [THEN] The run row completes with counts that exactly match the dry-run preview.
        ResyncRun.Find();
        _Assert.IsTrue(ResyncRun.Status = ResyncRun.Status::Completed, 'The run must complete');
        _Assert.AreEqual(PreviewBaselines, ResyncRun."Baselines Cleared", 'Executed baseline count must equal the preview');
        _Assert.AreEqual(PreviewMarks, ResyncRun."Marks Reset", 'Executed mark count must equal the preview');
        _Assert.IsTrue(ResyncRun."Baselines Cleared" > 0, 'The run must have cleared baselines');
    end;

    [Test]
    procedure GivenBlockedTables_WhenTableResetInvoked_ThenRefusedWithRationale()
    var
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
    begin
        // [SCENARIO] A table reset is refused with its rationale for the voucher tables, the Item Price and the Item Ledger Entry, and every re-sync entry point is refused while the feature is off.
        Initialize();
        Commit();   // the asserterror rollbacks must not undo the feature/setup fixture

        // [WHEN] A voucher table reset is attempted. [THEN] refused: wiping the baseline loses one change per voucher.
        asserterror SpfyResyncMgt.StartTableResync(Database::"NPR NpRv Voucher");
        _Assert.ExpectedError('Tracking for Retail Vouchers cannot be reset');

        // [WHEN] An Item Price reset is attempted. [THEN] refused: the value-gate keeps no baseline to un-drift.
        asserterror SpfyResyncMgt.StartTableResync(Database::"NPR Spfy Item Price");
        _Assert.ExpectedError('Tracking for Item Prices cannot be reset');

        // [WHEN] An ILE reset is attempted. [THEN] refused, pointing at fast-forward instead.
        asserterror SpfyResyncMgt.StartTableResync(Database::"Item Ledger Entry");
        _Assert.ExpectedError('cannot be reset to 0');

        // [WHEN] The feature is off. [THEN] every re-sync entry point is gated.
        _Lib.SetFeatureEnabled(false);
        asserterror SpfyResyncMgt.StartTableResync(Database::Item);
        _Assert.ExpectedError('RowVersion change detection is not enabled');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,SinkMessageHandler')]
    procedure GivenSingleItemRepush_ThenCascadeClearsAndBumps_SkipsIneligible_AndConvergesInOneCycle()
    var
        Item: Record Item;
        GoodVariant: Record "Item Variant";
        BlockedVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        LocationId: Text[30];
        DeletionRowsBefore: Integer;
        LevelUpdatedBefore: DateTime;
        TasksAfterFirstCycle: Integer;
    begin
        // [SCENARIO] A single-item re-push clears the item's whole cascade and bumps its inventory, skips an ineligible variant, logs no delete intent, re-sends the item graph on the next detection cycle and stays quiet afterwards.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Last Direct Cost" := 10;
        Item."Item Category Code" := _Lib.CreateItemCategory('Repush tag');
        Item.Modify(false);
        _Lib.CreateLocationWithLink(StoreCode, LocationId);
        _Lib.CreateItemVariant(GoodVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", GoodVariant.Code, StoreCode), 'gid://var/good');
        _Lib.CreateItemVariant(BlockedVariant, Item."No.");
        BlockedVariant.Blocked := true;
        BlockedVariant.Modify(true);
        _Lib.CreateVariantModif(SpfyItemVariantModif, Item."No.", GoodVariant.Code, StoreCode, false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'repush value');
        SpfyInventoryLevel.Init();
        SpfyInventoryLevel."Shopify Store Code" := StoreCode;
        SpfyInventoryLevel."Shopify Location ID" := LocationId;
        SpfyInventoryLevel."Item No." := Item."No.";
        SpfyInventoryLevel."Variant Code" := GoodVariant.Code;
        SpfyInventoryLevel.Insert(true);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreCode);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);
        SpfySyncStateMgt.SeedItemVariantBaseline(GoodVariant);
        SpfySyncStateMgt.SeedItemVariantBaseline(BlockedVariant);
        SpfySyncStateMgt.SeedItemVariantModifBaseline(SpfyItemVariantModif);
        SpfySyncStateMgt.SeedEntityMetafieldBaseline(SpfyEntityMetafield);
        _Lib.RegisterEnabledTables();
        DeletionRowsBefore := _Lib.TotalDeletionRowCount();
        SpfyInventoryLevel.Find();
        LevelUpdatedBefore := SpfyInventoryLevel."Last Updated at";

        // [WHEN] The single-item re-push cascade runs (non-GUI session: no confirmation dialog).
        SpfyResyncMgt.ResyncStoreItemLink(SpfyStoreItemLink);

        // [THEN] The full product cascade is cleared + bumped for this store.
        _Assert.IsFalse(_Lib.HasBaseline(Database::Item, Item.SystemId, StoreCode), 'Item baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, StoreCode), 'Link baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"Item Variant", GoodVariant.SystemId, ''), 'Eligible variant baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, StoreCode), 'Variant modif baseline must be cleared');
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, ''), 'Metafield baseline must be cleared');
        // [THEN] An ineligible (blocked) variant is skipped: its baseline is kept, nothing fakes a queued send.
        _Assert.IsTrue(_Lib.HasBaseline(Database::"Item Variant", BlockedVariant.SystemId, ''), 'A blocked variant must be skipped, its baseline kept');
        // [THEN] Inventory is re-sent via a forced bump with a fresh log date - no baseline involved.
        SpfyInventoryLevel.Find();
        _Assert.IsTrue(SpfyInventoryLevel."Last Updated at" > LevelUpdatedBefore, 'The inventory level must be bumped with a fresh Last Updated at');
        // [THEN] The bumps produce no delete-intent noise for unchanged active variants.
        _Assert.AreEqual(DeletionRowsBefore, _Lib.TotalDeletionRowCount(), 'A re-push must not log any deletion intents');

        // [WHEN] The next detection cycle runs. [THEN] the item graph is re-sent...
        _Lib.RunDetection();
        TasksAfterFirstCycle := _Lib.TaskCount();
        _Assert.IsTrue(TasksAfterFirstCycle > 0, 'The re-push must re-send on the next cycle');
        _Assert.IsTrue(_Lib.TaskCount(Database::Item) > 0, 'The product payload must be re-sent');
        _Assert.IsTrue(_Lib.TaskCount(Database::"Inventory Buffer") > 0, 'The cost must be re-sent');

        // ...and the following cycle is quiet again (one-shot, not a resend loop).
        _Lib.RunDetection();
        _Assert.AreEqual(TasksAfterFirstCycle, _Lib.TaskCount(), 'The re-push must converge after one cycle');

        // The cascade's Confirm + completion Message fire only when GuiAllowed() is true.
        _Lib.ConsumeConfirm();
        _Lib.ConsumeMessage();
    end;

    [Test]
    procedure GivenLineMovedWhileDetectionMissedIt_WhenMarkOnlyRequeueRuns_ThenBothLocationsHeal()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SalesLine: Record "Sales Line";
        LevelA: Record "NPR Spfy Inventory Level";
        LevelB: Record "NPR Spfy Inventory Level";
        ResyncRun: Record "NPR Spfy Resync Run";
        StoreCode: Code[20];
        LocationA: Code[10];
        LocationB: Code[10];
        LocIdA: Text[30];
        LocIdB: Text[30];
    begin
        // [SCENARIO] A mark-only requeue keeps the stale move-key baseline and resets the mark, so the re-scan heals both the abandoned and the current location of a sales line whose move detection was missed.
        Initialize();
        StoreCode := _Lib.CreateStore(false, true, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LocationA := _Lib.CreateLocationWithLink(StoreCode, LocIdA);
        LocationB := _Lib.CreateLocationWithLink(StoreCode, LocIdB);
        _Lib.RunDetection();
        _Lib.CreateSalesOrderLine(SalesLine, Item."No.", '', LocationA, 5);
        _Lib.RunDetection();
        _Assert.AreEqual(Format(LocationA), _Lib.Facet(Database::"Sales Line", SalesLine.SystemId, '', 'salesLineLocationCode'), 'The move-key baseline must hold location A');

        // [GIVEN] The line moves to B but detection misses the window (mark already past the change).
        SalesLine."Location Code" := LocationB;
        SalesLine.Modify(false);
        _Lib.SetMark(Database::"Sales Line", _Lib.CurrentMaxRowVersion(Database::"Sales Line"));
        _Lib.RunDetection();
        _Assert.AreEqual(Format(LocationA), _Lib.Facet(Database::"Sales Line", SalesLine.SystemId, '', 'salesLineLocationCode'), 'The skipped move must leave the stale baseline (the drift under repair)');

        // [WHEN] The mark-only requeue re-scans the trigger table (baseline KEPT, mark reset).
        ResyncRun.Init();
        ResyncRun.Scope := ResyncRun.Scope::"Table";
        ResyncRun."Table No." := Database::"Sales Line";
        _Lib.RunBulkResync(ResyncRun);
        _Assert.IsTrue(_Lib.HasBaseline(Database::"Sales Line", SalesLine.SystemId, ''), 'Mark-only requeue must keep the move-key baseline');
        _Assert.IsTrue(_Lib.GetMark(Database::"Sales Line") = 0, 'Mark-only requeue must reset the mark');
        _Lib.RunDetection();

        // [THEN] The re-scan sees old A (from the kept baseline) vs current B and heals BOTH locations.
        _Assert.AreEqual(Format(LocationB), _Lib.Facet(Database::"Sales Line", SalesLine.SystemId, '', 'salesLineLocationCode'), 'The baseline must advance to location B');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelA, StoreCode, LocIdA, Item."No.", ''), 'The abandoned location must be recomputed');
        _Assert.AreEqual(0, LevelA.Inventory, 'The abandoned location must not be left stale');
        _Assert.IsTrue(_Lib.GetInventoryLevel(LevelB, StoreCode, LocIdB, Item."No.", ''), 'The new location must be recomputed');
        _Assert.AreEqual(-5, LevelB.Inventory, 'The new location must carry the moved quantity');
    end;
    #endregion

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure SinkMessageHandler(MessageText: Text[1024])
    begin
    end;
}
