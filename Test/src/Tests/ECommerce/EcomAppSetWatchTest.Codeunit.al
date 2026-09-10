#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85393 "NPR EcomAppSetWatchTest"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        Initialize();
    end;

    /// <summary>
    /// Runs at the top of every test, not just once per codeunit. OnRun fires once for the whole
    /// codeunit, and this is SingleInstance state that test isolation does not roll back, so without a
    /// per-test reset the tests leak into each other: a control test that lets the watch take a real
    /// baseline leaves _BaselineTaken set, and a unit test leaves a fake baseline in _BaselineApps.
    /// Combined, the next test to call ApplicationChanged() compares the real app set against a fake
    /// baseline, latches _Changed, and every later ecommerce and Entria suite in the session then
    /// exits its loops before touching a record.
    /// </summary>
    local procedure Initialize()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
    begin
        EcomAppSetWatch.ResetForTest();
    end;

    var
        _Assert: Codeunit Assert;
        _LibraryEntria: Codeunit "NPR Library - Entria";
        _StoreCodeLbl: Label 'NPRENT-GUARD', Locked = true;
        _SpfyStoreCodeLbl: Label 'NPRSPFY-GUARD', Locked = true;

    [Test]
    procedure UnchangedAppSet_IsNotReportedAsChanged()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();
        // [SCENARIO] Nothing was published, so a steady loop must not exit.
        // [GIVEN] Two identical readings of the installed app set
        AddApp(Baseline, BaselineNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Baseline, BaselineNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');
        AddApp(Current, CurrentNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Current, CurrentNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');

        // [WHEN] The readings are compared. Captured and reset before asserting: SetBaselineForTest latches
        //        _BaselineTaken, and a failing assert would otherwise leave that fake baseline in force for
        //        every later suite in the session - Initialize() guards entry to this codeunit, not exit.
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] No change is reported
        _Assert.IsFalse(Differs, 'An unchanged app set must not be reported as changed.');
        _Assert.AreEqual('', ChangeDetail, 'No detail should be produced when nothing changed.');
    end;

    [Test]
    procedure UpgradedApp_IsReportedAlthoughCountIsUnchanged()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();
        // [SCENARIO] An app was upgraded. This is the case a count-based detector misses, and the one
        // that was actually observed poisoning documents.
        // [GIVEN] The same apps, one of them on a new package id
        AddApp(Baseline, BaselineNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Baseline, BaselineNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');
        AddApp(Current, CurrentNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Current, CurrentNames, KopKandeAppId(), PackageC(), 'KopKande-Saas');

        // [WHEN] The readings are compared
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] The change is reported and the detail names the app, not just a package id
        _Assert.IsTrue(Differs, 'An upgrade at an unchanged app count must be reported as changed.');
        _Assert.IsTrue(ChangeDetail.Contains('KopKande-Saas'), 'The reported detail must name the changed app. Actual: ' + ChangeDetail);
    end;

    [Test]
    procedure InstalledApp_IsReportedAsChanged()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();
        // [SCENARIO] A new extension was installed alongside the running session.
        // [GIVEN] A reading with one app more than the baseline
        AddApp(Baseline, BaselineNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Current, CurrentNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Current, CurrentNames, Sport24AppId(), PackageC(), 'Sport24');

        // [WHEN] The readings are compared
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] The change is reported and names the new app
        _Assert.IsTrue(Differs, 'An installed app must be reported as changed.');
        _Assert.IsTrue(ChangeDetail.Contains('Sport24'), 'The reported detail must name the installed app. Actual: ' + ChangeDetail);
    end;

    [Test]
    procedure UninstalledApp_IsReportedAndNamedFromTheBaseline()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();
        // [SCENARIO] An extension was uninstalled. An upgrade passes through this state - the observed
        // sequence was REMOVED then CHANGED - so it must be detected in its own right. The name can
        // only come from the baseline, because the app is no longer in the current reading.
        // [GIVEN] A reading with one app fewer than the baseline
        AddApp(Baseline, BaselineNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Baseline, BaselineNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');
        AddApp(Current, CurrentNames, RetailAppId(), PackageA(), 'NP Retail');

        // [WHEN] The readings are compared
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] The change is reported and still names the removed app
        _Assert.IsTrue(Differs, 'An uninstalled app must be reported as changed.');
        _Assert.IsTrue(ChangeDetail.Contains('KopKande-Saas'), 'The reported detail must name the uninstalled app, taken from the baseline. Actual: ' + ChangeDetail);
    end;

    [Test]
    procedure RenamedApp_IsOneChangeNotAnUninstallPlusInstall()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();
        // [SCENARIO] An app was renamed as part of an upgrade. Identity is the App ID, so this is one
        // upgraded app. Keying the comparison on the name would report it as two separate changes.
        // [GIVEN] The same App ID under a new name and a new package id
        AddApp(Baseline, BaselineNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');
        AddApp(Current, CurrentNames, KopKandeAppId(), PackageC(), 'KopKande Cloud');

        // [WHEN] The readings are compared
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] It reads as one upgraded app, named from the current reading rather than the baseline
        _Assert.IsTrue(Differs, 'A renamed and upgraded app must be reported as changed.');
        _Assert.IsTrue(ChangeDetail.Contains('KopKande Cloud'), 'A renamed app must be named from the current reading, not from the baseline. Actual: ' + ChangeDetail);
        _Assert.IsTrue(ChangeDetail.StartsWith('1 change(s)'), 'This is one upgraded app. Keying the comparison on the name would report it as an uninstall plus an install, which the count would show as two. Actual: ' + ChangeDetail);
    end;

    local procedure AddApp(var Apps: Dictionary of [Guid, Guid]; var Names: Dictionary of [Guid, Text]; AppId: Guid; PackageId: Guid; AppName: Text)
    begin
        Apps.Add(AppId, PackageId);
        Names.Add(AppId, AppName);
    end;

    local procedure RetailAppId(): Guid
    begin
        exit(AsGuid('992c2309-cca4-43cb-9e41-911f482ec088'));
    end;

    local procedure KopKandeAppId(): Guid
    begin
        exit(AsGuid('fafc1111-2222-3333-4444-555566667777'));
    end;

    local procedure Sport24AppId(): Guid
    begin
        exit(AsGuid('ef98fece-1111-2222-3333-444455556666'));
    end;

    local procedure PackageA(): Guid
    begin
        exit(AsGuid('aaaaaaaa-0000-0000-0000-000000000001'));
    end;

    local procedure PackageB(): Guid
    begin
        exit(AsGuid('bbbbbbbb-0000-0000-0000-000000000002'));
    end;

    local procedure PackageC(): Guid
    begin
        exit(AsGuid('cccccccc-0000-0000-0000-000000000003'));
    end;

    local procedure AsGuid(GuidText: Text) Result: Guid
    begin
        Evaluate(Result, GuidText);
    end;

    [Test]
    procedure MultipleChanges_AreAllReportedNotJustTheFirst()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        Current: Dictionary of [Guid, Guid];
        CurrentNames: Dictionary of [Guid, Text];
        ChangeDetail: Text;
        Differs: Boolean;
    begin
        Initialize();

        // [SCENARIO] A deployment moves more than one app at once. Dictionary.Keys() has no defined order,
        // so reporting only the first difference names an arbitrary one of them.

        // [GIVEN] One app upgraded and one gone, in the same reading
        AddApp(Baseline, BaselineNames, RetailAppId(), PackageA(), 'NP Retail');
        AddApp(Baseline, BaselineNames, KopKandeAppId(), PackageB(), 'KopKande-Saas');
        AddApp(Current, CurrentNames, RetailAppId(), PackageC(), 'NP Retail');

        // [WHEN] The readings are compared
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);
        Differs := EcomAppSetWatch.DiffersFromBaseline(Current, CurrentNames, ChangeDetail);
        EcomAppSetWatch.ResetForTest();

        // [THEN] Both differences are counted and both apps are named
        _Assert.IsTrue(Differs, 'Two differences must be reported as changed.');
        _Assert.IsTrue(ChangeDetail.StartsWith('2 change(s)'), 'Every difference must be counted, not just the first one found. Actual: ' + ChangeDetail);
        _Assert.IsTrue(ChangeDetail.Contains('NP Retail'), 'The upgraded app must be named. Actual: ' + ChangeDetail);
        _Assert.IsTrue(ChangeDetail.Contains('KopKande-Saas'), 'The app that is gone must be named. Actual: ' + ChangeDetail);
    end;

    [Test]
    procedure ApplicationChanged_BaselineDiffersFromLiveSet_LatchesTrue()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        Baseline: Dictionary of [Guid, Guid];
        BaselineNames: Dictionary of [Guid, Text];
        FirstAsk: Boolean;
        SecondAsk: Boolean;
    begin
        Initialize();

        // [SCENARIO] The entry point itself, not just the comparison helper. Without this the suite passes
        // against a permanently dead watch: the unit tests call DiffersFromBaseline directly, the guarded
        // tests short-circuit on SetChangedForTest, and the controls expect false - which a watch that
        // never fires also returns.

        // [GIVEN] A baseline that cannot describe this tenant - one app that is certainly not installed
        AddApp(Baseline, BaselineNames, Sport24AppId(), PackageA(), 'Sport24');
        EcomAppSetWatch.SetBaselineForTest(Baseline, BaselineNames);

        // [WHEN] The watch reads the live app set and compares it against that baseline, twice. Both answers
        //        are captured and the latch cleared before asserting: this test ends with _Changed set, and
        //        a failing assert would carry that into every later suite in the session.
        FirstAsk := EcomAppSetWatch.ApplicationChanged();
        SecondAsk := EcomAppSetWatch.ApplicationChanged();
        EcomAppSetWatch.ResetForTest();

        // [THEN] It reports a change
        _Assert.IsTrue(FirstAsk, 'A baseline that does not describe the installed app set must be reported as changed - if this is false the watch never fires at all.');

        // [THEN] And it stays latched, because the session stays stale for the rest of its life
        _Assert.IsTrue(SecondAsk, 'Once a change is seen the answer must not go back to false.');
    end;

    [Test]
    procedure ApplicationChanged_BaselineFromTheLiveSet_StaysFalse()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        FirstAsk: Boolean;
        SecondAsk: Boolean;
    begin
        Initialize();

        // [SCENARIO] The control for the case above. The first call takes the live app set as its baseline,
        // so the second compares that set against itself. Paired with the positive case this shows the diff
        // branch is both live and discriminating, rather than stuck on one answer.

        // [GIVEN] A watch that has just taken its baseline from the live app set
        // [WHEN] It reads again with nothing published in between
        FirstAsk := EcomAppSetWatch.ApplicationChanged();
        SecondAsk := EcomAppSetWatch.ApplicationChanged();
        EcomAppSetWatch.ResetForTest();

        // [THEN] Neither ask reports a change
        _Assert.IsFalse(FirstAsk, 'The first call only establishes the baseline, so it must report no change.');
        _Assert.IsFalse(SecondAsk, 'An app set compared against itself must not be reported as changed.');
    end;

    #region Entria - the page in flight
    [Test]
    procedure Entria_ChangedAppSet_PageIsNotWalkedAndSessionMaxStaysPut()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
        WindowStart: DateTime;
        SessionMaxAfter: DateTime;
        RowExists: Boolean;
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] An extension changed while the session was part way through a page. The orders left
        // in that page must not be charged, and the session max must not claim them - it is what
        // TryFlushMarker would promote into the store marker.

        // [GIVEN] An enabled Entria store and a page holding one order that cannot import
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        EntriaStore.Get(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(4, 3, 2024), 100000T);
        EntriaJQ.SeedSessionMax(_StoreCodeLbl);
        WindowStart := EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCodeLbl);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-GUARD-A', 'medusa-guard-a', OrderUpdatedAt, OrderUpdatedAt, 100);

        // [WHEN] The app set is already known to have changed and ProcessList runs over that page
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TryEntriaProcessList(EntriaJQ, OrdersArr, EntriaStore);
        SessionMaxAfter := EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCodeLbl);
        RowExists := EntriaOrderImpFailure.Get(_StoreCodeLbl, 'medusa-guard-a');
        EcomAppSetWatch.ResetForTest();

        // [THEN] Nothing was raised. Asserted because the wrapper swallows errors, so without this the
        //        remaining assertions could hold on a crash rather than on a working guard.
        _Assert.IsTrue(GuardHeld, 'A guarded page walk must return cleanly.');

        // [THEN] The order is not charged
        _Assert.IsFalse(RowExists, 'An order the guard skipped must not be charged a failure - the platform error belongs to the stale session, not to the order.');

        // [THEN] The session max still describes only what the pass really consumed
        _Assert.AreEqual(WindowStart, SessionMaxAfter, 'The session max must not advance past an order that was never walked - TryFlushMarker promotes it into the store marker, so an inflated max loses the skipped orders.');
    end;

    [Test]
    procedure Entria_UnchangedAppSet_PageIsWalkedAndSessionMaxAdvances()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        OrderUpdatedAt: DateTime;
    begin
        Initialize();
        // [SCENARIO] The control for the case above. Same fixture, nothing changed, so the page must be
        // walked in full - otherwise the assertions above would hold for a fixture that imports nothing.

        // [GIVEN] An enabled Entria store, a clear latch and the same unimportable order
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        EntriaStore.Get(_StoreCodeLbl);
        OrderUpdatedAt := CreateDateTime(DMY2Date(4, 3, 2024), 100000T);
        EntriaJQ.SeedSessionMax(_StoreCodeLbl);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-GUARD-B', 'medusa-guard-b', OrderUpdatedAt, OrderUpdatedAt, 100);

        // [WHEN] ProcessList runs over that page
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);

        // [THEN] The order is charged and the session max advances to it
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCodeLbl, 'medusa-guard-b'), 'Without a change to guard against, the page must be walked and the failing order recorded - if it is not, the guarded case proves nothing.');
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCodeLbl), 'Without a change to guard against, the session max must advance to the order''s bc_status_updated_at.');
    end;
    #endregion

    #region Entria - the store loop and the marker row
    [Test]
    procedure Entria_ChangedAppSet_StoreLoopWritesNoSyncStateRow()
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        RowExists: Boolean;
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] The store loop leaves before it touches the store's marker at all. GetSyncStateMarker
        // is the first thing DownloadOrders does and it inserts the sync-state row when none exists, so
        // the absence of that row is the observable proof that the store was never entered.

        // [GIVEN] An enabled Entria store with no sync-state row
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        _Assert.IsFalse(EntriaStoreSyncState.Get(_StoreCodeLbl), 'Setup: the store must start without a sync-state row, otherwise this test cannot tell whether the loop was entered.');

        // [WHEN] The app set is already known to have changed and the store loop runs
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TryEntriaProcessEnabledStores(EntriaJQ);
        RowExists := EntriaStoreSyncState.Get(_StoreCodeLbl);
        EcomAppSetWatch.ResetForTest();

        // [THEN] Nothing was raised. Asserted first because the wrapper swallows errors, and an absent row
        //        proves nothing if the loop crashed before it could create one.
        _Assert.IsTrue(GuardHeld, 'A guarded store loop must return cleanly.');

        // [THEN] The store was never entered, so no marker row was created
        _Assert.IsFalse(RowExists, 'A guarded store loop must leave before ProcessStore, so no sync-state row is created and no Medusa request is issued.');
    end;

    [Test]
    procedure Entria_UnchangedAppSet_StoreLoopWritesTheSyncStateRow()
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        Initialize();
        // [SCENARIO] The control for the case above. With a clear latch the store IS entered, and the row
        // appears - GetSyncStateMarker creates it before the first Medusa call, so this holds in a sandbox
        // where that call cannot succeed. Without this pair the case above would pass on a tenant where
        // the store is not enabled at all.

        // [GIVEN] The same enabled store with no sync-state row, and a clear latch
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        _Assert.IsFalse(EntriaStoreSyncState.Get(_StoreCodeLbl), 'Setup: the store must start without a sync-state row.');

        // [WHEN] The store loop runs
        EntriaJQ.ProcessEnabledStores();

        // [THEN] The store was entered
        _Assert.IsTrue(EntriaStoreSyncState.Get(_StoreCodeLbl), 'Without a change to guard against, the store must be entered and its sync-state row created - if it is not, the guarded case proves nothing.');
    end;

    [Test]
    procedure Entria_ChangedAppSet_StoredMarkerIsNotMoved()
    var
        EntriaStore: Record "NPR Entria Store";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        OrdersArr: JsonArray;
        MarkerBefore: DateTime;
        MarkerAfter: DateTime;
        SessionMaxAfter: DateTime;
        ExpectedMarkerDT: DateTime;
        OrderUpdatedAt: DateTime;
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] The one that matters for data loss: a session that stops part way through a page
        // must leave the stored marker exactly where it was, so the next pass re-reads the same window.
        // The orders it re-reads are skipped by the ExistingDocs check, which is the accepted cost.

        // [GIVEN] An enabled Entria store whose marker stands at 1 March 2024
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        EntriaStore.Get(_StoreCodeLbl);
        MarkerBefore := CreateDateTime(DMY2Date(1, 3, 2024), 100000T);
        EntriaStore.SetLastOrdersImportedAt(_StoreCodeLbl, MarkerBefore);
        _Assert.AreEqual(MarkerBefore, EntriaJQ.GetSyncStateMarker(_StoreCodeLbl), 'Setup: the stored marker must be the value this test is about to watch.');

        // [GIVEN] A pass that has already consumed one order, so the session max stands ahead of the marker
        OrderUpdatedAt := CreateDateTime(DMY2Date(2, 3, 2024), 100000T);
        EntriaJQ.SeedSessionMax(_StoreCodeLbl);
        _LibraryEntria.BuildOrderArrayWithNoPaymentLines(OrdersArr, 'ZZ-GUARD-M', 'medusa-guard-m', OrderUpdatedAt, OrderUpdatedAt, 100);
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCodeLbl), 'Setup: the session max must stand ahead of the stored marker, or the flush this test blocks would be a no-op anyway.');

        // [WHEN] The app set changes and the store loop runs, which is where the flush would have happened
        ExpectedMarkerDT := MarkerBefore;
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TryEntriaProcessEnabledStores(EntriaJQ);
        MarkerAfter := EntriaJQ.GetSyncStateMarker(_StoreCodeLbl);
        SessionMaxAfter := EntriaJQ.GetSessionMaxBcStatusUpdatedAt(_StoreCodeLbl);
        EcomAppSetWatch.ResetForTest();

        // [THEN] Nothing was raised. Asserted because the wrapper swallows errors, and an unmoved marker
        //        proves nothing if the loop crashed before it could move one.
        _Assert.IsTrue(GuardHeld, 'A guarded store loop must return cleanly.');

        // [THEN] The store was never entered. This is the assertion that pins the guard: without it
        //        DownloadOrders reseeds the session max to PassWindowStart(marker) as its third statement,
        //        long before anything can fail, so a regression is visible here and nowhere else.
        _Assert.AreEqual(OrderUpdatedAt, SessionMaxAfter, 'A guarded store loop must not reach DownloadOrders, which reseeds the session max from the stored marker before it fetches anything.');

        // [THEN] The marker has not moved. On its own this would be weak - a blocked HTTP call leaves the
        //        marker at MarkerBefore too - but paired with the assertion above it says the marker
        //        survived because the loop never started, not because the fetch happened to fail.
        _Assert.AreEqual(MarkerBefore, MarkerAfter, 'A guard trip must advance no marker. Moving it would mark the un-walked orders as consumed and no pass would ever fetch them again.');

        // [THEN] And the flush itself, called directly, still works - the guard is the loop''s business,
        //        not a change to the marker primitive every other caller relies on
        _Assert.IsTrue(EntriaJQ.TryFlushMarker(_StoreCodeLbl, ExpectedMarkerDT), 'TryFlushMarker must keep its single meaning: the guard sits at its call site, not inside it, because the Entria suite calls it directly.');
        _Assert.AreEqual(OrderUpdatedAt, EntriaJQ.GetSyncStateMarker(_StoreCodeLbl), 'Called directly with a clear latch, the flush must still promote the session max - otherwise the test above passed because flushing is broken, not because the guard works.');
    end;
    #endregion

    #region Entria - the retry pass
    [Test]
    procedure Entria_ChangedAppSet_DueRetryIsNotCharged()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
        RetryCountAfter: Integer;
        RowExists: Boolean;
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] The retry pass burns a retry of ten every time it touches a row. A stale session must
        // not spend one on a failure that has nothing to do with the order.

        // [GIVEN] An enabled Entria store and a registry row that is due for retry
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        EntriaStore.Get(_StoreCodeLbl);
        _LibraryEntria.InsertOrderFailureRow(_StoreCodeLbl, 'medusa-guard-r', 0, CurrentDateTime() - 60000);

        // [WHEN] The app set is already known to have changed and the retry pass runs
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TryEntriaProcessDueRetries(EntriaJQ, EntriaStore);
        RowExists := EntriaOrderImpFailure.Get(_StoreCodeLbl, 'medusa-guard-r');
        if RowExists then
            RetryCountAfter := EntriaOrderImpFailure."Retry Count";
        EcomAppSetWatch.ResetForTest();

        // [THEN] Nothing was raised. Asserted because the wrapper swallows errors, and an untouched row
        //        satisfies both assertions below on a crash just as well as on a working guard.
        _Assert.IsTrue(GuardHeld, 'A guarded retry pass must return cleanly.');

        // [THEN] The row is still there. Asserted before the count, because RetryCountAfter stays 0 when
        //        the row is gone as well as when it is untouched - and a successful retry deletes the row
        //        (DeleteOrderFailure), so without this the count assertion passes on that regression too.
        _Assert.IsTrue(RowExists, 'A guarded retry pass must leave the registry row alone, not process it away.');

        // [THEN] The row keeps its full retry budget
        _Assert.AreEqual(0, RetryCountAfter, 'A guarded retry pass must not spend a retry. Ten of these and the row is abandoned for a reason that was never the order''s fault.');
    end;

    [Test]
    procedure Entria_UnchangedAppSet_DueRetryIsCharged()
    var
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        EntriaJQ: Codeunit "NPR Entria Order Import JQ";
    begin
        Initialize();
        // [SCENARIO] The control for the case above: with a clear latch the same row IS charged, because
        // the single-order re-fetch cannot reach Medusa from a sandbox.

        // [GIVEN] An enabled Entria store, a clear latch and the same due registry row
        InitializeEntria();
        _LibraryEntria.EnableEntriaStore(_StoreCodeLbl);
        _LibraryEntria.DisableStoresExcept(_StoreCodeLbl);
        EntriaStore.Get(_StoreCodeLbl);
        _LibraryEntria.InsertOrderFailureRow(_StoreCodeLbl, 'medusa-guard-r2', 0, CurrentDateTime() - 60000);

        // [WHEN] The retry pass runs
        EntriaJQ.ProcessDueRetries(EntriaStore, true);

        // [THEN] The refetch failure really was charged, so the guarded case above is not vacuous. The row is
        //        asserted before its field, for the reason its guarded sibling spells out: a retry that
        //        succeeded deletes the row, and "Retry Count" then reads 0 off a blank record rather than
        //        failing with a message that says what actually happened.
        _Assert.IsTrue(EntriaOrderImpFailure.Get(_StoreCodeLbl, 'medusa-guard-r2'), 'The registry row must still exist. If it is gone the re-fetch succeeded, which this control does not expect - it relies on Medusa being unreachable from a sandbox.');
        _Assert.AreEqual(1, EntriaOrderImpFailure."Retry Count", 'Without a change to guard against, the blocked re-fetch must be logged as a retry - if it is not, the guarded case proves nothing.');
    end;
    #endregion

    #region Shopify - the marker
    [Test]
    procedure Shopify_ChangedAppSet_ImportMarkerIsNotAdvanced()
    var
        ShopifyStore: Record "NPR Spfy Store";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        MarkerBefore: DateTime;
        MarkerAfter: DateTime;
        SessionMax: DateTime;
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] Shopify writes its marker one level above the download loop - TryUpdateMarker between
        // downloads and FinalizeMarker at the end of the run. Both refuse, and FinalizeMarker is the one a test
        // can drive: TryUpdateMarker is throttled to one write every five minutes.
        // Leaving the loop is therefore not enough on its own; the write point itself has to refuse.

        // [GIVEN] A Shopify store whose orders marker stands at 1 March 2024
        MarkerBefore := CreateDateTime(DMY2Date(1, 3, 2024), 100000T);
        SessionMax := CreateDateTime(DMY2Date(2, 3, 2024), 100000T);
        InitializeShopifyStore(ShopifyStore, MarkerBefore);

        // [GIVEN] A pass whose session maximum already stands a day ahead of it
        SpfyOrderImportJQ.SetMarkers(ShopifyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order, SessionMax);

        // [WHEN] The app set is already known to have changed and the marker write is attempted
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TrySpfyFinalizeMarker(SpfyOrderImportJQ, ShopifyStore);
        MarkerAfter := LastOrdersImportedAt(ShopifyStore.Code);
        EcomAppSetWatch.ResetForTest();

        // [THEN] Nothing was raised. Asserted because the wrapper swallows errors, and an unmoved marker
        //        proves nothing if the writer crashed before it could move one.
        _Assert.IsTrue(GuardHeld, 'A guarded marker write must return cleanly.');

        // [THEN] The marker has not moved
        _Assert.AreEqual(MarkerBefore, MarkerAfter, 'A session that stopped paging part way through no longer has a session max that describes a window it finished importing, so it must write no marker at all.');
    end;

    [Test]
    procedure Shopify_UnchangedAppSet_ImportMarkerIsAdvanced()
    var
        ShopifyStore: Record "NPR Spfy Store";
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        MarkerBefore: DateTime;
        SessionMax: DateTime;
    begin
        Initialize();
        // [SCENARIO] The control for the case above. Same fixture, clear latch, so the marker MUST move -
        // otherwise the assertion above would hold for a store whose marker cannot be written at all.

        // [GIVEN] The same store and session maximum, with a clear latch
        MarkerBefore := CreateDateTime(DMY2Date(1, 3, 2024), 100000T);
        SessionMax := CreateDateTime(DMY2Date(2, 3, 2024), 100000T);
        InitializeShopifyStore(ShopifyStore, MarkerBefore);
        SpfyOrderImportJQ.SetMarkers(ShopifyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order, SessionMax);

        // [WHEN] The marker write is attempted
        SpfyOrderImportJQ.FinalizeMarker(ShopifyStore, "NPR SpfyEventLogDocType"::Order);

        // [THEN] The marker advances to the session maximum
        _Assert.AreEqual(SessionMax, LastOrdersImportedAt(ShopifyStore.Code), 'Without a change to guard against, the marker must advance to the session maximum - if it does not, the guarded case proves nothing.');
    end;

    [Test]
    procedure Shopify_ChangedAppSet_StoreLoopIsNotEntered()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]];
        AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean];
        GuardHeld: Boolean;
    begin
        Initialize();

        // [SCENARIO] The outermost Shopify guard. The observable is deliberately NOT the marker: with the
        // download blocked in a sandbox, LogError sets ErrorsSinceLastMarker and the marker stays put
        // whether the guard fires or not, so a marker assertion here would pass for the wrong reason. The
        // dictionary instead names a store that does not exist, and Process reaches ShopifyStore.Get one
        // statement after the guard. Reaching it is an error; not reaching it is the guard working.

        // [GIVEN] A store list naming a store code that has no record
        AreaEnabled.Set("NPR SpfyEventLogDocType"::Order, true);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::"Return Order", false);
        StoresDict.Add('NPRSPFY-NOSUCH', AreaEnabled);

        // [WHEN] The app set is already known to have changed and the store loop runs
        EcomAppSetWatch.SetChangedForTest();
        GuardHeld := TrySpfyProcess(SpfyOrderImportJQ, StoresDict);
        EcomAppSetWatch.ResetForTest();

        // [THEN] It returned without touching the store. The wrapper exists so the reset above survives a
        //        failure, but it also swallows the error, so the result has to be asserted - otherwise a
        //        regressed guard raises DB:RecordNotFound, the wrapper eats it, and this test passes with
        //        nothing checked at all.
        _Assert.IsTrue(GuardHeld, 'A guarded store loop must return before ShopifyStore.Get, so nothing may be raised - the Get one statement below the guard would have failed on the missing record.');
    end;

    [Test]
    procedure Shopify_UnchangedAppSet_StoreLoopIsEntered()
    var
        EcomAppSetWatch: Codeunit "NPR Ecom App Set Watch";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]];
        AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean];
    begin
        Initialize();
        // [SCENARIO] The control for the case above: with a clear latch the same call DOES reach
        // ShopifyStore.Get and fails on the missing record. Without this, the case above would pass on a
        // Process that had been emptied out entirely.

        // [GIVEN] The same store list naming a store code that has no record, and a clear latch
        AreaEnabled.Set("NPR SpfyEventLogDocType"::Order, true);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::"Return Order", false);
        StoresDict.Add('NPRSPFY-NOSUCH', AreaEnabled);

        // [WHEN] The store loop runs
        asserterror SpfyOrderImportJQ.Process(StoresDict);

        // [THEN] It got as far as reading the store
        _Assert.ExpectedErrorCode('DB:RecordNotFound');
    end;
    #endregion

    // AL has no try/finally, and the calls these wrap raise exactly when the guard under test regresses.
    // Without the wrapper the ResetForTest() that follows would be skipped on that failure and _Changed
    // would stay latched in the SingleInstance watch for the rest of the test session, silencing every
    // later suite that runs a guarded loop.
    //
    // The job queue codeunit comes in by reference and is never declared here. Neither JQ is
    // SingleInstance, so a local declaration would be a second instance: the production call would run
    // against it while the caller asserted against its own, and every assertion that reads job queue
    // state - the session maxima, which live in codeunit globals - would compare a value with itself.
    [TryFunction]
    local procedure TryEntriaProcessList(var EntriaJQ: Codeunit "NPR Entria Order Import JQ"; OrdersArr: JsonArray; EntriaStore: Record "NPR Entria Store")
    begin
        EntriaJQ.ProcessList(OrdersArr, EntriaStore);
    end;

    [TryFunction]
    local procedure TryEntriaProcessEnabledStores(var EntriaJQ: Codeunit "NPR Entria Order Import JQ")
    begin
        EntriaJQ.ProcessEnabledStores();
    end;

    [TryFunction]
    local procedure TryEntriaProcessDueRetries(var EntriaJQ: Codeunit "NPR Entria Order Import JQ"; EntriaStore: Record "NPR Entria Store")
    begin
        EntriaJQ.ProcessDueRetries(EntriaStore, true);
    end;

    [TryFunction]
    local procedure TrySpfyFinalizeMarker(var SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ"; ShopifyStore: Record "NPR Spfy Store")
    begin
        SpfyOrderImportJQ.FinalizeMarker(ShopifyStore, "NPR SpfyEventLogDocType"::Order);
    end;

    [TryFunction]
    local procedure TrySpfyProcess(var SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ"; StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]])
    begin
        SpfyOrderImportJQ.Process(StoresDict);
    end;

    local procedure InitializeEntria()
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
    begin
        // Per test, not once per run: TestIsolation = Codeunit rolls back at the END of the codeunit, so
        // everything an earlier test wrote is still there for the next one. Same reasoning as the existing
        // Entria suite - only this store code is swept, so nothing else in the session is disturbed.
        EntriaOrderImpFailure.SetRange("Store Code", _StoreCodeLbl);
        EntriaOrderImpFailure.DeleteAll();
        EcomSalesHeader.SetRange("Ecommerce Store Code", _StoreCodeLbl);
        EcomSalesHeader.DeleteAll(true);
        EntriaStoreSyncState.SetRange("Store Code", _StoreCodeLbl);
        EntriaStoreSyncState.DeleteAll();
        EntriaIntegrationMgt.SetRereadSetup();
    end;

    local procedure InitializeShopifyStore(var ShopifyStore: Record "NPR Spfy Store"; MarkerDT: DateTime)
    begin
        // Direct field values only - nothing here needs the store's validation triggers, and the import
        // marker lives on the sync pointer rather than on the store row.
        if not ShopifyStore.Get(_SpfyStoreCodeLbl) then begin
            ShopifyStore.Init();
            ShopifyStore.Code := _SpfyStoreCodeLbl;
            ShopifyStore.Insert();
        end;
        ShopifyStore.SetLastOrdersImportedAt(MarkerDT);

        // Re-read with the FlowField calculated: SetMarkers seeds the pass window from the record it is
        // handed, so an uncalculated one would start the pass from a blank marker instead of this one.
        ShopifyStore.SetAutoCalcFields("Last Orders Imported At (FF)");
        ShopifyStore.Get(_SpfyStoreCodeLbl);
    end;

    local procedure LastOrdersImportedAt(StoreCode: Code[20]): DateTime
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        // Read back through the FlowField rather than through the record the test still holds: the
        // production code writes the sync pointer, and a stale in-memory copy would hide that.
        ShopifyStore.Get(StoreCode);
        ShopifyStore.CalcFields("Last Orders Imported At (FF)");
        exit(ShopifyStore."Last Orders Imported At (FF)");
    end;
}
#endif
