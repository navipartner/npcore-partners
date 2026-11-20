codeunit 85592 "NPR NPRE W/Pad Notes Tests"
{
    // [FEATURE] Order notes on a split bill and a waiter pad merge: the copies on the target pad, held by no sale, rolled back with a failed action
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _SplitMergeTests: Codeunit "NPR NPRE W/Pad SplitMergeTests";
        _ConfirmCount: Integer;
        _ConfirmQuestion: Text;
        _FailCloseOfWaiterPadNo: Code[20];
        _FailInsertOfItemNo: Code[20];
        _FailInsertSourcePadNo: Code[20];
        _IsInitialized: Boolean;
        _POSInitialized: Boolean;
        ForcedCloseFailureErr: Label 'The test forced the close of the merged waiter pad to fail.', Locked = true;
        ForcedMoveFailureErr: Label 'The test forced the move of this line to another waiter pad to fail.', Locked = true;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        NewBillTok: Label 'NEW BILL', Locked = true;
        NoKitchenRequestErr: Label 'The fixture should have sent pad %1 to the kitchen.', Locked = true, Comment = '%1 = waiter pad number';
        ParkedSaleNotLoadedErr: Label 'F9: the fixture should have resumed the parked sale %1.', Locked = true, Comment = '%1 = sales ticket number of the parked sale';
        ParkedSaveNewPadMsg: Label 'F9: content of the new pad %1 after the parked sale of the source pad was resumed and saved.', Locked = true, Comment = '%1 = waiter pad number';
        ParkedSaveNoteCountMsg: Label 'F9: lines "Milk allergy" on the source pad %1 after its parked sale was resumed and saved.', Locked = true, Comment = '%1 = waiter pad number';
        ParkedSaleWarningTxt: Label 'is currently held in a parked sale', Locked = true;
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';
        WarningsTxt: Label '%1 warning(s), the last: %2', Locked = true, Comment = '%1 = number of confirm dialogs, %2 = the last question';

    #region Split bill

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_NotesCopiedToTheNewBill()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        Seating: Record "NPR NPRE Seating";
        PadC: Record "NPR NPRE Waiter Pad";
        SourcePad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        NewPadNo: Code[20];
        Mismatches: Text;
    begin
        // [SCENARIO] A split copies the order notes of the source pad after the lines moved to the target pad; the source keeps its notes, or closes and loses them when only comments are left
        Initialize();

        // [GIVEN] Per row, a source pad with the row's lines, sent only in the row that says so
        // [WHEN] The row's selection is split to a new pad, or to pad C
        // [THEN] The source pad and the target pad hold the row's lines
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);
        CheckRow('S10.a source pad', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.a new pad', 'BEER 1; Milk allergy', PadContent(NewPadNo), Mismatches);

        CreatePad(SourcePad);
        AddNote(SourcePad."No.", 'Milk allergy');
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddNote(SourcePad."No.", 'Birthday');
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);
        CheckRow('S10.b source pad', '', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.b source pad state', 'closed', PadState(SourcePad."No."), Mismatches);
        CheckRow('S10.b new pad', 'DISH 1; Milk allergy; Birthday', PadContent(NewPadNo), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 2, DishLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);
        CheckRow('S10.c source pad', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.c new pad', 'DISH 1; Milk allergy', PadContent(NewPadNo), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        _LibraryRestaurant.SendWaiterPadToKitchen(SourcePad);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);
        CheckRow('S10.d source pad', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.d new pad', 'BEER 1; Milk allergy', PadContent(NewPadNo), Mismatches);
        CheckRow('S10.d kitchen request linked to the new pad', BeerLine."No.", RequestItemsOfPad(NewPadNo), Mismatches);
        CheckRow('S10.d one kitchen order keeps both requests', Format(OrderOfPad(SourcePad."No.")), Format(OrderOfPad(NewPadNo)), Mismatches);
        CheckRow('S10.d note list of the kitchen order', 'Milk allergy', OrderNotesOfPad(NewPadNo), Mismatches);

        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(SourcePad."No.", 'No onions', DishLine, CommentLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);
        CheckRow('S10.e source pad', '', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.e source pad state', 'closed', PadState(SourcePad."No."), Mismatches);
        CheckRow('S10.e new pad', 'DISH 1 [No onions]; Milk allergy', PadContent(NewPadNo), Mismatches);

        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'DISH', 1, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(PadC."No.", 'Milk allergy', DishLine, CommentLine);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        SplitToAnExistingBill(SourcePad."No.", BillLines, PadC."No.");
        CheckRow('S10.o source pad', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.o pad C', 'DISH 1 [Milk allergy]; BEER 1; Milk allergy', PadContent(PadC."No."), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Rows S10.a, S10.b, S10.c, S10.d, S10.e and S10.o: the order notes of the source pad are copied after the lines moved to the target pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_NotesCopiedToAnExistingBill()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        ColaLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        Seating: Record "NPR NPRE Seating";
        PadA: Record "NPR NPRE Waiter Pad";
        PadC: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] A split into an existing pad of the table copies the order notes of the source pad unless the target already holds an equal note
        Initialize();

        // [GIVEN] Per row, pad A with DISH 1, BEER 1 and "Milk allergy", and pad C of the same table with COLA 1 and the row's note
        // [WHEN] BEER 1 is split to pad C, and in the last row split back from pad C to pad A
        // [THEN] Pad A and pad C hold the row's lines, with no second equal note
        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        SplitToAnExistingBill(PadA."No.", BillLines, PadC."No.");
        CheckRow('S10.f pad A', 'DISH 1; Milk allergy', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.f pad C', 'COLA 1; BEER 1; Milk allergy', PadContent(PadC."No."), Mismatches);

        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        AddNote(PadC."No.", 'Milk allergy');
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        SplitToAnExistingBill(PadA."No.", BillLines, PadC."No.");
        CheckRow('S10.g pad A', 'DISH 1; Milk allergy', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.g pad C', 'COLA 1; Milk allergy; BEER 1', PadContent(PadC."No."), Mismatches);

        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        SplitToAnExistingBill(PadA."No.", BillLines, PadC."No.");
        FindLineByDescription(PadC."No.", 'BEER', BeerLine);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        SplitToAnExistingBill(PadC."No.", BillLines, PadA."No.");
        CheckRow('S10.i pad A', 'DISH 1; Milk allergy; BEER 1', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.i pad C', 'COLA 1; Milk allergy', PadContent(PadC."No."), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Rows S10.f, S10.g and S10.i: an existing pad gets the order notes of the source pad once, after its lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_SeveralSourcePads()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        ColaLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        Seating: Record "NPR NPRE Seating";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        PadC: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Bills: JsonArray;
        SecondBillLines: JsonArray;
        NewPadNo: Code[20];
        Mismatches: Text;
    begin
        // [SCENARIO] A split with several source pads copies to each target the notes its source pads held when the split started, and a pad that is both source and target keeps its own notes
        Initialize();

        // [GIVEN] Per row, pads of one table with the row's lines
        // [WHEN] The row's lines of several pads are split in one action
        // [THEN] Each target holds its lines and then the notes of its sources; a source left with only comments closes and loses them
        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        AddNote(PadC."No.", 'Birthday');
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        AddBillLine(BillLines, ColaLine, 1);
        NewPadNo := SplitToANewBill(PadA."No.", BillLines);
        CheckRow('S10.j pad A', '', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.j pad A state', 'closed', PadState(PadA."No."), Mismatches);
        CheckRow('S10.j pad C', '', PadContent(PadC."No."), Mismatches);
        CheckRow('S10.j pad C state', 'closed', PadState(PadC."No."), Mismatches);
        CheckRow('S10.j new pad D', 'DISH 1; COLA 1; Milk allergy; Birthday', PadContent(NewPadNo), Mismatches);

        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        AddNote(PadC."No.", 'Birthday');
        Clear(Bills);
        Clear(BillLines);
        AddBillLine(BillLines, BeerLine, 1);
        AddBill(Bills, PadC."No.", BillLines);
        Clear(SecondBillLines);
        AddBillLine(SecondBillLines, ColaLine, 1);
        AddBill(Bills, PadA."No.", SecondBillLines);
        SplitBills(PadA."No.", Bills);
        CheckRow('S10.k pad A', 'DISH 1; Milk allergy; COLA 1; Birthday', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.k pad C', 'Birthday; BEER 1; Milk allergy', PadContent(PadC."No."), Mismatches);

        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        AddNote(PadB."No.", 'Birthday');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);
        Clear(Bills);
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        AddBill(Bills, PadB."No.", BillLines);
        Clear(SecondBillLines);
        AddBillLine(SecondBillLines, BeerLine, 1);
        AddBill(Bills, PadC."No.", SecondBillLines);
        SplitBills(PadA."No.", Bills);
        CheckRow('S10.l pad A', '', PadContent(PadA."No."), Mismatches);
        CheckRow('S10.l pad A state', 'closed', PadState(PadA."No."), Mismatches);
        CheckRow('S10.l pad B', 'Birthday; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S10.l pad C', 'COLA 1; BEER 1; Birthday', PadContent(PadC."No."), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Rows S10.j, S10.k and S10.l: each target gets the notes its source pads held when the split started.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_MoveFails_WholeSplitRolledBack()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FailingMove: Codeunit "NPR NPRE W/Pad Notes Tests";
        BillLines: JsonArray;
        NewPadNo: Code[20];
        PadCountBefore: Integer;
        Mismatches: Text;
    begin
        // [SCENARIO] A split that stops with an error rolls back as a whole, the new pad included, and running it again is a plain first split
        // [GIVEN] Pad A with DISH 1, BEER 1, "Milk allergy" and "Birthday", where the move of BEER to any other pad fails
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        AddNote(SourcePad."No.", 'Birthday');
        AddBillLine(BillLines, DishLine, 1);
        AddBillLine(BillLines, BeerLine, 1);
        FailingMove.FailInsertOfItemOnAnotherPad(SourcePad."No.", BeerLine."No.");
        PadCountBefore := WaiterPad.Count();
        Commit();

        // [WHEN] DISH 1 and BEER 1 are split to a new pad
        BindSubscription(FailingMove);
        asserterror SplitToANewBill(SourcePad."No.", BillLines);
        UnbindSubscription(FailingMove);

        // [THEN] The split fails, pad A is unchanged and no new pad exists
        _Assert.ExpectedError(ForcedMoveFailureErr);
        CheckRow('S10.h source pad after the failed split', 'DISH 1; BEER 1; Milk allergy; Birthday', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.h number of waiter pads after the failed split', Format(PadCountBefore), Format(WaiterPad.Count()), Mismatches);

        // [WHEN] The waiter runs the split again
        Clear(BillLines);
        AddBillLine(BillLines, DishLine, 1);
        AddBillLine(BillLines, BeerLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);

        // [THEN] The second split is a plain first split: the new pad holds both items and both notes, and pad A closes
        CheckRow('S10.h new pad after the second split', 'DISH 1; BEER 1; Milk allergy; Birthday', PadContent(NewPadNo), Mismatches);
        CheckRow('S10.h source pad after the second split', '', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.h source pad state after the second split', 'closed', PadState(SourcePad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S10.h: a failed split rolls back as a whole and the next split is a plain first split.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_RecalledCopy_SavedOnce()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        NewPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        SourcePad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] A copied order note is held by no sale: a recall of the target pad loads it, and a save keeps it once
        Initialize();

        // [GIVEN] Pad A with DISH 1, BEER 1 and "Milk allergy", none sent, and BEER 1 split to a new pad B
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        AddBillLine(BillLines, BeerLine, 1);
        NewPad.Get(SplitToANewBill(SourcePad."No.", BillLines));

        // [WHEN] Pad B is recalled to the POS, saved with no change and sent to the kitchen
        RecallPad(NewPad, POSSession, SalePOS);
        SaveSaleToPad(SalePOS, NewPad);
        _LibraryRestaurant.SendWaiterPadToKitchen(NewPad);

        // [THEN] Pad B holds BEER 1 and "Milk allergy" once, pad A is unchanged, and the ticket header and the KDS of pad B list "Milk allergy"
        CheckRow('S10.m source pad', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.m pad B', 'BEER 1; Milk allergy', PadContent(NewPad."No."), Mismatches);
        CheckRow('S10.m ticket header of pad B', 'Milk allergy', PadHeaderNotes(NewPad."No."), Mismatches);
        CheckRow('S10.m KDS note list of the order of pad B', 'Milk allergy', OrderNotesOfPad(NewPad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S10.m: a copied order note is held by no sale, so a recall and a save keep it once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure SplitBill_SourceHeldByParkedSale_CopyHeldByNoSale()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        NewPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        SourcePad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] When the source pad is held by a parked sale, the order note a split copies to the new pad is held by no sale, and a recall of the new pad warns about the parked sale and loads the copy only
        Initialize();

        // [GIVEN] Pad A with DISH 1, BEER 1 and "Milk allergy", recalled to the POS on terminal 1 and parked there
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        RecallPad(SourcePad, POSSession, SalePOS);
        ParkSale(POSSavedSaleEntry);

        // [WHEN] BEER 1 is split to a new pad B from terminal 2
        AddBillLine(BillLines, BeerLine, 1);
        NewPad.Get(SplitToANewBill(SourcePad."No.", BillLines));

        // [THEN] Pad A keeps "Milk allergy" held by the parked sale; pad B holds BEER 1, held by the parked sale, and "Milk allergy", held by no sale; the ticket header of pad B lists it
        CheckRow('S10.n pad A', 'DISH 1; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('S10.n "Milk allergy" of pad A held by', 'the parked sale', SaleHolding(SourcePad."No.", 'Milk allergy', POSSavedSaleEntry.SystemId), Mismatches);
        CheckRow('S10.n pad B', 'BEER 1; Milk allergy', PadContent(NewPad."No."), Mismatches);
        CheckRow('S10.n BEER of pad B held by', 'the parked sale', SaleHolding(NewPad."No.", 'BEER', POSSavedSaleEntry.SystemId), Mismatches);
        CheckRow('S10.n "Milk allergy" of pad B held by', 'no sale', SaleHolding(NewPad."No.", 'Milk allergy', POSSavedSaleEntry.SystemId), Mismatches);
        CheckRow('S10.n ticket header of pad B', 'Milk allergy', PadHeaderNotes(NewPad."No."), Mismatches);

        // [WHEN] Pad B is sent to the kitchen and recalled to the POS on terminal 2
        _LibraryRestaurant.SendWaiterPadToKitchen(NewPad);
        RecallPad(NewPad, POSSession, SalePOS);

        // [THEN] The KDS lists "Milk allergy" for the order of pad B, and the recall warns about the parked sale and loads "Milk allergy" only
        CheckRow('S10.n KDS note list of the order of pad B', 'Milk allergy', OrderNotesOfPad(NewPad."No."), Mismatches);
        CheckRow('S10.n recall of pad B warns about the parked sale', 'warned once', ParkedSaleWarning(), Mismatches);
        CheckRow('S10.n lines the recall of pad B loads', 'Milk allergy', SaleLineDescriptions(SalePOS), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S10.n: the order note a split copies from a pad held by a parked sale is held by no sale.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_SourceHeldByParkedSale_ParkedSaleSavedLater_NoteKeptOnce()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        NewPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        SourcePad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        BillLines: JsonArray;
    begin
        // [SCENARIO] When the source pad of a split is held by a parked sale, the later save of that sale back to the source pad keeps its order note once and leaves the new pad as the split left it
        Initialize();

        // [GIVEN] F9: pad A with DISH 1, BEER 1 and "Milk allergy", recalled to the POS on terminal 1 and parked there, then BEER 1 split to a new pad B from terminal 2
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        RecallPad(SourcePad, POSSession, SalePOS);
        ParkSale(POSSavedSaleEntry);
        AddBillLine(BillLines, BeerLine, 1);
        NewPad.Get(SplitToANewBill(SourcePad."No.", BillLines));

        // [WHEN] The parked sale is resumed on terminal 1 and saved back to pad A
        ResumeParkedSale(POSSavedSaleEntry, POSSession, SalePOS);
        SaveSaleToPad(SalePOS, SourcePad);

        // [THEN] Pad A holds "Milk allergy" once, and pad B still holds BEER 1 and "Milk allergy"
        _Assert.AreEqual(1, LineCount(SourcePad."No.", 'Milk allergy'), StrSubstNo(ParkedSaveNoteCountMsg, SourcePad."No."));
        _Assert.AreEqual('BEER 1; Milk allergy', PadContent(NewPad."No."), StrSubstNo(ParkedSaveNewPadMsg, NewPad."No."));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_LineWithNothingToMove_NoNoteCopied()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        ColaLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        Seating: Record "NPR NPRE Seating";
        PadA: Record "NPR NPRE Waiter Pad";
        PadC: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        Mismatches: Text;
    begin
        // [SCENARIO] A split whose selected line has no quantity left to move copies no order note to the target pad
        Initialize();

        // [GIVEN] Pad A with DISH at quantity 0, BEER 1 and "Milk allergy", and pad C of the same table with COLA 1
        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, PadA);
        AddRoleLine(PadA, 'DISH', 0, DishLine);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePadAtSeating(Seating.Code, PadC);
        AddRoleLine(PadC, 'COLA', 1, ColaLine);

        // [WHEN] DISH 1 is split from pad A to pad C
        AddBillLine(BillLines, DishLine, 1);
        SplitToAnExistingBill(PadA."No.", BillLines, PadC."No.");

        // [THEN] Pad C holds COLA 1 only, and pad A is unchanged
        CheckRow('S10 (F1) pad C', 'COLA 1', PadContent(PadC."No."), Mismatches);
        CheckRow('S10 (F1) pad A', 'DISH 0; BEER 1; Milk allergy', PadContent(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S10 (F1): no order note is copied from a pad whose selected line had nothing to move.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBill_UnmarkedComment_StaysOnSource()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        NewPadNo: Code[20];
        Mismatches: Text;
    begin
        // [SCENARIO] A split leaves a comment line without the order-note marker on the source pad and copies only the order note
        Initialize();

        // [GIVEN] Pad A with DISH 1, BEER 1, the Set Sale VAT comment "VAT removed from sale: 2.40" with a blank No., and the order note "Milk allergy"
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', 1, DishLine);
        AddRoleLine(SourcePad, 'BEER', 1, BeerLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(SourcePad."No.", 'VAT removed from sale: 2.40', 0, CommentLine);
        AddNote(SourcePad."No.", 'Milk allergy');

        // [WHEN] BEER 1 is split to a new pad
        AddBillLine(BillLines, BeerLine, 1);
        NewPadNo := SplitToANewBill(SourcePad."No.", BillLines);

        // [THEN] Pad A keeps both comments, and the new pad holds BEER 1 and the copy of "Milk allergy" only
        CheckRow('E27 source pad', 'DISH 1; VAT removed from sale: 2.40; Milk allergy', PadContent(SourcePad."No."), Mismatches);
        CheckRow('E27 new pad', 'BEER 1; Milk allergy', PadContent(NewPadNo), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row E27: a split leaves a comment without the marker on the source pad and copies only the order note.');
    end;

    #endregion

    #region Merge

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_NotesAddedToPadB()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        BeerOrderId: BigInteger;
        DishOrderId: BigInteger;
        Mismatches: Text;
    begin
        // [SCENARIO] A merge adds every order note of pad A that pad B does not hold yet to the end of pad B, in pad A's line order, and pad A closes
        Initialize();

        // [GIVEN] Per row, pad A and pad B with the row's lines, sent only in the row that says so
        // [WHEN] Pad A is merged into pad B
        // [THEN] Pad B holds the row's lines, pad A is closed, and the kitchen orders list the notes of pad B
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        Merge(PadA, PadB);
        CheckRow('S11.a pad B', 'BEER 1; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.a pad A', '', PadContent(PadA."No."), Mismatches);
        CheckRow('S11.a pad A state', 'closed', PadState(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddNote(PadA."No.", 'Birthday');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        Merge(PadA, PadB);
        CheckRow('S11.b pad B', 'BEER 1; Birthday', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.b pad A', '', PadContent(PadA."No."), Mismatches);
        CheckRow('S11.b pad A state', 'closed', PadState(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        AddNote(PadB."No.", 'Milk allergy');
        Merge(PadA, PadB);
        CheckRow('S11.c pad B', 'BEER 1; Milk allergy; DISH 1', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.c pad A state', 'closed', PadState(PadA."No."), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        _LibraryRestaurant.SendWaiterPadToKitchen(PadA);
        DishOrderId := OrderOfPad(PadA."No.");
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadB);
        BeerOrderId := OrderOfPad(PadB."No.");
        Merge(PadA, PadB);
        CheckRow('S11.d pad B', 'BEER 1; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.d pad A state', 'closed', PadState(PadA."No."), Mismatches);
        CheckRow('S11.d note list of the kitchen order of DISH', 'Milk allergy', OrderNotes(DishOrderId), Mismatches);
        CheckRow('S11.d note list of the kitchen order of BEER', 'Milk allergy', OrderNotes(BeerOrderId), Mismatches);

        CreatePad(PadA);
        AddRoleLine(PadA, 'BEER', 1, BeerLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'DISH', 1, DishLine);
        AddNote(PadB."No.", 'Nut allergy');
        Merge(PadA, PadB);
        CheckRow('S11.f pad B', 'DISH 1; Nut allergy; BEER 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.f pad A state', 'closed', PadState(PadA."No."), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Rows S11.a, S11.b, S11.c, S11.d and S11.f: a merge adds the order notes of pad A that pad B does not hold to the end of pad B.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_MergeFails_WholeMergeRolledBack()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        FailingMerge: Codeunit "NPR NPRE W/Pad Notes Tests";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] A merge that stops with an error after DISH moved rolls back as a whole, and merging again is a plain first merge
        // [GIVEN] Pad A with DISH 1, "Milk allergy" and "Birthday", pad B with BEER 1, and the close of pad A, the last step of the merge, fails
        Initialize();
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        AddNote(PadA."No.", 'Birthday');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        FailingMerge.FailCloseOfWaiterPad(PadA."No.");
        PadA.Find();
        PadB.Find();
        Commit();

        // [WHEN] Pad A is merged into pad B
        BindSubscription(FailingMerge);
        asserterror WaiterPadMgt.MergeWaiterPad(PadA, PadB);
        UnbindSubscription(FailingMerge);

        // [THEN] The merge fails, pad B holds BEER 1 only and pad A is unchanged
        _Assert.ExpectedError(ForcedCloseFailureErr);
        CheckRow('S11.e pad B after the failed merge', 'BEER 1', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.e pad A after the failed merge', 'DISH 1; Milk allergy; Birthday', PadContent(PadA."No."), Mismatches);

        // [WHEN] The waiter merges pad A into pad B again
        Merge(PadA, PadB);

        // [THEN] The second merge is a plain first merge: pad B holds BEER 1, DISH 1 and both notes, and pad A is closed with no lines
        CheckRow('S11.e pad B after the second merge', 'BEER 1; DISH 1; Milk allergy; Birthday', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.e pad A after the second merge', '', PadContent(PadA."No."), Mismatches);
        CheckRow('S11.e pad A state after the second merge', 'closed', PadState(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S11.e: a failed merge rolls back as a whole and the next merge is a plain first merge.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_RecalledCopy_SavedOnce()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        Mismatches: Text;
    begin
        // [SCENARIO] An order note a merge adds to pad B is held by no sale: a recall of pad B loads it, and a save keeps it once
        Initialize();

        // [GIVEN] Pad A with DISH 1 and "Milk allergy" merged into pad B with BEER 1
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        Merge(PadA, PadB);

        // [WHEN] Pad B is recalled to the POS, saved with no change and sent to the kitchen
        RecallPad(PadB, POSSession, SalePOS);
        SaveSaleToPad(SalePOS, PadB);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadB);

        // [THEN] Pad B holds BEER 1, DISH 1 and "Milk allergy" once, and the ticket header and the KDS of pad B list "Milk allergy"
        CheckRow('S11.g pad B', 'BEER 1; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.g pad A state', 'closed', PadState(PadA."No."), Mismatches);
        CheckRow('S11.g ticket header of pad B', 'Milk allergy', PadHeaderNotes(PadB."No."), Mismatches);
        CheckRow('S11.g KDS note list of the order of pad B', 'Milk allergy', OrderNotesOfPad(PadB."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S11.g: an order note a merge adds is held by no sale, so a recall and a save keep it once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_TargetHeldByOpenSale_CopyOnPadOnly()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        Terminal1SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        Mismatches: Text;
    begin
        // [SCENARIO] An order note a merge adds to pad B while pad B is open in a sale on another terminal is on the pad only: that sale does not show it until it recalls pad B
        Initialize();

        // [GIVEN] Pad A with DISH 1 and "Milk allergy", and pad B with BEER 1 loaded in an open sale on terminal 1
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);
        RecallPad(PadB, POSSession, Terminal1SalePOS);

        // [WHEN] Pad A is merged into pad B from terminal 2 and pad B is sent to the kitchen
        Merge(PadA, PadB);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadB);

        // [THEN] Pad B holds BEER 1, DISH 1 and "Milk allergy", its ticket header and the KDS list "Milk allergy", and the open sale on terminal 1 still shows BEER only
        CheckRow('S11.h pad B', 'BEER 1; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.h pad A state', 'closed', PadState(PadA."No."), Mismatches);
        CheckRow('S11.h ticket header of pad B', 'Milk allergy', PadHeaderNotes(PadB."No."), Mismatches);
        CheckRow('S11.h KDS note list of the order of pad B', 'Milk allergy', OrderNotesOfPad(PadB."No."), Mismatches);
        CheckRow('S11.h open sale on terminal 1', 'BEER', SaleLineDescriptions(Terminal1SalePOS), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S11.h: an order note a merge adds to a pad open in another sale is on the pad only.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_MarkedNoteWithQuantityCopiedOnce()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        NoteLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        Mismatches: Text;
    begin
        // [SCENARIO] A merge copies an order note with quantity 1 and a sale link to the end of pad B once, held by no sale, and does not also move it as an item
        Initialize();

        // [GIVEN] Pad A with DISH 1 and the order note "Milk allergy" with quantity 1 and the sale link, as a save of a POS Sale Line API comment writes it, and pad B with BEER 1
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(PadA."No.", 'Milk allergy', NoteLine);
        NoteLine.Quantity := 1;
        NoteLine."Sale Retail ID" := CreateGuid();
        NoteLine."Sale Line Retail ID" := CreateGuid();
        NoteLine.Modify();
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);

        // [WHEN] Pad A is merged into pad B
        Merge(PadA, PadB);

        // [THEN] Pad B holds BEER 1, DISH 1 and "Milk allergy" once with quantity 1, held by no sale, and pad A is closed
        CheckRow('S11.i pad B', 'BEER 1; DISH 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('S11.i quantity of each "Milk allergy" on pad B', '1', LineQuantities(PadB."No.", 'Milk allergy'), Mismatches);
        CheckRow('S11.i each "Milk allergy" on pad B held by', 'no sale', SaleLinks(PadB."No.", 'Milk allergy'), Mismatches);
        CheckRow('S11.i pad A state', 'closed', PadState(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S11.i: a merge copies an order note with quantity 1 once, held by no sale, and does not also move it.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Merge_UnmarkedCommentWithQuantity_MovedAsToday()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        ColaLine: Record "NPR NPRE Waiter Pad Line";
        CouponLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        Mismatches: Text;
    begin
        // [SCENARIO] A merge moves a comment line without the order-note marker that has quantity 1 in its own turn, as it moves an item, and copies only the order note to the end of pad B
        Initialize();

        // [GIVEN] Pad A with DISH 1, a scanned coupon's comment "Free coffee coupon" with quantity 1 and a blank No., COLA 1 and the order note "Milk allergy", and pad B with BEER 1
        CreatePad(PadA);
        AddRoleLine(PadA, 'DISH', 1, DishLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(PadA."No.", 'Free coffee coupon', 0, CouponLine);
        CouponLine.Quantity := 1;
        CouponLine.Modify();
        AddRoleLine(PadA, 'COLA', 1, ColaLine);
        AddNote(PadA."No.", 'Milk allergy');
        CreatePad(PadB);
        AddRoleLine(PadB, 'BEER', 1, BeerLine);

        // [WHEN] Pad A is merged into pad B
        Merge(PadA, PadB);

        // [THEN] Pad B holds the coupon comment once, in pad A's line order before COLA, and the order note at the end; pad A is closed
        CheckRow('E27 pad B', 'BEER 1; DISH 1; Free coffee coupon; COLA 1; Milk allergy', PadContent(PadB."No."), Mismatches);
        CheckRow('E27 pad A state', 'closed', PadState(PadA."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row E27: a merge moves a comment without the marker as today and copies only the order note.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        _ConfirmCount := 0;
        _ConfirmQuestion := '';
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if _IsInitialized then
            exit;

        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateMealFlowStatuses();
        _LibraryRestaurant.CreateSeatingFlowStatuses();
        _LibraryRestaurant.CreateWaiterPadFlowStatuses();
        _LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        _LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
        _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        _POSUnit.Modify();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _IsInitialized := true;
        Commit();
    end;

    local procedure CreateSeating(var Seating: Record "NPR NPRE Seating")
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        CreateSeating(Seating);
        CreatePadAtSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreatePadAtSeating(SeatingCode: Code[20]; var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        _LibraryRestaurant.CreateWaiterPadForSeating(SeatingCode, WaiterPad);
    end;

    local procedure AddRoleLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Description: Text[100]; Quantity: Decimal; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
    end;

    local procedure AddNote(WaiterPadNo: Code[20]; NoteText: Text)
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.AddWaiterPadOrderNote(WaiterPadNo, NoteText, CommentLine);
    end;

    local procedure FindLineByDescription(WaiterPadNo: Code[20]; Description: Text; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, Description);
        WaiterPadLine.FindFirst();
    end;

    local procedure AddBillLine(var BillLines: JsonArray; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MoveQuantity: Decimal)
    var
        BillLine: JsonObject;
    begin
        BillLine.Add('key', WaiterPadLine.GetPosition());
        BillLine.Add('qty', MoveQuantity);
        BillLines.Add(BillLine);
    end;

    local procedure AddBill(var Bills: JsonArray; BillId: Code[20]; BillLines: JsonArray)
    var
        Bill: JsonObject;
    begin
        Bill.Add('id', BillId);
        Bill.Add('items', BillLines);
        Bills.Add(Bill);
    end;

    local procedure SplitToANewBill(SourcePadNo: Code[20]; BillLines: JsonArray) NewPadNo: Code[20]
    var
        SplitBillB: Codeunit "NPR POSAction Split Bill-B";
        Bills: JsonArray;
        ChooseBill: Option Active,FirstNew,Ask;
    begin
        // The bill id names no pad, so the split creates the new pad and hands its generated number back here
        AddBill(Bills, NewBillTok, BillLines);
        NewPadNo := SourcePadNo;
        SplitBillB.ProcessWaiterPadSplit(NewPadNo, Bills.AsToken(), ChooseBill::FirstNew);
    end;

    local procedure SplitToAnExistingBill(SourcePadNo: Code[20]; BillLines: JsonArray; TargetPadNo: Code[20])
    var
        Bills: JsonArray;
    begin
        AddBill(Bills, TargetPadNo, BillLines);
        SplitBills(SourcePadNo, Bills);
    end;

    local procedure SplitBills(CurrentPadNo: Code[20]; Bills: JsonArray)
    var
        SplitBillB: Codeunit "NPR POSAction Split Bill-B";
        ChooseBill: Option Active,FirstNew,Ask;
        WaiterPadNo: Code[20];
    begin
        WaiterPadNo := CurrentPadNo;
        SplitBillB.ProcessWaiterPadSplit(WaiterPadNo, Bills.AsToken(), ChooseBill::Active);
    end;

    local procedure Merge(var PadA: Record "NPR NPRE Waiter Pad"; var PadB: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        PadA.Find();
        PadB.Find();
        WaiterPadMgt.MergeWaiterPad(PadA, PadB);
    end;

    local procedure RecallPad(WaiterPad: Record "NPR NPRE Waiter Pad"; var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        SalePOS.Find();
    end;

    local procedure SaveSaleToPad(var SalePOS: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        SalePOS.Find();
        WaiterPad.Find();
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
    end;

    local procedure ParkSale(var POSSavedSaleEntry: Record "NPR POS Saved Sale Entry")
    var
        POSActionSavePOSSvSlB: Codeunit "NPR POS Action: SavePOSSvSl B";
    begin
        POSActionSavePOSSvSlB.SaveSale(POSSavedSaleEntry);
    end;

    local procedure ResumeParkedSale(var POSSavedSaleEntry: Record "NPR POS Saved Sale Entry"; var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSActionLoadPOSSvSlB: Codeunit "NPR POS Action: LoadPOSSvSl B";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Assert.IsTrue(POSActionLoadPOSSvSlB.LoadFromQuote(POSSavedSaleEntry, SalePOS), StrSubstNo(ParkedSaleNotLoadedErr, POSSavedSaleEntry."Sales Ticket No."));
        POSActionLoadPOSSvSlB.InsertParkedSale(POSSavedSaleEntry, SalePOS);
    end;

    internal procedure FailInsertOfItemOnAnotherPad(SourcePadNo: Code[20]; ItemNo: Code[20])
    begin
        _FailInsertSourcePadNo := SourcePadNo;
        _FailInsertOfItemNo := ItemNo;
    end;

    internal procedure FailCloseOfWaiterPad(WaiterPadNo: Code[20])
    begin
        _FailCloseOfWaiterPadNo := WaiterPadNo;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Waiter Pad Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure FailInsertOfTheItemOnAnotherPad(var Rec: Record "NPR NPRE Waiter Pad Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (_FailInsertOfItemNo = '') then
            exit;
        if (Rec."Line Type" = Rec."Line Type"::Item) and (Rec."No." = _FailInsertOfItemNo) and (Rec."Waiter Pad No." <> _FailInsertSourcePadNo) then
            Error(ForcedMoveFailureErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Waiter Pad", 'OnBeforeModifyEvent', '', false, false)]
    local procedure FailCloseOfThePad(var Rec: Record "NPR NPRE Waiter Pad"; var xRec: Record "NPR NPRE Waiter Pad"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or (_FailCloseOfWaiterPadNo = '') then
            exit;
        if (Rec."No." = _FailCloseOfWaiterPadNo) and Rec.Closed then
            Error(ForcedCloseFailureErr);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        _ConfirmCount += 1;
        _ConfirmQuestion := Question;
        Reply := true;
    end;

    #endregion

    #region Reading the result

    local procedure PadContent(WaiterPadNo: Code[20]): Text
    begin
        exit(_SplitMergeTests.PadContent(WaiterPadNo));
    end;

    local procedure PadState(WaiterPadNo: Code[20]): Text
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        WaiterPad.Get(WaiterPadNo);
        if WaiterPad.Closed then
            exit('closed');
        exit('open');
    end;

    local procedure OrderOfPad(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindFirst(), StrSubstNo(NoKitchenRequestErr, WaiterPadNo));
        exit(KitchenRequest."Order ID");
    end;

    local procedure RequestItemsOfPad(WaiterPadNo: Code[20]) ItemNos: Text
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        if KitchenRequest.FindSet() then
            repeat
                AddToList(ItemNos, KitchenRequest."No.");
            until KitchenRequest.Next() = 0;
    end;

    local procedure OrderNotesOfPad(WaiterPadNo: Code[20]): Text
    begin
        exit(OrderNotes(OrderOfPad(WaiterPadNo)));
    end;

    local procedure OrderNotes(OrderId: BigInteger): Text
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        OrderNotesMgt.GetOrderNotes(OrderId, Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure PadHeaderNotes(WaiterPadNo: Code[20]): Text
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        OrderNotesMgt.GetWaiterPadNotes(WaiterPadNo, Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure JoinNotes(Notes: List of [Text]) Joined: Text
    var
        Note: Text;
    begin
        foreach Note in Notes do
            AddToList(Joined, Note);
    end;

    local procedure SaleHolding(WaiterPadNo: Code[20]; Description: Text; ParkedSaleId: Guid): Text
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, Description);
        if not WaiterPadLine.FindFirst() then
            exit('<no such line on the pad>');
        if IsNullGuid(WaiterPadLine."Sale Retail ID") then
            exit('no sale');
        if WaiterPadLine."Sale Retail ID" = ParkedSaleId then
            exit('the parked sale');
        exit('another sale');
    end;

    local procedure SaleLinks(WaiterPadNo: Code[20]; Description: Text) Links: Text
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, Description);
        if WaiterPadLine.FindSet() then
            repeat
                if IsNullGuid(WaiterPadLine."Sale Retail ID") and IsNullGuid(WaiterPadLine."Sale Line Retail ID") then
                    AddToList(Links, 'no sale')
                else
                    AddToList(Links, 'a sale');
            until WaiterPadLine.Next() = 0;
    end;

    local procedure LineCount(WaiterPadNo: Code[20]; Description: Text): Integer
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, Description);
        exit(WaiterPadLine.Count());
    end;

    local procedure LineQuantities(WaiterPadNo: Code[20]; Description: Text) Quantities: Text
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, Description);
        if WaiterPadLine.FindSet() then
            repeat
                AddToList(Quantities, Format(WaiterPadLine.Quantity));
            until WaiterPadLine.Next() = 0;
    end;

    local procedure ParkedSaleWarning(): Text
    begin
        if (_ConfirmCount = 1) and (StrPos(_ConfirmQuestion, ParkedSaleWarningTxt) > 0) then
            exit('warned once');
        exit(StrSubstNo(WarningsTxt, _ConfirmCount, _ConfirmQuestion));
    end;

    local procedure SaleLineDescriptions(SalePOS: Record "NPR POS Sale") Descriptions: Text
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                AddToList(Descriptions, SaleLinePOS.Description);
            until SaleLinePOS.Next() = 0;
    end;

    local procedure AddToList(var Entries: Text; Entry: Text)
    begin
        if Entries <> '' then
            Entries += ', ';
        Entries += Entry;
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;

    #endregion
}
