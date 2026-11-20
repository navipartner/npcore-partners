codeunit 85557 "NPR NPRE Kitchen Ticket Tests"
{
    // [FEATURE] Kitchen Order ticket lines: the comments that print with a printed line, grouped by attachment
    Subtype = Test;

    var
        _BarPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        _DrinkPrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';
        NotPrintedTxt: Label '"%1" should be printed on the %2.', Locked = true, Comment = '%1 = printed text, %2 = print';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_CommentsAttachedToAPrintedLine_PrintRightAfterIt()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        BeerLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SecondDishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempBarTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] A printed line takes its attached comments along, an ordinary comment after it follows its group, and a comment of a line on another ticket stays off this one
        Initialize();

        // [GIVEN] Per row, a pad with the row's lines and the lines of each ticket selected for printing
        // [WHEN] The ticket lines are built
        // [THEN] Each ticket has the row's lines in the row's order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.a DRINK', 'DISH, No onions', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.e DRINK', 'DISH, No onions, Table 6 VIP', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'DISH', 0, SecondDishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, SecondDishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.e2 DRINK', 'DISH, ADDON-K, Table 6 VIP, DISH', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'BEER', 0, BeerLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'no ice', BeerLine, CommentLine);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempBarTicket, BeerLine, _BarPrintCategory.Code);
        CheckRow('S14.g DRINK', 'DISH', TicketLines(TempDrinkTicket), Mismatches);
        CheckRow('S14.g BAR', 'BEER, no ice', TicketLines(TempBarTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14.a, S14.e, S14.e2 and S14.g: the lines of the DRINK and BAR tickets.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_AttachedLinesThatDoOrDoNotPrint_OnlyCommentsOfPrintedLinesPrint()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] A comment prints when the line it is attached to prints on the ticket, wherever it is on the pad; an add-on that does not print still stops the search for ordinary comments
        Initialize();

        // [GIVEN] Per row, a pad with DISH and the row's attached lines, where DISH and ADDON-K print on DRINK and ADDON-M does not print
        // [WHEN] The DRINK ticket lines are built
        // [THEN] The DRINK ticket has the row's lines in the row's order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-M', DishLine."Line No.", AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.b DRINK', 'DISH, No onions', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        AddRoleLine(WaiterPad, 'ADDON-M', DishLine."Line No.", AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.c DRINK', 'DISH, ADDON-K, well done', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-M', DishLine."Line No.", AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'extra hot', AddOnMLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.d DRINK', 'DISH', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-M', DishLine."Line No.", AddOnMLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.f DRINK', 'DISH', TicketLines(TempDrinkTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14.b, S14.c, S14.d and S14.f: the lines of the DRINK ticket.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_AttachedLinesAnywhereOnThePad_GroupedUnderTheirPrintedParent()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SecondDishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] The ticket groups by attachment: a printed line, then its printed attached lines each with its own comments, then its own comments
        Initialize();

        // [GIVEN] Per row, a pad whose attached lines are placed as in the row, and the DRINK lines selected for printing
        // [WHEN] The DRINK ticket lines are built
        // [THEN] The DRINK ticket has the row's lines in the grouped order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.h DRINK', 'DISH, ADDON-K, well done, No onions', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'second DISH', 0, SecondDishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, SecondDishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.i DRINK', 'DISH, ADDON-K, second DISH', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.j DRINK', 'ADDON-K, well done', TicketLines(TempDrinkTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14.h, S14.i and S14.j: the DRINK ticket groups the lines by attachment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_SelectedLinesAttachedInACycleOrToThemselves_EachPrintsOnceInLineOrder()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] Selected lines whose attachments form a cycle, or a line attached to itself, still print, each once and in line order
        Initialize();

        // [GIVEN] Per row, a pad whose selected DRINK lines are attached to each other or to themselves, data that no writer produces
        // [WHEN] The DRINK ticket lines are built
        // [THEN] The DRINK ticket has the row's lines in line order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        DishLine."Attached to Line No." := AddOnKLine."Line No.";
        DishLine.Modify();
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14-cycle DRINK', 'DISH, ADDON-K', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        DishLine."Attached to Line No." := DishLine."Line No.";
        DishLine.Modify();
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        CheckRow('S14-self-attached DRINK', 'DISH', TicketLines(TempDrinkTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14-cycle and S14-self-attached: selected DRINK lines with a corrupt attachment still print, each once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_OrdinaryCommentAfterAnAddOnOfAPrintedDish_PrintsAfterTheWholeGroupOfTheDish()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] An ordinary comment that follows a line of a dish's group prints after the whole group of the dish, so after the dish's own comments
        Initialize();

        // [GIVEN] Per row, a pad with DISH, ADDON-K attached to DISH and the row's comments in the row's order, where DISH and ADDON-K print on DRINK
        // [WHEN] The DRINK ticket lines are built
        // [THEN] The DRINK ticket has the row's lines in the row's order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.k DRINK', 'DISH, ADDON-K, No onions, Table 6 VIP', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.l DRINK', 'DISH, ADDON-K, well done, No onions, Table 6 VIP', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'allergy', 0, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', DishLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'birthday', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        CheckRow('S14.m DRINK', 'DISH, ADDON-K, No onions, allergy, birthday', TicketLines(TempDrinkTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14.k, S14.l and S14.m: an ordinary comment after a line of the DISH group prints after the whole group of DISH.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_OrdinaryCommentBetweenTwoPrintedDishes_PrintsAfterTheGroupOfTheFirstDish()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        SecondDishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Mismatches: Text;
    begin
        // [SCENARIO] An ordinary comment between two dishes prints after the group of the first dish and before the second dish, as today
        Initialize();

        // [GIVEN] Per row, a pad with DISH, the row's add-on of DISH, the ordinary "Table 6 VIP" and DISH2, where the item lines print on DRINK
        // [WHEN] The DRINK ticket lines are built
        // [THEN] The DRINK ticket has the row's lines in the row's order
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        AddRoleLine(WaiterPad, 'DISH2', 0, SecondDishLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, SecondDishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.n DRINK', 'DISH, Table 6 VIP, DISH2', TicketLines(TempDrinkTicket), Mismatches);

        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        AddRoleLine(WaiterPad, 'DISH2', 0, SecondDishLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, SecondDishLine, _DrinkPrintCategory.Code);
        CheckRow('S14.o DRINK', 'DISH, ADDON-K, Table 6 VIP, DISH2', TicketLines(TempDrinkTicket), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S14.n and S14.o: an ordinary comment between DISH and DISH2 prints after the group of DISH, before DISH2.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicket_OrdinaryCommentAfterSelectedLinesAttachedInACycle_PrintsAfterThoseLines()
    var
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        DishLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Lines: Text;
    begin
        // [SCENARIO] An ordinary comment that follows selected lines attached to each other in a cycle prints after those lines, not before them
        Initialize();

        // [GIVEN] A pad with DISH attached to ADDON-K and ADDON-K attached to DISH, data that no writer produces, then the ordinary "Table 6 VIP"; DISH and ADDON-K print on DRINK
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'DISH', 0, DishLine);
        AddRoleLine(WaiterPad, 'ADDON-K', DishLine."Line No.", AddOnKLine);
        DishLine."Attached to Line No." := AddOnKLine."Line No.";
        DishLine.Modify();
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentLine);
        SelectForTicket(TempDrinkTicket, DishLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, AddOnKLine, _DrinkPrintCategory.Code);

        // [WHEN] The DRINK ticket lines are built
        Lines := TicketLines(TempDrinkTicket);

        // [THEN] DISH and ADDON-K print once each in line order, and "Table 6 VIP" prints last
        _Assert.AreEqual(
            'DISH, ADDON-K, Table 6 VIP', Lines,
            'S14.p: the DRINK ticket should print DISH and ADDON-K once each, then "Table 6 VIP" last, not before the lines of the cycle.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenTicketAndPreReceipt_CommentsOnADishAndOnItsAddOn_AddOnCommentIndentedOneLevelDeeper()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        SaladLine: Record "NPR NPRE Waiter Pad Line";
        SteakLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempDrinkTicket: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        TempPreReceipt: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        StaticKitchenPrint: Codeunit "NPR NPRE Static Kitchen Print";
        KitchenPrintHandler: Codeunit "NPR Retail Print Handler";
        PreReceiptPrintHandler: Codeunit "NPR Retail Print Handler";
        Mismatches: Text;
    begin
        // [SCENARIO] On the kitchen ticket and the pre-receipt, a comment on an add-on prints two spaces deeper than a comment on its dish, which lines up with the add-on
        Initialize();

        // [GIVEN] The user's POS unit in User Setup, and a pad with Steak, Salad as an add-on of Steak, "no dressing" attached to Salad and "No onions" attached to Steak, where Steak and Salad print on DRINK
        AssignUserToPOSUnit();
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'Steak', 0, SteakLine);
        AddRoleLine(WaiterPad, 'Salad', SteakLine."Line No.", SaladLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'no dressing', SaladLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', SteakLine, CommentLine);
        SelectForTicket(TempDrinkTicket, SteakLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempDrinkTicket, SaladLine, _DrinkPrintCategory.Code);
        SelectForTicket(TempPreReceipt, SteakLine, '');

        // [WHEN] The DRINK kitchen ticket and the pre-receipt of the pad are printed
        BindSubscription(KitchenPrintHandler);
        StaticKitchenPrint.Print(TempDrinkTicket, Codeunit::"NPR NPRE Static Kitchen Print");
        UnbindSubscription(KitchenPrintHandler);
        BindSubscription(PreReceiptPrintHandler);
        Codeunit.Run(Codeunit::"NPR NPRE Static Pre Receipt", TempPreReceipt);
        UnbindSubscription(PreReceiptPrintHandler);

        // [THEN] On each print, "no dressing" has two more spaces in front of it than "No onions", and "No onions" as many as "Salad"
        CheckAttachedLineIndents('kitchen ticket', KitchenPrintHandler.GetPrintJobBase64(), Mismatches);
        CheckAttachedLineIndents('pre-receipt', PreReceiptPrintHandler.GetPrintJobBase64(), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'On the kitchen ticket and the pre-receipt, "no dressing" should print two spaces deeper than "No onions", and "No onions" in line with Salad, so it does not read as a note on Salad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreReceipt_CommentLines_TextOnlyInTheDescriptionColumn()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        NoteLine: Record "NPR NPRE Waiter Pad Line";
        SteakLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempPreReceipt: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        Base64Convert: Codeunit "Base64 Convert";
        PreReceiptPrintHandler: Codeunit "NPR Retail Print Handler";
        PrintJob: Text;
        Mismatches: Text;
    begin
        // [SCENARIO] On the pre-receipt a comment line prints only its text, in the description column of the item rows: no quantity and no amount
        Initialize();

        // [GIVEN] A pad with Steak, "No onions" attached to Steak, and the order note "Milk allergy"
        AssignUserToPOSUnit();
        CreatePad(WaiterPad);
        AddRoleLine(WaiterPad, 'Steak', 0, SteakLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', SteakLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadOrderNote(WaiterPad."No.", 'Milk allergy', NoteLine);
        SelectForTicket(TempPreReceipt, SteakLine, '');

        // [WHEN] The pre-receipt of the pad is printed
        BindSubscription(PreReceiptPrintHandler);
        Codeunit.Run(Codeunit::"NPR NPRE Static Pre Receipt", TempPreReceipt);
        UnbindSubscription(PreReceiptPrintHandler);
        PrintJob := Base64Convert.FromBase64(PreReceiptPrintHandler.GetPrintJobBase64());

        // [THEN] Both comments fill a field as wide as the Steak description, and their rows carry no " x " and no amount
        CheckRow('"Milk allergy" field width', Format(FieldWidth(PrintJob, 'Steak')), Format(FieldWidth(PrintJob, 'Milk allergy')), Mismatches);
        CheckRow('"No onions" field width', Format(FieldWidth(PrintJob, 'Steak')), Format(FieldWidth(PrintJob, 'No onions')), Mismatches);
        CheckRow('"Milk allergy" row has a quantity or an amount', Format(false), Format(HasQuantityOrAmount(PrintedRow(PrintJob, 'Milk allergy'))), Mismatches);
        CheckRow('"No onions" row has a quantity or an amount', Format(false), Format(HasQuantityOrAmount(PrintedRow(PrintJob, 'No onions'))), Mismatches);
        _Assert.AreEqual(
            '', Mismatches,
            'On the pre-receipt, "Milk allergy" and "No onions" should print only their text, in a field as wide as the Steak description, with no quantity and no amount.');
    end;

    local procedure Initialize()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if _RestaurantInitialized then
            exit;

        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        _LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.CreatePrintCategory(_DrinkPrintCategory);
        _LibraryRestaurant.CreatePrintCategory(_BarPrintCategory);
        _RestaurantInitialized := true;
        Commit();
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure AddRoleLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Description: Text[100]; AttachedToLineNo: Integer; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item.Description := Description;
        Item.Modify();
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, AttachedToLineNo, WaiterPadLine);
    end;

    local procedure AssignUserToPOSUnit()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
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
    var
        KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
    begin
        KitchenPrintMgt.GetGroupedPrintLines(TempTicket);
        TempTicket.Reset();
        if TempTicket.FindSet() then
            repeat
                if Lines <> '' then
                    Lines += ', ';
                Lines += TempTicket.Description;
            until TempTicket.Next() = 0;
        TempTicket.DeleteAll();
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;

    local procedure CheckAttachedLineIndents(PrintName: Text; PrintJobBase64: Text; var Mismatches: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        PrintJob: Text;
        AddOnCommentIndent: Integer;
        AddOnIndent: Integer;
        DishCommentIndent: Integer;
    begin
        PrintJob := Base64Convert.FromBase64(PrintJobBase64);
        AddOnIndent := SpacesBefore(PrintJob, 'Salad', PrintName);
        AddOnCommentIndent := SpacesBefore(PrintJob, 'no dressing', PrintName);
        DishCommentIndent := SpacesBefore(PrintJob, 'No onions', PrintName);
        CheckRow(PrintName + ', spaces before "no dressing"', Format(DishCommentIndent + 2), Format(AddOnCommentIndent), Mismatches);
        CheckRow(PrintName + ', spaces before "No onions"', Format(AddOnIndent), Format(DishCommentIndent), Mismatches);
    end;

    local procedure FieldWidth(PrintJob: Text; FieldText: Text) Width: Integer
    var
        Position: Integer;
        EndPosition: Integer;
    begin
        // A left-aligned field is its text padded with spaces to the column width, so its width runs from its own leading spaces to its last trailing space
        Position := StrPos(PrintJob, FieldText);
        _Assert.AreNotEqual(0, Position, StrSubstNo(NotPrintedTxt, FieldText, 'pre-receipt'));
        EndPosition := Position + StrLen(FieldText);
        while (EndPosition <= StrLen(PrintJob)) and (PrintJob[EndPosition] = ' ') do
            EndPosition += 1;
        Width := SpacesBefore(PrintJob, FieldText, 'pre-receipt') + EndPosition - Position;
    end;

    local procedure PrintedRow(PrintJob: Text; FieldText: Text) Row: Text
    var
        TypeHelper: Codeunit "Type Helper";
        PrintedLine: Text;
    begin
        foreach PrintedLine in PrintJob.Split(TypeHelper.LFSeparator()) do
            if PrintedLine.Contains(FieldText) then
                exit(PrintedLine);
    end;

    local procedure HasQuantityOrAmount(Row: Text): Boolean
    begin
        exit(Row.Contains(' x ') or Row.Contains('0.00') or Row.Contains('0,00'));
    end;

    local procedure SpacesBefore(PrintJob: Text; FieldText: Text; PrintName: Text) Spaces: Integer
    var
        Position: Integer;
    begin
        // Each field of the job starts with printer control codes, so the spaces right before a text are the ones its own field begins with
        Position := StrPos(PrintJob, FieldText);
        _Assert.AreNotEqual(0, Position, StrSubstNo(NotPrintedTxt, FieldText, PrintName));
        while (Position - Spaces > 1) and (PrintJob[Position - Spaces - 1] = ' ') do
            Spaces += 1;
    end;
}
