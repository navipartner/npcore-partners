#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85260 "NPR Entria Tests"
{
    // [FEATURE] Entria order import - the list and ID-based retry passes, the sync marker, the order
    // import failure registry and the payload-to-document mapping - plus the guards of the Entria item
    // price-change webhook subscriber.
    //
    // NOTE on the price-change webhook: the production publisher
    // "NPR Entria Integr. Webhooks".OnItemUnitPriceChanged is an [ExternalBusinessEvent], which is not a
    // subscribable in-process event type - the notification goes to external HTTP subscribers only after
    // the transaction commits, so a BC test cannot observe the dispatch. The WebhookGuards_* tests
    // therefore verify that the production subscriber "NPR Entria Webhook Subscr." would REACH the
    // publisher call: "NPR Entria TestSub" captures the same Rec/xRec state on Item OnAfterModifyEvent,
    // and HasEnabledStore() is called from the test directly.

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _Initialized: Boolean;
        _StoreCode: Code[20];
        _StoreCodeLbl: Label 'NPRENT-TEST', Locked = true;

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
        _Assert.AreNotEqual(TestSub.GetOnAfterRecPrice(), TestSub.GetOnAfterXRecPrice(),
            'Guard: Rec."Unit Price" <> xRec."Unit Price" must hold');

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
            'A repeat within the hour must be deduped - the job retries every minute, so emitting each one would bury Sentry in duplicates of a single outage.');

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
        // created_at and updated_at are equal here - the marker now tracks created_at, but the
        // distinction between the two is covered separately by MarkerAdvancesByCreatedAtNotUpdatedAt.

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

        // [THEN] The session max advances to the failing order's created_at instead of freezing
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
            'Session max must advance to the failing order''s created_at, not stay frozen.');

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
    procedure MarkerAdvancesByCreatedAtNotUpdatedAt()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderCreatedAt: DateTime;
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] The marker must track the order's created_at (immutable), and must
        // NOT be influenced by updated_at (mutable). updated_at is deliberately set far in the
        // future of created_at, so a marker that took updated_at instead would be caught here.

        // [GIVEN] An enabled Entria store and an order created in 2024 but carrying an updated_at in 2030
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderCreatedAt := CreateDateTime(DMY2Date(15, 6, 2024), 100000T);
        OrderUpdatedAt := CreateDateTime(DMY2Date(15, 6, 2030), 100000T);

        // [GIVEN] A seeded session max and a page holding that one order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-CREATEDMARK', 'medusa-createdmark', OrderCreatedAt, OrderUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max tracks created_at and ignores the far later updated_at
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
            'The marker must advance to the order''s created_at, not its (later) updated_at.');
    end;

    [Test]
    procedure ProcessListSecondPassSkipsNotYetDueRegistryRow()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        SessionMaxAfterFirstPass: DateTime;
    begin
        // [SCENARIO] Regression guard: once ProcessList has recorded a registry row for
        // a failed order, a second ProcessList pass over the SAME order array must not touch that
        // row again while it is not yet due - the registry, not the list path, owns retry timing.
        // Before the fix this re-ran LogOrderFailure every pass, burning the whole
        // backoff schedule in seconds and growing Retry Count unbounded.

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
        SessionMaxAfterFirstPass := EntriaJQ.GetSessionMaxCreatedAt(_StoreCode);

        // [WHEN] ProcessList runs a second time over the SAME order array, while the row is not yet due
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The registry row keeps its retry budget and the session max does not advance again
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-duppass');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'Second pass over the same order must not touch the registry row - Next Retry At is still in the future.');
        _Assert.AreEqual(SessionMaxAfterFirstPass, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
            'Second pass must not advance the session max again for a skipped not-due retry row.');
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

        // [GIVEN] A registry row for that order which is not yet due, so the list path skips it
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-regmark', 0, CurrentDateTime() + 3600000);

        // [GIVEN] A session max seeded from that marker and a page holding only that one order
        EntriaJQ.SeedSessionMax(_StoreCode);
        _Assert.AreEqual(MarkerBefore, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode), 'Setup: the session max must start at the stored marker.');
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-REGMARK', 'medusa-regmark', OrderCreatedAt, OrderCreatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The session max advances to the skipped order's created_at
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
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
    procedure ParkedRowRequiresManualMarkForImport()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        ParkedRowIsDue: Boolean;
    begin
        // [SCENARIO] A row that has exhausted its retry budget is PARKED. The one Sentry alert at exhaustion summons a human;
        //only the page's "Mark for Import" (Retry Count 0, Next Retry At now) re-arms it.

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

        // [THEN] The parked row is left untouched at MaxRetries()
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-parked');
        _Assert.AreEqual(EntriaJQ.MaxRetries(), EntriaOrderImpFailure."Retry Count",
            'The list path must skip a parked row untouched.');

        // [WHEN] A human uses "Mark for Import" - Retry Count back to 0, an immediate Next Retry At and Suppressed cleared
        EntriaOrderImpFailure."Retry Count" := 0;
        EntriaOrderImpFailure."Next Retry At" := CurrentDateTime();
        EntriaOrderImpFailure.Suppressed := false;
        EntriaOrderImpFailure.Modify(true);

        // [THEN] The row is due for the ID-based retry pass again
        _Assert.IsTrue(EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-parked'),
            '"Mark for Import" must make the row due for the ID-based retry pass again.');
    end;

    [Test]
    procedure FromDTStableAcrossPagesInOneCycle()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        ExpectedMarkerDT: DateTime;
        FromDT: DateTime;
        InitialMarker: DateTime;
        Page2CreatedAt: DateTime;
        Page1RequestText: Text;
        Page2RequestText: Text;
        RederivedRequestText: Text;
        WindowSegment: Text;
        WindowPos: Integer;
    begin
        // [SCENARIO] The original pagination bug: the query window must be snapshotted once per
        // DownloadOrders pass and stay fixed while Offset advances - re-deriving it from the marker per
        // page narrows the window while Offset has already moved on, skipping a page worth of orders.
        // DownloadOrders is local and needs a live HTTP layer, so what is pinned instead is the contract
        // it rests on: GenerateGetOrderListRequest takes the window from the FromDT it is HANDED, never
        // from the marker - which real flushes deliberately advance between the two pages here.

        // [GIVEN] An enabled Entria store whose marker already stands at 14 June 2024, so the pass has
        //         a real window start rather than the never-synced 0DT sentinel (which carries no filter)
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        InitialMarker := CreateDateTime(DMY2Date(14, 6, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCode, InitialMarker);

        // [GIVEN] A second page whose order is created a day after the first page's
        Page2CreatedAt := CreateDateTime(DMY2Date(16, 6, 2024), 100000T);

        // [GIVEN] The pass snapshots its query window FromDT once, up front, and seeds its session max
        ExpectedMarkerDT := EntriaJQ.GetSyncStateMarker(_StoreCode);
        EntriaJQ.SeedSessionMax(_StoreCode);
        FromDT := ExpectedMarkerDT;
        _Assert.AreEqual(InitialMarker, FromDT, 'Setup: the pass must snapshot the stored marker as its window start.');

        // [GIVEN] The window segment the pass's very first request carries, taken from that request's own
        //         output rather than rebuilt here, so the overlap constant stays pinned in one place -
        //         OrderListRequestContract
        Page1RequestText := EntriaJQ.GenerateGetOrderListRequest(0, 40, FromDT);
        WindowPos := Page1RequestText.IndexOf('created_at[$gte]=');
        _Assert.IsTrue(WindowPos > 0, 'Setup: a pass with a real window start must carry a created_at window filter.');
        WindowSegment := CopyStr(Page1RequestText, WindowPos);

        // [WHEN] Page 1 is processed and flushed
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-PAGE1', 'medusa-page-1', CreateDateTime(DMY2Date(15, 6, 2024), 100000T), CreateDateTime(DMY2Date(15, 6, 2024), 100000T), 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);
        EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [WHEN] Page 2, carrying the later order, is processed and flushed in the same pass
        Clear(OrdersArr);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-PAGE2', 'medusa-page-2', Page2CreatedAt, Page2CreatedAt, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);
        EntriaJQ.TryFlushMarker(_StoreCode, ExpectedMarkerDT);

        // [THEN] The flushes have advanced the stored marker to the later order
        _Assert.AreEqual(Page2CreatedAt, EntriaJQ.GetSyncStateMarker(_StoreCode),
            'The flushes must have advanced the stored marker to the later order.');

        // [THEN] The page-2 request built from the pass's own snapshot carries the very same window as
        //        page 1 did, even though the marker has since advanced under it
        Page2RequestText := EntriaJQ.GenerateGetOrderListRequest(40, 40, FromDT);
        _Assert.IsTrue(Page2RequestText.Contains(WindowSegment),
            'Page 2 must query the window the pass snapshotted - the request builder takes it from the FromDT it is handed, never from the marker.');

        // [THEN] Re-deriving the window from the advanced marker gives a strictly narrower one - that
        //        difference is exactly what the pagination bug leaked, so the snapshot is what
        //        DownloadOrders has to keep passing in
        RederivedRequestText := EntriaJQ.GenerateGetOrderListRequest(40, 40, EntriaJQ.GetSyncStateMarker(_StoreCode));
        _Assert.IsFalse(RederivedRequestText.Contains(WindowSegment),
            'A window re-derived from the advanced marker must NOT be the window the pass snapshotted - re-deriving it per page is the bug.');
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
        // budget failing is what parks the row at MaxRetries(). The concrete step lengths are pinned
        // by BackoffDurationCoversExactlyTheRetryBudget.

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

        // [WHEN] Every retry but the last one in the budget fails in turn
        for i := 1 to EntriaJQ.MaxRetries() - 1 do begin
            RetryCount := EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-BACKOFF', 'medusa-backoff', BaseDT, StrSubstNo('boom %1', i + 1), 0, BaseDT);

            // [THEN] Retry Count counts the retries performed and the next retry gets its own backoff step
            _Assert.AreEqual(i, RetryCount, StrSubstNo('Failed retry %1 must increment Retry Count to %1.', i));
            EntriaOrderImpFailure.Get(_StoreCode, 'medusa-backoff');
            _Assert.AreEqual(BaseDT + EntriaJQ.BackoffDuration(i + 1), EntriaOrderImpFailure."Next Retry At",
                StrSubstNo('Retry %1 must be scheduled its own backoff step out.', i + 1));
        end;

        // [WHEN] The last retry in the budget fails
        RetryCount := EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-BACKOFF', 'medusa-backoff', BaseDT, 'boom final', 0, BaseDT);

        // [THEN] Retry Count reaches MaxRetries() and the row is parked with the 0DT sentinel
        _Assert.AreEqual(EntriaJQ.MaxRetries(), RetryCount, 'The last failed retry in the budget must bring Retry Count to MaxRetries() and park the row.');
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-backoff');
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At",
            'A parked row must carry the 0DT sentinel - no further automatic retry is ever scheduled.');
    end;

    [Test]
    procedure DisplayNoSurvivesFailedRefetchDuringIdBasedRetry()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
    begin
        // [SCENARIO] A row's captured identity must survive the ID-based retry pass's refetch-failure
        // branch in ProcessDueRetry, which forwards the row's own "Display No.", "Document No." and
        // "Order Updated At" to LogOrderFailure rather than losing them.

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

        // [THEN] The row keeps the identity it captured on the first failure
        _Assert.AreEqual(OrderUpdatedAt, EntriaOrderImpFailure."Order Updated At",
            'Order Updated At must survive the refetch-failure branch - it is written unconditionally, so a branch that stopped forwarding it would wipe the row''s timestamp.');
        _Assert.AreEqual(360, EntriaOrderImpFailure."Display No.",
            'Display No. must survive the refetch-failure branch of the ID-based retry - it is the order number the merchant sees in the Entria admin, captured from the list payload on the FIRST failure, and a refetch failure carries no payload to read display_id from again; resetting it to 0 shows an operator a column of blanks during an Entria outage.');
        _Assert.AreEqual('ZZ-DOC-DISPNO', EntriaOrderImpFailure."Document No.",
            'Document No. must survive the refetch-failure branch too - it is the other half of the row''s captured identity.');
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
        // [SCENARIO] SetFailureFields writes "Document No." and "Display No." only when the failure
        // being logged actually carries them. That matters as soon as an order fails TWICE: the first
        // failure captured its identity from the payload, while both blank-identity branches - the list
        // path's missing custom_display_id and the retry pass's own - log the second failure with '' and
        // 0. Without the guards that second failure would blank out the very two columns an operator
        // identifies the order by on the failures page, exactly when the order has been failing longest.

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
    procedure MissingDisplayIdGetsOneRegistryRowNotOnePerPass()
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
        _Assert.AreEqual(OrderCreatedAt, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
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
        // [SCENARIO] The literal wire contract the whole marker design rests on: ordinal offset
        // paging is only sound because the sort key is the immutable created_at, the window filter
        // is created_at with the 30-second overlap subtracted, and offset/limit are passed through
        // verbatim. Nothing else in the suite exercises the actual request text.

        // [GIVEN] A window start of 12:00 on 15 June 2024
        FromDT := CreateDateTime(DMY2Date(15, 6, 2024), 120000T);

        // [WHEN] The list request is generated for offset 80 and limit 40 from that window start
        RequestText := EntriaJQ.GenerateGetOrderListRequest(80, 40, FromDT);

        // [THEN] It sorts by created_at and filters on created_at with the 30-second overlap subtracted
        _Assert.IsTrue(RequestText.Contains('order=created_at'), 'The list must be sorted by created_at.');
        _Assert.IsTrue(RequestText.Contains('created_at[$gte]=' + Format(FromDT - 30000, 0, 9)),
            'The window filter must be created_at with the 30-second overlap subtracted.');

        // [THEN] Offset and limit are passed through verbatim and updated_at appears nowhere
        _Assert.IsTrue(RequestText.Contains('offset=80'), 'The offset must be passed through verbatim.');
        _Assert.IsTrue(RequestText.Contains('limit=40'), 'The limit must be passed through verbatim.');
        _Assert.IsFalse(RequestText.Contains('updated_at'), 'updated_at must appear nowhere in the request - it is mutable and was the original skip bug.');

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

        // [THEN] The request carries no window filter at all, so the full history is requested
        _Assert.IsFalse(RequestText.Contains('created_at[$gte]'),
            'A store that has never synced (0DT marker) must request the full history, without a window filter.');
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
        // [SCENARIO] Second shape: "payment_collections" IS present but carries no
        // "payments". That must fail the import just like a missing "payment_collections" does.

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
        _Assert.IsFalse(ImportSucceeded, 'Import must fail when payment_collections carries no payments and the amount is non-zero.');

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
        // due - a parked row has no automatic re-arm at all and waits for "Mark for Import".
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

        // [THEN] The row is left byte-for-byte untouched - Retry Count, Order Updated At and Next Retry At all unchanged
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-rearm');
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
    procedure SuppressedRowIsNotRearmedByFresherPayload()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OldUpdatedAt: DateTime;
        NewUpdatedAt: DateTime;
        RetryCountBefore: Integer;
    begin
        // [SCENARIO] Suppressed is an explicit human "stop trying this one" and outranks even a
        // fresher updated_at. 

        // [GIVEN] An enabled Entria store, an order first seen on 3 February 2024 and a fresher payload dated a day later
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OldUpdatedAt := CreateDateTime(DMY2Date(3, 2, 2024), 100000T);
        NewUpdatedAt := CreateDateTime(DMY2Date(4, 2, 2024), 100000T);

        // [GIVEN] A registry row for that order that a human has explicitly Suppressed
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SUPRR', 'medusa-suprr', OldUpdatedAt, 'boom', 0, CurrentDateTime() - 60000);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprr');
        EntriaOrderImpFailure.Suppressed := true;
        EntriaOrderImpFailure.Modify();
        RetryCountBefore := EntriaOrderImpFailure."Retry Count";

        // [GIVEN] A seeded session max and a page carrying that same order with the FRESHER updated_at
        EntriaJQ.SeedSessionMax(_StoreCode);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-DOC-SUPRR', 'medusa-suprr', NewUpdatedAt, NewUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The row survives with Suppressed still set and its Retry Count unchanged
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprr'), 'The Suppressed row must still exist.');
        _Assert.IsTrue(EntriaOrderImpFailure.Suppressed, 'Suppressed must remain true - a newer payload must not clear a human''s explicit stop.');
        _Assert.AreEqual(RetryCountBefore, EntriaOrderImpFailure."Retry Count", 'Retry Count must be unchanged - the list path must not touch a Suppressed row at all.');

        // [THEN] The ID-based retry pass does not re-arm it either
        _Assert.IsFalse(EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-suprr'),
            'A Suppressed row must not be due for the ID-based retry pass either.');
    end;

    [Test]
    procedure SuppressedRowIsSkippedByTheWholeRetryPass()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrderUpdatedAt: DateTime;
        NextRetryAtBefore: DateTime;
    begin
        // [SCENARIO] Suppressed is checked twice on the way to a retry - as a filter when the due rows
        // are collected, and once more per row just before it is retried, since a human can suppress a
        // row between the two. ProcessDueRetries is the only reachable seam that runs the whole sequence,
        // so the end-to-end guarantee is pinned here: a row that is due on every other count must come
        // out of a complete retry pass untouched while it is Suppressed.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 8 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        OrderUpdatedAt := CreateDateTime(DMY2Date(8, 2, 2024), 100000T);

        // [GIVEN] A registry row that is due on every other count - a minute-old Next Retry At and its full retry budget
        EntriaJQ.UpsertOrderFailure(_StoreCode, 'ZZ-DOC-SUPRUN', 'medusa-suprun', OrderUpdatedAt, 'boom', 360, CurrentDateTime() - 60000);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprun');
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" <= CurrentDateTime(),
            'Setup: the row must already be due on its Next Retry At, so Suppressed is the only thing holding it back.');
        NextRetryAtBefore := EntriaOrderImpFailure."Next Retry At";

        // [GIVEN] A human has Suppressed that row
        EntriaOrderImpFailure.Suppressed := true;
        EntriaOrderImpFailure.Modify();

        // [WHEN] A full retry pass runs for a cycle whose store-wide list fetch succeeded
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The row was never retried - retry budget, schedule and the human's stop are all intact
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-suprun');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count",
            'A Suppressed row must not be retried - a burnt retry means the pass drove an order a human explicitly stopped towards parking.');
        _Assert.AreEqual(NextRetryAtBefore, EntriaOrderImpFailure."Next Retry At",
            'A Suppressed row must not be rescheduled either - the retry pass must leave it exactly as the human left it.');
        _Assert.IsTrue(EntriaOrderImpFailure.Suppressed, 'The retry pass must not clear Suppressed.');
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
        // [SCENARIO] A row that reached parking through the normal route carries BOTH halves of the
        // parked state at once - Retry Count at MaxRetries() AND the 0DT sentinel in "Next Retry At" -
        // so no test built on such a row can tell which of the two conditions is doing the work. Each
        // is pinned on its own here, on rows inserted directly: an exhausted budget alone keeps a row
        // out of the retry pass even with a perfectly due timestamp, and the 0DT sentinel alone keeps
        // it out even on a full budget.

        // [GIVEN] An enabled Entria store and a due timestamp an hour in the past
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        EntriaStore.Get(_StoreCode);
        PastDueDT := CurrentDateTime() - (60 * 60 * 1000);

        // [GIVEN] A row whose retry budget is exhausted, but whose Next Retry At is a real and long-past timestamp
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-exhausted', EntriaJQ.MaxRetries(), PastDueDT);

        // [GIVEN] A row on its full retry budget, but carrying the 0DT sentinel
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-sentinel', 0, 0DT);

        // [GIVEN] A row that is due on both counts, so a pass that picked up nothing at all would be caught
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-duecontrol', 0, PastDueDT);

        // [WHEN] The ID-based retry pass is asked about each of the three rows
        ExhaustedRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-exhausted');
        SentinelRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-sentinel');
        DueControlRowIsDue := EntriaJQ.IsOrderDueForIdBasedRetry(_StoreCode, 'medusa-duecontrol');

        // [THEN] The exhausted row is not retried, however due its timestamp looks
        _Assert.IsFalse(ExhaustedRowIsDue,
            'A row at MaxRetries() must never be retried automatically - it waits for "Mark for Import", or the retry budget stops bounding anything.');

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
        SuppressedRowIsDue: Boolean;
        ExhaustedRowIsDue: Boolean;
        SentinelRowIsDue: Boolean;
        FutureRowIsDue: Boolean;
    begin
        // [SCENARIO] IsRetryDue is the row-level re-check ProcessDueRetries runs after CollectDueRetries
        // has already filtered, so it is the half that stops a row suppressed between the two steps.
        // Asserting it through IsOrderDueForIdBasedRetry cannot pin it - that helper calls both layers,
        // so each masks the other and deleting one condition alone stays green. Each is pinned here.

        // [GIVEN] An enabled Entria store and a due timestamp an hour in the past
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        PastDueDT := CurrentDateTime() - (60 * 60 * 1000);

        // [GIVEN] A row due on every condition, and four rows each failing exactly one of them
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-all', 0, PastDueDT);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-suppressed', 0, PastDueDT);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-exhausted', EntriaJQ.MaxRetries(), PastDueDT);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-sentinel', 0, 0DT);
        _LibraryEntria.InsertOrderFailureRow(_StoreCode, 'medusa-due-future', 0, CurrentDateTime() + (60 * 60 * 1000));

        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-suppressed');
        EntriaOrderImpFailure.Suppressed := true;
        EntriaOrderImpFailure.Modify();

        // [WHEN] The row-level check is asked about each row on its own
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-all');
        ControlRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-suppressed');
        SuppressedRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-exhausted');
        ExhaustedRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-sentinel');
        SentinelRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-due-future');
        FutureRowIsDue := EntriaJQ.IsRetryDue(EntriaOrderImpFailure);

        // [THEN] The row failing nothing is due, so the four negatives below cannot hold vacuously
        _Assert.IsTrue(ControlRowIsDue,
            'A row with budget left and a past Next Retry At must be due here - otherwise this check rejects everything and the assertions below prove nothing.');

        // [THEN] Suppressed alone stops it - this is the condition CollectDueRetries cannot cover
        _Assert.IsFalse(SuppressedRowIsDue,
            'A row suppressed after CollectDueRetries picked it up must still be stopped here, or a human''s "stop trying this one" is ignored under concurrency.');

        // [THEN] An exhausted budget alone stops it
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
        // parallel session. Only a BACKWARDS move (a human rewind) stops the pass - covered by
        // ManualMarkerEditMidPaginationIsNotOverwritten.

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
        BaseDT := CurrentDateTime() - (60 * 60 * 1000); // one hour in the past, safely before "now"

        // [GIVEN] 25 due registry rows whose Next Retry At values are staggered one second apart
        for i := 1 to 25 do begin
            EntriaOrderImpFailure.Init();
            EntriaOrderImpFailure."Store Code" := _StoreCode;
            EntriaOrderImpFailure."Order Id" := CopyStr(StrSubstNo('medusa-cap-%1', i), 1, MaxStrLen(EntriaOrderImpFailure."Order Id"));
            EntriaOrderImpFailure."Next Retry At" := BaseDT + (i * 1000);
            EntriaOrderImpFailure.Suppressed := false;
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
                StrSubstNo('The %1. latest due row must be excluded by the 20-row cap.', i));
    end;

    [Test]
    procedure SalesOrderIntegrationFlagGatesTheOrderImport()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // [SCENARIO] The order import job only ever looks at stores that are BOTH Enabled and flagged
        // for "Sales Order Integration"

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
        // HasEnabledSalesOrderIntegrationStore only gates SetupJobQueues, so it cannot cover this.

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
        // non-blank store code AND that store Enabled. All four corners are pinned here because
        // nothing else in the suite calls it at all.
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

        // BC's per-test rollback restores the setup RECORD, but not the SingleInstance codeunit's
        // cached copy of it - left as it is here, every later test in the run would read a cached
        // "integration off". So the switch is restored and the cache invalidated explicitly.
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
        EntriaStore.Delete(true);

        // [THEN] The store's registry row is gone too
        _Assert.IsFalse(EntriaOrderImpFailure.Get(StoreCode, 'medusa-delrel'), 'Deleting the store must delete its Order Imp. Failure registry row too.');
    end;

    [Test]
    procedure FailuresPageActionsMarkForImportSuppressUnsuppress()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EntriaOrderImpFailuresPage: TestPage "NPR Entria Order Imp. Failures";
        OrderUpdatedAt: DateTime;
        BeforeInvokeDT: DateTime;
    begin
        // [SCENARIO] The failures list page's Mark for Import / Suppress / Unsuppress actions must
        // write through Rec.Modify exactly as documented on the page.

        // [GIVEN] An enabled Entria store and an order timestamped 10:00 on 5 February 2024
        Initialize();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(5, 2, 2024), 100000T);

        // [GIVEN] Enough failures for that order to park its registry row at MaxRetries()
        _LibraryEntria.ParkOrderAtMaxRetries(_StoreCode, 'ZZ-DOC-PAGEACT', 'medusa-pageact', OrderUpdatedAt);

        // [GIVEN] The row is also Suppressed, so clearing Suppressed is an observable change rather
        //         than a value it already carried, and the parked row's Next Retry At is the 0DT sentinel
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        EntriaOrderImpFailure.Suppressed := true;
        EntriaOrderImpFailure.Modify();
        _Assert.AreEqual(0DT, EntriaOrderImpFailure."Next Retry At", 'Setup: a parked row carries the 0DT sentinel, so any real reschedule is observable.');

        // [GIVEN] A timestamp taken just before the invoke, less the few milliseconds a SQL datetime
        //         read-back can lose on its 1/300s grid
        BeforeInvokeDT := CurrentDateTime() - 10;

        // [WHEN] "Mark for Import" is invoked on that row from the failures list page
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.MarkForImport.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] Retry Count is reset to 0, an immediate retry is scheduled and Suppressed is cleared
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        _Assert.AreEqual(0, EntriaOrderImpFailure."Retry Count", 'Mark for Import must reset Retry Count to 0.');
        _Assert.AreNotEqual(0DT, EntriaOrderImpFailure."Next Retry At",
            'Mark for Import must write a real Next Retry At - left at the 0DT sentinel the row stays parked and the retry pass never picks it up, so the action would silently do nothing.');
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" >= BeforeInvokeDT,
            'Mark for Import must schedule the retry as of now - an older timestamp means the action wrote something other than the current time.');
        _Assert.IsTrue(EntriaOrderImpFailure."Next Retry At" <= CurrentDateTime(), 'Mark for Import must schedule an immediate retry.');
        _Assert.IsFalse(EntriaOrderImpFailure.Suppressed, 'Mark for Import must clear Suppressed - a row left Suppressed is still excluded from the retry pass.');

        // [WHEN] "Suppress" is invoked on the same row
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.Suppress.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] Suppressed is set to true
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        _Assert.IsTrue(EntriaOrderImpFailure.Suppressed, 'Suppress must set Suppressed to true.');

        // [WHEN] "Unsuppress" is invoked on the same row
        EntriaOrderImpFailuresPage.OpenEdit();
        EntriaOrderImpFailuresPage.GoToRecord(EntriaOrderImpFailure);
        EntriaOrderImpFailuresPage.Unsuppress.Invoke();
        EntriaOrderImpFailuresPage.Close();

        // [THEN] Suppressed is cleared again
        EntriaOrderImpFailure.Get(_StoreCode, 'medusa-pageact');
        _Assert.IsFalse(EntriaOrderImpFailure.Suppressed, 'Unsuppress must clear Suppressed.');
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
        // [SCENARIO] Third shape: "payment_collections" is present as an EMPTY array, so the loop over the
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
        EntriaStore.Delete(true);

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
        // [SCENARIO] UpdateSessionMaxCreatedAt keeps the MAXIMUM created_at of the page, never the last
        // one it happened to read. Entria lists by created_at, but the marker must not depend on that
        // ordering: taking the last order instead rewinds the marker whenever a page ends on an earlier
        // order, and the store then re-lists the same window every cycle.

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
        _Assert.AreEqual(LaterCreatedAt, EntriaJQ.GetSessionMaxCreatedAt(_StoreCode),
            'The session max must end up at the page''s highest created_at - keeping the last order read instead moves the marker back a day and the store re-lists and re-skips that window on every cycle.');
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
        // [SCENARIO] TryFlushMarker's one-second tolerance, in both directions: SQL's 1/300s datetime
        // grid can hand a marker back a few milliseconds below what was written, and counting that as an
        // administrator's rewind would abandon pagination after every page - while a gap of a full
        // second or more is a real external edit and must stop paging.

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
        JobQueueEntry: Record "Job Queue Entry";
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

        // [GIVEN] However many import jobs the tenant already runs, counted up front. The assertion below
        //         is about the delta this test causes - the environment may legitimately have one configured,
        //         and a test must never claim a tenant-wide absence it does not own.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Entria Order Import JQ");
        ImportJobsBefore := JobQueueEntry.Count();

        // [WHEN] Enabled is validated to true
        asserterror EntriaStore.Validate(Enabled, true);

        // [THEN] The missing url is what stopped it
        _Assert.ExpectedError('must have a value');

        // [THEN] Enabled stays false in the database
        EntriaStore.Get(StoreCode);
        _Assert.IsFalse(EntriaStore.Enabled,
            'A store with no Entria Url must stay disabled - enabled, the import job queries a backend the store has no address for and every cycle fails on it.');

        // [THEN] The refusal came before the job queue setup, so it added no import job of its own
        _Assert.AreEqual(ImportJobsBefore, JobQueueEntry.Count(),
            'The url check must fire before SetupJobQueues - a store whose enabling was refused must not leave a live recurring import job running behind it.');
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
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        OrdersArr: JsonArray;
        OrderTkn: JsonToken;
    begin
        EntriaStore.Get(_StoreCode);
        _LibraryEntria.BuildOrderArrayForItemLine(OrdersArr, DocumentNo, MedusaOrderId, CreatedAt, CurrencyCode, ItemObj, PaymentAmount);
        OrdersArr.Get(0, OrderTkn);
        EntriaOrderImpl.ImportOrder(OrderTkn, EntriaStore, DocumentNo, EcomSalesHeader);
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
        EntriaStore: Record "NPR Entria Store";
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
    begin
        // Per test, not once per run: the production code under test commits, so BC's per-test
        // rollback does not undo its writes and leftover state would otherwise flow from one test
        // into the next - a marker a later test committed would silently break an earlier one's
        // assertions depending on declaration order.
        EntriaOrderImpFailure.SetRange("Store Code", _StoreCodeLbl);
        EntriaOrderImpFailure.DeleteAll();
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCodeLbl);
        EcomSalesHeader.DeleteAll(true);
        EntriaStoreSyncState.SetRange("Store Code", _StoreCodeLbl);
        EntriaStoreSyncState.DeleteAll();

        EntriaStore.SetFilter(Code, 'ZZ-ENT-*');
        if not EntriaStore.IsEmpty() then
            EntriaStore.DeleteAll(true);

        if not _Initialized then begin
            _Initialized := true;
            _LibraryEntria.EnsureSetupExists();
        end;
        _StoreCode := _StoreCodeLbl;
    end;

}
#endif