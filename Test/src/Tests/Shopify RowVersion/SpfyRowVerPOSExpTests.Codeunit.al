codeunit 85482 "NPR Spfy RowVer POSExp Tests"
{
    // [FEATURE] Shopify POS entry export watermark - committed-boundary window and per-store marks (CORE-2227)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _BndSeam: Codeunit "NPR Spfy RowVer Boundary Seam";
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndBound: Boolean;

    local procedure Initialize()
    begin
        _Lib.ResetState(_BndSeam, _BndBound);
        _Lib.EnsureIntegrationEnabled();
        DeleteExportJobQueueEntries();
    end;

    [Test]
    procedure JQRun_CreatesTaskAndAdvancesOnlyLinkedStoreMark()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        POSEntry: Record "NPR POS Entry";
        StoreA: Code[20];
        StoreB: Code[20];
    begin
        // [SCENARIO] The export JQ creates one task for an eligible entry and moves only the linked store's mark to that entry; an unrelated store's mark stays, and a second run creates no duplicate.
        Initialize();
        StoreA := CreateTransStore(true, true);
        StoreB := CreateTransStore(true, true);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreA, true, true);
        CreatePOSEntry(POSEntry, Customer."No.", 120);
        Commit();

        // [WHEN] The JQ runs over both stores.
        RunExportJQ(StrSubstNo('%1|%2', StoreA, StoreB));

        // [THEN] One task; store A's mark is its own last evaluated entry; store B's mark is untouched (per-store rule).
        _Assert.AreEqual(1, _Lib.TaskCountForRecordId(Database::"NPR POS Entry", POSEntry.RecordId()), 'One export task for the eligible entry');
        _Assert.IsTrue(GetStoreMark(StoreA) = POSEntry.SystemRowVersion, StrSubstNo('Store A mark must move to its own last evaluated entry %1, was %2', POSEntry.SystemRowVersion, GetStoreMark(StoreA)));
        _Assert.IsTrue(GetStoreMark(StoreB) = 0, 'Store B mark must stay untouched (no linked customer)');

        // [WHEN] The JQ runs again. [THEN] no duplicate task.
        RunExportJQ(StrSubstNo('%1|%2', StoreA, StoreB));
        _Assert.AreEqual(1, _Lib.TaskCountForRecordId(Database::"NPR POS Entry", POSEntry.RecordId()), 'A second run must not duplicate the task');
    end;

    [Test]
    procedure JQRun_PinnedWindow_LeavesMarksUntouchedAndCreatesNothing()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        POSEntry: Record "NPR POS Entry";
        ShopifyStore: Record "NPR Spfy Store";
        StoreA: Code[20];
        PinnedMark: BigInteger;
    begin
        // [SCENARIO] While the boundary sits at or below the lowest store mark, the JQ creates nothing and every mark stays unchanged; the next run continues the window.
        Initialize();
        StoreA := CreateTransStore(true, true);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreA, true, true);
        CreatePOSEntry(POSEntry, Customer."No.", 120);
        Commit();
        POSEntry.Get(POSEntry."Entry No.");
        // [GIVEN] Boundary = mark, with the eligible entry ABOVE the mark: pinned while work is waiting.
        PinnedMark := POSEntry.SystemRowVersion - 1;
        ShopifyStore.Get(StoreA);
        ShopifyStore.SetLastPOSRowVersion(PinnedMark);
        Commit();
        _BndSeam.SetFixedBoundary(PinnedMark);

        // [WHEN] The JQ runs against the pinned window.
        RunExportJQ(StoreA);

        // [THEN] Nothing is created and the mark survives.
        _Assert.AreEqual(0, _Lib.TaskCountForRecordId(Database::"NPR POS Entry", POSEntry.RecordId()), 'A pinned run must create no task');
        _Assert.IsTrue(GetStoreMark(StoreA) = PinnedMark, 'A pinned run must not move the store mark');
    end;

    [Test]
    procedure POSEntryWindowFilter_ExcludesRowsAboveBoundary()
    var
        POSEntry: Record "NPR POS Entry";
        LatePOSEntry: Record "NPR POS Entry";
        FilteredPOSEntry: Record "NPR POS Entry";
        SpfyExportBCTransJQ: Codeunit "NPR Spfy Export BC Trans. JQ";
        Boundary: BigInteger;
    begin
        // [SCENARIO] The JQ's rowversion window helper selects only entries inside (After, UpTo], also when the lower mark is 0, so a row above the bound is never inside.
        Initialize();
        CreatePOSEntry(POSEntry, '', 10);
        CreatePOSEntry(LatePOSEntry, '', 10);
        Commit();
        POSEntry.Get(POSEntry."Entry No.");
        LatePOSEntry.Get(LatePOSEntry."Entry No.");
        // The bound is a chosen, fixture-derived rowversion: the first entry sits at it, the later entry above it.
        Boundary := POSEntry.SystemRowVersion;

        // [WHEN] Filtering (0, Boundary]. [THEN] the early entry is inside, the late entry is outside.
        SpfyExportBCTransJQ.SetPOSEntryRowVersionWindow(FilteredPOSEntry, 0, Boundary);
        FilteredPOSEntry.SetRange("Entry No.", POSEntry."Entry No.");
        _Assert.IsFalse(FilteredPOSEntry.IsEmpty(), 'A committed entry inside the window must be selected (also when the lower mark is 0)');
        FilteredPOSEntry.SetRange("Entry No.", LatePOSEntry."Entry No.");
        _Assert.IsTrue(FilteredPOSEntry.IsEmpty(), 'An entry above the upper bound must be excluded');
    end;

    [Test]
    procedure BCCustomerTransactionsOnValidate_SeedsPointerAtCommittedBoundary()
    var
        POSEntry: Record "NPR POS Entry";
        LaterPOSEntry: Record "NPR POS Entry";
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
        Boundary: BigInteger;
    begin
        // [SCENARIO] Enabling "Send POS Customer Purchases" on a store with a zero pointer seeds the pointer at exactly the boundary, never at the table max the old FindLast seed used.
        Initialize();
        // The store stays disabled so the trigger's job-queue setup takes its cancel branch (no job is scheduled).
        StoreCode := CreateTransStore(false, false);
        // [GIVEN] Two committed entries and a fixed boundary at the FIRST one: the table max lies above the boundary.
        CreatePOSEntry(POSEntry, '', 10);
        CreatePOSEntry(LaterPOSEntry, '', 10);
        Commit();
        POSEntry.Get(POSEntry."Entry No.");
        LaterPOSEntry.Get(LaterPOSEntry."Entry No.");
        Boundary := POSEntry.SystemRowVersion;
        _BndSeam.SetFixedBoundary(Boundary);

        // [WHEN] The flag is validated on.
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Validate("BC Customer Transactions", true);

        // [THEN] The pointer is exactly the boundary; the old FindLast seed would land on the later entry, above it.
        _Assert.IsTrue(GetStoreMark(StoreCode) = Boundary, StrSubstNo('The seed must be exactly the boundary %1, was %2', Boundary, GetStoreMark(StoreCode)));
        _Assert.IsTrue(GetStoreMark(StoreCode) < LaterPOSEntry.SystemRowVersion, 'The seed must never pass the boundary up to the table max');
    end;

    [Test]
    procedure JQRun_QuietStore_KeepsItsNonZeroMark()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        POSEntry: Record "NPR POS Entry";
        ShopifyStore: Record "NPR Spfy Store";
        StoreA: Code[20];
        MarkBefore: BigInteger;
    begin
        // [SCENARIO] A run that exports nothing for a store leaves that store's mark alone. The export buffer reports 0 for a quiet store, so a write that could lower the mark would reset it and rescan every POS entry on every later run.
        Initialize();
        StoreA := CreateTransStore(true, true);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreA, true, true);
        CreatePOSEntry(POSEntry, Customer."No.", 120);
        Commit();
        POSEntry.Get(POSEntry."Entry No.");
        // [GIVEN] The store already sits at its only entry, so the next window holds nothing for it.
        MarkBefore := POSEntry.SystemRowVersion;
        ShopifyStore.Get(StoreA);
        ShopifyStore.SetLastPOSRowVersion(MarkBefore);
        Commit();

        // [WHEN] The JQ runs over the empty window.
        RunExportJQ(StoreA);

        // [THEN] The mark survives: a write that is not raise-only would drop it to the buffer's 0.
        _Assert.IsTrue(GetStoreMark(StoreA) = MarkBefore, StrSubstNo('A quiet run must keep the store mark at %1, was %2', MarkBefore, GetStoreMark(StoreA)));
    end;

    [Test]
    procedure JQRun_EntryAboveTheBoundary_IsExcludedAndTheMarkStopsBelowIt()
    var
        Customer: Record Customer;
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        POSEntry: Record "NPR POS Entry";
        LatePOSEntry: Record "NPR POS Entry";
        StoreA: Code[20];
        Boundary: BigInteger;
    begin
        // [SCENARIO] The JQ passes the frozen boundary as the scan's upper bound: an otherwise eligible entry above it is not exported, and the store mark stops below it.
        Initialize();
        StoreA := CreateTransStore(true, true);
        _Lib.CreateCustomerWithLink(Customer, SpfyStoreCustomerLink, StoreA, true, true);
        CreatePOSEntry(POSEntry, Customer."No.", 120);
        CreatePOSEntry(LatePOSEntry, Customer."No.", 130);
        Commit();
        POSEntry.Get(POSEntry."Entry No.");
        LatePOSEntry.Get(LatePOSEntry."Entry No.");
        // [GIVEN] Two eligible entries and a fixed boundary AT the first: the second lies above the window.
        Boundary := POSEntry.SystemRowVersion;
        _BndSeam.SetFixedBoundary(Boundary);

        // [WHEN] The JQ runs.
        RunExportJQ(StoreA);

        // [THEN] Only the entry inside the window is exported, and the mark stops below the excluded one.
        _Assert.AreEqual(1, _Lib.TaskCountForRecordId(Database::"NPR POS Entry", POSEntry.RecordId()), 'The entry inside the window must be exported');
        _Assert.AreEqual(0, _Lib.TaskCountForRecordId(Database::"NPR POS Entry", LatePOSEntry.RecordId()), 'An entry above the boundary must not be exported');
        _Assert.IsTrue(GetStoreMark(StoreA) = POSEntry.SystemRowVersion, StrSubstNo('The mark must stop at the last entry inside the window %1, was %2', POSEntry.SystemRowVersion, GetStoreMark(StoreA)));
        _Assert.IsTrue(GetStoreMark(StoreA) < LatePOSEntry.SystemRowVersion, 'The mark must never pass an entry above the boundary');
    end;

    local procedure CreateTransStore(StoreEnabled: Boolean; TransEnabled: Boolean): Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        // Direct insert skips the heavy OnValidate side effects; fresh codes per call keep the SingleInstance integration mgt cache clean.
        ShopifyStore.Init();
        ShopifyStore.Code := _Lib.NextCode('S', MaxStrLen(ShopifyStore.Code));
        ShopifyStore.Enabled := StoreEnabled;
        ShopifyStore."BC Customer Transactions" := TransEnabled;
        ShopifyStore.Insert(false);
        SpfyIntegrationMgt.SetRereadSetup();
        exit(ShopifyStore.Code);
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

    local procedure RunExportJQ(StoreFilter: Text)
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyExportBCTransJQ: Codeunit "NPR Spfy Export BC Trans. JQ";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Parameter String" := CopyStr('store_filter=' + StoreFilter, 1, MaxStrLen(JobQueueEntry."Parameter String"));
        Commit();
        SpfyExportBCTransJQ.Run(JobQueueEntry);
    end;

    local procedure GetStoreMark(StoreCode: Code[20]): BigInteger
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.Get(StoreCode);
        ShopifyStore.CalcFields("Last POS Entry Row Version");
        exit(ShopifyStore."Last POS Entry Row Version");
    end;

    local procedure DeleteExportJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // ZERO export JQ entries may exist during a run: a live JQ session would race the tests, and the store card OnValidate path can create one.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Export BC Trans. JQ");
        JobQueueEntry.SetFilter(Status, '<>%1', JobQueueEntry.Status::"In Process");
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;
}
