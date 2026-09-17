codeunit 85283 "NPR Spfy RowVer Engine Tests"
{
    // [FEATURE] Shopify RowVersion change detection - engine: Change Tracker mark contract, engine policy constants, poll flows (real DB)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _Seam: Codeunit "NPR Spfy RowVer Fail Seam";

    local procedure Initialize()
    begin
        _Lib.ResetState();   // also disarms the RowVer fail seam - see SpfyRowVerTestLib.ResetState()
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
    end;

    #region Tracker Contract
    local procedure CreateTracker(TableNo: Integer; Mark: BigInteger; var ChangeTracker: Record "NPR Change Tracker")
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        ChangeTrackerMgt.EnsureTracker("NPR Integration Type"::Shopify, TableNo, ChangeTracker);
        ChangeTracker."Last Row Version" := Mark;
        ChangeTracker.Modify(false);
    end;

    [Test]
    procedure AdvanceMark_AdvancesToMaxMonotonic()
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        Result: Boolean;
    begin
        // [SCENARIO] Advancing the tracker mark moves it up to a higher target and never lets it decrease.
        Initialize();
        CreateTracker(Database::Item, 100, ChangeTracker);
        // [WHEN] Advancing above the mark. [THEN] it moves to the new max.
        Result := ChangeTrackerMgt.AdvanceMark(ChangeTracker, 200);
        _Assert.IsTrue(Result, 'Advance to a higher mark must succeed');
        _Assert.IsTrue(ChangeTracker."Last Row Version" = 200, 'Mark must advance to 200');
        // [WHEN] A lower target arrives. [THEN] the mark never decreases.
        Result := ChangeTrackerMgt.AdvanceMark(ChangeTracker, 150);
        _Assert.IsTrue(Result, 'A lower target is still a successful no-op');
        _Assert.IsTrue(ChangeTracker."Last Row Version" = 200, 'Mark must never decrease');
    end;

    [Test]
    procedure AdvanceMark_ConcurrentLoweringWins()
    var
        StaleTracker: Record "NPR Change Tracker";
        DbTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        Result: Boolean;
    begin
        // [SCENARIO] A mark that a re-sync lowered while a poller held a stale copy is not re-cemented: the advance is refused and the reset survives.
        Initialize();
        CreateTracker(Database::Item, 500, StaleTracker);
        // [GIVEN] A re-sync lowers the DB mark to 0 under the stale poller's high in-memory copy.
        DbTracker.Get(StaleTracker."Integration Type", StaleTracker."Table No.");
        DbTracker."Last Row Version" := 0;
        DbTracker.Modify(false);
        // [WHEN] The stale poller flushes its buffered progress. [THEN] AdvanceMark refuses; the reset survives.
        Result := ChangeTrackerMgt.AdvanceMark(StaleTracker, 600);
        _Assert.IsFalse(Result, 'A concurrently-lowered mark must make AdvanceMark return false');
        DbTracker.Get(DbTracker."Integration Type", DbTracker."Table No.");
        _Assert.IsTrue(DbTracker."Last Row Version" = 0, 'The re-sync reset (0) must not be re-cemented');
    end;

    [Test]
    procedure AdvanceMark_PeerAdvancedIsMonotonicNoop()
    var
        StaleTracker: Record "NPR Change Tracker";
        DbTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        Result: Boolean;
    begin
        // [SCENARIO] When a peer has already advanced the mark further, an older advance succeeds as a no-op and the caller's copy refreshes to the higher mark.
        Initialize();
        CreateTracker(Database::Item, 100, StaleTracker);
        // [GIVEN] A peer advanced the DB mark to 300 while this caller still holds 100.
        DbTracker.Get(StaleTracker."Integration Type", StaleTracker."Table No.");
        DbTracker."Last Row Version" := 300;
        DbTracker.Modify(false);
        // [WHEN] Advancing with an older buffered target 150. [THEN] success, but the higher mark stands.
        Result := ChangeTrackerMgt.AdvanceMark(StaleTracker, 150);
        _Assert.IsTrue(Result, 'A peer-advanced mark is a successful monotonic no-op');
        _Assert.IsTrue(StaleTracker."Last Row Version" = 300, 'Caller copy must refresh to the higher mark');
    end;

    [Test]
    procedure AdvanceMark_VanishedRowReturnsFalse()
    var
        StaleTracker: Record "NPR Change Tracker";
        DbTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        // [SCENARIO] Advancing a tracker whose row has been deleted underneath the caller fails instead of resurrecting it.
        Initialize();
        CreateTracker(Database::Item, 100, StaleTracker);
        // [GIVEN] The tracker row is deleted under the stale in-memory copy.
        DbTracker.Get(StaleTracker."Integration Type", StaleTracker."Table No.");
        DbTracker.Delete(false);
        // [THEN] AdvanceMark re-Gets, finds nothing and aborts.
        _Assert.IsFalse(ChangeTrackerMgt.AdvanceMark(StaleTracker, 200), 'A vanished tracker row must make AdvanceMark return false');
    end;

    [Test]
    procedure RecordRowFailure_StreakAndReanchor()
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        // [SCENARIO] Repeated failures of the same row version count up as one streak, and a different failing row version restarts the count at one.
        Initialize();
        CreateTracker(Database::Item, 100, ChangeTracker);
        // [WHEN] The same poison rowversion fails three cycles. [THEN] the streak counts 1,2,3.
        _Assert.AreEqual(1, ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123), 'First failure');
        _Assert.AreEqual(2, ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123), 'Second failure');
        _Assert.AreEqual(3, ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123), 'Third failure');
        // [WHEN] A different rowversion fails. [THEN] the streak re-anchors to 1.
        _Assert.AreEqual(1, ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 456), 'A new failing rowversion restarts the streak');
    end;

    [Test]
    procedure ClearRowFailure_ResetsStreak()
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeQuarantine: Record "NPR Change Quarantine";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        // [SCENARIO] A row that dispatches cleanly after failures has its failure streak and failing row version cleared, and nothing is quarantined.
        Initialize();
        CreateTracker(Database::Item, 100, ChangeTracker);
        ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123);
        ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123);
        // [WHEN] The row later dispatches cleanly. [THEN] the failure state resets and nothing was quarantined.
        ChangeTrackerMgt.ClearRowFailure(ChangeTracker);
        _Assert.AreEqual(0, ChangeTracker."Consecutive Failures", 'Consecutive failures must reset to 0');
        _Assert.IsTrue(ChangeTracker."Failing Row Version" = 0, 'Failing row version must reset to 0');
        _Assert.IsTrue(ChangeQuarantine.IsEmpty(), 'A transient error must not quarantine anything');
    end;

    [Test]
    procedure QuarantineRow_InsertsAdvancesAndClears()
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeQuarantine: Record "NPR Change Quarantine";
        EntityItem: Record Item;
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        EntityRecordId: RecordId;
        EntityId: Guid;
    begin
        // [SCENARIO] Quarantining a poison row writes one quarantine entry carrying the entity identity and error, advances the mark past that row and clears the failure streak.
        Initialize();
        EntityId := CreateGuid();
        // A realistic quarantined-entity RecordId (the Item under detection), distinct from the tracker row's own.
        EntityItem."No." := 'QUARITEM';
        EntityRecordId := EntityItem.RecordId();
        CreateTracker(Database::Item, 100, ChangeTracker);
        ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123);
        ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123);
        ChangeTrackerMgt.RecordRowFailure(ChangeTracker, 123);
        // [WHEN] The poison row is quarantined on the third strike.
        ChangeTrackerMgt.QuarantineRow(ChangeTracker, 123, EntityRecordId, EntityId, 'boom');
        // [THEN] exactly one quarantine row capturing the entity identity an operator needs for recovery.
        _Assert.AreEqual(1, ChangeQuarantine.Count(), 'Exactly one quarantine row');
        ChangeQuarantine.FindFirst();
        _Assert.IsTrue(ChangeQuarantine."Integration Type" = "NPR Integration Type"::Shopify, 'Quarantine integration type');
        _Assert.AreEqual(Database::Item, ChangeQuarantine."Table No.", 'Quarantine table no.');
        _Assert.IsTrue(ChangeQuarantine."Row Version" = 123, 'Quarantine row version');
        _Assert.AreEqual(EntityRecordId, ChangeQuarantine."Record ID", 'Quarantine must capture the entity RecordId');
        _Assert.AreEqual(EntityId, ChangeQuarantine."Entity System Id", 'Quarantine entity id');
        _Assert.AreEqual('boom', ChangeQuarantine."Error Text", 'Quarantine error text');
        _Assert.AreNotEqual(0DT, ChangeQuarantine."Quarantined At", 'Quarantined At must be stamped');
        // [THEN] the mark advances past the poison row and the failure streak clears.
        _Assert.IsTrue(ChangeTracker."Last Row Version" = 123, 'Mark must advance past the quarantined row');
        _Assert.AreEqual(0, ChangeTracker."Consecutive Failures", 'Failure streak must clear after quarantine');
    end;

    [Test]
    procedure ResetTracking_ZeroesMarkAndTrackerIsSingleRow()
    var
        ChangeTracker: Record "NPR Change Tracker";
        RegisteredCount: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        // [SCENARIO] A table keeps exactly one tracker row per integration type however often it is ensured, and resetting tracking zeroes its mark for a full re-scan.
        Initialize();
        // [GIVEN] EnsureTracker called twice for the same (type, table) yields exactly one row.
        CreateTracker(Database::Item, 500, ChangeTracker);
        ChangeTrackerMgt.EnsureTracker("NPR Integration Type"::Shopify, Database::Item, ChangeTracker);
        RegisteredCount.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        RegisteredCount.SetRange("Table No.", Database::Item);
        _Assert.AreEqual(1, RegisteredCount.Count(), 'One global tracker row per (integration type, table)');
        // [WHEN] ResetTracking runs. [THEN] the mark is zeroed for a full re-scan.
        ChangeTrackerMgt.ResetTracking("NPR Integration Type"::Shopify, Database::Item);
        ChangeTracker.Get("NPR Integration Type"::Shopify, Database::Item);
        _Assert.IsTrue(ChangeTracker."Last Row Version" = 0, 'ResetTracking must zero the mark');
    end;
    #endregion

    #region Engine Policy
    [Test]
    procedure BatchSize_PerRowForInternalCommitTables()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
    begin
        // [SCENARIO] Tables whose dispatch commits internally are flushed one row at a time, while tables whose handlers never commit are flushed in 100-row chunks.
        // Tables whose dispatch commits internally stay per-row (duplicate window <=1).
        _Assert.AreEqual(1, SpfyChangeTrackerMgt.BatchSizeForTable(Database::"Item Variant"), 'Item Variant batch size');
        _Assert.AreEqual(1, SpfyChangeTrackerMgt.BatchSizeForTable(Database::"NPR Spfy Item Variant Modif."), 'Variant Modif. batch size');
        _Assert.AreEqual(1, SpfyChangeTrackerMgt.BatchSizeForTable(Database::"Item Reference"), 'Item Reference batch size');
        // Handlers that never commit flush per 100-row chunk.
        _Assert.AreEqual(100, SpfyChangeTrackerMgt.BatchSizeForTable(Database::Item), 'Item batch size');
        _Assert.AreEqual(100, SpfyChangeTrackerMgt.BatchSizeForTable(Database::"NPR Spfy Store-Item Link"), 'Store-Item Link batch size');
    end;

    [Test]
    procedure QuarantineThreshold_IsThree()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
    begin
        // [SCENARIO] A failing row is quarantined after three strikes.
        _Assert.AreEqual(3, SpfyChangeTrackerMgt.QuarantineThreshold(), 'Quarantine threshold must be 3 strikes');
    end;
    #endregion

    #region Poll Flows
    [Test]
    procedure GivenSeededIntegration_WhenDetectionRunsAndEntitiesRedispatch_ThenZeroTasks()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        Voucher: Record "NPR NpRv Voucher";
        StoreCode: Code[20];
    begin
        // [SCENARIO] An existing integration seeded by the migration sweep produces no tasks on the first detection cycle after the feature goes live, and re-dispatching each seeded entity stays a no-op.
        Initialize();
        // [GIVEN] An existing synced integration, seeded with the migration sweep while the feature is OFF.
        _Lib.SetFeatureEnabled(false);
        StoreCode := _Lib.CreateStore(true, false, false, true, true);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Item."Last Direct Cost" := 10;
        Item.Modify(false);
        SpfyStoreItemLink."Shopify Name" := 'Seeded product';
        SpfyStoreItemLink.Modify(false);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), 'gid://var/seeded');
        _Lib.CreateVariantModif(SpfyItemVariantModif, Item."No.", ItemVariant.Code, StoreCode, false);
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId(), 'seeded value');
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreCode, true, true);
        _Lib.CreateVoucherFixture(Voucher, StoreCode, true);

        _Lib.RunSeedWorker(false);

        // [WHEN] The feature goes live and the first detection cycle runs.
        _Lib.SetFeatureEnabled(true);
        _Lib.RunDetection();

        // [THEN] No spurious re-send burst: the sweep left every mark at the current max.
        _Assert.AreEqual(0, _Lib.TaskCount(), 'The first cycle after seeding must produce zero tasks (marks seeded to current max)');

        // [THEN] Even a forced re-dispatch of every seeded entity compares equal against its baseline.
        _Lib.DispatchModify(Item);
        _Lib.DispatchModify(SpfyStoreItemLink);
        _Lib.DispatchModify(ItemVariant);
        _Lib.DispatchModify(SpfyItemVariantModif);
        _Lib.DispatchModify(SpfyEntityMetafield);
        _Lib.DispatchModify(SpfyStoreCustomerLink);
        _Lib.DispatchModify(Voucher);
        _Assert.AreEqual(0, _Lib.TaskCount(), 'Re-dispatching seeded entities must be a no-op (seed and detector share one builder per facet)');
    end;

    [Test]
    procedure GivenRowsPastTheMark_WhenTablePolled_ThenOnlyThoseDispatchedAndMarkAdvances()
    var
        Item1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        Link1: Record "NPR Spfy Store-Item Link";
        Link2: Record "NPR Spfy Store-Item Link";
        Link3: Record "NPR Spfy Store-Item Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Polling a table dispatches only the rows changed past the mark, advances the mark to the highest scanned row version, and creates nothing for a repeated poll or an excluded-field change.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item1, Link1, StoreCode);
        _Lib.CreateSyncedItemWithLink(Item2, Link2, StoreCode);
        _Lib.CreateSyncedItemWithLink(Item3, Link3, StoreCode);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(Link1);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(Link2);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(Link3);
        // [GIVEN] First registration seeds the mark to the current max - pre-existing rows are never replayed.
        _Lib.RegisterTable(Database::"NPR Spfy Store-Item Link");
        _Lib.PollTable(Database::"NPR Spfy Store-Item Link");
        _Assert.AreEqual(0, _Lib.TaskCount(), 'Registration must seed to current max: no pre-existing row may be re-detected');

        // [WHEN] Two of the three links change past the mark.
        Link1."Shopify Name" := 'Changed 1';
        Link1.Modify(false);
        Link2."Shopify Name" := 'Changed 2';
        Link2.Modify(false);
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") < _Lib.CurrentMaxRowVersion(Database::"NPR Spfy Store-Item Link"), 'Sanity: the modified rows must lie past the mark before the poll');
        _Lib.PollTable(Database::"NPR Spfy Store-Item Link");

        // [THEN] Only the changed rows are dispatched; the untouched one is not.
        AssertProductTaskCount(1, Item1."No.", Link1, 'Changed link 1 must produce a product task');
        AssertProductTaskCount(1, Item2."No.", Link2, 'Changed link 2 must produce a product task');
        AssertProductTaskCount(0, Item3."No.", Link3, 'Unchanged link must not be dispatched');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") = _Lib.CurrentMaxRowVersion(Database::"NPR Spfy Store-Item Link"), 'Mark must advance to the max scanned rowversion');

        // [THEN] A repeated poll re-dispatches nothing.
        _Lib.PollTable(Database::"NPR Spfy Store-Item Link");
        _Assert.AreEqual(2, _Lib.TaskCount(Database::Item), 'A repeated poll must not duplicate tasks');

        // [THEN] A no-op row (excluded field only) still advances the mark and creates nothing.
        Link3."Shopify Status" := Link3."Shopify Status"::DRAFT;
        Link3.Modify(false);
        _Lib.PollTable(Database::"NPR Spfy Store-Item Link");
        AssertProductTaskCount(0, Item3."No.", Link3, 'An excluded-field change must not create a task');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") = _Lib.CurrentMaxRowVersion(Database::"NPR Spfy Store-Item Link"), 'A no-op row must still advance the mark');
    end;

    local procedure AssertProductTaskCount(Expected: Integer; ItemNo: Code[20]; SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; Context: Text)
    var
        Actual: Integer;
    begin
        // Same assertion strength as AreEqual; on mismatch the failure text carries the full detection-state dump.
        Actual := _Lib.TaskCountForValue(Database::Item, ItemNo);
        if Actual = Expected then
            exit;
        _Assert.Fail(StrSubstNo('%1 | expected %2, actual %3 | %4', Context, Expected, Actual, _Lib.DumpDetectionState(SpfyStoreItemLink)));
    end;

    [Test]
    procedure GivenFeatureOffOrResyncActive_WhenDetectionRuns_ThenCycleSkippedAndDrainDeferred()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        PreMark: BigInteger;
        DeleteEntryNo: BigInteger;
    begin
        // [SCENARIO] A detection cycle does nothing while the feature is off or a re-sync run is active, deferring a pending delete instead of dropping it, and processes the whole backlog once the re-sync completes.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.RegisterTable(Database::"NPR Spfy Store-Item Link");
        PreMark := _Lib.GetMark(Database::"NPR Spfy Store-Item Link");
        SpfyStoreItemLink."Shopify Name" := 'Pending change';
        SpfyStoreItemLink.Modify(false);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::"Item Variant", Item."No.", ItemVariant.Code, '', StoreCode, 'gid://var/pending');

        // [WHEN] The feature is disabled. [THEN] the cycle is a complete no-op.
        _Lib.SetFeatureEnabled(false);
        _Lib.RunDetection();
        _Assert.AreEqual(0, _Lib.TaskCount(), 'Feature off: no tasks');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") = PreMark, 'Feature off: mark must not move');

        // [WHEN] The feature is on but a re-sync run is active. [THEN] poll and drain both defer.
        _Lib.SetFeatureEnabled(true);
        _Lib.InsertActiveResyncRun();
        _Lib.RunDetection();
        _Assert.AreEqual(0, _Lib.TaskCount(), 'Resync active: no tasks');
        _Assert.IsTrue(_Lib.GetMark(Database::"NPR Spfy Store-Item Link") = PreMark, 'Resync active: mark must not move');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Pending, 'Resync active: the pending delete must be deferred, never dropped');

        // [WHEN] The re-sync completes. [THEN] the next cycle processes the backlog including the drain.
        _Lib.CompleteActiveResyncRuns();
        _Lib.RunDetection();
        _Assert.AreEqual(1, _Lib.TaskCountForValue(Database::Item, Item."No."), 'The deferred modify must be sent on the next cycle');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The deferred delete must drain on the next cycle');
        _Assert.IsTrue(NcTask.Get(DeletionLog."NC Task Entry No."), 'The drained delete must reference its NC task');
        _Assert.IsTrue(NcTask.Type = NcTask.Type::Delete, 'The drained task must be a Delete task');
    end;

    [Test]
    procedure GivenItemSyncedToTwoStores_WhenCostChanges_ThenOneCostTaskPerStoreFromOneTrackerRow()
    var
        Item: Record Item;
        LinkA: Record "NPR Spfy Store-Item Link";
        LinkB: Record "NPR Spfy Store-Item Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreA: Code[20];
        StoreB: Code[20];
    begin
        // [SCENARIO] One cost change on an item synced to two stores produces one cost task per store and advances both stores' cost facets, from a single tracker row.
        Initialize();
        StoreA := _Lib.CreateStore(true, false, false, false, false);
        StoreB := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, LinkA, StoreA);
        _Lib.CreateItemLink(LinkB, Item."No.", StoreB, true, true);
        Item."Last Direct Cost" := 10;
        Item.Modify(false);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreA);
        SpfySyncStateMgt.SeedItemBaseline(Item, StoreB);
        _Lib.RegisterTable(Database::Item);

        // [WHEN] One polled Item change occurs.
        Item."Last Direct Cost" := 15;
        Item.Modify(false);
        _Lib.PollTable(Database::Item);

        // [THEN] Fan-out happens at task creation: one cost task per syncing store, from one global tracker row.
        _Assert.AreEqual(1, _Lib.TaskCountForStore(Database::"Inventory Buffer", StoreA), 'One cost task for store A');
        _Assert.AreEqual(1, _Lib.TaskCountForStore(Database::"Inventory Buffer", StoreB), 'One cost task for store B');
        _Assert.AreEqual(1, _Lib.TrackerRowCount(Database::Item), 'Exactly one tracker row per (integration type, table), regardless of store count');
        _Assert.AreEqual('15', _Lib.Facet(Database::Item, Item.SystemId, StoreA, 'itemCost'), 'Store A cost facet must advance');
        _Assert.AreEqual('15', _Lib.Facet(Database::Item, Item.SystemId, StoreB, 'itemCost'), 'Store B cost facet must advance');
    end;

    [Test]
    procedure GivenAllAreasEnabled_WhenTablesRegistered_ThenDeletionLogNotPolledAndSendTableLast()
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Registering the enabled areas leaves the Deletion Log and Sync State unpolled, polls trigger tables first and the inventory send table last, and registers Transfer Line only once a store includes transfer orders.
        Initialize();
        StoreCode := _Lib.CreateStore(true, true, true, true, true);

        // [WHEN] Registration runs for every enabled area.
        _Lib.RegisterEnabledTables();

        // [THEN] The Deletion Log is drained by its Processed-flag queue, never rowversion-polled.
        _Assert.IsFalse(_Lib.TrackerExists(Database::"NPR Spfy Deletion Log"), 'The Deletion Log must have no tracker row');
        _Assert.IsFalse(_Lib.TrackerExists(Database::"NPR Spfy Sync State"), 'Sync State must have no tracker row');
        // [THEN] Trigger tables poll first; the Inventory Level send table polls last within a cycle.
        _Assert.AreEqual(1000, _Lib.TrackerProcessingOrder(Database::"NPR Spfy Inventory Level"), 'Inventory Level must be polled last (processing order 1000)');
        _Assert.AreEqual(0, _Lib.TrackerProcessingOrder(Database::Item), 'Trigger tables must be polled first (processing order 0)');
        // [THEN] Transfer Line polling is conditional on transfer-order sync being enabled.
        _Assert.IsFalse(_Lib.TrackerExists(Database::"Transfer Line"), 'Transfer Line must not be registered while no store includes transfer orders');
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Include Transfer Orders" := ShopifyStore."Include Transfer Orders"::All;
        ShopifyStore.Modify(false);
        _Lib.RegisterEnabledTables();
        _Assert.IsTrue(_Lib.TrackerExists(Database::"Transfer Line"), 'Transfer Line must be registered once a store includes transfer orders');
    end;

    [Test]
    procedure GivenAPoisonRow_WhenDetectionRunsFourCycles_ThenQuarantinedOnThirdStrikeAndCycleContinues()
    var
        ItemI: Record Item;
        ItemJ: Record Item;
        LinkI: Record "NPR Spfy Store-Item Link";
        LinkJ: Record "NPR Spfy Store-Item Link";
        VariantJ: Record "Item Variant";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ChangeTracker: Record "NPR Change Tracker";
        ChangeQuarantine: Record "NPR Change Quarantine";
        DeletionLog: Record "NPR Spfy Deletion Log";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        DeleteEntryNo: BigInteger;
        PoisonRowVersion: BigInteger;
        LocationCode: Code[10];
        StoreCode: Code[20];
        ShopifyLocationId: Text[30];
    begin
        // [SCENARIO] A row whose real dispatch keeps failing is quarantined on the third strike and the mark then moves past it, while every failing cycle still polls the later tables and still drains the deletion log.
        Initialize();
        // [GIVEN] A store syncing items and inventory levels, with one linked location.
        StoreCode := _Lib.CreateStore(true, true, false, false, false);
        LocationCode := _Lib.CreateLocationWithLink(StoreCode, ShopifyLocationId);
        // [GIVEN] Item I, whose inventory recalculation is made to fail, and healthy item J with a variant.
        _Lib.CreateSyncedItemWithLink(ItemI, LinkI, StoreCode);
        _Lib.CreateSyncedItemWithLink(ItemJ, LinkJ, StoreCode);
        _Lib.CreateItemVariant(VariantJ, ItemJ."No.");
        _Lib.RegisterEnabledTables();
        Commit();   // the marks are read with ReadCommitted: the whole fixture must be visible before they are seeded
        ChangeTrackerMgt.ReseedAllMarksToCurrentMax("NPR Integration Type"::Shopify);

        // [GIVEN] A pending delete to drain, an Item Ledger Entry for I past the mark, and a pending payload change on J's later-polled link.
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::"Item Variant", ItemJ."No.", VariantJ.Code, '', StoreCode, 'gid://var/poisoncycle');
        _Lib.InsertItemLedgerEntry(ItemLedgerEntry, ItemI."No.", '', LocationCode, 5);
        LinkJ."Shopify Name" := 'Healthy change';
        LinkJ.Modify(false);
        Commit();   // the asserterror rollbacks must not undo the fixture
        ItemLedgerEntry.Get(ItemLedgerEntry."Entry No.");   // SystemRowVersion is assigned by SQL, so it must be re-read, not taken from the in-memory insert
        PoisonRowVersion := ItemLedgerEntry.SystemRowVersion;
        // Armed by SystemId, not No.: the fixture lib's own generated codes can collide across test
        // codeunits, so keying on No. risked matching an unrelated item too. A SystemId never does. This
        // item itself is committed and stays in the database, so if this test fails before Disarm() below,
        // the seam is still cleared before the next test runs - ResetState() (called from every RowVer
        // test codeunit's own Initialize()) disarms it unconditionally.
        _Seam.Arm(ItemI.SystemId);

        // [WHEN] Detection runs four cycles over the same poison row: three with the injected dispatch failure armed, the fourth after it is lifted.
        asserterror _Lib.RunDetection();

        // [THEN] The first cycle reports the dispatch failure and anchors the streak on the poison row without moving past it.
        _Assert.ExpectedError('Injected inventory failure');
        ChangeTracker.Get("NPR Integration Type"::Shopify, Database::"Item Ledger Entry");
        _Assert.AreEqual(1, ChangeTracker."Consecutive Failures", 'The first failing cycle must record exactly one strike on the Item Ledger Entry tracker');
        _Assert.IsTrue(ChangeTracker."Failing Row Version" = PoisonRowVersion, StrSubstNo('The streak must be anchored on the poison row version %1, was %2', PoisonRowVersion, ChangeTracker."Failing Row Version"));
        _Assert.IsTrue(_Lib.GetMark(Database::"Item Ledger Entry") < PoisonRowVersion, StrSubstNo('The mark must stay before the poison row version %1, was %2', PoisonRowVersion, _Lib.GetMark(Database::"Item Ledger Entry")));

        // [THEN] The failure costs only its own row: the later-polled table was still dispatched and the deletion log still drained.
        _Assert.IsTrue(_Lib.TaskCountForValue(Database::Item, ItemJ."No.") >= 1, StrSubstNo('The healthy change on %1 lies on a later-polled table and must still be dispatched in the failing cycle', ItemJ."No."));
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The deletion log drain runs after the poll loop and must still process the pending delete');

        asserterror _Lib.RunDetection();
        _Assert.ExpectedError('Injected inventory failure');
        asserterror _Lib.RunDetection();
        _Assert.ExpectedError('Injected inventory failure');

        // [THEN] The third strike quarantines the poison row with its English dispatch error and releases the mark.
        ChangeQuarantine.SetRange("Table No.", Database::"Item Ledger Entry");
        ChangeQuarantine.SetRange("Record ID", ItemLedgerEntry.RecordId());
        _Assert.AreEqual(1, ChangeQuarantine.Count(), 'Exactly one quarantine row for the poison Item Ledger Entry after three failing cycles');
        ChangeQuarantine.FindFirst();
        _Assert.IsTrue(StrPos(ChangeQuarantine."Error Text", 'Injected inventory failure') > 0, StrSubstNo('The quarantine must carry the dispatch error text, was ''%1''', ChangeQuarantine."Error Text"));
        ChangeTracker.Get("NPR Integration Type"::Shopify, Database::"Item Ledger Entry");
        _Assert.AreEqual(0, ChangeTracker."Consecutive Failures", 'Quarantining the row must clear the failure streak');
        _Assert.IsTrue(_Lib.GetMark(Database::"Item Ledger Entry") >= PoisonRowVersion, StrSubstNo('The mark must advance past the quarantined row version %1, was %2', PoisonRowVersion, _Lib.GetMark(Database::"Item Ledger Entry")));

        _Seam.Disarm();
        _Lib.RunDetection();

        // [THEN] With the poison row behind the mark the next cycle raises nothing (an error here fails the test) and quarantines nothing more.
        _Assert.AreEqual(1, ChangeQuarantine.Count(), 'The cycle after the quarantine must not quarantine the same row again');
    end;
    #endregion
}
