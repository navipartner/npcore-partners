codeunit 85275 "NPR Spfy RowVer Baseline Tests"
{
    // [FEATURE] Shopify RowVersion change detection - Sync State baseline store, facet encoding and payload hashing
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    local procedure Initialize()
    var
        SyncState: Record "NPR Spfy Sync State";
    begin
        SyncState.DeleteAll(false);
    end;

    #region Sync State
    [Test]
    procedure Baseline_SaveGetRoundTrip()
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        Baseline: JsonObject;
        Loaded: JsonObject;
        EntityId: Guid;
    begin
        // [SCENARIO] A baseline facet saved for an entity and store reloads unchanged and reports the baseline as present.
        Initialize();
        EntityId := CreateGuid();
        // [GIVEN] A saved facet. [WHEN] reloaded. [THEN] the facet value round-trips.
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v1');
        SpfySyncStateMgt.SaveBaseline(Database::Item, EntityId, 'STORE01', Baseline);
        SpfySyncStateMgt.GetBaseline(Database::Item, EntityId, 'STORE01', Loaded);
        _Assert.AreEqual('v1', SpfySyncStateMgt.Facet(Loaded, 'k'), 'Facet must round-trip');
        _Assert.IsTrue(SpfySyncStateMgt.HasBaseline(Database::Item, EntityId, 'STORE01'), 'HasBaseline must be true after save');
    end;

    [Test]
    procedure Baseline_PayloadVersionMismatchReadsEmpty()
    var
        SyncState: Record "NPR Spfy Sync State";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        Baseline: JsonObject;
        Loaded: JsonObject;
        EntityId: Guid;
    begin
        // [SCENARIO] A baseline stored under an outdated payload version reads back as empty so the entity is re-detected instead of trusting a stale facet.
        Initialize();
        EntityId := CreateGuid();
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v1');
        SpfySyncStateMgt.SaveBaseline(Database::Item, EntityId, '', Baseline);
        // [GIVEN] The stored row's Payload Version no longer matches the current version.
        SyncState.Get(Database::Item, EntityId, '');
        SyncState."Payload Version" := SpfySyncStateMgt.PayloadVersion() + 1;
        SyncState.Modify(false);
        // [THEN] GetBaseline returns empty (safe direction: re-detect), not the stale facet.
        SpfySyncStateMgt.GetBaseline(Database::Item, EntityId, '', Loaded);
        _Assert.AreEqual('', SpfySyncStateMgt.Facet(Loaded, 'k'), 'A version mismatch must read as no baseline');
    end;

    [Test]
    procedure Baseline_OneRowPerKeyOverwritten()
    var
        SyncState: Record "NPR Spfy Sync State";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        Baseline: JsonObject;
        Loaded: JsonObject;
        EntityId: Guid;
    begin
        // [SCENARIO] Repeated baseline saves for the same table, entity and store overwrite one row that ends up holding the latest facet value.
        Initialize();
        EntityId := CreateGuid();
        // [WHEN] The same (table, entity, store) baseline is written repeatedly.
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v1');
        SpfySyncStateMgt.SaveBaseline(Database::Item, EntityId, 'S', Baseline);
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v2');
        SpfySyncStateMgt.SaveBaseline(Database::Item, EntityId, 'S', Baseline);
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v3');
        SpfySyncStateMgt.SaveBaseline(Database::Item, EntityId, 'S', Baseline);
        // [THEN] Exactly one row survives (overwritten, not appended)...
        SyncState.SetRange("Table No.", Database::Item);
        SyncState.SetRange("Entity System Id", EntityId);
        _Assert.AreEqual(1, SyncState.Count(), 'Baseline must be one overwritten row per key');
        // ...and it holds the LATEST value (the Modify branch actually updated Parameters, not stuck at v1).
        SpfySyncStateMgt.GetBaseline(Database::Item, EntityId, 'S', Loaded);
        _Assert.AreEqual('v3', SpfySyncStateMgt.Facet(Loaded, 'k'), 'Surviving row must hold the latest value v3');
    end;

    [Test]
    procedure RemoveBaseline_NoopWhenAbsent()
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        EntityId: Guid;
    begin
        // [SCENARIO] Removing a baseline that was never saved completes without an error and leaves no baseline behind.
        Initialize();
        EntityId := CreateGuid();
        // [WHEN] Removing a baseline that never existed. [THEN] the call raises no error; the baseline is still absent.
        SpfySyncStateMgt.RemoveBaseline(Database::Item, EntityId, 'S');
        _Assert.IsFalse(SpfySyncStateMgt.HasBaseline(Database::Item, EntityId, 'S'), 'No baseline must exist');
    end;

    [Test]
    procedure RemoveBaselineAllStores_ClearsEveryStoreRow()
    var
        SyncState: Record "NPR Spfy Sync State";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        Baseline: JsonObject;
        EntityId: Guid;
    begin
        // [SCENARIO] Removing an entity's baselines for all stores clears every per-store row, including the store-independent one.
        Initialize();
        EntityId := CreateGuid();
        SpfySyncStateMgt.SetFacet(Baseline, 'k', 'v');
        SpfySyncStateMgt.SaveBaseline(Database::"Item Variant", EntityId, '', Baseline);
        SpfySyncStateMgt.SaveBaseline(Database::"Item Variant", EntityId, 'S1', Baseline);
        SpfySyncStateMgt.SaveBaseline(Database::"Item Variant", EntityId, 'S2', Baseline);
        // [WHEN] The entity is physically deleted -> all per-store baselines cleared, incl. the '' row.
        SpfySyncStateMgt.RemoveBaselineAllStores(Database::"Item Variant", EntityId);
        SyncState.SetRange("Table No.", Database::"Item Variant");
        SyncState.SetRange("Entity System Id", EntityId);
        _Assert.AreEqual(0, SyncState.Count(), 'All per-store baselines must be removed');
    end;
    #endregion

    #region Facet Encoding
    [Test]
    procedure FacetDecimal_InvariantEqualityAndDifference()
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        BaselineA: JsonObject;
        BaselineC: JsonObject;
    begin
        // [SCENARIO] A decimal facet written as text with trailing zeros reads back as the same invariant decimal, and a different value stays different.
        // A text facet with trailing zeros parses back as the plain decimal (invariant locale 9), and 0 differs.
        SpfySyncStateMgt.SetFacet(BaselineA, 'k', '5.00');
        SpfySyncStateMgt.SetFacetDecimal(BaselineC, 'k', 0);
        _Assert.AreEqual(5.0, SpfySyncStateMgt.FacetAsDecimal(BaselineA, 'k'), '''5.00'' text facet must parse as decimal 5');
        _Assert.AreNotEqual(SpfySyncStateMgt.FacetAsDecimal(BaselineA, 'k'), SpfySyncStateMgt.FacetAsDecimal(BaselineC, 'k'), '5 and 0 must differ');
    end;
    #endregion

    #region Payload Hashing
    [Test]
    procedure Hash_LengthPrefixIsInjective()
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        TempLinkA: Record "NPR Spfy Store-Customer Link" temporary;
        TempLinkB: Record "NPR Spfy Store-Customer Link" temporary;
    begin
        // [SCENARIO] Payload hashing tells apart values whose field boundary shifts, even when a value contains the delimiter character.
        // Case 1: same concatenation "ABC" split on a different boundary between two adjacent payload fields.
        TempLinkA."First Name" := 'AB';
        TempLinkA."Last Name" := 'C';
        TempLinkB."First Name" := 'A';
        TempLinkB."Last Name" := 'BC';
        _Assert.AreNotEqual(SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkA), SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkB), 'Boundary shift must change the hash');
        // Case 2: a '|' inside a value must not collide with a shifted field boundary (naive delimiter joining would).
        Clear(TempLinkA);
        Clear(TempLinkB);
        TempLinkA."First Name" := 'A|B';
        TempLinkA."Last Name" := 'C';
        TempLinkB."First Name" := 'A';
        TempLinkB."Last Name" := 'B|C';
        _Assert.AreNotEqual(SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkA), SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkB), 'A delimiter inside a value must not shift the field boundary');
    end;

    [Test]
    procedure Hash_ExcludesNonPayloadFields()
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        TempLinkA: Record "NPR Spfy Store-Customer Link" temporary;
        TempLinkB: Record "NPR Spfy Store-Customer Link" temporary;
    begin
        // [SCENARIO] Changing only bookkeeping fields that are excluded from the payload leaves the payload hash unchanged.
        // Identical payload; only the four excluded bookkeeping/op-type fields differ -> hash unchanged.
        TempLinkA."First Name" := 'X';
        TempLinkA."E-Mail" := 'x@y.z';
        TempLinkB."First Name" := 'X';
        TempLinkB."E-Mail" := 'x@y.z';
        TempLinkB."Synchronization Is Enabled" := true;
        TempLinkB."Address Updated in BC" := true;
        TempLinkB."Marketing State Updated in BC" := true;
        TempLinkB."Sync. to this Store" := true;
        _Assert.AreEqual(SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkA), SpfySyncStateMgt.StoreCustomerLinkPayloadHash(TempLinkB), 'Excluded field must not change the hash');
    end;
    #endregion
}
