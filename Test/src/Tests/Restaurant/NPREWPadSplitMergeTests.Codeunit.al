codeunit 85409 "NPR NPRE W/Pad SplitMergeTests"
{
    // [FEATURE] Splitting and merging waiter pad lines: quantity, kitchen request source links and print log entries
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _FailInsertOfItemNo: Code[20];
        _FailInsertOnWaiterPadNo: Code[20];
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        AttachedEntryTxt: Label '%1 > %2', Locked = true, Comment = '%1 = line entry, %2 = description of the line it is attached to';
        BilledEntryTxt: Label '%1 billed %2', Locked = true, Comment = '%1 = line entry, %2 = billed quantity';
        CommentsEntryTxt: Label '%1 [%2]', Locked = true, Comment = '%1 = line entry, %2 = the comments attached to the line';
        ForcedFailureErr: Label 'The test forced this line to fail on the new bill.', Locked = true;
        ItemEntryTxt: Label '%1 %2', Locked = true, Comment = '%1 = description, %2 = quantity';
        MissingParentTxt: Label '(missing)', Locked = true;
        OrphanCommentTxt: Label '%1 (on a missing line)', Locked = true, Comment = '%1 = comment text';
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_QuantityAndBilledQuantityDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving part of a dish to another bill divides both what is owed and what is already paid
        // [GIVEN] A line of four with one already billed and a priced amount on it, and a second pad to move part of it to
        //         The amount has to be set explicitly. Only the POS save-back path ever writes "Amount Incl. VAT", so a
        //         hand-built line carries zero and the amount assertions below would be 0 = 0 whatever the split did.
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, false);
        _LibraryRestaurant.SetWaiterPadLineBilledQuantity(SourceLine, 1);
        SourceLine.Find();
        SourceLine."Amount Incl. VAT" := 400;
        SourceLine."Amount Excl. VAT" := 320;
        SourceLine.Modify();
        CreatePad(TargetPad);

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] The new line carries three unbilled, and the source keeps one billed one
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(3, NewLine.Quantity, 'The moved line should carry the split quantity.');
        _Assert.AreEqual(0, NewLine."Billed Quantity", 'The moved line should carry none of the billed quantity while an unbilled remainder exists.');
        SourceLine.Find();
        _Assert.AreEqual(1, SourceLine.Quantity, 'The source line should keep what was not moved.');
        _Assert.AreEqual(1, SourceLine."Billed Quantity", 'The already billed quantity should stay with the source line.');

        // [THEN] Amounts are cleared on both, to be recalculated when each bill is next priced
        _Assert.AreEqual(0, NewLine."Amount Incl. VAT", 'A split should clear the amount on the moved line.');
        _Assert.AreEqual(0, SourceLine."Amount Incl. VAT", 'A split should clear the amount on the source line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplitOfUntouchedLine_SourceLineDeleted()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving a whole dish nobody has started leaves nothing behind
        // [GIVEN] A line of two, never sent and unbilled
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, false);
        CreatePad(TargetPad);

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The target holds it and the source line is gone
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, NewLine.Quantity, 'The whole quantity should have moved.');
        _Assert.IsFalse(SourceLine.Find(), 'A fully moved line with nothing sent and nothing billed should be removed from the source pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplitOfSentLine_SendingEvidenceMovesWithIt()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving a whole dish the kitchen already has takes its history to the new bill
        // [GIVEN] A line of two already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);
        _Assert.AreEqual(1, PrintLogCount(SourcePad."No.", SourceLine."Line No."), 'The sent line should have a print log entry before the split.');

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The print log moved with the line, and the source line went with it
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(1, PrintLogCount(TargetPad."No.", NewLine."Line No."), 'The print log entry should now sit against the moved line.');
        _Assert.AreEqual(0, PrintLogCount(SourcePad."No.", SourceLine."Line No."), 'No print log entry should be left on the source line.');
        _Assert.IsFalse(SourceLine.Find(), 'The source line is removed on a full transfer: its sending evidence moved to the target, so nothing marks it as sent.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplit_KitchenSourceLinksMoved()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The kitchen's work follows the dish to whichever bill now owns it
        // [GIVEN] A line of two already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The kitchen request now names the target pad as its source
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The kitchen request source links should point at the moved line.');
        _Assert.AreEqual(0, SourceLinkCount(SourcePad."No.", SourceLine."Line No."), 'No kitchen request source link should be left on the source line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_KitchenSourceLinksDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Splitting part of a dish splits the kitchen's work to match
        // [GIVEN] A line of four already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, true);
        CreatePad(TargetPad);
        _Assert.AreEqual(4, SourceLinkQuantity(SourcePad."No.", SourceLine."Line No."), 'The whole quantity should be with the kitchen before the split.');

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] Each pad line's source links add up to the quantity that pad now owes
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(3, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The moved line should own three of the kitchen quantity.');
        _Assert.AreEqual(1, SourceLinkQuantity(SourcePad."No.", SourceLine."Line No."), 'The source line should be left owning one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Split_PrintCategoriesAndFlowStatusesCopied()
    var
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A moved dish keeps the routing that decides which station cooks it
        // [GIVEN] A line carrying an assigned print category and meal flow status
        Initialize();
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        CreatePadWithLine(SourcePad, SourceLine, 2, false, PrintCategory.Code);
        CreatePad(TargetPad);
        _Assert.IsTrue(HasAssignedPrintCategory(SourceLine, PrintCategory.Code), 'The source line should carry the print category before the split.');

        // [WHEN] Part of the line is split onto the other pad
        SplitLine(SourcePad, SourceLine, 1, TargetPad);

        // [THEN] The moved line carries the same print category and serving step
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.IsTrue(HasAssignedPrintCategory(NewLine, PrintCategory.Code), 'The moved line should carry the print category across.');
        _Assert.IsTrue(HasAssignedFlowStatus(NewLine, MainCourseStepTok), 'The moved line should carry its serving step across.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_PrintLogEntriesDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The record of what was sent is divided too, so a later resend knows what each bill still owes
        // [GIVEN] A line of four already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, true);
        CreatePad(TargetPad);

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] Both lines carry print log entries, and the sent quantities net out to what each pad owes
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreNotEqual(0, PrintLogCount(TargetPad."No.", NewLine."Line No."), 'The moved line should carry print log entries.');
        _Assert.AreEqual(3, PrintLogSentQuantity(TargetPad."No.", NewLine."Line No."), 'The moved line should be recorded as having three sent.');
        _Assert.AreEqual(1, PrintLogSentQuantity(SourcePad."No.", SourceLine."Line No."), 'The source line should be left recorded as having one sent.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeOfSentPad_KitchenLinksFollowToTarget()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Joining two tables' bills keeps the kitchen pointed at the surviving one
        // [GIVEN] A source pad whose only line is already with the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);

        // [WHEN] The source pad is merged into the target
        WaiterPadMgt.MergeWaiterPad(SourcePad, TargetPad);

        // [THEN] The kitchen work now hangs off the target pad and none is orphaned on the source
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The kitchen work should follow the merged line to the target pad.');
        _Assert.AreEqual(0, SourceLinkCount(SourcePad."No.", SourceLine."Line No."), 'No kitchen work should be left pointing at the emptied source pad.');
    end;

    #region Attached comments on a split bill

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_WholeUnsentDishMoved_ItsCommentMovesWithIt()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] A dish that moves whole to another bill takes its attached comment along and leaves no copy behind
        Initialize();

        // [GIVEN] Per row, a source pad with the row's lines and a new bill
        // [WHEN] The whole DISH is split to the new bill
        // [THEN] The comment of DISH is on the new bill only
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.a source pad', '', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S8.a new pad', 'DISH 1 [No onions]', PadContent(TargetPad."No."), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'no ice', DishLine, CommentLine);
        AddRoleLine(SourcePad, 'BEER', 1, 0, true, BeerLine);
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.f source pad', 'BEER 1', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S8.f new pad', 'DISH 1 [no ice]', PadContent(TargetPad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S8.a and S8.f: an attached comment goes only to the bill its whole DISH moves to.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_PartOfADishMoved_BothBillsCarryTheComment()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
    begin
        // [SCENARIO] When the quantity of a dish is divided between two bills, each bill gets the comment attached to its share
        // [GIVEN] A pad with DISH quantity 2 and "No onions" attached to it, and another bill that already holds BEER 1
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 2, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        CreatePad(TargetPad);
        AddRoleLine(TargetPad, 'BEER', 1, 0, true, BeerLine);

        // [WHEN] One DISH is split to the other bill
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);

        // [THEN] Each pad holds DISH 1 with "No onions" attached, and on the other bill the copy is attached to DISH, not to BEER
        _Assert.AreEqual('DISH 1 [No onions]', PadContent(SourcePad."No."), 'S8.b: the source pad should keep DISH 1 with "No onions" attached.');
        _Assert.AreEqual(
            'BEER 1; DISH 1 [No onions]', PadContent(TargetPad."No."),
            'S8.b: the other bill should keep BEER 1 and get DISH 1 with a copy of "No onions" attached to DISH, not to BEER.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_DishAndItsAddOnMoved_TheAddOnsCommentMovesWithTheAddOn()
    var
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
    begin
        // [SCENARIO] A comment attached to an add-on follows the add-on to the new bill
        // [GIVEN] A pad with DISH, ADDON-M attached to DISH and "extra hot" attached to ADDON-M, and a new bill
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(SourcePad, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'extra hot', AddOnMLine, CommentLine);
        CreatePad(TargetPad);

        // [WHEN] DISH and ADDON-M are split to the new bill
        AddBillLine(BillLines, DishLine, 1);
        AddBillLine(BillLines, AddOnMLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);

        // [THEN] The new pad holds DISH, ADDON-M attached to it and "extra hot" attached to ADDON-M; nothing of the group is left
        _Assert.AreEqual('', PadContent(SourcePad."No."), 'S8.c: nothing of the DISH group should be left on the source pad.');
        _Assert.AreEqual(
            'DISH 1; ADDON-M 1 > DISH [extra hot]', PadContent(TargetPad."No."),
            'S8.c: the new pad should hold DISH, ADDON-M attached to DISH and "extra hot" attached to ADDON-M.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_DishMovedWithoutItsAddOn_TheAddOnAndItsCommentStay()
    var
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
    begin
        // [SCENARIO] An add-on whose dish moved without it stays on the source pad as today, and its comment stays attached to it
        // [GIVEN] A pad with DISH, ADDON-M attached to DISH and "extra hot" attached to ADDON-M, and a new bill
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(SourcePad, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'extra hot', AddOnMLine, CommentLine);
        CreatePad(TargetPad);

        // [WHEN] Only DISH is split to the new bill
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);

        // [THEN] ADDON-M and "extra hot" stay on the source pad, and the new pad holds DISH
        _Assert.AreEqual(
            'ADDON-M 1 > (missing) [extra hot]', PadContent(SourcePad."No."),
            'S8.d: ADDON-M should stay on the source pad without its DISH, with "extra hot" still attached to it.');
        _Assert.AreEqual('DISH 1', PadContent(TargetPad."No."), 'S8.d: the new pad should hold DISH 1.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_DishMovedAwayFromAnOrderNote_OrderNoteCopiedToTheNewBill()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] A split dish takes a copy of the order note to the new bill: the note stays on the source pad, or is deleted with it when only comments are left
        Initialize();

        // [GIVEN] Per row, a source pad with an unsent DISH, the order note "Table 6 VIP" and the row's other lines, and a new bill
        // [WHEN] DISH is split to the new bill
        // [THEN] The new bill holds DISH and a copy of "Table 6 VIP"; the source keeps "Table 6 VIP" with BEER, or loses it with nothing else left
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, 0, true, BeerLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(SourcePad."No.", 'Table 6 VIP', CommentLine);
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.e source pad', 'BEER 1; Table 6 VIP', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S8.e new pad (S10.a)', 'DISH 1; Table 6 VIP', PadContent(TargetPad."No."), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(SourcePad."No.", 'Table 6 VIP', CommentLine);
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.k source pad', '', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S8.k new pad (S10.b)', 'DISH 1; Table 6 VIP', PadContent(TargetPad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S8.e and S8.k (S10.a, S10.b): the order note stays on the source pad as today and a copy follows DISH to the new bill.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_DishLeftWithNothingToBill_CommentMovesToTheNewBill()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] When nothing is left to bill on the source line, sent or already billed, its comment moves to the new bill and is not left behind
        Initialize();

        // [GIVEN] Per row, a pad with DISH and "No onions" attached, where DISH is sent to the kitchen or partly billed, and a new bill
        // [WHEN] The quantity of DISH not yet billed is split to the new bill
        // [THEN] "No onions" is on the new bill, attached to DISH, and not on the source pad
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(SourcePad);
        DishLine.Find();
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.g source pad comments', '', CommentsOnPad(SourcePad."No."), Mismatches);
        CheckRow('S8.g new pad', 'DISH 1 [No onions]', PadContent(TargetPad."No."), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 2, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        DishLine.Find();
        _LibraryRestaurant.SetWaiterPadLineBilledQuantity(DishLine, 1);
        CreatePad(TargetPad);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);
        CheckRow('S8.h source pad', 'DISH 1 billed 1', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S8.h new pad', 'DISH 1 [No onions]', PadContent(TargetPad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S8.g and S8.h: a comment leaves the source pad when nothing is left to bill on its DISH there.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_MoveFailsHalfway_EveryCommentStaysWithItsParentAndNothingMoves()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SecondDishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        FailingInsert: Codeunit "NPR NPRE W/Pad SplitMergeTests";
        BillLines: JsonArray;
    begin
        // [SCENARIO] A split that fails halfway rolls back every move, so each comment is on exactly one pad with its parent and none is duplicated
        // [GIVEN] A pad with DISH and "No onions" attached, BEER and "no ice" attached, and a second DISH; the move of BEER to the new bill fails
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        AddRoleLine(SourcePad, 'BEER', 1, 0, true, BeerLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'no ice', BeerLine, CommentLine);
        AddRoleLine(SourcePad, 'second DISH', 1, 0, true, SecondDishLine);
        CreatePad(TargetPad);
        FailingInsert.FailInsertOfItemOnWaiterPad(TargetPad."No.", BeerLine."No.");
        Commit();

        // [WHEN] DISH, BEER and the second DISH are split to the new bill
        AddBillLine(BillLines, DishLine, 1);
        AddBillLine(BillLines, BeerLine, 1);
        AddBillLine(BillLines, SecondDishLine, 1);
        BindSubscription(FailingInsert);
        asserterror SplitBill(SourcePad, BillLines, TargetPad);
        UnbindSubscription(FailingInsert);

        // [THEN] The split fails, every line and comment is back on the source pad with its parent, and the new bill holds nothing
        _Assert.ExpectedError(ForcedFailureErr);
        _Assert.AreEqual(
            'DISH 1 [No onions]; BEER 1 [no ice]; second DISH 1', PadContent(SourcePad."No."),
            'S8.i: after the failed split each comment should be on the source pad attached to its parent, once.');
        _Assert.AreEqual('', PadContent(TargetPad."No."), 'S8.i: after the failed split the new bill should hold no line and no comment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_SplitAgainAfterASplit_OneCopyOfTheCommentPerDish()
    var
        Item: Record Item;
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        SourceDishLine: Record "NPR NPRE Waiter Pad Line";
        TargetDishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
    begin
        // [SCENARIO] Splitting the same pad again moves the remaining dish with its comment, and no dish ends up with two copies
        // [GIVEN] The result of splitting one of two DISH: DISH 1 with "No onions" on the source pad and on the new bill, nothing sent
        Initialize();
        CreateRoleItem('DISH', true, Item);
        CreatePad(SourcePad);
        _LibraryRestaurant.AddWaiterPadLine(SourcePad."No.", Item."No.", 1, 0, SourceDishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', SourceDishLine, CommentLine);
        CreatePad(TargetPad);
        _LibraryRestaurant.AddWaiterPadLine(TargetPad."No.", Item."No.", 1, 0, TargetDishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(TargetPad."No.", 'No onions', TargetDishLine, CommentLine);

        // [WHEN] The DISH of the source pad is split to the new bill
        AddBillLine(BillLines, SourceDishLine, 1);
        SplitBill(SourcePad, BillLines, TargetPad);

        // [THEN] The new bill holds two DISH with one "No onions" each, and the source pad holds nothing
        _Assert.AreEqual(
            'DISH 1 [No onions]; DISH 1 [No onions]', PadContent(TargetPad."No."),
            'S8.j: the new bill should hold two DISH 1, each with exactly one "No onions".');
        _Assert.AreEqual('', PadContent(SourcePad."No."), 'S8.j: the source pad should hold no DISH and no "No onions".');
    end;

    #endregion

    #region Attached comments on a merge

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeWaiterPad_PadWithAttachedComments_CommentsFollowTheirParents()
    var
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        OtherLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] Merging pad A into pad B moves every attached comment of A to B, attached to its parent's new line
        Initialize();

        // [GIVEN] Per row, pad A with the row's lines, and pad B that already holds a line of its own
        // [WHEN] Pad A is merged into pad B
        // [THEN] Pad B holds the lines of A with their comments attached, and pad A holds no comment
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 2, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.a pad B', 'OTHER 1; DISH 2 [No onions]', PadContent(PadB."No."), Mismatches);
        CheckRow('S9.a pad A', '', PadContent(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(PadA, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'extra hot', AddOnMLine, CommentLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.b pad B', 'OTHER 1; DISH 1; ADDON-M 1 > DISH [extra hot]', PadContent(PadB."No."), Mismatches);
        CheckRow('S9.b pad A', '', PadContent(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadA);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.d pad B', 'OTHER 1; DISH 1 [No onions]', PadContent(PadB."No."), Mismatches);
        CheckRow('S9.d pad A comments', '', CommentsOnPad(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S9.a, S9.b and S9.d: a merge moves every attached comment to pad B with its parent.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeWaiterPad_PadWithAnOrderNote_OrderNoteAddedToPadB()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        OtherLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A merge adds the order note of pad A to the end of pad B, and the emptied pad A keeps no lines
        // [GIVEN] Pad A with an unsent DISH and the order note "Table 6 VIP", and pad B that already holds a line of its own
        Initialize();
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(PadA."No.", 'Table 6 VIP', CommentLine);
        CreatePadWithOwnLine(PadB, OtherLine);

        // [WHEN] Pad A is merged into pad B
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);

        // [THEN] Pad B holds its own line, DISH and "Table 6 VIP" at the end, and pad A holds nothing
        _Assert.AreEqual(
            'OTHER 1; DISH 1; Table 6 VIP', PadContent(PadB."No."),
            'S9.c (S11.a): pad B should hold its own line, DISH and then a copy of the order note "Table 6 VIP".');
        _Assert.AreEqual('', PadContent(PadA."No."), 'S9.c (S11.a): pad A should hold no lines; its "Table 6 VIP" is deleted when it closes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeWaiterPad_DishWithAnAddOnAndComments_PadBKeepsTheLineOrderOfPadA()
    var
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        OtherLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] A merge moves each attached comment in its own turn, after its parent, so pad B keeps the line order of pad A
        Initialize();

        // [GIVEN] Per row, pad A with DISH, ADDON-M attached to DISH and the row's other lines, and pad B that already holds a line of its own
        // [WHEN] Pad A is merged into pad B
        // [THEN] Pad B holds the lines of pad A in pad A's order, each attached to its parent, and pad A holds none of the moved lines
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(PadA, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.e pad B', 'OTHER; DISH; ADDON-M > DISH; No onions > DISH', PadLineOrder(PadB."No."), Mismatches);
        CheckRow('S9.e pad A', '', PadLineOrder(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(PadA, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'extra hot', AddOnMLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        AddRoleLine(PadA, 'BEER', 1, 0, true, BeerLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow(
            'S9.f pad B', 'OTHER; DISH; ADDON-M > DISH; extra hot > ADDON-M; No onions > DISH; BEER', PadLineOrder(PadB."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(PadA, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadA);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.g pad B', 'OTHER; DISH; ADDON-M > DISH; No onions > DISH', PadLineOrder(PadB."No."), Mismatches);
        CheckRow('S9.g pad A comments', '', CommentsOnPad(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S9.e, S9.f and S9.g: after a merge pad B keeps the line order of pad A.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeWaiterPad_CommentBeforeAnAddOnOrBeforeItsParentOrAnOrderNote_MergedAsSpecified()
    var
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        OtherLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] A merge keeps today's result for a comment placed before an add-on of its parent or before its parent, and adds an order note of pad A to the end of pad B
        Initialize();

        // [GIVEN] Per row, pad A with DISH and the row's lines in the row's order, and pad B that already holds a line of its own
        // [WHEN] Pad A is merged into pad B
        // [THEN] Pad B holds the row's lines in the row's order, and pad A holds no comment where the row says so
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        AddRoleLine(PadA, 'ADDON-M', 1, DishLine."Line No.", false, AddOnMLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.h pad B', 'OTHER; DISH; No onions > DISH; ADDON-M > DISH', PadLineOrder(PadB."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(PadA."No.", 'Table 6 VIP', CommentLine);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.i pad B (S11.a)', 'OTHER; DISH; Table 6 VIP', PadLineOrder(PadB."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        CommentLine.Rename(PadA."No.", 5000);
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        CheckRow('S9.j pad B', 'OTHER; DISH; No onions > DISH', PadLineOrder(PadB."No."), Mismatches);
        CheckRow('S9.j pad A comments', '', CommentsOnPad(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S9.h, S9.i (S11.a) and S9.j: a merge keeps the attached comments as today and adds the order note to the end of pad B.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeOfASentPadWithAnAddOnAndAComment_PadBSavedAndSentAgain_NoDishStationFlagged()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        OtherLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] After a sent pad is merged into another pad, saving and sending that pad again does not ask the kitchen to accept a change, and the dish keeps its modifiers in their order
        // [GIVEN] Pad A with DISH, ADDON-K attached to DISH without a kitchen request of its own and "No onions" attached to DISH, sent to the kitchen, then merged into pad B that holds a line of its own
        Initialize();
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, 0, true, DishLine);
        AddRoleLine(PadA, 'ADDON-K', 1, DishLine."Line No.", false, AddOnKLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadA."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadA);
        _LibraryRestaurant.FindKitchenRequestsForPad(PadA."No.", KitchenRequest);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'S9.k: sending pad A should create one kitchen request, the one of DISH.');
        KitchenRequest.FindFirst();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        _Assert.AreEqual(
            'ADDON-K; No onions', RequestModifiers(KitchenRequest."Request No."), 'S9.k: after sending pad A the DISH request should list ADDON-K, then "No onions".');
        _Assert.AreEqual('', FlaggedStations(KitchenRequest."Request No."), 'S9.k: right after sending pad A no station of the DISH request should be flagged.');
        CreatePadWithOwnLine(PadB, OtherLine);
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);

        // [WHEN] Pad B is recalled to the POS, saved back and sent to the kitchen
        RecallAndSavePad(PadB);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadB);

        // [THEN] No station of the DISH request is flagged, and its modifiers are still ADDON-K, then "No onions"
        CheckRow('S9.k DISH stations flagged', '', FlaggedStations(KitchenRequest."Request No."), Mismatches);
        CheckRow('S9.k DISH modifiers', 'ADDON-K; No onions', RequestModifiers(KitchenRequest."Request No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S9.k: saving and sending pad B after the merge should leave the DISH request as the kitchen accepted it.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStationSelectionAll: Record "NPR NPRE Kitchen Station Slct.";
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
            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();
            _RestaurantInitialized := true;
        end;

        // Manual close keeps the emptied source pad in the merge scenario from disappearing before it is asserted on.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // Routing selections with a blank seating location or serving step outrank the narrower ones a test builds, so the
        // table is wiped per test. Spelled out in full at NPREKitchenSendTests.Codeunit.al, in its Initialize.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        Commit();
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreatePadWithLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal; SendToKitchen: Boolean)
    begin
        CreatePadWithLine(WaiterPad, WaiterPadLine, Quantity, SendToKitchen, '');
    end;

    local procedure CreatePadWithLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal; SendToKitchen: Boolean; PrintCategoryCode: Code[20])
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        CreatePad(WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        if PrintCategoryCode <> '' then
            _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategoryCode);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
        if SendToKitchen then
            _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        WaiterPadLine.Find();
    end;

    local procedure SplitLine(var SourcePad: Record "NPR NPRE Waiter Pad"; var SourceLine: Record "NPR NPRE Waiter Pad Line"; MoveQuantity: Decimal; TargetPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // The moved-line map has to be cleared at the start of an operation and the same codeunit instance kept
        // for its duration, which is how an add-on line finds its dish's new line number on the target pad.
        WaiterPadPOSMgt.ClearMovedWaiterPadLineMap();
        WaiterPadPOSMgt.SplitWaiterPadLine(SourcePad, SourceLine, MoveQuantity, TargetPad);
    end;

    local procedure FindOnlyLine(WaiterPadNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        _Assert.AreEqual(1, WaiterPadLine.Count(), 'The pad should hold exactly one line at this point.');
        WaiterPadLine.FindFirst();
    end;

    local procedure SourceLinkCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        FilterSourceLinks(WaiterPadNo, WaiterPadLineNo, KitchenReqSourceLink);
        exit(KitchenReqSourceLink.Count());
    end;

    local procedure SourceLinkQuantity(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Decimal
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        // Splitting records the transfer as offsetting entries rather than editing the originals, so the quantity a
        // line currently owes the kitchen is the sum of its links, not the value on any single one.
        FilterSourceLinks(WaiterPadNo, WaiterPadLineNo, KitchenReqSourceLink);
        KitchenReqSourceLink.CalcSums(Quantity);
        exit(KitchenReqSourceLink.Quantity);
    end;

    local procedure FilterSourceLinks(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        KitchenReqSourceLink.Reset();
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadNo);
        KitchenReqSourceLink.SetRange("Source Document Line No.", WaiterPadLineNo);
    end;

    local procedure PrintLogCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterPrintLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        exit(WPadLinePrintLogEntry.Count());
    end;

    local procedure PrintLogSentQuantity(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Decimal
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterPrintLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        WPadLinePrintLogEntry.CalcSums("Sent Quanity (Base)");
        exit(WPadLinePrintLogEntry."Sent Quanity (Base)");
    end;

    local procedure FilterPrintLog(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry")
    begin
        WPadLinePrintLogEntry.Reset();
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
    end;

    local procedure HasAssignedPrintCategory(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintCategoryCode: Code[20]): Boolean
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        AssignedPrintCategory.SetRange("Table No.", Database::"NPR NPRE Waiter Pad Line");
        AssignedPrintCategory.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedPrintCategory.SetRange("Print/Prod. Category Code", PrintCategoryCode);
        exit(not AssignedPrintCategory.IsEmpty());
    end;

    local procedure HasAssignedFlowStatus(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FlowStatusCode: Code[10]): Boolean
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        AssignedFlowStatus.SetRange("Table No.", Database::"NPR NPRE Waiter Pad Line");
        AssignedFlowStatus.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        AssignedFlowStatus.SetRange("Flow Status Code", FlowStatusCode);
        exit(not AssignedFlowStatus.IsEmpty());
    end;

    local procedure CreateRoleItem(Description: Text[100]; Routed: Boolean; var Item: Record Item)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        if not Routed then
            exit;
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
    end;

    local procedure AddRoleLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Description: Text[100]; Quantity: Decimal; AttachedToLineNo: Integer; Routed: Boolean; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
    begin
        CreateRoleItem(Description, Routed, Item);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, AttachedToLineNo, WaiterPadLine);
    end;

    local procedure CreatePadWithOwnLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'OTHER', 1, 0, true, WaiterPadLine);
    end;

    local procedure AddBillLine(var BillLines: JsonArray; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MoveQuantity: Decimal)
    var
        BillLine: JsonObject;
    begin
        BillLine.Add('key', WaiterPadLine.GetPosition());
        BillLine.Add('qty', MoveQuantity);
        BillLines.Add(BillLine);
    end;

    local procedure SplitBill(SourcePad: Record "NPR NPRE Waiter Pad"; BillLines: JsonArray; TargetPad: Record "NPR NPRE Waiter Pad")
    var
        SplitBillB: Codeunit "NPR POSAction Split Bill-B";
        Bill: JsonObject;
        Bills: JsonArray;
        WaiterPadNo: Code[20];
    begin
        Bill.Add('id', TargetPad."No.");
        Bill.Add('items', BillLines);
        Bills.Add(Bill);
        WaiterPadNo := SourcePad."No.";
        SplitBillB.ProcessWaiterPadSplit(WaiterPadNo, Bills.AsToken(), 0);
    end;

    internal procedure PadContent(WaiterPadNo: Code[20]) Content: Text
    var
        ParentLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Comments: Text;
        Entry: Text;
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        if not WaiterPadLine.FindSet() then
            exit;
        repeat
            if (WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Comment) and (WaiterPadLine."Attached to Line No." <> 0) then begin
                if not ParentLine.Get(WaiterPadNo, WaiterPadLine."Attached to Line No.") then
                    AddToContent(Content, StrSubstNo(OrphanCommentTxt, WaiterPadLine.Description));
            end else begin
                Entry := WaiterPadLine.Description;
                if WaiterPadLine."Line Type" = WaiterPadLine."Line Type"::Item then
                    Entry := StrSubstNo(ItemEntryTxt, Entry, WaiterPadLine.Quantity);
                if WaiterPadLine."Billed Quantity" <> 0 then
                    Entry := StrSubstNo(BilledEntryTxt, Entry, WaiterPadLine."Billed Quantity");
                if WaiterPadLine."Attached to Line No." <> 0 then
                    if ParentLine.Get(WaiterPadNo, WaiterPadLine."Attached to Line No.") then
                        Entry := StrSubstNo(AttachedEntryTxt, Entry, ParentLine.Description)
                    else
                        Entry := StrSubstNo(AttachedEntryTxt, Entry, MissingParentTxt);
                Comments := CommentsAttachedTo(WaiterPadNo, WaiterPadLine."Line No.");
                if Comments <> '' then
                    Entry := StrSubstNo(CommentsEntryTxt, Entry, Comments);
                AddToContent(Content, Entry);
            end;
        until WaiterPadLine.Next() = 0;
    end;

    local procedure CommentsAttachedTo(WaiterPadNo: Code[20]; ParentLineNo: Integer) Comments: Text
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CommentLine.SetRange("Waiter Pad No.", WaiterPadNo);
        CommentLine.SetRange("Attached to Line No.", ParentLineNo);
        CommentLine.SetRange("Line Type", CommentLine."Line Type"::Comment);
        if CommentLine.FindSet() then
            repeat
                if Comments <> '' then
                    Comments += ', ';
                Comments += CommentLine.Description;
            until CommentLine.Next() = 0;
    end;

    internal procedure CommentsOnPad(WaiterPadNo: Code[20]) Comments: Text
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CommentLine.SetRange("Waiter Pad No.", WaiterPadNo);
        CommentLine.SetRange("Line Type", CommentLine."Line Type"::Comment);
        if CommentLine.FindSet() then
            repeat
                AddToContent(Comments, CommentLine.Description);
            until CommentLine.Next() = 0;
    end;

    local procedure AddToContent(var Content: Text; Entry: Text)
    begin
        if Content <> '' then
            Content += '; ';
        Content += Entry;
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;

    internal procedure PadLineOrder(WaiterPadNo: Code[20]) LineOrder: Text
    var
        ParentLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        Entry: Text;
    begin
        // Every line in line order, so the position of a comment among the add-ons shows
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        if WaiterPadLine.FindSet() then
            repeat
                Entry := WaiterPadLine.Description;
                if WaiterPadLine."Attached to Line No." <> 0 then
                    if ParentLine.Get(WaiterPadNo, WaiterPadLine."Attached to Line No.") then
                        Entry := StrSubstNo(AttachedEntryTxt, Entry, ParentLine.Description)
                    else
                        Entry := StrSubstNo(AttachedEntryTxt, Entry, MissingParentTxt);
                AddToContent(LineOrder, Entry);
            until WaiterPadLine.Next() = 0;
    end;

    local procedure FlaggedStations(RequestNo: BigInteger) Stations: Text
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", true);
        if KitchenRequestStation.FindSet() then
            repeat
                AddToContent(Stations, KitchenRequestStation."Kitchen Station");
            until KitchenRequestStation.Next() = 0;
    end;

    local procedure RequestModifiers(RequestNo: BigInteger) Modifiers: Text
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
    begin
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        if KitchenRequestModifier.FindSet() then
            repeat
                AddToContent(Modifiers, KitchenRequestModifier.Description);
            until KitchenRequestModifier.Next() = 0;
    end;

    local procedure RecallAndSavePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
    end;

    internal procedure FailInsertOfItemOnWaiterPad(WaiterPadNo: Code[20]; ItemNo: Code[20])
    begin
        _FailInsertOnWaiterPadNo := WaiterPadNo;
        _FailInsertOfItemNo := ItemNo;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Waiter Pad Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure FailInsertOfTheChosenLine(var Rec: Record "NPR NPRE Waiter Pad Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if (_FailInsertOnWaiterPadNo <> '') and (Rec."Waiter Pad No." = _FailInsertOnWaiterPadNo) and (Rec."No." = _FailInsertOfItemNo) then
            Error(ForcedFailureErr);
    end;

    #endregion
}
