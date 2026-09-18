codeunit 85376 "NPR NPRE End Of Sale Tests"
{
    // [FEATURE] Waiter pad billing on end of sale

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_FullBill_BillsEveryWaiterPadLineAndLinksItToThePostedLine()
    var
        FirstItem: Record Item;
        FirstSaleLine: Record "NPR POS Sale Line";
        FirstWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSEntry: Record "NPR POS Entry";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        Seating: Record "NPR NPRE Seating";
        SecondItem: Record Item;
        SecondSaleLine: Record "NPR POS Sale Line";
        SecondWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Paying an order in full bills every line of the waiter pad and closes it

        // [GIVEN] A waiter pad ordering 3 of one item and 1 of another, recalled onto a bill
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(FirstItem, 3);
        CreateItemSaleLine(SecondItem, 1);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(FirstItem."No.", FirstSaleLine);
        FindCurrentItemSaleLine(SecondItem."No.", SecondSaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", FirstItem."No.", FirstWaiterPadLine);
        FindWaiterPadItemLine(WaiterPad."No.", SecondItem."No.", SecondWaiterPadLine);

        // [WHEN] The bill is paid in full
        EndCurrentSale(POSEntry);

        // [THEN] Both waiter-pad lines are billed for their whole ordered quantity
        FirstWaiterPadLine.Get(WaiterPad."No.", FirstWaiterPadLine."Line No.");
        SecondWaiterPadLine.Get(WaiterPad."No.", SecondWaiterPadLine."Line No.");
        _Assert.AreEqual(3, FirstWaiterPadLine."Billed Quantity", 'The first waiter-pad line was not billed in full.');
        _Assert.AreEqual(3, FirstWaiterPadLine."Billed Qty. (Base)", 'The first waiter-pad base quantity was not billed in full.');
        _Assert.AreEqual(1, SecondWaiterPadLine."Billed Quantity", 'The second waiter-pad line was not billed in full.');
        _Assert.AreEqual(1, SecondWaiterPadLine."Billed Qty. (Base)", 'The second waiter-pad base quantity was not billed in full.');

        // [THEN] Each posted line is linked to the waiter-pad line it billed, and to nothing else
        AssertExactWaiterPadLink(POSEntry, FirstSaleLine.SystemId, FirstWaiterPadLine);
        AssertExactWaiterPadLink(POSEntry, SecondSaleLine.SystemId, SecondWaiterPadLine);
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.AreEqual(2, POSWaiterPadLink.Count(), 'The POS entry must contain exactly two waiter-pad links.');

        // [THEN] The waiter pad is closed as a finished sale
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_PartialBill_BillsOnlyTheSoldQuantityAndKeepsThePadOpen()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Billing fewer units than were ordered leaves the rest of the order on an open waiter pad

        // [GIVEN] A waiter pad ordering 3 units, of which only 1 is put on the bill
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 3);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        SaleLine.Validate(Quantity, 1);
        SaleLine.Modify(true);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] Only the billed unit is recorded, and the ordered quantity is untouched
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(3, WaiterPadLine.Quantity, 'Partial billing must not change the ordered waiter-pad quantity.');
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The waiter-pad line must record the partial billed quantity.');
        _Assert.AreEqual(1, WaiterPadLine."Billed Qty. (Base)", 'The waiter-pad line must record the partial billed base quantity.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);

        // [THEN] The waiter pad stays open for the remaining units
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'A partly billed waiter pad must remain open.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_SecondPartialBill_AccumulatesOnTopOfTheFirstAndClosesThePad()
    var
        FirstPOSEntry: Record "NPR POS Entry";
        FirstSaleLine: Record "NPR POS Sale Line";
        Item: Record Item;
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        SecondPOSEntry: Record "NPR POS Entry";
        SecondSaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A split bill is paid over two separate sales that together settle the whole waiter pad

        // [GIVEN] A waiter pad ordering 3 units of which 1 has already been billed and paid
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 3);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", FirstSaleLine);
        FirstSaleLine.Validate(Quantity, 1);
        FirstSaleLine.Modify(true);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        EndCurrentSale(FirstPOSEntry);
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'Test prerequisite: the first partial bill must be recorded.');
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'Test prerequisite: the waiter pad must still be open.');

        // [WHEN] The waiter pad is recalled and the remaining units are paid
        _LibraryRestaurant.LoadWaiterPadIntoCurrentPOSSale(_POSSession, WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SecondSaleLine);
        _Assert.AreEqual(2, SecondSaleLine.Quantity, 'The second bill must load the remaining waiter-pad quantity.');
        EndCurrentSale(SecondPOSEntry);

        // [THEN] The billed quantity of the two bills adds up to the whole order
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(3, WaiterPadLine."Billed Quantity", 'The second bill must accumulate with the first bill.');
        _Assert.AreEqual(3, WaiterPadLine."Billed Qty. (Base)", 'The accumulated billed base quantity is incorrect.');

        // [THEN] Both bills are separate POS entries, each linked to the same waiter-pad line
        _Assert.AreNotEqual(FirstPOSEntry."Entry No.", SecondPOSEntry."Entry No.", 'The partial bills must create separate POS entries.');
        AssertExactWaiterPadLink(FirstPOSEntry, FirstSaleLine.SystemId, WaiterPadLine);
        AssertExactWaiterPadLink(SecondPOSEntry, SecondSaleLine.SystemId, WaiterPadLine);
        POSWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(2, POSWaiterPadLink.Count(), 'The waiter-pad line must have exactly two billing links.');

        // [THEN] The fully settled waiter pad is closed
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ManyWaiterPadLines_BillsEachOfThemExactlyOnce()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        Seating: Record "NPR NPRE Seating";
        TempWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        LineIndex: Integer;
    begin
        // [SCENARIO] Every line of a larger order is billed once - none is skipped and none is billed twice

        // [GIVEN] A waiter pad with five item lines of differing quantities, recalled onto a bill
        InitializeTableServiceScenario(Seating, WaiterPad);
        for LineIndex := 1 to 5 do begin
            Clear(Item);
            CreateItemSaleLine(Item, LineIndex);
        end;
        SaveAndRecallWaiterPad(WaiterPad);
        CopyWaiterPadItemLines(WaiterPad."No.", TempWaiterPadLine);
        _Assert.AreEqual(5, TempWaiterPadLine.Count(), 'The arranged waiter pad must contain exactly five item lines.');

        // [WHEN] The bill is paid in full
        EndCurrentSale(POSEntry);

        // [THEN] Every line is billed for exactly its ordered quantity and linked once
        TempWaiterPadLine.FindSet();
        repeat
            WaiterPadLine.Get(TempWaiterPadLine."Waiter Pad No.", TempWaiterPadLine."Line No.");
            _Assert.AreEqual(WaiterPadLine.Quantity, WaiterPadLine."Billed Quantity", 'A waiter-pad line was skipped or billed more than once.');
            AssertExactWaiterPadLink(POSEntry, TempWaiterPadLine."Sale Line Retail ID", WaiterPadLine);
        until TempWaiterPadLine.Next() = 0;
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.AreEqual(5, POSWaiterPadLink.Count(), 'The POS entry must have exactly five waiter-pad links.');
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_SharedSaleLineId_BillsOnlyTheFirstMatchingWaiterPadLine()
    var
        FirstWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        SecondWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SplitWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] One posted sale line bills only the first matching waiter-pad line after a split

        // [GIVEN] A recalled line split across two pads retains the same sale-line ID on both halves
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 2);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, SplitWaiterPad);
        WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, WaiterPadLine, 1, SplitWaiterPad);
        SaleLine.Validate(Quantity, 1);
        SaleLine.Modify(true);

        WaiterPadLine.Reset();
        WaiterPadLine.SetCurrentKey("Sale Line Retail ID");
        WaiterPadLine.SetRange("Sale Line Retail ID", SaleLine.SystemId);
        _Assert.AreEqual(2, WaiterPadLine.Count(), 'The split must leave two waiter-pad lines linked to one sale line.');
        WaiterPadLine.FindFirst();
        FirstWaiterPadLine := WaiterPadLine;
        WaiterPadLine.Next();
        SecondWaiterPadLine := WaiterPadLine;

        // [WHEN] One half is paid
        EndCurrentSale(POSEntry);

        // [THEN] The first match is billed and linked once; the other half remains unbilled
        FirstWaiterPadLine.Get(FirstWaiterPadLine."Waiter Pad No.", FirstWaiterPadLine."Line No.");
        SecondWaiterPadLine.Get(SecondWaiterPadLine."Waiter Pad No.", SecondWaiterPadLine."Line No.");
        _Assert.AreEqual(1, FirstWaiterPadLine."Billed Quantity", 'The first matching waiter-pad line must be billed.');
        _Assert.AreEqual(0, SecondWaiterPadLine."Billed Quantity", 'The same posted line must not bill a second waiter-pad line.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, FirstWaiterPadLine);
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.AreEqual(1, POSWaiterPadLink.Count(), 'One posted sale line must create exactly one waiter-pad link.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DatabaseGuidFilter_OneThousandTerms_SelectsLastMatchingWaiterPadLine()
    var
        DecoyWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        FilterGuid: Guid;
        MatchingGuid: Guid;
        FilterString: Text;
        GuidIndex: Integer;
    begin
        // [SCENARIO] The database accepts the same 1,000-term GUID filter shape used by end-of-sale billing

        // [GIVEN] A waiter-pad line whose sale-line ID is the last of 1,000 GUIDs and a decoy outside the filter
        MatchingGuid := CreateGuid();
        WaiterPad.Init();
        WaiterPad."No." := CopyStr(Format(CreateGuid()), 1, MaxStrLen(WaiterPad."No."));
        WaiterPad.Insert();

        WaiterPadLine.Init();
        WaiterPadLine."Waiter Pad No." := WaiterPad."No.";
        WaiterPadLine."Line No." := 10000;
        WaiterPadLine."Register No." := 'FILTER';
        WaiterPadLine."Sale Line Retail ID" := MatchingGuid;
        WaiterPadLine.Insert();

        DecoyWaiterPadLine.Init();
        DecoyWaiterPadLine."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        DecoyWaiterPadLine."Line No." := 20000;
        DecoyWaiterPadLine."Register No." := 'FILTER';
        DecoyWaiterPadLine."Sale Line Retail ID" := CreateGuid();
        DecoyWaiterPadLine.Insert();

        for GuidIndex := 1 to 1000 do begin
            if GuidIndex = 1000 then
                FilterGuid := MatchingGuid
            else
                FilterGuid := CreateGuid();
            if FilterString <> '' then
                FilterString += '|';
            FilterString += Format(FilterGuid);
        end;

        // [WHEN] The same filter shape used by end-of-sale billing is applied to the database table
        WaiterPadLine.Reset();
        WaiterPadLine.SetCurrentKey("Sale Line Retail ID");
        WaiterPadLine.SetFilter("Sale Line Retail ID", FilterString);

        // [THEN] The matching waiter-pad line is found without truncating the filter
        _Assert.AreEqual(1, WaiterPadLine.Count(), 'The 1,000-GUID filter must select only the matching waiter-pad line.');
        _Assert.IsTrue(WaiterPadLine.FindFirst(), 'The 1,000-GUID filter did not find the matching waiter-pad line.');
        _Assert.AreEqual(MatchingGuid, WaiterPadLine."Sale Line Retail ID", 'The 1,000-GUID filter found the wrong waiter-pad line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_UoMFactorChangedAfterOrdering_BillsUsingTheHistoricalFactor()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] When the sales unit of measure is redefined between ordering and billing, the base quantity is what reconciles the two

        // [GIVEN] An order taken at 2 units per sales unit of measure
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateSaleItem(Item);
        _LibraryRestaurant.CreateItemSalesUnitOfMeasure(Item, ItemUnitOfMeasure, 2);
        _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        SaleLine.Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
        SaleLine.Modify(true);
        SaveAndStartNewSale(WaiterPad);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        _Assert.AreEqual(2, WaiterPadLine."Qty. per Unit of Measure", 'The waiter-pad line must retain the original UOM factor.');

        // [GIVEN] The unit of measure is redefined to 3 units before the order is recalled
        _LibraryRestaurant.SetItemUnitOfMeasureFactor(ItemUnitOfMeasure, 3);
        _LibraryRestaurant.LoadWaiterPadIntoCurrentPOSSale(_POSSession, WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        _Assert.AreEqual(3, SaleLine."Qty. per Unit of Measure", 'The reloaded sale line must use the changed UOM factor.');
        _Assert.AreEqual(3, SaleLine."Quantity (Base)", 'The reloaded sale line base quantity is incorrect.');

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad keeps its historical factor and converts the posted base quantity through it
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(2, WaiterPadLine."Qty. per Unit of Measure", 'Billing must not rewrite the waiter-pad historical UOM factor.');
        _Assert.AreEqual(3, WaiterPadLine."Billed Qty. (Base)", 'The posted base quantity must be accumulated on the waiter-pad line.');
        _Assert.AreEqual(1.5, WaiterPadLine."Billed Quantity", 'The billed quantity must be converted with the waiter-pad historical UOM factor.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ZeroQuantityLine_IsLinkedButNotBilled()
    var
        PaidItem: Record Item;
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ZeroedItem: Record Item;
        ZeroedSaleLine: Record "NPR POS Sale Line";
    begin
        // [SCENARIO] A line whose quantity is taken down to zero before payment is recorded as handled without being billed

        // [GIVEN] A recalled waiter pad with a paid line and a second line zeroed out on the bill
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(PaidItem, 1);
        CreateItemSaleLine(ZeroedItem, 2);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(ZeroedItem."No.", ZeroedSaleLine);
        ZeroedSaleLine.Validate(Quantity, 0);
        ZeroedSaleLine.Modify(true);
        FindWaiterPadItemLine(WaiterPad."No.", ZeroedItem."No.", WaiterPadLine);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The zeroed line is linked to its posted line but its billed quantity stays at zero
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(0, WaiterPadLine."Billed Quantity", 'A zero-quantity line must not be billed.');
        _Assert.AreEqual(0, WaiterPadLine."Billed Qty. (Base)", 'A zero-quantity line must not be billed in base quantity.');
        AssertExactWaiterPadLink(POSEntry, ZeroedSaleLine.SystemId, WaiterPadLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ItemAddedStraightToTheBill_IsPostedWithoutAWaiterPadLink()
    var
        OrderedItem: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        Seating: Record "NPR NPRE Seating";
        WalkInItem: Record Item;
        WalkInSaleLine: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] An item rung up straight onto the bill is sold normally but does not belong to the waiter pad

        // [GIVEN] A recalled waiter pad with one ordered item, plus an item added directly to the bill
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(OrderedItem, 1);
        SaveAndRecallWaiterPad(WaiterPad);
        CreateItemSaleLine(WalkInItem, 1);
        FindCurrentItemSaleLine(WalkInItem."No.", WalkInSaleLine);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The directly added item is posted but is linked to no waiter-pad line
        POSEntrySalesLine.GetBySystemId(WalkInSaleLine.SystemId);
        _Assert.AreEqual(POSEntry."Entry No.", POSEntrySalesLine."POS Entry No.", 'The directly added item was not posted with the bill.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSWaiterPadLink.SetRange("POS Entry Sales Line No.", POSEntrySalesLine."Line No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'An item added straight to the bill must not be linked to the waiter pad.');

        // [THEN] Only the ordered item is linked to the waiter pad
        POSWaiterPadLink.SetRange("POS Entry Sales Line No.");
        POSWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.AreEqual(1, POSWaiterPadLink.Count(), 'Only the recalled waiter-pad line may be linked to the POS entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_POSUnitWithoutARestaurant_PostsWithoutAnyWaiterPadWork()
    var
        Item: Record Item;
        NonRestaurantPOSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] A sale on a POS unit that is not part of a restaurant posts as an ordinary sale

        // [GIVEN] A restaurant exists in the database, and a POS unit that is not attached to it
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateNonRestaurantPOSUnit(NonRestaurantPOSUnit);
        _POSSession.ClearAll();
        Clear(_POSSession);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, NonRestaurantPOSUnit, POSSale);
        CreateSaleItem(Item);
        _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);
        FindCurrentItemSaleLine(Item."No.", SaleLine);

        // [WHEN] The sale is paid
        EndCurrentSale(POSEntry);

        // [THEN] The line is posted, and no waiter-pad link is produced anywhere on the entry
        POSEntrySalesLine.GetBySystemId(SaleLine.SystemId);
        _Assert.AreEqual(POSEntry."Entry No.", POSEntrySalesLine."POS Entry No.", 'The sale line was not posted.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'A sale on a non-restaurant POS unit must not create waiter-pad links.');

        // [THEN] The unrelated waiter pad is left untouched
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'A sale on a non-restaurant POS unit must not close another unit''s waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_FastFoodPadCreatedDuringTheSale_IsBilledAndClosed()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WPadAction: Option "Print Pre-Receipt","Send Kitchen Order","Request Next Serving","Request Specific Serving","Merge Waiter Pad","Close w/out Saving";
    begin
        // [SCENARIO] In a fast-food flow the order is sent to the kitchen from the open sale, and paying it bills and closes the pad

        // [GIVEN] An open fast-food sale of a kitchen-routed item, pre-set to a waiter pad and seating
        InitializeFastFoodScenario(Seating, WaiterPad);
        CreateSaleItem(Item);
        _LibraryRestaurant.SetupItemForKitchenOrders(Item);
        _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 2);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        PreSetWaiterPadOnCurrentSale(WaiterPad, Seating);

        // [GIVEN] The serving is requested, which moves the sale line onto the waiter pad
        _LibraryRestaurant.RunWaiterPadAction(_POSSession, WPadAction::"Request Next Serving", false);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        _Assert.AreEqual(SaleLine.SystemId, WaiterPadLine."Sale Line Retail ID", 'The fast-food waiter-pad line is not linked to the active POS sale line.');

        // [WHEN] The sale is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter-pad line is billed, linked, and the pad is closed
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(2, WaiterPadLine."Billed Quantity", 'The fast-food waiter-pad line was not billed on end of sale.');
        _Assert.AreEqual(2, WaiterPadLine."Billed Qty. (Base)", 'The fast-food waiter-pad base quantity was not billed on end of sale.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_PreSetWaiterPadWithNothingOrdered_IsClosedAnyway()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A waiter pad that was opened but never ordered on is released when the sale it is attached to ends

        // [GIVEN] An empty waiter pad pre-set on a sale that bills an unrelated item
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 1);
        PreSetWaiterPadOnCurrentSale(WaiterPad, Seating);

        // [WHEN] The sale is paid
        EndCurrentSale(POSEntry);

        // [THEN] The empty waiter pad is closed as a finished sale
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_SavedWaiterPadWithUnsupportedPayment_BillsLinkedLinesWithoutPreSetPad()
    var
        Item: Record Item;
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Finishing a sale that could not be cleared after saving to a waiter pad still bills its linked lines

        // [GIVEN] An item and a partial payment are saved to a waiter pad, so unsupported-line cleanup cannot clear the sale
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 1);
        InsertPartialPaymentLine(PaymentSaleLine);
        _Assert.IsFalse(
          _LibraryRestaurant.SaveCurrentPOSSaleToWaiterPad(_POSSession, WaiterPad, true),
          'Saving a sale with a payment line must leave the sale open.');

        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Assert.AreEqual('', SalePOS."NPRE Pre-Set Waiter Pad No.", 'The save-to-waiter-pad flow must not pre-set the waiter pad on the sale.');
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        _Assert.AreEqual(SalePOS.SystemId, WaiterPadLine."Sale Retail ID", 'The waiter-pad line must remain linked to the open sale.');

        // [WHEN] The unsupported partial payment is removed and the remaining sale is paid
        PaymentSaleLine.Delete(true);
        EndCurrentSale(POSEntry);

        // [THEN] The header-level sale link admits billing even though no waiter pad was pre-set
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The saved waiter-pad line was not billed.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_GlobalSetupWithPOSUnitProfile_BillsAndClosesPreSetWaiterPad()
    var
        ExistingPOSEntry: Record "NPR POS Entry";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
        ExistingReceiptNo: BigInteger;
        ReceiptNo: BigInteger;
    begin
        // [SCENARIO] A POS unit profile with no restaurant code uses global setup to bill and close a pre-set waiter pad

        // [GIVEN] Posted receipts already exist before the global restaurant fixture creates its POS unit
        ExistingPOSEntry."Document No." := '900000000000000000';
        ExistingPOSEntry.Insert(false);
        Evaluate(ExistingReceiptNo, ExistingPOSEntry."Document No.");
        Clear(ExistingPOSEntry);
        ExistingPOSEntry."Document No." := 'LEGACY-RECEIPT';
        ExistingPOSEntry.Insert(false);

        // [GIVEN] A POS unit profile with no restaurant code, global setup, and a recalled waiter pad
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestaurantProfile, '');
        InitializeGlobalRestaurantSetupScenario(Seating, WaiterPad, POSRestaurantProfile.Code, '');
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Evaluate(ReceiptNo, SalePOS."Sales Ticket No.");
        _Assert.IsTrue(ReceiptNo > ExistingReceiptNo, 'The fixture must allocate receipts above existing numeric receipt numbers.');
        CreateItemSaleLine(Item, 1);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);

        // [WHEN] The waiter-pad item is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter-pad line is billed and linked using global restaurant settings
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The global-setup waiter-pad line was not billed.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);

        // [THEN] The pre-set waiter pad closes and releases its seating
        AssertWaiterPadClosed(WaiterPad);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The seating must be released when the pre-set waiter pad closes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_GlobalSetupWithPOSStoreProfile_ClosesEmptyPreSetWaiterPad()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] An inherited store profile with no restaurant code closes an empty pad using global setup

        // [GIVEN] A store profile with no restaurant code, no unit profile, and an empty pre-set pad
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestaurantProfile, '');
        InitializeGlobalRestaurantSetupScenario(Seating, WaiterPad, '', POSRestaurantProfile.Code);
        _POSUnit.TestField("POS Restaurant Profile", '');
        _POSStore.TestField("POS Restaurant Profile", POSRestaurantProfile.Code);
        CreateItemSaleLine(Item, 1);
        PreSetWaiterPadOnCurrentSale(WaiterPad, Seating);
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'The pre-set pad must have no lines to close it during billing.');
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The seating must be occupied before the sale finishes.');

        // [WHEN] An unrelated item is paid through normal sale completion
        EndCurrentSale(POSEntry);

        // [THEN] The pre-set pad closes and releases its seating without creating billing links
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        AssertWaiterPadClosed(WaiterPad);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The empty pre-set pad must release its seating.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'An empty pad must not create a waiter-pad billing link.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelSale_RecalledPad_PreservesBilledQuantityAndOtherSaleLines()
    var
        Item: Record Item;
        OtherSaleLine: Record "NPR NPRE Waiter Pad Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        CancelSaleAction: Codeunit "NPR POSAction: Cancel Sale B";
        POSSale: Codeunit "NPR POS Sale";
        OtherSaleId: Guid;
        OtherSaleLineId: Guid;
    begin
        // [SCENARIO] Cancelling a recalled bill preserves billed quantities and lines owned by other sales

        // [GIVEN] A recalled pad line with one unit already billed and one still outstanding
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateSaleItem(Item);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 2, 0, WaiterPadLine);
        _LibraryRestaurant.SetWaiterPadLineBilledQuantity(WaiterPadLine, 1);
        _LibraryRestaurant.LoadWaiterPadIntoCurrentPOSSale(_POSSession, WaiterPad);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Another sale owns a line added after recall, avoiding the other-sale recall confirmation
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, OtherSaleLine);
        OtherSaleId := CreateGuid();
        OtherSaleLineId := CreateGuid();
        OtherSaleLine."Sale Retail ID" := OtherSaleId;
        OtherSaleLine."Sale Line Retail ID" := OtherSaleLineId;
        OtherSaleLine.Modify(true);

        // [WHEN] The cancel-sale business action completes the POS sale
        _Assert.IsTrue(CancelSaleAction.CancelSale(), 'The cancel-sale action must finish the POS sale.');

        // [THEN] A cancellation entry is created without billing or linking any items
        POSEntry.GetBySystemId(SalePOS.SystemId);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        _Assert.IsTrue(POSEntrySalesLine.IsEmpty(), 'A cancelled sale must not post item lines.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'A cancelled sale must not create waiter-pad billing links.');
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine.Quantity, 'Cancellation must remove only the outstanding quantity.');
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'Cancellation must preserve the quantity already billed.');

        // [THEN] The other sale retains its line and keeps the pad open
        OtherSaleLine.Get(WaiterPad."No.", OtherSaleLine."Line No.");
        _Assert.AreEqual(1, OtherSaleLine.Quantity, 'Cancellation must leave the other sale quantity unchanged.');
        _Assert.AreEqual(0, OtherSaleLine."Billed Quantity", 'Cancellation must not bill the other sale line.');
        _Assert.AreEqual(OtherSaleId, OtherSaleLine."Sale Retail ID", 'Cancellation must preserve the other sale ownership.');
        _Assert.AreEqual(OtherSaleLineId, OtherSaleLine."Sale Line Retail ID", 'Cancellation must preserve the other sale line link.');
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'The other sale still has outstanding quantity on the pad.');
        WaiterPad.TestField("Close Reason", WaiterPad."Close Reason"::Undefined);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancelSale')]
    procedure EndSale_AfterPartlyPaidLoginCancellationFails_BillsAndClosesWaiterPad()
    var
        Item: Record Item;
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ChangeViewAction: Codeunit "NPR POS Action: Change View-B";
        POSSale: Codeunit "NPR POS Sale";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
    begin
        // [SCENARIO] Paying after a rejected login-view cancellation still settles the recalled waiter pad

        // [GIVEN] A recalled item priced at 10 with a partial payment of 1
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 1);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        InsertPartialPaymentLine(PaymentSaleLine);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] Attempting to log out commits the cleared header links before cancellation rejects the payment
        ChangeViewAction.ChangeView(ViewType::Sale, '');
        asserterror ChangeViewAction.ChangeView(ViewType::Login, '');
        _Assert.ExpectedError('It has been partly paid.');
        SalePOS.GetBySystemId(SalePOS.SystemId);
        SalePOS.TestField("NPRE Pre-Set Waiter Pad No.", '');
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.IsTrue(IsNullGuid(WaiterPadLine."Sale Retail ID"), 'Failed cancellation must leave the committed header link cleared.');
        _Assert.AreEqual(SaleLine.SystemId, WaiterPadLine."Sale Line Retail ID", 'Failed cancellation must retain the billable sale-line link.');
        _Assert.IsTrue(SaleLine.GetBySystemId(SaleLine.SystemId), 'Failed cancellation must preserve the item on the sale.');
        _Assert.IsTrue(PaymentSaleLine.GetBySystemId(PaymentSaleLine.SystemId), 'Failed cancellation must preserve the partial payment.');

        // [WHEN] Paying the remaining balance of 9 completes the surviving sale
        _Assert.IsTrue(
          _LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 9, ''),
          'The sale must finish after paying its remaining balance.');

        // [THEN] The paid item is billed and linked exactly once, and the pad releases its seating
        POSEntry.GetBySystemId(SalePOS.SystemId);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The waiter-pad item must be billed after the failed cancellation.');
        _Assert.AreEqual(1, WaiterPadLine."Billed Qty. (Base)", 'The waiter-pad base quantity must be billed after the failed cancellation.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
        AssertWaiterPadClosed(WaiterPad);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The paid waiter pad must release its seating.');
    end;

    [ConfirmHandler]
    procedure ConfirmCancelSale(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditSale_RecalledPad_ExportBillsAndClosesWaiterPad()
    var
        Customer: Record Customer;
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        SalesHeader: Record "Sales Header";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        LibrarySales: Codeunit "Library - Sales";
        POSSale: Codeunit "NPR POS Sale";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
    begin
        // [SCENARIO] Exporting a recalled bill to a sales order bills its waiter-pad item and closes the pad

        // [GIVEN] A recalled waiter-pad item and a customer for credit-sale export
        InitializeTableServiceScenario(Seating, WaiterPad);
        CreateItemSaleLine(Item, 1);
        SaveAndRecallWaiterPad(WaiterPad);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        LibrarySales.CreateCustomerWithAddress(Customer);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Assert.IsTrue(
          SelectCustomerAction.AttachCustomer(SalePOS, '', 0, Customer."No.", false),
          'The customer must be attached before exporting a credit sale.');

        // [WHEN] The recalled bill is exported to a sales order through the normal export business function
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [THEN] Credit-sale posting bills and links the waiter-pad item and closes the pad
        SalesDocumentExportMgt.GetCreatedSalesHeader(SalesHeader);
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.TestField("Sell-to Customer No.", Customer."No.");
        POSEntry.GetBySystemId(SalePOS.SystemId);
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");
        _Assert.IsFalse(SalePOS.Find(), 'Credit-sale export must end the POS sale.');
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'Credit-sale export must bill the recalled waiter-pad item.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
        AssertWaiterPadClosed(WaiterPad);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_NoRestaurantProfileOrPreSetPad_BillsSaleLinkedWaiterPad()
    var
        Item: Record Item;
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        SaleLine: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] A saved waiter-pad item is billed without a restaurant profile or a pre-set pad

        // [GIVEN] A POS unit without a restaurant profile saves an item while a payment prevents sale cleanup
        InitializeGlobalRestaurantSetupScenario(Seating, WaiterPad, '', '');
        _POSUnit.TestField("POS Restaurant Profile", '');
        _POSStore.TestField("POS Restaurant Profile", '');
        CreateItemSaleLine(Item, 1);
        InsertPartialPaymentLine(PaymentSaleLine);
        _Assert.IsFalse(
          _LibraryRestaurant.SaveCurrentPOSSaleToWaiterPad(_POSSession, WaiterPad, true),
          'The partial payment must keep the saved sale open.');

        // [GIVEN] Only the live sale links identify the waiter-pad work; no pad is pre-set on the sale
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("NPRE Pre-Set Waiter Pad No.", '');
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        FindWaiterPadItemLine(WaiterPad."No.", Item."No.", WaiterPadLine);
        WaiterPadLine.TestField("Sale Retail ID", SalePOS.SystemId);
        WaiterPadLine.TestField("Sale Line Retail ID", SaleLine.SystemId);
        _Assert.AreEqual(0, WaiterPadLine."Billed Quantity", 'The saved waiter-pad item must not already be billed.');

        // [WHEN] The partial payment is removed and the sale is paid normally
        PaymentSaleLine.Delete(true);
        EndCurrentSale(POSEntry);

        // [THEN] Sale-linked waiter-pad work is billed and closed even without a profile or pre-set pad
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The no-profile sale must bill its linked waiter-pad item.');
        _Assert.AreEqual(1, WaiterPadLine."Billed Qty. (Base)", 'The no-profile sale must bill its linked waiter-pad base quantity.');
        AssertExactWaiterPadLink(POSEntry, SaleLine.SystemId, WaiterPadLine);
        AssertWaiterPadClosed(WaiterPad);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'Closing the paid waiter pad must release its seating.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_NoProfileWithOnlySaleLineLink_SkipsWaiterPadProcessing()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        SaleLine: Record "NPR POS Sale Line";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A sale-line link alone does not enable waiter-pad processing without a profile or header link

        // [GIVEN] A profile-less POS sale has a matching waiter-pad line whose header link is cleared
        InitializeGlobalRestaurantSetupScenario(Seating, WaiterPad, '', '');
        _POSUnit.TestField("POS Restaurant Profile", '');
        _POSStore.TestField("POS Restaurant Profile", '');
        CreateItemSaleLine(Item, 1);
        FindCurrentItemSaleLine(Item."No.", SaleLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
        WaiterPadLine."Sale Line Retail ID" := SaleLine.SystemId;
        WaiterPadLine.Modify(true);
        _Assert.IsTrue(IsNullGuid(WaiterPadLine."Sale Retail ID"), 'Test prerequisite: the waiter-pad line must have no sale-header link.');

        // [WHEN] The item is paid normally
        EndCurrentSale(POSEntry);

        // [THEN] The sale posts without billing or closing the waiter pad through its remaining line link
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        WaiterPadLine.Get(WaiterPad."No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(0, WaiterPadLine."Billed Quantity", 'A line link alone must not enable waiter-pad billing without a profile.');
        _Assert.AreEqual(0, WaiterPadLine."Billed Qty. (Base)", 'A line link alone must not enable waiter-pad base-quantity billing.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'The skipped waiter-pad line must not create a billing link.');
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'The skipped waiter pad must remain open.');
        WaiterPad.TestField("Close Reason", WaiterPad."Close Reason"::Undefined);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The skipped waiter pad must not release its seating.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_NoRestaurantProfile_LeavesEmptyPreSetWaiterPadOpen()
    var
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Global setup and a pre-set pad do not enable restaurant processing on a POS without a profile

        // [GIVEN] A POS with no unit or store profile has an empty pre-set waiter pad
        InitializeGlobalRestaurantSetupScenario(Seating, WaiterPad, '', '');
        _POSUnit.TestField("POS Restaurant Profile", '');
        _POSStore.TestField("POS Restaurant Profile", '');
        CreateItemSaleLine(Item, 1);
        PreSetWaiterPadOnCurrentSale(WaiterPad, Seating);
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'The pre-set pad must have no lines.');
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The seating must be occupied before the sale finishes.');

        // [WHEN] The retail item is paid normally
        EndCurrentSale(POSEntry);

        // [THEN] The sale posts without closing the empty pad or releasing its seating
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'The no-profile sale must not close even an empty pre-set waiter pad.');
        WaiterPad.TestField("Close Reason", WaiterPad."Close Reason"::Undefined);
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The no-profile sale must not release the pre-set waiter-pad seating.');
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSWaiterPadLink.IsEmpty(), 'The no-profile sale must not create waiter-pad billing links.');
    end;

    local procedure InitializeTableServiceScenario(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryRestaurant.SetupTableServiceRestaurant(_POSUnit, Seating, ServiceFlowProfile);
        _LibraryRestaurant.SetServiceFlowWaiterPadClosing(ServiceFlowProfile.Code, ServiceFlowProfile."Close Waiter Pad On"::Payment, true);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
    end;

    local procedure InitializeFastFoodScenario(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryRestaurant.SetupRestaurantForKitchenOrders(_POSUnit, Seating);
        _LibraryRestaurant.GetPOSUnitServiceFlowProfile(_POSUnit, ServiceFlowProfile);
        _LibraryRestaurant.SetServiceFlowWaiterPadClosing(ServiceFlowProfile.Code, ServiceFlowProfile."Close Waiter Pad On"::Payment, true);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
    end;

    local procedure InitializeGlobalRestaurantSetupScenario(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad"; POSUnitRestaurantProfileCode: Code[20]; POSStoreRestaurantProfileCode: Code[20])
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSRestaurantProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        SeatingLocation: Record "NPR NPRE Seating Location";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _POSStore.GetProfile(POSPostingProfile);
        _LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        _POSStore."POS Restaurant Profile" := POSStoreRestaurantProfileCode;
        _POSStore.Modify(true);
        _LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        _POSUnit."POS Restaurant Profile" := POSUnitRestaurantProfileCode;
        _POSUnit.Modify(true);
        SetReceiptNoSeriesAbovePostedReceipts(_POSUnit);
        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateServiceFlowProfile(ServiceFlowProfile);
        _LibraryRestaurant.SetServiceFlowWaiterPadClosing(ServiceFlowProfile.Code, ServiceFlowProfile."Close Waiter Pad On"::Payment, true);
        RestaurantSetup.Get();
        RestaurantSetup."Default Service Flow Profile" := ServiceFlowProfile.Code;
        RestaurantSetup.Modify(true);

        _LibraryRestaurant.CreateSeatingLocation(SeatingLocation, '');
        _LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        _POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSRestProfile(POSRestaurantProfile);
        if POSUnitRestaurantProfileCode <> '' then
            POSRestaurantProfile.TestField(Code, POSUnitRestaurantProfileCode)
        else
            POSRestaurantProfile.TestField(Code, POSStoreRestaurantProfileCode);
        _Assert.AreEqual('', POSSetup.RestaurantCode(), 'Test prerequisite: the POS session must not resolve a restaurant code.');
    end;

    local procedure SetReceiptNoSeriesAbovePostedReceipts(POSUnit: Record "NPR POS Unit")
    var
        NoSeriesLine: Record "No. Series Line";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEntry: Record "NPR POS Entry";
        HighestReceiptNo: BigInteger;
        ReceiptNo: BigInteger;
    begin
        POSEntry.SetFilter("Document No.", '<>%1', '');
        if POSEntry.FindSet() then
            repeat
                if DelChr(POSEntry."Document No.", '=', '0123456789') = '' then begin
                    Evaluate(ReceiptNo, POSEntry."Document No.");
                    if ReceiptNo > HighestReceiptNo then
                        HighestReceiptNo := ReceiptNo;
                end;
            until POSEntry.Next() = 0;

        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        NoSeriesLine.SetRange("Series Code", POSAuditProfile."Sales Ticket No. Series");
        NoSeriesLine.FindFirst();
        // Recreate this unused sequence so its next value follows the new starting number.
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Normal);
        NoSeriesLine.Validate("Starting No.", Format(HighestReceiptNo + Random(1000), 0, 9));
        NoSeriesLine.Validate(Implementation, NoSeriesLine.Implementation::Sequence);
        NoSeriesLine.Modify(true);
    end;

    local procedure CreateNonRestaurantPOSUnit(var NonRestaurantPOSUnit: Record "NPR POS Unit")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        _POSStore.GetProfile(POSPostingProfile);
        _LibraryPOSMasterData.CreatePOSUnit(NonRestaurantPOSUnit, _POSStore.Code, POSPostingProfile.Code);
        _Assert.AreEqual('', NonRestaurantPOSUnit."POS Restaurant Profile", 'Test prerequisite: the POS unit must not belong to a restaurant.');
    end;

    local procedure PreSetWaiterPadOnCurrentSale(WaiterPad: Record "NPR NPRE Waiter Pad"; Seating: Record "NPR NPRE Seating")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS."NPRE Pre-Set Seating Code" := Seating.Code;
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;

    local procedure CreateItemSaleLine(var Item: Record Item; Quantity: Decimal)
    begin
        CreateSaleItem(Item);
        _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", Quantity);
    end;

    local procedure InsertPartialPaymentLine(var PaymentSaleLine: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(PaymentSaleLine);
        PaymentSaleLine."No." := _POSPaymentMethod.Code;
        PaymentSaleLine."Amount Including VAT" := 1;
        PaymentSaleLine.Amount := 1;
        _Assert.IsTrue(POSPaymentLine.InsertPaymentLine(PaymentSaleLine, 0), 'The partial payment line was not inserted.');

        PaymentSaleLine.Reset();
        PaymentSaleLine.SetRange("Register No.", SalePOS."Register No.");
        PaymentSaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        PaymentSaleLine.SetRange("Line Type", PaymentSaleLine."Line Type"::"POS Payment");
        PaymentSaleLine.SetRange("No.", _POSPaymentMethod.Code);
        PaymentSaleLine.FindLast();
    end;

    local procedure CreateSaleItem(var Item: Record Item)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
    end;

    local procedure SaveAndRecallWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        SaveAndStartNewSale(WaiterPad);
        _LibraryRestaurant.LoadWaiterPadIntoCurrentPOSSale(_POSSession, WaiterPad);
    end;

    local procedure SaveAndStartNewSale(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Assert.IsTrue(
          _LibraryRestaurant.SaveCurrentPOSSaleToWaiterPad(_POSSession, WaiterPad, true),
          'The POS sale was not cleared after being saved to the waiter pad.');
        SalePOS.Find();
        SalePOS.Delete(true);

        _POSSession.ClearAll();
        Clear(_POSSession);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
    end;

    local procedure CopyWaiterPadItemLines(WaiterPadNo: Code[20]; var TempWaiterPadLine: Record "NPR NPRE Waiter Pad Line" temporary)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        TempWaiterPadLine.Reset();
        TempWaiterPadLine.DeleteAll();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        if not WaiterPadLine.FindSet() then
            exit;
        repeat
            TempWaiterPadLine := WaiterPadLine;
            TempWaiterPadLine.Insert();
        until WaiterPadLine.Next() = 0;
    end;

    local procedure FindCurrentItemSaleLine(ItemNo: Code[20]; var SaleLine: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SaleLine.Reset();
        SaleLine.SetRange("Register No.", SalePOS."Register No.");
        SaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLine.SetRange("Line Type", SaleLine."Line Type"::Item);
        SaleLine.SetRange("No.", ItemNo);
        SaleLine.FindFirst();
    end;

    local procedure FindWaiterPadItemLine(WaiterPadNo: Code[20]; ItemNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        WaiterPadLine.SetRange("No.", ItemNo);
        WaiterPadLine.FindFirst();
    end;

    local procedure EndCurrentSale(var POSEntry: Record "NPR POS Entry")
    var
        SalePOS: Record "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        SubTotal: Decimal;
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        _Assert.IsTrue(
          _LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, ''),
          'The restaurant sale did not end.');
        POSEntry.GetBySystemId(SalePOS.SystemId);
    end;

    local procedure AssertExactWaiterPadLink(POSEntry: Record "NPR POS Entry"; SourceSaleLineSystemId: Guid; WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
    begin
        POSEntrySalesLine.GetBySystemId(SourceSaleLineSystemId);
        _Assert.AreEqual(POSEntry."Entry No.", POSEntrySalesLine."POS Entry No.", 'The posted source line belongs to another POS entry.');

        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSWaiterPadLink.SetRange("POS Entry Sales Line No.", POSEntrySalesLine."Line No.");
        _Assert.AreEqual(1, POSWaiterPadLink.Count(), 'The posted source line must have exactly one waiter-pad link.');

        POSWaiterPadLink.Reset();
        POSWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadLine."Waiter Pad No.");
        POSWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, POSWaiterPadLink.Count(), 'The waiter-pad line must have exactly one link in the POS entry.');

        _Assert.IsTrue(
          POSWaiterPadLink.Get(POSEntry."Entry No.", POSEntrySalesLine."Line No.", WaiterPadLine."Waiter Pad No.", WaiterPadLine."Line No."),
          'The posted source line is not linked to the expected waiter-pad line.');
    end;

    local procedure AssertWaiterPadClosed(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsTrue(WaiterPad.Closed, 'The waiter pad must be closed when its sale finishes.');
        _Assert.AreEqual("NPR NPRE W/Pad Closing Reason"::"Finished Sale", WaiterPad."Close Reason", 'The waiter pad close reason is incorrect.');
    end;
}
