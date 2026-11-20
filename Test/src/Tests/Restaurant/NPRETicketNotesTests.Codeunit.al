codeunit 85591 "NPR NPRE Ticket Notes Tests"
{
    // [FEATURE] Order notes on the standard kitchen ticket: the header list of the printing pad, the body without order notes, and the NaviPartner Feature "Order Notes in Kitchen Ticket Header" that switches it on
    Subtype = Test;

    var
        _BarPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        _FoodPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
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
        CommentQuantityTok: Label '0 x ', Locked = true;
        ItemQuantityTok: Label '1 x ', Locked = true;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        NewBillTok: Label 'NEW BILL', Locked = true;
        NoKitchenRequestErr: Label 'The fixture should have sent pad %1 to the kitchen.', Locked = true, Comment = '%1 = waiter pad number';
        NumberOfGuestsTok: Label 'Number of Guests', Locked = true;
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';
        SeparatorTok: Label '--------', Locked = true;
        StarterStepTok: Label 'STARTER', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketHeader_NotesOfThePrintingPad()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AutoSentPad: Record "NPR NPRE Waiter Pad";
        CategorySplitPad: Record "NPR NPRE Waiter Pad";
        DishOnlyPad: Record "NPR NPRE Waiter Pad";
        NoteAfterDishPad: Record "NPR NPRE Waiter Pad";
        ResentPad: Record "NPR NPRE Waiter Pad";
        ServingRequestPad: Record "NPR NPRE Waiter Pad";
        ServingStepsPad: Record "NPR NPRE Waiter Pad";
        SplitPad: Record "NPR NPRE Waiter Pad";
        TwiceTypedPad: Record "NPR NPRE Waiter Pad";
        TwoNotesPad: Record "NPR NPRE Waiter Pad";
        SplitNewPadNo: Code[20];
        AutoSentPadNotes: Text;
        CategorySplitPadNotes: Text;
        DishOnlyPadNotes: Text;
        Mismatches: Text;
        NoteAfterDishPadNotes: Text;
        ResentPadNotes: Text;
        ServingRequestPadNotes: Text;
        ServingStepsPadNotes: Text;
        SplitNewPadNotes: Text;
        SplitPadNotes: Text;
        TwiceTypedPadNotes: Text;
        TwoNotesPadNotes: Text;
    begin
        // [SCENARIO] The ticket header lists the current order notes of the printing pad, each once, in pad line order; a note added to another pad of the same kitchen order is not listed
        Initialize();

        // [GIVEN] Per row, a pad with the row's lines, sent and changed as the row says
        CreatePad(CategorySplitPad);
        AddNote(CategorySplitPad."No.", 'Milk allergy');
        AddRoleLine(CategorySplitPad, 'DISH', MainCourseStepTok, DishLine);
        AddRoleLine(CategorySplitPad, 'BEER', MainCourseStepTok, BeerLine);

        CreatePad(NoteAfterDishPad);
        AddRoleLine(NoteAfterDishPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(NoteAfterDishPad."No.", 'Milk allergy');
        AddRoleLine(NoteAfterDishPad, 'BEER', MainCourseStepTok, BeerLine);

        CreatePad(ResentPad);
        AddRoleLine(ResentPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(ResentPad);
        AddNote(ResentPad."No.", 'Birthday');

        CreatePad(AutoSentPad);
        AddRoleLine(AutoSentPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(AutoSentPad);
        AddNote(AutoSentPad."No.", 'Birthday');
        AddRoleLine(AutoSentPad, 'BEER', MainCourseStepTok, BeerLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(AutoSentPad);

        CreatePad(ServingStepsPad);
        AddRoleLine(ServingStepsPad, 'DISH', StarterStepTok, DishLine);
        AddRoleLine(ServingStepsPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(ServingStepsPad."No.", 'Milk allergy');

        CreatePad(ServingRequestPad);
        AddRoleLine(ServingRequestPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(ServingRequestPad."No.", 'Milk allergy');

        CreatePad(TwoNotesPad);
        AddRoleLine(TwoNotesPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(TwoNotesPad."No.", 'Milk allergy');
        AddNote(TwoNotesPad."No.", 'Birthday');

        CreatePad(DishOnlyPad);
        AddRoleLine(DishOnlyPad, 'DISH', MainCourseStepTok, DishLine);

        CreatePad(TwiceTypedPad);
        AddRoleLine(TwiceTypedPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(TwiceTypedPad."No.", 'Milk allergy');
        AddNote(TwiceTypedPad."No.", 'Milk allergy');

        CreatePad(SplitPad);
        AddRoleLine(SplitPad, 'DISH', MainCourseStepTok, DishLine);
        AddRoleLine(SplitPad, 'BEER', MainCourseStepTok, BeerLine);
        AddNote(SplitPad."No.", 'Milk allergy');
        _LibraryRestaurant.SendWaiterPadToKitchen(SplitPad);
        SplitNewPadNo := SplitToANewBill(SplitPad."No.", BeerLine, 1);
        AddNote(SplitPad."No.", 'Birthday');

        // [WHEN] The header note list of each row's printing pad is read
        CategorySplitPadNotes := PadHeaderNotes(CategorySplitPad."No.");
        NoteAfterDishPadNotes := PadHeaderNotes(NoteAfterDishPad."No.");
        ResentPadNotes := PadHeaderNotes(ResentPad."No.");
        AutoSentPadNotes := PadHeaderNotes(AutoSentPad."No.");
        ServingStepsPadNotes := PadHeaderNotes(ServingStepsPad."No.");
        ServingRequestPadNotes := PadHeaderNotes(ServingRequestPad."No.");
        TwoNotesPadNotes := PadHeaderNotes(TwoNotesPad."No.");
        DishOnlyPadNotes := PadHeaderNotes(DishOnlyPad."No.");
        TwiceTypedPadNotes := PadHeaderNotes(TwiceTypedPad."No.");
        SplitNewPadNotes := PadHeaderNotes(SplitNewPadNo);
        SplitPadNotes := PadHeaderNotes(SplitPad."No.");

        // [THEN] Each header lists the row's notes
        CheckRow('S6.a "Milk allergy", DISH, BEER: the FOOD and the BAR ticket', 'Milk allergy', CategorySplitPadNotes, Mismatches);
        CheckRow('S6.b DISH, "Milk allergy", BEER: the FOOD and the BAR ticket', 'Milk allergy', NoteAfterDishPadNotes, Mismatches);
        CheckRow('S6.c "Birthday" added after DISH was sent: resend all', 'Birthday', ResentPadNotes, Mismatches);
        CheckRow('S6.d "Birthday" added after DISH was sent, then BEER auto-sent', 'Birthday', AutoSentPadNotes, Mismatches);
        CheckRow('S6.e the STARTER and the MAIN ticket', 'Milk allergy', ServingStepsPadNotes, Mismatches);
        CheckRow('S6.f the serving request ticket for MAIN', 'Milk allergy', ServingRequestPadNotes, Mismatches);
        CheckRow('S6.g one ticket, split None', 'Milk allergy, Birthday', TwoNotesPadNotes, Mismatches);
        CheckRow('S6.h DISH only', '', DishOnlyPadNotes, Mismatches);
        CheckRow('S6.i "Milk allergy" typed twice', 'Milk allergy', TwiceTypedPadNotes, Mismatches);
        CheckRow('S6.j resend of pad B after the split, "Birthday" added on pad A', 'Milk allergy', SplitNewPadNotes, Mismatches);
        CheckRow('S6.j pad A', 'Milk allergy, Birthday', SplitPadNotes, Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Rows S6.a, S6.b, S6.c, S6.d, S6.e, S6.f, S6.g, S6.h, S6.i and S6.j: the ticket header lists the order notes of the printing pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketBody_FeatureOn_NoOrderNote()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AttachedCommentPad: Record "NPR NPRE Waiter Pad";
        NoteBeforeDishPad: Record "NPR NPRE Waiter Pad";
        NoteBetweenDishesPad: Record "NPR NPRE Waiter Pad";
        TempAttachedCommentTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempNoteBeforeDishTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempNoteBetweenDishesTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Mismatches: Text;
    begin
        // [SCENARIO] With the feature on the ticket body keeps the dishes and their attached comments and prints no order note, after a dish or before the first dish
        Initialize();

        // [GIVEN] Per row, a pad with the row's lines and its DISH selected for the FOOD ticket
        CreatePad(AttachedCommentPad);
        AddRoleLine(AttachedCommentPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(AttachedCommentPad."No.", 'No onions', DishLine, CommentLine);
        AddNote(AttachedCommentPad."No.", 'Table 6 VIP');
        SelectForTicket(TempAttachedCommentTicket, DishLine, _FoodPrintCategory.Code);

        CreatePad(NoteBeforeDishPad);
        AddNote(NoteBeforeDishPad."No.", 'Milk allergy');
        AddRoleLine(NoteBeforeDishPad, 'DISH', MainCourseStepTok, DishLine);
        SelectForTicket(TempNoteBeforeDishTicket, DishLine, _FoodPrintCategory.Code);

        CreatePad(NoteBetweenDishesPad);
        AddRoleLine(NoteBetweenDishesPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(NoteBetweenDishesPad."No.", 'Table 6 VIP');
        AddRoleLine(NoteBetweenDishesPad, 'BEER', MainCourseStepTok, BeerLine);
        SelectForTicket(TempNoteBetweenDishesTicket, DishLine, _FoodPrintCategory.Code);

        // [WHEN] Each FOOD ticket body is built as the print builds it with the feature on: the grouped print lines without the order notes
        KitchenPrintMgt.GetGroupedPrintLines(TempAttachedCommentTicket);
        OrderNotesMgt.RemoveOrderNotesFromBody(TempAttachedCommentTicket);
        KitchenPrintMgt.GetGroupedPrintLines(TempNoteBeforeDishTicket);
        OrderNotesMgt.RemoveOrderNotesFromBody(TempNoteBeforeDishTicket);
        KitchenPrintMgt.GetGroupedPrintLines(TempNoteBetweenDishesTicket);
        OrderNotesMgt.RemoveOrderNotesFromBody(TempNoteBetweenDishesTicket);

        // [THEN] Each FOOD ticket body holds the row's lines and no order note
        CheckRow('S7.a DISH, "No onions" attached to DISH, "Table 6 VIP"', 'DISH, No onions', TicketLines(TempAttachedCommentTicket), Mismatches);
        CheckRow('S7.b "Milk allergy", DISH', 'DISH', TicketLines(TempNoteBeforeDishTicket), Mismatches);
        CheckRow('S7.c DISH, "Table 6 VIP", BEER', 'DISH', TicketLines(TempNoteBetweenDishesTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S7.a, S7.b and S7.c: with the feature on the FOOD ticket body prints no order note.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketBody_FeatureOn_SystemCommentStaysInBody()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempFoodTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        HeaderNotes: Text;
        Mismatches: Text;
    begin
        // [SCENARIO] With the feature on a comment line without the order-note marker stays in the ticket body after its dish, and only the marked order note is in the header
        Initialize();

        // [GIVEN] A pad with DISH, the Set Sale VAT comment "VAT removed from sale: 2.40" with a blank No., and the order note "Milk allergy", with its DISH selected for the FOOD ticket
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'VAT removed from sale: 2.40', 0, CommentLine);
        AddNote(WaiterPad."No.", 'Milk allergy');
        SelectForTicket(TempFoodTicket, DishLine, _FoodPrintCategory.Code);

        // [WHEN] The FOOD ticket is built as the print builds it with the feature on: the header note list of the pad, and the grouped print lines without the order notes
        HeaderNotes := PadHeaderNotes(WaiterPad."No.");
        KitchenPrintMgt.GetGroupedPrintLines(TempFoodTicket);
        OrderNotesMgt.RemoveOrderNotesFromBody(TempFoodTicket);

        // [THEN] The header lists "Milk allergy" only, and the body holds DISH and the Set Sale VAT comment
        CheckRow('S7.g ticket header', 'Milk allergy', HeaderNotes, Mismatches);
        CheckRow('S7.g FOOD ticket body', 'DISH, VAT removed from sale: 2.40', TicketLines(TempFoodTicket), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'Row S7.g: with the feature on a comment without the marker prints in the body as today, and only the order note is in the header.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketBody_FeatureOff_AsToday()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        NewPadBeerLine: Record "NPR NPRE Waiter Pad Line";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TempBarTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        NewPadNo: Code[20];
    begin
        // [SCENARIO] With the feature off the BAR ticket of the pad that received BEER by a split prints BEER and then the copied order note, which follows the last moved line
        // [GIVEN] Pad A with DISH, "No sauce" and BEER, BEER split to a new pad B, and the BEER line of pad B selected for the BAR ticket
        Initialize();
        CreatePad(SourcePad);
        AddRoleLine(SourcePad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(SourcePad."No.", 'No sauce');
        AddRoleLine(SourcePad, 'BEER', MainCourseStepTok, BeerLine);
        NewPadNo := SplitToANewBill(SourcePad."No.", BeerLine, 1);
        NewPadBeerLine.SetRange("Waiter Pad No.", NewPadNo);
        NewPadBeerLine.SetRange("Line Type", NewPadBeerLine."Line Type"::Item);
        NewPadBeerLine.FindFirst();
        SelectForTicket(TempBarTicket, NewPadBeerLine, _BarPrintCategory.Code);

        // [WHEN] The BAR ticket body is built with the feature off: the grouped print lines as they are
        KitchenPrintMgt.GetGroupedPrintLines(TempBarTicket);

        // [THEN] The BAR ticket body of pad B is BEER and then "No sauce"
        _Assert.AreEqual(
            'BEER, No sauce', TicketLines(TempBarTicket),
            'S7.f: the BAR ticket of pad B should print BEER and then the copy of the order note "No sauce", which follows the last moved line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_FeatureOn_PrintedTicketHasHeaderNotesAndNoBodyNote()
    var
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        AttachedCommentPad: Record "NPR NPRE Waiter Pad";
        CategorySplitPad: Record "NPR NPRE Waiter Pad";
        DishOnlyPad: Record "NPR NPRE Waiter Pad";
        TempAttachedCommentTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempSavedFeature: Record "NPR Feature" temporary;
        TempBarTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempDishOnlyTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempFoodTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        AttachedCommentTicket: Text;
        BarTicket: Text;
        DishOnlyTicket: Text;
        FoodTicket: Text;
        Mismatches: Text;
    begin
        // [SCENARIO] With the feature enabled a printed kitchen ticket lists the order notes of its pad after the number of guests and prints no order note in its body
        Initialize();

        // [GIVEN] The feature enabled, and per row a pad with the row's lines and a dish selected for the row's ticket
        SaveFeature(TempSavedFeature);
        SetHeaderNotesFeature(true);
        CreatePad(CategorySplitPad);
        AddNote(CategorySplitPad."No.", 'Milk allergy');
        AddRoleLine(CategorySplitPad, 'DISH', MainCourseStepTok, DishLine);
        SelectForTicket(TempFoodTicket, DishLine, _FoodPrintCategory.Code);
        AddRoleLine(CategorySplitPad, 'BEER', MainCourseStepTok, BeerLine);
        SelectForTicket(TempBarTicket, BeerLine, _BarPrintCategory.Code);

        CreatePad(DishOnlyPad);
        AddRoleLine(DishOnlyPad, 'DISH', MainCourseStepTok, DishLine);
        SelectForTicket(TempDishOnlyTicket, DishLine, _FoodPrintCategory.Code);

        CreatePad(AttachedCommentPad);
        AddRoleLine(AttachedCommentPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(AttachedCommentPad."No.", 'No onions', DishLine, CommentLine);
        AddNote(AttachedCommentPad."No.", 'Table 6 VIP');
        SelectForTicket(TempAttachedCommentTicket, DishLine, _FoodPrintCategory.Code);

        // [WHEN] Each ticket is printed through the standard kitchen print
        FoodTicket := PrintTicket(TempFoodTicket);
        BarTicket := PrintTicket(TempBarTicket);
        DishOnlyTicket := PrintTicket(TempDishOnlyTicket);
        AttachedCommentTicket := PrintTicket(TempAttachedCommentTicket);
        RestoreFeature(TempSavedFeature);

        // [THEN] Each ticket prints its pad's order notes between the number of guests and the separator, and none in its body
        CheckRow(
            'S6.a FOOD ticket of "Milk allergy", DISH, BEER', 'Number of Guests, --------, Milk allergy, --------, 1 x DISH',
            TicketOutline(FoodTicket), Mismatches);
        CheckRow(
            'S6.a BAR ticket of "Milk allergy", DISH, BEER', 'Number of Guests, --------, Milk allergy, --------, 1 x BEER',
            TicketOutline(BarTicket), Mismatches);
        CheckRow('S6.h FOOD ticket of DISH only', 'Number of Guests, --------, 1 x DISH', TicketOutline(DishOnlyTicket), Mismatches);
        CheckRow(
            'S7.a (S9.c feature enabled) FOOD ticket of DISH, "No onions" attached to DISH, "Table 6 VIP"',
            'Number of Guests, --------, Table 6 VIP, --------, 1 x DISH, No onions', TicketOutline(AttachedCommentTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S6.a, S6.h, S7.a and S9.c: the printed kitchen ticket with the feature enabled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_FeatureOff_PrintedTicketAsToday()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempFoodTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempSavedFeature: Record "NPR Feature" temporary;
        FoodTicket: Text;
    begin
        // [SCENARIO] With the feature disabled a printed kitchen ticket is as today: no note in the header, and the order note after its dish in the body
        Initialize();

        // [GIVEN] The feature disabled, and a pad with DISH, "No onions" attached to DISH and "Table 6 VIP", with its DISH selected for the FOOD ticket
        SaveFeature(TempSavedFeature);
        SetHeaderNotesFeature(false);
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', MainCourseStepTok, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        AddNote(WaiterPad."No.", 'Table 6 VIP');
        SelectForTicket(TempFoodTicket, DishLine, _FoodPrintCategory.Code);

        // [WHEN] The FOOD ticket is printed through the standard kitchen print
        FoodTicket := PrintTicket(TempFoodTicket);
        RestoreFeature(TempSavedFeature);

        // [THEN] The header has no note, and the body prints DISH, "No onions" and "0 x Table 6 VIP"
        _Assert.AreEqual(
            'Number of Guests, --------, 1 x DISH, No onions, 0 x Table 6 VIP', TicketOutline(FoodTicket),
            'S7.d (S9.b feature disabled): the FOOD ticket should print no header note, and DISH, "No onions" and "0 x Table 6 VIP" in its body, as today.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TicketFeature_EnabledDecides()
    var
        Feature: Record "NPR Feature";
        TempSavedFeature: Record "NPR Feature" temporary;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        OrderNotesFeature: Codeunit "NPR NPRE Order Notes Feature";
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        FeatureAbsent: Text;
        FeatureDisabled: Text;
        FeatureDisabledAgain: Text;
        FeatureDisabledOnThePage: Text;
        FeatureEnabled: Text;
        FeatureEnabledOnThePage: Text;
        KdsNotesWithFeatureOff: Text;
        KdsNotesWithFeatureOn: Text;
        Mismatches: Text;
    begin
        // [SCENARIO] The NaviPartner Feature "Order Notes in Kitchen Ticket Header" decides the ticket notes when a ticket is printed: absent or disabled is off, it can be enabled and disabled again at any time, and the KDS lists the notes either way
        Initialize();

        // [GIVEN] A sent pad with DISH and "Milk allergy"
        CreateSentPadWithDishAndNote(WaiterPad, 'Milk allergy');
        SaveFeature(TempSavedFeature);

        // [WHEN] The feature is read with its row absent, disabled, enabled and disabled again, then enabled and disabled as the Feature Management page does; the KDS note list is read with the feature off and on
        if Feature.Get(OrderNotesFeature.GetFeatureId()) then
            Feature.Delete();
        FeatureAbsent := FeatureState(OrderNotesMgt);
        SetHeaderNotesFeature(false);
        FeatureDisabled := FeatureState(OrderNotesMgt);
        KdsNotesWithFeatureOff := OrderNotesOfPad(WaiterPad."No.");
        SetHeaderNotesFeature(true);
        FeatureEnabled := FeatureState(OrderNotesMgt);
        KdsNotesWithFeatureOn := OrderNotesOfPad(WaiterPad."No.");
        SetHeaderNotesFeature(false);
        FeatureDisabledAgain := FeatureState(OrderNotesMgt);
        Feature.Get(OrderNotesFeature.GetFeatureId());
        Feature.Validate(Enabled, true);
        Feature.Modify(true);
        FeatureEnabledOnThePage := FeatureState(OrderNotesMgt);
        Feature.Validate(Enabled, false);
        Feature.Modify(true);
        FeatureDisabledOnThePage := FeatureState(OrderNotesMgt);
        RestoreFeature(TempSavedFeature);

        // [THEN] Only an enabled feature switches the ticket notes on, every change counts at once, and the KDS lists "Milk allergy" with the feature on and off
        CheckRow('S9.a feature row absent', 'off', FeatureAbsent, Mismatches);
        CheckRow('S9.b feature disabled', 'off', FeatureDisabled, Mismatches);
        CheckRow('S9.c feature enabled', 'on', FeatureEnabled, Mismatches);
        CheckRow('S9.d feature disabled again, same session', 'off', FeatureDisabledAgain, Mismatches);
        CheckRow('S9.e feature enabled through the page validation', 'on', FeatureEnabledOnThePage, Mismatches);
        CheckRow('S9.e feature disabled again through the page validation', 'off', FeatureDisabledOnThePage, Mismatches);
        CheckRow('S9.f KDS note list with the feature off', 'Milk allergy', KdsNotesWithFeatureOff, Mismatches);
        CheckRow('S9.f KDS note list with the feature on', 'Milk allergy', KdsNotesWithFeatureOn, Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S9.a to S9.f: the NaviPartner Feature decides the ticket notes and can be enabled and disabled at any time.');
    end;

    local procedure Initialize()
    var
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
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
        _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        _POSUnit.Modify();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.CreatePrintCategory(_FoodPrintCategory);
        _LibraryRestaurant.CreatePrintCategory(_BarPrintCategory);
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

    local procedure CreateSentPadWithDishAndNote(var WaiterPad: Record "NPR NPRE Waiter Pad"; NoteText: Text)
    var
        DishLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', MainCourseStepTok, DishLine);
        AddNote(WaiterPad."No.", NoteText);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure AddRoleLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Description: Text[100]; ServingStep: Code[10]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
    end;

    local procedure AddNote(WaiterPadNo: Code[20]; NoteText: Text)
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.AddWaiterPadOrderNote(WaiterPadNo, NoteText, CommentLine);
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

    local procedure SelectForTicket(var TempTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintCategoryCode: Code[20])
    var
        EntryNo: Integer;
    begin
        // The rows the print route hands to a kitchen print handler for one print category, before the handler builds the ticket lines
        TempTicket.Reset();
        if TempTicket.FindLast() then
            EntryNo := TempTicket."Entry No.";
        TempTicket.Init();
        TempTicket."Entry No." := EntryNo + 1;
        TempTicket."Output Type" := TempTicket."Output Type"::Print;
        TempTicket."Waiter Pad No." := WaiterPadLine."Waiter Pad No.";
        TempTicket."Waiter Pad Line No." := WaiterPadLine."Line No.";
        TempTicket."Print Category Code" := PrintCategoryCode;
        TempTicket."Serving Step" := MainCourseStepTok;
        TempTicket.Insert();
    end;

    local procedure TicketLines(var TempTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary) Lines: Text
    begin
        TempTicket.Reset();
        if TempTicket.FindSet() then
            repeat
                AddToList(Lines, TempTicket.Description);
            until TempTicket.Next() = 0;
    end;

    local procedure PrintTicket(var TempTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        StaticKitchenPrint: Codeunit "NPR NPRE Static Kitchen Print";
    begin
        // The bound handler keeps the job the printer would get instead of sending it
        BindSubscription(RetailPrintHandler);
        StaticKitchenPrint.Print(TempTicket, Codeunit::"NPR NPRE Static Kitchen Print");
        UnbindSubscription(RetailPrintHandler);
        exit(Base64Convert.FromBase64(RetailPrintHandler.GetPrintJobBase64()));
    end;

    local procedure TicketOutline(PrintJob: Text) Outline: Text
    var
        TypeHelper: Codeunit "Type Helper";
        Roles: List of [Text];
        PrintedLine: Text;
        Role: Text;
    begin
        // Each printed line reduced to what the rows check: the guests line, the separator, and the role texts with their quantity column
        Roles.AddRange('DISH', 'BEER', 'No onions', 'Milk allergy', 'Table 6 VIP');
        foreach PrintedLine in PrintJob.Split(TypeHelper.LFSeparator()) do begin
            if PrintedLine.Contains(NumberOfGuestsTok) then
                AddToList(Outline, NumberOfGuestsTok);
            if PrintedLine.Contains(SeparatorTok) then
                AddToList(Outline, SeparatorTok);
            foreach Role in Roles do
                if PrintedLine.Contains(Role) then
                    AddToList(Outline, QuantityColumn(PrintedLine) + Role);
        end;
    end;

    local procedure QuantityColumn(PrintedLine: Text): Text
    begin
        if PrintedLine.Contains(CommentQuantityTok) then
            exit(CommentQuantityTok);
        if PrintedLine.Contains(ItemQuantityTok) then
            exit(ItemQuantityTok);
        exit('');
    end;

    local procedure SetHeaderNotesFeature(Enabled: Boolean)
    var
        Feature: Record "NPR Feature";
        OrderNotesFeature: Codeunit "NPR NPRE Order Notes Feature";
    begin
        if not Feature.Get(OrderNotesFeature.GetFeatureId()) then
            OrderNotesFeature.AddFeature();
        OrderNotesFeature.SetFeatureEnabled(Enabled);
    end;

    local procedure SaveFeature(var TempSavedFeature: Record "NPR Feature" temporary)
    var
        Feature: Record "NPR Feature";
        OrderNotesFeature: Codeunit "NPR NPRE Order Notes Feature";
    begin
        TempSavedFeature.Reset();
        TempSavedFeature.DeleteAll();
        if not Feature.Get(OrderNotesFeature.GetFeatureId()) then
            exit;
        TempSavedFeature := Feature;
        TempSavedFeature.Insert();
    end;

    local procedure RestoreFeature(var TempSavedFeature: Record "NPR Feature" temporary)
    var
        Feature: Record "NPR Feature";
        OrderNotesFeature: Codeunit "NPR NPRE Order Notes Feature";
    begin
        if Feature.Get(OrderNotesFeature.GetFeatureId()) then
            Feature.Delete();
        if not TempSavedFeature.FindFirst() then
            exit;
        Feature := TempSavedFeature;
        Feature.Insert();
    end;

    local procedure FeatureState(var OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt."): Text
    begin
        if OrderNotesMgt.HeaderNotesEnabled() then
            exit('on');
        exit('off');
    end;

    local procedure PadHeaderNotes(WaiterPadNo: Code[20]): Text
    var
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        OrderNotesMgt.GetWaiterPadNotes(WaiterPadNo, Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure OrderNotesOfPad(WaiterPadNo: Code[20]): Text
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        OrderNotesMgt: Codeunit "NPR NPRE Order Notes Mgt.";
        Notes: List of [Text];
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindFirst(), StrSubstNo(NoKitchenRequestErr, WaiterPadNo));
        OrderNotesMgt.GetOrderNotes(KitchenRequest."Order ID", Notes);
        exit(JoinNotes(Notes));
    end;

    local procedure JoinNotes(Notes: List of [Text]) Joined: Text
    var
        Note: Text;
    begin
        foreach Note in Notes do
            AddToList(Joined, Note);
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
}
