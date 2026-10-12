codeunit 85100 "NPR POS ActMergeSimLines Tests"
{
    // [FEATURE] POS Action Merge Similar Lines: merge sale lines of the same item, price and tracking into one line

    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSimilarLines()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // [Given] Active POS session & sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 5);

        POSSale.GetCurrentSale(SalePOS);

        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.FindFirst();

        Assert.IsTrue(SaleLinePOS.Quantity = 6, 'Quantity merged');
        Assert.IsTrue(SaleLinePOS."No." = Item."No.", 'Item inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeKeepsDifferentLotsOnSeparateLines()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNoA: Code[50];
        LotNoB: Code[50];
    begin
        // [SCENARIO] Lines of the same item with different lot numbers are not merged.
        // [GIVEN] A lot tracked item with 10 in stock for lot A and 10 for lot B
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNoA := LibraryUtility.GenerateGUID();
        LotNoB := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNoA, 10);
        PostPositiveAdjustment(Item, LotNoB, 10);

        // [GIVEN] One line of 1 for lot A and one line of 1 for lot B
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoB);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] Each lot keeps its own line with quantity 1
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines with different lots must not be merged');
        SaleLinePOS.SetRange("Lot No.", LotNoA);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(1, SaleLinePOS.Quantity, 'Quantity for lot A');
        SaleLinePOS.SetRange("Lot No.", LotNoB);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(1, SaleLinePOS.Quantity, 'Quantity for lot B');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSameLotUpToFullStock()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNo: Code[50];
    begin
        // [SCENARIO] Lines with the same lot merge into one line when the total equals the lot's full stock.
        // [GIVEN] A lot tracked item with 10 in stock for lot A
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNo := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNo, 10);

        // [GIVEN] Lines of 1 and 9 for lot A, which use the whole stock
        AddItemLineWithLot(Item, 1, LotNo);
        AddItemLineWithLot(Item, 9, LotNo);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] One line of 10 for lot A remains
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(1, SaleLinePOS.Count(), 'Lines with the same lot must be merged');
        SaleLinePOS.FindFirst();
        Assert.AreEqual(10, SaleLinePOS.Quantity, 'Merged quantity');
        Assert.AreEqual(LotNo, SaleLinePOS."Lot No.", 'Lot No. of the merged line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSameLotWithStockUsedByAnotherSale()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNo: Code[50];
    begin
        // [SCENARIO] Lines with the same lot merge when the total fits the stock left after another open sale.
        // [GIVEN] A lot tracked item with 10 in stock for lot A, 6 of it on a line in another open sale
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNo := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNo, 10);
        InsertLineInOtherSale(Item, LotNo, 6);

        // [GIVEN] Two lines of 2 for lot A in this sale, which use the remaining stock
        AddItemLineWithLot(Item, 2, LotNo);
        AddItemLineWithLot(Item, 2, LotNo);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] One line of 4 for lot A remains in this sale
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(1, SaleLinePOS.Count(), 'Lines with the same lot must be merged');
        SaleLinePOS.FindFirst();
        Assert.AreEqual(4, SaleLinePOS.Quantity, 'Merged quantity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSameLotOverStockFailsAndKeepsLines()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotItem: Record Item;
        LotNo: Code[50];
    begin
        // [SCENARIO] When the merged quantity of a lot exceeds its stock, the merge fails and every line keeps its quantity.
        // [GIVEN] Two lines of 1 for an item without tracking
        // The untracked item is added first, so its group is inserted and committed before the lot group is validated.
        // This is what lets the test catch a commit before validation.
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        // [GIVEN] Two lines of 3 for lot A of a lot tracked item with 10 in stock
        CreateLotItem(LotItem);
        LotNo := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(LotItem, LotNo, 10);
        AddItemLineWithLot(LotItem, 3, LotNo);
        AddItemLineWithLot(LotItem, 3, LotNo);

        // [GIVEN] Another open sale takes 6 of lot A, so a merged line of 6 exceeds the stock
        InsertLineInOtherSale(LotItem, LotNo, 6);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        asserterror POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] The stock error is raised and all four lines keep their quantities
        Assert.ExpectedError('is not in the stock');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(4, SaleLinePOS.Count(), 'Number of lines after the failed merge');
        SaleLinePOS.SetRange("No.", Item."No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines of the item without tracking');
        SaleLinePOS.SetFilter(Quantity, '<>%1', 1);
        Assert.RecordIsEmpty(SaleLinePOS);
        SaleLinePOS.SetRange(Quantity);
        SaleLinePOS.SetRange("No.", LotItem."No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines of the lot tracked item');
        SaleLinePOS.SetFilter(Quantity, '<>%1', 3);
        Assert.RecordIsEmpty(SaleLinePOS);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeKeepsSerialNoLinesSeparate()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryCoupon: Codeunit "NPR Library Coupon";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        SerialNo1: Code[50];
        SerialNo2: Code[50];
    begin
        // [SCENARIO] Lines of a serial-tracked item with different serial numbers are not merged.
        // [GIVEN] A serial tracked item with one line per serial number
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryCoupon.CreateItemTrackingAndAssignToItem(Item, ItemTrackingCode);
        SerialNo1 := LibraryUtility.GenerateGUID();
        SerialNo2 := LibraryUtility.GenerateGUID();
        LibraryPOSMock.CreateItemLineWithSerialNo(POSSession, Item."No.", 1, SerialNo1);
        LibraryPOSMock.CreateItemLineWithSerialNo(POSSession, Item."No.", 1, SerialNo2);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] Both lines stay, each with quantity 1 and its own serial number
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines with serial numbers must not be merged');
        SaleLinePOS.SetRange("Serial No.", SerialNo1);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(1, SaleLinePOS.Quantity, 'Quantity for serial number 1');
        SaleLinePOS.SetRange("Serial No.", SerialNo2);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(1, SaleLinePOS.Quantity, 'Quantity for serial number 2');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeInterleavedLotsNeverMixesLots()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNoA: Code[50];
        LotNoB: Code[50];
    begin
        // [SCENARIO] Lines added in alternating lot order are never merged across lots.
        // [GIVEN] A lot tracked item with 10 in stock for lot A and 10 for lot B
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNoA := LibraryUtility.GenerateGUID();
        LotNoB := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNoA, 10);
        PostPositiveAdjustment(Item, LotNoB, 10);

        // [GIVEN] Lines of 1 added in the order A, B, A, B
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoB);
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoB);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] Every line has lot A or lot B, and each lot still totals 2
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        SaleLinePOS.SetFilter("Lot No.", '<>%1&<>%2', LotNoA, LotNoB);
        Assert.RecordIsEmpty(SaleLinePOS);
        SaleLinePOS.SetRange("Lot No.", LotNoA);
        SaleLinePOS.CalcSums(Quantity);
        Assert.AreEqual(2, SaleLinePOS.Quantity, 'Total quantity for lot A');
        SaleLinePOS.SetRange("Lot No.", LotNoB);
        SaleLinePOS.CalcSums(Quantity);
        Assert.AreEqual(2, SaleLinePOS.Quantity, 'Total quantity for lot B');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeEachLotGroupSeparately()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNoA: Code[50];
        LotNoB: Code[50];
    begin
        // [SCENARIO] Lines of two lots each merge into their own line.
        // [GIVEN] A lot tracked item with 10 in stock for lot A and 10 for lot B
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNoA := LibraryUtility.GenerateGUID();
        LotNoB := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNoA, 10);
        PostPositiveAdjustment(Item, LotNoB, 10);

        // [GIVEN] Lines of 1 added in the order A, A, B, B
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoB);
        AddItemLineWithLot(Item, 1, LotNoB);
        POSSale.GetCurrentSale(SalePOS);

        // [WHEN] Similar lines are merged
        POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] Both lots are merged, each into one line of 2
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Each lot must be merged into one line');
        SaleLinePOS.SetRange("Lot No.", LotNoA);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(2, SaleLinePOS.Quantity, 'Quantity for lot A');
        SaleLinePOS.SetRange("Lot No.", LotNoB);
        SaleLinePOS.FindFirst();
        Assert.AreEqual(2, SaleLinePOS.Quantity, 'Quantity for lot B');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeSameLotInTwoPriceGroupsOverStockKeepsLines()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryUtility: Codeunit "Library - Utility";
        POSSale: Codeunit "NPR POS Sale";
        POSActMrgSimLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Item: Record Item;
        LotNoA: Code[50];
    begin
        // [SCENARIO] When one lot is merged in two price groups whose combined quantity exceeds stock, the merge fails and all lines keep their quantities.
        // [GIVEN] A lot tracked item with 10 in stock for lot A
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore, POSPaymentMethod);
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        CreateLotItem(Item);
        LotNoA := LibraryUtility.GenerateGUID();
        PostPositiveAdjustment(Item, LotNoA, 10);

        // [GIVEN] Lines of 2, 2, 1 and 1 for lot A in this sale
        AddItemLineWithLot(Item, 2, LotNoA);
        AddItemLineWithLot(Item, 2, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoA);
        AddItemLineWithLot(Item, 1, LotNoA);
        POSSale.GetCurrentSale(SalePOS);

        // [GIVEN] The two lines of 1 get another unit price, so lot A is merged in two groups of 4 and 2
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        SaleLinePOS.SetRange(Quantity, 1);
        SaleLinePOS.FindSet();
        repeat
            SaleLinePOS."Unit Price" += 1;
            SaleLinePOS.Modify(false);
        until SaleLinePOS.Next() = 0;

        // [GIVEN] Another open sale takes 6 of lot A, so each group fits the stock alone but both together do not
        InsertLineInOtherSale(Item, LotNoA, 6);

        // [WHEN] Similar lines are merged
        asserterror POSActMrgSimLinesB.ColapseSaleLines(POSSession, SalePOS);

        // [THEN] The stock error is raised and all four lines keep their quantities
        Assert.ExpectedError('is not in the stock');
        SaleLinePOS.Reset();
        FilterSaleLines(SaleLinePOS, SalePOS, Item."No.");
        Assert.AreEqual(4, SaleLinePOS.Count(), 'Number of lines after the failed merge');
        SaleLinePOS.SetRange(Quantity, 2);
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines of 2');
        SaleLinePOS.SetRange(Quantity, 1);
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Lines of 1');
    end;

    local procedure CreateLotItem(var Item: Record Item)
    var
        ItemTrackingCode: Record "Item Tracking Code";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
    begin
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, true);
        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        Item.Modify(true);
    end;

    local procedure PostPositiveAdjustment(Item: Record Item; LotNo: Code[50]; Quantity: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ReservationEntry: Record "Reservation Entry";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
    begin
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", POSStore."Location Code", '', Quantity);
        ItemJournalLine.Validate("Unit Amount", 10);
        ItemJournalLine.Modify(true);
        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', LotNo, Quantity);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure AddItemLineWithLot(Item: Record Item; Quantity: Decimal; LotNo: Code[50])
    var
        ItemReference: Record "Item Reference";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        POSSession.GetFrontEnd(FrontEnd, true);
        POSActionInsertItem.AddItemLine(Item, ItemReference, 0, Quantity, 0, '', '', '', POSSession, FrontEnd, LotNo);
    end;

    local procedure InsertLineInOtherSale(Item: Record Item; LotNo: Code[50]; Quantity: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // Only the line is needed: the lot stock check counts open sale lines without reading their header.
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := 'MRGOTHER';
        SaleLinePOS."Sales Ticket No." := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(SaleLinePOS."Sales Ticket No."));
        SaleLinePOS.Date := Today();
        SaleLinePOS."Line No." := 10000;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := Item."No.";
        SaleLinePOS."Lot No." := LotNo;
        SaleLinePOS.Quantity := Quantity;
        SaleLinePOS.Insert(false);
    end;

    local procedure FilterSaleLines(var SaleLinePOS: Record "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; ItemNo: Code[20])
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", ItemNo);
    end;
}