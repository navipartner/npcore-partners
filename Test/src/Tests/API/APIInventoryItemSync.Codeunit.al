codeunit 85630 "NPR API Inventory Item Sync"
{
    // [FEATURE] Inventory API: GET /inventory/item with sync=true merges Item rows with item change rows inside one window

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        _LibraryAPIBI: Codeunit "NPR Library - API BI";
        _ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
        _BoundarySeam: Codeunit "NPR Spfy RowVer Boundary Seam";
        _BoundarySeamBound: Boolean;
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MarkedItemIsReturnedOnceAtItsChangeRowVersion()
    var
        ItemChange: Record "NPR Inventory Item Change";
        TempBlankItemChange: Record "NPR Inventory Item Change" temporary;
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionA: BigInteger;
        ExpectedChangeCount: BigInteger;
        NoChangeRowVersion: BigInteger;
    begin
        // [SCENARIO] A1: an item marked before and after the cursor is returned once, at its change row version, although its Item row is below the cursor.
        // [GIVEN] Item A marked before the cursor, and a mark for an empty item no.
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        MarkChanged(ItemA);
        _ItemChangeMgt.AddItemNo(TempBlankItemChange, '');
        _ItemChangeMgt.MarkItemsChanged(TempBlankItemChange);
        Cursor := Database.LastUsedRowVersion();
        // [GIVEN] A marked again after the cursor
        ChangeRowVersionA := MarkChanged(ItemA);
        Commit();

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] A is returned once at its change row version, and the second mark updated its change row
        _Assert.AreEqual(1, RowVersions.Count(), 'Only item A must be returned.');
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'A must be returned at its change row version.');
        ItemChange.Get(ItemA);
        ExpectedChangeCount := 2;
        _Assert.AreEqual(ExpectedChangeCount, ItemChange."Change Count", 'The second mark must update the existing change row of A.');
        NoChangeRowVersion := 0;
        _Assert.AreEqual(NoChangeRowVersion, _ItemChangeMgt.GetChangeRowVersion(''), 'A mark for an empty item no. must not create a change row.');
        AssertChangePathGuards(ItemA, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemAndChangeRowsMergeAcrossPagesWithoutDuplicates()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        ItemC: Code[20];
        ItemP: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionA: BigInteger;
        ChangeRowVersionB: BigInteger;
        ItemRowVersionC: BigInteger;
        ItemRowVersionP: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A2: with pageSize 1 the Item and change streams merge in row version order, an Item row with a newer change row is returned only at the change row, and a full last page reports no more pages.
        // [GIVEN] Items A, B, C and P
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        ItemC := _LibraryInventory.CreateItemNo();
        ItemP := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        // [GIVEN] After the cursor: A changed, B marked, C changed, A marked
        ChangeItem(ItemA);
        ChangeRowVersionB := MarkChanged(ItemB);
        ItemRowVersionC := ChangeItem(ItemC);
        ChangeRowVersionA := MarkChanged(ItemA);
        Commit();

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);

        // [THEN] Page 1 holds B at its change row version
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemB, ChangeRowVersionB, 'Page 1 must return B at its change row version.');
        AssertChangePathGuards(ItemB, Cursor);

        // [WHEN] Page 2 follows nextPageKey
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 holds C at its Item row version
        _Assert.IsTrue(MorePages, 'Page 2 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 2 must hold one item.');
        AssertReturnedAt(RowVersions, ItemC, ItemRowVersionC, 'Page 2 must return C at its Item row version.');

        // [WHEN] Page 3 follows nextPageKey
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 3 holds A at its change row version and ends the window although it is full
        _Assert.IsFalse(MorePages, 'Page 3 must be the last page, although it holds pageSize items.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 3 must hold one item.');
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'Page 3 must return A at its change row version.');

        // [GIVEN] P changed after the window
        ItemRowVersionP := ChangeItem(ItemP);
        Commit();

        // [WHEN] The next sync starts from the rowVersion of the last item page 3 returned
        ReadSyncPage(ChangeRowVersionA, '', 0, '', RowVersions, NextPageKey);

        // [THEN] P is returned, and A, B and C are not sent again
        _Assert.AreEqual(1, RowVersions.Count(), 'The next window must hold only P.');
        AssertReturnedAt(RowVersions, ItemP, ItemRowVersionP, 'The next window must return P.');
        AssertNotReturned(RowVersions, ItemA, 'A must not be sent again in the next window.');
        AssertNotReturned(RowVersions, ItemB, 'B must not be sent again in the next window.');
        AssertNotReturned(RowVersions, ItemC, 'C must not be sent again in the next window.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RowsAboveFixedBoundaryWaitForTheNextWindow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemC: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionA: BigInteger;
        ChangeRowVersionA: BigInteger;
        ChangeRowVersionC: BigInteger;
        ItemRowVersionC: BigInteger;
    begin
        // [SCENARIO] A3: Item rows and change rows above the window boundary wait for the next window, and an Item row is deferred only by a change row inside the window.
        // [GIVEN] Items A and C; after the cursor: A changed, A marked, C marked, C changed
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemC := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionA := ChangeItem(ItemA);
        ChangeRowVersionA := MarkChanged(ItemA);
        ChangeRowVersionC := MarkChanged(ItemC);
        ItemRowVersionC := ChangeItem(ItemC);
        Commit();

        // [WHEN] Call 1 syncs from the cursor with pageSize 1 and the boundary at A's Item row
        _BoundarySeam.SetFixedBoundary(ItemRowVersionA);
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey), 'Call 1 must be the last page of its window.');

        // [THEN] A is returned at its Item row version, because its change row is above the boundary
        _Assert.AreEqual('', NextPageKey, 'Call 1 must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 1 must return only A.');
        AssertReturnedAt(RowVersions, ItemA, ItemRowVersionA, 'Call 1 must return A at its Item row version.');

        // [WHEN] Call 2 syncs from A's Item row with the boundary at C's change row
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionC);
        ReadSyncPage(ItemRowVersionA, '', 0, '', RowVersions, NextPageKey);

        // [THEN] A is returned at its change row version; C is not, because its newer Item row is above the boundary
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 2 must return only A.');
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'Call 2 must return A at its change row version.');
        AssertNotReturned(RowVersions, ItemC, 'Call 2 must not return C, whose Item row is newer than its change row and above the boundary.');

        // [WHEN] Call 3 syncs from the rowVersion of the last item call 2 returned, with the last allocated boundary
        _BoundarySeam.UseLastAllocatedBoundary();
        ReadSyncPage(ChangeRowVersionA, '', 0, '', RowVersions, NextPageKey);

        // [THEN] C is returned at its Item row version, and A is not sent again
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 3 must return only C.');
        AssertReturnedAt(RowVersions, ItemC, ItemRowVersionC, 'Call 3 must return C at its Item row version.');
        AssertNotReturned(RowVersions, ItemA, 'Call 3 must not send A again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItemRowVersionMatchesSyncWhenNewestRowIsInWindow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        ItemC: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionA: BigInteger;
        ChangeRowVersionC: BigInteger;
        ItemRowVersionC: BigInteger;
    begin
        // [SCENARIO] A4: GET /inventory/item/:id returns the same rowVersion as the sync list when the item's newest row lies inside the window.
        // [GIVEN] The cursor is taken first; then A is created and marked, B is created, and C is created, marked and changed
        Initialize();
        Cursor := Database.LastUsedRowVersion();
        ItemA := _LibraryInventory.CreateItemNo();
        ChangeRowVersionA := MarkChanged(ItemA);
        ItemB := _LibraryInventory.CreateItemNo();
        ItemC := _LibraryInventory.CreateItemNo();
        ChangeRowVersionC := MarkChanged(ItemC);
        ItemRowVersionC := ChangeItem(ItemC);
        Commit();
        _Assert.IsTrue(ChangeRowVersionA > GetItemTableRowVersion(ItemA), 'Test setup: A''s change row must be newer than its Item row.');
        _Assert.IsTrue(ChangeRowVersionC < ItemRowVersionC, 'Test setup: C''s Item row must be newer than its change row.');

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] A comes at its change row, B and C at their Item rows
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'A must be returned at its change row version.');
        AssertReturnedAt(RowVersions, ItemB, GetItemTableRowVersion(ItemB), 'B must be returned at its Item row version.');
        AssertReturnedAt(RowVersions, ItemC, ItemRowVersionC, 'C must be returned at its Item row version.');

        // [THEN] GET returns the same rowVersion for each item
        AssertGetMatchesSync(RowVersions, ItemA);
        AssertGetMatchesSync(RowVersions, ItemB);
        AssertGetMatchesSync(RowVersions, ItemC);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenameDoesNotCascadeAndOrphanChangeRowIsSkipped()
    var
        Item: Record Item;
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemNoN: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionN: BigInteger;
        ChangeRowVersionA: BigInteger;
        ItemRowVersionN: BigInteger;
    begin
        // [SCENARIO] A5: renaming an item leaves the change rows alone, the item is returned under its new no., and a change row whose item does not exist is skipped.
        // [GIVEN] Unused item nos. N and Z, item A, and change rows for N (no item) and A before the cursor
        Initialize();
        ItemNoN := GetUnusedItemNo();
        ItemNoZ := GetUnusedItemNo();
        ItemA := _LibraryInventory.CreateItemNo();
        ChangeRowVersionN := MarkChanged(ItemNoN);
        ChangeRowVersionA := MarkChanged(ItemA);
        Cursor := Database.LastUsedRowVersion();
        // [GIVEN] After the cursor: A renamed to N, and Z marked
        Item.Get(ItemA);
        Item.Rename(ItemNoN);
        MarkChanged(ItemNoZ);
        Commit();

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] The change rows of N and A were not touched by the rename
        _Assert.AreEqual(ChangeRowVersionN, _ItemChangeMgt.GetChangeRowVersion(ItemNoN), 'The rename must not touch the change row of N.');
        _Assert.AreEqual(ChangeRowVersionA, _ItemChangeMgt.GetChangeRowVersion(ItemA), 'The rename must not move the change row of A.');
        // [THEN] N is returned once at its Item row version; A and Z are not
        ItemRowVersionN := GetItemTableRowVersion(ItemNoN);
        _Assert.IsTrue(ItemRowVersionN > ChangeRowVersionN, 'Test setup: N''s Item row must be newer than its change row.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Only N must be returned.');
        AssertReturnedAt(RowVersions, ItemNoN, ItemRowVersionN, 'The renamed item must be returned under N at its Item row version.');
        AssertNotReturned(RowVersions, ItemA, 'A no longer exists and must not be returned.');
        AssertNotReturned(RowVersions, ItemNoZ, 'A change row without an item must be skipped.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemNoZ) > Cursor, 'Test setup: Z''s change row must lie in the window.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemCodeFilterAppliesToChangeRows()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionA: BigInteger;
    begin
        // [SCENARIO] A6: the itemCode filter also limits the change stream.
        // [GIVEN] Items A and B, both marked after the cursor
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ChangeRowVersionA := MarkChanged(ItemA);
        MarkChanged(ItemB);
        Commit();

        // [WHEN] The items are synced from the cursor with itemCode A
        _Assert.IsFalse(ReadSyncPage(Cursor, ItemA, 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] Only A is returned
        _Assert.AreEqual(1, RowVersions.Count(), 'Only A must be returned.');
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'A must be returned at its change row version.');
        AssertNotReturned(RowVersions, ItemB, 'B must be filtered out by itemCode.');
        AssertChangePathGuards(ItemA, Cursor);
        AssertChangePathGuards(ItemB, Cursor);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ItemRowsAfterExhaustedChangeStreamAreReturnedOnce()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemX: Code[20];
        ItemY: Code[20];
        ItemZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionX: BigInteger;
        ItemRowVersionY: BigInteger;
        ItemRowVersionZ: BigInteger;
    begin
        // [SCENARIO] A7: Item rows read after the change stream is exhausted are returned once each, and the last change row is not emitted again.
        // [GIVEN] Items X, Y and Z, with Y marked before the cursor
        Initialize();
        ItemX := _LibraryInventory.CreateItemNo();
        ItemY := _LibraryInventory.CreateItemNo();
        ItemZ := _LibraryInventory.CreateItemNo();
        MarkChanged(ItemY);
        Cursor := Database.LastUsedRowVersion();
        // [GIVEN] After the cursor: X marked, Y changed, Z changed
        ChangeRowVersionX := MarkChanged(ItemX);
        ItemRowVersionY := ChangeItem(ItemY);
        ItemRowVersionZ := ChangeItem(ItemZ);
        Commit();

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] X, Y and Z are each returned once, in row version order
        _Assert.AreEqual(3, RowVersions.Count(), 'X, Y and Z must each be returned once.');
        AssertReturnedAt(RowVersions, ItemX, ChangeRowVersionX, 'X must be returned at its change row version.');
        AssertReturnedAt(RowVersions, ItemY, ItemRowVersionY, 'Y must be returned at its Item row version.');
        AssertReturnedAt(RowVersions, ItemZ, ItemRowVersionZ, 'Z must be returned at its Item row version.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemY) <= Cursor, 'Test setup: Y''s change row must lie below the window.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WindowBoundaryIsFixedAcrossPages()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemD: Code[20];
        ItemE: Code[20];
        ItemX: Code[20];
        ItemY: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        AfterPage1: BigInteger;
        ItemRowVersionD: BigInteger;
        ChangeRowVersionE: BigInteger;
        ChangeRowVersionD: BigInteger;
        ChangeRowVersionX: BigInteger;
        ItemRowVersionY: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A10: later pages of a window reuse the boundary that page 1 read, so writes between pages wait for the next window.
        // [GIVEN] Items D, E, X and Y; after the cursor: D changed, E marked
        Initialize();
        ItemD := _LibraryInventory.CreateItemNo();
        ItemE := _LibraryInventory.CreateItemNo();
        ItemX := _LibraryInventory.CreateItemNo();
        ItemY := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionD := ChangeItem(ItemD);
        ChangeRowVersionE := MarkChanged(ItemE);
        Commit();

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);
        AfterPage1 := Database.LastUsedRowVersion();

        // [THEN] Page 1 holds D, reports more pages and read the boundary once
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreNotEqual('', NextPageKey, 'Page 1 must carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemD, ItemRowVersionD, 'Page 1 must return D at its Item row version.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'Page 1 must read the boundary once.');

        // [GIVEN] Between pages: D marked, X marked, Y changed
        ChangeRowVersionD := MarkChanged(ItemD);
        ChangeRowVersionX := MarkChanged(ItemX);
        ItemRowVersionY := ChangeItem(ItemY);
        Commit();
        _Assert.IsTrue((AfterPage1 < ChangeRowVersionD) and (ChangeRowVersionD < ChangeRowVersionX) and (ChangeRowVersionX < ItemRowVersionY), 'Test setup: the writes between pages must lie above page 1''s boundary.');

        // [WHEN] Page 2 follows nextPageKey
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 holds only E, ends the window at page 1's boundary and reads no boundary
        _Assert.IsFalse(MorePages, 'Page 2 must be the last page of the window.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 2 must hold only E.');
        AssertReturnedAt(RowVersions, ItemE, ChangeRowVersionE, 'Page 2 must return E at its change row version.');
        AssertNotReturned(RowVersions, ItemD, 'D''s new change row is above the window and must wait.');
        AssertNotReturned(RowVersions, ItemX, 'X''s change row is above the window and must wait.');
        AssertNotReturned(RowVersions, ItemY, 'Y''s new Item row is above the window and must wait.');
        _Assert.AreEqual(0, _BoundarySeam.BoundaryReadCount(), 'Page 2 must reuse the boundary carried in the pageKey.');

        // [WHEN] The next window starts from the rowVersion of the last item page 2 returned
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(ChangeRowVersionE, '', 0, '', RowVersions, NextPageKey);

        // [THEN] D, X and Y are returned, E is not sent again, and the new window read the boundary once
        _Assert.IsFalse(MorePages, 'The next window must fit on one page.');
        _Assert.AreEqual(3, RowVersions.Count(), 'The next window must hold D, X and Y.');
        AssertReturnedAt(RowVersions, ItemD, ChangeRowVersionD, 'The next window must return D at its new change row version.');
        AssertReturnedAt(RowVersions, ItemX, ChangeRowVersionX, 'The next window must return X at its change row version.');
        AssertReturnedAt(RowVersions, ItemY, ItemRowVersionY, 'The next window must return Y at its Item row version.');
        AssertNotReturned(RowVersions, ItemE, 'E must not be sent again.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'A request without pageKey must read the boundary once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PageKeyWithoutBoundaryStartsNewWindow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemG: Code[20];
        ItemH: Code[20];
        ItemK: Code[20];
        OldKey: Text;
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionH: BigInteger;
        ItemRowVersionK: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A11: a pageKey in the format issued before the window boundary existed still works; it starts a new window at the key's position.
        // [GIVEN] Items G, H and K; after the cursor: G changed, H marked, K changed
        Initialize();
        ItemG := _LibraryInventory.CreateItemNo();
        ItemH := _LibraryInventory.CreateItemNo();
        ItemK := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ChangeItem(ItemG);
        ChangeRowVersionH := MarkChanged(ItemH);
        ItemRowVersionK := ChangeItem(ItemK);
        Commit();
        // [GIVEN] A pageKey built the old way from G's Item row
        OldKey := BuildOldFormatPageKey(ItemG);
        _Assert.AreEqual(0, StrPos(OldKey, '.'), 'Test setup: the old-format key must not contain a dot.');

        // [WHEN] Call 1 sends the old key with pageSize 1
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(Cursor, '', 1, OldKey, RowVersions, NextPageKey);

        // [THEN] H is returned from the change stream above the key's position, and the call read a boundary
        _Assert.IsTrue(MorePages, 'Call 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemH, ChangeRowVersionH, 'Call 1 must return H at its change row version.');
        AssertNotReturned(RowVersions, ItemG, 'G is at the key''s position and must not be returned again.');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'A key without a boundary must start a window and read the boundary.');

        // [WHEN] Call 2 follows nextPageKey
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] K is returned on the last page, and the carried boundary is reused
        _Assert.IsFalse(MorePages, 'Call 2 must be the last page.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 2 must hold one item.');
        AssertReturnedAt(RowVersions, ItemK, ItemRowVersionK, 'Call 2 must return K at its Item row version.');
        _Assert.AreEqual(0, _BoundarySeam.BoundaryReadCount(), 'Call 2 must reuse the boundary carried in the pageKey.');

        // [WHEN] Call 3 sends the old key again while the boundary lies below the key's position
        _BoundarySeam.SetFixedBoundary(Cursor);
        _BoundarySeam.ResetBoundaryReadCount();
        MorePages := ReadSyncPage(Cursor, '', 1, OldKey, RowVersions, NextPageKey);

        // [THEN] The window is empty
        AssertEmptyLastPage(MorePages, RowVersions, NextPageKey, 'Call 3');
        _Assert.AreEqual(1, _BoundarySeam.BoundaryReadCount(), 'Call 3 must read the boundary once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MalformedCursorParametersReturn400()
    var
        ItemG: Code[20];
        SharedKey: Text;
        CursorText: Text;
    begin
        // [SCENARIO] A12: a pageKey whose window boundary is not the canonical number text, or a non-numeric lastRowVersion with sync=true, returns 400 with a message that names the rejected parameter.
        // [GIVEN] Item G and a shared pageKey built from it
        Initialize();
        ItemG := _LibraryInventory.CreateItemNo();
        CursorText := Format(Database.LastUsedRowVersion(), 0, 9);
        Commit();
        SharedKey := BuildOldFormatPageKey(ItemG);
        _Assert.AreEqual(0, StrPos(SharedKey, '.'), 'Test setup: the shared key must not contain a dot.');

        // [WHEN] The key is sent with a canonical boundary and a valid lastRowVersion
        // [THEN] The call succeeds
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(CallItemSync(CursorText, SharedKey + '.' + CursorText)), 'A key with a canonical boundary and a valid lastRowVersion must be accepted.');

        // [WHEN] The boundary or lastRowVersion is malformed
        // [THEN] Each call returns 400, and the message names pageKey or lastRowVersion
        AssertSyncRejected(CursorText, SharedKey + '.abc', 'pageKey is not valid', 'A non-numeric boundary must return 400.');
        AssertSyncRejected(CursorText, SharedKey + '.-1', 'pageKey is not valid', 'A negative boundary must return 400.');
        AssertSyncRejected(CursorText, SharedKey + '.', 'pageKey is not valid', 'An empty boundary must return 400.');
        AssertSyncRejected(CursorText, SharedKey + '.5.6', 'pageKey is not valid', 'A boundary with a second dot must return 400.');
        AssertSyncRejected(CursorText, SharedKey + '.05', 'pageKey is not valid', 'A boundary with a leading zero must return 400.');
        AssertSyncRejected('abc', '', 'lastRowVersion is not valid', 'A non-numeric lastRowVersion with sync=true must return 400.');
        // [THEN] The lastRowVersion message does not point the client to syncRowVersion
        _Assert.IsFalse(GetText(_LibraryNPRetailAPI.GetResponseBody(CallItemSync('abc', '')), 'message').Contains('syncRowVersion'), 'The lastRowVersion 400 message must not name syncRowVersion.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeRowAboveBoundaryLeavesItemRowOnEarlierPage()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionA: BigInteger;
        ChangeRowVersionB: BigInteger;
        ChangeRowVersionA: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A13: a change row above the boundary does not defer the Item row, later pages keep page 1's boundary, and GET is not clamped to the window.
        // [GIVEN] Items A and B; after the cursor: A changed, B marked, A marked
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionA := ChangeItem(ItemA);
        ChangeRowVersionB := MarkChanged(ItemB);
        ChangeRowVersionA := MarkChanged(ItemA);
        Commit();
        _Assert.IsTrue((ItemRowVersionA < ChangeRowVersionB) and (ChangeRowVersionB < ChangeRowVersionA), 'Test setup: the writes must be ordered A changed, B marked, A marked.');
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionB);

        // [WHEN] A is read by its id
        // [THEN] GET returns A's newest row, unclamped
        _Assert.AreEqual(ChangeRowVersionA, GetItemRowVersion(ItemA), 'GET must return A''s change row version.');

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);

        // [THEN] A is returned at its Item row version, because its change row is above the boundary
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemA, ItemRowVersionA, 'Page 1 must return A at its Item row version.');

        // [WHEN] Page 2 follows nextPageKey while the seam would now return a later boundary
        _BoundarySeam.UseLastAllocatedBoundary();
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 holds B, ends the window at page 1's boundary and does not return A again
        _Assert.IsFalse(MorePages, 'Page 2 must be the last page of the window.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 2 must hold only B.');
        AssertReturnedAt(RowVersions, ItemB, ChangeRowVersionB, 'Page 2 must return B at its change row version.');
        AssertNotReturned(RowVersions, ItemA, 'A''s change row is above the window and must wait.');

        // [WHEN] The next window starts from the rowVersion of the last item page 2 returned
        ReadSyncPage(ChangeRowVersionB, '', 0, '', RowVersions, NextPageKey);

        // [THEN] A is returned at its change row version, B is not sent again, and GET matches the sync value
        _Assert.AreEqual(1, RowVersions.Count(), 'The next window must hold only A.');
        AssertReturnedAt(RowVersions, ItemA, ChangeRowVersionA, 'The next window must return A at its change row version.');
        AssertNotReturned(RowVersions, ItemB, 'B must not be sent again.');
        _Assert.AreEqual(RowVersions.Get(ItemA), GetItemRowVersion(ItemA), 'GET must match the sync value once A''s newest row lies inside the window.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EmptyWindowEndsOnOneEmptyPage()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionZ: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A14: a window that returns no item is one empty last page, whether the boundary is above, equal to or below lastRowVersion.
        // [GIVEN] After the cursor: a change row for an unused item no. Z
        Initialize();
        Cursor := Database.LastUsedRowVersion();
        ItemNoZ := GetUnusedItemNo();
        ChangeRowVersionZ := MarkChanged(ItemNoZ);
        Commit();

        // [WHEN] Call 1 syncs from the cursor with the boundary at Z's change row
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionZ);
        MorePages := ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey);
        // [THEN] The page is empty and ends the sync
        AssertEmptyLastPage(MorePages, RowVersions, NextPageKey, 'Call 1');

        // [WHEN] Call 2 syncs from Z's change row with the boundary below it
        _BoundarySeam.SetFixedBoundary(Cursor);
        MorePages := ReadSyncPage(ChangeRowVersionZ, '', 0, '', RowVersions, NextPageKey);
        // [THEN] The page is empty and ends the sync
        AssertEmptyLastPage(MorePages, RowVersions, NextPageKey, 'Call 2');

        // [WHEN] Call 3 syncs from Z's change row with the boundary equal to it
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionZ);
        MorePages := ReadSyncPage(ChangeRowVersionZ, '', 0, '', RowVersions, NextPageKey);
        // [THEN] The page is empty and ends the sync
        AssertEmptyLastPage(MorePages, RowVersions, NextPageKey, 'Call 3');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrphanAtWindowEndIsReadAgainWithoutDuplicates()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemQ: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionQ: BigInteger;
        ChangeRowVersionZ: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A15: a window that ends with a skipped orphan ends on the page that returns Q. The next sync starts at Q's rowVersion, reads the orphan again and returns nothing.
        // [GIVEN] Item Q; after the cursor: Q marked, then an unused item no. Z marked
        Initialize();
        ItemQ := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ChangeRowVersionQ := MarkChanged(ItemQ);
        ItemNoZ := GetUnusedItemNo();
        ChangeRowVersionZ := MarkChanged(ItemNoZ);
        Commit();
        _Assert.IsTrue(ChangeRowVersionQ < ChangeRowVersionZ, 'Test setup: Q must be marked before Z.');

        // [WHEN] Call 1 syncs from the cursor with the boundary at Z's change row
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionZ);
        MorePages := ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey);

        // [THEN] Q is returned, and the orphan Z is skipped
        _Assert.IsFalse(MorePages, 'Call 1 must be the last page.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Call 1 must return only Q.');
        AssertReturnedAt(RowVersions, ItemQ, ChangeRowVersionQ, 'Call 1 must return Q at its change row version.');
        AssertNotReturned(RowVersions, ItemNoZ, 'A change row without an item must be skipped.');

        // [WHEN] Call 2 syncs from Q's rowVersion, the last item call 1 returned, with the last allocated boundary
        _BoundarySeam.UseLastAllocatedBoundary();
        MorePages := ReadSyncPage(ChangeRowVersionQ, '', 0, '', RowVersions, NextPageKey);

        // [THEN] Call 2 reads the orphan again and returns nothing
        AssertEmptyLastPage(MorePages, RowVersions, NextPageKey, 'Call 2');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullPageFollowedOnlyBySkippedRowsIsLastPage()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemD: Code[20];
        ItemE: Code[20];
        ItemY: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionD: BigInteger;
        ItemRowVersionE: BigInteger;
        ChangeRowVersionZ: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A16: a full page whose remaining window holds only a skipped orphan reports no more pages.
        // [GIVEN] Items D, E and Y; after the cursor: D changed, E changed, an unused item no. Z marked
        Initialize();
        ItemD := _LibraryInventory.CreateItemNo();
        ItemE := _LibraryInventory.CreateItemNo();
        ItemY := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionD := ChangeItem(ItemD);
        ItemRowVersionE := ChangeItem(ItemE);
        ItemNoZ := GetUnusedItemNo();
        ChangeRowVersionZ := MarkChanged(ItemNoZ);
        Commit();
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionZ);

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);

        // [THEN] Page 1 holds D and reports more pages
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemD, ItemRowVersionD, 'Page 1 must return D at its Item row version.');

        // [GIVEN] Y changed between pages, while the seam would now return a later boundary
        _BoundarySeam.UseLastAllocatedBoundary();
        ChangeItem(ItemY);
        Commit();

        // [WHEN] Page 2 follows nextPageKey
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 holds E and is the last page, because only the orphan Z follows E in the window; Y is on no page
        _Assert.IsFalse(MorePages, 'Page 2 must be the last page: only a skipped orphan follows E.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 2 must hold one item.');
        AssertReturnedAt(RowVersions, ItemE, ItemRowVersionE, 'Page 2 must return E at its Item row version.');
        AssertNotReturned(RowVersions, ItemY, 'Y changed above the carried boundary and must wait.');
        AssertNotReturned(RowVersions, ItemNoZ, 'A change row without an item must be skipped.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LookaheadReadsPastSkippedRowToNextItem()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionA: BigInteger;
        ChangeRowVersionZ: BigInteger;
        ItemRowVersionB: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A17: a full page looks past a skipped orphan row and reports more pages when a later row in the window is due.
        // [GIVEN] Items A and B; after the cursor: A changed, an unused item no. Z marked, B changed
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionA := ChangeItem(ItemA);
        ItemNoZ := GetUnusedItemNo();
        ChangeRowVersionZ := MarkChanged(ItemNoZ);
        ItemRowVersionB := ChangeItem(ItemB);
        Commit();
        _Assert.IsTrue((ItemRowVersionA < ChangeRowVersionZ) and (ChangeRowVersionZ < ItemRowVersionB), 'Test setup: the writes must be ordered A changed, Z marked, B changed.');

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);

        // [THEN] Page 1 holds A and reports more pages, because B is due after the orphan Z
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemA, ItemRowVersionA, 'Page 1 must return A at its Item row version.');

        // [WHEN] Page 2 follows nextPageKey
        MorePages := ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 holds B, skips Z and is the last page
        _Assert.IsFalse(MorePages, 'Page 2 must be the last page.');
        _Assert.AreEqual('', NextPageKey, 'The last page must not carry a nextPageKey.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 2 must hold one item.');
        AssertReturnedAt(RowVersions, ItemB, ItemRowVersionB, 'Page 2 must return B at its Item row version.');
        AssertNotReturned(RowVersions, ItemNoZ, 'A change row without an item must be skipped.');
        AssertNotReturned(RowVersions, ItemA, 'A must not be returned again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClientRecoversWhenFoundItemLeavesWindow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionA: BigInteger;
        ItemRowVersionB: BigInteger;
        NewItemRowVersionB: BigInteger;
        MorePages: Boolean;
    begin
        // [SCENARIO] A18: when the item that made page 1 report more pages changes before page 2, a client that syncs again from the last returned rowVersion still gets it.
        // [GIVEN] Items A and B; after the cursor: A changed, B changed; the boundary at B's Item row
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionA := ChangeItem(ItemA);
        ItemRowVersionB := ChangeItem(ItemB);
        Commit();
        _BoundarySeam.SetFixedBoundary(ItemRowVersionB);

        // [WHEN] Page 1 is read from the cursor with pageSize 1
        MorePages := ReadSyncPage(Cursor, '', 1, '', RowVersions, NextPageKey);

        // [THEN] Page 1 holds A and reports more pages
        _Assert.IsTrue(MorePages, 'Page 1 must report more pages.');
        _Assert.AreEqual(1, RowVersions.Count(), 'Page 1 must hold one item.');
        AssertReturnedAt(RowVersions, ItemA, ItemRowVersionA, 'Page 1 must return A at its Item row version.');

        // [GIVEN] B changed between pages, so its Item row moves above the carried boundary
        NewItemRowVersionB := ChangeItem(ItemB);
        Commit();

        // [WHEN] Page 2 follows nextPageKey
        ReadSyncPage(Cursor, '', 1, NextPageKey, RowVersions, NextPageKey);

        // [THEN] Page 2 does not return A again
        AssertNotReturned(RowVersions, ItemA, 'Page 2 must not return A again.');

        // [WHEN] A new sync starts from A's rowVersion, the last item the client received, with the last allocated boundary
        _BoundarySeam.UseLastAllocatedBoundary();
        ReadSyncPage(ItemRowVersionA, '', 0, '', RowVersions, NextPageKey);

        // [THEN] B is returned at its new Item row version, and A is not sent again
        AssertReturnedAt(RowVersions, ItemB, NewItemRowVersionB, 'The new sync must return B at its new Item row version.');
        AssertNotReturned(RowVersions, ItemA, 'The new sync must not send A again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OlderChangeRowDoesNotDeferNewerItemRow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemC: Code[20];
        ItemP: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionC: BigInteger;
        ItemRowVersionC: BigInteger;
        ChangeRowVersionP: BigInteger;
    begin
        // [SCENARIO] RI-lower: an Item row newer than its item's change row is returned at the Item row, and the older change row returns nothing.
        // [GIVEN] Items C and P; after the cursor: C marked, C changed, P marked
        Initialize();
        ItemC := _LibraryInventory.CreateItemNo();
        ItemP := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ChangeRowVersionC := MarkChanged(ItemC);
        ItemRowVersionC := ChangeItem(ItemC);
        ChangeRowVersionP := MarkChanged(ItemP);
        Commit();
        _Assert.IsTrue((ChangeRowVersionC < ItemRowVersionC) and (ItemRowVersionC < ChangeRowVersionP), 'Test setup: the writes must be ordered C marked, C changed, P marked.');

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] Exactly C at its Item row version and P at its change row version are returned
        _Assert.AreEqual(2, RowVersions.Count(), 'Exactly C and P must be returned.');
        AssertReturnedAt(RowVersions, ItemC, ItemRowVersionC, 'C must be returned at its Item row version.');
        AssertReturnedAt(RowVersions, ItemP, ChangeRowVersionP, 'P must be returned at its change row version.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ChangeRowAboveBoundaryLeavesItemRowInWindow()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemA: Code[20];
        ItemB: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ItemRowVersionA: BigInteger;
        ChangeRowVersionB: BigInteger;
        ChangeRowVersionA: BigInteger;
    begin
        // [SCENARIO] RI-boundary: an Item row whose newer change row lies above the boundary is returned at the Item row in the same window.
        // [GIVEN] Items A and B; after the cursor: A changed, B marked, A marked; the boundary at B's change row
        Initialize();
        ItemA := _LibraryInventory.CreateItemNo();
        ItemB := _LibraryInventory.CreateItemNo();
        Cursor := Database.LastUsedRowVersion();
        ItemRowVersionA := ChangeItem(ItemA);
        ChangeRowVersionB := MarkChanged(ItemB);
        ChangeRowVersionA := MarkChanged(ItemA);
        Commit();
        _Assert.IsTrue((ItemRowVersionA < ChangeRowVersionB) and (ChangeRowVersionB < ChangeRowVersionA), 'Test setup: the writes must be ordered A changed, B marked, A marked.');
        _BoundarySeam.SetFixedBoundary(ChangeRowVersionB);

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] Exactly A at its Item row version and B at its change row version are returned
        _Assert.AreEqual(2, RowVersions.Count(), 'Exactly A and B must be returned.');
        AssertReturnedAt(RowVersions, ItemA, ItemRowVersionA, 'A must be returned at its Item row version.');
        AssertReturnedAt(RowVersions, ItemB, ChangeRowVersionB, 'B must be returned at its change row version.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrphanChangeRowInWindowIsSkipped()
    var
        RowVersions: Dictionary of [Code[20], BigInteger];
        ItemQ: Code[20];
        ItemNoZ: Code[20];
        NextPageKey: Text;
        Cursor: BigInteger;
        ChangeRowVersionQ: BigInteger;
    begin
        // [SCENARIO] Orphan-in-window: a change row whose item does not exist is skipped, while other change rows in the window are returned.
        // [GIVEN] Item Q and an unused item no. Z; after the cursor: Q marked, Z marked
        Initialize();
        ItemQ := _LibraryInventory.CreateItemNo();
        ItemNoZ := GetUnusedItemNo();
        Cursor := Database.LastUsedRowVersion();
        ChangeRowVersionQ := MarkChanged(ItemQ);
        MarkChanged(ItemNoZ);
        Commit();

        // [WHEN] The items are synced from the cursor
        _Assert.IsFalse(ReadSyncPage(Cursor, '', 0, '', RowVersions, NextPageKey), 'One page must hold the whole window.');

        // [THEN] Exactly Q is returned; Z is not
        _Assert.AreEqual(1, RowVersions.Count(), 'Exactly Q must be returned.');
        AssertReturnedAt(RowVersions, ItemQ, ChangeRowVersionQ, 'Q must be returned at its change row version.');
        AssertNotReturned(RowVersions, ItemNoZ, 'A change row without an item must be skipped.');
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemNoZ) > Cursor, 'Test setup: Z''s change row must lie in the window.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonSyncListFiltersOnLastRowVersion()
    var
        QueryParams: Dictionary of [Text, Text];
        ItemX: Code[20];
        RowVersionX: BigInteger;
        Body: JsonObject;
        DataToken: JsonToken;
        ElementToken: JsonToken;
    begin
        // [SCENARIO] With sync=false, lastRowVersion returns only items whose Item row version is above it.
        // [GIVEN] Item X, changed after it was created
        Initialize();
        ItemX := _LibraryInventory.CreateItemNo();
        RowVersionX := ChangeItem(ItemX);
        Commit();

        // [WHEN] X is listed with sync=false from just below its row version
        QueryParams.Add('sync', 'false');
        QueryParams.Add('itemCode', ItemX);
        QueryParams.Add('lastRowVersion', Format(RowVersionX - 1, 0, 9));
        Body := GetBody(CallInventoryApi('/inventory/item', QueryParams));
        // [THEN] The page holds exactly X, and X carries no rowVersion
        _Assert.IsTrue(Body.Get('data', DataToken), 'The non-sync page must carry data.');
        _Assert.AreEqual(1, DataToken.AsArray().Count(), 'The non-sync page must hold exactly X.');
        DataToken.AsArray().Get(0, ElementToken);
        _Assert.AreEqual(Format(ItemX), GetText(ElementToken.AsObject(), 'code'), 'The non-sync page must return X.');
        _Assert.IsFalse(ElementToken.AsObject().Contains('rowVersion'), 'sync=false must not return rowVersion.');

        // [WHEN] X is listed with sync=false from its row version
        QueryParams.Set('lastRowVersion', Format(RowVersionX, 0, 9));
        Body := GetBody(CallInventoryApi('/inventory/item', QueryParams));
        // [THEN] The page is empty
        _Assert.IsTrue(Body.Get('data', DataToken), 'The non-sync page must carry data.');
        _Assert.AreEqual(0, DataToken.AsArray().Count(), 'The non-sync page must be empty from X''s row version.');
    end;

    local procedure Initialize()
    begin
        // Without the seam the open test transaction pins the real boundary below every fixture.
        if not _BoundarySeamBound then begin
            BindSubscription(_BoundarySeam);
            _BoundarySeamBound := true;
        end;
        // Some cases set a fixed boundary; every case starts from the default.
        _BoundarySeam.UseLastAllocatedBoundary();

        if _Initialized then
            exit;

        _LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Inventory');
        _Initialized := true;
        Commit();
    end;

    local procedure ReadSyncPage(LastRowVersion: BigInteger; ItemCode: Code[20]; PageSize: Integer; PageKey: Text; var RowVersions: Dictionary of [Code[20], BigInteger]; var NextPageKey: Text) MorePages: Boolean
    var
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        DataToken: JsonToken;
        ElementToken: JsonToken;
        Element: JsonObject;
        ItemNo: Code[20];
        RowVersion: BigInteger;
        HighestRowVersion: BigInteger;
    begin
        Clear(RowVersions);
        QueryParams.Add('sync', 'true');
        QueryParams.Add('lastRowVersion', Format(LastRowVersion, 0, 9));
        if ItemCode <> '' then
            QueryParams.Add('itemCode', ItemCode);
        if PageSize > 0 then
            QueryParams.Add('pageSize', Format(PageSize, 0, 9));
        if PageKey <> '' then
            QueryParams.Add('pageKey', PageKey);
        Body := GetBody(CallInventoryApi('/inventory/item', QueryParams));

        _Assert.IsTrue(Body.Get('data', DataToken), 'The sync page must carry data.');
        foreach ElementToken in DataToken.AsArray() do begin
            Element := ElementToken.AsObject();
            ItemNo := CopyStr(GetText(Element, 'code'), 1, MaxStrLen(ItemNo));
            _Assert.IsFalse(RowVersions.ContainsKey(ItemNo), StrSubstNo('Item %1 must appear at most once on a sync page.', ItemNo));
            _Assert.IsTrue(Element.Contains('rowVersion'), StrSubstNo('Item %1 must carry a rowVersion on a sync page.', ItemNo));
            RowVersion := _LibraryAPIBI.GetBigInteger(Element, 'rowVersion');
            _Assert.IsTrue(RowVersion > HighestRowVersion, 'rowVersion must increase strictly along a sync page.');
            HighestRowVersion := RowVersion;
            RowVersions.Add(ItemNo, RowVersion);
        end;
        MorePages := _LibraryAPIBI.GetRequiredBoolean(Body, 'morePages');
        NextPageKey := GetText(Body, 'nextPageKey');

        _Assert.IsFalse(Body.Contains('syncRowVersion'), 'A sync page must not carry syncRowVersion.');
        _Assert.AreEqual(MorePages, NextPageKey <> '', 'nextPageKey must be set exactly when morePages is true.');
        if MorePages and (PageSize > 0) then
            _Assert.AreEqual(PageSize, DataToken.AsArray().Count(), 'A page with morePages = true must hold pageSize items.');
    end;

    local procedure CallItemSync(LastRowVersionText: Text; PageKey: Text): JsonObject
    var
        QueryParams: Dictionary of [Text, Text];
    begin
        QueryParams.Add('sync', 'true');
        QueryParams.Add('lastRowVersion', LastRowVersionText);
        if PageKey <> '' then
            QueryParams.Add('pageKey', PageKey);
        exit(CallInventoryApi('/inventory/item', QueryParams));
    end;

    local procedure AssertSyncRejected(LastRowVersionText: Text; PageKey: Text; ExpectedMessageStart: Text; FailureMessage: Text)
    var
        Response: JsonObject;
    begin
        Response := CallItemSync(LastRowVersionText, PageKey);
        _Assert.AreEqual(400, GetStatusCode(Response), FailureMessage);
        _Assert.IsTrue(GetText(_LibraryNPRetailAPI.GetResponseBody(Response), 'message').StartsWith(ExpectedMessageStart), StrSubstNo('%1 The message must start with ''%2''.', FailureMessage, ExpectedMessageStart));
    end;

    // Builds a sync pageKey the way the API did before the window boundary was appended.
    local procedure BuildOldFormatPageKey(ItemNo: Code[20]): Text
    var
        Item: Record Item;
        APIRequest: Codeunit "NPR API Request";
        RecRef: RecordRef;
    begin
        Item.Get(ItemNo);
        RecRef.GetTable(Item);
        APIRequest.SetKeyToRowVersion(RecRef);
        exit(APIRequest.GetPageKey(RecRef));
    end;

    // The second Get picks up any nested write a subscriber made to the item.
    local procedure ChangeItem(ItemNo: Code[20]): BigInteger
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Description := CopyStr(Format(CreateGuid()), 1, MaxStrLen(Item.Description));
        Item.Modify();
        Item.Get(ItemNo);
        exit(Item.SystemRowVersion);
    end;

    local procedure MarkChanged(ItemNo: Code[20]): BigInteger
    var
        TempItemChange: Record "NPR Inventory Item Change" temporary;
    begin
        _ItemChangeMgt.AddItemNo(TempItemChange, ItemNo);
        _ItemChangeMgt.MarkItemsChanged(TempItemChange);
        exit(_ItemChangeMgt.GetChangeRowVersion(ItemNo));
    end;

    local procedure GetItemTableRowVersion(ItemNo: Code[20]): BigInteger
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        exit(Item.SystemRowVersion);
    end;

    local procedure GetItemRowVersion(ItemNo: Code[20]): BigInteger
    var
        Item: Record Item;
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
    begin
        Item.Get(ItemNo);
        Body := GetBody(CallInventoryApi('/inventory/item/' + FormatGuid(Item.SystemId), QueryParams));
        _Assert.IsTrue(Body.Contains('rowVersion'), 'GET /inventory/item/:id must return rowVersion.');
        exit(_LibraryAPIBI.GetBigInteger(Body, 'rowVersion'));
    end;

    // Change rows survive between cases, so each case needs its own unused item no.
    local procedure GetUnusedItemNo() ItemNo: Code[20]
    var
        Item: Record Item;
    begin
        ItemNo := CopyStr('Z' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(ItemNo));
        _Assert.IsFalse(Item.Get(ItemNo), 'The generated item no. is already in use.');
    end;

    // The Item row did not carry the change, and the mark did.
    local procedure AssertChangePathGuards(ItemNo: Code[20]; Cursor: BigInteger)
    begin
        _Assert.IsTrue(GetItemTableRowVersion(ItemNo) <= Cursor, StrSubstNo('Test setup: the Item row of %1 must lie below the cursor.', ItemNo));
        _Assert.IsTrue(_ItemChangeMgt.GetChangeRowVersion(ItemNo) > Cursor, StrSubstNo('Test setup: the change row of %1 must lie above the cursor.', ItemNo));
    end;

    local procedure AssertGetMatchesSync(RowVersions: Dictionary of [Code[20], BigInteger]; ItemNo: Code[20])
    var
        GetRowVersion: BigInteger;
    begin
        GetRowVersion := GetItemRowVersion(ItemNo);
        _Assert.AreEqual(RowVersions.Get(ItemNo), GetRowVersion, StrSubstNo('GET must return the sync rowVersion of %1.', ItemNo));
    end;

    local procedure AssertReturnedAt(RowVersions: Dictionary of [Code[20], BigInteger]; ItemNo: Code[20]; ExpectedRowVersion: BigInteger; FailureMessage: Text)
    begin
        _Assert.IsTrue(RowVersions.ContainsKey(ItemNo), FailureMessage);
        _Assert.AreEqual(ExpectedRowVersion, RowVersions.Get(ItemNo), FailureMessage);
    end;

    local procedure AssertNotReturned(RowVersions: Dictionary of [Code[20], BigInteger]; ItemNo: Code[20]; FailureMessage: Text)
    begin
        _Assert.IsFalse(RowVersions.ContainsKey(ItemNo), FailureMessage);
    end;

    local procedure AssertEmptyLastPage(MorePages: Boolean; RowVersions: Dictionary of [Code[20], BigInteger]; NextPageKey: Text; CallName: Text)
    begin
        _Assert.IsFalse(MorePages, CallName + ' must be the last page.');
        _Assert.AreEqual('', NextPageKey, CallName + ' must not carry a nextPageKey.');
        _Assert.AreEqual(0, RowVersions.Count(), CallName + ' must return no items.');
    end;

    local procedure CallInventoryApi(Path: Text; QueryParams: Dictionary of [Text, Text]): JsonObject
    var
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
    begin
        exit(_LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers));
    end;

    local procedure GetBody(Response: JsonObject): JsonObject
    begin
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The API call should succeed');
        exit(_LibraryNPRetailAPI.GetResponseBody(Response));
    end;

    local procedure GetStatusCode(Response: JsonObject): Integer
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Response.Get('statusCode', Token), 'The response should contain a status code');
        exit(Token.AsValue().AsInteger());
    end;

    local procedure GetText(Json: JsonObject; PropertyName: Text): Text
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Json.Get(PropertyName, Token), PropertyName + ' must be returned');
        exit(Token.AsValue().AsText());
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
