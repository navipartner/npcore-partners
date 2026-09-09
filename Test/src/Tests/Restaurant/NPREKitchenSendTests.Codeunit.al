codeunit 85407 "NPR NPRE Kitchen Send Tests"
{
    // [FEATURE] Sending waiter pad lines to the kitchen: station routing, its fallback cascade, and order identity
    Subtype = Test;

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
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        StarterStepTok: Label 'STARTER', Locked = true;

    #region Reaching the kitchen at all

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RoutedLine_Sent_OrderRequestAndStationCreated()
    var
        Item: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A dish routed to a station turns into work the kitchen can see
        // [GIVEN] An item routed to the main course step, on a pad, with a station selected for that step
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] A kitchen request exists for the line, with a station request and an order behind it
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'The routed line should have produced exactly one kitchen request.');
        KitchenRequest.FindFirst();
        _Assert.AreNotEqual(0, KitchenRequest."Order ID", 'The kitchen request should belong to a kitchen order.');
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'The kitchen request should have been placed at one station.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineWithNoApplicableStation_Sent_NothingCreated()
    var
        Item: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A dish nobody is set up to cook does not silently become an order
        // [GIVEN] An item routed to a serving step that has no station selection
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, StarterStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        // The return value is the positive control: without it this test passes identically if the send machinery
        // never ran at all, which is indistinguishable from "nothing was routable".
        _Assert.IsFalse(
            _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad, false),
            'A pad with nothing routable should report that nothing was sent.');

        // [THEN] No kitchen request was created
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.IsTrue(KitchenRequest.IsEmpty(), 'A line with no applicable station should not reach the kitchen.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoStationsOnOneStep_Sent_BothGetTheRequest()
    var
        Item: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A dish two stations both work on appears on both screens
        // [GIVEN] Two stations selected for the same serving step and production step
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The one kitchen request carries a station request for each station
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'Two stations on one step should still be one kitchen request.');
        KitchenRequest.FindFirst();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.AreEqual(2, KitchenRequestStation.Count(), 'Each station on the step should get its own station request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlankProductionRestaurant_Sent_DefaultsToSeatingRestaurant()
    var
        Item: Record Item;
        KitchenStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A selection that names no production restaurant produces for the restaurant the guest is sitting in
        // [GIVEN] A company-wide station selection - blank restaurant code - whose Production Restaurant Code is blank
        //         The selection's own restaurant code has to be blank for this to discriminate. Set it to the pad's
        //         restaurant and every candidate value is the same string, so a bug that copied the selection's code
        //         instead of the seating location's would pass. A blank one is still matched, through the recursion in
        //         GetKitchenStationSelection, and now differs from the value the assertion expects.
        Initialize();
        _LibraryRestaurant.CreateKitchenStation(KitchenStation, _Restaurant.Code);
        KitchenStationSelection.Init();
        KitchenStationSelection."Restaurant Code" := '';
        KitchenStationSelection."Seating Location" := _SeatingLocation.Code;
        KitchenStationSelection."Serving Step" := MainCourseStepTok;
        KitchenStationSelection."Print Category Code" := '';
        KitchenStationSelection."Production Restaurant Code" := '';
        KitchenStationSelection."Kitchen Station" := KitchenStation.Code;
        KitchenStationSelection."Production Step" := 0;
        KitchenStationSelection.Insert(true);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The station request was raised under the seating location's restaurant
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.IsFalse(KitchenRequest.IsEmpty(), 'The line should have reached the kitchen.');
        KitchenRequest.FindFirst();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.IsTrue(KitchenRequestStation.FindFirst(), 'A station request should exist.');
        _Assert.AreEqual(_Restaurant.Code, KitchenRequestStation."Production Restaurant Code", 'A blank production restaurant should fall back to the seating location''s restaurant.');
    end;

    #endregion

    #region The station selection fallback cascade

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExactSeatingLocationAndBlankOne_Sent_ExactWins()
    var
        Item: Record Item;
        ExactStation: Record "NPR NPRE Kitchen Station";
        FallbackStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A selection naming this seating location beats a catch-all one
        // [GIVEN] Two selections for the step: one for the pad's seating location, one with a blank location
        Initialize();
        _LibraryRestaurant.CreateKitchenStation(ExactStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStation(FallbackStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, '', ExactStation.Code, 0);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, '', MainCourseStepTok, '', FallbackStation.Code, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] Only the seating-location-specific station received the work
        AssertOnlyStationUsed(WaiterPad."No.", ExactStation.Code);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NoSelectionForServingStep_Sent_BlankStepUsed()
    var
        Item: Record Item;
        FallbackStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A step with no selection of its own falls back to the any-step selection
        // [GIVEN] Only a selection with a blank serving step
        Initialize();
        _LibraryRestaurant.CreateKitchenStation(FallbackStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, _SeatingLocation.Code, '', '', FallbackStation.Code, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The blank-step selection was used
        AssertOnlyStationUsed(WaiterPad."No.", FallbackStation.Code);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NoSelectionForPrintCategory_Sent_BlankCategoryUsed()
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        FallbackStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A line carrying a print category with no selection of its own falls back to the any-category selection
        // [GIVEN] A line with a print category, and only a selection with a blank print category
        Initialize();
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        _LibraryRestaurant.CreateKitchenStation(FallbackStation, _Restaurant.Code);
        _LibraryRestaurant.CreateKitchenStationSelection(
            KitchenStationSelection, _Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, '', FallbackStation.Code, 0);
        CreatePad(Seating, WaiterPad);
        CreateRoutedItem(Item, ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategory.Code);
        AddPadLine(WaiterPad, Item."No.", 1);

        // Pinned before the act: if the category never lands on the line, the blank-category rung is reached on the
        // first pass instead of by falling through, and the assertion below cannot tell the two apart.
        AssertLineHasPrintCategory(WaiterPad."No.", PrintCategory.Code);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The blank-category selection was used
        AssertOnlyStationUsed(WaiterPad."No.", FallbackStation.Code);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NoRestaurantLevelSelection_Sent_GlobalSelectionUsed()
    var
        Item: Record Item;
        GlobalStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] With nothing configured for this restaurant, the company-wide selection applies
        // [SCENARIO] This is the last rung of the fallback cascade, reached by a recursive call at global scope
        // [GIVEN] Only a selection with a blank restaurant code
        Initialize();
        _LibraryRestaurant.CreateKitchenStation(GlobalStation, _Restaurant.Code);
        KitchenStationSelection.Init();
        KitchenStationSelection."Restaurant Code" := '';
        KitchenStationSelection."Seating Location" := '';
        KitchenStationSelection."Serving Step" := '';
        KitchenStationSelection."Print Category Code" := '';
        KitchenStationSelection."Production Restaurant Code" := _Restaurant.Code;
        KitchenStationSelection."Kitchen Station" := GlobalStation.Code;
        KitchenStationSelection."Production Step" := 0;
        KitchenStationSelection.Insert(true);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The global selection was used
        AssertOnlyStationUsed(WaiterPad."No.", GlobalStation.Code);
    end;

    #endregion

    #region Order identity and logging

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SameSourceDocumentOrderId_SecondSend_OrderReused()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] A second round of food for the same table joins the order already on the board
        // [GIVEN] Order ID Assignment = Same for Source Document, and a pad already sent once
        Initialize();
        SetOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"Same for Source Document");
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, FirstItem, MainCourseStepTok, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        FirstOrderID := OnlyOrderIDForPad(WaiterPad."No.");

        // [WHEN] A second routed line is added and the pad sent again
        CreateRoutedItemForStep(SecondItem, MainCourseStepTok);
        AddPadLine(WaiterPad, SecondItem."No.", 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] Both requests sit on the same order
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(2, KitchenRequest.Count(), 'Both lines should have reached the kitchen.');
        KitchenRequest.SetRange("Order ID", FirstOrderID);
        _Assert.AreEqual(2, KitchenRequest.Count(), 'A second send for the same pad should join the existing order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewEachTimeOrderId_SecondSend_SecondOrderCreated()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        OrderIDs: List of [BigInteger];
    begin
        // [SCENARIO] Each send is its own ticket when the restaurant is configured that way
        // [GIVEN] Order ID Assignment = New Each Time, and a pad already sent once
        Initialize();
        SetOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"New Each Time");
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, FirstItem, MainCourseStepTok, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [WHEN] A second routed line is added and the pad sent again
        CreateRoutedItemForStep(SecondItem, MainCourseStepTok);
        AddPadLine(WaiterPad, SecondItem."No.", 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The two requests sit on two different orders
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        KitchenRequest.FindSet();
        repeat
            if not OrderIDs.Contains(KitchenRequest."Order ID") then
                OrderIDs.Add(KitchenRequest."Order ID");
        until KitchenRequest.Next() = 0;
        _Assert.AreEqual(2, OrderIDs.Count(), 'New Each Time should raise a separate order for the second send.');
        _Assert.IsTrue(KitchenOrder.Get(OrderIDs.Get(1)), 'The first order should exist.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FinishedOrder_FurtherLineSent_NewOrderCreated()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] Food ordered after the first round was finished starts a fresh ticket rather than reopening a closed one
        // [GIVEN] Same for Source Document, and a first order already finished
        Initialize();
        SetOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"Same for Source Document");
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, FirstItem, MainCourseStepTok, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        FirstOrderID := OnlyOrderIDForPad(WaiterPad."No.");
        _LibraryRestaurant.FinishKitchenOrder(FirstOrderID);
        KitchenOrder.Get(FirstOrderID);
        _Assert.AreEqual(KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status", 'The first order should be finished before the second send.');

        // [WHEN] A further routed line is added and the pad sent again
        CreateRoutedItemForStep(SecondItem, MainCourseStepTok);
        AddPadLine(WaiterPad, SecondItem."No.", 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The new request went onto a different order
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        KitchenRequest.SetFilter("Order ID", '<>%1', FirstOrderID);
        _Assert.IsFalse(KitchenRequest.IsEmpty(), 'A finished order should not be reused for a later send.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LineSentToKitchen_PrintLogEntryWritten()
    var
        Item: Record Item;
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Sending is recorded, so a resend can tell what already went out
        // [GIVEN] A routed line on a pad
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);

        // [WHEN] The pad is sent to the kitchen
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] A print log entry records the send against the resulting order
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.IsTrue(WPadLinePrintLogEntry.FindFirst(), 'Sending a line to the kitchen should be logged.');
        _Assert.AreEqual(OnlyOrderIDForPad(WaiterPad."No."), WPadLinePrintLogEntry."Kitchen Order ID", 'The log entry should name the order the line was sent to.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingRequested_PlannedRequestAdvancedToServingRequested()
    var
        Item: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ServingRequestType: Option "Order","Serving Request";
    begin
        // [SCENARIO] Asking the kitchen to serve a course moves its requests out of the planned state
        // [GIVEN] A routed line already sent, sitting in Planned
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadWithRoutedLine(Seating, WaiterPad, Item, MainCourseStepTok, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        KitchenRequest.FindFirst();
        _Assert.AreEqual(KitchenRequest."Line Status"::Planned, KitchenRequest."Line Status", 'A newly sent request should start out planned.');

        // [WHEN] A serving request is sent for the same lines
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        KitchenOrderMgt.SendWPLinesToKitchen(WaiterPad, WaiterPadLine, MainCourseStepTok, '', ServingRequestType::"Serving Request", 0DT);

        // [THEN] The request has advanced and carries the moment serving was asked for
        KitchenRequest.Find();
        _Assert.AreEqual(KitchenRequest."Line Status"::"Serving Requested", KitchenRequest."Line Status", 'A serving request should advance a planned request.');
        _Assert.AreNotEqual(0DT, KitchenRequest."Serving Requested Date-Time", 'A serving request should stamp when serving was asked for.');
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

        // Manual close keeps a pad from closing itself out from under the kitchen assertions.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        SetOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"New Each Time");

        // The routing table is wiped per test. A per-test seating location is not enough on its own: the cascade
        // matches seating location before serving step, so a selection with a blank seating location left behind by
        // an earlier test outranks the blank-serving-step selection a later test is trying to exercise. Every test
        // here builds exactly the selections it needs, so starting from an empty table is both safe and necessary.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        Commit();
    end;

    local procedure SetOrderIDAssignment(Method: Enum "NPR NPRE Ord.ID Assign. Method")
    begin
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := Method;
        _Restaurant.Modify();
    end;

    local procedure CreatePad(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreatePadWithRoutedLine(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; ServingStep: Code[10]; Quantity: Decimal)
    begin
        CreatePad(Seating, WaiterPad);
        CreateRoutedItemForStep(Item, ServingStep);
        AddPadLine(WaiterPad, Item."No.", Quantity);
    end;

    local procedure CreateRoutedItemForStep(var Item: Record Item; ServingStep: Code[10])
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        CreateRoutedItem(Item, ItemRoutingProfile, ServingStep);
    end;

    local procedure CreateRoutedItem(var Item: Record Item; var ItemRoutingProfile: Record "NPR NPRE Item Routing Profile"; ServingStep: Code[10])
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
    end;

    local procedure AddPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; ItemNo: Code[20]; Quantity: Decimal)
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", ItemNo, Quantity, 0, WaiterPadLine);
    end;

    local procedure OnlyOrderIDForPad(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindFirst(), 'The pad should have reached the kitchen.');
        exit(KitchenRequest."Order ID");
    end;

    local procedure AssertLineHasPrintCategory(WaiterPadNo: Code[20]; PrintCategoryCode: Code[20])
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        WaiterPadLine.FindFirst();
        AssignedPrintCategory.SetRange("Table No.", Database::"NPR NPRE Waiter Pad Line");
        AssignedPrintCategory.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedPrintCategory.SetRange("Print/Prod. Category Code", PrintCategoryCode);
        _Assert.IsFalse(AssignedPrintCategory.IsEmpty(), 'The pad line should carry the print category before the send.');
    end;

    local procedure AssertOnlyStationUsed(WaiterPadNo: Code[20]; ExpectedStationCode: Code[20])
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindFirst(), 'The line should have reached the kitchen.');
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'Exactly one station should have been selected.');
        KitchenRequestStation.FindFirst();
        _Assert.AreEqual(ExpectedStationCode, KitchenRequestStation."Kitchen Station", 'The fallback cascade selected the wrong station.');
    end;

    #endregion
}
