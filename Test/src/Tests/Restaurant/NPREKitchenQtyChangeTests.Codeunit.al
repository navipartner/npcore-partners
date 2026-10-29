codeunit 85408 "NPR NPRE Kitchen QtyChg Tests"
{
    // [FEATURE] Allocating a waiter pad line quantity change across the kitchen requests already raised for it
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
        DessertStepTok: Label 'DESSERT', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityIncreased_OpenRequestExists_DeltaAbsorbedByThatRequest()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Ordering more of a dish the kitchen has not started yet grows the work already on the board
        // [GIVEN] A line of two, sent, sitting on one unstarted request
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);
        _Assert.AreEqual(1, RequestCount(WaiterPad."No."), 'The line should start with one kitchen request.');

        // [WHEN] The quantity goes up to five and the pad is sent again
        SetLineQuantity(WaiterPadLine, 5);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The existing request grew rather than a second one being raised
        _Assert.AreEqual(1, RequestCount(WaiterPad."No."), 'An open request should absorb the increase rather than a second request being raised.');
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(5, KitchenRequest.Quantity, 'The request should now cover the whole line quantity.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityIncreasedAfterServing_PadResent_SecondRequestRaised()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Ordering more of a dish that has already been served starts fresh work rather than reopening it
        // [GIVEN] A line of two, sent and already served
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);
        ServeEverything(WaiterPad);

        // [WHEN] The quantity goes up to five and the pad is sent again
        SetLineQuantity(WaiterPadLine, 5);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] A second request covers the extra three, leaving the served one alone
        _Assert.AreEqual(2, RequestCount(WaiterPad."No."), 'A served request should not absorb an increase; a new request is expected.');
        FindRequests(WaiterPad."No.", KitchenRequest);
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Served);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'Exactly one new unserved request should have been raised.');
        KitchenRequest.FindFirst();
        KitchenRequest.CalcFields(Quantity);
        _Assert.AreEqual(3, KitchenRequest.Quantity, 'The new request should cover only the increase.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreased_UnstartedRequest_RequestReduced()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Cutting an order back before the kitchen starts simply reduces it
        // [GIVEN] A line of five, sent, on one unstarted request
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 5);

        // [WHEN] The quantity drops to two and the pad is sent again
        SetLineQuantity(WaiterPadLine, 2);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The request now covers two, and is still live
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(2, KitchenRequest.Quantity, 'The request should have been reduced to the new line quantity.');
        _Assert.AreNotEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'A partly reduced request should stay live.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_UnstartedRequest_RequestCancelled()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Taking a dish off the order entirely cancels the kitchen's work
        // [GIVEN] A line of two, sent, on one unstarted request
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);

        // [WHEN] The quantity drops to zero and the pad is sent again
        SetLineQuantity(WaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The request is cancelled
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'Dropping the line to zero should cancel its kitchen request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_SentWithNothingToSendCheck_RequestAndOrderCancelled()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Taking the only dish off the order cancels its kitchen work and its kitchen order, also when the send checks for nothing to send
        // [GIVEN] A line of one, sent, on the only request of its kitchen order
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 1);

        // [WHEN] The quantity drops to zero and the pad is sent the way the Send Kitchen Order POS action does
        SetLineQuantity(WaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad, true);

        // [THEN] The request and its kitchen order are cancelled
        FindOnlyRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'Dropping the only line to zero should cancel its kitchen request.');
        KitchenOrder.Get(KitchenRequest."Order ID");
        _Assert.AreEqual(KitchenOrder."Order Status"::Cancelled, KitchenOrder."Order Status", 'A kitchen order whose every request is cancelled should be cancelled too.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_RequestsOnTwoOrders_BothOrdersCancelled()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] Taking a dish off the order cancels it on every kitchen order it was sent to, and every one of those orders is updated
        // [GIVEN] A new kitchen order for each send, and a line of one that was finished in production and then raised to two on a second order
        Initialize();
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"New Each Time";
        _Restaurant.Modify();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 1);
        FirstOrderID := OnlyRequestOrderID(WaiterPad."No.");
        KitchenOrderMgt.SetHideValidationDialog(true);
        FindOnlyStation(WaiterPad."No.", KitchenRequestStation);
        KitchenOrderMgt.EndProduction(KitchenRequestStation);
        SetLineQuantity(WaiterPadLine, 2);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        FindRequests(WaiterPad."No.", KitchenRequest);
        KitchenRequest.SetFilter("Order ID", '<>%1', FirstOrderID);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'The increase should have been sent on a second kitchen order.');

        // [WHEN] The quantity drops to zero and the pad is sent the way the Send Kitchen Order POS action does
        SetLineQuantity(WaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad, true);

        // [THEN] Both kitchen orders are cancelled
        FindRequests(WaiterPad."No.", KitchenRequest);
        KitchenRequest.FindSet();
        repeat
            KitchenOrder.Get(KitchenRequest."Order ID");
            _Assert.AreEqual(KitchenOrder."Order Status"::Cancelled, KitchenOrder."Order Status", 'Every kitchen order the dish was taken off should be cancelled.');
        until KitchenRequest.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreased_IncreaseAfterServingCancelled_ItsOrderCancelled()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ServedRequestNo: BigInteger;
    begin
        // [SCENARIO] Cutting back only the extra portion ordered after serving cancels that portion's kitchen order, while the served one stays
        // [GIVEN] A line of one, served, then raised to two, which puts the extra portion on a new kitchen order
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 1);
        ServeEverything(WaiterPad);
        ServedRequestNo := OnlyRequestNo(WaiterPad."No.");
        SetLineQuantity(WaiterPadLine, 2);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [WHEN] The quantity drops back to one and the pad is sent again
        SetLineQuantity(WaiterPadLine, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The extra portion and its kitchen order are cancelled
        FindRequests(WaiterPad."No.", KitchenRequest);
        KitchenRequest.SetFilter("Request No.", '<>%1', ServedRequestNo);
        _Assert.IsTrue(KitchenRequest.FindFirst(), 'The increase should have raised a second request.');
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'The extra portion should be cancelled.');
        KitchenOrder.Get(KitchenRequest."Order ID");
        _Assert.AreEqual(KitchenOrder."Order Status"::Cancelled, KitchenOrder."Order Status", 'The kitchen order of the cancelled portion should be cancelled too.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_ServingRequested_ItsOrderCancelled()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SecondWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] Taking a dish off the order and then requesting serving cancels that dish's kitchen order
        // [GIVEN] A new kitchen order for each send, one dish sent on a first order, a second dish sent on a second order, and the second dish taken off
        Initialize();
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"New Each Time";
        _Restaurant.Modify();
        CreateSentPadLine(WaiterPad, FirstWaiterPadLine, 1);
        FirstOrderID := OnlyRequestOrderID(WaiterPad."No.");
        AddSentPadLine(WaiterPad, SecondWaiterPadLine, 1);
        SetLineQuantity(SecondWaiterPadLine, 0);

        // [WHEN] Serving is requested for the pad
        RequestServing(WaiterPad);

        // [THEN] The second dish and its kitchen order are cancelled
        FindRequests(WaiterPad."No.", KitchenRequest);
        KitchenRequest.SetFilter("Order ID", '<>%1', FirstOrderID);
        _Assert.IsTrue(KitchenRequest.FindFirst(), 'The second dish should have been sent on a second kitchen order.');
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'The dish taken off should be cancelled.');
        KitchenOrder.Get(KitchenRequest."Order ID");
        _Assert.AreEqual(KitchenOrder."Order Status"::Cancelled, KitchenOrder."Order Status", 'The kitchen order of the dish taken off should be cancelled too.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_NewDishSentTogether_NewDishJoinsSameOrder()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SecondWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] Swapping a dish for another one in the same send keeps the new dish on the same kitchen order
        // [GIVEN] A line of one, sent, and a second dish added to the pad but not sent yet
        Initialize();
        CreateSentPadLine(WaiterPad, FirstWaiterPadLine, 1);
        FirstOrderID := OnlyRequestOrderID(WaiterPad."No.");
        AddRoutedPadLine(WaiterPad, SecondWaiterPadLine, MainCourseStepTok, 1);

        // [WHEN] The first dish drops to zero and the pad is sent the way the Send Kitchen Order POS action does
        SetLineQuantity(FirstWaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad, true);

        // [THEN] The new dish is on the first kitchen order, which stays open
        FindOnlyLiveRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(FirstOrderID, KitchenRequest."Order ID", 'The new dish should join the kitchen order of the dish it replaced.');
        KitchenOrder.Get(FirstOrderID);
        _Assert.AreEqual(KitchenOrder."Order Status"::Planned, KitchenOrder."Order Status", 'The kitchen order should stay open for the new dish.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreasedToZero_NewDishOnLaterServingStep_NewDishJoinsSameOrder()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SecondWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        FirstOrderID: BigInteger;
    begin
        // [SCENARIO] Swapping a dish for one from a later serving step in the same send keeps the new dish on the same kitchen order
        // [GIVEN] A main course of one, sent, and a dessert added to the pad but not sent yet
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, DessertStepTok, 0);
        CreateSentPadLine(WaiterPad, FirstWaiterPadLine, 1);
        FirstOrderID := OnlyRequestOrderID(WaiterPad."No.");
        AddRoutedPadLine(WaiterPad, SecondWaiterPadLine, DessertStepTok, 1);

        // [WHEN] The main course drops to zero and the pad is sent the way the Send Kitchen Order POS action does
        SetLineQuantity(FirstWaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad, true);

        // [THEN] The dessert is on the first kitchen order, which stays open
        FindOnlyLiveRequest(WaiterPad."No.", KitchenRequest);
        _Assert.AreEqual(FirstOrderID, KitchenRequest."Order ID", 'The dessert should join the kitchen order of the dish it replaced.');
        KitchenOrder.Get(FirstOrderID);
        _Assert.AreEqual(KitchenOrder."Order Status"::Planned, KitchenOrder."Order Status", 'The kitchen order should stay open for the dessert.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityDecreased_UnstartedExhausted_ReachesServedRequest()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ServedRequestNo: BigInteger;
    begin
        // [SCENARIO] A reduction bigger than the untouched work eats into what the kitchen already served
        // [GIVEN] Three served and one unstarted, from a line of four
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 3);
        ServeEverything(WaiterPad);
        ServedRequestNo := OnlyRequestNo(WaiterPad."No.");
        SetLineQuantity(WaiterPadLine, 4);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        _Assert.AreEqual(2, RequestCount(WaiterPad."No."), 'The increase should have raised a second request.');

        // [WHEN] The quantity drops to one and the pad is sent again
        SetLineQuantity(WaiterPadLine, 1);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The unstarted request is gone and the served one has been cut back to what remains
        KitchenRequest.Get(ServedRequestNo);
        KitchenRequest.CalcFields(Quantity);
        _Assert.AreEqual(1, KitchenRequest.Quantity, 'The served request should have absorbed the remainder of the reduction.');
        _Assert.AreEqual(1, LiveRequestCount(WaiterPad."No."), 'Only the served request should still be live.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityChangedOnStartedRequest_StationsFlaggedAsNotAccepted()
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The kitchen is told when an order it has started changes under it
        // [GIVEN] A line of two, sent, with production started
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);
        StartProductionOnPad(WaiterPad);

        // [WHEN] The quantity goes up and the pad is sent again
        SetLineQuantity(WaiterPadLine, 4);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The station is flagged so the change has to be acknowledged
        FindOnlyStation(WaiterPad."No.", KitchenRequestStation);
        _Assert.IsTrue(KitchenRequestStation."Qty. Change Not Accepted", 'A quantity change on started work should be flagged for the station to accept.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FlaggedStation_ChangeAccepted_FlagCleared()
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        // [SCENARIO] Acknowledging the change clears the flag from the station's screen
        // [GIVEN] A station flagged with an unaccepted quantity change
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);
        StartProductionOnPad(WaiterPad);
        SetLineQuantity(WaiterPadLine, 4);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        FindOnlyStation(WaiterPad."No.", KitchenRequestStation);
        _Assert.IsTrue(KitchenRequestStation."Qty. Change Not Accepted", 'The station should be flagged before the change is accepted.');

        // [WHEN] The kitchen accepts the change
        KitchenOrderMgt.AcceptQtyChange(KitchenRequestStation);

        // [THEN] The flag is gone
        KitchenRequestStation.Find();
        _Assert.IsFalse(KitchenRequestStation."Qty. Change Not Accepted", 'Accepting the change should clear the flag.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelledRequest_QuantityIncreased_CancelledRequestLeftAlone()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        CancelledRequestNo: BigInteger;
    begin
        // [SCENARIO] Work the kitchen was told to drop is not quietly revived by a later change
        // [GIVEN] A request cancelled by dropping the line to zero
        Initialize();
        CreateSentPadLine(WaiterPad, WaiterPadLine, 2);
        CancelledRequestNo := OnlyRequestNo(WaiterPad."No.");
        SetLineQuantity(WaiterPadLine, 0);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        KitchenRequest.Get(CancelledRequestNo);
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'The request should be cancelled before the increase.');

        // [WHEN] The quantity goes back up and the pad is sent again
        SetLineQuantity(WaiterPadLine, 3);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The cancelled request is untouched and the new work sits on a fresh request
        KitchenRequest.Get(CancelledRequestNo);
        _Assert.AreEqual(KitchenRequest."Line Status"::Cancelled, KitchenRequest."Line Status", 'A cancelled request should stay cancelled.');
        _Assert.AreEqual(1, LiveRequestCount(WaiterPad."No."), 'The increase should have raised one live request.');
    end;

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

        // Kept so a pad sent more than once stays on a single kitchen order, which keeps these fixtures readable.
        // Not load-bearing for allocation itself: FindKitchenRequestsForSourceDoc filters on source document, restaurant
        // and serving step, never on "Order ID", and HandleQtyChange narrows only by line and production status.
        _Restaurant.Find();
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"Same for Source Document";
        _Restaurant.Modify();

        // Routing selections with a blank seating location or serving step outrank the narrower ones a test builds, so the
        // table is wiped per test. Spelled out in full at NPREKitchenSendTests.Codeunit.al, in its Initialize.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        Commit();
    end;

    local procedure CreateSentPadLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal)
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        AddSentPadLine(WaiterPad, WaiterPadLine, Quantity);
    end;

    local procedure AddSentPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal)
    begin
        AddRoutedPadLine(WaiterPad, WaiterPadLine, MainCourseStepTok, Quantity);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure AddRoutedPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10]; Quantity: Decimal)
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
    end;

    local procedure SetLineQuantity(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal)
    begin
        WaiterPadLine.Find();
        WaiterPadLine.Validate(Quantity, Quantity);
        WaiterPadLine.Modify(true);
    end;

    local procedure ServeEverything(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        HandledOrders: List of [BigInteger];
    begin
        FindRequests(WaiterPad."No.", KitchenRequest);
        _Assert.IsTrue(KitchenRequest.FindSet(), 'The pad should have reached the kitchen before its requests can be served.');
        repeat
            if not HandledOrders.Contains(KitchenRequest."Order ID") then begin
                HandledOrders.Add(KitchenRequest."Order ID");
                _LibraryRestaurant.FinishKitchenOrder(KitchenRequest."Order ID");
            end;
        until KitchenRequest.Next() = 0;
    end;

    local procedure RequestServing(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        ServingRequestType: Option "Order","Serving Request";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        KitchenOrderMgt.SendWPLinesToKitchen(WaiterPad, WaiterPadLine, MainCourseStepTok, '', ServingRequestType::"Serving Request", 0DT);
        KitchenOrderMgt.UpdateCancelledKitchenOrders();
    end;

    local procedure StartProductionOnPad(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        KitchenOrderMgt.SetHideValidationDialog(true);
        FindOnlyStation(WaiterPad."No.", KitchenRequestStation);
        KitchenOrderMgt.StartProduction(KitchenRequestStation);
    end;

    local procedure FindRequests(WaiterPadNo: Code[20]; var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        KitchenRequest.SetAutoCalcFields(Quantity);
    end;

    local procedure FindOnlyRequest(WaiterPadNo: Code[20]; var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        FindRequests(WaiterPadNo, KitchenRequest);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'The pad should have exactly one kitchen request at this point.');
        KitchenRequest.FindFirst();
    end;

    local procedure FindOnlyLiveRequest(WaiterPadNo: Code[20]; var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        FindRequests(WaiterPadNo, KitchenRequest);
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        _Assert.AreEqual(1, KitchenRequest.Count(), 'The pad should have exactly one live kitchen request at this point.');
        KitchenRequest.FindFirst();
    end;

    local procedure OnlyRequestNo(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindOnlyRequest(WaiterPadNo, KitchenRequest);
        exit(KitchenRequest."Request No.");
    end;

    local procedure OnlyRequestOrderID(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindOnlyRequest(WaiterPadNo, KitchenRequest);
        exit(KitchenRequest."Order ID");
    end;

    local procedure RequestCount(WaiterPadNo: Code[20]): Integer
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindRequests(WaiterPadNo, KitchenRequest);
        exit(KitchenRequest.Count());
    end;

    local procedure LiveRequestCount(WaiterPadNo: Code[20]): Integer
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindRequests(WaiterPadNo, KitchenRequest);
        KitchenRequest.SetFilter("Line Status", '<>%1', KitchenRequest."Line Status"::Cancelled);
        exit(KitchenRequest.Count());
    end;

    local procedure FindOnlyStation(WaiterPadNo: Code[20]; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        FindOnlyRequest(WaiterPadNo, KitchenRequest);
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        _Assert.AreEqual(1, KitchenRequestStation.Count(), 'The request should sit at exactly one station.');
        KitchenRequestStation.FindFirst();
    end;

    #endregion
}
