codeunit 85590 "NPR NPRE KDS Order Notes Tests"
{
    // [FEATURE] Order notes of a kitchen order: which comment lines are notes, which pads of the order list them, and the orderNotes property of the KDS board
    Subtype = Test;

    var
        _BarPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        _BarStation: Record "NPR NPRE Kitchen Station";
        _FoodPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        _KitchenStation: Record "NPR NPRE Kitchen Station";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _IsInitialized: Boolean;
        _POSInitialized: Boolean;
        // Declared for its member names only, as the KDS web service declares it, so a test can name the board action it runs
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";
        BarBoardNotesMsg: Label 'F14: orderNotes of order %1 on the board of station BAR, after BEER of pad %2 was split to pad %3 and "Birthday" was added on pad %2.', Locked = true, Comment = '%1 = kitchen order id, %2 = source pad number, %3 = new pad number';
        BlankLineCountMsg: Label 'F10: comment lines of only spaces on pad %1, %2.', Locked = true, Comment = '%1 = waiter pad number, %2 = which pad it is';
        BlankNoteFixtureErr: Label 'F10: the fixture should have put one marked note of spaces on pad %1.', Locked = true, Comment = '%1 = waiter pad number';
        CopiedNoteCountMsg: Label 'F10: comment lines "%1" on pad %2, %3.', Locked = true, Comment = '%1 = note text, %2 = waiter pad number, %3 = which pad it is';
        MainCourseStepTok: Label 'MAIN', Locked = true;
        NewBillTok: Label 'NEW BILL', Locked = true;
        NoKitchenRequestErr: Label 'The fixture should have sent pad %1 to the kitchen.', Locked = true, Comment = '%1 = waiter pad number';
        NoOrderNotesTxt: Label '<no orderNotes property>', Locked = true;
        NotAnArrayTxt: Label '<orderNotes is not an array>', Locked = true;
        NotOnTheBoardTxt: Label '<order not on the board>', Locked = true;
        OnlyMarkedCommentsMsg: Label 'Rows S1.a to S1.j and D1: only a marked comment line with no parent line is an order note. Note lists: <%1>, <%2> and <%3>.', Locked = true, Comment = '%1 = note list of the first order, %2 = note list of the second order, %3 = note list of the third order';
        OrderNotesTok: Label 'orderNotes', Locked = true;
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';

    #region The note list of a kitchen order

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_OnlyMarkedCommentsAreNotes()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        DetachedNotePad: Record "NPR NPRE Waiter Pad";
        OlderNotePad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        DetachedNotePadNotes: List of [Text];
        Notes: List of [Text];
        OlderNotePadNotes: List of [Text];
        Mismatches: Text;
    begin
        // [SCENARIO] Only a comment line with no parent line and the order-note marker is an order note; comments other functions write without the marker and notes saved before the marker are not, and a marked note with only spaces is skipped
        Initialize();

        // [GIVEN] A sent pad with the marked "Milk allergy" as its first line, DISH, "No onions" attached to DISH, BEER, the marked "Birthday", the unmarked "VAT removed from sale: 2.40", "Free coffee coupon" with quantity 1 and "Table 12", a marked Click & Collect delivery comment, and a marked note of spaces
        CreatePad(WaiterPad);
        AddNote(WaiterPad."No.", 'Milk allergy');
        AddDish(WaiterPad, 1, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        AddBeer(WaiterPad, BeerLine);
        AddNote(WaiterPad."No.", 'Birthday');
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'VAT removed from sale: 2.40', 0, CommentLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Free coffee coupon', 0, CommentLine);
        CommentLine.Quantity := 1;
        CommentLine.Modify();
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 12', 0, CommentLine);
        AddNote(WaiterPad."No.", 'Collect Order 1001');
        AddNote(WaiterPad."No.", '   ');
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [GIVEN] A sent pad whose marked "No onions" lost its DISH on the waiter pad page and was then saved again from the POS
        CreatePad(DetachedNotePad);
        AddBeer(DetachedNotePad, BeerLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(DetachedNotePad);
        AddDish(DetachedNotePad, 1, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(DetachedNotePad."No.", 'No onions', DishLine, CommentLine);
        DishLine.Delete(true);
        RecallChangeNotesAndSave(DetachedNotePad, '', '', '', '');

        // [GIVEN] A sent pad with DISH and "Milk allergy" saved before the marker existed, with a blank No.
        CreatePad(OlderNotePad);
        AddDish(OlderNotePad, 1, DishLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(OlderNotePad."No.", 'Milk allergy', 0, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(OlderNotePad);

        // [WHEN] The note list of each pad's kitchen order is read
        OrderNotesMgt.GetOrderNotes(OrderOfPad(WaiterPad."No."), Notes);
        OrderNotesMgt.GetOrderNotes(OrderOfPad(DetachedNotePad."No."), DetachedNotePadNotes);
        OrderNotesMgt.GetOrderNotes(OrderOfPad(OlderNotePad."No."), OlderNotePadNotes);

        // [THEN] Only the marked comment lines with no parent line are listed, and the marked note of spaces is skipped
        CheckRow('S1.a "Milk allergy", No. "*", not attached, first line of the pad', 'listed', ListedState(Notes, 'Milk allergy'), Mismatches);
        CheckRow('S1.b "Birthday", No. "*", not attached, after BEER', 'listed', ListedState(Notes, 'Birthday'), Mismatches);
        CheckRow('S1.c "No onions" attached to DISH', 'not listed', ListedState(Notes, 'No onions'), Mismatches);
        CheckRow(
            'S1.d "No onions", No. "*", whose DISH was deleted on the pad, saved again', 'listed',
            ListedState(DetachedNotePadNotes, 'No onions'), Mismatches);
        CheckRow('S1.e item line DISH', 'not listed', ListedState(Notes, 'DISH'), Mismatches);
        CheckRow('S1.e item line BEER', 'not listed', ListedState(Notes, 'BEER'), Mismatches);
        CheckRow(
            'S1.f "VAT removed from sale: 2.40" of Set Sale VAT, No. blank', 'not listed',
            ListedState(Notes, 'VAT removed from sale: 2.40'), Mismatches);
        CheckRow(
            'S1.g scanned coupon comment "Free coffee coupon", quantity 1, No. blank', 'not listed',
            ListedState(Notes, 'Free coffee coupon'), Mismatches);
        CheckRow('S1.h "Table 12" of Table Buzzer, No. blank', 'not listed', ListedState(Notes, 'Table 12'), Mismatches);
        CheckRow(
            'S1.i (E9) "Milk allergy" saved before the marker, No. blank', 'not listed',
            ListedState(OlderNotePadNotes, 'Milk allergy'), Mismatches);
        CheckRow(
            'S1.j (E26) Click & Collect delivery comment "Collect Order 1001", No. "*"', 'listed',
            ListedState(Notes, 'Collect Order 1001'), Mismatches);
        CheckRow('D1 marked note of spaces', 'not listed', BlankNoteState(Notes), Mismatches);
        _Assert.AreEqual(
            '', Mismatches, StrSubstNo(OnlyMarkedCommentsMsg, JoinNotes(Notes), JoinNotes(DetachedNotePadNotes), JoinNotes(OlderNotePadNotes)));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_OnePadFeedsTwoOrders_SharedCacheGivesEachOrderItsList()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        PadA: Record "NPR NPRE Waiter Pad";
        PadB: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstBuildCache: Dictionary of [Code[20], List of [Text]];
        SecondBuildCache: Dictionary of [Code[20], List of [Text]];
        BeerOrderId: BigInteger;
        DishOrderId: BigInteger;
        PadBOnlyOrderId: BigInteger;
        PadsAAndBOrderId: BigInteger;
        FirstBuildBeerOrderNotes: Text;
        FirstBuildDishOrderNotes: Text;
        FirstBuildPadBOnlyOrderNotes: Text;
        FirstBuildPadsAAndBOrderNotes: Text;
        Mismatches: Text;
        SecondBuildBeerOrderNotes: Text;
        SecondBuildDishOrderNotes: Text;
    begin
        // [SCENARIO] One pad-notes cache per board build gives each kitchen order the current notes of the pads that feed it, also when a pad feeds two orders and a second pad feeds one of them, and a note added between two builds shows in the next build
        Initialize();

        // [GIVEN] A pad with DISH and "Milk allergy" sent to the kitchen and its order finished, then BEER added and sent, which starts a second order fed by the same pad
        CreatePad(WaiterPad);
        AddDish(WaiterPad, 1, DishLine);
        AddNote(WaiterPad."No.", 'Milk allergy');
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        DishOrderId := OrderOfLine(DishLine);
        _LibraryRestaurant.FinishKitchenOrder(DishOrderId);
        AddBeer(WaiterPad, BeerLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        BeerOrderId := OrderOfLine(BeerLine);
        _Assert.IsTrue(DishOrderId <> BeerOrderId, 'E8: the fixture should have started a second kitchen order for BEER after the order of DISH finished.');

        // [GIVEN] Pad A with DISH 2 sent to the kitchen and DISH 1 split to a new pad B, so both pads feed one order; "Milk allergy" added to pad A and "Birthday" to pad B; that order finished, then BEER added to pad B and sent, which starts an order fed by pad B only
        CreatePad(PadA);
        AddDish(PadA, 2, DishLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadA);
        PadsAAndBOrderId := OrderOfLine(DishLine);
        PadB.Get(SplitToANewBill(PadA."No.", DishLine, 1));
        AddNote(PadA."No.", 'Milk allergy');
        AddNote(PadB."No.", 'Birthday');
        _LibraryRestaurant.FinishKitchenOrder(PadsAAndBOrderId);
        AddBeer(PadB, BeerLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(PadB);
        PadBOnlyOrderId := OrderOfLine(BeerLine);
        _Assert.IsTrue(
            PadsAAndBOrderId <> PadBOnlyOrderId, 'E8: the fixture should have started a second kitchen order for BEER of pad B after the order of pads A and B finished.');

        // [WHEN] A first board build reads, with one pad-notes cache, the orders of DISH and BEER, then the order of pads A and B, then the order of pad B only; "Birthday" is added to the pad of DISH and BEER; a second build reads the orders of DISH and BEER with a new cache
        FirstBuildDishOrderNotes := CachedOrderNotes(DishOrderId, FirstBuildCache);
        FirstBuildBeerOrderNotes := CachedOrderNotes(BeerOrderId, FirstBuildCache);
        FirstBuildPadsAAndBOrderNotes := CachedOrderNotes(PadsAAndBOrderId, FirstBuildCache);
        FirstBuildPadBOnlyOrderNotes := CachedOrderNotes(PadBOnlyOrderId, FirstBuildCache);
        AddNote(WaiterPad."No.", 'Birthday');
        SecondBuildDishOrderNotes := CachedOrderNotes(DishOrderId, SecondBuildCache);
        SecondBuildBeerOrderNotes := CachedOrderNotes(BeerOrderId, SecondBuildCache);

        // [THEN] Each order lists the notes of the pads that feed it in each build, and the second build lists "Birthday" too
        CheckRow('E8 first build, order of DISH', 'Milk allergy', FirstBuildDishOrderNotes, Mismatches);
        CheckRow('E8 first build, order of BEER, from the same cache', 'Milk allergy', FirstBuildBeerOrderNotes, Mismatches);
        CheckRow('E8 first build, order fed by pads A and B, from the same cache', 'Milk allergy, Birthday', FirstBuildPadsAAndBOrderNotes, Mismatches);
        CheckRow(
            'E8 first build, order fed by pad B only, from the same cache after the order of pads A and B', 'Birthday',
            FirstBuildPadBOnlyOrderNotes, Mismatches);
        CheckRow('E8 second build with a new cache, order of DISH', 'Milk allergy, Birthday', SecondBuildDishOrderNotes, Mismatches);
        CheckRow('E8 second build with a new cache, order of BEER', 'Milk allergy, Birthday', SecondBuildBeerOrderNotes, Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row E8 (S3 order lists): one cache per board build gives each order the current notes of the pads that feed it.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_OrderWideListAndOrder()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AttachedCommentPad: Record "NPR NPRE Waiter Pad";
        ClosedPad: Record "NPR NPRE Waiter Pad";
        DishOnlyPad: Record "NPR NPRE Waiter Pad";
        EqualTextPad: Record "NPR NPRE Waiter Pad";
        TwoNotesPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        AttachedCommentPadNotes: Text;
        ClosedPadNotes: Text;
        DishOnlyPadNotes: Text;
        EqualTextPadNotes: Text;
        Mismatches: Text;
        TwoNotesPadNotes: Text;
    begin
        // [SCENARIO] An order lists the notes of its pad in pad line order, an equal text once, an attached comment never, an empty list without notes, and the notes of a pad closed on payment
        Initialize();

        // [GIVEN] Per row, a sent pad with the row's lines; the pad with DISH and "Milk allergy" is then paid and closed while its order stays open
        CreatePad(TwoNotesPad);
        AddNote(TwoNotesPad."No.", 'Milk allergy');
        AddDish(TwoNotesPad, 1, DishLine);
        AddNote(TwoNotesPad."No.", 'Birthday');
        _LibraryRestaurant.SendWaiterPadToKitchen(TwoNotesPad);

        CreatePad(AttachedCommentPad);
        AddDish(AttachedCommentPad, 1, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(AttachedCommentPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(AttachedCommentPad);

        CreateSentPadWithDish(DishOnlyPad, '');

        CreateSentPadWithDish(ClosedPad, 'Milk allergy');
        FindDishLine(ClosedPad."No.", DishLine);
        _LibraryRestaurant.SetWaiterPadLineBilledQuantity(DishLine, 1);
        ClosedPad.Find();
        WaiterPadMgt.TryCloseWaiterPad(ClosedPad, true, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        CreatePad(EqualTextPad);
        AddDish(EqualTextPad, 1, DishLine);
        AddNote(EqualTextPad."No.", 'Milk allergy');
        AddNote(EqualTextPad."No.", 'milk allergy ');
        _LibraryRestaurant.SendWaiterPadToKitchen(EqualTextPad);

        // [WHEN] The note list of each row's kitchen order is read
        TwoNotesPadNotes := OrderNotesOfPad(TwoNotesPad."No.");
        AttachedCommentPadNotes := OrderNotesOfPad(AttachedCommentPad."No.");
        DishOnlyPadNotes := OrderNotesOfPad(DishOnlyPad."No.");
        ClosedPadNotes := OrderNotesOfPad(ClosedPad."No.");
        EqualTextPadNotes := OrderNotesOfPad(EqualTextPad."No.");

        // [THEN] Each order lists the row's notes
        CheckRow('S3.a pad: "Milk allergy", DISH, "Birthday"', 'Milk allergy, Birthday', TwoNotesPadNotes, Mismatches);
        CheckRow('S3.d pad: DISH, "No onions" attached to DISH', '', AttachedCommentPadNotes, Mismatches);
        CheckRow('S3.e pad: DISH only', '', DishOnlyPadNotes, Mismatches);
        CheckRow('S3.f pad closed by payment', 'closed', PadState(ClosedPad."No."), Mismatches);
        CheckRow('S3.f order of the pad closed by payment, still open', 'Milk allergy', ClosedPadNotes, Mismatches);
        CheckRow('S3.h pad: DISH, "Milk allergy", "milk allergy "', 'Milk allergy', EqualTextPadNotes, Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S3.a, S3.d, S3.e, S3.f and S3.h: the note list of a kitchen order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_AfterASplitOrMerge()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        CorrectedNotePad: Record "NPR NPRE Waiter Pad";
        MergedIntoPad: Record "NPR NPRE Waiter Pad";
        MergedPad: Record "NPR NPRE Waiter Pad";
        SameRequestPad: Record "NPR NPRE Waiter Pad";
        SplitPad: Record "NPR NPRE Waiter Pad";
        SplitMergeTests: Codeunit "NPR NPRE W/Pad SplitMergeTests";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        MergedIntoOrderId: BigInteger;
        SameRequestNewPadNo: Code[20];
        SplitNewPadNo: Code[20];
        CorrectedNotePadNotes: Text;
        MergedIntoPadNotes: Text;
        Mismatches: Text;
        SameRequestPadNotes: Text;
        SplitPadNotes: Text;
    begin
        // [SCENARIO] After a split or a merge an order lists the current notes of every pad linked to it, the pads in the order of their lowest request and then of their number, an equal text once
        Initialize();

        // [GIVEN] Per row, the pads of the row built through a split or a merge of sent pads, and the row's later note changes
        CreateSentPadWithDishBeerAndNote(SplitPad, 'Table 6 VIP', BeerLine);
        SplitNewPadNo := SplitToANewBill(SplitPad."No.", BeerLine, 1);

        CreateSentPadWithDish(MergedIntoPad, 'Milk allergy');
        MergedIntoOrderId := OrderOfPad(MergedIntoPad."No.");
        CreatePad(MergedPad);
        AddBeer(MergedPad, BeerLine);
        AddNote(MergedPad."No.", 'Birthday');
        _LibraryRestaurant.SendWaiterPadToKitchen(MergedPad);
        MergedPad.Find();
        MergedIntoPad.Find();
        WaiterPadMgt.MergeWaiterPad(MergedPad, MergedIntoPad);

        CreateSentPadWithDishBeerAndNote(CorrectedNotePad, 'Milk allergy', BeerLine);
        SplitToANewBill(CorrectedNotePad."No.", BeerLine, 1);
        RecallChangeNotesAndSave(CorrectedNotePad, 'Milk allergy', '', '', 'Nut allergy');

        CreatePad(SameRequestPad);
        AddDish(SameRequestPad, 2, DishLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(SameRequestPad);
        SameRequestNewPadNo := SplitToANewBill(SameRequestPad."No.", DishLine, 1);
        AddNote(SameRequestPad."No.", 'Birthday');
        AddNote(SameRequestNewPadNo, 'Milk allergy');

        // [WHEN] The note list of each row's kitchen order is read
        SplitPadNotes := OrderNotesOfPad(SplitPad."No.");
        MergedIntoPadNotes := OrderNotes(MergedIntoOrderId);
        CorrectedNotePadNotes := OrderNotesOfPad(CorrectedNotePad."No.");
        SameRequestPadNotes := OrderNotesOfPad(SameRequestPad."No.");

        // [THEN] Each order lists the row's notes in the row's order
        CheckRow('S3.b pad B holds the copy of "Table 6 VIP"', 'Table 6 VIP', SplitMergeTests.CommentsOnPad(SplitNewPadNo), Mismatches);
        CheckRow('S3.b pads A and B both hold "Table 6 VIP"', 'Table 6 VIP', SplitPadNotes, Mismatches);
        CheckRow('S3.c pad B merged into pad A', 'Milk allergy, Birthday', MergedIntoPadNotes, Mismatches);
        CheckRow('S3.i "Milk allergy" deleted and "Nut allergy" added on pad A after the split', 'Nut allergy, Milk allergy', CorrectedNotePadNotes, Mismatches);
        CheckRow('S3.j pads A and B on the same DISH request', 'Birthday, Milk allergy', SameRequestPadNotes, Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S3.b, S3.c, S3.i and S3.j: the note list of an order fed by several pads.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_BlankNote_SplitCopiesNoBlankLine()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        NewPadNo: Code[20];
    begin
        // [SCENARIO] A split copies the order notes of the source pad to the new pad but not a marked note of only spaces
        Initialize();

        // [GIVEN] F10: pad A with DISH, BEER, the marked "Milk allergy" and a marked note of spaces, sent to the kitchen
        CreatePad(SourcePad);
        AddDish(SourcePad, 1, DishLine);
        AddBeer(SourcePad, BeerLine);
        AddNote(SourcePad."No.", 'Milk allergy');
        AddNote(SourcePad."No.", '   ');
        _LibraryRestaurant.SendWaiterPadToKitchen(SourcePad);
        _Assert.AreEqual(1, BlankCommentLineCount(SourcePad."No."), StrSubstNo(BlankNoteFixtureErr, SourcePad."No."));

        // [WHEN] BEER of pad A is split to a new pad B
        NewPadNo := SplitToANewBill(SourcePad."No.", BeerLine, 1);

        // [THEN] Pad B holds "Milk allergy" once and no comment line of only spaces
        _Assert.AreEqual(1, CommentLineCount(NewPadNo, 'Milk allergy'), StrSubstNo(CopiedNoteCountMsg, 'Milk allergy', NewPadNo, 'the new pad of the split'));
        _Assert.AreEqual(0, BlankCommentLineCount(NewPadNo), StrSubstNo(BlankLineCountMsg, NewPadNo, 'the new pad of the split'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_BlankNote_MergeCopiesNoBlankLine()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        MergedIntoPad: Record "NPR NPRE Waiter Pad";
        MergedPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A merge copies the order notes of the merged pad to the target pad but not a marked note of only spaces
        Initialize();

        // [GIVEN] F10: pad A with DISH sent to the kitchen, and pad B with BEER, the marked "Birthday" and a marked note of spaces, sent to the kitchen
        CreateSentPadWithDish(MergedIntoPad, '');
        CreatePad(MergedPad);
        AddBeer(MergedPad, BeerLine);
        AddNote(MergedPad."No.", 'Birthday');
        AddNote(MergedPad."No.", '   ');
        _LibraryRestaurant.SendWaiterPadToKitchen(MergedPad);
        _Assert.AreEqual(1, BlankCommentLineCount(MergedPad."No."), StrSubstNo(BlankNoteFixtureErr, MergedPad."No."));
        MergedPad.Find();
        MergedIntoPad.Find();

        // [WHEN] Pad B is merged into pad A
        WaiterPadMgt.MergeWaiterPad(MergedPad, MergedIntoPad);

        // [THEN] Pad A holds "Birthday" once and no comment line of only spaces
        _Assert.AreEqual(1, CommentLineCount(MergedIntoPad."No.", 'Birthday'), StrSubstNo(CopiedNoteCountMsg, 'Birthday', MergedIntoPad."No.", 'the target pad of the merge'));
        _Assert.AreEqual(0, BlankCommentLineCount(MergedIntoPad."No."), StrSubstNo(BlankLineCountMsg, MergedIntoPad."No.", 'the target pad of the merge'));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_AfterASaveChange()
    var
        AddedPad: Record "NPR NPRE Waiter Pad";
        ApiEditedPad: Record "NPR NPRE Waiter Pad";
        AutoSentPad: Record "NPR NPRE Waiter Pad";
        CorrectedPad: Record "NPR NPRE Waiter Pad";
        DeletedPad: Record "NPR NPRE Waiter Pad";
        UnchangedPad: Record "NPR NPRE Waiter Pad";
        ZoomEditedPad: Record "NPR NPRE Waiter Pad";
        PrintLogEntriesBeforeSave: Integer;
        Mismatches: Text;
    begin
        // [SCENARIO] After a note is added, edited or deleted in the POS and the sale is saved, the next poll lists the current notes; no station is flagged and the auto-send prints nothing new
        Initialize();

        // [GIVEN] Per row, a pad with DISH, and "Milk allergy" where the row has it, sent to the kitchen
        CreateSentPadWithDish(AddedPad, '');
        CreateSentPadWithDish(DeletedPad, 'Milk allergy');
        CreateSentPadWithDish(UnchangedPad, 'Milk allergy');
        CreateSentPadWithDish(ZoomEditedPad, 'Milk allergy');
        CreateSentPadWithDish(ApiEditedPad, 'Milk allergy');
        CreateSentPadWithDish(AutoSentPad, 'Milk allergy');
        CreateSentPadWithDish(CorrectedPad, 'Milk allergy');
        PrintLogEntriesBeforeSave := PrintLogEntryCount(AutoSentPad."No.");

        // [WHEN] Per row, the pad is recalled to the POS, the row's change is made in the sale and the sale is saved
        RecallChangeNotesAndSave(AddedPad, '', '', '', 'Milk allergy');
        RecallChangeNotesAndSave(DeletedPad, 'Milk allergy', '', '', '');
        RecallChangeNotesAndSave(UnchangedPad, '', '', '', '');
        RecallChangeNotesAndSave(ZoomEditedPad, '', 'Milk allergy', 'Nut allergy', '');
        RecallChangeNotesAndSave(ApiEditedPad, '', 'Milk allergy', 'Nut allergy', '');
        RecallChangeNotesAndSave(AutoSentPad, '', '', '', 'Birthday');
        RecallChangeNotesAndSave(CorrectedPad, 'Milk allergy', '', '', 'Nut allergy');

        // [THEN] The next poll lists each row's notes, no station of the order is flagged, and the auto-send printed nothing new
        CheckRow('S4.a "Milk allergy" added', 'Milk allergy', OrderNotesOfPad(AddedPad."No."), Mismatches);
        CheckRow('S4.a flagged stations', '', FlaggedStations(AddedPad."No."), Mismatches);
        CheckRow('S4.b "Milk allergy" deleted', '', OrderNotesOfPad(DeletedPad."No."), Mismatches);
        CheckRow('S4.b flagged stations', '', FlaggedStations(DeletedPad."No."), Mismatches);
        CheckRow('S4.c no change, saved again', 'Milk allergy', OrderNotesOfPad(UnchangedPad."No."), Mismatches);
        CheckRow('S4.c flagged stations', '', FlaggedStations(UnchangedPad."No."), Mismatches);
        CheckRow('S4.d edited to "Nut allergy" by Zoom Line', 'Nut allergy', OrderNotesOfPad(ZoomEditedPad."No."), Mismatches);
        CheckRow('S4.d flagged stations', '', FlaggedStations(ZoomEditedPad."No."), Mismatches);
        CheckRow(
            'S4.e edited to "Nut allergy" through the POS Sale Line API description, which runs the same SetDescription',
            'Nut allergy', OrderNotesOfPad(ApiEditedPad."No."), Mismatches);
        CheckRow('S4.e flagged stations', '', FlaggedStations(ApiEditedPad."No."), Mismatches);
        CheckRow('S4.f "Birthday" added with auto-send on', 'Milk allergy, Birthday', OrderNotesOfPad(AutoSentPad."No."), Mismatches);
        CheckRow('S4.f flagged stations', '', FlaggedStations(AutoSentPad."No."), Mismatches);
        CheckRow('S4.f print log entries of the pad', Format(PrintLogEntriesBeforeSave), Format(PrintLogEntryCount(AutoSentPad."No.")), Mismatches);
        CheckRow('S4.g "Milk allergy" deleted and "Nut allergy" added', 'Nut allergy', OrderNotesOfPad(CorrectedPad."No."), Mismatches);
        CheckRow('S4.g flagged stations', '', FlaggedStations(CorrectedPad."No."), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S4.a, S4.b, S4.c, S4.d, S4.e, S4.f and S4.g: the next poll after a change saved from the POS.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_EditedNote_SavedThenRecalled_SaleHasNewText()
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        Mismatches: Text;
    begin
        // [SCENARIO] A note edited in the POS and saved comes back with its new text when the pad is recalled into a new sale
        Initialize();

        // [GIVEN] A pad with DISH and "Milk allergy" sent to the kitchen, recalled to the POS, "Milk allergy" edited to "Nut allergy" and the sale saved
        CreateSentPadWithDish(WaiterPad, 'Milk allergy');
        RecallChangeNotesAndSave(WaiterPad, '', 'Milk allergy', 'Nut allergy', '');

        // [WHEN] The pad is recalled into a new sale
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The comment line of the recalled sale reads "Nut allergy"
        CheckRow('S4.h comment lines of the recalled sale', 'Nut allergy', SaleComments(SalePOS), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Row S4.h: a note edited to "Nut allergy" and saved comes back as "Nut allergy" when the pad is recalled.');
    end;

    #endregion

    #region The KDS board

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_ViewsThatListThem()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishOnlyPad: Record "NPR NPRE Waiter Pad";
        FinishedPad: Record "NPR NPRE Waiter Pad";
        KitchenDonePad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        BarBoard: JsonObject;
        CustomerDisplay: JsonObject;
        ExpediteBoard: JsonObject;
        FinishedOrders: JsonObject;
        KitchenBoard: JsonObject;
        DishOnlyOrderId: BigInteger;
        FinishedOrderId: BigInteger;
        KitchenDoneOrderId: BigInteger;
        OrderId: BigInteger;
        Mismatches: Text;
    begin
        // [SCENARIO] The order header lists the notes on the view of every station with open work of the order, on the expedite view and in the finished orders, and never on the customer display
        Initialize();

        // [GIVEN] Three sent pads with DISH for KITCHEN, BEER for BAR and "Milk allergy", DISH finished at KITCHEN on the second and the order of the third finished, and a sent pad with DISH only
        CreateSentPadWithDishBeerAndNote(WaiterPad, 'Milk allergy', BeerLine);
        OrderId := OrderOfPad(WaiterPad."No.");
        CreateSentPadWithDishBeerAndNote(KitchenDonePad, 'Milk allergy', BeerLine);
        KitchenDoneOrderId := OrderOfPad(KitchenDonePad."No.");
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, _KitchenStation.Code, 0, KitchenDoneOrderId, _KitchenAction::"End Production", ServerId());
        CreateSentPadWithDishBeerAndNote(FinishedPad, 'Milk allergy', BeerLine);
        FinishedOrderId := OrderOfPad(FinishedPad."No.");
        _LibraryRestaurant.FinishKitchenOrder(FinishedOrderId);
        CreateSentPadWithDish(DishOnlyPad, '');
        DishOnlyOrderId := OrderOfPad(DishOnlyPad."No.");

        // [WHEN] The board is built for station KITCHEN, station BAR and the expedite view, the finished orders are read, and the customer display is refreshed
        KitchenBoard := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, _KitchenStation.Code, false, 0DT, ServerId());
        BarBoard := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, _BarStation.Code, false, 0DT, ServerId());
        ExpediteBoard := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', false, 0DT, ServerId());
        FinishedOrders := KDSFrontendAssistImpl.GetFinishedOrders(_Restaurant.Code, 0DT, ServerId());
        CustomerDisplay := KDSFrontendAssistImpl.RefreshCustomerDisplayKitchenOrders(_Restaurant.Code, ServerId());

        // [THEN] Each view carries the row's notes
        CheckRow('S2.a station KITCHEN', '["Milk allergy"]', BoardOrderNotes(KitchenBoard, OrderId), Mismatches);
        CheckRow('S2.b station BAR', '["Milk allergy"]', BoardOrderNotes(BarBoard, OrderId), Mismatches);
        CheckRow('S2.c expedite view', '["Milk allergy"]', BoardOrderNotes(ExpediteBoard, OrderId), Mismatches);
        CheckRow('S2.d station KITCHEN with DISH finished there and BEER open', NotOnTheBoardTxt, BoardOrderNotes(KitchenBoard, KitchenDoneOrderId), Mismatches);
        CheckRow('S2.e finished orders', '["Milk allergy"]', BoardOrderNotes(FinishedOrders, FinishedOrderId), Mismatches);
        CheckRow('S2.f customer display', 'absent', NotesPropertyOnTheDisplay(CustomerDisplay, OrderId), Mismatches);
        CheckRow('S2.g station KITCHEN, DISH only', '[]', BoardOrderNotes(KitchenBoard, DishOnlyOrderId), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S2.a, S2.b, S2.c, S2.d, S2.e, S2.f and S2.g: the views of the board that carry the order notes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_BarBoardAfterASplitAndAnAddedNote()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        BarBoard: JsonObject;
        OrderId: BigInteger;
        NewPadNo: Code[20];
    begin
        // [SCENARIO] After BEER is split to a new pad and a note is added on the source pad, the BAR station board lists the notes of both pads for the order, although only the BEER request of the new pad is at BAR
        Initialize();

        // [GIVEN] S3.g: pad A with DISH for KITCHEN, BEER for BAR and "Milk allergy", sent to the kitchen; BEER split to a new pad B; then "Birthday" added on pad A in the POS and the sale saved
        CreateSentPadWithDishBeerAndNote(SourcePad, 'Milk allergy', BeerLine);
        NewPadNo := SplitToANewBill(SourcePad."No.", BeerLine, 1);
        RecallChangeNotesAndSave(SourcePad, '', '', '', 'Birthday');
        OrderId := OrderOfPad(NewPadNo);

        // [WHEN] The board is built for station BAR
        BarBoard := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, _BarStation.Code, false, 0DT, ServerId());

        // [THEN] The order on the BAR board carries orderNotes ["Milk allergy","Birthday"]
        _Assert.AreEqual('["Milk allergy","Birthday"]', BoardOrderNotes(BarBoard, OrderId), StrSubstNo(BarBoardNotesMsg, OrderId, SourcePad."No.", NewPadNo));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderNotes_ApiContract()
    var
        DishLine: Record "NPR NPRE Waiter Pad Line";
        DishOnlyPad: Record "NPR NPRE Waiter Pad";
        FinishedPad: Record "NPR NPRE Waiter Pad";
        TwoNotesPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistant: Codeunit "NPR KDS Frontend Assistant";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        BoardFromTheImpl: JsonObject;
        CustomerDisplay: JsonObject;
        ExpediteBoard: JsonObject;
        ExpediteBoardWithFinished: JsonObject;
        FinishedOrders: JsonObject;
        KitchenBoard: JsonObject;
        DishOnlyOrderId: BigInteger;
        FinishedOrderId: BigInteger;
        TwoNotesOrderId: BigInteger;
        Mismatches: Text;
    begin
        // [SCENARIO] Every web service call that returns the board carries orderNotes, an array of the note texts in list order, and the customer display call does not
        Initialize();

        // [GIVEN] A sent pad with "Milk allergy", DISH and "Birthday", a sent pad with DISH only, and a sent pad with DISH and "Milk allergy" whose order finished a day ago
        CreatePad(TwoNotesPad);
        AddNote(TwoNotesPad."No.", 'Milk allergy');
        AddDish(TwoNotesPad, 1, DishLine);
        AddNote(TwoNotesPad."No.", 'Birthday');
        _LibraryRestaurant.SendWaiterPadToKitchen(TwoNotesPad);
        TwoNotesOrderId := OrderOfPad(TwoNotesPad."No.");
        CreateSentPadWithDish(DishOnlyPad, '');
        DishOnlyOrderId := OrderOfPad(DishOnlyPad."No.");
        CreateSentPadWithDish(FinishedPad, 'Milk allergy');
        FinishedOrderId := OrderOfPad(FinishedPad."No.");
        _LibraryRestaurant.FinishKitchenOrder(FinishedOrderId);
        MoveOrderOneDayBack(FinishedOrderId);

        // [WHEN] The board calls of the KDS web service are made, and the board procedure that the obsolete RefreshKDSData and the POS frontend board call run
        KitchenBoard.ReadFrom(KDSFrontendAssistant.RefreshKDSDataV2(_Restaurant.Code, _KitchenStation.Code, false, 0DT, ServerId()));
        ExpediteBoard.ReadFrom(KDSFrontendAssistant.RefreshKDSDataV2(_Restaurant.Code, '', false, 0DT, ServerId()));
        FinishedOrders.ReadFrom(KDSFrontendAssistant.GetFinishedOrdersV2(_Restaurant.Code, 0DT, ServerId()));
        CustomerDisplay.ReadFrom(KDSFrontendAssistant.RefreshCustomerDisplayKitchenOrdersV2(_Restaurant.Code, ServerId()));
        ExpediteBoardWithFinished.ReadFrom(KDSFrontendAssistant.RefreshKDSDataV2(_Restaurant.Code, '', true, 0DT, ServerId()));
        BoardFromTheImpl := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, _KitchenStation.Code, false, 0DT, '');

        // [THEN] Each call carries the row's orderNotes array, or none for the customer display
        CheckRow('S5.a RefreshKDSDataV2, station KITCHEN', '["Milk allergy","Birthday"]', BoardOrderNotes(KitchenBoard, TwoNotesOrderId), Mismatches);
        CheckRow('S5.b RefreshKDSDataV2, expedite, DISH only', '[]', BoardOrderNotes(ExpediteBoard, DishOnlyOrderId), Mismatches);
        CheckRow('S5.c GetFinishedOrdersV2', '["Milk allergy"]', BoardOrderNotes(FinishedOrders, FinishedOrderId), Mismatches);
        CheckRow('S5.d RefreshCustomerDisplayKitchenOrdersV2', 'absent', NotesPropertyOnTheDisplay(CustomerDisplay, TwoNotesOrderId), Mismatches);
        CheckRow(
            'S5.e RefreshKDSDataV2, expedite with includeFinished, order finished a day ago', '["Milk allergy"]',
            BoardOrderNotes(ExpediteBoardWithFinished, FinishedOrderId), Mismatches);
        CheckRow(
            'S5.f obsolete RefreshKDSData, which runs RefreshKDSDataV2 and so this board procedure', '["Milk allergy","Birthday"]',
            BoardOrderNotes(BoardFromTheImpl, TwoNotesOrderId), Mismatches);
        CheckRow(
            'S5.g the POS frontend board call, which runs this board procedure', '["Milk allergy","Birthday"]',
            BoardOrderNotes(BoardFromTheImpl, TwoNotesOrderId), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S5.a, S5.b, S5.c, S5.d, S5.e, S5.f and S5.g: the orderNotes property of the KDS web service.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
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
        _Restaurant."Mark Requests as Served" := _Restaurant."Mark Requests as Served"::Manual;
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"Same for Source Document";
        _Restaurant.Modify();
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
        _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        _POSUnit.Modify();

        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _SeatingLocation."Auto Send Kitchen Order" := _SeatingLocation."Auto Send Kitchen Order"::Yes;
        _SeatingLocation."Resend All On New Lines" := _SeatingLocation."Resend All On New Lines"::No;
        _SeatingLocation.Modify();
        _LibraryRestaurant.CreatePrintCategory(_FoodPrintCategory);
        _LibraryRestaurant.CreatePrintCategory(_BarPrintCategory);
        _LibraryRestaurant.CreateKitchenStation(_KitchenStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStation(_BarStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, _FoodPrintCategory.Code, _KitchenStation.Code, 1);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, _BarPrintCategory.Code, _BarStation.Code, 1);
        _IsInitialized := true;
        Commit();
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreateSentPadWithDish(var WaiterPad: Record "NPR NPRE Waiter Pad"; NoteText: Text)
    var
        DishLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CreatePad(WaiterPad);
        AddDish(WaiterPad, 1, DishLine);
        if NoteText <> '' then
            AddNote(WaiterPad."No.", NoteText);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure CreateSentPadWithDishBeerAndNote(var WaiterPad: Record "NPR NPRE Waiter Pad"; NoteText: Text; var BeerLine: Record "NPR NPRE Waiter Pad Line")
    var
        DishLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CreatePad(WaiterPad);
        AddDish(WaiterPad, 1, DishLine);
        AddBeer(WaiterPad, BeerLine);
        AddNote(WaiterPad."No.", NoteText);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure AddDish(WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        AddRoutedLine(WaiterPad, 'DISH', _FoodPrintCategory.Code, Quantity, WaiterPadLine);
    end;

    local procedure AddBeer(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        AddRoutedLine(WaiterPad, 'BEER', _BarPrintCategory.Code, 1, WaiterPadLine);
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Description: Text[100]; PrintCategoryCode: Code[20]; Quantity: Decimal; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategoryCode);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
    end;

    local procedure AddNote(WaiterPadNo: Code[20]; NoteText: Text)
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.AddWaiterPadOrderNote(WaiterPadNo, NoteText, CommentLine);
    end;

    local procedure FindDishLine(WaiterPadNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange(Description, 'DISH');
        WaiterPadLine.FindFirst();
    end;

    local procedure SplitToANewBill(SourcePadNo: Code[20]; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; MoveQuantity: Decimal) NewPadNo: Code[20]
    var
        SplitBillB: Codeunit "NPR POSAction Split Bill-B";
        Bill: JsonObject;
        BillLine: JsonObject;
        BillLines: JsonArray;
        Bills: JsonArray;
        ChooseBill: Option Active,FirstNew,Ask;
    begin
        // The bill id names no pad, so the split creates the new pad and hands its generated number back here
        BillLine.Add('key', WaiterPadLine.GetPosition());
        BillLine.Add('qty', MoveQuantity);
        BillLines.Add(BillLine);
        Bill.Add('id', NewBillTok);
        Bill.Add('items', BillLines);
        Bills.Add(Bill);
        NewPadNo := SourcePadNo;
        SplitBillB.ProcessWaiterPadSplit(NewPadNo, Bills.AsToken(), ChooseBill::FirstNew);
    end;

    local procedure RecallChangeNotesAndSave(var WaiterPad: Record "NPR NPRE Waiter Pad"; NoteToDelete: Text; NoteToEdit: Text; EditedNote: Text[100]; NoteToAdd: Text[100])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        InsertCommentB: Codeunit "NPR POS Action - Insert Comm B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPad.Find();
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        POSSession.GetSaleLine(POSSaleLine);
        if NoteToDelete <> '' then begin
            FindSaleComment(SalePOS, NoteToDelete, SaleLinePOS);
            SaleLinePOS.Delete(true);
        end;
        if NoteToEdit <> '' then begin
            FindSaleComment(SalePOS, NoteToEdit, SaleLinePOS);
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
            POSSaleLine.SetDescription(EditedNote);
        end;
        if NoteToAdd <> '' then
            InsertCommentB.InputPosCommentLine(NoteToAdd, POSSaleLine);
        SalePOS.Find();
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
    end;

    local procedure FindSaleComment(SalePOS: Record "NPR POS Sale"; Description: Text; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Comment);
        SaleLinePOS.SetRange(Description, Description);
        SaleLinePOS.FindFirst();
    end;

    local procedure MoveOrderOneDayBack(OrderId: BigInteger)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
        KitchenOrder.Get(OrderId);
        KitchenOrder."Created Date-Time" := CurrentDateTime() - (24 * 60 * 60 * 1000);
        KitchenOrder."Finished Date-Time" := CurrentDateTime() - (24 * 60 * 60 * 1000);
        KitchenOrder.Modify();
    end;

    local procedure ServerId(): Text
    begin
        exit(Format(ServiceInstanceId()));
    end;

    #endregion

    #region Reading the result

    local procedure OrderOfPad(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindFirst(), StrSubstNo(NoKitchenRequestErr, WaiterPadNo));
        exit(KitchenRequest."Order ID");
    end;

    local procedure OrderOfLine(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"): BigInteger
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadLine."Waiter Pad No.");
        KitchenReqSourceLink.SetRange("Source Document Line No.", WaiterPadLine."Line No.");
        _Assert.IsTrue(KitchenReqSourceLink.FindFirst(), StrSubstNo(NoKitchenRequestErr, WaiterPadLine."Waiter Pad No."));
        KitchenRequest.Get(KitchenReqSourceLink."Request No.");
        exit(KitchenRequest."Order ID");
    end;

    local procedure OrderNotesOfPad(WaiterPadNo: Code[20]): Text
    begin
        exit(OrderNotes(OrderOfPad(WaiterPadNo)));
    end;

    local procedure CachedOrderNotes(OrderId: BigInteger; var PadNotesCache: Dictionary of [Code[20], List of [Text]]): Text
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        OrderNotesMgt.GetOrderNotes(OrderId, PadNotesCache, Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure OrderNotes(OrderId: BigInteger): Text
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        OrderNotesMgt.GetOrderNotes(OrderId, Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure JoinNotes(Notes: List of [Text]) Joined: Text
    var
        Note: Text;
    begin
        foreach Note in Notes do
            AddToList(Joined, Note);
    end;

    local procedure ListedState(Notes: List of [Text]; Note: Text): Text
    begin
        if Notes.Contains(Note) then
            exit('listed');
        exit('not listed');
    end;

    local procedure BlankNoteState(Notes: List of [Text]): Text
    var
        Note: Text;
    begin
        foreach Note in Notes do
            if DelChr(Note, '=', ' ') = '' then
                exit('listed');
        exit('not listed');
    end;

    local procedure CommentLineCount(WaiterPadNo: Code[20]; Description: Text): Integer
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Comment);
        WaiterPadLine.SetRange(Description, Description);
        exit(WaiterPadLine.Count());
    end;

    local procedure BlankCommentLineCount(WaiterPadNo: Code[20]) LineCount: Integer
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Comment);
        if WaiterPadLine.FindSet() then
            repeat
                if DelChr(WaiterPadLine.Description, '=', ' ') = '' then
                    LineCount += 1;
            until WaiterPadLine.Next() = 0;
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

    local procedure FlaggedStations(WaiterPadNo: Code[20]) Stations: Text
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Order ID", OrderOfPad(WaiterPadNo));
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", true);
        if KitchenRequestStation.FindSet() then
            repeat
                AddToList(Stations, KitchenRequestStation."Kitchen Station");
            until KitchenRequestStation.Next() = 0;
    end;

    local procedure SaleComments(SalePOS: Record "NPR POS Sale") Comments: Text
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Comment);
        if SaleLinePOS.FindSet() then
            repeat
                AddToList(Comments, SaleLinePOS.Description);
            until SaleLinePOS.Next() = 0;
    end;

    local procedure PrintLogEntryCount(WaiterPadNo: Code[20]): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        exit(WPadLinePrintLogEntry.Count());
    end;

    local procedure BoardOrderNotes(Response: JsonObject; OrderId: BigInteger): Text
    var
        Order: JsonObject;
    begin
        if not FindBoardOrder(Response, OrderId, Order) then
            exit(NotOnTheBoardTxt);
        exit(OrderNotesArray(Order));
    end;

    local procedure NotesPropertyOnTheDisplay(Response: JsonObject; OrderId: BigInteger): Text
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Order: JsonObject;
    begin
        if not FindBoardOrder(Response, OrderId, Order) then
            exit(NotOnTheBoardTxt);
        if JsonHelper.TokenExists(Order.AsToken(), OrderNotesTok) then
            exit('present');
        exit('absent');
    end;

    local procedure FindBoardOrder(Response: JsonObject; OrderId: BigInteger; var Order: JsonObject): Boolean
    var
        OrderIdToken: JsonToken;
        OrdersToken: JsonToken;
        OrderToken: JsonToken;
    begin
        if not Response.Get('orders', OrdersToken) then
            exit(false);
        foreach OrderToken in OrdersToken.AsArray() do
            if OrderToken.AsObject().Get('orderId', OrderIdToken) then
                if OrderIdToken.AsValue().AsBigInteger() = OrderId then begin
                    Order := OrderToken.AsObject();
                    exit(true);
                end;
        exit(false);
    end;

    local procedure OrderNotesArray(Order: JsonObject) NotesArray: Text
    var
        NotesToken: JsonToken;
        NoteToken: JsonToken;
        NoteJson: Text;
    begin
        if not Order.Get(OrderNotesTok, NotesToken) then
            exit(NoOrderNotesTxt);
        if not NotesToken.IsArray() then
            exit(NotAnArrayTxt);
        foreach NoteToken in NotesToken.AsArray() do begin
            NoteToken.WriteTo(NoteJson);
            if NotesArray <> '' then
                NotesArray += ',';
            NotesArray += NoteJson;
        end;
        NotesArray := '[' + NotesArray + ']';
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
