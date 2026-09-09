codeunit 85410 "NPR NPRE Kitchen Prod. Tests"
{
    // [FEATURE] KDS production and serving: production steps, hold and resume, serving-time station handling, order status
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

    #region Production steps

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ProductionStarted_StationStampedAndRequestFollows()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Starting a dish marks it as under way and stamps when
        // [GIVEN] A sent line sitting at one unstarted station
        Initialize();
        CreateChainAndSend(WaiterPad, 1);
        FindStationAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        _Assert.AreEqual(KitchenRequestStation."Production Status"::"Not Started", KitchenRequestStation."Production Status", 'A newly sent station request should be unstarted.');

        // [WHEN] The station starts production
        StartProduction(KitchenRequestStation);

        // [THEN] The station is started and stamped, and the request reflects it
        KitchenRequestStation.Find();
        _Assert.AreEqual(KitchenRequestStation."Production Status"::Started, KitchenRequestStation."Production Status", 'The station should be marked as started.');
        _Assert.AreNotEqual(0DT, KitchenRequestStation."Start Date-Time", 'Starting production should stamp when it began.');
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        _Assert.AreEqual(KitchenRequest."Production Status"::Started, KitchenRequest."Production Status", 'The request should follow its station into production.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FirstStepFinished_NextStepReleased()
    var
        FirstStepStation: Record "NPR NPRE Kitchen Req. Station";
        SecondStepStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] The next station in the chain only sees the dish once the one before it is done
        // [GIVEN] A two-step chain, with the second step waiting
        Initialize();
        CreateChainAndSend(WaiterPad, 2);
        FindStationAtStep(WaiterPad."No.", 1, SecondStepStation);
        _Assert.AreEqual(SecondStepStation."Production Status"::Pending, SecondStepStation."Production Status", 'A later production step should start out pending.');

        // [WHEN] The first step finishes
        FindStationAtStep(WaiterPad."No.", 0, FirstStepStation);
        EndProduction(FirstStepStation);

        // [THEN] The second step is released for work
        SecondStepStation.Find();
        _Assert.AreEqual(SecondStepStation."Production Status"::"Not Started", SecondStepStation."Production Status", 'Finishing the first step should release the next one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OneOfTwoStationsOnStepFinished_NextStepStillWaiting()
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        SecondStepStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A step is only done when every station working on it is done
        // [GIVEN] Two stations on the first step and one on the second
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 1);
        CreatePadAndSend(WaiterPad);

        // [WHEN] Only one of the two first-step stations finishes
        FilterStationsAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        _Assert.AreEqual(2, KitchenRequestStation.Count(), 'Both first-step stations should have received the request.');
        KitchenRequestStation.FindFirst();
        EndProduction(KitchenRequestStation);

        // [THEN] The second step is still waiting
        FindStationAtStep(WaiterPad."No.", 1, SecondStepStation);
        _Assert.AreEqual(SecondStepStation."Production Status"::Pending, SecondStepStation."Production Status", 'The next step should wait until every station on the current one is finished.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LaterStepRevertedWhileEarlierUnfinished_BackToPending()
    var
        FirstStepStation: Record "NPR NPRE Kitchen Req. Station";
        SecondStepStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Undoing work puts a later step back into waiting rather than leaving it runnable out of order
        // [GIVEN] A two-step chain worked through to the end, then the first step reopened
        Initialize();
        CreateChainAndSend(WaiterPad, 2);
        FindStationAtStep(WaiterPad."No.", 0, FirstStepStation);
        EndProduction(FirstStepStation);
        FindStationAtStep(WaiterPad."No.", 1, SecondStepStation);
        StartProduction(SecondStepStation);
        EndProduction(SecondStepStation);
        FindStationAtStep(WaiterPad."No.", 0, FirstStepStation);
        SetProductionNotStarted(FirstStepStation);

        // [WHEN] The second step is reopened while the first is unfinished
        FindStationAtStep(WaiterPad."No.", 1, SecondStepStation);
        SetProductionNotStarted(SecondStepStation);

        // [THEN] It falls back to pending rather than not started
        SecondStepStation.Find();
        _Assert.AreEqual(SecondStepStation."Production Status"::Pending, SecondStepStation."Production Status", 'A later step reopened while an earlier one is unfinished should go back to pending.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StationPutOnHoldAndResumed_StatusRestored()
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        // [SCENARIO] A station can park a dish and pick it back up
        // [GIVEN] A started station request
        Initialize();
        CreateChainAndSend(WaiterPad, 1);
        FindStationAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        StartProduction(KitchenRequestStation);

        // [WHEN] It is put on hold
        KitchenOrderMgt.SetKitchenRequestStationOnHold(KitchenRequestStation, true, true);

        // [THEN] The station reports being on hold
        KitchenRequestStation.Find();
        _Assert.IsTrue(KitchenRequestStation."On Hold", 'The station should report being on hold.');

        // [WHEN] It is resumed
        KitchenOrderMgt.SetKitchenRequestStationOnHold(KitchenRequestStation, false, true);

        // [THEN] The hold is lifted and the work is still in production
        KitchenRequestStation.Find();
        _Assert.IsFalse(KitchenRequestStation."On Hold", 'Resuming should lift the hold.');
        _Assert.AreEqual(KitchenRequestStation."Production Status"::Started, KitchenRequestStation."Production Status", 'Resuming should leave the work where it was.');
    end;

    #endregion

    #region When a request counts as served

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MarkServedWhenProductionFinished_LastStationFinishes_RequestServed()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] With no hand-out screen, finishing the food is what counts as serving it
        // [GIVEN] Mark Requests as Served = When Prod. Finished, and the course has been asked for
        //         A merely planned request stays planned however far production gets: the line status only advances
        //         once serving has been requested, so the serving request is part of the precondition, not decoration.
        Initialize();
        SetMarkRequestsAsServed("NPR NPRE Mark Req. as Served"::"When Prod. Finished");
        CreateChainAndSend(WaiterPad, 1);
        RequestServing(WaiterPad);

        // [WHEN] The only station finishes
        FindStationAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        EndProduction(KitchenRequestStation);

        // [THEN] The request counts as served
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        _Assert.AreEqual(KitchenRequest."Line Status"::Served, KitchenRequest."Line Status", 'Finishing production should serve the request in this mode.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MarkServedManually_LastStationFinishes_RequestOnlyReadyForServing()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] With a hand-out screen, finished food waits to be handed over before it counts as served
        // [GIVEN] Mark Requests as Served = Manual, and the course has been asked for
        Initialize();
        SetMarkRequestsAsServed("NPR NPRE Mark Req. as Served"::Manual);
        CreateChainAndSend(WaiterPad, 1);
        RequestServing(WaiterPad);

        // [WHEN] The only station finishes
        FindStationAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        EndProduction(KitchenRequestStation);

        // [THEN] The request is ready to serve but not yet served
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        _Assert.AreEqual(KitchenRequest."Line Status"::"Ready for Serving", KitchenRequest."Line Status", 'Finished production should only make the request ready for serving in this mode.');
    end;

    #endregion

    #region What serving does to unfinished stations

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingWithFinishAll_UnfinishedStationsFinished()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Handing the dish out closes off whatever the kitchen had left on it
        // [GIVEN] Station Req. Handling on Serving = Finish All, one station started and one not
        Initialize();
        SetStationHandlingOnServing("NPR NPRE Req.Handl.on Serving"::"Finish All");
        CreatePadWithStartedAndUnstartedStation(WaiterPad);

        // [WHEN] The request is served
        ServeOnlyRequest(WaiterPad);

        // [THEN] Both stations are finished
        _Assert.AreEqual(2, StationCountWithStatus(WaiterPad, "NPR NPRE K.Req.L. Prod.Status"::Finished), 'Finish All should finish every unfinished station.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingWithCancelAllUnfinished_UnfinishedStationsCancelled()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Handing the dish out writes off whatever the kitchen had left on it
        // [GIVEN] Station Req. Handling on Serving = Cancel All Unfinished, one station started and one not
        Initialize();
        SetStationHandlingOnServing("NPR NPRE Req.Handl.on Serving"::"Cancel All Unfinished");
        CreatePadWithStartedAndUnstartedStation(WaiterPad);

        // [WHEN] The request is served
        ServeOnlyRequest(WaiterPad);

        // [THEN] Both stations are cancelled
        _Assert.AreEqual(2, StationCountWithStatus(WaiterPad, "NPR NPRE K.Req.L. Prod.Status"::Cancelled), 'Cancel All Unfinished should cancel every unfinished station.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingWithFinishStartedCancelNotStarted_StationsSplit()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        StartedStationLineNo: Integer;
        UnstartedStationLineNo: Integer;
    begin
        // [SCENARIO] Work already begun is credited, work never begun is written off
        //
        // Asserted per station rather than as one-of-each. The totals cannot tell the two apart, so swapping the
        // Started and "Not Started" arms of the product's decision would cancel the work in progress and credit the
        // work nobody had touched, and still leave one finished station and one cancelled one for a count to find.
        //
        // [GIVEN] Station Req. Handling on Serving = Finish Started/Cancel Not Started
        Initialize();
        SetStationHandlingOnServing("NPR NPRE Req.Handl.on Serving"::"Finish Started/Cancel Not Started");
        CreatePadWithStartedAndUnstartedStation(WaiterPad, StartedStationLineNo, UnstartedStationLineNo);

        // [WHEN] The request is served
        ServeOnlyRequest(WaiterPad);

        // [THEN] The station that had started is finished, and the one that had not is cancelled
        _Assert.AreEqual(
            "NPR NPRE K.Req.L. Prod.Status"::Finished, StationProductionStatus(WaiterPad, StartedStationLineNo),
            'The station that had already started should be finished.');
        _Assert.AreEqual(
            "NPR NPRE K.Req.L. Prod.Status"::Cancelled, StationProductionStatus(WaiterPad, UnstartedStationLineNo),
            'The station that had not started should be cancelled.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingWithDoNothing_StationsLeftAsTheyWere()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        StartedStationLineNo: Integer;
        UnstartedStationLineNo: Integer;
    begin
        // [SCENARIO] Serving does not touch the kitchen's own record of what it has done
        //
        // Per station for the same reason as the split test above: a Do Nothing that quietly swapped the two statuses
        // would leave one started and one not started, and satisfy any count.
        //
        // [GIVEN] Station Req. Handling on Serving = Do Nothing
        Initialize();
        SetStationHandlingOnServing("NPR NPRE Req.Handl.on Serving"::"Do Nothing");
        CreatePadWithStartedAndUnstartedStation(WaiterPad, StartedStationLineNo, UnstartedStationLineNo);

        // [WHEN] The request is served
        ServeOnlyRequest(WaiterPad);

        // [THEN] Each station keeps the status it had
        _Assert.AreEqual(
            "NPR NPRE K.Req.L. Prod.Status"::Started, StationProductionStatus(WaiterPad, StartedStationLineNo),
            'The station that had started should be left started.');
        _Assert.AreEqual(
            "NPR NPRE K.Req.L. Prod.Status"::"Not Started", StationProductionStatus(WaiterPad, UnstartedStationLineNo),
            'The station that had not started should be left unstarted.');
    end;

    #endregion

    #region Order status and cancellation

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderReadyOnAnyRequest_OneRequestFinished_OrderReadyForServing()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] The pass is told the order is ready as soon as any part of it is
        // [GIVEN] Order Ready for Serving On = Any Request, with one dish finished and one still cooking
        Initialize();
        SetOrderReadyForServingOn("NPR NPRE Order Ready Serving"::"Any Request");

        // [WHEN] One dish finishes production while the other is still cooking
        CreatePadWithOneFinishedAndOneStartedRequest(WaiterPad, KitchenOrder);

        // [THEN] The order counts as ready for serving
        KitchenOrder.Find();
        _Assert.AreEqual(KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status", 'Any Request should make the order ready as soon as one dish is done.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderReadyOnAllRequests_OneRequestStillCooking_OrderInProduction()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] The pass waits for the whole table's food before calling the order ready
        // [GIVEN] Order Ready for Serving On = All Requests, with one dish finished and one still cooking
        Initialize();
        SetOrderReadyForServingOn("NPR NPRE Order Ready Serving"::"All Requests");

        // [WHEN] One dish finishes production while the other is still cooking
        CreatePadWithOneFinishedAndOneStartedRequest(WaiterPad, KitchenOrder);

        // [THEN] The order still counts as in production
        KitchenOrder.Find();
        _Assert.AreEqual(KitchenOrder."Order Status"::"In-Production", KitchenOrder."Order Status", 'All Requests should hold the order in production until every dish is done.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderCancelled_RequestsAndStationsCancelled()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        // [SCENARIO] Killing an order takes its work off every station screen
        // [GIVEN] An order with a live request at a station
        Initialize();
        CreateChainAndSend(WaiterPad, 1);
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        KitchenOrder.Get(KitchenRequest."Order ID");

        // [WHEN] The order is cancelled
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.CancelKitchenOrder(KitchenOrder);

        // [THEN] The order, its request and its station request are all cancelled
        KitchenOrder.Find();
        _Assert.AreEqual(KitchenOrder."Order Status"::Cancelled, KitchenOrder."Order Status", 'The order should be cancelled.');
        KitchenRequest.Find();
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'The request should be cancelled with its order.');
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.FindFirst();
        _Assert.AreEqual(KitchenRequestStation."Production Status"::Cancelled, KitchenRequestStation."Production Status", 'The station request should be cancelled with its order.');
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

        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // Manual serving is the default here so production scenarios are not cut short by requests serving themselves.
        SetMarkRequestsAsServed("NPR NPRE Mark Req. as Served"::Manual);
        SetStationHandlingOnServing("NPR NPRE Req.Handl.on Serving"::"Do Nothing");
        SetOrderReadyForServingOn("NPR NPRE Order Ready Serving"::"All Requests");

        // Normalised per test like the three settings above. CreatePadWithOneFinishedAndOneStartedRequest switches it to
        // "Same for Source Document" so both its dishes land on one order, and without resetting it here that choice
        // leaks into whichever test runs next.
        SetOrderIDAssignment("NPR NPRE Ord.ID Assign. Method"::"New Each Time");

        // Routing selections with a blank seating location or serving step outrank the narrower ones a test builds, so the
        // table is wiped per test. Spelled out in full at NPREKitchenSendTests.Codeunit.al, in its Initialize.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        Commit();
    end;

    local procedure SetMarkRequestsAsServed(Mode: Enum "NPR NPRE Mark Req. as Served")
    begin
        _Restaurant.Find();
        _Restaurant."Mark Requests as Served" := Mode;
        _Restaurant.Modify();
    end;

    local procedure SetStationHandlingOnServing(Mode: Enum "NPR NPRE Req.Handl.on Serving")
    begin
        _Restaurant.Find();
        _Restaurant."Station Req. Handl. On Serving" := Mode;
        _Restaurant.Modify();
    end;

    local procedure SetOrderIDAssignment(Method: Enum "NPR NPRE Ord.ID Assign. Method")
    begin
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := Method;
        _Restaurant.Modify();
    end;

    local procedure SetOrderReadyForServingOn(Mode: Enum "NPR NPRE Order Ready Serving")
    begin
        _Restaurant.Find();
        _Restaurant."Order Is Ready For Serving" := Mode;
        _Restaurant.Modify();
    end;

    local procedure CreateChainAndSend(var WaiterPad: Record "NPR NPRE Waiter Pad"; StepCount: Integer)
    begin
        _LibraryRestaurant.CreateProductionChain(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, StepCount);
        CreatePadAndSend(WaiterPad);
    end;

    local procedure CreatePadAndSend(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Item: Record Item;
    begin
        CreatePadWithRoutedLine(WaiterPad, Item);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure CreatePadWithRoutedLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        Seating: Record "NPR NPRE Seating";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
    end;

    local procedure CreatePadWithStartedAndUnstartedStation(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        StartedStationLineNo: Integer;
        UnstartedStationLineNo: Integer;
    begin
        CreatePadWithStartedAndUnstartedStation(WaiterPad, StartedStationLineNo, UnstartedStationLineNo);
    end;

    local procedure CreatePadWithStartedAndUnstartedStation(var WaiterPad: Record "NPR NPRE Waiter Pad"; var StartedStationLineNo: Integer; var UnstartedStationLineNo: Integer)
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        // Two stations on the same production step, so both are runnable and one can be left untouched. Which one was
        // started is handed back, because after serving the two are only distinguishable by identity - the statuses
        // they end up with are exactly what is under test.
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadAndSend(WaiterPad);
        FilterStationsAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        _Assert.AreEqual(2, KitchenRequestStation.Count(), 'Both stations should have received the request.');

        KitchenRequestStation.FindFirst();
        StartedStationLineNo := KitchenRequestStation."Line No.";
        StartProduction(KitchenRequestStation);

        FilterStationsAtStep(WaiterPad."No.", 0, KitchenRequestStation);
        KitchenRequestStation.SetFilter("Line No.", '<>%1', StartedStationLineNo);
        KitchenRequestStation.FindFirst();
        UnstartedStationLineNo := KitchenRequestStation."Line No.";
        _Assert.AreEqual(
            "NPR NPRE K.Req.L. Prod.Status"::"Not Started", KitchenRequestStation."Production Status",
            'The second station should still be untouched, or there is nothing for the serving rules to tell apart.');
    end;

    local procedure CreatePadWithOneFinishedAndOneStartedRequest(var WaiterPad: Record "NPR NPRE Waiter Pad"; var KitchenOrder: Record "NPR NPRE Kitchen Order")
    var
        SecondItem: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // Both dishes must sit on one order for the order status rules to be exercised.
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"Same for Source Document";
        _Restaurant.Modify();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadAndSend(WaiterPad);

        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(SecondItem, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(SecondItem, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SecondItem."No.", 1, 0, WaiterPadLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(2, KitchenRequest.Count(), 'Both dishes should have reached the kitchen.');
        KitchenRequest.FindFirst();
        KitchenOrder.Get(KitchenRequest."Order ID");

        // First dish finished, second one started.
        StationForRequest(KitchenRequest."Request No.", KitchenRequestStation);
        EndProduction(KitchenRequestStation);
        // Asserted rather than discarded: if Next() returned 0 the two lines below would re-touch the request just
        // finished, and the "one finished, one started" precondition would silently never be built.
        _Assert.AreNotEqual(0, KitchenRequest.Next(), 'The fixture needs a second kitchen request to start.');
        StationForRequest(KitchenRequest."Request No.", KitchenRequestStation);
        StartProduction(KitchenRequestStation);

        // Both order-ready tests assert only on the order status, so the precondition they rest on is pinned here:
        // exactly one station finished and one still in production.
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Order ID", KitchenOrder."Order ID");
        KitchenRequestStation.SetRange("Production Status", KitchenRequestStation."Production Status"::Finished);
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'The fixture should leave exactly one station finished.');
        KitchenRequestStation.SetRange("Production Status", KitchenRequestStation."Production Status"::Started);
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'The fixture should leave exactly one station still in production.');
    end;

    local procedure RequestServing(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        ServingRequestType: Option "Order","Serving Request";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        KitchenOrderMgt.SendWPLinesToKitchen(WaiterPad, WaiterPadLine, MainCourseStepTok, '', ServingRequestType::"Serving Request", 0DT);
    end;

    local procedure ServeOnlyRequest(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        KitchenOrderMgt.SetRequestLineAsServed(KitchenRequest);
    end;

    local procedure StartProduction(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.StartProduction(KitchenRequestStation);
    end;

    local procedure EndProduction(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenOrderMgt.EndProduction(KitchenRequestStation);
    end;

    local procedure SetProductionNotStarted(var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);
        KitchenRequest.Get(KitchenRequestStation."Request No.");
        KitchenOrderMgt.SetProductionNotStarted(KitchenRequest, KitchenRequestStation);
    end;

    local procedure FindOnlyRequest(WaiterPadNo: Code[20]; var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'The pad should have exactly one kitchen request.');
        KitchenRequest.FindFirst();
    end;

    local procedure FilterStationsAtStep(WaiterPadNo: Code[20]; ProductionStep: Integer; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindOnlyRequest(WaiterPadNo, KitchenRequest);
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.SetRange("Production Step", ProductionStep);
    end;

    local procedure FindStationAtStep(WaiterPadNo: Code[20]; ProductionStep: Integer; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        FilterStationsAtStep(WaiterPadNo, ProductionStep, KitchenRequestStation);
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'Exactly one station should sit at this production step.');
        KitchenRequestStation.FindFirst();
    end;

    local procedure StationForRequest(RequestNo: BigInteger; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.IsTrue(KitchenRequestStation.FindFirst(), 'The request should sit at a station.');
    end;

    local procedure StationProductionStatus(WaiterPad: Record "NPR NPRE Waiter Pad"; StationLineNo: Integer): Enum "NPR NPRE K.Req.L. Prod.Status"
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        KitchenRequestStation.Get(KitchenRequest."Request No.", StationLineNo);
        exit(KitchenRequestStation."Production Status");
    end;

    local procedure StationCountWithStatus(WaiterPad: Record "NPR NPRE Waiter Pad"; ProductionStatus: Enum "NPR NPRE K.Req.L. Prod.Status"): Integer
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequestStation.SetRange("Production Status", ProductionStatus);
        exit(KitchenRequestStation.Count());
    end;

    #endregion
}
