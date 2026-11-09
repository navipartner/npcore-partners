codeunit 85602 "NPR NPRE Print Lines Tests"
{
    Subtype = Test;

    var
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Seating: Record "NPR NPRE Seating";
        _Assert: Codeunit Assert;
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _LibraryUtility: Codeunit "Library - Utility";
        _KitchenPrintMgt: Codeunit "NPR NPRE Kitchen Print Mgt";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_PlainDishRepeated_MergedWithSummedQuantity()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'PIZZA', 'Pizza Napoli', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'COLA', 'Cola', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 30000, 0, 'PIZZA', 'Pizza Napoli', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, TempWPadLineOutBuffer.Count(), 'The two plain pizza lines should be merged into one.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(2, TempWPadLineOutBuffer.Quantity, 'The merged pizza line should carry the total quantity.');
        FindPrintLine(TempWPadLineOutBuffer, 20000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The cola line should be untouched.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_PlainDishClickedManyTimes_CollapsedToOneLine()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        LineNo: Integer;
    begin
        // The core pain: clicking the same button five times yields five lines.
        for LineNo := 1 to 5 do
            AddItemPrintLine(TempWPadLineOutBuffer, LineNo * 10000, 0, 'COLA', 'Coca Cola', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, TempWPadLineOutBuffer.Count(), 'Five identical plain lines should collapse to one.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(5, TempWPadLineOutBuffer.Quantity, 'The single line should carry the total quantity.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_DishWithAddOn_NeverMergedEvenIfIdentical()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'PIZZA', 'Pizza Napoli', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 10001, 10000, 'CHEESE', 'Extra cheese', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'PIZZA', 'Pizza Napoli', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20001, 20000, 'CHEESE', 'Extra cheese', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(4, TempWPadLineOutBuffer.Count(), 'Dishes carrying an add-on keep their own line so the add-on quantity is never ambiguous.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The first pizza keeps its own quantity.');
        FindPrintLine(TempWPadLineOutBuffer, 20000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The second pizza keeps its own quantity.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_DishesWithDifferentAddOns_KeptApart()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'PIZZA', 'Pizza Napoli', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 10001, 10000, 'CHEESE', 'Extra cheese', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'PIZZA', 'Pizza Napoli', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20001, 20000, 'OLIVES', 'Olives', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(4, TempWPadLineOutBuffer.Count(), 'Pizzas with different add-ons must stay separate lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_PlainAndCustomisedSameItem_OnlyPlainMerged()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 30000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 30001, 30000, 'CHEESE', 'Extra cheese', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(3, TempWPadLineOutBuffer.Count(), 'The two plain burgers merge; the burger with cheese stays on its own line.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(2, TempWPadLineOutBuffer.Quantity, 'The plain burgers should be bulked to quantity two.');
        FindPrintLine(TempWPadLineOutBuffer, 30000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The customised burger keeps quantity one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_DishWithComment_NotMergedWithPlain()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'STEAK', 'Steak', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'STEAK', 'Steak', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 30000, 0, 'STEAK', 'Steak', 1);
        AddCommentPrintLine(TempWPadLineOutBuffer, 30001, 'Well done');

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(3, TempWPadLineOutBuffer.Count(), 'The two plain steaks merge; the steak with a comment stays separate with its comment.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(2, TempWPadLineOutBuffer.Quantity, 'The plain steaks should be bulked to quantity two.');
        FindPrintLine(TempWPadLineOutBuffer, 30000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The commented steak keeps quantity one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_CustomisedDish_AddOnQuantityUnchanged()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 10001, 10000, 'CHEESE', 'Extra cheese', 2);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, TempWPadLineOutBuffer.Count(), 'A single customised dish is left untouched.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The burger quantity is unchanged.');
        FindPrintLine(TempWPadLineOutBuffer, 10001);
        _Assert.AreEqual(2, TempWPadLineOutBuffer.Quantity, 'The add-on quantity is shown as entered for this one dish, not summed or divided.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_AddOnsAfterAllMainLines_OnlyPlainMerged()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        // Split bill leaves the pad with every main line first and the add-on lines appended at the end, so an add-on is
        // not directly below its dish. Add-on ownership must be read from "Attached to Line No.", not from adjacency.
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 30000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 40000, 0, 'BURGER', 'Burger', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 10001, 10000, 'CHEESE', 'Extra cheese', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20001, 20000, 'CHEESE', 'Extra cheese', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(5, TempWPadLineOutBuffer.Count(), 'Only the two plain burgers merge; the two customised burgers and their add-ons stay.');
        FindPrintLine(TempWPadLineOutBuffer, 30000);
        _Assert.AreEqual(2, TempWPadLineOutBuffer.Quantity, 'The two plain burgers should be bulked to quantity two.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'A customised burger must not be bulked just because its add-on is listed later.');
        FindPrintLine(TempWPadLineOutBuffer, 20000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The other customised burger is likewise untouched.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_CancelledLineKeptSeparate()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        // A line removed after it was sent is kept at quantity zero and re-buffered on the next send alongside a freshly rung
        // line of the same item. The zero-quantity cancellation must stay on its own line, not be netted off by bulking.
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'COLA', 'Cola', 0);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'COLA', 'Cola', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, TempWPadLineOutBuffer.Count(), 'The cancelled zero-quantity line must stay separate from the new line of the same item.');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        _Assert.AreEqual(0, TempWPadLineOutBuffer.Quantity, 'The cancellation keeps its zero quantity.');
        FindPrintLine(TempWPadLineOutBuffer, 20000);
        _Assert.AreEqual(1, TempWPadLineOutBuffer.Quantity, 'The newly ordered cola keeps quantity one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_SameItemDifferentVariant_NotMerged()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        // Same item, different variant (e.g. a size) is a different dish to the kitchen, so the variant is part of the merge key.
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'COLA', 'Cola', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'COLA', 'Cola', 1);
        FindPrintLine(TempWPadLineOutBuffer, 20000);
        TempWPadLineOutBuffer."Variant Code" := 'LARGE';
        TempWPadLineOutBuffer.Modify();

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, TempWPadLineOutBuffer.Count(), 'Two variants of the same item must stay on separate lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeIdenticalLines_SameItemDifferentDescription_NotMerged()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
    begin
        // Same item number but a different printed description (e.g. an edited line) reads differently, so the description is
        // part of the merge key.
        AddItemPrintLine(TempWPadLineOutBuffer, 10000, 0, 'COFFEE', 'Coffee', 1);
        AddItemPrintLine(TempWPadLineOutBuffer, 20000, 0, 'COFFEE', 'Coffee decaf', 1);

        _KitchenPrintMgt.MergeIdenticalLines(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, TempWPadLineOutBuffer.Count(), 'The same item with a different description must not be bulked.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLatestKDSOrderIDsFromSendLog_EachOrderListedOnce()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        WaiterPadNo: Code[20];
        KitchenOrderIDs: List of [BigInteger];
    begin
        WaiterPadNo := RandomWaiterPadNo();
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 10000, '');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 20000, '');
        InsertSendLogEntry(WaiterPadNo, 10000, false, 0);
        InsertSendLogEntry(WaiterPadNo, 10000, true, 151);
        InsertSendLogEntry(WaiterPadNo, 20000, true, 151);

        KitchenOrderIDs := _KitchenPrintMgt.GetLatestKDSOrderIDsFromSendLog(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenOrderIDs.Count(), 'An order shared by both lines should be listed once.');
        _Assert.AreEqual('151', Format(KitchenOrderIDs.Get(1)), 'The kitchen order the lines were sent to should be listed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLatestKDSOrderIDsFromSendLog_NothingSentToKDS_Empty()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        WaiterPadNo: Code[20];
        KitchenOrderIDs: List of [BigInteger];
    begin
        WaiterPadNo := RandomWaiterPadNo();
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 10000, '');
        InsertSendLogEntry(WaiterPadNo, 10000, false, 0);

        KitchenOrderIDs := _KitchenPrintMgt.GetLatestKDSOrderIDsFromSendLog(TempWPadLineOutBuffer);

        _Assert.AreEqual(0, KitchenOrderIDs.Count(), 'Without KDS there is no kitchen order to print.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLatestKDSOrderIDsFromSendLog_SameLineRelogged_Latest()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        WaiterPadNo: Code[20];
        KitchenOrderIDs: List of [BigInteger];
    begin
        // A line sent twice (e.g. its quantity was increased) has two KDS log entries; the ticket must show the newest order.
        WaiterPadNo := RandomWaiterPadNo();
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 10000, '');
        InsertSendLogEntry(WaiterPadNo, 10000, true, 151);
        InsertSendLogEntry(WaiterPadNo, 10000, true, 152);

        KitchenOrderIDs := _KitchenPrintMgt.GetLatestKDSOrderIDsFromSendLog(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenOrderIDs.Count(), 'One line belongs to one current kitchen order.');
        _Assert.AreEqual('152', Format(KitchenOrderIDs.Get(1)), 'The most recent kitchen order the line was sent to should be shown, not the first.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLatestKDSOrderIDsFromSendLog_TwoLinesTwoOrders_Both()
    var
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        WaiterPadNo: Code[20];
        KitchenOrderIDs: List of [BigInteger];
    begin
        WaiterPadNo := RandomWaiterPadNo();
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 10000, '');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPadNo, 20000, '');
        InsertSendLogEntry(WaiterPadNo, 10000, true, 151);
        InsertSendLogEntry(WaiterPadNo, 20000, true, 152);

        KitchenOrderIDs := _KitchenPrintMgt.GetLatestKDSOrderIDsFromSendLog(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, KitchenOrderIDs.Count(), 'Lines sent to two different kitchen orders should both be listed.');
        _Assert.AreEqual('151', Format(KitchenOrderIDs.Get(1)), 'The first line''s kitchen order should be listed.');
        _Assert.AreEqual('152', Format(KitchenOrderIDs.Get(2)), 'The second line''s kitchen order should be listed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_LineRoutedToStation_StationListed()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        InsertKitchenRequestForLine(WaiterPad."No.", 10000, 'GRILL', 'Grill');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenStationDescriptions.Count(), 'The station the line was routed to on the kitchen request should be listed.');
        _Assert.AreEqual('Grill', KitchenStationDescriptions.Get(1), 'The station should be listed by its description.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_LineHasNoKitchenRequest_Empty()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(0, KitchenStationDescriptions.Count(), 'A line never sent to the kitchen display has no station to print (e.g. a print-only restaurant).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_TwoLinesSameStation_ListedOnce()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        InsertKitchenRequestForLine(WaiterPad."No.", 10000, 'GRILL', 'Grill');
        InsertKitchenRequestForLine(WaiterPad."No.", 20000, 'GRILL', 'Grill');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 20000, '');

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenStationDescriptions.Count(), 'Two lines routed to the same station list it once.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_TwoStationsOnOneRequest_BothListed()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        InsertKitchenRequestWithTwoStations(WaiterPad."No.", 10000, 'GRILL', 'Grill', 'FRYER', 'Fryer');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(2, KitchenStationDescriptions.Count(), 'A request routed to two stations lists both.');
        _Assert.IsTrue(KitchenStationDescriptions.Contains('Grill'), 'The first station should be listed.');
        _Assert.IsTrue(KitchenStationDescriptions.Contains('Fryer'), 'The second station should be listed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_BlankStationDescription_FallsBackToCode()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        InsertKitchenRequestForLine(WaiterPad."No.", 10000, 'PASS', '');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenStationDescriptions.Count(), 'The station should still be listed when it has no description.');
        _Assert.AreEqual('PASS', KitchenStationDescriptions.Get(1), 'A station with a blank description falls back to its code.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetKitchenStationDescriptions_JobSplitByStep_OnlyThatStepsStation()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary;
        KitchenStationDescriptions: List of [Text];
    begin
        // One line routed to two serving steps has one kitchen request per step. A ticket split by step must show only its
        // own step's station, not the later course's.
        Initialize();
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        InsertKitchenRequestForLineInStep(WaiterPad."No.", 10000, 'GRILL', 'Grill', 'STARTER');
        InsertKitchenRequestForLineInStep(WaiterPad."No.", 10000, 'FRYER', 'Fryer', 'MAIN');
        AddDispatchedLine(TempWPadLineOutBuffer, WaiterPad."No.", 10000, '');
        FindPrintLine(TempWPadLineOutBuffer, 10000);
        TempWPadLineOutBuffer."Serving Step" := 'STARTER';
        TempWPadLineOutBuffer.Modify();

        KitchenStationDescriptions := _KitchenPrintMgt.GetKitchenStationDescriptions(TempWPadLineOutBuffer);

        _Assert.AreEqual(1, KitchenStationDescriptions.Count(), 'A step-split ticket lists only its own step''s station.');
        _Assert.AreEqual('Grill', KitchenStationDescriptions.Get(1), 'The starter ticket shows the starter station, not the main course station.');
    end;

    local procedure Initialize()
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        KitchenStationSelection.DeleteAll();
        if _Initialized then
            exit;

        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateMealFlowStatuses();
        _LibraryRestaurant.CreateSeatingFlowStatuses();
        _LibraryRestaurant.CreateWaiterPadFlowStatuses();
        _LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        _LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.CreateSeating(_Seating, _SeatingLocation.Code);
        _Initialized := true;
    end;

    local procedure AddDispatchedLine(var TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; PrintCategoryCode: Code[20])
    begin
        TempWPadLineOutBuffer.Init();
        TempWPadLineOutBuffer."Entry No." := TempWPadLineOutBuffer.Count() + 1;
        TempWPadLineOutBuffer."Waiter Pad No." := WaiterPadNo;
        TempWPadLineOutBuffer."Waiter Pad Line No." := WaiterPadLineNo;
        TempWPadLineOutBuffer."Print Category Code" := PrintCategoryCode;
        TempWPadLineOutBuffer.Insert();
    end;

    local procedure AddItemPrintLine(var TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; WaiterPadLineNo: Integer; AttachedToLineNo: Integer; ItemNo: Code[20]; Description: Text[100]; Quantity: Decimal)
    begin
        TempWPadLineOutBuffer.Init();
        TempWPadLineOutBuffer."Entry No." := TempWPadLineOutBuffer.Count() + 1;
        TempWPadLineOutBuffer."Waiter Pad No." := 'PAD';
        TempWPadLineOutBuffer."Waiter Pad Line No." := WaiterPadLineNo;
        TempWPadLineOutBuffer."Attached to Line No." := AttachedToLineNo;
        TempWPadLineOutBuffer."Line Type" := TempWPadLineOutBuffer."Line Type"::Item;
        TempWPadLineOutBuffer."No." := ItemNo;
        TempWPadLineOutBuffer.Description := Description;
        TempWPadLineOutBuffer.Quantity := Quantity;
        TempWPadLineOutBuffer.Insert();
    end;

    local procedure AddCommentPrintLine(var TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; WaiterPadLineNo: Integer; Comment: Text[100])
    begin
        TempWPadLineOutBuffer.Init();
        TempWPadLineOutBuffer."Entry No." := TempWPadLineOutBuffer.Count() + 1;
        TempWPadLineOutBuffer."Waiter Pad No." := 'PAD';
        TempWPadLineOutBuffer."Waiter Pad Line No." := WaiterPadLineNo;
        TempWPadLineOutBuffer."Line Type" := TempWPadLineOutBuffer."Line Type"::Comment;
        TempWPadLineOutBuffer.Description := Comment;
        TempWPadLineOutBuffer.Insert();
    end;

    local procedure FindPrintLine(var TempWPadLineOutBuffer: Record "NPR NPRE W.Pad.Line Out.Buffer" temporary; WaiterPadLineNo: Integer)
    begin
        TempWPadLineOutBuffer.Reset();
        TempWPadLineOutBuffer.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
        _Assert.IsTrue(TempWPadLineOutBuffer.FindFirst(), StrSubstNo('Waiter pad line %1 should be among the print lines.', WaiterPadLineNo));
        TempWPadLineOutBuffer.Reset();
    end;

    local procedure InsertSendLogEntry(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; SentToKDS: Boolean; KitchenOrderID: BigInteger)
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        WPadLinePrintLogEntry.Init();
        WPadLinePrintLogEntry."Waiter Pad No." := WaiterPadNo;
        WPadLinePrintLogEntry."Waiter Pad Line No." := WaiterPadLineNo;
        WPadLinePrintLogEntry."Print Type" := WPadLinePrintLogEntry."Print Type"::"Kitchen Order";
        if SentToKDS then
            WPadLinePrintLogEntry."Output Type" := WPadLinePrintLogEntry."Output Type"::KDS;
        WPadLinePrintLogEntry."Kitchen Order ID" := KitchenOrderID;
        WPadLinePrintLogEntry."Sent Date-Time" := CurrentDateTime();
        WPadLinePrintLogEntry.Insert();
    end;

    local procedure InsertKitchenRequestForLine(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; StationCode: Code[20]; StationDescription: Text[50])
    begin
        InsertKitchenRequestForLineInStep(WaiterPadNo, WaiterPadLineNo, StationCode, StationDescription, '');
    end;

    local procedure InsertKitchenRequestForLineInStep(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; StationCode: Code[20]; StationDescription: Text[50]; ServingStep: Code[10])
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        // Build the kitchen request a KDS send would leave behind for one waiter pad line at one serving step, so the station
        // resolver has something to read: a station, a request, its station row and the source link back to the waiter pad line.
        EnsureKitchenStation(StationCode, StationDescription);

        KitchenRequest.Init();
        KitchenRequest."Restaurant Code" := _Restaurant.Code;
        KitchenRequest.Insert(false); // "Request No." is AutoIncrement

        KitchenRequestStation.Init();
        KitchenRequestStation."Request No." := KitchenRequest."Request No.";
        KitchenRequestStation."Line No." := 1;
        KitchenRequestStation."Production Restaurant Code" := _Restaurant.Code;
        KitchenRequestStation."Kitchen Station" := StationCode;
        KitchenRequestStation.Insert(false);

        KitchenReqSourceLink.Init();
        KitchenReqSourceLink."Request No." := KitchenRequest."Request No.";
        KitchenReqSourceLink."Source Document Type" := KitchenReqSourceLink."Source Document Type"::"Waiter Pad";
        KitchenReqSourceLink."Source Document No." := WaiterPadNo;
        KitchenReqSourceLink."Source Document Line No." := WaiterPadLineNo;
        KitchenReqSourceLink."Serving Step" := ServingStep;
        KitchenReqSourceLink.Insert(false); // "Entry No." is AutoIncrement
    end;

    local procedure InsertKitchenRequestWithTwoStations(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; Station1Code: Code[20]; Station1Description: Text[50]; Station2Code: Code[20]; Station2Description: Text[50])
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        // One kitchen request routed to two stations (a dish two sections prepare), so the resolver lists both.
        EnsureKitchenStation(Station1Code, Station1Description);
        EnsureKitchenStation(Station2Code, Station2Description);

        KitchenRequest.Init();
        KitchenRequest."Restaurant Code" := _Restaurant.Code;
        KitchenRequest.Insert(false);

        KitchenRequestStation.Init();
        KitchenRequestStation."Request No." := KitchenRequest."Request No.";
        KitchenRequestStation."Line No." := 1;
        KitchenRequestStation."Production Restaurant Code" := _Restaurant.Code;
        KitchenRequestStation."Kitchen Station" := Station1Code;
        KitchenRequestStation.Insert(false);

        KitchenRequestStation.Init();
        KitchenRequestStation."Request No." := KitchenRequest."Request No.";
        KitchenRequestStation."Line No." := 2;
        KitchenRequestStation."Production Restaurant Code" := _Restaurant.Code;
        KitchenRequestStation."Kitchen Station" := Station2Code;
        KitchenRequestStation.Insert(false);

        KitchenReqSourceLink.Init();
        KitchenReqSourceLink."Request No." := KitchenRequest."Request No.";
        KitchenReqSourceLink."Source Document Type" := KitchenReqSourceLink."Source Document Type"::"Waiter Pad";
        KitchenReqSourceLink."Source Document No." := WaiterPadNo;
        KitchenReqSourceLink."Source Document Line No." := WaiterPadLineNo;
        KitchenReqSourceLink.Insert(false);
    end;

    local procedure EnsureKitchenStation(StationCode: Code[20]; StationDescription: Text[50])
    var
        KitchenStation: Record "NPR NPRE Kitchen Station";
    begin
        if KitchenStation.Get(_Restaurant.Code, StationCode) then
            exit;
        KitchenStation.Init();
        KitchenStation."Restaurant Code" := _Restaurant.Code;
        KitchenStation.Code := StationCode;
        KitchenStation.Description := StationDescription;
        KitchenStation.Insert(false);
    end;

    local procedure RandomWaiterPadNo(): Code[20]
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        exit(CopyStr(_LibraryUtility.GenerateRandomCode(WaiterPad.FieldNo("No."), Database::"NPR NPRE Waiter Pad"), 1, MaxStrLen(WaiterPad."No.")));
    end;
}
