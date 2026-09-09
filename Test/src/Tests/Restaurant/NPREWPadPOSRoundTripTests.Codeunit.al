codeunit 85405 "NPR NPRE W/Pad RoundTripTests"
{
    // [FEATURE] Waiter pad and POS sale round-trip: saving a sale onto a pad and recalling a pad into a sale
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _Seating: Record "NPR NPRE Seating";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _ConfirmCallCount: Integer;
        _ConfirmReply: Boolean;
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;

    #region POS sale to waiter pad

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleWithTwoLines_SavedToPad_LinesMatch()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] A POS sale is parked onto the table's bill
        // [GIVEN] A POS sale carrying two item lines and an open waiter pad
        Initialize();
        CreateItem(FirstItem);
        CreateItem(SecondItem);
        StartSaleWithLines(POSSession, SalePOS, FirstItem."No.", 2, SecondItem."No.", 3);
        CreatePad(WaiterPad);

        // [WHEN] The sale is saved onto the pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The pad carries both lines with their item, quantity and unit of measure
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.AreEqual(2, WaiterPadLine.Count(), 'Both sale lines should have been saved onto the waiter pad.');
        FindPadLineForItem(WaiterPad."No.", FirstItem."No.", WaiterPadLine);
        _Assert.AreEqual(2, WaiterPadLine.Quantity, 'The first line should keep its quantity.');
        _Assert.AreEqual(FirstItem."Base Unit of Measure", WaiterPadLine."Unit of Measure Code", 'The first line should keep its unit of measure.');
        FindPadLineForItem(WaiterPad."No.", SecondItem."No.", WaiterPadLine);
        _Assert.AreEqual(3, WaiterPadLine.Quantity, 'The second line should keep its quantity.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleSavedToPad_CleanupRequested_SaleEmptiedAndUnlinked()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CleanupSuccessful: Boolean;
    begin
        // [SCENARIO] Saving a sale to a pad clears the register so the next guest can be served
        // [GIVEN] A sale that was recalled from a pad, so it holds a line and is pre-set to that pad
        //         The recall leg is what sets "NPRE Pre-Set Waiter Pad No." - without it the unlink assertion below
        //         would pass against a field that was never populated in the first place.
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        SalePOS.Find();
        _Assert.AreEqual(
            WaiterPad."No.", SalePOS."NPRE Pre-Set Waiter Pad No.", 'The recall should have pre-set the sale to the pad.');

        // [WHEN] The sale is saved back with cleanup requested
        CleanupSuccessful := WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] Cleanup succeeded, the sale has no lines left and no longer points at the pad
        _Assert.IsTrue(CleanupSuccessful, 'Cleanup should succeed when every sale line is supported.');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        _Assert.IsTrue(SaleLinePOS.IsEmpty(), 'A cleaned up sale should have no lines left.');
        SalePOS.Find();
        _Assert.AreEqual('', SalePOS."NPRE Pre-Set Waiter Pad No.", 'A cleaned up sale should no longer be pre-set to the waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleWithUnsupportedLine_SavedToPad_CleanupRefused()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CleanupSuccessful: Boolean;
    begin
        // [SCENARIO] A sale holding something a waiter pad cannot carry is left alone rather than silently emptied
        // [GIVEN] A sale with a supported item line and one line of an unsupported type
        Initialize();
        CreateItem(Item);
        StartSaleWithLines(POSSession, SalePOS, Item."No.", 1, '', 0);
        AddUnsupportedSaleLine(SalePOS);
        CreatePad(WaiterPad);

        // [WHEN] The sale is saved with cleanup requested
        CleanupSuccessful := WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] Cleanup is refused and the whole sale is left intact - the unsupported line and the item line with it
        _Assert.IsFalse(CleanupSuccessful, 'Cleanup should be refused while unsupported lines remain on the sale.');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '<>%1&<>%2', SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::Comment);
        _Assert.IsFalse(SaleLinePOS.IsEmpty(), 'The unsupported line should be left on the sale.');

        // The item line matters more than the unsupported one: a partial cleanup would take the guest's food off the
        // register while refusing to finish, which is the loss this refusal exists to prevent.
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("No.", Item."No.");
        _Assert.IsFalse(SaleLinePOS.IsEmpty(), 'A refused cleanup should leave the supported item line on the sale too.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SentLineDeletedInPOS_SaleSavedBack_PadLineKeptAtZero()
    var
        Item: Record Item;
        OtherItem: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OtherPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Removing a dish the kitchen already started must reach the kitchen, not vanish silently
        // [GIVEN] A pad with a sent dish and a second line, recalled into a sale where the sent dish is then deleted
        //         A second line has to remain: the save-back skips its removed-line cleanup entirely when no
        //         supported sale lines are left, so deleting every line would be a no-op.
        Initialize();
        CreateRoutedItem(Item);
        CreateItem(OtherItem);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        AddPadLine(WaiterPad, OtherItem."No.", 1, OtherPadLine);
        SendPadToKitchen(WaiterPad);
        RequestNo := GetOnlyKitchenRequestNo(WaiterPad."No.");
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        // The recall modifies the sale header, so the local copy has to be refreshed before it is written to again.
        SalePOS.Find();
        DeleteSaleLineForItem(SalePOS, Item."No.");

        // [WHEN] The sale is saved back onto the pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The pad line survives with nothing outstanding and its kitchen request is cancelled
        WaiterPadLine.Find();
        _Assert.AreEqual(0, WaiterPadLine.Quantity, 'A line already sent to the kitchen should be reduced to zero rather than deleted.');
        KitchenRequest.Get(RequestNo);
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'Removing the dish in POS should cancel the kitchen request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnsentLineDeletedInPOS_SaleSavedBack_PadLineRemoved()
    var
        Item: Record Item;
        OtherItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OtherPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Removing a dish nobody has started simply takes it off the bill
        // [GIVEN] A pad with an unsent, unbilled line and a second line, recalled into a sale where the first is deleted
        Initialize();
        CreateItem(Item);
        CreateItem(OtherItem);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        AddPadLine(WaiterPad, OtherItem."No.", 1, OtherPadLine);
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        // The recall modifies the sale header, so the local copy has to be refreshed before it is written to again.
        SalePOS.Find();
        DeleteSaleLineForItem(SalePOS, Item."No.");

        // [WHEN] The sale is saved back onto the pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The deleted line is gone from the pad and the other one remains
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("No.", Item."No.");
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'An unsent, unbilled line removed in POS should be deleted from the pad.');
        WaiterPadLine.SetRange("No.", OtherItem."No.");
        _Assert.IsFalse(WaiterPadLine.IsEmpty(), 'The line that was not removed should still be on the pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadWithPrintedPreReceipt_NewLinesSaved_PreReceiptInvalidated()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Adding to the bill after the pre-receipt was printed invalidates it
        // [GIVEN] A pad whose pre-receipt has been printed, and a sale with a new line
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        WaiterPad."Pre-receipt Printed" := true;
        WaiterPad.Modify();
        StartSaleWithLines(POSSession, SalePOS, Item."No.", 1, '', 0);

        // [WHEN] The sale is saved onto the pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The pre-receipt is marked as no longer valid
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad."Pre-receipt Printed", 'Adding lines should invalidate a previously printed pre-receipt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadWithCommentLine_Recalled_CommentReachesTheSale()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CommentTok: Label 'No onions', Locked = true;
    begin
        // [SCENARIO] A kitchen note held on the pad reaches the register when the bill is recalled
        //            Only the recall leg is covered here - the comment is written straight onto the pad rather than
        //            saved down from a sale, so this does not pin the save direction.
        // [GIVEN] A pad holding an item line and a comment line attached to it
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", CommentTok, WaiterPadLine."Line No.", WaiterPadLine);

        // [WHEN] The pad is recalled into a sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The comment line is on the sale
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Comment);
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The comment line should be recalled onto the sale.');
        _Assert.AreEqual(CommentTok, SaleLinePOS.Description, 'The comment text should survive the round-trip.');
    end;

    #endregion

    #region Waiter pad to POS sale

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadRecalled_SaleHeaderPreset()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Recalling a bill tells the register which table and party it belongs to
        // [GIVEN] A pad for four guests on a seating, carrying one line
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        WaiterPad."Number of Guests" := 4;
        WaiterPad.Modify();

        // [WHEN] The pad is recalled into a sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The sale header carries the pad, its seating and the party size
        SalePOS.Find();
        _Assert.AreEqual(WaiterPad."No.", SalePOS."NPRE Pre-Set Waiter Pad No.", 'The sale should be pre-set to the recalled waiter pad.');
        _Assert.AreEqual(_Seating.Code, SalePOS."NPRE Pre-Set Seating Code", 'The sale should be pre-set to the pad''s seating.');
        _Assert.AreEqual(4, SalePOS."NPRE Number of Guests", 'The sale should carry the pad''s party size.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure PadWithLineClaimedByAnotherSale_RecallConfirmed_OnlyFreeLinesTaken()
    var
        Item: Record Item;
        OtherSalePOS: Record "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] A bill partly loaded on another register warns the waiter, then hands over only what is free
        // [GIVEN] A pad with two lines, one of them bound to a different sale
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, FirstLine);
        AddPadLine(WaiterPad, Item."No.", 1, SecondLine);

        // The claiming sale has to be a genuinely different one. GetSaleFromWaiterPadToPOS excludes the current sale
        // from its "claimed elsewhere" filter, so binding the line to the sale being recalled into would skip the
        // whole confirm branch and leave this scenario untested.
        StartEmptySale(POSSession, OtherSalePOS);
        StartEmptySale(POSSession, SalePOS);
        SecondLine."Sale Retail ID" := OtherSalePOS.SystemId;
        SecondLine.Modify();
        _ConfirmReply := true;

        // [WHEN] The pad is recalled and the waiter accepts the warning
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The waiter was warned, and only the free line was copied across
        _Assert.AreEqual(1, _ConfirmCallCount, 'Recalling a pad with a line held by another sale should warn the waiter.');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        _Assert.AreEqual(1, SaleLinePOS.Count(), 'Only the unclaimed pad line should be recalled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure PadWithLineClaimedByAnotherSale_RecallDeclined_NothingTaken()
    var
        Item: Record Item;
        OtherSalePOS: Record "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Declining the warning abandons the recall rather than taking half the bill
        // [GIVEN] A pad with two lines, one of them bound to a different sale
        Initialize();
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, FirstLine);
        AddPadLine(WaiterPad, Item."No.", 1, SecondLine);
        StartEmptySale(POSSession, OtherSalePOS);
        StartEmptySale(POSSession, SalePOS);
        SecondLine."Sale Retail ID" := OtherSalePOS.SystemId;
        SecondLine.Modify();
        _ConfirmReply := false;

        // [WHEN] The pad is recalled and the waiter declines the warning
        asserterror WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The recall is abandoned and the sale is left empty
        //         The confirm count is the assertion with teeth here. ExpectedErrorCode narrows the bare asserterror to
        //         the Error('') the decline raises, but the empty-sale check is partly true by construction: asserterror
        //         rolls the statement back, so nothing the recall did would have survived regardless.
        _Assert.ExpectedErrorCode('Dialog');
        _Assert.AreEqual(1, _ConfirmCallCount, 'The waiter should have been warned before the recall was abandoned.');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        _Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Declining the warning should leave the sale untouched.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadLineInNonBaseUnitOfMeasure_Recalled_UnitOfMeasureKept()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Recalling a bottle-sized line must not silently turn it back into glasses
        // [GIVEN] A pad line in a non-base unit of measure holding six base units
        Initialize();
        CreateItem(Item);
        _LibraryRestaurant.CreateItemUnitOfMeasure(Item, ItemUnitOfMeasure, 6);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        WaiterPadLine.Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
        WaiterPadLine.Validate(Quantity, 1);
        WaiterPadLine.Modify(true);

        // [WHEN] The pad is recalled into a sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The recalled sale line keeps that unit of measure and its conversion
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The pad line should have been recalled.');
        _Assert.AreEqual(ItemUnitOfMeasure.Code, SaleLinePOS."Unit of Measure Code", 'Recall should keep the pad line''s unit of measure, not reset it to the item base unit.');
        _Assert.AreEqual(6, SaleLinePOS."Qty. per Unit of Measure", 'Recall should keep the unit of measure conversion.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnLineWithDiscount_Recalled_DiscountKept()
    var
        AddOnItem: Record Item;
        DishItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        AddOnLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CustomDiscountPct: Decimal;
    begin
        // [SCENARIO] A discount written on a pad line survives being recalled into a sale
        //            Scoped to the discount round-tripping, and no further. The attached-line protection only gates
        //            discount *recalculation*, and this fixture gives the add-on item no competing price or discount
        //            rule for recall to apply - so detaching the line would leave this assertion passing. It does not
        //            distinguish an attached line from a standalone one, and the pad line is hand-built so it carries
        //            no amount either. The amount half is covered by AddOnBuiltInPOS_SavedAndRecalled_AmountNotReprised,
        //            which builds its line from a real POS sale; the repricing half is the same gap #9949 has below.
        // [GIVEN] A dish with an attached add-on line carrying a discount
        Initialize();
        CreateItem(DishItem);
        CreateItem(AddOnItem);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, DishItem."No.", 1, DishLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, DishLine."Line No.", AddOnLine);

        AddOnLine.Validate("Discount %", 10);
        AddOnLine.Modify(true);
        AddOnLine.Find();
        CustomDiscountPct := AddOnLine."Discount %";

        // [WHEN] The pad is recalled into a sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The recalled add-on line keeps its discount
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", AddOnItem."No.");
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The add-on line should have been recalled.');
        _Assert.AreEqual(CustomDiscountPct, SaleLinePOS."Discount %", 'Recall should keep the discount the add-on was given.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleAlreadyHoldingAPad_SecondPadRecalled_Rejected()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        FirstWaiterPad: Record "NPR NPRE Waiter Pad";
        SecondWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] One register cannot hold two tables' bills at once
        // [GIVEN] A sale already recalled from one pad, and a second pad
        Initialize();
        CreateItem(Item);
        CreatePad(FirstWaiterPad);
        AddPadLine(FirstWaiterPad, Item."No.", 1, WaiterPadLine);
        CreatePad(SecondWaiterPad);
        AddPadLine(SecondWaiterPad, Item."No.", 1, WaiterPadLine);
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(FirstWaiterPad, POSSession);

        // [WHEN] A second pad is recalled into the same sale
        asserterror WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(SecondWaiterPad, POSSession);

        // [THEN] The attempt is rejected
        _Assert.ExpectedErrorCode('TestField');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnBuiltInPOS_SavedAndRecalled_AmountNotReprised()
    var
        AddOnItem: Record Item;
        DishItem: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        AddOnUnitPrice: Decimal;
        PadAmountInclVAT: Decimal;
    begin
        // [SCENARIO] An add-on priced by its add-on configuration is billed at that price after a round-trip,
        //            rather than being repriced from the item card
        //
        // NOTE ON WHAT THIS DOES NOT PIN. Mutation testing on 2026-09-02 showed this test still passes when the
        // attached-line protection in GetSaleLineFromWaiterPadToPOS - the SetSkipCalcDiscount / "Manual Item Sales
        // Price" block that is the #9949 fix - is disabled. The amount survives here by direct assignment, so the
        // protection never has to do anything in this fixture. Detecting its removal needs a competing price or
        // discount rule on the add-on item that recall would otherwise apply. Until that is added, treat this as
        // covering "the amount round-trips", not "the #9949 fix is in place".
        // [GIVEN] A dish and an attached add-on built in the POS at a price of its own, saved onto a pad
        Initialize();
        CreateItem(DishItem);
        CreateItem(AddOnItem);
        _LibraryRestaurant.CreateItemAddon(ItemAddOn);
        AddOnUnitPrice := 17;
        // Guard against a vacuous pass: if the add-on happened to be priced at its item card price, repricing on
        // recall would be indistinguishable from preserving it.
        _Assert.AreNotEqual(AddOnUnitPrice, AddOnItem."Unit Price", 'The add-on price under test must differ from the item card price for this scenario to mean anything.');
        StartSaleWithLines(POSSession, SalePOS, DishItem."No.", 1, AddOnItem."No.", 1);
        AttachSaleLineAsAddOn(SalePOS, DishItem."No.", AddOnItem."No.", ItemAddOn."No.", AddOnUnitPrice);
        CreatePad(WaiterPad);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // The pad line now holds the amounts the POS calculated, which is what a real add-on line looks like.
        FindPadLineForItem(WaiterPad."No.", AddOnItem."No.", WaiterPadLine);
        PadAmountInclVAT := WaiterPadLine."Amount Incl. VAT";
        _Assert.AreNotEqual(0, PadAmountInclVAT, 'The saved add-on line should carry the amount the POS calculated.');
        _Assert.AreNotEqual(0, WaiterPadLine."Attached to Line No.", 'The saved add-on line should stay attached to its dish.');

        // [WHEN] The pad is recalled into a fresh sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The recalled add-on bills the same amount it was saved at
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", AddOnItem."No.");
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The add-on line should have been recalled.');
        _Assert.AreEqual(PadAmountInclVAT, SaleLinePOS."Amount Including VAT", 'Recall should bill the add-on at the amount it was sold for, not reprice it from the item card.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLineWithPOSInfo_SavedAndRecalled_POSInfoSurvives()
    var
        Item: Record Item;
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoWaiterPadLink: Record "NPR POS Info NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSInfoValueTok: Label 'Allergy: shellfish', Locked = true;
    begin
        // [SCENARIO] Information captured against a sale line survives being parked on the bill and picked up again
        // [GIVEN] A sale line carrying a POS Info value
        Initialize();
        CreateItem(Item);
        CreatePOSInfo(POSInfo);
        StartSaleWithLines(POSSession, SalePOS, Item."No.", 1, '', 0);
        FindSaleLineForItem(SalePOS, Item."No.", SaleLinePOS);
        AddPOSInfoToSaleLine(SaleLinePOS, POSInfo.Code, POSInfoValueTok);
        CreatePad(WaiterPad);

        // [WHEN] The sale is saved onto the pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The pad line carries the POS Info
        FindPadLineForItem(WaiterPad."No.", Item."No.", WaiterPadLine);
        POSInfoWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSInfoWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        POSInfoWaiterPadLink.SetRange("POS Info Code", POSInfo.Code);
        _Assert.IsTrue(POSInfoWaiterPadLink.FindFirst(), 'The POS Info should have been saved onto the waiter pad line.');
        _Assert.AreEqual(POSInfoValueTok, POSInfoWaiterPadLink."POS Info", 'The saved POS Info should keep its value.');

        // [WHEN] The pad is recalled into a fresh sale
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The POS Info is back on the recalled sale line, exactly once
        FindSaleLineForItem(SalePOS, Item."No.", SaleLinePOS);
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        _Assert.AreEqual(1, POSInfoTransaction.Count(), 'The recalled sale line should carry the POS Info exactly once.');
        POSInfoTransaction.FindFirst();
        _Assert.AreEqual(POSInfoValueTok, POSInfoTransaction."POS Info", 'The recalled POS Info should keep its value.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if not _RestaurantInitialized then begin
            _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
            _LibraryRestaurant.CreateMealFlowStatuses();
            _LibraryRestaurant.CreateSeatingFlowStatuses();
            _LibraryRestaurant.CreateWaiterPadFlowStatuses();
            _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
            _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
            _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
            _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
            _LibraryRestaurant.CreateSeating(_Seating, _SeatingLocation.Code);
            _LibraryRestaurant.CreateKitchenStation(KitchenStation, _Restaurant.Code);

            KitchenStationSelection.Init();
            KitchenStationSelection."Restaurant Code" := _Restaurant.Code;
            KitchenStationSelection."Seating Location" := _SeatingLocation.Code;
            KitchenStationSelection."Serving Step" := MainCourseStepTok;
            KitchenStationSelection."Production Restaurant Code" := _Restaurant.Code;
            KitchenStationSelection."Kitchen Station" := KitchenStation.Code;
            KitchenStationSelection."Production Step" := 1;
            KitchenStationSelection.Insert(true);

            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();
            _RestaurantInitialized := true;
        end;

        // Manual close keeps these scenarios about the round-trip: no pad closes itself mid-test.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        _ConfirmCallCount := 0;
        _ConfirmReply := false;
        Commit();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        _ConfirmCallCount += 1;
        Reply := _ConfirmReply;
    end;

    local procedure CreateItem(var Item: Record Item)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
    end;

    local procedure CreateRoutedItem(var Item: Record Item)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        CreateItem(Item);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
    end;

    local procedure AddPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; ItemNo: Code[20]; Quantity: Decimal; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", ItemNo, Quantity, 0, WaiterPadLine);
    end;

    local procedure StartEmptySale(var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure StartSaleWithLines(var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale"; FirstItemNo: Code[20]; FirstQuantity: Decimal; SecondItemNo: Code[20]; SecondQuantity: Decimal)
    begin
        StartEmptySale(POSSession, SalePOS);
        _LibraryPOSMock.CreateItemLine(POSSession, FirstItemNo, FirstQuantity);
        if SecondItemNo <> '' then
            _LibraryPOSMock.CreateItemLine(POSSession, SecondItemNo, SecondQuantity);
    end;

    local procedure AddUnsupportedSaleLine(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LastSaleLinePOS: Record "NPR POS Sale Line";
    begin
        // A G/L Payment line - a payment, not a G/L account line; the enum has no G/L account type. It is neither Item
        // nor Comment, which is what makes FilterSupportedSaleLines leave it behind.
        LastSaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        LastSaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if LastSaleLinePOS.FindLast() then;

        SaleLinePOS.Init();
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := SalePOS.Date;
        SaleLinePOS."Line No." := LastSaleLinePOS."Line No." + 10000;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"GL Payment";
        SaleLinePOS.Description := 'Unsupported line';
        SaleLinePOS.Insert(true);
    end;

    local procedure FindSaleLineForItem(SalePOS: Record "NPR POS Sale"; ItemNo: Code[20]; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", ItemNo);
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The sale should hold a line for the item.');
    end;

    local procedure AttachSaleLineAsAddOn(SalePOS: Record "NPR POS Sale"; DishItemNo: Code[20]; AddOnItemNo: Code[20]; AddOnNo: Code[20]; AddOnUnitPrice: Decimal)
    var
        AddOnSaleLinePOS: Record "NPR POS Sale Line";
        DishSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FindSaleLineForItem(SalePOS, DishItemNo, DishSaleLinePOS);
        FindSaleLineForItem(SalePOS, AddOnItemNo, AddOnSaleLinePOS);

        // The add-on link record is what marks the line as an add-on, and it is read on the *save* leg:
        // CopyItemAddOnLinkInfoToWPLine follows it to populate the pad line's "Attached to Line No.". Recall then
        // reads that field - not this record - to decide the line must not be repriced. Two steps rather than one,
        // but the consequence is the same: a plain second sale line would not exercise the behaviour under test.
        SaleLinePOSAddOn.Init();
        SaleLinePOSAddOn."Register No." := AddOnSaleLinePOS."Register No.";
        SaleLinePOSAddOn."Sales Ticket No." := AddOnSaleLinePOS."Sales Ticket No.";
        SaleLinePOSAddOn."Sale Date" := AddOnSaleLinePOS.Date;
        SaleLinePOSAddOn."Sale Line No." := AddOnSaleLinePOS."Line No.";
        SaleLinePOSAddOn."Line No." := 10000;
        SaleLinePOSAddOn."Applies-to Line No." := DishSaleLinePOS."Line No.";
        SaleLinePOSAddOn."AddOn No." := AddOnNo;
        SaleLinePOSAddOn."AddOn Line No." := 10;
        SaleLinePOSAddOn.Insert(true);

        AddOnSaleLinePOS.Validate("Unit Price", AddOnUnitPrice);
        AddOnSaleLinePOS.Modify(true);
    end;

    local procedure CreatePOSInfo(var POSInfo: Record "NPR POS Info")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSInfo.Init();
        POSInfo.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(POSInfo.FieldNo(Code), Database::"NPR POS Info"), 1, MaxStrLen(POSInfo.Code));
        POSInfo.Description := 'Test POS Info';
        POSInfo.Insert(true);
    end;

    local procedure AddPOSInfoToSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; POSInfoCode: Code[20]; POSInfoValue: Text)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.Init();
        POSInfoTransaction."Register No." := SaleLinePOS."Register No.";
        POSInfoTransaction."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        POSInfoTransaction."Sales Line No." := SaleLinePOS."Line No.";
        POSInfoTransaction."Sale Date" := SaleLinePOS.Date;
        POSInfoTransaction."Line Type" := SaleLinePOS."Line Type";
        POSInfoTransaction."Entry No." := 0;
        POSInfoTransaction.Validate("POS Info Code", POSInfoCode);
        POSInfoTransaction."POS Info" := CopyStr(POSInfoValue, 1, MaxStrLen(POSInfoTransaction."POS Info"));
        POSInfoTransaction.Insert(true);
    end;

    local procedure DeleteSaleLineForItem(SalePOS: Record "NPR POS Sale"; ItemNo: Code[20])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", ItemNo);
        _Assert.IsTrue(SaleLinePOS.FindFirst(), 'The recalled sale should hold a line for the item about to be removed.');
        SaleLinePOS.Delete(true);
    end;

    local procedure SendPadToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        RestaurantPrint.PrintWaiterPadLinesToKitchen(WaiterPad, WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", '', false, false);
    end;

    local procedure GetOnlyKitchenRequestNo(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadNo);
        _Assert.AreEqual(1, KitchenReqSourceLink.Count(), 'The pad should have produced exactly one kitchen request.');
        KitchenReqSourceLink.FindFirst();
        exit(KitchenReqSourceLink."Request No.");
    end;

    local procedure FindPadLineForItem(WaiterPadNo: Code[20]; ItemNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("No.", ItemNo);
        _Assert.IsTrue(WaiterPadLine.FindFirst(), 'The waiter pad should hold a line for the item.');
    end;

    #endregion
}
