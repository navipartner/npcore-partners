codeunit 85416 "NPR NPRE KDS Web Service Tests"
{
    // [FEATURE] The KDS web service: what a kitchen display board is shown, and what it can do to an order
    //
    // These tests drive "NPR KDS Frontend Assist. Impl." directly rather than the public facade. The facade is a thin
    // wrapper that serialises the same JsonObject to text, and only the implementation exposes SetSkipServerIDCheck.
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
        // Declared for its member names only, exactly as the public facade does, so the tests can name the action they run.
        _KitchenAction: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving";
        MainCourseStepTok: Label 'MAIN', Locked = true;

    #region What the board is shown

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoStationsWithWork_BoardRefreshedForOneStation_OnlyThatStationsOrderReturned()
    var
        FirstWaiterPad: Record "NPR NPRE Waiter Pad";
        SecondWaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Orders: JsonArray;
    begin
        // [SCENARIO] A kitchen display shows the work of its own station, not the whole restaurant's
        // [GIVEN] Two stations, each with an order of its own
        Initialize();
        CreatePadAndSendToNewStation(FirstWaiterPad);
        CreatePadAndSendToNewStation(SecondWaiterPad);

        // [WHEN] The board refreshes for the first station
        SkipServerIDCheck(KDSFrontendAssistImpl);
        Orders := ResponseOrders(
            KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, StationForPad(FirstWaiterPad."No."), false, 0DT, ''));

        // [THEN] Only the first station's order is on it
        _Assert.IsTrue(
            ContainsOrder(Orders, OrderForPad(FirstWaiterPad."No.")),
            'The board should show the order routed to the station it refreshed for.');
        _Assert.IsFalse(
            ContainsOrder(Orders, OrderForPad(SecondWaiterPad."No.")),
            'The board should not show an order routed to a different station.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FinishedOrder_BoardRefreshed_ExcludedByDefaultAndIncludedOnRequest()
    var
        ActiveWaiterPad: Record "NPR NPRE Waiter Pad";
        FinishedWaiterPad: Record "NPR NPRE Waiter Pad";
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Orders: JsonArray;
        FinishedOrderId: BigInteger;
    begin
        // [SCENARIO] Finished work leaves the board unless it is asked for, which is what keeps a busy board readable
        // [GIVEN] One finished order and one still in production
        Initialize();
        CreatePadAndSendToNewStation(FinishedWaiterPad);
        CreatePadAndSend(ActiveWaiterPad);
        FinishedOrderId := OrderForPad(FinishedWaiterPad."No.");
        _LibraryRestaurant.FinishKitchenOrder(FinishedOrderId);

        KitchenOrder.Get(FinishedOrderId);
        _Assert.AreEqual(
            KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status",
            'The fixture should have left the first order finished, otherwise this test proves nothing.');

        // [WHEN] The board refreshes without asking for finished orders
        SkipServerIDCheck(KDSFrontendAssistImpl);
        Orders := ResponseOrders(KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', false, 0DT, ''));

        // [THEN] Only the active order is on it
        _Assert.IsTrue(
            ContainsOrder(Orders, OrderForPad(ActiveWaiterPad."No.")), 'An order still in production should be on the board.');
        _Assert.IsFalse(ContainsOrder(Orders, FinishedOrderId), 'A finished order should be left off the board by default.');

        // [WHEN] It refreshes again asking for finished orders too
        Orders := ResponseOrders(KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', true, 0DT, ''));

        // [THEN] The finished order is included
        _Assert.IsTrue(ContainsOrder(Orders, FinishedOrderId), 'A finished order should appear when finished orders are requested.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrdersFromDifferentTimes_BoardRefreshedFromACutoff_OnlyTheNewerReturned()
    var
        NewerWaiterPad: Record "NPR NPRE Waiter Pad";
        OlderWaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Orders: JsonArray;
        OlderOrderId: BigInteger;
    begin
        // [SCENARIO] A board coming back online asks only for what it missed, rather than reloading days of history
        //
        // [!] Refines catalogue scenario S3-03. startingFrom is only applied when finished orders are in scope:
        //     GenerateKDSData sets the date-time filter inside "if IncludeFinished or FinishedOnly", so a plain
        //     refresh ignores the parameter entirely. This test therefore asks for finished orders as well, which
        //     is the only mode in which the cutoff means anything.
        // [GIVEN] Two orders, one created an hour before the other
        Initialize();
        CreatePadAndSendToNewStation(OlderWaiterPad);
        CreatePadAndSend(NewerWaiterPad);
        OlderOrderId := OrderForPad(OlderWaiterPad."No.");
        BackdateOrder(OlderOrderId, 60);

        // [WHEN] The board refreshes from a cutoff between the two
        SkipServerIDCheck(KDSFrontendAssistImpl);
        Orders := ResponseOrders(
            KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', true, CurrentDateTime() - (30 * 60 * 1000), ''));

        // [THEN] Only the newer order comes back
        _Assert.IsTrue(
            ContainsOrder(Orders, OrderForPad(NewerWaiterPad."No.")), 'An order created after the cutoff should be returned.');
        _Assert.IsFalse(ContainsOrder(Orders, OlderOrderId), 'An order created before the cutoff should be filtered out.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StaleServerId_BoardRefreshed_DataReturnedWithTheCurrentServerId()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Response: JsonObject;
        Orders: JsonArray;
    begin
        // [SCENARIO] A board holding a server id from a different NST is brought up to date rather than served stale rows
        //
        // [!] Corrects catalogue scenario S3-04, which expects a stale id to make the call fail. It does not, and it
        //     should not: inbound web service requests are load balanced across NSTs, so a board can legitimately
        //     reach a server it has not spoken to before. CheckServerID answers that by calling SelectLatestVersion()
        //     to drop this NST's read cache, then serving the request normally.
        //
        //     Scope: this is a smoke test of that path, not a guard on it. SelectLatestVersion() has no in-process
        //     observable effect and AddServerIDToResponse stamps serverId on every response regardless of what was
        //     passed in, so neither assertion below can detect CheckServerID being emptied or inverted. What it does
        //     pin is that a board holding an unknown server id is served normally rather than refused, which is the
        //     behaviour the catalogue got wrong. It is the one test that does not skip the check, so the path at
        //     least executes.
        // [GIVEN] An order the board has not seen
        Initialize();
        CreatePadAndSendToNewStation(WaiterPad);

        // [WHEN] The board refreshes quoting a server id that is not this one
        Response := KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', false, 0DT, 'not-this-server');

        // [THEN] The data comes back, stamped with the id of the server that actually answered
        Orders := ResponseOrders(Response);
        _Assert.IsTrue(
            ContainsOrder(Orders, OrderForPad(WaiterPad."No.")), 'A stale server id should refresh the cache, not refuse the call.');
        _Assert.AreEqual(
            Format(ServiceInstanceId()), GetText(Response, 'serverId'),
            'The response should carry the id of the server that answered, so the board can stop asking for a refresh.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrderWithModifierAndCustomer_BoardRefreshed_PayloadCarriesWhatTheBoardDraws()
    var
        Item: Record Item;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        CommentWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Orders: JsonArray;
        KitchenRequests: JsonArray;
        KitchenStations: JsonArray;
        LineModifiers: JsonArray;
        KitchenRequest: JsonObject;
        Order: JsonObject;
        CustomerNameTok: Label 'Table of Four', Locked = true;
        CustomerPhoneTok: Label '+4512345678', Locked = true;
        NoOnionsTok: Label 'No onions', Locked = true;
    begin
        // [SCENARIO] A single refresh carries everything a ticket on the board is drawn from, so the board never has to ask twice
        // [GIVEN] An order for a named guest, with a dish carrying a comment
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        WaiterPad.Description := CustomerNameTok;
        WaiterPad."Customer Phone No." := CustomerPhoneTok;
        WaiterPad.Modify();
        AddRoutedLine(WaiterPad, Item, WaiterPadLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", NoOnionsTok, WaiterPadLine."Line No.", CommentWaiterPadLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);

        // [WHEN] The board refreshes
        SkipServerIDCheck(KDSFrontendAssistImpl);
        Orders := ResponseOrders(KDSFrontendAssistImpl.RefreshKDSData(_Restaurant.Code, '', false, 0DT, ''));

        // [THEN] The order header carries the guest, and the request carries the dish, its station and its comment
        _Assert.IsTrue(FindOrder(Orders, OrderForPad(WaiterPad."No."), Order), 'The order should be on the board.');
        _Assert.AreEqual(_Restaurant.Code, GetText(Order, 'restaurantId'), 'The order should name its restaurant.');
        _Assert.AreEqual(CustomerNameTok, GetText(Order, 'customerName'), 'The order should carry the guest name from the pad.');
        _Assert.AreEqual(CustomerPhoneTok, GetText(Order, 'customerPhoneNo'), 'The order should carry the guest phone number from the pad.');
        // Compared against the order's actual status rather than merely asserting non-blank: StatusEnumValueName
        // resolves a caption for any valid ordinal, so a non-blank assertion cannot fail.
        KitchenOrder.Get(OrderForPad(WaiterPad."No."));
        _Assert.AreEqual(
            Format(KitchenOrder."Order Status"), GetText(Order, 'orderStatusName'),
            'The order should carry the readable name of its own status.');

        KitchenRequests := GetArray(Order, 'kitchenRequests');
        _Assert.AreEqual(1, KitchenRequests.Count(), 'The order should carry exactly one kitchen request.');
        KitchenRequest := ObjectAt(KitchenRequests, 0);
        _Assert.AreEqual(Item."No.", GetText(KitchenRequest, 'itemNo'), 'The request should name the item to cook.');
        _Assert.AreEqual(MainCourseStepTok, GetText(KitchenRequest, 'servingStep'), 'The request should name its serving step.');

        KitchenStations := GetArray(KitchenRequest, 'kitchenStations');
        _Assert.AreEqual(1, KitchenStations.Count(), 'The request should list the station cooking it.');
        _Assert.AreEqual(
            _Restaurant.Code, GetText(ObjectAt(KitchenStations, 0), 'productionRestaurantId'),
            'The station entry should name the restaurant producing the request.');

        LineModifiers := GetArray(KitchenRequest, 'lineModifiers');
        _Assert.AreEqual(1, LineModifiers.Count(), 'The request should carry the comment as a line modifier.');
        _Assert.AreEqual(
            NoOnionsTok, GetText(ObjectAt(LineModifiers, 0), 'lineDescription'),
            'The modifier should carry the comment text the kitchen has to read.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DelayThresholdsConfigured_SetupsRequested_ThresholdsReturned()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        Response: JsonObject;
        FirstThreshold: Integer;
        SecondThreshold: Integer;
    begin
        // [SCENARIO] The board learns when to start colouring an order late
        //
        // [!] Corrects catalogue scenario S3-07, which expects GetSetups to list restaurants and their stations.
        //     It returns neither: the payload is the two delayed-order thresholds off the company-wide restaurant
        //     setup. The board discovers restaurants and stations elsewhere.
        // [GIVEN] A setup with both delay thresholds configured
        Initialize();
        FirstThreshold := 7;
        SecondThreshold := 14;
        RestaurantSetup.Get();
        RestaurantSetup."Delayed Ord. Threshold 1 (min)" := FirstThreshold;
        RestaurantSetup."Delayed Ord. Threshold 2 (min)" := SecondThreshold;
        RestaurantSetup.Modify();
        Commit();

        // [WHEN] The board asks for setups
        SkipServerIDCheck(KDSFrontendAssistImpl);
        Response := KDSFrontendAssistImpl.GetSetups('');

        // [THEN] Both thresholds come back
        _Assert.AreEqual(
            FirstThreshold, GetInteger(Response, 'warningAfterMinutes'), 'The first delay threshold should be returned to the board.');
        _Assert.AreEqual(
            SecondThreshold, GetInteger(Response, 'errorAfterMinutes'), 'The second delay threshold should be returned to the board.');
    end;

    #endregion

    #region What the board can do

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ProductionActions_RunFromTheBoard_StationProductionStatusFollows()
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        OrderId: BigInteger;
        StationCode: Code[20];
    begin
        // [SCENARIO] Starting and finishing a dish from the board moves the station the same way the kitchen codeunit does
        // [GIVEN] An order at one station, not yet started
        Initialize();
        CreatePadAndSendToNewStation(WaiterPad);
        OrderId := OrderForPad(WaiterPad."No.");
        StationCode := StationForPad(WaiterPad."No.");
        SkipServerIDCheck(KDSFrontendAssistImpl);

        // [WHEN] Production is started from the board
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, StationCode, 0, OrderId, _KitchenAction::"Start Production", '');

        // [THEN] The station is producing
        FindStationForOrder(OrderId, KitchenRequestStation);
        _Assert.AreEqual(
            KitchenRequestStation."Production Status"::Started, KitchenRequestStation."Production Status",
            'Starting production from the board should move the station to Started.');

        // [WHEN] Production is ended from the board
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, StationCode, 0, OrderId, _KitchenAction::"End Production", '');

        // [THEN] The station is finished
        FindStationForOrder(OrderId, KitchenRequestStation);
        _Assert.AreEqual(
            KitchenRequestStation."Production Status"::Finished, KitchenRequestStation."Production Status",
            'Ending production from the board should move the station to Finished.');

        // [WHEN] Production is set back to not started
        KDSFrontendAssistImpl.RunKitchenAction(
            _Restaurant.Code, StationCode, 0, OrderId, _KitchenAction::"Set Production Not Started", '');

        // [THEN] The station is back where it began
        FindStationForOrder(OrderId, KitchenRequestStation);
        _Assert.AreEqual(
            KitchenRequestStation."Production Status"::"Not Started", KitchenRequestStation."Production Status",
            'Setting production not started from the board should return the station to Not Started.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HoldAndResume_RunFromTheBoard_StationFlaggedAndRequestStatusFollows()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        OrderId: BigInteger;
        StationCode: Code[20];
    begin
        // [SCENARIO] A station can park a dish and pick it up again from the board
        //
        // Hold is not a production status. It is a separate "On Hold" flag on the station, and the enum value
        // "Production Status"::"On Hold" is only ever reached on the *request*, which UpdateRequestProdStatus derives
        // from any held station. So both halves are asserted: the flag that was written and the status the board reads.
        // [GIVEN] An order at one station
        Initialize();
        CreatePadAndSendToNewStation(WaiterPad);
        OrderId := OrderForPad(WaiterPad."No.");
        StationCode := StationForPad(WaiterPad."No.");
        SkipServerIDCheck(KDSFrontendAssistImpl);

        // [WHEN] The station puts it on hold
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, StationCode, 0, OrderId, _KitchenAction::"Set OnHold", '');

        // [THEN] The station is flagged as held, and the request reports itself on hold
        FindStationForOrder(OrderId, KitchenRequestStation);
        _Assert.IsTrue(KitchenRequestStation."On Hold", 'Holding a request from the board should flag the station as on hold.');
        FindRequestForOrder(OrderId, KitchenRequest);
        _Assert.AreEqual(
            KitchenRequest."Production Status"::"On Hold", KitchenRequest."Production Status",
            'A held station should make the request report itself on hold, which is what the board draws.');

        // [WHEN] The station resumes it
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, StationCode, 0, OrderId, _KitchenAction::Resume, '');

        // [THEN] Both the flag and the request status are back
        FindStationForOrder(OrderId, KitchenRequestStation);
        _Assert.IsFalse(KitchenRequestStation."On Hold", 'Resuming a request from the board should clear the station''s hold flag.');
        FindRequestForOrder(OrderId, KitchenRequest);
        // The exact value is known: with a single not-started station, UpdateRequestProdStatus copies that station's
        // status onto the request. AreNotEqual would accept Finished or Cancelled just as happily.
        _Assert.AreEqual(
            KitchenRequest."Production Status"::"Not Started", KitchenRequest."Production Status",
            'Resuming should return the request to the status of its single not-started station.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServeAndRevoke_RunFromTheBoard_RequestLineStatusFollows()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        OrderId: BigInteger;
    begin
        // [SCENARIO] Serving a dish and taking that back are both reachable from the board
        // [GIVEN] An order that has been sent to one station
        Initialize();
        CreatePadAndSendToNewStation(WaiterPad);
        OrderId := OrderForPad(WaiterPad."No.");
        SkipServerIDCheck(KDSFrontendAssistImpl);

        // [WHEN] The request is marked served from the board
        // Serving is requested without a station filter, which is how the serving screen calls it.
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, '', 0, OrderId, _KitchenAction::"Set Served", '');

        // [THEN] The request line is served
        FindRequestForOrder(OrderId, KitchenRequest);
        _Assert.AreEqual(
            KitchenRequest."Line Status"::Served, KitchenRequest."Line Status",
            'Serving from the board should move the request line to Served.');

        // [WHEN] Serving is revoked from the board
        KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, '', 0, OrderId, _KitchenAction::"Revoke Serving", '');

        // [THEN] The request line is no longer served
        FindRequestForOrder(OrderId, KitchenRequest);
        // RevokeServingForRequestLine sets Ready for Serving specifically. Asserting merely "not Served" would accept
        // Cancelled - the worst outcome, since the board filters cancelled lines out and the dish would vanish rather
        // than return to the pass.
        _Assert.AreEqual(
            KitchenRequest."Line Status"::"Ready for Serving", KitchenRequest."Line Status",
            'Revoking serving should put the request line back to Ready for Serving.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NeitherRequestNorOrderNamed_ActionRunFromTheBoard_CallRejected()
    var
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
    begin
        // [SCENARIO] An action with nothing to act on is refused rather than being applied to the whole restaurant
        // [GIVEN] Nothing to identify the work
        Initialize();
        SkipServerIDCheck(KDSFrontendAssistImpl);

        // [WHEN] An action is run with neither a request nor an order
        asserterror KDSFrontendAssistImpl.RunKitchenAction(_Restaurant.Code, '', 0, 0, _KitchenAction::"Start Production", '');

        // [THEN] The call is refused
        _Assert.ExpectedError('must be specified');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NotificationSetupExists_OrderReadyNotificationsCreatedFromTheBoard_EntryScheduled()
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        NotificationSetup: Record "NPR NPRE Notification Setup";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.";
        OrderId: BigInteger;
    begin
        // [SCENARIO] Telling a guest their food is ready is something the board itself can trigger
        // [GIVEN] An order, and a notification setup for order-ready on that restaurant
        Initialize();
        CreatePadAndSendToNewStation(WaiterPad);
        OrderId := OrderForPad(WaiterPad."No.");

        NotificationSetup.Init();
        NotificationSetup."Notification Trigger" := "NPR NPRE Notification Trigger"::KDS_ORDER_READY_FOR_SERVING;
        NotificationSetup."Restaurant Code" := _Restaurant.Code;
        NotificationSetup."E-Mail Notification" := true;
        NotificationSetup.Recipient := "NPR NPRE Notif. Recipient"::CUSTOMER;
        NotificationSetup.Insert(true);

        // [WHEN] The board creates order-ready notifications
        SkipServerIDCheck(KDSFrontendAssistImpl);
        KDSFrontendAssistImpl.CreateOrderReadyNotifications(OrderId, '');

        // [THEN] A notification is scheduled for the order
        NotificationEntry.SetRange("Kitchen Order ID", OrderId);
        NotificationEntry.SetRange("Notification Trigger", "NPR NPRE Notification Trigger"::KDS_ORDER_READY_FOR_SERVING);
        _Assert.IsFalse(
            NotificationEntry.IsEmpty(), 'Creating order-ready notifications should schedule an entry for the order.');
    end;

    #endregion

    #region Fixtures

    local procedure CreatePadAndSendToNewStation(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        // A station of its own per pad, so a test can tell one station's board from another's. The routing table is
        // wiped first because every selection this fixture adds carries the same restaurant, seating location, serving
        // step and blank print category, and they differ only by "Kitchen Station" - which is part of the primary key,
        // so they coexist. The cascade's first rung filters on exactly those four values and only falls through when
        // it finds nothing, so a row left behind by an earlier pad does not shadow the new one: it joins it, and the
        // send routes the pad to both stations. That is a different failure from the one the stage 2 send suites
        // document, where the leftover had a blank seating location and out-ranked a row that named one.
        ClearStationSelections();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        CreatePadAndSend(WaiterPad);
    end;

    local procedure CreatePadAndSend(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Item: Record Item;
        Seating: Record "NPR NPRE Seating";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        AddRoutedLine(WaiterPad, Item, WaiterPadLine);
        _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
    end;

    local procedure ClearStationSelections()
    var
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
    begin
        KitchenStationSelection.DeleteAll();
    end;

    local procedure BackdateOrder(OrderId: BigInteger; Minutes: Integer)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
        // Written rather than waited for: the board filters on the order's own Created Date-Time, so moving that back
        // gives the test a cutoff it can state exactly instead of one that depends on how fast the fixture ran.
        KitchenOrder.Get(OrderId);
        KitchenOrder."Created Date-Time" := CurrentDateTime() - (Minutes * 60 * 1000);
        KitchenOrder.Modify();
    end;

    local procedure OrderForPad(WaiterPadNo: Code[20]): BigInteger
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
    begin
        _LibraryRestaurant.FindKitchenRequestsForPad(WaiterPadNo, KitchenRequest);
        KitchenRequest.FindFirst();
        exit(KitchenRequest."Order ID");
    end;

    local procedure StationForPad(WaiterPadNo: Code[20]): Code[20]
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        FindStationForOrder(OrderForPad(WaiterPadNo), KitchenRequestStation);
        exit(KitchenRequestStation."Kitchen Station");
    end;

    local procedure FindStationForOrder(OrderId: BigInteger; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Order ID", OrderId);
        KitchenRequestStation.FindFirst();
    end;

    local procedure FindRequestForOrder(OrderId: BigInteger; var KitchenRequest: Record "NPR NPRE Kitchen Request")
    begin
        KitchenRequest.Reset();
        KitchenRequest.SetRange("Order ID", OrderId);
        KitchenRequest.FindFirst();
    end;

    #endregion

    #region Reading the response

    local procedure SkipServerIDCheck(var KDSFrontendAssistImpl: Codeunit "NPR KDS Frontend Assist. Impl.")
    begin
        // SetSkipServerIDCheck is obsoleted along with the Dragonglass-coupled KDS endpoints, but it is still the
        // supported way to run these entry points without a real NST round trip, and the coverage plan calls for it
        // deliberately. Wrapped so the deprecation is acknowledged once rather than at every call site.
#pragma warning disable AL0432
        KDSFrontendAssistImpl.SetSkipServerIDCheck(true);
#pragma warning restore AL0432
    end;

    local procedure ResponseOrders(Response: JsonObject) Orders: JsonArray
    begin
        exit(GetArray(Response, 'orders'));
    end;

    local procedure FindOrder(Orders: JsonArray; OrderId: BigInteger; var Found: JsonObject): Boolean
    var
        OrderToken: JsonToken;
        PropertyToken: JsonToken;
        OrderIndex: Integer;
    begin
        for OrderIndex := 0 to Orders.Count() - 1 do begin
            Orders.Get(OrderIndex, OrderToken);
            if OrderToken.AsObject().Get('orderId', PropertyToken) then
                if PropertyToken.AsValue().AsBigInteger() = OrderId then begin
                    Found := OrderToken.AsObject();
                    exit(true);
                end;
        end;
        exit(false);
    end;

    local procedure ContainsOrder(Orders: JsonArray; OrderId: BigInteger): Boolean
    var
        Found: JsonObject;
    begin
        exit(FindOrder(Orders, OrderId, Found));
    end;

    local procedure GetArray(Source: JsonObject; PropertyName: Text) Values: JsonArray
    var
        PropertyToken: JsonToken;
    begin
        if not Source.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The response carried no %1 array.', PropertyName));
        exit(PropertyToken.AsArray());
    end;

    local procedure ObjectAt(Values: JsonArray; Index: Integer) Value: JsonObject
    var
        ValueToken: JsonToken;
    begin
        Values.Get(Index, ValueToken);
        exit(ValueToken.AsObject());
    end;

    local procedure GetText(Source: JsonObject; PropertyName: Text): Text
    var
        PropertyToken: JsonToken;
    begin
        // An absent key fails rather than reading as '': it means the payload lost a field, and reporting that as a
        // wrong value sends the reader looking at the value that was written instead of the key that was not. A key
        // that is present and null is a different thing - the serialiser wrote it, and '' is the right reading.
        if not Source.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The payload carried no %1.', PropertyName));
        if PropertyToken.AsValue().IsNull() then
            exit('');
        exit(PropertyToken.AsValue().AsText());
    end;

    local procedure GetInteger(Source: JsonObject; PropertyName: Text): Integer
    var
        PropertyToken: JsonToken;
    begin
        if not Source.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The response carried no %1 value.', PropertyName));
        exit(PropertyToken.AsValue().AsInteger());
    end;

    #endregion

    local procedure Initialize()
    var
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

        // Manual close keeps a pad from settling before the board has been read.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // Manual serving keeps requests from serving themselves out from under the action tests.
        _Restaurant.Find();
        _Restaurant."Mark Requests as Served" := _Restaurant."Mark Requests as Served"::Manual;
        _Restaurant."Order ID Assign. Method" := _Restaurant."Order ID Assign. Method"::"New Each Time";
        _Restaurant.Modify();

        ClearStationSelections();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        Commit();
    end;
}
