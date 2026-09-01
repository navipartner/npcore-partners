#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85260 "NPR Entria Tests"
{
    // [FEATURE] Entria integration: the order import - the list and ID-based retry passes, the sync marker,
    //           the order import failure registry and the payload-to-document mapping - the guards of the
    //           Entria item price-change webhook subscriber, and enabling a store. The order import job
    //           queue lifecycle lives in "NPR Entria JQ Tests".
    //
    // NOTE on the price-change webhook: the production publisher
    // "NPR Entria Integr. Webhooks".OnItemUnitPriceChanged is an [ExternalBusinessEvent], which is not a
    // subscribable in-process event type - the notification goes to external HTTP subscribers only after
    // the transaction commits, so a BC test cannot observe the dispatch. The WebhookGuards_* tests
    // therefore verify whether the production subscriber "NPR Entria Webhook Subscr." would REACH or exit
    // before the publisher call: "NPR Entria TestSub" captures the same Rec/xRec state on Item OnAfterModifyEvent,
    // and HasEnabledStore() is called from the test directly.
    //
    // Initialize() normalises state at the START of each test that touches the database, not once per run:
    // there is no per-test rollback - TestIsolation = Codeunit rolls back once, at the END of the codeunit -
    // so every write an earlier test made, committed or not, is still there for every test declared after it.

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _Initialized: Boolean;
        _StoreCode: Code[20];
        _StoreCodeLbl: Label 'NPRENT-TEST', Locked = true;
        _SecondStoreCodeLbl: Label 'NPRENT-TEST2', Locked = true;
        _LastMessageTxt: Text;
        _MockOrderId: Text[100];
        _MockOrderUpdatedAt: DateTime;
        _MockRequestCount: Integer;

    [Test]
    procedure WebhookGuards_PriceChangeOnEntriaItemWithEnabledStore_AllGuardsPass()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Entria item, enabled store, Unit Price changes from 100 to 200.

        // [GIVEN] An enabled Entria store and an item flagged as Entria product with Unit Price 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, true);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] The item's Unit Price is changed from 100 to 200 and the item is modified
        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] All production-subscriber guards evaluate to a state that would
        // reach the publisher call line.
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.AreEqual(1, TestSub.GetOnAfterCallCount(), 'OnAfterModifyEvent should fire exactly once');

        // [THEN] Rec carries the Entria flag and the new price 200, xRec the loaded old price 100, so the price-diff guard holds
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Guard: Rec."NPR Entria Product" must be true');
        _Assert.IsTrue(TestSub.GetOnAfterXRecLoaded(), 'Guard: xRec."Unit Price" must be loaded');
        _Assert.AreEqual(200, TestSub.GetOnAfterRecPrice(), 'Guard: Rec."Unit Price" must reflect the new value');
        _Assert.AreEqual(100, TestSub.GetOnAfterXRecPrice(), 'Guard: xRec."Unit Price" must reflect the old value');

        // [THEN] The store guard holds - at least one Entria store is enabled
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(), 'Guard: HasEnabledStore must be true');
    end;

    [Test]
    procedure WebhookGuards_NonEntriaItemPriceChange_BlockedByEntriaProductFlag()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Item with NPR Entria Product = false has Unit Price changed.

        // [GIVEN] An enabled Entria store and an item with NPR Entria Product = false and Unit Price 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] The non-Entria item's Unit Price is changed from 100 to 200
        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] The Item OnAfterModifyEvent still fires
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');

        // [THEN] Production subscriber would early-exit at guard 2 (the flag check).
        _Assert.IsFalse(TestSub.GetOnAfterRecEntriaProduct(),
            'Flag guard: Rec."NPR Entria Product" must be false → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_EntriaItemDescriptionChange_BlockedByPriceGuard()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Entria item is modified but Unit Price stays the same (Description change).

        // [GIVEN] An enabled Entria store and an Entria item with Unit Price 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, true);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] Only the item's Description is changed, leaving Unit Price untouched
        Item.Get(Item."No.");
        Item.Description := 'Description changed, price untouched';
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] The Item OnAfterModifyEvent fires and the Entria flag guard still holds
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag stays true');

        // [THEN] Production subscriber would early-exit at guard 5 (price equality).
        _Assert.AreEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: Rec."Unit Price" must equal xRec."Unit Price" → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_EntriaItemPriceChangeAllStoresDisabled_BlockedByHasEnabledStore()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Entria item price changes but no store is enabled.

        // [GIVEN] Every Entria store is disabled and an Entria item exists with Unit Price 100
        Initialize();
        _LibraryEntria.DisableAllStores();
        _LibraryEntria.CreateItem(Item, 100, true);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] The Entria item's Unit Price is changed from 100 to 200
        Item.Get(Item."No.");
        Item.Validate("Unit Price", 200);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] Earlier guards (flag, price diff) hold, but HasEnabledStore returns false,
        //        so production exits before publisher call.
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag is true');
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price actually changed');
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledStore(),
            'Store guard: HasEnabledStore must be false → production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_FlagToggleFalseToTruePriceUnchanged_BlockedByPriceGuard()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
    begin
        // [SCENARIO] Item starts non-Entria with non-zero price; admin flips
        //            NPR Entria Product to true without changing Unit Price.

        // [GIVEN] An enabled Entria store and a non-Entria item with a non-zero Unit Price of 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] NPR Entria Product is flipped to true and the Unit Price is left untouched
        Item.Get(Item."No.");
        Item.Validate("NPR Entria Product", true);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] The Item OnAfterModifyEvent fires with the Entria flag now true
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Flag just got toggled to true');

        // [THEN] Documents the "first-sync edge case": flag toggle alone does not
        //        trigger an initial price sync because guard 5 (price diff) blocks it.
        _Assert.AreEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: untouched Unit Price means production exits before publisher call');
    end;

    [Test]
    procedure WebhookGuards_DerivedPriceChangeViaUnitCostValidate_AllGuardsPass()
    var
        Item: Record Item;
        TestSub: Codeunit "NPR Entria TestSub";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] Caller validates Unit Cost on an item set to derive Unit Price
        //            from cost. OnValidate side effect changes Unit Price.

        // [GIVEN] An enabled Entria store and an Entria item with Unit Price 100
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, true);

        // [GIVEN] The item derives its Unit Price from cost (Price=Cost+Profit with Profit % 0)
        Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"Price=Cost+Profit");
        Item.Validate("Profit %", 0);
        Item.Modify(true);

        // [GIVEN] The test subscriber is bound so it captures the same Rec/xRec state the production subscriber sees
        TestSub.Reset();
        BindSubscription(TestSub);

        // [WHEN] Unit Cost is validated to 250, so the OnValidate side effect derives a new Unit Price
        Item.Get(Item."No.");
        Item.Validate("Unit Cost", 250);
        Item.Modify(true);

        UnbindSubscription(TestSub);

        // [THEN] All production guards still pass for the derived new Unit Price,
        //        and OnAfterModifyEvent fires exactly once.
        _Assert.IsTrue(TestSub.WasOnAfterCalled(), 'Item OnAfterModifyEvent must fire');
        _Assert.AreEqual(1, TestSub.GetOnAfterCallCount(), 'OnAfterModifyEvent should fire exactly once');
        _Assert.IsTrue(TestSub.GetOnAfterRecEntriaProduct(), 'Entria flag is true');
        _Assert.AreNotEqual(100, TestSub.GetOnAfterRecPrice(),
            'Rec."Unit Price" must reflect the derived new value, not the original 100');
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Price guard: derived Unit Price differs from the pre-modify Unit Price');
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(), 'Store guard: HasEnabledStore is true');
    end;

    [Test]
    procedure SentryThrottleForListFetch()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        BaseDT: DateTime;
        FirstFailureEmits: Boolean;
        WithinHourEmits: Boolean;
        AtExactlyOneHourEmits: Boolean;
    begin
        // [SCENARIO] ShouldEmitSentryError dedups the store-wide list-fetch failure for one hour. Its
        // dedup key is StoreCode plus a hardcoded '<list-fetch>' marker - no document takes part in it,
        // so every list-fetch outage of one store shares a single hourly bucket. The window is strict
        // ("< OneHour"), so a failure at exactly one hour emits again.

        // [GIVEN] A base timestamp of 08:00 on 1 January 2024 for store 'ZZTEST'
        BaseDT := CreateDateTime(DMY2Date(1, 1, 2024), 080000T);

        // [WHEN] The same store's list fetch fails at that time, 59 minutes later and at exactly 60 minutes
        FirstFailureEmits := EntriaJQ.ShouldEmitSentryError('ZZTEST', BaseDT);
        WithinHourEmits := EntriaJQ.ShouldEmitSentryError('ZZTEST', BaseDT + (59 * 60 * 1000));
        AtExactlyOneHourEmits := EntriaJQ.ShouldEmitSentryError('ZZTEST', BaseDT + (60 * 60 * 1000));

        // [THEN] The first failure of an outage emits
        _Assert.IsTrue(FirstFailureEmits,
            'The first list-fetch failure must emit - suppressing it would leave an Entria outage entirely unreported.');

        // [THEN] A failure 59 minutes in is deduped away
        _Assert.IsFalse(WithinHourEmits,
            'A repeat within the hour must be deduped - the job retries every second for its whole 6h session, so emitting each one would bury Sentry in duplicates of a single outage.');

        // [THEN] A failure at exactly one hour emits again, because the window is strict
        _Assert.IsTrue(AtExactlyOneHourEmits,
            'At exactly one hour the outage must be reported again - relaxing "< OneHour" to "<=" would silently double the reporting interval.');
    end;

    [Test]
    procedure MarkerAdvancesPastOrderWhoseImportFails()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] Root cause: a deterministically failing order must not freeze
        // the "Last Order Import Sync At" marker - the session max must advance past it.
        // All of the fixture's timestamps are equal here - the marker tracks bc_status_updated_at, and
        // the distinction from created_at is covered separately by
        // MarkerAdvancesByBcStatusUpdatedAtNotCreatedAt.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 15 June 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(15, 6, 2024), 100000T);

        // [GIVEN] A seeded session max and a page holding one order that cannot import - amount 100 with no payment lines
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-MARKER', 'medusa-marker-1', OrderUpdatedAt, OrderUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max advances to the failing order's bc_status_updated_at instead of freezing
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'Session max must advance to the failing order''s bc_status_updated_at, not stay frozen.');

        // [THEN] The failure is recorded in the registry, still on its full retry budget
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-marker-1'), 'A registry row must be recorded for the failed order.');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'The initial import failure is not a retry - Retry Count must stay 0.');

        // [THEN] The row carries the identity the list payload supplied, so an operator can recognise the order
        _Assert.AreEqual('ZZ-DOC-MARKER', EntriaOrderImpFailure."Document No.",
            'The list path must capture the payload''s custom_display_id as Document No. - without it the failures page shows a row an operator cannot tie to any document.');
        _Assert.AreEqual(360, EntriaOrderImpFailure."Display No.",
            'The list path must capture the payload''s display_id as Display No. - it is the order number the merchant sees in the Entria admin.');

        // [THEN] The row carries the reason it failed, not an empty Last Error
        _Assert.IsTrue(EntriaOrderImpFailure."Last Error".Contains('ZZ-DOC-MARKER'),
            'The list path must store the import error text - a blank Last Error leaves the operator with nothing to act on.');
    end;

    [Test]
    procedure MarkerAdvancesByBcStatusUpdatedAtNotCreatedAt()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        OrderUpdatedAt: DateTime;
        OrderBcStatusUpdatedAt: DateTime;
    begin
        // [SCENARIO] The marker must track the field the request actually filters and sorts on -
        // bc_status_updated_at - and must be influenced by neither created_at nor updated_at. Feeding
        // the window a created_at value would compare two different clocks: an order's bc status is
        // stamped long after it was created, so the marker could overtake the bc_status_updated_at of
        // orders still waiting and drop them out of the window for good. All three timestamps are
        // deliberately distinct here, so a marker taking the wrong one is caught either way.

        // [GIVEN] An enabled Entria store, and an order created in 2024, bc-stamped in 2026, updated in 2030
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(15, 6, 2024), 100000T);
        OrderBcStatusUpdatedAt := CreateDateTime(DMY2Date(15, 6, 2026), 100000T);
        OrderUpdatedAt := CreateDateTime(DMY2Date(15, 6, 2030), 100000T);

        // [GIVEN] A seeded session max and a page holding that one order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-BCSTATMARK', 'medusa-bcstatmark', OrderCreatedAt, OrderUpdatedAt, 100);
        _LibraryEntria.OverrideBcStatusUpdatedAt(OrdersArr, OrderBcStatusUpdatedAt);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max tracks bc_status_updated_at, ignoring the earlier created_at and the later updated_at
        _Assert.AreEqual(OrderBcStatusUpdatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'The marker must advance to the order''s bc_status_updated_at, not its created_at or updated_at.');
    end;

    [Test]
    procedure ProcessListSecondPassLeavesExistingRegistryRowUntouched()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        NextRetryAtAfterFirstPass: DateTime;
    begin
        // [SCENARIO] Regression guard: once ProcessList has recorded a registry row for a failed order,
        // a second ProcessList pass over the SAME order array must leave that row completely alone.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 20 June 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(20, 6, 2024), 100000T);

        // [GIVEN] A seeded session max and a page holding one order that cannot import - amount 100 with no payment lines
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-DUPPASS', 'medusa-duppass', OrderUpdatedAt, OrderUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page a first time
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The registry row records the initial failure with Retry Count 0
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-duppass');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'First pass: initial failure, Retry Count must be 0.');
        NextRetryAtAfterFirstPass := EntriaOrderImpFailure."Next Retry At";

        // [WHEN] ProcessList runs a second time over the SAME order array
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The registry row is untouched: both the budget it has left and when it is next due
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-duppass');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'Second pass over the same order must not re-log the failure - Retry Count would climb and the backoff budget would burn out in seconds.');
        _Assert.AreEqual(NextRetryAtAfterFirstPass, EntriaOrderImpFailure."Next Retry At",
            'Second pass must not reschedule the row either - re-logging rewrites Next Retry At from the current time and pushes the retry away on every cycle.');
    end;

    [Test]
    procedure MarkerAdvancesPastOrderThatAlreadyHasARegistryRow()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        MarkerBefore: DateTime;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] Marker bookkeeping is unconditional: an order the list path skips because it
        // already has a registry row must still move the session max forward.

        // [GIVEN] An enabled Entria store whose stored marker stands a day before the order's created_at
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        MarkerBefore := CreateDateTime(DMY2Date(9, 7, 2024), 100000T);
        OrderCreatedAt := CreateDateTime(DMY2Date(10, 7, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, MarkerBefore);

        // [GIVEN] A registry row for that order, so the list path skips it
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-regmark', 0, CurrentDateTime() + 3600000);

        // [GIVEN] A session max seeded from that marker and a page holding only that one order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _Assert.AreEqual(EntriaJQ.PassWindowStart(MarkerBefore), EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'Setup: the session max must start at the window the pass opens with - the stored marker less the propagation overlap.');
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-REGMARK', 'medusa-regmark', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max advances to the skipped order's bc_status_updated_at
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'A page of nothing but already-registered failures must still advance the session max - a marker frozen behind them makes the store re-list the same page every cycle forever.');
    end;

    [Test]
    procedure ManualMarkerEditMidPaginationIsNotOverwritten()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        AdminResyncPoint: DateTime;
        ExpectedMarkerDT: DateTime;
        FirstFlushProceeded: Boolean;
        FlushAfterRewindProceeded: Boolean;
    begin
        // [SCENARIO] Editing "Last Orders Imported At" is allowed while the import job runs. An
        // administrator moving it BACKWARDS to force a re-sync must survive even when the edit
        // lands in the middle of a store's pagination

        // [GIVEN] An enabled Entria store, an order timestamped 25 June 2024 and an admin re-sync point back in March
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(25, 6, 2024), 100000T);
        AdminResyncPoint := CreateDateTime(DMY2Date(1, 3, 2024), 0T);

        // [GIVEN] The pass has snapshotted the marker, seeded its session max and processed its first page
        ExpectedMarkerDT := EntriaJQ.GetSyncStateMarker(_StoreCode);
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-MIDEDIT', 'medusa-midedit', OrderUpdatedAt, OrderUpdatedAt, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [WHEN] The pass flushes that first page's marker
        FirstFlushProceeded := EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [THEN] The flush proceeds, advances the stored marker to the order and the pass's snapshot follows its own write
        _Assert.IsTrue(FirstFlushProceeded, 'The first flush of the pass must proceed normally.');
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSyncStateMarker(_StoreCode), 'The first flush must have advanced the marker.');
        _Assert.AreEqual(OrderUpdatedAt, ExpectedMarkerDT, 'The pass''s snapshot must track what it just wrote itself.');

        // [WHEN] The administrator rewinds the marker backwards between two flushes of the same pass, and the pass flushes again
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, AdminResyncPoint);
        FlushAfterRewindProceeded := EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [THEN] That flush reports the external change and leaves the manual re-sync point standing as the next pass's window start
        _Assert.IsFalse(FlushAfterRewindProceeded, 'TryFlushMarker must report the external change so pagination stops.');
        _Assert.AreEqual(AdminResyncPoint, EntriaJQ.GetSyncStateMarker(_StoreCode), 'The manual re-sync point must survive in the database and become the next pass''s window start.');
    end;

    [Test]
    procedure ParkedRowRequiresManualRequeue()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        ParkedRowIsDue: Boolean;
    begin
        // [SCENARIO] A row that has exhausted its retry budget is PARKED. The one Sentry alert at exhaustion summons a human;
        //only the page's "Requeue for Import" (Retry Count 0, Next Retry At now, Status back to Pending) re-arms it.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 23 June 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(23, 6, 2024), 100000T);

        // [GIVEN] Enough failures for that order to exhaust its retry budget, so the row is parked with the 0DT sentinel
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-PARKED', 'medusa-parked', OrderUpdatedAt);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-parked');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At", 'A parked row must carry the 0DT sentinel in Next Retry At.');

        // [WHEN] The ID-based retry pass is asked whether the parked row is due
        ParkedRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-parked');

        // [THEN] It does not pick the parked row up
        _Assert.IsFalse(ParkedRowIsDue,
            'A parked row must NOT be due for the ID-based retry pass - it waits for a human.');

        // [WHEN] The list path processes a page holding that same order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-PARKED', 'medusa-parked', OrderUpdatedAt, OrderUpdatedAt, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The parked row is left untouched at MaxRetries(), still reading as Error
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-parked');
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count",
            'The list path must skip a parked row untouched.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status,
            'The list path must leave the parked row''s Status at Error - flipping it back to Pending would hand the exhausted row to the retry pass again.');

        // [WHEN] A human uses "Requeue for Import", the one way back out of Error
        EntriaJQ.MarkOrderForRetry(EntriaOrderImpFailure);
        //A second in the past, not the CurrentDateTime() MarkOrderForRetry stamps: CollectDueRetries filters
        //"Next Retry At" <= CurrentDateTime() against the STORED value, and SQL's 1/300s datetime grid can round
        //the write up past the instant it was taken. Measured on this codeunit: 4 failures in 69 runs without the
        //margin, 0 in 80 with it. Running this test alone never reproduced it - 0 in 40. That MarkOrderForRetry
        //stamps the current time at all is pinned by FailuresPageActionsRequeueForImportAndSkip.
        EntriaOrderImpFailure."Next Retry At" := CurrentDateTime() - 1000;
        EntriaOrderImpFailure.Modify(true);

        // [THEN] The row is due for the ID-based retry pass again
        _Assert.IsTrue(EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-parked'),
            '"Requeue for Import" must make the row due for the ID-based retry pass again.');
    end;

    [Test]
    procedure ContinuationPageAdvancesWindowWithoutReapplyingOverlap()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        ExpectedMarkerDT: DateTime;
        InitialMarker: DateTime;
        PageOrderDT: DateTime;
        SessionMax: DateTime;
        Page1RequestText: Text;
        ContinuationRequestText: Text;
    begin
        // [SCENARIO] The window a pass opens with is the stored marker moved back by the propagation
        // overlap, computed ONCE, and every page after that moves the window strictly forward to the
        // highest bc_status_updated_at consumed so far. The offset is only meaningful against a fixed
        // filter, so the overlap must never be re-applied per page.

        // [GIVEN] An enabled Entria store whose marker already stands at 14 June 2024, so the pass has
        //         a real window start rather than the never-synced 0DT sentinel (which carries no filter)
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        InitialMarker := CreateDateTime(DMY2Date(14, 6, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, InitialMarker);
        ExpectedMarkerDT := EntriaJQ.GetSyncStateMarker(_StoreCode);

        // [THEN] The pass opens one overlap before the stored marker, and the never-synced sentinel is
        //        left alone so it still means "no window at all"
        _Assert.AreEqual(ExpectedMarkerDT - EntriaJQ.PropagationOverlap(), EntriaJQ.PassWindowStart(ExpectedMarkerDT),
            'A pass must open one propagation overlap before the stored marker, so orders that had not surfaced when the marker was written are still picked up.');
        _Assert.AreEqual(0DT, EntriaJQ.PassWindowStart(0DT),
            'The never-synced sentinel must survive untouched - subtracting from it would underflow and it has to keep meaning "request the whole backlog".');

        // [THEN] The seeded running maximum equals that same opening window, never the bare marker -
        //        seeded ahead of the window, the first comparison would advance the window regardless of
        //        what the page actually contained
        EntriaJQ.SeedSessionMax(_StoreCode);
        _Assert.AreEqual(EntriaJQ.PassWindowStart(ExpectedMarkerDT), EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'The running maximum must start at the window the pass opens with, not at the stored marker.');

        // [GIVEN] The request that opening window produces
        Page1RequestText := EntriaJQ.GenerateGetOrderListRequest(0, 40, EntriaJQ.PassWindowStart(ExpectedMarkerDT));
        _Assert.IsTrue(Page1RequestText.Contains('bc_status_updated_at[$gte]=' + Format(ExpectedMarkerDT - EntriaJQ.PropagationOverlap(), 0, 9)),
            'The opening request must carry the overlapped window verbatim.');

        // [WHEN] A page carrying an order two days later is processed and flushed
        PageOrderDT := CreateDateTime(DMY2Date(16, 6, 2024), 100000T);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-KEYSET', 'medusa-keyset', PageOrderDT, PageOrderDT, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);
        EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);
        SessionMax := EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode);
        _Assert.AreEqual(PageOrderDT, SessionMax, 'Setup: the running maximum must stand at the consumed order''s bc_status_updated_at.');

        // [THEN] The continuation opens exactly AT the consumed maximum - moved forward, and with no
        //        second overlap subtracted from it
        ContinuationRequestText := EntriaJQ.GenerateGetOrderListRequest(0, 40, SessionMax);
        _Assert.IsTrue(ContinuationRequestText.Contains('bc_status_updated_at[$gte]=' + Format(SessionMax, 0, 9)),
            'A continuation must open exactly at the consumed maximum - that forward step is what replaces ordinal offset paging, leaving the offset only for a page whose rows all share one timestamp.');
        _Assert.IsFalse(ContinuationRequestText.Contains(Format(SessionMax - EntriaJQ.PropagationOverlap(), 0, 9)),
            'The continuation window must not have the overlap subtracted again: re-applying it against the moving window rewinds it faster than it advances.');

        // [THEN] The continuation has left the opening window behind, so the cursor makes forward progress
        _Assert.IsFalse(ContinuationRequestText.Contains(Format(ExpectedMarkerDT - EntriaJQ.PropagationOverlap(), 0, 9)),
            'The continuation must not still be querying the window the pass opened with.');
    end;

    [Test]
    procedure RegistryRowUpsertedOnFailureWithBackoff()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        BaseDT: DateTime;
        RetryCount: Integer;
        i: Integer;
    begin
        // [SCENARIO] "Retry Count" counts retries performed, so the initial import failure creates
        // the row with 0 and the order still gets the full budget of MaxRetries() retries, each one
        // scheduled its own BackoffDuration() step out from the failure. The last retry in the
        // budget failing is what parks the row at MaxRetries().

        // [GIVEN] An enabled Entria store and a base timestamp of 08:00 on 1 January 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        BaseDT := CreateDateTime(DMY2Date(1, 1, 2024), 080000T);

        // [WHEN] The initial import failure is logged for the order
        RetryCount := EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-BACKOFF', 'medusa-backoff', BaseDT, 'boom 1', 0, BaseDT);

        // [THEN] The row is created with Retry Count 0, keeps the Medusa order id and schedules retry 1 its first backoff step out
        _Assert.AreEqual(0, RetryCount, 'The initial import failure is not a retry - Retry Count must stay 0.');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-backoff');
        _Assert.AreEqual('medusa-backoff', EntriaOrderImpFailure."Order Id", 'Order Id must be stored.');
        _Assert.AreEqual(BaseDT + EntriaJQ.BackoffDuration(1), EntriaOrderImpFailure."Next Retry At", 'Retry 1 must be scheduled its first backoff step out.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
            'A row created with its whole retry budget intact must read as Pending - Error here would send a human after an order the job is still working on by itself.');

        // [WHEN] Every retry but the last one in the budget fails in turn
        for i := 1 to EntriaJQ.MaxRetries() - 1 do begin
            RetryCount := EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-BACKOFF', 'medusa-backoff', BaseDT, StrSubstNo('boom %1', i + 1), 0, BaseDT);

            // [THEN] Retry Count counts the retries performed and the next retry gets its own backoff step
            _Assert.AreEqual(i, RetryCount, StrSubstNo('Failed retry %1 must increment Retry Count to %1.', i));
            EntriaOrderImpFailure.Get(_StoreCode, 'medusa-backoff');
            _Assert.AreEqual(BaseDT + EntriaJQ.BackoffDuration(i + 1), EntriaOrderImpFailure."Next Retry At",
                StrSubstNo('Retry %1 must be scheduled its own backoff step out.', i + 1));

            // [THEN] Status still reads Pending, in step with the real schedule the row just got
            _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
                StrSubstNo('After failed retry %1 the row still has budget left and must read as Pending, matching the real Next Retry At it was just given.', i));
        end;

        // [WHEN] The last retry in the budget fails
        RetryCount := EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-BACKOFF', 'medusa-backoff', BaseDT, 'boom final', 0, BaseDT);

        // [THEN] Retry Count reaches MaxRetries() and the row is parked with the 0DT sentinel, now reading as Error
        _Assert.AreEqual(EntriaJQ.MaxRetries(), RetryCount, 'The last failed retry in the budget must bring Retry Count to MaxRetries() and park the row.');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-backoff');
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count",
            'The parked row must be stored at MaxRetries() too, not only reported as such by the return value.');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At",
            'A parked row must carry the 0DT sentinel - no further automatic retry is ever scheduled.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status,
            'The failure that spends the last retry must flip Status to Error in the same write that sets the sentinel - the two halves of exhaustion must never be applied one without the other.');
    end;

    [Test]
    procedure OrderUpdatedAtSurvivesFailedRefetchDuringIdBasedRetry()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] When a retry cannot even fetch the order from Entria, the failure row must keep the
        // order timestamp it already had. That timestamp is what later decides whether an edited order has
        // earned a fresh retry budget, so losing it makes every later payload look newer than it is.
        //
        // The document no. and display no. are deliberately NOT asserted here: they are only ever written
        // when a failure actually carries them, so they would survive this path even if it stopped passing
        // them - asserting them here would pass no matter what the branch did. That guard is the real
        // protection and CapturedIdentitySurvivesALaterIdentitylessFailure is what pins it.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 7 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(7, 2, 2024), 100000T);

        // [GIVEN] A due registry row whose initial failure captured Display No. 360 and its document no.
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-DISPNO', 'medusa-dispno', OrderUpdatedAt, 'boom', 360, CurrentDateTime() - 60000);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-dispno');
        _Assert.AreEqual(360, EntriaOrderImpFailure."Display No.", 'Setup: Display No. must be captured on the initial failure.');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'Setup: the initial failure is not a retry, so Retry Count starts at 0.');

        // [WHEN] The ID-based retry pass runs and its single-order re-fetch cannot even execute - a sandbox
        //        blocks HttpClient requests by default, so the "refetch failed" branch runs deterministically
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The refetch-failure branch really ran and logged the second failure as a retry
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-dispno');
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count",
            'The refetch failure must have been logged as a retry - otherwise the branch under test never ran and the rest of this test would pass vacuously.');

        // [THEN] The row keeps the timestamp it captured on the first failure
        _Assert.AreEqual(OrderUpdatedAt, EntriaOrderImpFailure."Order Updated At",
            'Order Updated At must survive the refetch-failure branch - it is written unconditionally, so a branch that stopped forwarding it would wipe the row''s timestamp and hand IsPayloadFresher a 0DT baseline that makes every later payload look fresher.');
    end;

    [Test]
    procedure CapturedIdentitySurvivesALaterIdentitylessFailure()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] An order that fails a second time must keep the document no. and display no. captured
        // on the first failure. Some failures carry no identity at all, and if such a failure blanked those
        // two columns, the failures page would stop naming the order exactly when it has been stuck longest.

        // [GIVEN] An enabled Entria store and an order created at 10:00 on 9 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(9, 2, 2024), 100000T);

        // [GIVEN] The order has already failed once through the list path, capturing document no. and display no. from the payload
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-IDKEEP', 'medusa-idkeep', OrderCreatedAt, OrderCreatedAt, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-idkeep');
        _Assert.AreEqual('ZZ-DOC-IDKEEP', EntriaOrderImpFailure."Document No.", 'Setup: the first failure must have captured the document no.');
        _Assert.AreEqual(360, EntriaOrderImpFailure."Display No.", 'Setup: the first failure must have captured the display no.');

        // [WHEN] The same order fails a second time, logged the way both blank-identity branches log it - no document no. and no display no.
        EntriaJQ.UpsertOrderFailure(_StoreCode, '', 'medusa-idkeep', OrderCreatedAt, 'boom without identity', 0, CurrentDateTime());

        // [THEN] That second failure really landed on the same row, as a retry
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-idkeep');
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count",
            'The second failure must have been counted on the same registry row - otherwise the identity assertions below would pass vacuously.');

        // [THEN] Both halves of the captured identity survived it
        _Assert.AreEqual('ZZ-DOC-IDKEEP', EntriaOrderImpFailure."Document No.",
            'Document No. must survive a failure that carries none - blanking it leaves an operator a registry row that names no document at all.');
        _Assert.AreEqual(360, EntriaOrderImpFailure."Display No.",
            'Display No. must survive a failure that carries none - blanking it hides the order number the merchant sees in the Entria admin and quotes on the phone.');
    end;

    [Test]
    procedure SentryEmitsOnlyOnFinalOrderFailure()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        RetryCount: Integer;
        BudgetExhaustingRetryEmits: Boolean;
    begin
        // [SCENARIO] Per-order Sentry emission fires exactly once, on the retry that brings
        // Retry Count to MaxRetries() - not on the initial failure or any of the earlier retries.

        // [WHEN] The retry that brings Retry Count to MaxRetries() is asked whether it emits
        BudgetExhaustingRetryEmits := EntriaJQ.ShouldEmitSentryErrorForOrder(EntriaJQ.MaxRetries());

        // [THEN] Neither the initial import failure nor any failed retry short of the budget emits to Sentry
        for RetryCount := 0 to EntriaJQ.MaxRetries() - 1 do
            _Assert.IsFalse(EntriaJQ.ShouldEmitSentryErrorForOrder(RetryCount),
                StrSubstNo('Retry Count %1 is short of MaxRetries() - it must not emit to Sentry.', RetryCount));

        // [THEN] Only the retry that brings Retry Count to MaxRetries() emits
        _Assert.IsTrue(BudgetExhaustingRetryEmits, 'The last retry in the budget (= MaxRetries) must emit to Sentry.');
    end;

    [Test]
    procedure BackoffDurationCoversExactlyTheRetryBudget()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        FiveSeconds: Duration;
        TenSeconds: Duration;
        FifteenSeconds: Duration;
        TwentySeconds: Duration;
        ThirtySeconds: Duration;
        FortySeconds: Duration;
        OneMinute: Duration;
        NinetySeconds: Duration;
        TwoAndAHalfMinutes: Duration;
        ThreeMinutes: Duration;
        TenMinutes: Duration;
        TotalBudget: Duration;
        i: Integer;
    begin
        // [SCENARIO] The backoff schedule covers exactly the retry budget - 5s / 10s / 15s / 20s /
        // 30s / 40s / 1min / 90s / 2.5min / 3min for retries 1..MaxRetries(), ten minutes in total -
        // and nothing beyond: a parked row is never rescheduled so a retry number beyond the budget
        // is a programming error and must fail loudly rather than invent a cadence.

        // [GIVEN] The ten steps the backoff schedule is expected to use, and the ten minutes they are
        //         expected to span in total
        FiveSeconds := 5 * 1000;
        TenSeconds := 10 * 1000;
        FifteenSeconds := 15 * 1000;
        TwentySeconds := 20 * 1000;
        ThirtySeconds := 30 * 1000;
        FortySeconds := 40 * 1000;
        OneMinute := 60 * 1000;
        NinetySeconds := 90 * 1000;
        TwoAndAHalfMinutes := 150 * 1000;
        ThreeMinutes := 3 * 60 * 1000;
        TenMinutes := 10 * 60 * 1000;

        // [THEN] Every retry in the budget gets its own concrete step
        _Assert.AreEqual(FiveSeconds, EntriaJQ.BackoffDuration(1), 'Retry 1 must be scheduled 5 seconds out.');
        _Assert.AreEqual(TenSeconds, EntriaJQ.BackoffDuration(2), 'Retry 2 must be scheduled 10 seconds out.');
        _Assert.AreEqual(FifteenSeconds, EntriaJQ.BackoffDuration(3), 'Retry 3 must be scheduled 15 seconds out.');
        _Assert.AreEqual(TwentySeconds, EntriaJQ.BackoffDuration(4), 'Retry 4 must be scheduled 20 seconds out.');
        _Assert.AreEqual(ThirtySeconds, EntriaJQ.BackoffDuration(5), 'Retry 5 must be scheduled 30 seconds out.');
        _Assert.AreEqual(FortySeconds, EntriaJQ.BackoffDuration(6), 'Retry 6 must be scheduled 40 seconds out.');
        _Assert.AreEqual(OneMinute, EntriaJQ.BackoffDuration(7), 'Retry 7 must be scheduled 1 minute out.');
        _Assert.AreEqual(NinetySeconds, EntriaJQ.BackoffDuration(8), 'Retry 8 must be scheduled 90 seconds out.');
        _Assert.AreEqual(TwoAndAHalfMinutes, EntriaJQ.BackoffDuration(9), 'Retry 9 must be scheduled 2.5 minutes out.');
        _Assert.AreEqual(ThreeMinutes, EntriaJQ.BackoffDuration(10), 'Retry 10 must be scheduled 3 minutes out.');

        // [THEN] The retry budget those steps have to cover is ten retries
        _Assert.AreEqual(10, EntriaJQ.MaxRetries(), 'The retry budget must be 10 retries.');

        // [WHEN] The backoff steps of the whole budget are summed
        for i := 1 to EntriaJQ.MaxRetries() do
            TotalBudget += EntriaJQ.BackoffDuration(i);

        // [THEN] They span exactly ten minutes
        _Assert.AreEqual(TenMinutes, TotalBudget, 'The backoff steps of the whole budget must add up to exactly ten minutes.');

        // [WHEN] A retry number beyond the budget is asked for
        asserterror EntriaJQ.BackoffDuration(EntriaJQ.MaxRetries() + 1);

        // [THEN] It errors for being outside the retry range rather than inventing a cadence, and not
        //        because of something unrelated on the way there
        _Assert.ExpectedError('is outside the supported Entria order retry range');
    end;

    [Test]
    procedure MissingCustomDisplayIdGetsOneRegistryRowNotOnePerPass()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        NextRetryAtAfterFirstPass: DateTime;
        PageAccepted: Boolean;
    begin
        // [SCENARIO] custom_display_id is an Entria customisation (unlike the core timestamps), so
        // its absence is a PER-ORDER data problem.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A seeded session max and a page holding one order that carries no custom_display_id
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithoutDisplayId(OrdersArr, 'medusa-nodispid2p', CreateDateTime(DMY2Date(20, 6, 2024), 100000T), 100);

        // [WHEN] ProcessList runs over that page a first time
        PageAccepted := EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The page is accepted - the missing display id is only a per-order failure
        _Assert.IsTrue(PageAccepted, 'A missing display id must not reject the page - it is a per-order failure.');

        // [THEN] The order gets a registry row on the normal retry budget, with Display No. defaulted to 0
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-nodispid2p');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'First pass records the initial failure with the normal retry budget.');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Display No.",
            'The fixture carries no Medusa display_id property at all, so Display No. must default to 0, not error the page.');
        NextRetryAtAfterFirstPass := EntriaOrderImpFailure."Next Retry At";

        // [WHEN] ProcessList runs a second time over the same page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The existing row is skipped, not re-logged - Retry Count and Next Retry At are unchanged
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-nodispid2p');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'Second pass must not re-log: the row exists, so the list path skips the order.');
        _Assert.AreEqual(NextRetryAtAfterFirstPass, EntriaOrderImpFailure."Next Retry At",
            'Second pass must leave the row untouched entirely.');
    end;

    [Test]
    procedure PageOfAlreadyImportedOrdersStillAdvancesMarker()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] Marker bookkeeping is unconditional for every order the page returned. A page
        // holding nothing but already-imported orders (the steady state, thanks to the 30s overlap)
        // must still advance the session max - otherwise the marker stands still and the same page
        // is re-listed every second for the rest of the 6h session.

        // [GIVEN] An enabled Entria store and an order created at 11:00 on 21 June 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(21, 6, 2024), 110000T);

        // [GIVEN] That order's document has already been imported, so an Ecom Sales Header exists for it,
        //         still carrying no Bucket Id - only a reached ProcessOrder ever assigns one
        _LibraryEntria.CreateEcomOrderHeader(_StoreCode, 'ZZ-DOC-IMPORTED');
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-IMPORTED');
        _Assert.AreEqual(0, EcomSalesHeader."Bucket Id", 'Setup: the already-imported header must start unbucketed.');

        // [GIVEN] A seeded session max and a page holding nothing but that already-imported order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-IMPORTED', 'medusa-imported', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max still advances past it, and no registry row is created
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'The session max must advance past an already-imported order too.');
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-imported'),
            'An already-imported order must not produce a registry row.');

        // [THEN] The document is not duplicated - exactly one Ecom Sales Header remains
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-IMPORTED');
        _Assert.AreEqual(1, EcomSalesHeader.Count(),
            'Exactly one Ecom Sales Header must exist for the already-imported document - the dedup must not create a duplicate.');

        // [THEN] The order never reached ProcessOrder at all - its header is still unbucketed
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-IMPORTED');
        _Assert.AreEqual(0, EcomSalesHeader."Bucket Id",
            'The batch dedup must skip the order BEFORE ProcessOrder - a reached ProcessOrder assigns a Bucket Id, which re-publishes the already-imported document to the bucket-filtered processing jobs.');
    end;

    [Test]
    procedure SuccessfulImportDeletesRegistryRow()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        NowDT: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The registry invariant: a row exists only while the last known attempt failed.
        // A subsequent successful import of the same order must delete its row - that is what keeps
        // the registry from accumulating rows for orders that have long since made it in.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        NowDT := CurrentDateTime();

        // [GIVEN] A registry row recording that the order's last attempt failed
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-HEAL', 'medusa-heal', NowDT, 'boom', 0, NowDT);
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-heal'), 'Setup: the registry row must exist before the retry.');

        // [GIVEN] A payload for that same order that will import cleanly - zero amount, so the payment guard passes
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-HEAL', 'medusa-heal', NowDT, NowDT, 0);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder re-imports the order
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-HEAL', 'medusa-heal', NowDT, 0);

        // [THEN] The retry import succeeds
        _Assert.IsTrue(ImportSucceeded, 'The retry import must succeed.');

        // [THEN] The registry row is deleted, so the registry only holds orders whose last attempt failed
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-heal'),
            'A successful import must delete the registry row.');
    end;

    [Test]
    procedure OrderListRequestContract()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        RequestText: Text;
        FromDT: DateTime;
    begin
        // [SCENARIO] The literal wire contract of the bc-sync work-list endpoint, and the one place in
        // the suite that exercises the actual request text. Three things have to hold together or the
        // marker design breaks: the work list is narrowed to bc_status=pending, the window filter and
        // the sort key are the SAME field the marker is flushed from (bc_status_updated_at), and the
        // sort is ascending so flushing between pages only ever advances past rows already consumed.

        // [GIVEN] A window start of 12:00 on 15 June 2024
        FromDT := CreateDateTime(DMY2Date(15, 6, 2024), 120000T);

        // [WHEN] The list request is generated for offset 80 and limit 40 from that window start
        RequestText := EntriaJQ.GenerateGetOrderListRequest(80, 40, FromDT);

        // [THEN] It addresses the bc-sync endpoint and asks only for orders awaiting BC
        _Assert.IsTrue(RequestText.StartsWith('admin/orders/bc-sync?'),
            'The list must be fetched from the bc-sync endpoint - admin/orders/bc-sync, plural "orders".');
        _Assert.IsTrue(RequestText.Contains('bc_status=pending'), 'The list must be narrowed to orders awaiting BC processing.');

        // [THEN] Window filter and sort key are both bc_status_updated_at, and the window start is carried
        //        through EXACTLY as handed in - the builder must not adjust it, or the offset it is paired
        //        with would be indexing a result set of a different shape
        _Assert.IsTrue(RequestText.Contains('bc_status_updated_at[$gte]=' + Format(FromDT, 0, 9)),
            'The window filter must be bc_status_updated_at carrying the window start verbatim - any adjustment here reshapes the result set the offset counts against.');
        _Assert.IsTrue(RequestText.Contains('order=bc_status_updated_at'),
            'The list must be sorted by bc_status_updated_at - the same field the marker is flushed from.');

        // [THEN] The sort is ascending, which is what the endpoint specifies - oldest first, so the
        //        orders that have waited longest are imported first. It is also what makes carrying the
        //        window forward between pages safe: newest-first would put the window maximum on page 1,
        //        so a pass that stopped early would leave the marker above every page it never read and
        //        lose those orders for good.
        _Assert.IsFalse(RequestText.Contains('order=-'),
            'The sort must be ascending: oldest first, so a between-pages flush only advances past consumed rows.');

        // [THEN] The mutable updated_at drives neither the window nor the sort - that was the original skip bug
        _Assert.IsFalse(RequestText.Contains('&updated_at[$gte]'), 'updated_at must never be the window filter - it is mutable.');
        _Assert.IsFalse(RequestText.Contains('order=updated_at'), 'updated_at must never be the sort key - it is mutable.');

        // [THEN] Offset and limit are passed through verbatim
        _Assert.IsTrue(RequestText.Contains('offset=80'), 'The offset must be passed through verbatim.');
        _Assert.IsTrue(RequestText.Contains('limit=40'), 'The limit must be passed through verbatim.');

        // [THEN] The field projection asks for the properties the importer actually reads, so a
        //        projection that stopped requesting them cannot pass unnoticed
        _Assert.IsTrue(RequestText.Contains('payment_collections.payments'),
            'The projection must request payment_collections.payments - without them every non-zero order hits the missing-payments error and can never import, no matter how often it is retried.');
        _Assert.IsTrue(RequestText.Contains('currency_code'),
            'The projection must request currency_code - without it every foreign-currency order imports as if it were in LCY.');
        _Assert.IsTrue(RequestText.Contains('billing_address'),
            'The projection must request billing_address - without it every imported document loses its Sell-to name, address and phone no.');

        // [WHEN] The list request is generated for a store that has never synced (0DT marker)
        RequestText := EntriaJQ.GenerateGetOrderListRequest(0, 40, 0DT);

        // [THEN] The request carries no window filter at all, so the full pending backlog is requested
        _Assert.IsFalse(RequestText.Contains('[$gte]'),
            'A store that has never synced (0DT marker) must request the whole pending backlog, without a window filter.');
        _Assert.IsTrue(RequestText.Contains('bc_status=pending'),
            'Even without a window the request must stay narrowed to orders awaiting BC processing.');
    end;

    [Test]
    procedure PageWithOrderMissingMedusaIdIsRejected()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        GoodArr: JsonArray;
        BadArr: JsonArray;
        NoIdObj: JsonObject;
        SomeDT: DateTime;
        PageAccepted: Boolean;
    begin
        // [SCENARIO] A page containing even one order without a readable Medusa id must be rejected
        // as a whole - ProcessList returns false BEFORE processing anything, and the caller treats
        // it like a failed list fetch (loud, marker untouched). Such an order can neither be
        // imported nor recorded in the registry, and before this guard the required id read threw
        // outside any try boundary and took the whole job queue session down for every store.

        // [GIVEN] An enabled Entria store and a reference timestamp of 10:00 on 24 June 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        SomeDT := CreateDateTime(DMY2Date(24, 6, 2024), 100000T);

        // [GIVEN] A seeded session max and a page whose every order carries a Medusa id
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(GoodArr, 'ZZ-DOC-IDOK', 'medusa-idok', SomeDT, SomeDT, 100);
        EntriaJQ.SeedSessionMax(_StoreCode);

        // [WHEN] ProcessList runs over that page
        PageAccepted := EntriaJQ.ProcessList(GoodArr, EntriaStore);

        // [THEN] The page is accepted
        _Assert.IsTrue(PageAccepted, 'A page whose every order carries an id must be accepted.');

        // [GIVEN] A second page holding one valid order plus one order carrying no readable Medusa id
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(BadArr, 'ZZ-DOC-IDOK2', 'medusa-idok2', SomeDT, SomeDT, 100);
        NoIdObj.Add('custom_display_id', 'ZZ-DOC-NOID');
        NoIdObj.Add('created_at', Format(SomeDT, 0, 9));
        NoIdObj.Add('updated_at', Format(SomeDT, 0, 9));
        BadArr.Add(NoIdObj);

        // [WHEN] ProcessList runs over the page containing the id-less order
        PageAccepted := EntriaJQ.ProcessList(BadArr, EntriaStore);

        // [THEN] The whole page is rejected
        _Assert.IsFalse(PageAccepted, 'A page containing one order without an id must be rejected as a whole.');

        // [THEN] The rejection is atomic - not even the valid order of that page was touched
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-idok2'),
            'The rejection must be atomic: no order of the rejected page may have been processed or registered.');
    end;

    [Test]
    procedure RetrySkippedWhenListFetchFailedThisCycle()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        NowDT: DateTime;
    begin
        // [SCENARIO] During a Medusa outage (store-wide list fetch failed this cycle), the
        // bounded retry pass must be skipped entirely so failed orders don't burn a retry
        // attempt for nothing.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        NowDT := CurrentDateTime();

        // [GIVEN] A registry row whose Next Retry At is already a minute in the past, so it is due
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SKIP', 'medusa-skip', NowDT, 'boom', 0, NowDT - 60000);

        // [WHEN] The retry pass runs for a cycle whose store-wide list fetch failed
        EntriaJQ.ProcessDueRetries(EntriaStore, false);

        // [THEN] The due row still exists with its retry budget intact - the retry stage never ran
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-skip'), 'Registry row must still exist untouched.');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'Retry Count must be unchanged - the retry stage must not have run.');
    end;

    [Test]
    procedure NoPaymentLinesWithNonZeroAmountFailsImport()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] An order with zero payment lines and a non-zero amount must fail
        // import (no Ecom document left behind), so it becomes eligible for a durable retry.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] An order payload with an amount of 100 and no payment lines at all
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-NOPAY', 'medusa-nopay', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 100);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder tries to import it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-NOPAY', 'medusa-nopay', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);

        // [THEN] The import fails
        _Assert.IsFalse(ImportSucceeded, 'Import must fail when there are no payment lines and the document amount is non-zero.');

        // [THEN] No Ecom Sales Header is left behind - the insert was rolled back
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-NOPAY');
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'No Ecom Sales Header may survive a failed import - the insert must have been rolled back.');
    end;

    [Test]
    procedure NoPaymentLinesWithZeroAmountSucceeds()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] A zero-value order with zero payment lines must still import
        // successfully - it is a legitimate zero-value order, not a missing-payment-lines bug.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] An order payload with a zero amount and no payment lines at all
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-ZEROAMT', 'medusa-zeroamt', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-ZEROAMT', 'medusa-zeroamt', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);

        // [THEN] The import succeeds
        _Assert.IsTrue(ImportSucceeded, 'Import must succeed for a zero-value order even with no payment lines.');

        // [THEN] The Ecom Sales Header is created for the zero-value order
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-ZEROAMT');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
    end;

    [Test]
    procedure EmptyPaymentCollectionsWithNonZeroAmountFailsImport()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] Second shape: "payment_collections" IS present but carries an empty
        // "payments" array. That must fail the import just like a missing "payment_collections" does.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] An order payload with an amount of 100 whose payment_collections carries an empty payments array
        _LibraryEntria.BuildOrderArrayWithEmptyPaymentCollections(OrdersArr, 'ZZ-DOC-EMPTYPC', 'medusa-emptypc', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 100);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder tries to import it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-EMPTYPC', 'medusa-emptypc', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);

        // [THEN] The import fails, exactly as for a missing payment_collections
        _Assert.IsFalse(ImportSucceeded, 'Import must fail when payment_collections carries an empty payments array and the amount is non-zero.');

        // [THEN] No Ecom Sales Header is left behind - the insert was rolled back
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-EMPTYPC');
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'No Ecom Sales Header may survive a failed import - the insert must have been rolled back.');
    end;

    [Test]
    procedure NonZeroOrderWithPaymentsImportsWithPaymentLine()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        PaymentAmount: Decimal;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The success direction of the payment guard: a non-zero order that carries its
        // payments imports and produces a payment line from payment_collections.payments.

        // [GIVEN] An enabled Entria store and an order of 100 created at 09:00 on 1 January 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 1, 2024), 090000T);
        PaymentAmount := 100;

        // [GIVEN] The payload carries a matching card payment of 100 with pspReference 'PSP-PAID'
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-PAID', 'medusa-paid', OrderCreatedAt, OrderCreatedAt, PaymentAmount, PaymentAmount, 'PSP-PAID');
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-PAID', 'medusa-paid', OrderCreatedAt, 0);

        // [THEN] The import succeeds
        _Assert.IsTrue(ImportSucceeded, 'A non-zero order carrying its payments must import.');

        // [THEN] The Ecom Sales Header is created
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-PAID');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');

        // [THEN] Exactly one payment line is created, carrying the payment's amount and pspReference
        EcomSalesPmtLine.SetRange("External Document No.", 'ZZ-DOC-PAID');
        _Assert.AreEqual(1, EcomSalesPmtLine.Count(), 'Exactly one payment line must be created from payment_collections.payments.');
        EcomSalesPmtLine.FindFirst();
        _Assert.AreEqual(PaymentAmount, EcomSalesPmtLine.Amount, 'The payment line must carry the payment''s amount.');
        _Assert.AreEqual('PSP-PAID', EcomSalesPmtLine."Payment Reference", 'The payment line must carry the payment''s pspReference.');
    end;

    [Test]
    procedure OrderWithUnresolvableLocaleStillImports()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        Language: Codeunit Language;
        OrdersArr: JsonArray;
        OrderObj: JsonObject;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] Entria deliberately does not reject an unusable locale at intake. The order imports with the tag
        // preserved and no language code, so the rejection happens later, at processing time, through
        // ValidateLanguage. Without that, one shop-side locale typo would fail the order's import and send it
        // round the retry registry instead of leaving an actionable document for the operator.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 1, 2024), 090000T);

        // [GIVEN] 'zz-ZZ' resolves to no Windows language, so no BC language code can be derived from it
        _Assert.IsFalse(WindowsLanguage.Get(Language.GetLanguageIdFromCultureName('zz-ZZ')), 'Precondition: ''zz-ZZ'' must not resolve to a Windows Language row.');

        // [GIVEN] An order payload carrying that locale
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-LOCALE', 'medusa-locale', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-LOCALE');
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();
        OrderObj.Add('locale', 'zz-ZZ');
        OrderTkn := OrderObj.AsToken();

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-LOCALE', 'medusa-locale', OrderCreatedAt, 0);

        // [THEN] The import succeeds - an unusable locale must not fail the Entria import
        _Assert.IsTrue(ImportSucceeded, 'An order carrying an unresolvable locale must still import.');

        // [THEN] The document exists, keeps the tag it was sent, and carries no language code
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-LOCALE');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
        _Assert.AreEqual('zz-ZZ', EcomSalesHeader."Language Tag", 'The supplied locale must be preserved on the document, so the later failure names the offending value.');
        _Assert.AreEqual('', EcomSalesHeader."Language Code", 'No language code can be derived from an unresolvable locale.');

        // [THEN] ...and the document does not process: the locale is rejected at processing time instead,
        asserterror EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeader);
        _Assert.ExpectedError('RFC 5646');
    end;

    [Test]
    procedure OrderWithUnmappedLocaleImportsThenFailsOnLanguageCode()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        Language: Record Language;
        WindowsLanguage: Record "Windows Language";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        SystemLanguage: Codeunit Language;
        OrdersArr: JsonArray;
        OrderObj: JsonObject;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The realistic version of the failure, and the one no intake gate catches. 'af-ZA' is a
        // perfectly valid tag, so ValidateLanguageTag passes and the Ecom API would not reject it either - but
        // no BC Language is set up for it, so the resolver falls back to the raw Windows abbreviation. The
        // order imports carrying a non-blank language code that has no Language record, and dies later on the
        // "Language Code" table relation - a different failure mechanism than an unusable tag.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 1, 2024), 090000T);

        // [GIVEN] 'af-ZA' is a real culture...
        _Assert.IsTrue(WindowsLanguage.Get(SystemLanguage.GetLanguageIdFromCultureName('af-ZA')), 'Precondition: ''af-ZA'' must resolve to a Windows Language row.');

        // [GIVEN] ...that no BC Language maps to, by either lookup. Asserted rather than arranged: this
        // codeunit rolls back once at the END of the run, so deleting real Language rows here would leak into
        // every test declared after this one.
        _Assert.IsFalse(Language.Get(WindowsLanguage."Abbreviated Name"), 'Precondition: no Language may be named after the Windows abbreviation of ''af-ZA''.');
        Language.SetRange("Windows Language ID", WindowsLanguage."Language ID");
        _Assert.IsTrue(Language.IsEmpty(), 'Precondition: no Language may carry the Windows language id of ''af-ZA''.');

        // [GIVEN] An order payload carrying that locale
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-LOC-UNMAP', 'medusa-loc-unmap', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-LOC-UNMAP');
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();
        OrderObj.Add('locale', 'af-ZA');
        OrderTkn := OrderObj.AsToken();

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-LOC-UNMAP', 'medusa-loc-unmap', OrderCreatedAt, 0);

        // [THEN] The import succeeds
        _Assert.IsTrue(ImportSucceeded, 'An order whose locale maps to no BC language must still import.');

        // [THEN] The document carries the Windows abbreviation, which is not a usable language code
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-LOC-UNMAP');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
        _Assert.AreEqual(WindowsLanguage."Abbreviated Name", EcomSalesHeader."Language Code", 'The fallback must put the Windows abbreviated name on the document.');
        _Assert.IsFalse(Language.Get(EcomSalesHeader."Language Code"), 'The fallback code must have no Language record - that is what makes it fail later.');

        // [THEN] ...so processing rejects it. The failure is the "Language Code" table relation, not the tag
        // check that catches an unusable tag - only the offending code is pinned, since the surrounding words
        // are a platform message.
        asserterror EcomSalesDocUtils.ValidateDocBySource(EcomSalesHeader);
        _Assert.ExpectedError(EcomSalesHeader."Language Code");
    end;

    [Test]
    procedure OrderWithoutLocaleImportsWithNoLanguage()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] An order that carries no locale at all must import with no language

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 1, 2024), 090000T);

        // [GIVEN] An order payload with no locale property at all
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-LOC-NONE', 'medusa-loc-none', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-LOC-NONE');
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-LOC-NONE', 'medusa-loc-none', OrderCreatedAt, 0);

        // [THEN] The import succeeds and the document carries no language at all
        _Assert.IsTrue(ImportSucceeded, 'An order without a locale must import.');
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-LOC-NONE');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
        _Assert.AreEqual('', EcomSalesHeader."Language Tag", 'No locale was supplied, so no language tag may be stored.');
        _Assert.AreEqual('', EcomSalesHeader."Language Code", 'No locale was supplied, so no language code may be derived.');
    end;

    [Test]
    procedure OrderWithMappedLocaleGetsLanguageCode()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        Language: Record Language;
        WindowsLanguage: Record "Windows Language";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        SystemLanguage: Codeunit Language;
        OrdersArr: JsonArray;
        OrderObj: JsonObject;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The success direction: the order with 'en-US' tag resolves to BC language code

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(1, 1, 2024), 090000T);

        // [GIVEN] 'en-US' resolves to a Windows language whose abbreviation is a real BC Language
        _Assert.IsTrue(WindowsLanguage.Get(SystemLanguage.GetLanguageIdFromCultureName('en-US')), 'Precondition: ''en-US'' must resolve to a Windows Language row.');
        _Assert.IsTrue(Language.Get(WindowsLanguage."Abbreviated Name"), 'Precondition: a Language named after the Windows abbreviation of ''en-US'' must exist.');

        // [GIVEN] An order payload carrying that locale
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-LOC-OK', 'medusa-loc-ok', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-LOC-OK');
        OrdersArr.Get(0, OrderTkn);
        OrderObj := OrderTkn.AsObject();
        OrderObj.Add('locale', 'en-US');
        OrderTkn := OrderObj.AsToken();

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-LOC-OK', 'medusa-loc-ok', OrderCreatedAt, 0);

        // [THEN] The import succeeds and the document carries both the tag and a usable language code
        _Assert.IsTrue(ImportSucceeded, 'An order with a mapped locale must import.');
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-LOC-OK');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
        _Assert.AreEqual('en-US', EcomSalesHeader."Language Tag", 'The supplied locale must be preserved on the document.');
        _Assert.AreEqual(Language.Code, EcomSalesHeader."Language Code", 'The locale must resolve to the BC Language named after its Windows abbreviation.');
    end;

    [Test]
    procedure EmptyPaymentCollectionsWithZeroAmountSucceeds()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The zero-amount exemption applies to the empty-payments shape too.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A zero-amount order payload whose payment_collections carries an empty payments array
        _LibraryEntria.BuildOrderArrayWithEmptyPaymentCollections(OrdersArr, 'ZZ-DOC-EMPTYPC0', 'medusa-emptypc0', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-EMPTYPC0', 'medusa-emptypc0', CreateDateTime(DMY2Date(1, 1, 2024), 090000T), 0);

        // [THEN] The import succeeds
        _Assert.IsTrue(ImportSucceeded, 'A zero-value order must import even with empty payment collections.');

        // [THEN] The Ecom Sales Header is created
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-EMPTYPC0');
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'The Ecom Sales Header must have been created.');
    end;

    [Test]
    procedure ListPathNeverTouchesOrderWithRegistryRow()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OldUpdatedAt: DateTime;
        NewUpdatedAt: DateTime;
        NextRetryAtBefore: DateTime;
    begin
        // [SCENARIO] The ownership rule: ANY registry row - even a parked one facing a strictly
        // FRESHER payload - removes the order from the list path entirely. Re-arm on a newer
        // updated_at belongs to the ID-based retry pass, which only ever sees rows that are still
        // due - a parked row has no automatic re-arm at all and waits for "Requeue for Import".
        // Either way the list path must leave the row byte-for-byte untouched.

        // [GIVEN] An enabled Entria store, an order first seen on 1 February 2024 and a fresher payload dated a day later
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OldUpdatedAt := CreateDateTime(DMY2Date(1, 2, 2024), 100000T);
        NewUpdatedAt := CreateDateTime(DMY2Date(2, 2, 2024), 100000T);

        // [GIVEN] Enough failures on the older payload to park the row at MaxRetries()
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-REARM', 'medusa-rearm', OldUpdatedAt);

        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm');
        NextRetryAtBefore := EntriaOrderImpFailure."Next Retry At";

        // [GIVEN] A seeded session max and a page carrying that same order with the FRESHER updated_at
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-REARM', 'medusa-rearm', NewUpdatedAt, NewUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The row is left byte-for-byte untouched - Status, Retry Count, Order Updated At and Next Retry At all unchanged
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status, 'The list path must not touch the row: Status unchanged, still Error.');
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count", 'The list path must not touch the row: Retry Count unchanged.');
        _Assert.AreEqual(OldUpdatedAt, EntriaOrderImpFailure."Order Updated At", 'The list path must not touch the row: Order Updated At unchanged.');
        _Assert.AreEqual(NextRetryAtBefore, EntriaOrderImpFailure."Next Retry At", 'The list path must not touch the row: Next Retry At unchanged.');
    end;

    [Test]
    procedure IsPayloadFresherHonoursTheRoundingSlack()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        RowUpdatedAt: DateTime;
        NoTimestampOnEitherSideIsFresher: Boolean;
        FirstTimestampAgainstEmptyRowIsFresher: Boolean;
        UnchangedTimestampIsFresher: Boolean;
        ExactlyTheSlackIsFresher: Boolean;
        OneMsPastTheSlackIsFresher: Boolean;
    begin
        // [SCENARIO] The predicate ProcessDueRetry's "Retry Count := 0" re-arm hangs on: a payload
        // counts as fresher only STRICTLY past the row's timestamp plus the 10 ms slack that absorbs
        // SQL's 1/300s datetime rounding.

        // [GIVEN] A registry row timestamped 10:00 on 5 July 2024
        RowUpdatedAt := CreateDateTime(DMY2Date(5, 7, 2024), 100000T);

        // [WHEN] The predicate is asked about no timestamp at all, a first timestamp against an empty row,
        //        an unchanged one, one exactly the slack later and one a millisecond past the slack
        NoTimestampOnEitherSideIsFresher := EntriaJQ.IsPayloadFresher(0DT, 0DT);
        FirstTimestampAgainstEmptyRowIsFresher := EntriaJQ.IsPayloadFresher(RowUpdatedAt, 0DT);
        UnchangedTimestampIsFresher := EntriaJQ.IsPayloadFresher(RowUpdatedAt, RowUpdatedAt);
        ExactlyTheSlackIsFresher := EntriaJQ.IsPayloadFresher(RowUpdatedAt + 10, RowUpdatedAt);
        OneMsPastTheSlackIsFresher := EntriaJQ.IsPayloadFresher(RowUpdatedAt + 11, RowUpdatedAt);

        // [THEN] With no timestamp on either side there is nothing to re-arm on
        _Assert.IsFalse(NoTimestampOnEitherSideIsFresher,
            'A payload with no updated_at must not re-arm a row that has none either - it would hand back a full retry budget on every pass and the order would never park.');

        // [THEN] The first real timestamp against an empty row is fresher
        _Assert.IsTrue(FirstTimestampAgainstEmptyRowIsFresher,
            'A first real updated_at against an empty row must re-arm - otherwise an order whose row predates timestamp capture can never earn a retry from a genuine edit.');

        // [THEN] An unchanged timestamp is not fresher
        _Assert.IsFalse(UnchangedTimestampIsFresher,
            'An unchanged updated_at must not re-arm - Retry Count would reset on every retry and the order would never reach parking.');

        // [THEN] A difference of exactly the slack is still rounding noise, not an edit
        _Assert.IsFalse(ExactlyTheSlackIsFresher,
            'A gap of exactly the 10 ms slack is the SQL read-back artifact, not an edit - re-arming on it resets the retry budget forever and the order never parks.');

        // [THEN] One millisecond past the slack is a real edit
        _Assert.IsTrue(OneMsPastTheSlackIsFresher,
            'A gap past the 10 ms slack is a real merchant edit and must re-arm - without it a corrected order keeps burning the retry budget it was already denied.');
    end;

    [Test]
    procedure SkippedRowIsNotRearmedByFresherPayload()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OldUpdatedAt: DateTime;
        NewUpdatedAt: DateTime;
        RetryCountBefore: Integer;
    begin
        // [SCENARIO] Skipped is an explicit human "stop trying this one" and outranks even a fresher
        // payload. Two things are pinned. The scheduled import must leave the row untouched - the order
        // timestamp proves it, since it is always rewritten when a row is touched, so it would now be
        // carrying the newer value; that half holds simply because the row exists, Skipped or not. The
        // half that Skipped alone carries is the retry pass refusing to pick the row up as due.

        // [GIVEN] An enabled Entria store, an order first seen on 3 February 2024 and a fresher payload dated a day later
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OldUpdatedAt := CreateDateTime(DMY2Date(3, 2, 2024), 100000T);
        NewUpdatedAt := CreateDateTime(DMY2Date(4, 2, 2024), 100000T);

        // [GIVEN] A registry row for that order that a human has explicitly Skipped
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SUPRR', 'medusa-suprr', OldUpdatedAt, 'boom', 0, CurrentDateTime() - 60000);
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-suprr');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprr');
        RetryCountBefore := EntriaOrderImpFailure."Retry Count";

        // [GIVEN] A seeded session max and a page carrying that same order with the FRESHER updated_at
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-SUPRR', 'medusa-suprr', NewUpdatedAt, NewUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The row survives still reading Skipped and with its Retry Count unchanged
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprr'), 'The Skipped row must still exist.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status, 'Status must remain Skipped - a newer payload must not clear a human''s explicit stop.');
        _Assert.AreEqual(RetryCountBefore, EntriaOrderImpFailure."Retry Count", 'Retry Count must be unchanged - the list path must not touch a Skipped row at all.');
        _Assert.AreEqual(OldUpdatedAt, EntriaOrderImpFailure."Order Updated At",
            'Order Updated At must still be the ORIGINAL payload''s - SetFailureFields writes it unconditionally, so a list path that touched this row would have stamped the fresher timestamp onto it.');

        // [THEN] The ID-based retry pass does not re-arm it either
        _Assert.IsFalse(EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-suprr'),
            'A Skipped row must not be due for the ID-based retry pass either.');
    end;

    [Test]
    procedure SkippedRowIsBypassedByTheWholeRetryPass()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
        NextRetryAtBefore: DateTime;
    begin
        // [SCENARIO] Skipped is checked twice on the way to a retry - as a filter when the due rows
        // are collected, and once more per row just before it is retried, since a human can Skip a
        // row between the two. ProcessDueRetries is the only reachable seam that runs the whole sequence,
        // so the end-to-end guarantee is pinned here: a row that is due on every other count must come
        // out of a complete retry pass untouched while it is Skipped.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 8 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(8, 2, 2024), 100000T);

        // [GIVEN] A registry row that is due on every other count - a minute-old Next Retry At and its full retry budget
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SUPRUN', 'medusa-suprun', OrderUpdatedAt, 'boom', 360, CurrentDateTime() - 60000);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprun');
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" <= CurrentDateTime(),
            'Setup: the row must already be due on its Next Retry At, so Skipped is the only thing holding it back.');
        NextRetryAtBefore := EntriaOrderImpFailure."Next Retry At";

        // [GIVEN] A human has Skipped that row
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-suprun');

        // [WHEN] A full retry pass runs for a cycle whose store-wide list fetch succeeded
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The row was never retried - retry budget, schedule and the human's stop are all intact
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprun');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'A Skipped row must not be retried - a burnt retry means the pass drove an order a human explicitly stopped towards parking.');
        _Assert.AreEqual(NextRetryAtBefore, EntriaOrderImpFailure."Next Retry At",
            'A Skipped row must not be rescheduled either - the retry pass must leave it exactly as the human left it.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status, 'The retry pass must not lift Skipped.');
    end;

    [Test]
    procedure NeitherHalfOfTheParkedStateAloneIsRetried()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        PastDueDT: DateTime;
        ExhaustedRowIsDue: Boolean;
        SentinelRowIsDue: Boolean;
        DueControlRowIsDue: Boolean;
    begin
        // [SCENARIO] A row that reached parking through the normal route carries every marker of the
        // parked state at once - Retry Count at MaxRetries(), the 0DT sentinel in "Next Retry At" AND
        // Status Error - so no test built on such a row can tell which of the conditions is doing the
        // work. Each is pinned on its own here, on rows inserted directly: an exhausted budget alone
        // keeps a row out of the retry pass even with a perfectly due timestamp and a Status that still
        // says Pending, and the 0DT sentinel alone keeps it out even on a full budget.

        // [GIVEN] An enabled Entria store and a due timestamp an hour in the past
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        PastDueDT := CurrentDateTime() - (60 * 60 * 1000);

        // [GIVEN] A row whose retry budget is exhausted, but whose Next Retry At is a real and long-past timestamp
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-exhausted', EntriaJQ.MaxRetries(), PastDueDT, Enum::"NPR Entria Order Imp. Status"::Pending);

        // [GIVEN] A row on its full retry budget, but carrying the 0DT sentinel
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-sentinel', 0, 0DT);

        // [GIVEN] A row that is due on both counts, so a pass that picked up nothing at all would be caught
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-duecontrol', 0, PastDueDT);

        // [WHEN] The ID-based retry pass is asked about each of the three rows
        ExhaustedRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-exhausted');
        SentinelRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-sentinel');
        DueControlRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-duecontrol');

        // [THEN] The exhausted row is not retried, however due its timestamp looks and whatever its Status says
        _Assert.IsFalse(ExhaustedRowIsDue,
            'A row at MaxRetries() must never be retried automatically - it waits for "Requeue for Import", or the retry budget stops bounding anything and a row is retried on the strength of its Status label alone.');

        // [THEN] The 0DT row is not retried either, however much budget it has left
        _Assert.IsFalse(SentinelRowIsDue,
            'The 0DT sentinel must never be read as "due since the beginning of time" - such a row would be re-fetched on every single cycle.');

        // [THEN] The row that is due on both counts is picked up
        _Assert.IsTrue(DueControlRowIsDue,
            'A row with budget left and a past Next Retry At must be retried - otherwise the two assertions above would hold for every row alike.');
    end;

    [Test]
    procedure IsRetryDuePinsEachConditionOnItsOwn()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        PastDueDT: DateTime;
        ControlRowIsDue: Boolean;
        SkippedRowIsDue: Boolean;
        ExhaustedRowIsDue: Boolean;
        SentinelRowIsDue: Boolean;
        FutureRowIsDue: Boolean;
    begin
        // [SCENARIO] IsRetryDue is the row-level re-check ProcessDueRetries runs after CollectDueRetries
        // has already filtered, so it is the half that stops a row Skipped between the two steps.
        // Asserting it through IsOrderDueForIdBasedRetry cannot pin it - that helper calls both layers,
        // so each masks the other and deleting one condition alone stays green. Each is pinned here.

        // [GIVEN] An enabled Entria store and a due timestamp an hour in the past
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        PastDueDT := CurrentDateTime() - (60 * 60 * 1000);

        // [GIVEN] A row due on every condition, and four rows each failing exactly one of them
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-all', 0, PastDueDT);
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-due-skipped', 0, PastDueDT, Enum::"NPR Entria Order Imp. Status"::Skipped);
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-due-exhausted', EntriaJQ.MaxRetries(), PastDueDT, Enum::"NPR Entria Order Imp. Status"::Pending);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-sentinel', 0, 0DT);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-future', 0, CurrentDateTime() + (60 * 60 * 1000));

        // [WHEN] The row-level check is asked about each row on its own
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-all');
        ControlRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-skipped');
        SkippedRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-exhausted');
        ExhaustedRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-sentinel');
        SentinelRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-future');
        FutureRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);

        // [THEN] The row failing nothing is due, so the four negatives below cannot hold vacuously
        _Assert.IsTrue(ControlRowIsDue,
            'A row with budget left and a past Next Retry At must be due here - otherwise this check rejects everything and the assertions below prove nothing.');

        // [THEN] Skipped alone stops it - this is the condition CollectDueRetries cannot cover
        _Assert.IsFalse(SkippedRowIsDue,
            'A row Skipped after CollectDueRetries picked it up must still be stopped here, or a human''s "stop trying this one" is ignored under concurrency.');

        // [THEN] An exhausted budget alone stops it, even while its Status still reads Pending
        _Assert.IsFalse(ExhaustedRowIsDue,
            'A row at MaxRetries() must be stopped by this check too, or the retry budget only bounds the collect step and not the process step.');

        // [THEN] The 0DT sentinel alone stops it
        _Assert.IsFalse(SentinelRowIsDue,
            'The 0DT sentinel must not read as "due since the beginning of time" here, or a parked row is re-fetched on every cycle.');

        // [THEN] A future timestamp alone stops it
        _Assert.IsFalse(FutureRowIsDue,
            'A row scheduled in the future must be stopped here, or the backoff schedule is ignored once a row reaches the process step.');
    end;

    [Test]
    procedure ForwardMarkerAdvanceDoesNotStopPaging()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        ExpectedMarkerDT: DateTime;
        ParallelSessionMarker: DateTime;
        InitialMarker: DateTime;
        SessionMaxSeed: DateTime;
    begin
        // [SCENARIO] The direction of an external marker change decides its meaning: this job's
        // own writes are strictly monotonic, so a FORWARD move can only be a parallel session's
        // flush (or a deliberate skip-ahead) - not a re-sync request. The pass must adopt the
        // higher value and keep paging, instead of abandoning its progress on every cycle of a
        // parallel session. Only a BACKWARDS move (a human rewind) stops the pass.

        // [GIVEN] An enabled Entria store and a marker value from a parallel session, far ahead in 2030
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        InitialMarker := CreateDateTime(DMY2Date(10, 6, 2024), 100000T);
        SessionMaxSeed := CreateDateTime(DMY2Date(12, 6, 2024), 100000T);
        ParallelSessionMarker := CreateDateTime(DMY2Date(1, 1, 2030), 120000T);

        // [GIVEN] A session max strictly between this pass's own window start and the parallel session's
        //         marker, seeded through the stored marker, so it is a value that COULD regress the higher
        //         one and the "must not regress" check below is not vacuous
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, SessionMaxSeed);
        EntriaJQ.SeedSessionMax(_StoreCode);

        // [GIVEN] This pass has snapshotted a real, non-0DT marker - the direction check is skipped
        //         entirely for the never-synced 0DT sentinel, which would make this whole test vacuous
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, InitialMarker);
        ExpectedMarkerDT := EntriaJQ.GetSyncStateMarker(_StoreCode);
        _Assert.AreEqual(InitialMarker, ExpectedMarkerDT, 'Setup: the pass must snapshot a real marker, not the 0DT sentinel.');

        // [WHEN] The stored marker is moved FORWARD underneath the pass, as a parallel session's flush would
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, ParallelSessionMarker);

        // [THEN] The flush treats it as no re-sync request, so paging continues
        _Assert.IsTrue(EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT),
            'A forward marker move is not a re-sync request - paging must continue.');

        // [THEN] The pass adopts the higher value as its own snapshot
        _Assert.AreEqual(ParallelSessionMarker, ExpectedMarkerDT,
            'The pass must adopt the higher value so the next page''s backwards-check compares against what it last saw.');

        // [THEN] The stored marker is not regressed to this pass's lower session max
        _Assert.AreEqual(ParallelSessionMarker, EntriaJQ.GetSyncStateMarker(_StoreCode),
            'The parallel session''s higher marker must stand - this pass''s lower session max must not regress it.');
    end;

    [Test]
    procedure IdBasedRetryCapsAt20EarliestDueRows()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        BaseDT: DateTime;
        RowIsDue: array[25] of Boolean;
        OrderId: Text;
        i: Integer;
    begin
        // [SCENARIO] MaxRetryRowsPerCycle() bounds the ID-based retry pass to the 20 EARLIEST due
        // rows (ordered by Next Retry At), so a large due backlog cannot turn into an unbounded
        // burst of single-order HTTP calls in one cycle.

        // [GIVEN] An enabled Entria store and a base timestamp one hour in the past, safely before "now"
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        BaseDT := CurrentDateTime() - (60 * 60 * 1000);

        // [GIVEN] 25 due registry rows whose Next Retry At values are staggered one second apart
        for i := 1 to 25 do begin
            EntriaOrderImpFailure.Init();
            EntriaOrderImpFailure."Store Code" := _StoreCode;
            EntriaOrderImpFailure."Order Id" := CopyStr(StrSubstNo('medusa-cap-%1', i), 1, MaxStrLen(EntriaOrderImpFailure."Order Id"));
            EntriaOrderImpFailure."Next Retry At" := BaseDT + (i * 1000);
            EntriaOrderImpFailure.Insert();
        end;

        // [WHEN] The capped ID-based retry pass decides, row by row, which of the 25 it picks up
        for i := 1 to 25 do begin
            OrderId := StrSubstNo('medusa-cap-%1', i);
            RowIsDue[i] := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, OrderId);
        end;

        // [THEN] The 20 earliest due rows are the ones the capped pass picks up
        for i := 1 to 20 do
            _Assert.IsTrue(RowIsDue[i],
                StrSubstNo('The %1. earliest due row must be included in the capped pass.', i));

        // [THEN] The 5 latest due rows are left for a following cycle
        for i := 21 to 25 do
            _Assert.IsFalse(RowIsDue[i],
                StrSubstNo('The %1. earliest due row must be excluded by the 20-row cap.', i));
    end;

    [Test]
    procedure SalesOrderIntegrationFlagGatesTheOrderImport()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] The master switch that decides whether the order import job exists counts only stores
        // that are BOTH Enabled and flagged for "Sales Order Integration"

        // [GIVEN] Exactly one enabled Entria store, flagged for Sales Order Integration
        Initialize();
        _LibraryEntria.DisableAllStores();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [THEN] It counts as an order-import store
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(),
            'An enabled store flagged for Sales Order Integration must count as an order-import store.');

        // [WHEN] Only the Sales Order Integration flag is cleared, the store staying Enabled
        EntriaStore.Get(_StoreCode);
        EntriaStore."Sales Order Integration" := false;
        EntriaStore.Modify();

        // [THEN] It no longer counts - being Enabled alone is not enough to be imported from
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(),
            'Enabled alone must not be enough - clearing Sales Order Integration must remove the store from the order import.');

        // [THEN] The webhook-side guard still sees it, because that one deliberately filters on
        //        Enabled only - the two guards are not interchangeable
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(),
            'HasEnabledStore filters on Enabled only, so the store must remain visible to the price-change webhook.');
    end;

    [Test]
    procedure ProcessEnabledStoresVisitsOnlySalesOrderIntegrationStores()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StoreCodeWithoutFlag: Code[20];
    begin
        // [SCENARIO] The job's own store loop filters on Enabled AND "Sales Order Integration".
        // HasEnabledSalesOrderIntegrationStore only decides whether the job exists, never which stores it visits.

        // [GIVEN] Exactly two enabled stores: one flagged for Sales Order Integration...
        Initialize();
        _LibraryEntria.DisableAllStores();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [GIVEN] ...and one Enabled but not flagged. Direct assignment, not Validate: the Enabled
        // OnValidate runs SetupJobQueues, which would leave a live recurring Job Queue Entry behind.
        StoreCodeWithoutFlag := 'ZZ-ENT-NOSOI';
        _LibraryEntria.CreateEntriaStoreWithUrl(EntriaStore, StoreCodeWithoutFlag);
        EntriaStore.Enabled := true;
        EntriaStore."Sales Order Integration" := false;
        EntriaStore.Modify();

        // [GIVEN] Neither store has a sync state row - that row is what proves the store was visited,
        //         and the loop creates it before the list fetch, so an unreachable Entria is no obstacle
        EntriaStoreSyncState.SetFilter("Store Code", '%1|%2', _StoreCode, StoreCodeWithoutFlag);
        EntriaStoreSyncState.DeleteAll();
        EntriaStoreSyncState.Reset();

        // [WHEN] The store loop runs, called directly - OnRun soft-exits on a synthetic Job Queue Entry ID
        EntriaJQ.ProcessEnabledStores();

        // [THEN] The flagged store was visited
        _Assert.IsTrue(EntriaStoreSyncState.Get(_StoreCode),
            'A store that is Enabled and flagged for Sales Order Integration must be visited by the import job - dropping that filter pair silently stops all order imports.');

        // [THEN] The unflagged store was not
        _Assert.IsFalse(EntriaStoreSyncState.Get(StoreCodeWithoutFlag),
            'A store with "Sales Order Integration" cleared must never be visited - the job would otherwise call Entria and import orders for a store the customer switched off.');
    end;

    [Test]
    procedure IntegrationDisabledHidesEveryEnabledStore()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] With "Enable Integration" cleared, ReadySetup() reports the integration off and both store lookups must find nothing
        // to import from

        // [GIVEN] Exactly one enabled Entria store, flagged for Sales Order Integration
        Initialize();
        _LibraryEntria.DisableAllStores();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [WHEN] The integration-level switch is cleared and the cached setup is invalidated, the store left untouched
        _LibraryEntria.SetEnableIntegration(false);
        EntriaIntegrationMgt.SetRereadSetup();

        // [THEN] Neither lookup sees the store any more
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledStore(),
            'With the integration disabled, HasEnabledStore must find nothing even though the store is still Enabled.');
        _Assert.IsFalse(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(),
            'With the integration disabled, no store may count as an order-import store.');

        // [THEN] The store record itself was not touched - only the switch was
        EntriaStore.Get(_StoreCode);
        _Assert.IsTrue(EntriaStore.Enabled, 'The store must still be Enabled - only the integration switch was cleared.');
        _Assert.IsTrue(EntriaStore."Sales Order Integration", 'The store must still be flagged for Sales Order Integration.');

        // [WHEN] The switch is turned back on and the cached setup is invalidated
        _LibraryEntria.SetEnableIntegration(true);
        EntriaIntegrationMgt.SetRereadSetup();

        // [THEN] Both lookups see the store again, so the switch is what gated them
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledStore(),
            'Re-enabling the integration must make the store visible again.');
        _Assert.IsTrue(EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore(),
            'Re-enabling the integration must restore the store as an order-import store.');
    end;

    [Test]
    procedure IsEnabledRequiresBothSetupAndStore()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] IsEnabled is the combined gate - it needs the integration switch on AND a
        // non-blank store code AND that store Enabled. All four corners are pinned here.
        //
        // SetRereadSetup() follows every write because IsEnabled reaches the store through a
        // by-code cache that would otherwise answer from the pre-write record.

        // [GIVEN] An enabled Entria store with the integration on
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [THEN] Integration on plus an Enabled store is enabled
        _Assert.IsTrue(EntriaIntegrationMgt.IsEnabled(_StoreCode),
            'An Enabled store must be enabled while the integration is on.');

        // [THEN] A blank store code is never enabled, whatever the setup says
        _Assert.IsFalse(EntriaIntegrationMgt.IsEnabled(''), 'A blank store code must never count as enabled.');

        // [WHEN] The store is disabled, the integration left on
        EntriaStore.Get(_StoreCode);
        EntriaStore.Enabled := false;
        EntriaStore.Modify();
        EntriaIntegrationMgt.SetRereadSetup();

        // [THEN] It is not enabled - the store flag alone can turn it off
        _Assert.IsFalse(EntriaIntegrationMgt.IsEnabled(_StoreCode),
            'A disabled store must not be enabled even while the integration is on.');

        // [WHEN] The store is Enabled again but the integration switch is cleared instead
        EntriaStore.Enabled := true;
        EntriaStore.Modify();
        _LibraryEntria.SetEnableIntegration(false);
        EntriaIntegrationMgt.SetRereadSetup();

        // [THEN] It is still not enabled - the switch outranks the store flag
        _Assert.IsFalse(EntriaIntegrationMgt.IsEnabled(_StoreCode),
            'The integration switch must outrank the store flag.');

        // Nothing restores this between tests - TestIsolation = Codeunit rolls back at the END of the
        // codeunit - and the SingleInstance codeunit caches the setup on top of that, so a later test that
        // reads it would get "integration off". Both the switch and the cache are put back explicitly.
        _LibraryEntria.SetEnableIntegration(true);
        EntriaIntegrationMgt.SetRereadSetup();
    end;

    [Test]
    procedure DeletingStoreDeletesRelatedOrderFailureRegistryRow()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StoreCode: Code[20];
    begin
        // [SCENARIO] "NPR Entria Store".OnDelete calls EntriaIntegrationMgt.DeleteRelatedRecords,
        // which must remove this store's Order Imp. Failure registry rows.

        // [GIVEN] An Entria store
        Initialize();
        StoreCode := 'ZZ-ENT-DELREL';
        EntriaStore.Init();
        EntriaStore.Code := StoreCode;
        EntriaStore.Insert();

        // [GIVEN] An Order Imp. Failure registry row belonging to that store
        EntriaJQ.UpsertOrderFailure(StoreCode, 'ZZ-DOC-DELREL', 'medusa-delrel', CurrentDateTime(), 'boom', 0, CurrentDateTime());
        _Assert.IsTrue(EntriaOrderImpFailure.Get(StoreCode, 'medusa-delrel'), 'Setup: the registry row must exist before the store is deleted.');

        // [WHEN] The store is deleted, so OnDelete runs DeleteRelatedRecords
        _LibraryEntria.DeleteStore(StoreCode);

        // [THEN] The store's registry row is gone too
        _Assert.IsFalse(EntriaOrderImpFailure.Get(StoreCode, 'medusa-delrel'), 'Deleting the store must delete its Order Imp. Failure registry row too.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure FailuresPageActionsRequeueForImportAndSkip()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaOrderImpFailuresPage: TestPage "NPR Entria Order Imp. Failures";
        OrderUpdatedAt: DateTime;
        BeforeInvokeDT: DateTime;
        AfterInvokeDT: DateTime;
    begin
        // [SCENARIO] The failures list page's two actions - Requeue for Import and Skip - must write through
        // Rec.Modify exactly as documented on the page. Requeue for Import is deliberately the only way back
        // from Skipped, so it is exercised here on a row that is both parked AND Skipped.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 5 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(5, 2, 2024), 100000T);

        // [GIVEN] Enough failures for that order to park its registry row at MaxRetries()
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-PAGEACT', 'medusa-pageact', OrderUpdatedAt);

        // [GIVEN] The row is also Skipped, so the move back to Pending is an observable change rather
        //         than a value it already carried, and the parked row's Next Retry At is the 0DT sentinel
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-pageact');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At", 'Setup: a parked row carries the 0DT sentinel, so any real reschedule is observable.');

        // [GIVEN] A lower timestamp just before the invoke, with 10 ms tolerance for SQL datetime
        //         precision on its 1/300s grid
        BeforeInvokeDT := CurrentDateTime() - 10;

        // [WHEN] "Requeue for Import" is invoked on that row from the failures list page
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.RequeueForImport.Invoke();
        // The upper bound is taken immediately after the invoke, with the same SQL datetime tolerance
        AfterInvokeDT := CurrentDateTime() + 10;
        EntriaOrderImpFailuresPage.Close();

        // [THEN] The row is Pending on a fresh budget and scheduled inside the invoke window
        AssertOrderWasArmedForImmediateRetry('medusa-pageact', BeforeInvokeDT, AfterInvokeDT, 'the page action');

        // Refresh the record before using it on the page again
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        // [WHEN] "Skip" is invoked on the same row
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.SkipOrder.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] The row reads Skipped
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status, 'Skip must set Status to Skipped.');

        // [THEN] Skip left the retry bookkeeping alone - it stops the order, it does not spend or grant budget
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'Skip must not touch Retry Count - a row released later must resume on the budget it had when it was stopped.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerNo')]
    procedure FailuresPageRequeueForImportCanBeCancelled()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        EntriaOrderImpFailuresPage: TestPage "NPR Entria Order Imp. Failures";
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] "Requeue for Import" asks before it acts, and a No must cost nothing: the action grants a
        // fresh retry budget to whichever row the cursor happens to sit on, so a misclick that went through
        // silently would put an order back into the import rotation nobody asked to have retried.

        // [GIVEN] An enabled Entria store and an order parked at MaxRetries(), so it reads Error on the 0DT sentinel
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(5, 2, 2024), 100000T);
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-CANCEL', 'medusa-cancel', OrderUpdatedAt);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-cancel');

        // [WHEN] "Requeue for Import" is invoked on that row and the confirmation is answered No
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.RequeueForImport.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] The row is exactly as it was - still parked in Error, on a spent budget and on the 0DT sentinel
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-cancel');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status,
            'A cancelled requeue must leave the Status alone - lifted to Pending on a No, the row is back in the retry rotation and the operator who misclicked has nothing telling them so.');
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count",
            'A cancelled requeue must leave Retry Count alone - reset on a No, the order is granted a whole fresh budget the operator declined to grant.');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At",
            'A cancelled requeue must leave the 0DT sentinel in place - given a real Next Retry At, the retry pass picks the row up on its next cycle.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure FailuresPageRequeueForImportWarnsWhenStoreIsDisabled()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaStore: Record "NPR Entria Store";
        JobQueueEntry: Record "Job Queue Entry";
        EntriaOrderImpFailuresPage: TestPage "NPR Entria Order Imp. Failures";
    begin
        // [SCENARIO] Requeueing only re-arms the row - the import itself is done by the Entria import job, which
        // skips a disabled store entirely. Requeued on such a store the row reads Pending and looks under way
        // while nothing will ever pick it up, so the operator has to be told what is in the way.

        // [GIVEN] An enabled Entria store carrying a Pending registry row
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-storeoff', 1, CurrentDateTime());
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-storeoff');

        // [GIVEN] The store is disabled after the row was registered
        _LibraryEntria.DisableAllStores();
        Clear(_LastMessageTxt);

        // [WHEN] "Requeue for Import" is confirmed on that row
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.RequeueForImport.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] The requeue still went through - the action does what it says whatever state the store is in
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-storeoff');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
            'The requeue must go through even on a disabled store - refused instead, an operator has to enable the store before a row can be re-armed at all, which is not what the action promises.');

        // [THEN] The operator was told which store the import will not run for
        _Assert.IsTrue(StrPos(_LastMessageTxt, _StoreCode) > 0,
            StrSubstNo('Requeueing on a disabled store must warn and must name the store - unnamed, an operator holding several stores cannot tell which one to go and enable. Message: "%1"', _LastMessageTxt));
        _Assert.IsTrue(StrPos(_LastMessageTxt, EntriaStore.TableCaption()) > 0,
            StrSubstNo('The warning must point at the Entria store as the thing to fix. Message: "%1"', _LastMessageTxt));

        // [THEN] It stops at the store and says nothing about the job queue: enabling the store runs
        //        SetupJobQueues, which brings the import job back on its own, so naming it would send the
        //        operator after a second thing that is about to fix itself
        _Assert.IsTrue(StrPos(_LastMessageTxt, JobQueueEntry.TableCaption()) = 0,
            StrSubstNo('A store that is off must be reported on its own - listing the job queue next to it sends the operator after something enabling the store already restores. Message: "%1"', _LastMessageTxt));
    end;

    [Test]
    procedure FailuresPageActionVisibilityFollowsStatus()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaOrderImpFailuresPage: TestPage "NPR Entria Order Imp. Failures";
        NextRetryAt: DateTime;
    begin
        // [SCENARIO] Skip must be offered only where it changes something - on a row that is not already
        // Skipped. Requeue for Import is the single way out of both Error and Skipped, so unlike Skip it must be
        // offered on every Status without exception, and a Skipped row is never left with no action at all.

        // [GIVEN] An enabled Entria store and a Pending registry row
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        NextRetryAt := CreateDateTime(DMY2Date(5, 2, 2024), 100000T);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-pagevis', 1, NextRetryAt);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pagevis');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status, 'Setup: the row must start out Pending, otherwise the first state is not the one under test.');

        // [WHEN] The page is opened on that row
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);

        // [THEN] Both actions are offered
        _Assert.IsTrue(EntriaOrderImpFailuresPage.SkipOrder.Visible(), 'Skip must be visible on a Pending row - hidden, the retrying row cannot be stopped from the list at all.');
        _Assert.IsTrue(EntriaOrderImpFailuresPage.RequeueForImport.Visible(), 'Requeue for Import must be visible on a Pending row - it is the only way to re-arm a row on demand, so it must never depend on the Status.');
        EntriaOrderImpFailuresPage.Close();

        // [GIVEN] The same row is at Error - its retry budget spent and no human stop on it
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pagevis');
        EntriaOrderImpFailure.Status := EntriaOrderImpFailure.Status::Error;
        EntriaOrderImpFailure.Modify();

        // [WHEN] The page is reopened on it
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);

        // [THEN] Skip follows Skipped and not "is this row moving", so an Error row is still offered Skip
        _Assert.IsTrue(EntriaOrderImpFailuresPage.SkipOrder.Visible(), 'Skip must be visible on an Error row - a human must be able to take an exhausted order off the list without first re-arming it.');
        _Assert.IsTrue(EntriaOrderImpFailuresPage.RequeueForImport.Visible(), 'Requeue for Import must be visible on an Error row - this is the Status it exists for.');
        EntriaOrderImpFailuresPage.Close();

        // [GIVEN] The same row is Skipped
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-pagevis');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pagevis');

        // [WHEN] The page is reopened on it
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);

        // [THEN] Skip drops away, and Requeue for Import is what is left to act on the row with
        _Assert.IsFalse(EntriaOrderImpFailuresPage.SkipOrder.Visible(),
            'Skip must be hidden on a Skipped row - offered, an operator invokes it on an already Skipped row and reads that as having just stopped a row that is in fact still retrying.');
        _Assert.IsTrue(EntriaOrderImpFailuresPage.RequeueForImport.Visible(), 'Requeue for Import must be visible on a Skipped row - it is the only action that both lifts the stop and grants a fresh budget.');
        EntriaOrderImpFailuresPage.Close();
    end;

    [Test]
    procedure RequeueForImportFromErrorAndFromSkippedBothArmAFreshBudget()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
        BeforeInvokeDT: DateTime;
        AfterInvokeDT: DateTime;
    begin
        // [SCENARIO] "Requeue for Import" is the single way out that actually gets the order imported again, and it
        // must behave identically whichever dead end the row sits in: both Error and Skipped must come out
        // Pending, on a full budget and due now. The page offers the action on every Status, so a state left
        // out here is a state where an operator presses it and nothing happens.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 12 March 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(12, 3, 2024), 100000T);

        // [GIVEN] One row parked in Error by a spent budget, and one row a human Skipped
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-REARMERR', 'medusa-rearmerr', OrderUpdatedAt);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-rearmskip', 3, CurrentDateTime() + (60 * 60 * 1000));
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-rearmskip');

        // [GIVEN] A lower timestamp immediately before re-arming the Error row, with 10 ms tolerance
        //         for SQL datetime precision on its 1/300s grid
        BeforeInvokeDT := CurrentDateTime() - 10;

        // [WHEN] "Requeue for Import" is applied to the Error row
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearmerr');
        EntriaJQ.MarkOrderForRetry(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Modify();
        // The upper bound is taken immediately after the write, with the same tolerance
        AfterInvokeDT := CurrentDateTime() + 10;

        // [THEN] It is Pending on a full budget, scheduled inside the action window and due for the retry pass
        AssertOrderWasArmedForImmediateRetry('medusa-rearmerr', BeforeInvokeDT, AfterInvokeDT, 'an Error row');

        // [GIVEN] A fresh lower bound immediately before re-arming the Skipped row
        BeforeInvokeDT := CurrentDateTime() - 10;

        // [WHEN] The same action is applied to the Skipped row
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearmskip');
        EntriaJQ.MarkOrderForRetry(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Modify();
        // A fresh upper bound taken immediately after the write
        AfterInvokeDT := CurrentDateTime() + 10;

        // [THEN] It comes out in exactly the same state - a human's stop is no harder to lift than a spent budget
        AssertOrderWasArmedForImmediateRetry('medusa-rearmskip', BeforeInvokeDT, AfterInvokeDT, 'a Skipped row');
    end;

    [Test]
    procedure SkippedRowSurvivesAFailureLoggedDuringTheRetryWindow()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] A retry pass that has already collected a row goes on to log its failure through
        // UpsertOrderFailure, which maintains Status from the retry budget. If a human presses Skip in the
        // meantime, that write must not talk the row back out of Skipped: the budget-derived Status is applied
        // only while the row is not Skipped, so the stop survives the failure that lands on top of it. The
        // row's own bookkeeping must still be kept, or the stop would freeze the budget too and an order
        // released later would run on retries it had in fact already spent.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 13 March 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(13, 3, 2024), 100000T);

        // [GIVEN] A registry row a human has Skipped
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SKIPMID', 'medusa-skipmid', OrderUpdatedAt, 'boom', 0, CurrentDateTime() - 60000);
        _LibraryEntria.SkipOrder(_StoreCode, 'medusa-skipmid');

        // [WHEN] A failure is logged for that order anyway, as a retry already in flight would
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SKIPMID', 'medusa-skipmid', OrderUpdatedAt, 'boom again', 0, CurrentDateTime());

        // [THEN] The row is still Skipped, and still not something the retry pass will pick up
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-skipmid');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status,
            'A failure logged onto a Skipped row must leave it Skipped - deriving Status from the budget here would undo a human''s stop the moment one more failure landed.');
        _Assert.IsFalse(EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-skipmid'),
            'The row must still be out of the retry pass - a Status quietly reset to Pending would put it straight back in.');

        // [THEN] The failure itself was still recorded, so the budget keeps counting behind the stop
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count",
            'The failure must still be counted on a Skipped row - dropping it would let the order be released later on a budget it had already spent.');
        _Assert.AreEqual('boom again', EntriaOrderImpFailure."Last Error",
            'The newest error must still be stored on a Skipped row - it is what a human decides on when releasing it.');
    end;

    [Test]
    procedure CueTilesSplitTheRegistryByStatus()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        RetailSalesCue: Record "NPR Retail Sales Cue";
        PendingBefore: Integer;
        ErrorBefore: Integer;
        SkippedBefore: Integer;
    begin
        // [SCENARIO] The three role center tiles must count three disjoint sets. Deltas are asserted rather
        // than absolutes on purpose: the FlowFields carry no store filter, so a registry row left behind under
        // a store code outside this codeunit's two is counted as well and Initialize() cannot sweep it. What a
        // delta of exactly 1 per tile still catches is the copy-paste failure three near-identical CalcFormulas
        // invite - two tiles sharing one Status filter, which moves one delta to 2 and leaves another at 0.

        // [GIVEN] An enabled Entria store and the three tile counts as they stand before anything is seeded
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        // The singleton cue row is read the way the role center pages read it, and initialised in memory if
        // the test database has none - none of the three CalcFormulas reads a field off the row itself.
        if not RetailSalesCue.Get() then
            RetailSalesCue.Init();
        RetailSalesCue.CalcFields("Entria Order Imports Pending", "Entria Order Imports Error", "Entria Order Imports Skipped");
        PendingBefore := RetailSalesCue."Entria Order Imports Pending";
        ErrorBefore := RetailSalesCue."Entria Order Imports Error";
        SkippedBefore := RetailSalesCue."Entria Order Imports Skipped";

        // [WHEN] Exactly one row of each Status is added for the test store
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-cue-pending', 0, CurrentDateTime(), EntriaOrderImpFailure.Status::Pending);
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-cue-error', 0, 0DT, EntriaOrderImpFailure.Status::Error);
        _LibraryEntria.InsertOrderFailureRowWithStatus(_StoreCode, 'medusa-cue-skipped', 0, CurrentDateTime(), EntriaOrderImpFailure.Status::Skipped);

        // [THEN] Each tile moved by exactly one, so no two of them are counting the same Status
        RetailSalesCue.CalcFields("Entria Order Imports Pending", "Entria Order Imports Error", "Entria Order Imports Skipped");
        _Assert.AreEqual(PendingBefore + 1, RetailSalesCue."Entria Order Imports Pending",
            'The Pending tile must move by the Pending row alone - counting another Status reports orders as still being worked on when nothing is retrying them.');
        _Assert.AreEqual(ErrorBefore + 1, RetailSalesCue."Entria Order Imports Error",
            'The Error tile must move by the Error row alone - this is the tile that summons a human, so a wrong filter either hides the work or invents it.');
        _Assert.AreEqual(SkippedBefore + 1, RetailSalesCue."Entria Order Imports Skipped",
            'The Skipped tile must move by the Skipped row alone - orders a human deliberately stopped must not be mixed into the two tiles that ask for attention.');
    end;

    [Test]
    procedure UpgradeMapsSuppressedAndExhaustedRowsOntoStatus()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        FutureRetryAt: DateTime;
    begin
        // [SCENARIO] The backfill that gives pre-existing registry rows a Status. Status ordinal 0 is Pending,
        // so without it every parked and every suppressed row would read as Pending and be handed straight
        // back to the retry pass. The one genuinely ambiguous row is the one that is BOTH suppressed and out
        // of budget: it must end up Skipped, because a human's explicit stop outranks exhaustion - mapping it
        // to Error instead would put an order somebody deliberately stopped onto the list of orders to act on.
        //
        // This is the only test that still writes the obsoleted Suppressed field, and it cannot avoid it: the
        // state rows carried before Status existed is exactly what is under test.

        // [GIVEN] An enabled Entria store and a future schedule stamped on a whole second, so it survives
        //         SQL's 1/300s datetime grid unchanged and the "not touched" assertion below can be exact
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        FutureRetryAt := CreateDateTime(Today() + 1, 100000T);

        // [GIVEN] Four rows as the old code left them - every Suppressed/budget combination, Status untouched
        InsertLegacyOrderFailureRow('medusa-upg-suppbudget', 1, FutureRetryAt, true);
        InsertLegacyOrderFailureRow('medusa-upg-suppmax', EntriaJQ.MaxRetries(), 0DT, true);
        InsertLegacyOrderFailureRow('medusa-upg-max', EntriaJQ.MaxRetries(), 0DT, false);
        InsertLegacyOrderFailureRow('medusa-upg-budget', 1, FutureRetryAt, false);

        // [WHEN] The backfill runs
        UPGEcomSalesDocs.MigrateEntriaOrderImpFailureStatus();

        // [THEN] A suppressed row with budget left becomes Skipped
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-suppbudget');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status,
            'A suppressed row must become Skipped - left Pending it would be retried on the first cycle after the upgrade, against the stop a human had put on it.');

        // [THEN] A row that was BOTH suppressed and out of budget becomes Skipped too - the human wins
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-suppmax');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status,
            'A suppressed row at MaxRetries() must become Skipped, not Error - a human''s explicit stop outranks exhaustion, so the Skipped mapping must be applied last and win.');

        // [THEN] An exhausted row nobody suppressed becomes Error
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-max');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status,
            'A row at MaxRetries() must become Error - left Pending it sits in the tile that says the job is still working on it while nothing will ever retry it again.');

        // [THEN] An ordinary row with budget left stays Pending
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-budget');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
            'A row with budget left and no stop on it must stay Pending - moving it would strand an order the retry pass was still working through.');

        // [THEN] The backfill only ever wrote Status - the retry bookkeeping it reads is left exactly as it was
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count", 'The backfill must not touch Retry Count - rewriting it would either hand out retry budget or spend it.');
        _Assert.AreEqual(FutureRetryAt, EntriaOrderImpFailure."Next Retry At", 'The backfill must not touch Next Retry At - the schedule the row already had is what the retry pass resumes on.');

        // [WHEN] The backfill runs a second time, as a re-run of the upgrade would
        UPGEcomSalesDocs.MigrateEntriaOrderImpFailureStatus();

        // [THEN] Nothing moves - the mapping reads only fields it never writes, so it is idempotent
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-suppmax');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status,
            'A second run must leave the suppressed exhausted row Skipped - a run that re-derived Status from the budget alone would demote it to Error.');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-upg-budget');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
            'A second run must leave the untouched row Pending.');
    end;

    [Test]
    procedure FresherPayloadReArmsPendingRowAndPersistsIt()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StaleDT: DateTime;
        FresherDT: DateTime;
    begin
        // [SCENARIO] A merchant edits a failing order in Medusa, so the refetched payload is fresher than the
        // row's stored timestamp and the order gets its retry budget back. The assertions re-read the row from
        // the database, because persisting the reset is the whole point of the procedure.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [GIVEN] A due Pending row with four of its ten retries spent, stamped 10:00 on 13 March 2024
        StaleDT := CreateDateTime(DMY2Date(13, 3, 2024), 100000T);
        FresherDT := StaleDT + (60 * 1000);
        SeedRearmRow('medusa-rearm', Enum::"NPR Entria Order Imp. Status"::Pending, StaleDT);

        // [WHEN] The re-arm runs with the fresher payload timestamp
        EntriaJQ.ReArmOnFresherPayload(_StoreCode, 'medusa-rearm', FresherDT);

        // [THEN] The stored row - not an in-memory copy - carries a fresh budget and the newer timestamp
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'The re-arm must reset the stored Retry Count to 0 - a write that never reached the database leaves the order spending retries it was just granted back.');
        _Assert.AreEqual(FresherDT, EntriaOrderImpFailure."Order Updated At",
            'The re-arm must store the fresher timestamp - left stale, every later payload looks fresher again, the budget resets on every cycle and the order never parks or reaches the Error tile.');

        // [THEN] The row is due for the retry pass again, which is the whole point of re-arming it
        _Assert.IsTrue(EntriaJQ.IsRetryDue(EntriaOrderImpFailure),
            'A re-armed row must be due for the retry pass - a re-arm that reset the budget but left the row ineligible would be a silent no-op.');
    end;

    [Test]
    procedure ReArmIsBlockedOnEveryNonPendingStatus()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StaleDT: DateTime;
        FresherDT: DateTime;
    begin
        // [SCENARIO] The re-arm is the one write that can hand an order back to the retry pass, so it must
        // refuse every row a human or a spent budget has taken out of it, and must not resurrect a row that is
        // already gone. The Pending control row is asserted alongside; otherwise a guard that rejected
        // everything would satisfy all the negatives. The Error row carries a synthetic budget of four so that
        // Status is the only eligibility condition that differs between the three rows.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [GIVEN] Three due rows at four spent retries and the same stale timestamp: Pending, Skipped, Error
        StaleDT := CreateDateTime(DMY2Date(13, 3, 2024), 100000T);
        FresherDT := StaleDT + (60 * 1000);
        SeedRearmRow('medusa-rearm-pending', Enum::"NPR Entria Order Imp. Status"::Pending, StaleDT);
        SeedRearmRow('medusa-rearm-skipped', Enum::"NPR Entria Order Imp. Status"::Skipped, StaleDT);
        SeedRearmRow('medusa-rearm-error', Enum::"NPR Entria Order Imp. Status"::Error, StaleDT);

        // [WHEN] The re-arm runs against each of them, and against an order that has no row at all
        EntriaJQ.ReArmOnFresherPayload(_StoreCode, 'medusa-rearm-pending', FresherDT);
        EntriaJQ.ReArmOnFresherPayload(_StoreCode, 'medusa-rearm-skipped', FresherDT);
        EntriaJQ.ReArmOnFresherPayload(_StoreCode, 'medusa-rearm-error', FresherDT);
        EntriaJQ.ReArmOnFresherPayload(_StoreCode, 'medusa-rearm-gone', FresherDT);

        // [THEN] The Pending control row was re-armed, so the negatives below cannot hold vacuously
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm-pending');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'The Pending control row must be re-armed here - otherwise the guard rejects every row and the assertions below prove nothing.');

        // [THEN] The Skipped row keeps its budget, its timestamp and its Status, and stays out of the pass
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm-skipped');
        _Assert.AreEqual(4, EntriaOrderImpFailure."Retry Count",
            'A Skipped row must keep its spent budget - re-arming it puts an order a human explicitly stopped back into the retry pass.');
        _Assert.AreEqual(StaleDT, EntriaOrderImpFailure."Order Updated At",
            'A Skipped row must keep its stored timestamp - moving it forward discards the baseline the order will be judged against when somebody releases it.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Skipped, EntriaOrderImpFailure.Status,
            'A Skipped row must still read as Skipped - a re-arm that lifted the Status to Pending would undo a human''s stop while leaving every other field innocent.');
        _Assert.IsFalse(EntriaJQ.IsRetryDue(EntriaOrderImpFailure),
            'A Skipped row must stay out of the retry pass after the re-arm was refused.');

        // [THEN] The Error row keeps its budget, its timestamp and its Status, and stays out of the pass
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm-error');
        _Assert.AreEqual(4, EntriaOrderImpFailure."Retry Count",
            'An Error row must keep its spent budget - re-arming it bypasses Retry Import and hands an exhausted order back to the automatic pass.');
        _Assert.AreEqual(StaleDT, EntriaOrderImpFailure."Order Updated At",
            'An Error row must keep its stored timestamp - moving it forward discards the baseline the order will be judged against when somebody releases it.');
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Error, EntriaOrderImpFailure.Status,
            'An Error row must still read as Error - a re-arm that lifted the Status to Pending would silently return an exhausted order to the retry pass.');
        _Assert.IsFalse(EntriaJQ.IsRetryDue(EntriaOrderImpFailure),
            'An Error row must stay out of the retry pass after the re-arm was refused.');

        // [THEN] The order with no row was not resurrected
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm-gone'),
            'The re-arm must not insert a row for an order whose registry entry is gone - a resurrected row would be retried forever for an order that already imported.');
    end;

    [Test]
    [HandlerFunctions('MockRefetchedSingleOrder')]
    procedure RetryPassReArmsRowOnFresherRefetchedPayload()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StaleDT: DateTime;
    begin
        // [SCENARIO] When the refetched payload is fresher than the row's stored timestamp, the retry pass
        // re-arms the row before logging whatever happens next. The refetch is mocked to succeed with a fresher
        // updated_at and no custom_display_id, so the pass re-arms the row (four spent retries down to none)
        // and then logs the missing-document failure on top of it, landing on one. Without the re-arm the same
        // run lands on five, and the stored timestamp must advance too - left stale it makes every later
        // payload look fresher, so the budget resets on every cycle and the order never parks.

        // [GIVEN] An enabled Entria store carrying an api key, with HttpClient requests allowed - without
        //         both, the refetch fails inside the request builder and never reaches the mock at all
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.SetHttpClientRequestsAllowed(true);
        _LibraryEntria.EnsureStoreAPIKey(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A due Pending row at four spent retries, stamped 10:00 on 13 March 2024
        StaleDT := CreateDateTime(DMY2Date(13, 3, 2024), 100000T);
        _MockOrderId := 'medusa-wiring';
        _MockOrderUpdatedAt := StaleDT + (60 * 1000);
        SeedRearmRow(_MockOrderId, Enum::"NPR Entria Order Imp. Status"::Pending, StaleDT);

        // [WHEN] The ID-based retry pass runs against the mocked refetch
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The row was re-armed before the new failure was logged on top of it
        EntriaOrderImpFailure.Get(_StoreCode, _MockOrderId);
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count",
            'The pass must re-arm the row before logging the new failure - a Retry Count of 5 means the row was not re-armed and the fresher payload was ignored.');

        // [THEN] The fresher timestamp was carried through to the row, not the stale one it started with
        _Assert.AreEqual(_MockOrderUpdatedAt, EntriaOrderImpFailure."Order Updated At",
            'The pass must store the timestamp it just fetched - forwarding the stale one instead leaves every later payload looking fresher, so the budget resets on every cycle and the order never parks.');

        // [THEN] The scenario issued exactly the one refetch it is supposed to
        _Assert.AreEqual(1, _MockRequestCount,
            'The scenario must issue exactly one outbound request - a second one means the mock answered something this test does not model.');
    end;

    [Test]
    [HandlerFunctions('MockRefetchedSingleOrder')]
    procedure RetryPassSpendsARetryWhenRefetchedPayloadIsUnchanged()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        StaleDT: DateTime;
    begin
        // [SCENARIO] The freshness gate in front of the re-arm. An order nobody touched in Medusa comes back
        // with the timestamp the row already holds, so the retry must be spent rather than handed back: a pass
        // that re-armed unconditionally would reset the budget on every cycle and the order would never park.

        // [GIVEN] An enabled Entria store carrying an api key, with HttpClient requests allowed
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.SetHttpClientRequestsAllowed(true);
        _LibraryEntria.EnsureStoreAPIKey(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A due Pending row at four spent retries, and a refetch that returns that same timestamp
        StaleDT := CreateDateTime(DMY2Date(13, 3, 2024), 100000T);
        _MockOrderId := 'medusa-unchanged';
        _MockOrderUpdatedAt := StaleDT;
        SeedRearmRow(_MockOrderId, Enum::"NPR Entria Order Imp. Status"::Pending, StaleDT);

        // [WHEN] The ID-based retry pass runs against the unchanged payload
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The retry was spent, not refunded
        EntriaOrderImpFailure.Get(_StoreCode, _MockOrderId);
        _Assert.AreEqual(5, EntriaOrderImpFailure."Retry Count",
            'An unchanged payload must spend the retry - a Retry Count back at 0 or 1 means the re-arm ran without the freshness check and the order can never reach its retry ceiling.');
    end;

    [HttpClientHandler]
    procedure MockRefetchedSingleOrder(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        EnvelopeObj: JsonObject;
        ResponseTxt: Text;
    begin
        // Fails closed: only the single-order refetch for the order under test is answered, so a request this
        // test does not model shows up as a 404 the caller reports rather than as a bogus success.
        _MockRequestCount += 1;
        if not Request.Path().Contains(_MockOrderId) then begin
            Response.HttpStatusCode := 404;
            Response.ReasonPhrase := 'Not Found';
            exit(false);
        end;

        // The order carries no custom_display_id, so the pass fails on the document number after the re-arm has
        // already run. BuildOrderArrayWithoutDisplayId stamps its CreatedAt argument onto updated_at as well,
        // which is the value the freshness check compares against.
        _LibraryEntria.BuildOrderArrayWithoutDisplayId(OrdersArr, _MockOrderId, _MockOrderUpdatedAt, 100);
        OrdersArr.Get(0, OrderTkn);
        EnvelopeObj.Add('order', OrderTkn.AsObject());
        EnvelopeObj.WriteTo(ResponseTxt);

        Response.Content.WriteFrom(ResponseTxt);
        Response.HttpStatusCode := 200;
        Response.ReasonPhrase := 'OK';
        exit(false);
    end;

    /// <summary>
    /// Seeds a registry row whose only varying condition is Status: four of the ten retries spent and a
    /// Next Retry At an hour in the past, so every row these tests seed is due on every other condition.
    /// </summary>
    local procedure SeedRearmRow(MedusaOrderId: Text[100]; Status: Enum "NPR Entria Order Imp. Status"; OrderUpdatedAt: DateTime)
    begin
        _LibraryEntria.InsertOrderFailureRowWithTimestamp(_StoreCode, MedusaOrderId, 4, CurrentDateTime() - (60 * 60 * 1000), Status, OrderUpdatedAt);
    end;

    [Test]
    procedure TwoOrdersSharingDisplayIdWithExistingHeader_SecondOrderSilentlySkippedToo()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        FirstOrdersArr: JsonArray;
        SecondOrdersArr: JsonArray;
        OrderTkn: JsonToken;
        FirstOrderObj: JsonObject;
        SecondOrderObj: JsonObject;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] Two distinct Medusa orders share the same custom_display_id, and that document no.
        // ALREADY has an Ecom Sales Header. GetExistingEcomDocsForBatch dedups by DOCUMENT NO., not by
        // Medusa order id, so BOTH orders fail ProcessListOrder's ExistingDocs check and ProcessOrder is
        // never reached for either - the second, genuinely different order is ALSO silently treated as
        // already imported. Pinned as the actual behaviour, not a per-order-id distinction the code makes.

        // [GIVEN] An enabled Entria store and two orders created at 10:00 on 6 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(6, 2, 2024), 100000T);

        // [GIVEN] An Ecom Sales Header already exists for the document no. both orders will claim
        _LibraryEntria.CreateEcomOrderHeader(_StoreCode, 'ZZ-DOC-DUPDISPID');

        // [GIVEN] A page holding two distinct Medusa orders that share that same custom_display_id
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(FirstOrdersArr, 'ZZ-DOC-DUPDISPID', 'medusa-dupdispid-a', OrderCreatedAt, OrderCreatedAt, 100);
        FirstOrdersArr.Get(0, OrderTkn);
        FirstOrderObj := OrderTkn.AsObject();

        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(SecondOrdersArr, 'ZZ-DOC-DUPDISPID', 'medusa-dupdispid-b', OrderCreatedAt, OrderCreatedAt, 100);
        SecondOrdersArr.Get(0, OrderTkn);
        SecondOrderObj := OrderTkn.AsObject();

        OrdersArr.Add(FirstOrderObj);
        OrdersArr.Add(SecondOrderObj);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.SeedSessionMax(_StoreCode);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The shared document no. still has exactly one Ecom Sales Header
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-DUPDISPID');
        _Assert.AreEqual(1, EcomSalesHeader.Count(), 'Exactly one Ecom Sales Header must exist for the shared document no. - the dedup by document no. must hold.');

        // [THEN] Neither order gets a registry row - both are silently treated as already imported
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-dupdispid-a'), 'The first order must not get a registry row - it is treated as already imported.');
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-dupdispid-b'),
            'The second, genuinely different Medusa order is ALSO silently skipped: the batch dedup keys on document no., not Medusa order id, so it too is treated as already imported and gets no registry row and no new document.');
    end;

    [Test]
    procedure ListPathRegistryLookupIsScopedToTheStore()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] Before importing a page, the job asks which of these orders have already failed - and it
        // must ask only about the store it is importing. If that filter were lost, a failure belonging to one
        // store would make a different store skip its own order: never imported, and not shown as failed either.

        // [GIVEN] An enabled Entria store and an order created at 10:00 on 12 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(12, 2, 2024), 100000T);

        // [GIVEN] A SECOND store already holds a registry row for that same Medusa order id
        _LibraryEntria.InsertOrderFailureRow(_SecondStoreCodeLbl, 'medusa-storescope', 0, CurrentDateTime() + 3600000);

        // [GIVEN] A seeded session max and a page holding that order, which cannot import - amount 100 with no payment lines
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-STORESCOPE', 'medusa-storescope', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs for the FIRST store
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] This store processed the order and registered its OWN failure
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-storescope'),
            'The order must be processed for this store: a registry row belonging to ANOTHER store must not hide it, or the order would never be imported and never be logged anywhere visible.');

        // [THEN] The other store's row is left exactly as it was
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_SecondStoreCodeLbl, 'medusa-storescope'), 'The other store''s registry row must still exist.');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'The other store''s registry row must stay untouched - each store owns its own retry state for its own copy of the order.');
    end;

    [Test]
    procedure ListPathExistingDocumentLookupIsScopedToTheStore()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] The job also asks which of these orders it has already imported, and that question must
        // likewise be limited to the store being imported. If that filter were lost, a document belonging to
        // one store would make a different store treat its own order as done and skip it.

        // [GIVEN] An enabled Entria store and an order created at 10:00 on 13 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(13, 2, 2024), 100000T);

        // [GIVEN] A SECOND store already has an Ecom Sales Header of type Order carrying that document no.
        _LibraryEntria.CreateEcomOrderHeader(_SecondStoreCodeLbl, 'ZZ-DOC-HDRSCOPE');

        // [GIVEN] A seeded session max and a page holding that order, which cannot import - amount 100 with no payment lines
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-HDRSCOPE', 'medusa-hdrscope', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs for the FIRST store
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The order was processed here and its failure registered
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-hdrscope'),
            'The order must be processed for this store: a document belonging to ANOTHER store that reuses the same External No. must not make it look already imported - it would be dropped with no document, no registry row and nothing to see it by.');
    end;

    [Test]
    procedure ListPathExistingDocumentLookupIsScopedToDocumentTypeOrder()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] When the job asks whether an order was already imported, only sales orders answer. A
        // return document that happens to carry the same external order no. must not make the order itself
        // look imported and get skipped.

        // [GIVEN] An enabled Entria store and an order created at 10:00 on 14 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(14, 2, 2024), 100000T);

        // [GIVEN] This store already has a RETURN ORDER carrying that same External No.
        _LibraryEntria.CreateEcomDocumentHeader(_StoreCode, 'ZZ-DOC-TYPESCOPE', EcomSalesHeader."Document Type"::"Return Order");

        // [GIVEN] A seeded session max and a page holding that order, which cannot import - amount 100 with no payment lines
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-TYPESCOPE', 'medusa-typescope', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The order was processed and its failure registered
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-typescope'),
            'The order must be processed: a return of the same External No. is a different document type and must not suppress the order import.');
    end;

    [Test]
    procedure PagingCursorMovesTheWindowForwardAndOnlyWalksTheOrdinalOnATie()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        WindowStartDT: DateTime;
        ConsumedMaxDT: DateTime;
        Offset: Integer;
    begin
        // [SCENARIO] The decision the import makes after each page: how far the window moves, and where the
        // ordinal offset goes with it. An offset only means something against an unchanged filter, so it
        // must reset the moment the window moves, and it may only keep counting while the window stands
        // still. Getting either half wrong loses orders silently: an offset that survives a window move
        // lands past rows nobody read, and one that resets on a page of identical timestamps re-serves the
        // same rows forever.

        // [WHEN] A page brought orders newer than the window, from a non-zero offset
        WindowStartDT := CreateDateTime(DMY2Date(3, 3, 2024), 100000T);
        ConsumedMaxDT := CreateDateTime(DMY2Date(4, 3, 2024), 100000T);
        Offset := 80;
        EntriaJQ.AdvancePagingCursor(ConsumedMaxDT, 40, WindowStartDT, Offset);

        // [THEN] The window moves up to what was consumed and the offset starts over
        _Assert.AreEqual(ConsumedMaxDT, WindowStartDT, 'The window must move up to the highest timestamp consumed so far.');
        _Assert.AreEqual(0, Offset,
            'The offset must reset when the window moves - carried across a window change it counts against a result set of a different shape and lands past rows that were never read.');

        // [WHEN] The next page brings nothing above the window - every row shares the window's own timestamp
        WindowStartDT := CreateDateTime(DMY2Date(4, 3, 2024), 100000T);
        ConsumedMaxDT := WindowStartDT;
        Offset := 0;
        EntriaJQ.AdvancePagingCursor(ConsumedMaxDT, 40, WindowStartDT, Offset);

        // [THEN] The window stands still and the ordinal walks through the tied block instead
        _Assert.AreEqual(CreateDateTime(DMY2Date(4, 3, 2024), 100000T), WindowStartDT,
            'On equality the window must stand still: rewriting it with its own value and resetting the offset would serve the same tied rows forever.');
        _Assert.AreEqual(40, Offset, 'With the window unable to move, the ordinal is what walks through a block of rows sharing one timestamp.');

        // [WHEN] A page somehow reports a maximum BELOW the window - clock skew, or a stale running maximum
        WindowStartDT := CreateDateTime(DMY2Date(4, 3, 2024), 100000T);
        ConsumedMaxDT := CreateDateTime(DMY2Date(3, 3, 2024), 100000T);
        Offset := 40;
        EntriaJQ.AdvancePagingCursor(ConsumedMaxDT, 40, WindowStartDT, Offset);

        // [THEN] The window is never dragged backwards
        _Assert.AreEqual(CreateDateTime(DMY2Date(4, 3, 2024), 100000T), WindowStartDT,
            'The window must never move backwards - a window that retreats re-serves orders already imported and can stop the pass from ever finishing.');
        _Assert.AreEqual(80, Offset, 'A page that adds nothing above the window advances the ordinal, exactly as the tied case does.');
    end;

    [Test]
    procedure ListPathRegistryLookupSpansEveryFilterChunk()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        GeneratedOrderIds: List of [Text];
        GeneratedDocumentNos: List of [Code[20]];
        Index: Integer;
        OrderCount: Integer;
        OrderIdLength: Integer;
        NextRetryAtBefore: DateTime;
        OrderCreatedAt: DateTime;
        FirstOrderId: Text[100];
        SeededOrderId: Text[100];
    begin
        // [SCENARIO] A page can hold more orders than one database query can ask about at once, so the check
        // for known failures runs in several passes. Every order already recorded as failed must be
        // recognised in all of them - missed in a later pass, it is retried out of turn and burns its budget.

        // [GIVEN] An enabled Entria store and enough orders created at 10:00 on 15 February 2024, with ids
        //         at the Text[100] bound, that the ids cannot fit one filter chunk. The count is DERIVED
        //         from the cap rather than hardcoded: widening the cap would otherwise collapse this page
        //         into a single chunk and the test would keep passing while proving nothing about later ones.
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(15, 2, 2024), 100000T);
        OrderIdLength := 100;
        OrderCount := (EntriaJQ.MaxFilterLength() div (OrderIdLength + 1)) + 2;
        _Assert.IsTrue((OrderCount * OrderIdLength) + (OrderCount - 1) > EntriaJQ.MaxFilterLength(),
            'Setup: the ids of this page must not fit a single filter chunk, or every assertion below about later chunks proves nothing.');
        _LibraryEntria.BuildOrderPageWithManyOrders(OrdersArr, OrderCount, OrderIdLength, 0, OrderCreatedAt, 100, GeneratedOrderIds, GeneratedDocumentNos);
        FirstOrderId := CopyStr(GeneratedOrderIds.Get(1), 1, MaxStrLen(FirstOrderId));

        // [GIVEN] A registry row for EVERY order of the page except the first - whichever chunk each id ends
        //         up in, it is covered - holding its full retry budget and a retry an hour away
        NextRetryAtBefore := CurrentDateTime() + 3600000;
        for Index := 2 to GeneratedOrderIds.Count() do
            _LibraryEntria.InsertOrderFailureRow(_StoreCode, CopyStr(GeneratedOrderIds.Get(Index), 1, MaxStrLen(SeededOrderId)), 0, NextRetryAtBefore);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.SeedSessionMax(_StoreCode);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The page really was worked through - the first order, which has no registry row, could not import and got one
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, FirstOrderId),
            'The only order of the page without a registry row must have been processed and registered its failure - otherwise nothing at all happened and the chunk assertions below would prove nothing.');

        // [THEN] Every pre-seeded row is untouched, so no filter chunk was dropped
        for Index := 2 to GeneratedOrderIds.Count() do begin
            SeededOrderId := CopyStr(GeneratedOrderIds.Get(Index), 1, MaxStrLen(SeededOrderId));
            _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, SeededOrderId), StrSubstNo('The pre-seeded registry row of order %1 must still exist.', SeededOrderId));
            _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
                StrSubstNo('The registry row of order %1 must be untouched: a lookup that skips a filter chunk re-processes and re-logs the orders in it on EVERY pass, burning the whole backoff schedule.', SeededOrderId));
            _Assert.AreEqual(NextRetryAtBefore, EntriaOrderImpFailure."Next Retry At",
                StrSubstNo('The retry of order %1 must not be rescheduled either - re-logging rewrites Next Retry At from the current time and pushes the retry away on every cycle.', SeededOrderId));
        end;
    end;

    [Test]
    procedure ListPathExistingDocumentLookupSpansEveryFilterChunk()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        GeneratedOrderIds: List of [Text];
        GeneratedDocumentNos: List of [Code[20]];
        DocumentNo: Code[20];
        MarkerBefore: DateTime;
        OrderCreatedAt: DateTime;
        OrderCount: Integer;
        DocumentNoLength: Integer;
        LastOrderId: Text[100];
    begin
        // [SCENARIO] The same applies to the "already imported" check: on a page too large for one database
        // query, a document must be recognised as imported even when it falls in the last pass - missed, the
        // order is imported a second time.

        // [GIVEN] An enabled Entria store whose marker stands a day before the orders' bc_status_updated_at
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        MarkerBefore := CreateDateTime(DMY2Date(15, 2, 2024), 100000T);
        OrderCreatedAt := CreateDateTime(DMY2Date(16, 2, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, MarkerBefore);

        // [GIVEN] Enough orders, with document nos. at the Code[20] bound, that the document nos. cannot fit
        //         one filter chunk - the count derived from the cap, so widening the cap cannot quietly turn
        //         this back into a single-chunk page that still passes
        DocumentNoLength := 20;
        OrderCount := (EntriaJQ.MaxFilterLength() div (DocumentNoLength + 1)) + 2;
        _Assert.IsTrue((OrderCount * DocumentNoLength) + (OrderCount - 1) > EntriaJQ.MaxFilterLength(),
            'Setup: the document nos. of this page must not fit a single filter chunk, or the later-chunk assertions prove nothing.');
        _LibraryEntria.BuildOrderPageWithManyOrders(OrdersArr, OrderCount, 20, DocumentNoLength, OrderCreatedAt, 100, GeneratedOrderIds, GeneratedDocumentNos);
        LastOrderId := CopyStr(GeneratedOrderIds.Get(GeneratedOrderIds.Count()), 1, MaxStrLen(LastOrderId));

        // [GIVEN] Every one of those document nos. already has an Ecom Sales Header of type Order, so the whole page is a duplicate
        foreach DocumentNo in GeneratedDocumentNos do
            _LibraryEntria.CreateEcomOrderHeader(_StoreCode, DocumentNo);

        // [GIVEN] A session max seeded from the stored marker
        EntriaJQ.SeedSessionMax(_StoreCode);
        _Assert.AreEqual(EntriaJQ.PassWindowStart(MarkerBefore), EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'Setup: the session max must start at the window the pass opens with - the stored marker less the propagation overlap.');

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The page really was parsed - the session max advanced to the orders' bc_status_updated_at.
        //        The marker is advanced before the duplicate and failed-id checks, so this only rules out the
        //        page never being processed at all; the chunk-lookup evidence is the assertions below.
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'The session max must have advanced, which is what proves the page was parsed at all rather than never being processed.');

        // [THEN] The last order, whose document no. only appears in the final chunk, got no registry row
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, LastOrderId),
            'The last order must be recognised as already imported: a lookup that stops after the first filter chunk re-processes a genuine duplicate and logs a failure for it.');

        // [THEN] And neither did any other order of the page
        EntriaOrderImpFailure.Reset();
        EntriaOrderImpFailure.SetRange("Store Code", _StoreCode);
        _Assert.AreEqual(0, EntriaOrderImpFailure.Count(), 'No order of an all-duplicate page may be processed, so the failure registry must stay empty for the store.');
    end;

    [Test]
    procedure SingleOrderRequestSharesProjectionWithListRequest()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        ListRequestText: Text;
        SingleRequestText: Text;
        ProjectionText: Text;
        FieldsPos: Integer;
    begin
        // [SCENARIO] GenerateGetSingleOrderRequest must use the exact same field projection as
        // GenerateGetOrderListRequest (both delegate to GetOrderFieldsProjection), so the two
        // request builders cannot drift apart. The projection is extracted from the list request's
        // own output rather than hardcoded here, so a change to the shared projection cannot
        // silently desync the two.

        // [GIVEN] The field projection taken from the list request's own output
        ListRequestText := EntriaJQ.GenerateGetOrderListRequest(0, 40, 0DT);
        FieldsPos := ListRequestText.IndexOf('fields=');
        _Assert.IsTrue(FieldsPos > 0, 'The list request must contain a fields= projection.');
        ProjectionText := CopyStr(ListRequestText, FieldsPos);

        // [WHEN] The single-order request is generated for one Medusa order id
        SingleRequestText := EntriaJQ.GenerateGetSingleOrderRequest('medusa-single-1');

        // [THEN] It targets admin/orders/<id>? and carries the exact same field projection as the list request
        _Assert.IsTrue(SingleRequestText.StartsWith('admin/orders/medusa-single-1?'), 'The single-order request must target admin/orders/<id>?.');
        _Assert.IsTrue(SingleRequestText.Contains(ProjectionText), 'The single-order request must carry the exact same field projection as the list request.');
    end;

    [Test]
    procedure ImportedLineTakesQuantityUnitPriceAndTotalFromTheirOwnProperties()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Item: Record Item;
        ItemObj: JsonObject;
        NoTaxRates: List of [Decimal];
    begin
        // [SCENARIO] A multi-quantity line maps quantity, unit_price and total each to their own field.

        // [GIVEN] An enabled Entria store and an item whose own Unit Price is 999, so a line priced from the item card instead of the payload is visible
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 999, false);

        // [GIVEN] One line with quantity 2, unit_price 40 and total 90 - three different values, and a total that is not quantity * unit_price either
        _LibraryEntria.BuildItemLineJson(ItemObj, 'Entria multi-quantity line', Item."No.", 2, 40, 90, 0, 90, NoTaxRates);

        // [WHEN] The order is imported
        ImportSingleLineOrder('ZZ-DOC-QTY2', 'medusa-qty2', '', ItemObj, 90, CreateDateTime(DMY2Date(3, 7, 2024), 100000T));

        // [THEN] The line's description comes from the payload's title
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-QTY2');
        FindSingleEcomSalesLine(EcomSalesLine, EcomSalesHeader."Entry No.");
        _Assert.AreEqual('Entria multi-quantity line', EcomSalesLine.Description,
            'The line description must come from the payload title - a document whose lines are described by something else is unrecognisable to whoever handles the order.');

        // [THEN] Quantity, Unit Price and Line Amount each come from their own JSON property
        _Assert.AreEqual(2, EcomSalesLine.Quantity, 'Quantity must come from quantity - a quantity forced to 1 ships one of everything the customer ordered several of.');
        _Assert.AreEqual(40, EcomSalesLine."Unit Price",
            'Unit Price must come from unit_price - reading total there prices every unit of a multi-quantity line at the whole line''s amount.');
        _Assert.AreEqual(90, EcomSalesLine."Line Amount",
            'Line Amount must come from total - reading unit_price there understates every multi-quantity document and, because Amount is a FlowField over Line Amount, silently changes the payment guard too.');

        // [THEN] The line is typed as an item routed to the item the payload named
        _Assert.AreEqual(EcomSalesLine.Type::Item, EcomSalesLine.Type, 'A physical, non-giftcard line must be typed as an Item - any other type sends it down a virtual-item path it has no data for.');
        _Assert.AreEqual(EcomSalesLine.Subtype::Item, EcomSalesLine.Subtype, 'A plain stock item must get the Item subtype - a virtual subtype makes the document wait for tickets, memberships or coupons that never come.');
        _Assert.AreEqual(Item."No.", EcomSalesLine."No.",
            'The line must be routed to the item metadata.external_id names - without it the document cannot be turned into a sales order at all.');

        // [THEN] The header Amount FlowField the payment guard reads sums the line totals
        EcomSalesHeader.CalcFields(Amount);
        _Assert.AreEqual(90, EcomSalesHeader.Amount,
            'The header Amount must sum the lines'' totals - it is what HasNonZeroAmount reads, so a wrong Line Amount decides whether missing payments are an error or a silent pass.');
    end;

    [Test]
    procedure SingleTaxLineSetsVatPercentFromItsRateVerbatim()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Item: Record Item;
        ItemObj: JsonObject;
        TaxRates: List of [Decimal];
    begin
        // [SCENARIO] A line with exactly one tax_lines entry takes its VAT % straight from that entry's rate.

        // [GIVEN] An enabled Entria store and an item
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);

        // [GIVEN] One tax line at 25%, on a line whose tax_total 50 over subtotal 1000 would give 5% instead
        TaxRates.Add(25);
        _LibraryEntria.BuildItemLineJson(ItemObj, 'Entria single tax line', Item."No.", 2, 100, 250, 50, 1000, TaxRates);

        // [WHEN] The order is imported
        ImportSingleLineOrder('ZZ-DOC-VAT1', 'medusa-vat1', '', ItemObj, 250, CreateDateTime(DMY2Date(4, 7, 2024), 100000T));

        // [THEN] The line's VAT % is the single tax line's own rate, not a rate derived from tax_total and subtotal
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-VAT1');
        FindSingleEcomSalesLine(EcomSalesLine, EcomSalesHeader."Entry No.");
        _Assert.AreEqual(25, EcomSalesLine."VAT %",
            'A single tax line''s rate must be taken verbatim: deriving it from tax_total over subtotal would give 5% here and post the whole line at the wrong VAT.');
    end;

    [Test]
    procedure NonZeroItemTaxTotalWithoutTaxLinesFailsTheImport()
    var
        Item: Record Item;
        ItemObj: JsonObject;
        NoTaxRates: List of [Decimal];
    begin
        // [SCENARIO] A line carrying a non-zero tax_total but no tax_lines at all cannot have its VAT rate
        // determined, so the import must fail instead of importing the line VAT-free.

        // [GIVEN] An enabled Entria store and an item
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);

        // [GIVEN] A line with tax_total 25 and no tax_lines property at all
        _LibraryEntria.BuildItemLineJson(ItemObj, 'Entria tax total without tax lines', Item."No.", 1, 100, 125, 25, 100, NoTaxRates);

        // [WHEN] The order is imported
        asserterror ImportSingleLineOrder('ZZ-DOC-NOTAXL', 'medusa-notaxl', '', ItemObj, 125, CreateDateTime(DMY2Date(6, 7, 2024), 100000T));

        // [THEN] The import fails on the missing tax lines rather than silently importing a taxed line at VAT % 0
        _Assert.ExpectedError('but no tax_lines were provided in the payload');
    end;

    [Test]
    procedure PayloadCurrencyEqualToLcyCodeLeavesHeaderCurrencyBlank()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Item: Record Item;
        ItemObj: JsonObject;
        NoTaxRates: List of [Decimal];
        LcyCode: Code[10];
    begin
        // [SCENARIO] A payload currency_code that IS the local currency must leave the header's
        // Currency Code blank - blank is how the rest of BC recognises an LCY document.

        // [GIVEN] An enabled Entria store, an item and the local currency code the importer compares against
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);
        LcyCode := _LibraryEntria.EnsureLcyCode();

        // [GIVEN] An order sent in that very currency
        _LibraryEntria.BuildItemLineJson(ItemObj, 'Entria LCY line', Item."No.", 1, 100, 100, 0, 100, NoTaxRates);

        // [WHEN] The order is imported
        ImportSingleLineOrder('ZZ-DOC-LCY', 'medusa-lcy', LcyCode, ItemObj, 100, CreateDateTime(DMY2Date(7, 7, 2024), 100000T));

        // [THEN] The header carries no currency code at all
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-LCY');
        _Assert.AreEqual('', EcomSalesHeader."Currency Code",
            'An order sent in the local currency must leave Currency Code blank - stamping the LCY code on it makes the document a foreign-currency one that BC then converts and revalues.');
    end;

    [Test]
    procedure VoucherPaymentIsReservedInsteadOfTreatedAsACardPayment()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherSalesLine: Record "NPR NpRv Sales Line";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        VoucherReferenceNo: Text[50];
    begin
        // [SCENARIO] A payment whose data carries voucher_code is a voucher payment: it is classified as
        // Voucher, keeps the code as its Payment Reference and reserves the voucher it pays with.

        // [GIVEN] An enabled Entria store and an issued voucher of 100 with a known reference no.
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(9, 7, 2024), 100000T);
        VoucherReferenceNo := 'ZZENTVCH01';
        _LibraryEntria.EnsureIssuedVoucher(VoucherReferenceNo, 100, Voucher);

        // [GIVEN] An order of 100 paid with that voucher code by provider pp_voucher
        _LibraryEntria.BuildOrderArrayWithVoucherPayment(OrdersArr, 'ZZ-DOC-VCH', 'medusa-vch', OrderCreatedAt, OrderCreatedAt, 100, 100, 'pp_voucher', VoucherReferenceNo);

        // [WHEN] The order is imported
        ImportPrebuiltOrder('ZZ-DOC-VCH', OrdersArr);

        // [THEN] The one payment line is a voucher payment carrying the voucher code, not a card payment
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-VCH');
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.AreEqual(1, EcomSalesPmtLine.Count(), 'One payment must produce exactly one payment line - any extra line would make the amount assertions ambiguous.');
        EcomSalesPmtLine.FindFirst();
        _Assert.AreEqual(EcomSalesPmtLine."Payment Method Type"::Voucher, EcomSalesPmtLine."Payment Method Type",
            'voucher_code must be read before pspReference: classifying a voucher as a card payment skips the reservation, so the same voucher can still be spent elsewhere.');
        _Assert.AreEqual(VoucherReferenceNo, EcomSalesPmtLine."Payment Reference", 'The voucher code must reach Payment Reference - it is what the voucher is looked up by.');
        _Assert.AreEqual('pp_voucher ' + VoucherReferenceNo, EcomSalesPmtLine.Description, 'A voucher line''s description must carry the voucher code after the provider, so the paying voucher is identifiable on the document.');
        _Assert.AreEqual(100, EcomSalesPmtLine.Amount, 'The payment line must carry the payment''s amount.');

        // [THEN] The voucher is reserved for this document for the amount it pays
        VoucherSalesLine.SetRange("Document Source", VoucherSalesLine."Document Source"::"Sales Document");
        VoucherSalesLine.SetRange("External Document No.", 'ZZ-DOC-VCH');
        VoucherSalesLine.SetRange(Type, VoucherSalesLine.Type::Payment);
        _Assert.AreEqual(1, VoucherSalesLine.Count(), 'The imported voucher payment must reserve the voucher exactly once - without a reservation the voucher stays spendable and can be used twice.');
        VoucherSalesLine.FindFirst();
        _Assert.AreEqual(Voucher."No.", VoucherSalesLine."Voucher No.", 'The reservation must point at the voucher the code resolves to, otherwise a different voucher is consumed.');
        _Assert.AreEqual(100, VoucherSalesLine.Amount, 'The reservation must hold the amount the voucher pays on this order.');
        _Assert.IsTrue(VoucherSalesLine."NPR Inc Ecom Sales Pmt Line Id" = EcomSalesPmtLine.SystemId,
            'The reservation must link back to its payment line - without the link the reservation cannot be released when the payment line goes away.');
    end;

    [Test]
    procedure ZeroPaymentCollectionsWithNonZeroAmountFailsImport()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrdersArr: JsonArray;
    begin
        // [SCENARIO] "payment_collections" is present as an EMPTY array, so the loop over the
        // collections never runs. Only the check after the loop can catch it, and it must.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [GIVEN] An order payload with an amount of 100 whose payment_collections is an empty array
        _LibraryEntria.BuildOrderArrayWithZeroPaymentCollections(OrdersArr, 'ZZ-DOC-ZEROPC', 'medusa-zeropc', CreateDateTime(DMY2Date(9, 7, 2024), 110000T), CreateDateTime(DMY2Date(9, 7, 2024), 110000T), 100);

        // [WHEN] The order is imported
        asserterror ImportPrebuiltOrder('ZZ-DOC-ZEROPC', OrdersArr);

        // [THEN] The import fails on the missing payment information rather than importing a paid order unpaid
        _Assert.ExpectedError('payment information is not available yet');

        // [THEN] No Ecom Sales Header is left behind - the insert was rolled back
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-ZEROPC');
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'No Ecom Sales Header may survive a failed import - a surviving one would be invoiced with no payment at all.');
    end;

    [Test]
    procedure TwoPaymentsInOneCollectionBecomeTwoPaymentLines()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        FirstLineNo: Integer;
    begin
        // [SCENARIO] One collection carrying two payments must produce two payment lines on their own
        // line numbers - a shared line number would make the second payment overwrite or reject the first.

        // [GIVEN] An enabled Entria store and an order of 100 created at 13:00 on 9 July 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(9, 7, 2024), 130000T);

        // [GIVEN] The single collection carries a payment of 60 and a payment of 40
        _LibraryEntria.BuildOrderArrayWithTwoPaymentsInOneCollection(OrdersArr, 'ZZ-DOC-2PAY', 'medusa-2pay', OrderCreatedAt, OrderCreatedAt, 100, 60, 'PSP-SPLIT-1', 40, 'PSP-SPLIT-2');

        // [WHEN] The order is imported
        ImportPrebuiltOrder('ZZ-DOC-2PAY', OrdersArr);

        // [THEN] Both payments survive as their own lines, each with its own amount and reference
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-2PAY');
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.AreEqual(2, EcomSalesPmtLine.Count(), 'Two payments must produce two payment lines - losing one leaves the order looking part-paid.');
        EcomSalesPmtLine.FindSet();
        FirstLineNo := EcomSalesPmtLine."Line No.";
        _Assert.AreEqual(60, EcomSalesPmtLine.Amount, 'The first payment line must carry the first payment''s amount.');
        _Assert.AreEqual('PSP-SPLIT-1', EcomSalesPmtLine."Payment Reference", 'The first payment line must carry the first payment''s pspReference.');
        EcomSalesPmtLine.Next();
        _Assert.AreEqual(40, EcomSalesPmtLine.Amount, 'The second payment line must carry the second payment''s amount.');
        _Assert.AreEqual('PSP-SPLIT-2', EcomSalesPmtLine."Payment Reference", 'The second payment line must carry the second payment''s pspReference.');

        // [THEN] The second line sits on a higher line number than the first
        _Assert.IsTrue(EcomSalesPmtLine."Line No." > FirstLineNo,
            'Each payment must get its own ascending line number - reusing one makes the second payment collide with the first on the document''s primary key.');
    end;

    [Test]
    procedure ImportedHeaderCarriesEntriaDocumentSourceAndPayloadIdentity()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] InsertEcomSalesHeader stamps the imported header with the identity everything
        // downstream needs: "Document Source" is what the ecom processing keys on to recognise the
        // document as Entria's at all, and the payload's Medusa id and display_id are what tie it back
        // to the order in the Entria admin.

        // [GIVEN] An enabled Entria store and a paid order of 100 created at 09:00 on 12 July 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(12, 7, 2024), 090000T);
        _LibraryEntria.BuildOrderArrayWithPayments(OrdersArr, 'ZZ-DOC-DOCSRC', 'medusa-docsrc', OrderCreatedAt, OrderCreatedAt, 100, 100, 'PSP-DOCSRC');

        // [WHEN] The order is imported
        ImportPrebuiltOrder('ZZ-DOC-DOCSRC', OrdersArr);

        // [THEN] The header is stamped as an Entria document
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-DOCSRC');
        _Assert.AreEqual(EcomSalesHeader."Document Source"::Entria, EcomSalesHeader."Document Source",
            'The header must be stamped with the Entria document source - the ecom processing selects documents by it, so a header carrying another source is picked up by the wrong integration or by none at all.');

        // [THEN] It carries the payload's Medusa order id
        _Assert.AreEqual('medusa-docsrc', EcomSalesHeader."External Document Id",
            'The header must carry the payload''s Medusa order id - it is the only handle back to the order in Entria when the document has to be reconciled.');

        // [THEN] It carries the payload's display_id as the customer-facing reference
        _Assert.AreEqual('360', EcomSalesHeader."Your Reference",
            'The header must carry the payload''s display_id as Your Reference - it is the order number the merchant sees in the Entria admin and the customer quotes.');
    end;

    [Test]
    procedure DeletingStoreDeletesItsSyncStateMarker()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        StoreCode: Code[20];
    begin
        // [SCENARIO] "NPR Entria Store".OnDelete calls EntriaIntegrationMgt.DeleteRelatedRecords, which
        // must remove this store's sync state row as well as its registry rows.

        // [GIVEN] An Entria store whose sync marker stands at 10:00 on 3 July 2024
        Initialize();
        StoreCode := 'ZZ-ENT-DELSYNC';
        _LibraryEntria.CreateEntriaStoreWithUrl(EntriaStore, StoreCode);
        EntriaStore.SetLastOrdersImportedAt(StoreCode, CreateDateTime(DMY2Date(3, 7, 2024), 100000T));
        _Assert.IsTrue(EntriaStoreSyncState.Get(StoreCode), 'Setup: the sync state row must exist before the store is deleted.');

        // [WHEN] The store is deleted, so OnDelete runs DeleteRelatedRecords
        _LibraryEntria.DeleteStore(StoreCode);

        // [THEN] The store's sync state row is gone too
        _Assert.IsFalse(EntriaStoreSyncState.Get(StoreCode),
            'Deleting the store must delete its sync state row - a marker outliving its store makes a store recreated under the same code resume from the old marker and never import the order history before it.');
    end;

    [Test]
    procedure SessionMaxTakesThePageMaximumNotItsLastOrder()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        EarlierCreatedAt: DateTime;
        LaterCreatedAt: DateTime;
    begin
        // [SCENARIO] UpdateSessionMaxBcStatusUpdatedAt keeps the MAXIMUM bc_status_updated_at of the
        // page, never the last one it happened to read. The list is requested in ascending order, but
        // the marker must not depend on that ordering holding: taking the last order instead would
        // rewind the marker whenever a page ends on an earlier order, and the store would then re-list
        // the same window every cycle.

        // [GIVEN] An enabled Entria store and two orders created a day apart
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        EarlierCreatedAt := CreateDateTime(DMY2Date(17, 7, 2024), 100000T);
        LaterCreatedAt := CreateDateTime(DMY2Date(18, 7, 2024), 100000T);

        // [GIVEN] A seeded session max and one page carrying the LATER order first and the earlier one second
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildTwoOrderPage(OrdersArr, 'ZZ-DOC-PAGEMAX1', 'medusa-pagemax-1', LaterCreatedAt, 'ZZ-DOC-PAGEMAX2', 'medusa-pagemax-2', EarlierCreatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max stands at the later order, not at the last one read
        _Assert.AreEqual(LaterCreatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCode),
            'The session max must end up at the page''s highest bc_status_updated_at - keeping the last order read instead moves the marker back a day and the store re-lists and re-skips that window on every cycle.');
    end;

    [Test]
    procedure SubSecondMarkerReadBackIsNotTreatedAsARewind()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        MarkerDT: DateTime;
        ExpectedMarkerDT: DateTime;
        FlushAfterSubSecondGapProceeded: Boolean;
        FlushAfterTwoSecondGapProceeded: Boolean;
    begin
        // [SCENARIO] TryFlushMarker's one-second tolerance, on both sides of the threshold: SQL's 1/300s datetime
        // grid can hand a marker back a few milliseconds below what was written, and counting that as an
        // administrator's rewind would abandon pagination after every page - while a gap of more than a
        // second is a real external edit and must stop paging.

        // [GIVEN] An enabled Entria store whose stored marker stands at 10:00:00 on 4 July 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        MarkerDT := CreateDateTime(DMY2Date(4, 7, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, MarkerDT);
        EntriaJQ.SeedSessionMax(_StoreCode);

        // [WHEN] The pass flushes while its own snapshot stands 400 milliseconds above the stored marker
        ExpectedMarkerDT := MarkerDT + 400;
        FlushAfterSubSecondGapProceeded := EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [THEN] The flush proceeds and hands the pass the value actually stored, so pagination continues
        _Assert.IsTrue(FlushAfterSubSecondGapProceeded,
            'A sub-second gap is the datetime grid''s rounding, not a rewind - reporting it as one stops pagination after the very first page and the store never reads past its first 40 orders.');
        _Assert.AreEqual(MarkerDT, ExpectedMarkerDT, 'The flush must hand the pass back the marker that is really in the database.');
        _Assert.AreEqual(MarkerDT, EntriaJQ.GetSyncStateMarker(_StoreCode), 'A session max no higher than the stored marker must leave the stored marker standing.');

        // [WHEN] The pass flushes again while its snapshot stands two seconds above the stored marker
        ExpectedMarkerDT := MarkerDT + 2000;
        FlushAfterTwoSecondGapProceeded := EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [THEN] That gap counts as a rewind, so paging stops
        _Assert.IsFalse(FlushAfterTwoSecondGapProceeded,
            'A two-second gap is an administrator''s re-sync point - a tolerance wide enough to swallow it lets the pass overwrite the re-sync and the orders it was meant to re-import are never fetched.');

        // [THEN] The stored marker survives untouched as the next pass's window start
        _Assert.AreEqual(MarkerDT, EntriaJQ.GetSyncStateMarker(_StoreCode), 'A flush that reports a rewind must leave the stored marker exactly as it found it.');
    end;

    [Test]
    procedure SamePageDuplicateOrderProducesOneDocumentOnly()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] The set of already-imported documents is read once, before the page loop, so two
        // array entries carrying the same document no. inside ONE page both reach ImportOrder and only
        // its own in-transaction lookup stops the second one.

        // [GIVEN] An enabled Entria store with no document imported for 'ZZ-DOC-SAMEPAGE' yet
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(22, 7, 2024), 100000T);

        // [GIVEN] A seeded session max and one page carrying that very same zero-amount order twice
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildTwoOrderPage(OrdersArr, 'ZZ-DOC-SAMEPAGE', 'medusa-samepage', OrderCreatedAt, 'ZZ-DOC-SAMEPAGE', 'medusa-samepage', OrderCreatedAt, 0);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The order is imported exactly once
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetRange("External No.", 'ZZ-DOC-SAMEPAGE');
        _Assert.AreEqual(1, EcomSalesHeader.Count(),
            'An order repeated inside one page must produce a single Ecom Sales Header - a second one for the same Entria order is a document the customer is shipped and invoiced twice.');
    end;

    [Test]
    procedure SentryThrottleForListFetchIsPerStore()
    var
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        BaseDT: DateTime;
        FirstStoreFirstErrorEmits: Boolean;
        SecondStoreFirstErrorEmits: Boolean;
        FirstStoreSecondErrorEmits: Boolean;
    begin
        // [SCENARIO] The hourly list-fetch dedup is keyed per store. A key that stopped carrying the
        // store code would let the store that failed first swallow every other store's alert for the
        // rest of the hour.

        // [GIVEN] A base timestamp of 08:00 on 1 January 2024
        BaseDT := CreateDateTime(DMY2Date(1, 1, 2024), 080000T);

        // [WHEN] Store 'ZZTHR-A' reports a list-fetch failure, then store 'ZZTHR-B', then 'ZZTHR-A' again a minute later
        FirstStoreFirstErrorEmits := EntriaJQ.ShouldEmitSentryError('ZZTHR-A', BaseDT);
        SecondStoreFirstErrorEmits := EntriaJQ.ShouldEmitSentryError('ZZTHR-B', BaseDT);
        FirstStoreSecondErrorEmits := EntriaJQ.ShouldEmitSentryError('ZZTHR-A', BaseDT + (60 * 1000));

        // [THEN] Both stores' first failure emits - the second store is not silenced by the first
        _Assert.IsTrue(FirstStoreFirstErrorEmits, 'The first store''s first list-fetch failure must emit.');
        _Assert.IsTrue(SecondStoreFirstErrorEmits,
            'A second store''s first list-fetch failure must emit too - a store-independent key hides an Entria outage on every store except the one that happened to fail first.');

        // [THEN] The hourly throttle is still in force for the store that already emitted
        _Assert.IsFalse(FirstStoreSecondErrorEmits,
            'The first store''s second failure within the hour must still be deduped - without that the per-store assertion above would pass even with no throttle at all.');
    end;

    [Test]
    procedure EntriaUrlIsNormalisedBeforeItIsAccepted()
    var
        NormalizedUrl: Text;
    begin
        // [SCENARIO] ValidateEntriaUrl normalises what an administrator types into the one shape every
        // Entria request is concatenated onto: it assumes https:// when no scheme is given, drops the
        // /admin suffix a merchant copies out of the Entria admin address bar and drops a trailing
        // slash. What is still no URL after that is refused rather than stored.

        // [WHEN] A url carrying no scheme is validated
        NormalizedUrl := NormalizeEntriaUrl('entria.example.com');

        // [THEN] https:// is assumed
        _Assert.AreEqual('https://entria.example.com', NormalizedUrl,
            'A url with no scheme must get https:// - stored as typed, every request the integration builds addresses no host at all.');

        // [WHEN] A url already carrying http:// is validated
        NormalizedUrl := NormalizeEntriaUrl('http://entria.example.com');

        // [THEN] Its scheme is left alone rather than prefixed a second time
        _Assert.AreEqual('http://entria.example.com', NormalizedUrl,
            'An explicit http:// must survive - prefixing it again produces a url no request can be sent to.');

        // [WHEN] The url a merchant copies out of the Entria admin address bar is validated
        NormalizedUrl := NormalizeEntriaUrl('https://entria.example.com/admin');

        // [THEN] The /admin suffix is dropped
        _Assert.AreEqual('https://entria.example.com', NormalizedUrl,
            'The /admin suffix must be dropped - left on, every request path becomes /admin/admin/... and the Entria backend answers none of them.');

        // [WHEN] The same url with a trailing slash after /admin is validated
        NormalizedUrl := NormalizeEntriaUrl('https://entria.example.com/admin/');

        // [THEN] Suffix and slash are both dropped
        _Assert.AreEqual('https://entria.example.com', NormalizedUrl,
            'A trailing slash after /admin must be dropped with it - the two shapes a merchant pastes must be stored identically.');

        // [WHEN] A url whose only extra is a trailing slash is validated
        NormalizedUrl := NormalizeEntriaUrl('https://entria.example.com/');

        // [THEN] The trailing slash is dropped
        _Assert.AreEqual('https://entria.example.com', NormalizedUrl,
            'A trailing slash must be dropped - kept, every request path is built with a doubled slash.');

        // [WHEN] A value that is nothing but a scheme is validated
        asserterror NormalizedUrl := NormalizeEntriaUrl('https://');

        // [THEN] It is refused instead of being stored as the store's address
        _Assert.ExpectedError('must be a valid Entria store URL');
    end;

    [Test]
    procedure EnablingStoreWithoutEntriaUrlIsRejected()
    var
        EntriaStore: Record "NPR Entria Store";
        StoreCode: Code[20];
        ImportJobsBefore: Integer;
    begin
        // [SCENARIO] The Enabled OnValidate tests "Entria Url" before anything else: a store with no
        // url can reach no Entria backend, so enabling it must be refused before the same OnValidate
        // goes on to set the import job queue up for it.

        // [GIVEN] An Entria store carrying no Entria Url, committed to the database
        Initialize();
        StoreCode := 'ZZ-ENT-NOURL';
        EntriaStore.Init();
        EntriaStore.Code := StoreCode;
        EntriaStore.Insert();
        Commit();

        // [GIVEN] The import job count up front. Initialize() has already purged every order import job, so
        //         this is 0 - counted rather than assumed, so the assertion below stays a delta if that changes.
        ImportJobsBefore := _LibraryEntria.CountOrderImportJobs();

        // [WHEN] Enabled is validated to true
        asserterror EntriaStore.Validate(Enabled, true);

        // [THEN] The missing url is what stopped it
        _Assert.ExpectedError('must have a value');

        // [THEN] Enabled stays false in the database
        EntriaStore.Get(StoreCode);
        _Assert.IsFalse(EntriaStore.Enabled,
            'A store with no Entria Url must stay disabled - enabled, the import job queries a backend the store has no address for and every cycle fails on it.');

        // [THEN] The refusal left no import job behind. This cannot prove the url check ran BEFORE
        //        SetupJobQueues: asserterror rolls back the failed statement's own writes either way.
        _Assert.AreEqual(ImportJobsBefore, _LibraryEntria.CountOrderImportJobs(),
            'A store whose enabling was refused must not leave a live recurring import job running behind it.');
    end;

    [Test]
    procedure SuccessfulImportAssignsBucketId()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] A successfully imported order must leave the header bucketed: the ecom processing jobs are
        // bucket-filtered, so an unbucketed document is never picked up and never becomes a sales order.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A zero-value order that imports successfully
        OrderCreatedAt := CreateDateTime(DMY2Date(10, 7, 2024), 100000T);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-BUCKET', 'medusa-bucket', OrderCreatedAt, OrderCreatedAt, 0);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] ProcessOrder imports it
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-BUCKET', 'medusa-bucket', OrderCreatedAt, 0);

        // [THEN] The import succeeds
        _Assert.IsTrue(ImportSucceeded, 'Setup: the zero-value order must import successfully, otherwise there is no header to assert the Bucket Id on.');

        // [THEN] The imported header carries a Bucket Id
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-BUCKET');
        _Assert.AreNotEqual(0, EcomSalesHeader."Bucket Id",
            'A successful import must assign a Bucket Id - the ecom processing jobs filter on it, so an unbucketed document is silently never processed while the import still reports success.');
    end;

    [Test]
    procedure ImportMapsPayloadIdentityBillingAndShippingOntoHeader()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
    begin
        // [SCENARIO] The payload's identity, billing address, shipping address and shipment method must land on
        // their own header fields - Sell-to from billing_address, Ship-to from shipping_address, never swapped.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);

        // [GIVEN] A zero-value order carrying an email, a billing address, a shipping address whose every value
        // differs from its billing counterpart, and a shipment method
        OrderCreatedAt := CreateDateTime(DMY2Date(10, 7, 2024), 110000T);
        _LibraryEntria.BuildOrderArrayWithAddresses(OrdersArr, 'ZZ-DOC-ADDR', 'medusa-addr', OrderCreatedAt, 0);

        // [WHEN] The order is imported
        ImportPrebuiltOrder('ZZ-DOC-ADDR', OrdersArr);

        // [THEN] The identity fields come from the payload's own identity properties
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-ADDR');
        _Assert.AreEqual('medusa-addr', Format(EcomSalesHeader."External Document Id"), 'The payload id must reach External Document Id - it is what the order is matched back to Medusa by.');
        _Assert.AreEqual(_LibraryEntria.ExpectedEmail(), Format(EcomSalesHeader."Sell-to Email"), 'The payload email must reach Sell-to Email - it is the only address the order confirmation can be sent to.');

        // [THEN] The Sell-to block comes from billing_address
        _Assert.AreEqual(_LibraryEntria.ExpectedSellToName(), Format(EcomSalesHeader."Sell-to Name"), 'Sell-to Name must be the billing first and last name joined by a single space.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingAddress1(), Format(EcomSalesHeader."Sell-to Address"), 'billing_address.address_1 must reach Sell-to Address.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingAddress2(), Format(EcomSalesHeader."Sell-to Address 2"), 'billing_address.address_2 must reach Sell-to Address 2 - dropped, the invoice is missing the part of the address that identifies the flat or suite.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingPostCode(), Format(EcomSalesHeader."Sell-to Post Code"), 'billing_address.postal_code must reach Sell-to Post Code.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingCity(), Format(EcomSalesHeader."Sell-to City"), 'billing_address.city must reach Sell-to City.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingProvince(), Format(EcomSalesHeader."Sell-to County"), 'billing_address.province must reach Sell-to County - in the countries that require a state or province, an invoice without it is not deliverable.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingCountryCode(), Format(EcomSalesHeader."Sell-to Country Code"), 'billing_address.country_code must reach Sell-to Country Code.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingCompany(), Format(EcomSalesHeader."Sell-to Contact"), 'billing_address.company must reach Sell-to Contact - it is the company the order is billed to on a business purchase.');
        _Assert.AreEqual(_LibraryEntria.ExpectedBillingPhoneNo(), Format(EcomSalesHeader."Sell-to Phone No."), 'billing_address.phone must reach Sell-to Phone No. - it is the only number the customer can be reached on about the order.');

        // [THEN] The Ship-to block comes from shipping_address
        _Assert.AreEqual(_LibraryEntria.ExpectedShipToName(), Format(EcomSalesHeader."Ship-to Name"), 'Ship-to Name must be the shipping first and last name joined by a single space.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingAddress1(), Format(EcomSalesHeader."Ship-to Address"), 'shipping_address.address_1 must reach Ship-to Address.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingAddress2(), Format(EcomSalesHeader."Ship-to Address 2"), 'shipping_address.address_2 must reach Ship-to Address 2 - dropped, the parcel is missing the part of the address that identifies the flat or suite.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingPostCode(), Format(EcomSalesHeader."Ship-to Post Code"), 'shipping_address.postal_code must reach Ship-to Post Code.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingCity(), Format(EcomSalesHeader."Ship-to City"), 'shipping_address.city must reach Ship-to City.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingProvince(), Format(EcomSalesHeader."Ship-to County"), 'shipping_address.province must reach Ship-to County - in the countries that require a state or province, a parcel without it is not deliverable.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingCountryCode(), Format(EcomSalesHeader."Ship-to Country Code"), 'shipping_address.country_code must reach Ship-to Country Code.');
        _Assert.AreEqual(_LibraryEntria.ExpectedShippingCompany(), Format(EcomSalesHeader."Ship-to Contact"), 'shipping_address.company must reach Ship-to Contact - it is who the carrier asks for at the delivery address.');

        // [THEN] The shipment method comes from the first shipping method
        _Assert.AreEqual(_LibraryEntria.ExpectedShipmentMethodName(), Format(EcomSalesHeader."Shipment Method Code"), 'shipping_methods[0].name must reach Shipment Method Code - without it the order ships by whatever method the customer did not pay for.');

        // [THEN] The two blocks are not the same address: a Sell-to block wrongly read off shipping_address
        // would satisfy every field-by-field assertion above once both sides were sourced from one address
        _Assert.AreNotEqual(Format(EcomSalesHeader."Sell-to Address"), Format(EcomSalesHeader."Ship-to Address"),
            'The Sell-to and Ship-to addresses must stay distinct - reading both off one address invoices or ships the order to the wrong party.');
        _Assert.AreNotEqual(Format(EcomSalesHeader."Sell-to Name"), Format(EcomSalesHeader."Ship-to Name"),
            'The Sell-to and Ship-to names must stay distinct - reading both off one address invoices or ships the order to the wrong party.');
    end;

    [Test]
    procedure ImportSucceedsWithPartiallyLoadedStoreRecord()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
        OrderCreatedAt: DateTime;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] The scheduled import reads only two fields off the store - its code and its location. The
        // import must work with just those, because relying on any further store setting would fail only when
        // the job queue runs it, and nowhere else.

        // [GIVEN] An enabled Entria store read with exactly the two fields the job queue loads - Code and
        //         "Location Code". Widening the import path to read any third store field makes this test
        //         fail here, instead of only in the job queue where every other test loads a full store.
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.SetLoadFields(Code, "Location Code");
        EntriaStore.Get(_StoreCode);

        // [GIVEN] A zero-value order that imports successfully
        OrderCreatedAt := CreateDateTime(DMY2Date(10, 7, 2024), 140000T);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-PARTIAL', 'medusa-partial', OrderCreatedAt, OrderCreatedAt, 0);
        OrdersArr.Get(0, OrderTkn);

        // [WHEN] It is imported off that partially loaded store record
        ImportSucceeded := EntriaJQ.ProcessOrder(EntriaStore, OrderTkn, 'ZZ-DOC-PARTIAL', 'medusa-partial', OrderCreatedAt, 0);

        // [THEN] The import succeeds and the document is there
        _Assert.IsTrue(ImportSucceeded, 'The import must succeed off a store record loaded with only Code and Location Code - it is exactly the record the scheduled pass hands it.');
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-PARTIAL');

        // [THEN] Nothing was written to the failure registry
        _Assert.IsFalse(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-partial'),
            'A successful import must leave no registry row - a row here means the partially loaded store record made the import throw and the order was parked for retry.');
    end;

    [Test]
    procedure ImportedOrderIsTaxInclusive()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Item: Record Item;
        ItemObj: JsonObject;
        NoTaxRates: List of [Decimal];
    begin
        // [SCENARIO] An imported order must be tax-inclusive: the web always sends amounts with tax in them.

        // [GIVEN] An enabled Entria store and an item
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.CreateItem(Item, 100, false);

        // [GIVEN] An order of 100 in the local currency
        _LibraryEntria.BuildItemLineJson(ItemObj, 'Entria tax-inclusive line', Item."No.", 1, 100, 100, 0, 100, NoTaxRates);

        // [WHEN] The order is imported
        ImportSingleLineOrder('ZZ-DOC-INCLVAT', 'medusa-inclvat', '', ItemObj, 100, CreateDateTime(DMY2Date(10, 7, 2024), 120000T));

        // [THEN] The header is flagged tax-inclusive
        FindEcomOrderHeader(EcomSalesHeader, _StoreCode, 'ZZ-DOC-INCLVAT');
        _Assert.IsFalse(EcomSalesHeader."Price Excl. VAT",
            'An imported Entria order must carry Price Excl. VAT false - flagged excluding VAT, every tax-inclusive amount the web sent is re-read as a net amount and VAT is added on top of an already taxed order.');
    end;

    [Test]
    procedure MissingPaymentCollectionsAndMissingPaymentsFailWithDistinctMessages()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NoCollectionsOrdersArr: JsonArray;
        NoPaymentsOrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        MissingCollectionsError: Text;
        MissingPaymentsError: Text;
    begin
        // [SCENARIO] The two payment failure shapes must fail with their own message: "no payment_collections at
        // all" is an integration fault needing a developer, "a collection carrying no payments" is a timing issue
        // that fixes itself on retry, and an operator triaging a stuck store has only the message to tell them apart.

        // [GIVEN] An enabled Entria store
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderCreatedAt := CreateDateTime(DMY2Date(10, 7, 2024), 150000T);

        // [GIVEN] One order of 100 carrying no payment_collections property at all, and one whose
        // payment_collections is present but carries an empty payments array
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(NoCollectionsOrdersArr, 'ZZ-DOC-PCMSG1', 'medusa-pcmsg1', OrderCreatedAt, OrderCreatedAt, 100);
        _LibraryEntria.BuildOrderArrayWithEmptyPaymentCollections(NoPaymentsOrdersArr, 'ZZ-DOC-PCMSG2', 'medusa-pcmsg2', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] The order carrying no payment_collections is imported
        asserterror ImportPrebuiltOrder('ZZ-DOC-PCMSG1', NoCollectionsOrdersArr);
        MissingCollectionsError := GetLastErrorText();

        // [THEN] It fails on the collections being unavailable
        _Assert.ExpectedError('payment collections are not available yet');

        // [WHEN] The order whose collection carries no payments is imported
        asserterror ImportPrebuiltOrder('ZZ-DOC-PCMSG2', NoPaymentsOrdersArr);
        MissingPaymentsError := GetLastErrorText();

        // [THEN] It fails on the payment information being unavailable
        _Assert.ExpectedError('payment information is not available yet');

        // [THEN] The two failures do not report the same thing
        _Assert.AreNotEqual(MissingCollectionsError, MissingPaymentsError,
            'The two payment failure shapes must report differently - one message for both leaves an operator unable to tell an integration fault needing a developer from a benign timing issue that clears on retry.');

        // [THEN] Neither failed import left a document behind
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCode);
        EcomSalesHeader.SetFilter("External No.", '%1|%2', 'ZZ-DOC-PCMSG1', 'ZZ-DOC-PCMSG2');
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'No Ecom Sales Header may survive a failed import - a surviving one would be invoiced with no payment at all.');
    end;

    local procedure FindEcomOrderHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; StoreCode: Code[20]; ExternalNo: Code[20])
    begin
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Ecommerce Store Code", StoreCode);
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;

    local procedure ImportSingleLineOrder(DocumentNo: Code[20]; MedusaOrderId: Text; CurrencyCode: Code[10]; ItemObj: JsonObject; PaymentAmount: Decimal; CreatedAt: DateTime)
    var
        OrdersArr: JsonArray;
    begin
        _LibraryEntria.BuildOrderArrayForItemLine(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, CurrencyCode, ItemObj, PaymentAmount);
        ImportPrebuiltOrder(DocumentNo, OrdersArr);
    end;

    local procedure ImportPrebuiltOrder(DocumentNo: Code[20]; OrdersArr: JsonArray)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrderTkn: JsonToken;
    begin
        EntriaStore.Get(_StoreCode);
        OrdersArr.Get(0, OrderTkn);
        EntriaOrderImpl.ImportOrder(OrderTkn, EntriaStore, DocumentNo, EcomSalesHeader);
    end;

    local procedure NormalizeEntriaUrl(SuppliedUrl: Text): Text
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        EntriaStore.Init();
        EntriaStore."Entria Url" := CopyStr(SuppliedUrl, 1, MaxStrLen(EntriaStore."Entria Url"));
        EntriaIntegrationMgt.ValidateEntriaUrl(EntriaStore);
        exit(EntriaStore."Entria Url");
    end;

    /// <summary>
    /// Asserts the whole state "Requeue for Import" has to leave behind, so the Error and the Skipped case are held
    /// to the same bar - one of them asserted more loosely than the other is how the weaker path stays broken.
    /// Deliberately stops at the state the action wrote and does not re-ask IsOrderDueForIdBasedRetry: that helper
    /// compares the stored Next Retry At against a fresh CurrentDateTime, and the stamp this action writes can round
    /// up past that instant on SQL's 1/300s datetime grid - a few milliseconds that cost production nothing (the row
    /// is left untouched and the next pass takes it) but make the assertion flaky. That this state is due is pinned
    /// condition by condition in IsRetryDuePinsEachConditionOnItsOwn, and end to end with a margin in
    /// ParkedRowRequiresManualRequeue.
    /// </summary>
    local procedure AssertOrderWasArmedForImmediateRetry(MedusaOrderId: Text[100]; BeforeInvokeDT: DateTime; AfterInvokeDT: DateTime; RowDescription: Text)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.Get(_StoreCode, MedusaOrderId);
        _Assert.AreNotEqual(0DT, EntriaOrderImpFailure."Next Retry At",
            StrSubstNo('"Requeue for Import" on %1 must write a real Next Retry At - a row carrying the 0DT sentinel is filtered out of every retry pass, so the action would silently do nothing.', RowDescription));
        _Assert.AreEqual(EntriaOrderImpFailure.Status::Pending, EntriaOrderImpFailure.Status,
            StrSubstNo('"Requeue for Import" on %1 must leave it Pending - on any other Status the retry pass filters it out and the fresh budget is never spent.', RowDescription));
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            StrSubstNo('"Requeue for Import" on %1 must reset Retry Count to 0 - the budget check is independent of the Status, so a row left at its old count is still barred from the pass.', RowDescription));
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" >= BeforeInvokeDT,
            StrSubstNo('"Requeue for Import" on %1 must schedule the retry as of now - an older timestamp means the action wrote something other than the current time.', RowDescription));
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" <= AfterInvokeDT,
            StrSubstNo('"Requeue for Import" on %1 must schedule an immediate retry, not one in the future - a later timestamp means the row''s old schedule was left in place or something other than the current time was written.', RowDescription));
    end;

    /// <summary>
    /// Inserts a registry row the way the code before the Status field did: Suppressed written explicitly and
    /// Status left on its default, which is the state the upgrade backfill has to interpret.
    /// </summary>
    local procedure InsertLegacyOrderFailureRow(MedusaOrderId: Text[100]; RetryCount: Integer; NextRetryAt: DateTime; Suppressed: Boolean)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.Init();
        EntriaOrderImpFailure."Store Code" := _StoreCode;
        EntriaOrderImpFailure."Order Id" := MedusaOrderId;
        EntriaOrderImpFailure."Retry Count" := RetryCount;
        EntriaOrderImpFailure."Next Retry At" := NextRetryAt;
#pragma warning disable AL0432
        EntriaOrderImpFailure.Suppressed := Suppressed;
#pragma warning restore AL0432
        EntriaOrderImpFailure.Insert();
    end;

    local procedure FindSingleEcomSalesLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; DocumentEntryNo: BigInteger)
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", DocumentEntryNo);
        _Assert.AreEqual(1, EcomSalesLine.Count(), 'A one-item payload must produce exactly one Ecom Sales Line - any extra line would make the amount assertions ambiguous.');
        EcomSalesLine.FindFirst();
    end;

    local procedure Initialize()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // Per test, not once per run: TestIsolation = Codeunit rolls back once, at the END of the codeunit,
        // so every write an earlier test made - committed or not - is still there for the next one. A marker
        // one test leaves behind would silently break the assertions of every test declared after it.
        // Measured on BC 28: a committed row is gone in the next run, so the leak is between tests in one
        // run, not across runs.
        // Both store codes are swept: rows a cross-store test committed under the second one would
        // otherwise flow into a later test the same way.
        EntriaOrderImpFailure.SetFilter("Store Code", '%1|%2', _StoreCodeLbl, _SecondStoreCodeLbl);
        EntriaOrderImpFailure.DeleteAll();
        EcomSalesHeader.SetFilter("Ecommerce Store Code", '%1|%2', _StoreCodeLbl, _SecondStoreCodeLbl);
        EcomSalesHeader.DeleteAll(true);
        EntriaStoreSyncState.SetFilter("Store Code", '%1|%2', _StoreCodeLbl, _SecondStoreCodeLbl);
        EntriaStoreSyncState.DeleteAll();

        // The integration mgt. codeunit is SingleInstance and caches both the setup and the stores it
        // resolved by code. A test that switches "Enable Integration" off and fails before restoring it
        // would otherwise leave that cache behind and turn every later test red for an unrelated reason.
        EntriaIntegrationMgt.SetRereadSetup();

        //Bracketed with the hold subscriber: this DeleteAll fires "NPR Entria Store".OnDelete, which re-asserts
        //the order import job setup and reaches StartJobQueueEntry. That is inert today only because
        //TaskScheduler.CanCreateTask() is false in the test runner - on a runner where it is true the call would
        //hand the long-running importer to the platform. The hold subscriber removes that dependency.
        _LibraryEntria.DeleteStores('ZZ-ENT-*');

        // Deleting a store fires "NPR Entria Store".OnDelete, which re-asserts the order import job queue
        // setup. While _StoreCodeLbl is enabled with Sales Order Integration on, that re-assertion CREATES the
        // recurring importer entry and registers it as a monitored job. The hold subscriber keeps it On Hold,
        // but the entry and its monitored row are still there for every later test in this run, so both are
        // purged here.
        _LibraryEntria.ClearOrderImportJobQueueState();

        // The api-handler guard is what makes every refetch in this suite fail deterministically, and the one
        // test that needs a live refetch has to switch it off - through a write ProcessDueRetries then commits.
        // Swept here rather than restored at the end of that test: the restore would be rolled back with the
        // test while the committed enable survived it, and it would be skipped entirely by a failed assertion.
        _LibraryEntria.SetHttpClientRequestsAllowed(false);
        _LibraryEntria.ClearStoreAPIKey(_StoreCodeLbl);

        if not _Initialized then begin
            _Initialized := true;
            _LibraryEntria.EnsureSetupExists();
        end;
        _StoreCode := _StoreCodeLbl;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    /// <summary>Keeps the last message a page raised, so a test can assert what the operator was told.</summary>
    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
        _LastMessageTxt := Msg;
    end;

}
#endif
