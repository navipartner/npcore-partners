codeunit 85417 "NPR NPRE POS View Data Tests"
{
    // [FEATURE] The data the POS restaurant view is given: which waiter pads it lists and which statuses and colours it paints them with
    //
    // These suites assert on the payloads the assistant pushes to the front end rather than on a mock. Every push goes
    // through "NPR POS Front End Management".InvokeFrontEndMethod2, which queues the request JSON on the POS session's
    // Dragonglass response queue; POSSession.PopResponseQueue() hands it back. So the assertions here are made against
    // exactly the bytes the React front end would have received, with no capture mock in the way.
    //
    // The queue lives on a SingleInstance codeunit and therefore survives from one test to the next, which is why every
    // test drains it immediately before the call it is measuring.
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _LastDrainedRequests: JsonArray;
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        LayoutRefreshMethodTok: Label 'UpdateRestaurantLayout', Locked = true;
        MealFlowStatusStarterTok: Label 'STARTER', Locked = true;
        SwitchFilterPairTok: Label '%1|%2', Locked = true;
        StatusRefreshMethodTok: Label 'UpdateRestaurantStatuses', Locked = true;
        WaiterPadDataMethodTok: Label 'UpdateWaiterPadData', Locked = true;

    #region Which pads the view is given

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadsInTwoRestaurants_DataRefreshedForOne_OnlyThatRestaurantsPadsReturned()
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        OtherSeating: Record "NPR NPRE Seating";
        OtherSeatingLocation: Record "NPR NPRE Seating Location";
        OtherWaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        WaiterPads: JsonArray;
    begin
        // [SCENARIO] A restaurant's view shows that restaurant's tables, never the ones next door
        // [GIVEN] An open pad in the restaurant under test and another in a second restaurant
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(OtherSeatingLocation, OtherRestaurant.Code);
        _LibraryRestaurant.CreateSeating(OtherSeating, OtherSeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(OtherSeating.Code, OtherWaiterPad);

        // [WHEN] Waiter pad data is refreshed for the restaurant under test
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, _Restaurant.Code, _SeatingLocation.Code);

        // [THEN] Only its own pad is in the payload
        WaiterPads := PopFrontEndArray(POSSession, WaiterPadDataMethodTok, 'waiterPads');
        _Assert.IsTrue(
            ArrayContainsValue(WaiterPads, 'id', WaiterPad."No."),
            'The refreshed data should contain the pad belonging to the requested restaurant.');
        _Assert.IsFalse(
            ArrayContainsValue(WaiterPads, 'id', OtherWaiterPad."No."),
            'The refreshed data should not contain a pad belonging to another restaurant.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadsInTwoLocationsOfOneRestaurant_DataRefreshedForOneLocation_BothLocationsReturned()
    var
        SecondSeating: Record "NPR NPRE Seating";
        SecondSeatingLocation: Record "NPR NPRE Seating Location";
        SecondWaiterPad: Record "NPR NPRE Waiter Pad";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        WaiterPads: JsonArray;
    begin
        // [SCENARIO] Asking for one seating location returns the whole restaurant, because the location filter is not applied
        //
        // [!] Corrects catalogue scenario S3-09, which expects pad data to be scoped to restaurant *and* location.
        //     RefreshWaiterPadData accepts a LocationCode and ignores it: the SetRange that would apply it is
        //     commented out in the product, so the payload always spans every location of the restaurant. This test
        //     pins what the code does. Whether the filter should be restored is a product question, not a test one.
        // [GIVEN] Two seating locations in the same restaurant, each with an open pad
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        _LibraryRestaurant.CreateSeatingLocation(SecondSeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.CreateSeating(SecondSeating, SecondSeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(SecondSeating.Code, SecondWaiterPad);

        // [WHEN] Data is refreshed for the first location only
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, _Restaurant.Code, _SeatingLocation.Code);

        // [THEN] Pads from both locations come back
        WaiterPads := PopFrontEndArray(POSSession, WaiterPadDataMethodTok, 'waiterPads');
        _Assert.IsTrue(
            ArrayContainsValue(WaiterPads, 'id', WaiterPad."No."),
            'The requested location''s pad should be in the payload.');
        _Assert.IsTrue(
            ArrayContainsValue(WaiterPads, 'id', SecondWaiterPad."No."),
            'The location parameter is not applied, so the other location''s pad should be in the payload too.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPadOnSeating_DataRefreshed_SeatingLinkCarriesPadAndLocation()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        SeatingLinks: JsonArray;
        SeatingLink: JsonObject;
    begin
        // [SCENARIO] The view can place a pad on the floor plan, which needs the seating link, not just the pad
        // [GIVEN] An open pad on a seating
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        // [WHEN] Waiter pad data is refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, _Restaurant.Code, _SeatingLocation.Code);

        // [THEN] The seating link names the restaurant, the location, the seating and the pad
        SeatingLinks := PopFrontEndArray(POSSession, WaiterPadDataMethodTok, 'waiterPadSeatingLinks');
        _Assert.IsTrue(
            FindObjectByValue(SeatingLinks, 'waiterPadId', WaiterPad."No.", SeatingLink),
            'The payload should carry a seating link for the open pad.');
        _Assert.AreEqual(
            _Restaurant.Code, GetText(SeatingLink, 'restaurantId'), 'The seating link should name the restaurant.');
        _Assert.AreEqual(
            _SeatingLocation.Code, GetText(SeatingLink, 'locationId'), 'The seating link should name the seating location.');
        _Assert.AreEqual(
            Seating.Code, GetText(SeatingLink, 'seatingId'), 'The seating link should name the seating.');

        // [THEN] The same call also refreshed the statuses of the seatings it just described
        // Without this the follow-up RefreshStatus at the end of RefreshWaiterPadData could be deleted and the view
        // would paint the new pads with stale colours, with nothing here to notice.
        AssertAlsoQueued(StatusRefreshMethodTok);
    end;

    #endregion

    #region Statuses and their colours

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingsInDifferentStatuses_StatusRefreshed_EachReturnedWithItsColour()
    var
        BlockedSeating: Record "NPR NPRE Seating";
        ReadySeating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        Statuses: JsonObject;
        BlockedHexTok: Label 'FF0000', Locked = true;
        ReadyHexTok: Label '00FF00', Locked = true;
    begin
        // [SCENARIO] The floor plan can colour each table, so every seating comes back with its status and that status's colour
        // [GIVEN] A ready seating and a blocked one, with a colour configured against each status
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetSeatingStatusColour(_LibraryRestaurant.SeatingStatusReady(), ReadyHexTok);
        SetSeatingStatusColour(_LibraryRestaurant.SeatingStatusBlocked(), BlockedHexTok);
        _LibraryRestaurant.CreateSeating(ReadySeating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateSeating(BlockedSeating, _SeatingLocation.Code);
        SeatingMgt.SetSeatingIsReady(ReadySeating.Code);
        SeatingMgt.SetSeatingIsBlocked(BlockedSeating.Code);

        // [WHEN] Statuses are refreshed for the restaurant
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] Each seating carries its own status code and colour
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        AssertStatusAndColour(
            Statuses, ReadySeating.Code, _LibraryRestaurant.SeatingStatusReady(), ReadyHexTok, 'ready seating');
        AssertStatusAndColour(
            Statuses, BlockedSeating.Code, _LibraryRestaurant.SeatingStatusBlocked(), BlockedHexTok, 'blocked seating');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingsInTwoRestaurants_StatusRefreshedForOne_OnlyThatRestaurantsSeatingsReturned()
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        OtherSeating: Record "NPR NPRE Seating";
        OtherSeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        Statuses: JsonObject;
        StatusToken: JsonToken;
    begin
        // [SCENARIO] A status refresh is scoped the same way the pad data is, so one restaurant's floor plan never repaints another's
        // [GIVEN] A seating in the restaurant under test and one in a second restaurant
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        SeatingMgt.SetSeatingIsReady(Seating.Code);

        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(OtherSeatingLocation, OtherRestaurant.Code);
        _LibraryRestaurant.CreateSeating(OtherSeating, OtherSeatingLocation.Code);
        SeatingMgt.SetSeatingIsReady(OtherSeating.Code);

        // [WHEN] Statuses are refreshed for the restaurant under test
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] Only its seating is in the payload
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        _Assert.IsTrue(Statuses.Get(Seating.Code, StatusToken), 'The requested restaurant''s seating should have a status.');
        _Assert.IsFalse(
            Statuses.Get(OtherSeating.Code, StatusToken),
            'A seating belonging to another restaurant should not be in the payload.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPadOnSeating_StatusRefreshed_PadStatusReturnedAlongsideTheSeating()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        PadStatuses: JsonObject;
        StatusToken: JsonToken;
    begin
        // [SCENARIO] The view paints pads as well as tables, so an open pad comes back in the same refresh
        // [GIVEN] An open pad on a seating
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The pad has an entry of its own
        PadStatuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'waiterPad');
        _Assert.IsTrue(PadStatuses.Get(WaiterPad."No.", StatusToken), 'An open pad should have a status in the payload.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosedPadOnSeating_StatusRefreshed_PadLeftOutOfThePayload()
    var
        OpenSeating: Record "NPR NPRE Seating";
        Seating: Record "NPR NPRE Seating";
        OpenWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        PadStatuses: JsonObject;
        StatusToken: JsonToken;
    begin
        // [SCENARIO] A settled pad stops being painted on the floor plan while its neighbours stay
        //
        // The still-open pad is the control. RefreshStatus always adds the "waiterPad" key, empty object included, so
        // the absence assertion on its own is satisfied by any regression that empties the map - wrong restaurant
        // scoping, a broken seating location join - and would read as a pass.
        //
        // What this pins is the SetRange(Closed, false) on the seating link. The "and not WaiterPad.Closed" beside it
        // is unreachable from here and from anywhere else the fixture can build: closing a pad always closes its
        // seating links in the same call, so an open link pointing at a closed pad is not a state the product makes.
        //
        // [GIVEN] A pad that has been closed, and another one on a different seating that has not
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");
        _LibraryRestaurant.CreateSeating(OpenSeating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(OpenSeating.Code, OpenWaiterPad);

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The closed pad has no entry, and the open one still does
        PadStatuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'waiterPad');
        _Assert.IsFalse(PadStatuses.Get(WaiterPad."No.", StatusToken), 'A closed pad should not be painted on the floor plan.');
        _Assert.IsTrue(
            PadStatuses.Get(OpenWaiterPad."No.", StatusToken),
            'The open pad should still be painted, so an empty payload cannot pass the assertion above.');
    end;

    #endregion

    #region Colour resolution matches the table helpers

    // The payload no longer asks each seating and each pad for its own colour. It resolves them from one cached copy of
    // the status and colour setup instead, which is what takes the per-table round trips out of a refresh. These tests
    // exist to keep that copy honest: each one builds a case where the resolution rules actually bite, then asserts the
    // pushed value against the table helper the front end used to be painted from. If the two ever diverge, tables on a
    // real floor plan change colour, and that is not something a smaller-payload change is allowed to do.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadStatusOutranksSeatingStatus_StatusRefreshed_PadColourPaintsTheTable()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        Statuses: JsonObject;
        PadHexTok: Label 'AA0000', Locked = true;
        SeatingHexTok: Label '00AA00', Locked = true;
    begin
        // [SCENARIO] A table occupied by a pad whose status outranks the table's own is painted in the pad's colour
        // [GIVEN] A seating status and a waiter pad status with colours of their own, the pad status ranked higher
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::Seating, _LibraryRestaurant.SeatingStatusReady(), SeatingHexTok, 10, true);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 20, true);

        // [GIVEN] A ready table with an open pad waiting to be paid
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The table is painted in the pad's colour, not its own
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        AssertStatusAndColour(
            Statuses, Seating.Code, _LibraryRestaurant.SeatingStatusReady(), PadHexTok, 'occupied table');

        // [THEN] And that is the same colour the seating itself reports
        AssertSeatingColourMatchesHelper(Statuses, Seating);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StatusHiddenFromTheFrontEnd_StatusRefreshed_ItsColourIsIgnored()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        Statuses: JsonObject;
        HiddenHexTok: Label 'BB0000', Locked = true;
    begin
        // [SCENARIO] A status that is not available in the front end contributes no colour, however it is configured
        // [GIVEN] A seating status carrying a colour but flagged as unavailable in the front end
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::Seating, _LibraryRestaurant.SeatingStatusReady(), HiddenHexTok, 10, false);

        // [GIVEN] A table in that status
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The table comes back with no colour at all
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        AssertStatusAndColour(Statuses, Seating.Code, _LibraryRestaurant.SeatingStatusReady(), '', 'hidden-status table');

        // [THEN] And that is the same colour the seating itself reports
        AssertSeatingColourMatchesHelper(Statuses, Seating);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingAndPadStatusRankedEqually_StatusRefreshed_SeatingColourKeepsTheTable()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        Statuses: JsonObject;
        PadHexTok: Label 'CC0000', Locked = true;
        SeatingHexTok: Label '00CC00', Locked = true;
    begin
        // [SCENARIO] When two statuses are ranked equally the one resolved first keeps the table, so a tie does not repaint it
        // [GIVEN] A seating status and a waiter pad status carrying the same colour priority
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::Seating, _LibraryRestaurant.SeatingStatusReady(), SeatingHexTok, 10, true);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 10, true);

        // [GIVEN] A ready table with an open pad waiting to be paid
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The table keeps the colour of its own status, which is the one resolved first
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        AssertStatusAndColour(
            Statuses, Seating.Code, _LibraryRestaurant.SeatingStatusReady(), SeatingHexTok, 'evenly ranked table');

        // [THEN] And that is the same colour the seating itself reports
        AssertSeatingColourMatchesHelper(Statuses, Seating);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPadWithAStatus_StatusRefreshed_PadStatusAndColourMatchThePadHelpers()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        PadStatuses: JsonObject;
        PadEntry: JsonObject;
        PadToken: JsonToken;
        PadHexTok: Label 'DD0000', Locked = true;
    begin
        // [SCENARIO] A pad is listed with the status and colour its own record reports, so the badge on it does not drift
        // [GIVEN] A waiter pad status with a colour, on an open pad
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 20, true);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The pad entry carries the configured colour
        PadStatuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'waiterPad');
        if not PadStatuses.Get(WaiterPad."No.", PadToken) then
            _Assert.Fail('The open pad should have a status entry.');
        PadEntry := PadToken.AsObject();
        _Assert.AreEqual(PadHexTok, GetText(PadEntry, 'color'), 'The pad should carry the colour configured for its status.');

        // [THEN] And both its status and its colour are what the pad record itself reports
        WaiterPad.Find();
        _Assert.AreEqual(
            WaiterPad.WaiterPadFrontEndStatus(), GetText(PadEntry, 'status'),
            'The pushed pad status should be the one the pad record resolves.');
        _Assert.AreEqual(
            WaiterPad.RGBColorCodeHex(false), GetText(PadEntry, 'color'),
            'The pushed pad colour should be the one the pad record resolves.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadOnAHiddenServingStep_StatusRefreshed_VisiblePadStatusStillWins()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        PadStatuses: JsonObject;
        PadToken: JsonToken;
        PadHexTok: Label 'E10000', Locked = true;
        StepHexTok: Label '00E100', Locked = true;
    begin
        // [SCENARIO] A serving step the front end is not meant to show never wins the badge, however high it is ordered
        //
        // The serving step branch is otherwise dark in every test here, because a pad created by the library carries a
        // blank step. Without this the resolver's three meal-flow lookups could all be deleted and the suite stay green.
        //
        // [GIVEN] A serving step hidden from the front end but ordered above a visible pad status
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour("NPR NPRE Status Object"::WaiterPadLineMealFlow, MealFlowStatusStarterTok, StepHexTok, 20, false);
        SetFlowStatusOrder("NPR NPRE Status Object"::WaiterPadLineMealFlow, MealFlowStatusStarterTok, 100);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 10, true);
        SetFlowStatusOrder("NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), 10);

        // [GIVEN] A pad sitting on that step and waiting to be paid
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetWaiterPadServingStep(WaiterPad, MealFlowStatusStarterTok);
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The pad shows the visible status, not the hidden step that outranks it
        PadStatuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'waiterPad');
        if not PadStatuses.Get(WaiterPad."No.", PadToken) then
            _Assert.Fail('The open pad should have a status entry.');
        _Assert.AreEqual(
            _LibraryRestaurant.WaiterPadStatusReadyForPmt(), GetText(PadToken.AsObject(), 'status'),
            'A serving step hidden from the front end should not take the badge from a visible pad status.');

        // [THEN] And that is what the pad record itself resolves
        WaiterPad.Find();
        _Assert.AreEqual(
            WaiterPad.WaiterPadFrontEndStatus(), GetText(PadToken.AsObject(), 'status'),
            'The pushed pad status should be the one the pad record resolves.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadOnAVisibleServingStep_StatusRefreshed_ServingStepOutranksLowerPadStatus()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        PadStatuses: JsonObject;
        PadToken: JsonToken;
        PadHexTok: Label 'E20000', Locked = true;
        StepHexTok: Label '00E200', Locked = true;
    begin
        // [SCENARIO] A visible serving step further along the meal keeps the badge from an earlier pad status
        // [GIVEN] A visible serving step ordered above a visible pad status
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour("NPR NPRE Status Object"::WaiterPadLineMealFlow, MealFlowStatusStarterTok, StepHexTok, 20, true);
        SetFlowStatusOrder("NPR NPRE Status Object"::WaiterPadLineMealFlow, MealFlowStatusStarterTok, 100);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 10, true);
        SetFlowStatusOrder("NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), 10);

        // [GIVEN] A pad sitting on that step and waiting to be paid
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetWaiterPadServingStep(WaiterPad, MealFlowStatusStarterTok);
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The serving step keeps the badge, and its colour with it
        PadStatuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'waiterPad');
        if not PadStatuses.Get(WaiterPad."No.", PadToken) then
            _Assert.Fail('The open pad should have a status entry.');
        _Assert.AreEqual(
            MealFlowStatusStarterTok, GetText(PadToken.AsObject(), 'status'),
            'A visible serving step ordered above the pad status should keep the badge.');
        _Assert.AreEqual(
            StepHexTok, GetText(PadToken.AsObject(), 'color'),
            'The higher-priority serving step colour should win.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosedPadStillLinkedToSeating_StatusRefreshed_ItStillColoursTheTable()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        Statuses: JsonObject;
        PadStatusesToken: JsonToken;
        PadToken: JsonToken;
        PadHexTok: Label 'E30000', Locked = true;
        SeatingHexTok: Label '00E300', Locked = true;
    begin
        // [SCENARIO] A table keeps the colour of a pad that closed while its link stayed open, and the pad drops off the list
        //
        // The resolver colours a table from any linked pad that still exists, while it lists only pads that are open.
        // That asymmetry is carried over from the table helper deliberately, and nothing else pins it, so an apparent
        // consistency fix would repaint live floor plans. The state is built directly because closing a pad through the
        // product closes its links in the same call.
        //
        // [GIVEN] A ready table whose pad outranks it on colour
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::Seating, _LibraryRestaurant.SeatingStatusReady(), SeatingHexTok, 10, true);
        SetFlowStatusColour(
            "NPR NPRE Status Object"::WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt(), PadHexTok, 20, true);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());
        SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt());

        // [GIVEN] The pad is closed but its link to the table is left open
        WaiterPad.Find();
        WaiterPad.Closed := true;
        WaiterPad.Modify();

        // [WHEN] Statuses are refreshed
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshStatus(FrontEnd, _Restaurant.Code, '', '');

        // [THEN] The table still carries the closed pad's colour
        Statuses := PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        AssertStatusAndColour(
            Statuses, Seating.Code, _LibraryRestaurant.SeatingStatusReady(), PadHexTok, 'table with a closed but linked pad');
        AssertSeatingColourMatchesHelper(Statuses, Seating);

        // [THEN] But the pad itself is not listed, which is the other half of the asymmetry
        _Assert.IsFalse(
            DrainedRequest(StatusRefreshMethodTok).Get('waiterPad', PadStatusesToken) and PadStatusesToken.AsObject().Get(WaiterPad."No.", PadToken),
            'A closed pad should not be listed even while it still colours the table it is linked to.');
    end;

    #endregion

    #region Setup once, update repeatedly

    // The restaurant view used to reload its whole layout every time the POS switched back into it, which is after every
    // sale. It now loads the layout once per session and afterwards asks only for what changes during service, handing
    // back the layout version it was given so the back end can tell whether it still holds a current one.
    //
    // Two things have to hold for that to be worth anything. Setup changes an operator makes elsewhere still have to
    // reach the floor plan, and ordinary service must not look like a setup change - a table turning red or a pad being
    // opened is the normal case, and if it invalidated the layout the view would be back to reloading after every sale.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ViewSetupRequested_LayoutPushed_CarriesALayoutVersion()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Loading the view hands the front end a version it can quote back later
        // [GIVEN] A restaurant with a table
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);

        // [WHEN] The view setup is requested
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [THEN] The layout payload carries a version
        _Assert.AreNotEqual('', LayoutVersion, 'The setup payload should carry a layout version.');

        // [THEN] And the operational payloads come with it, so one call leaves the view fully painted
        AssertAlsoQueued(WaiterPadDataMethodTok);
        AssertAlsoQueued(StatusRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ViewUpdatedWithTheCurrentVersion_Requested_LayoutNotPushedAgain()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] An update that finds nothing changed costs the statuses only, which is the point of the split
        // [GIVEN] A view that has been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [WHEN] The view is updated quoting the version it was given
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The statuses come back
        PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');

        // [THEN] But the layout does not
        AssertNotQueued(LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ViewUpdatedWithNoVersion_Requested_LayoutPushed()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] A caller holding no version gets the full layout, so an update is always safe to call first
        // [GIVEN] A restaurant with a table, and a front end that has never been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);

        // [WHEN] The view is updated without quoting any version
        RunViewUpdate(POSSession, FrontEnd, '');

        // [THEN] The full layout is pushed
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingRenamedAfterSetup_ViewUpdated_LayoutPushedWithANewVersion()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        Content: JsonObject;
        LayoutVersion: Text;
    begin
        // [SCENARIO] Renaming a table reaches a POS that is already showing the floor plan
        // [GIVEN] A view that has been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] The table is given a new caption afterwards
        Seating.Find();
        Seating.Description := 'Renamed after setup';
        Seating.Modify();

        // [WHEN] The view is updated quoting the version from before the rename
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again, carrying a version that is no longer the old one
        Content := PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
        _Assert.AreNotEqual(
            LayoutVersion, GetText(Content, 'layoutVersion'),
            'A layout pushed because it went stale should carry a new version, or the next update would reload it again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DecorationMovedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Moving a component that is not a table still reaches a POS already showing the floor plan
        //
        // This is the case the seating setup timestamp did not cover before: a wall or a plant lives only in
        // "NPR NPRE Location Layout", so rearranging one wrote no seating row and nothing was marked as changed.
        //
        // [GIVEN] A decoration on the floor plan, and a view that has been set up with it
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        CreateDecoration(LocationLayout, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] The decoration is dragged to a new position afterwards
        //
        // The position is written to the "Frontend Properties" blob and nothing else on the row changes. Asserting on a
        // caption change instead would leave this green even if the subscriber were later gated on ordinary fields,
        // which is the one change that would stop a real drag from invalidating anything.
        MoveComponent(LocationLayout, '{"x":420,"y":240}');

        // [WHEN] The view is updated quoting the version from before the move
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingMovedToAnotherLocationAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        SecondSeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Moving a table to another room reaches a POS that is already showing the floor plan
        //
        // A move is not a rename: it travels through the seating subscriber's second branch, the one that also bumps the
        // room the table came from, so the renamed-seating test cannot stand in for it.
        //
        // [GIVEN] A table in one room and a second room to move it to, with the view set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateSeatingLocation(SecondSeatingLocation, _Restaurant.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] The table is moved to the second room afterwards
        Seating.Find();
        Seating."Seating Location" := SecondSeatingLocation.Code;
        Seating.Modify();

        // [WHEN] The view is updated quoting the version from before the move
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingLocationAddedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        NewSeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Opening a new room reaches a POS that is already showing the floor plan
        //
        // A room arrives through its own subscriber rather than through a seating or a layout component, so none of the
        // other staleness tests exercises this path.
        //
        // [GIVEN] A view that has been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] A new room is added to the restaurant afterwards
        _LibraryRestaurant.CreateSeatingLocation(NewSeatingLocation, _Restaurant.Code);

        // [WHEN] The view is updated quoting the version from before the room existed
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantRenamedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        OtherSeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Renaming the restaurant reaches a POS that is already showing its floor plan
        //
        // The restaurant's name is the caption the view puts on it, and it is the one part of the payload that no
        // seating, room or component subscriber covers: it rides on the restaurant row's own modified stamp.
        //
        // Run against a restaurant of its own rather than the suite's, because renaming the shared one would change the
        // caption every other test in the file is set up around.
        //
        // [GIVEN] A restaurant with a table, and a view set up against it
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(OtherSeatingLocation, OtherRestaurant.Code);
        _LibraryRestaurant.CreateSeating(Seating, OtherSeatingLocation.Code);
        LayoutVersion := RunViewSetupFor(POSSession, FrontEnd, OtherRestaurant.Code);

        // [GIVEN] The restaurant is given a new name afterwards
        OtherRestaurant.Find();
        OtherRestaurant.Name := 'Renamed after setup';
        OtherRestaurant.Modify();

        // [WHEN] The view is updated quoting the version from before the rename
        RunViewUpdateFor(POSSession, FrontEnd, OtherRestaurant.Code, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StatusColourChangedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
        RecolouredHexTok: Label 'EE0000', Locked = true;
    begin
        // [SCENARIO] Recolouring a status reaches a POS already showing the floor plan, because the layout carries the status catalogue
        // [GIVEN] A view that has been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] A seating status is given a different colour afterwards
        SetSeatingStatusColour(_LibraryRestaurant.SeatingStatusReady(), RecolouredHexTok);

        // [WHEN] The view is updated quoting the version from before the recolour
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ColourRepaintedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
        OriginalHexTok: Label 'E40000', Locked = true;
        RepaintedHexTok: Label '00E400', Locked = true;
    begin
        // [SCENARIO] Repainting a colour reaches a POS already showing the floor plan, even though no status row changes
        //
        // The neighbouring status test edits the flow status as well as the colour, and the flow status alone moves the
        // token. Only this case reaches the colour half of the setup fingerprint.
        //
        // [GIVEN] A seating status painted in one colour, with the view set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetSeatingStatusColour(_LibraryRestaurant.SeatingStatusReady(), OriginalHexTok);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] That colour is repainted on the colour table, touching no flow status
        SetColourHexOnly(OriginalHexTok, RepaintedHexTok);

        // [WHEN] The view is updated quoting the version from before the repaint
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingWithoutALayoutRow_ViewSetupRequested_RowCreatedAndComponentCarriesAHashedColour()
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        Component: JsonObject;
        Components: JsonArray;
        Locations: JsonArray;
        LocationEntry: JsonObject;
        ComponentsToken: JsonToken;
        SeatingHexTok: Label 'E50000', Locked = true;
    begin
        // [SCENARIO] Setup materialises the layout row a table created outside the floor plan designer never got, and paints it
        //
        // Two things only setup does. The backfill is what makes a table created on the seating list appear at all, and
        // the layout payload is the only caller that asks for a colour with the leading hash the front end needs; every
        // status push asks without it.
        //
        // [GIVEN] A table created outside the designer, so it has no layout row
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        SetSeatingStatusColour(_LibraryRestaurant.SeatingStatusReady(), SeatingHexTok);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusReady());
        LocationLayout.SetRange(Code, Seating.Code);
        _Assert.IsTrue(LocationLayout.IsEmpty(), 'The fixture should start with no layout row for the seating.');

        // [WHEN] The view setup is requested
        RunViewSetup(POSSession, FrontEnd);

        // [THEN] The table now has a layout row, carrying its room rather than a blank one
        LocationLayout.FindFirst();
        _Assert.AreEqual(
            _SeatingLocation.Code, LocationLayout."Seating Location",
            'The backfilled layout row should be written complete, not blank and corrected afterwards.');
        _Assert.AreEqual(
            Seating."Seating No.", LocationLayout."Seating No.",
            'The backfilled row should carry the table number the floor plan labels the component with.');
        _Assert.AreEqual(
            Seating.Description, LocationLayout.Description,
            'The backfilled row should carry the table name the floor plan shows.');

        // [THEN] And the component the layout payload carries for it is coloured with a leading hash
        Locations := DrainedRequestArray(LayoutRefreshMethodTok, 'locations');
        if not FindObjectByValue(Locations, 'id', _SeatingLocation.Code, LocationEntry) then
            _Assert.Fail('The layout payload should carry the seating location under test.');
        LocationEntry.Get('components', ComponentsToken);
        Components := ComponentsToken.AsArray();
        if not FindObjectByValue(Components, 'id', Seating.Code, Component) then
            _Assert.Fail('The layout payload should carry a component for the backfilled table.');
        _Assert.AreEqual(
            '#' + SeatingHexTok, GetText(Component, 'color'),
            'The layout payload is the only caller asking for a hashed colour, so nothing else pins the leading hash.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FloorPlanEditedInAnotherRestaurant_ViewUpdated_LayoutNotPushed()
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        OtherSeating: Record "NPR NPRE Seating";
        OtherSeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Rearranging one restaurant's floor plan leaves tills showing another restaurant alone
        //
        // Only reachable with restaurant switching on, because a pinned POS has a single restaurant in scope and no
        // other one's edits can reach its token. That is the configuration the whole switch list exists for, and the
        // token has to tell the two restaurants apart without being moved by either one's unrelated row writes.
        //
        // [GIVEN] An operator who may switch between two restaurants, with the view set up on the first
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        _LibraryRestaurant.CreateSeatingLocation(OtherSeatingLocation, OtherRestaurant.Code);
        AllowRestaurantSwitch(true);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] A table is added to the other restaurant afterwards
        _LibraryRestaurant.CreateSeating(OtherSeating, OtherSeatingLocation.Code);

        // [WHEN] The view is updated for the first restaurant, quoting the version from before that edit
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The statuses come back
        PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');

        // [THEN] But the layout is not reloaded, because nothing in this restaurant changed
        AssertNotQueued(LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantSwitchListNarrowedAfterSetup_ViewUpdated_LayoutPushedAgain()
    var
        OtherRestaurant: Record "NPR NPRE Restaurant";
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Taking a restaurant off an operator's switch list reaches a POS that is already showing the view
        //
        // The restaurants the operator may switch to are part of the payload, so narrowing the list has to move the
        // token. A count and a newest-modified stamp cannot see this: swapping one restaurant for another leaves both
        // unchanged and the till would keep offering a restaurant it can no longer use.
        //
        // [GIVEN] An operator who may switch between two restaurants, with the view set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateRestaurant(OtherRestaurant, _ServFlowProfile.Code);
        AllowRestaurantSwitch(true);
        SetRestaurantSwitchFilter(StrSubstNo(SwitchFilterPairTok, _Restaurant.Code, OtherRestaurant.Code));
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] The second restaurant is taken off the list afterwards
        SetRestaurantSwitchFilter(_Restaurant.Code);

        // [WHEN] The view is updated quoting the version from before the list was narrowed
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The layout is pushed again
        PopFrontEndRequest(POSSession, LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TableTakenDuringService_ViewUpdated_LayoutNotPushed()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        LayoutVersion: Text;
    begin
        // [SCENARIO] Ordinary service does not look like a setup change, which is what keeps the layout from reloading after every sale
        // [GIVEN] A view that has been set up
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);

        // [GIVEN] The table is then taken: a pad is opened on it and its status changes
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        SetSeatingStatus(Seating, _LibraryRestaurant.SeatingStatusOccupied());

        // [WHEN] The view is updated quoting the version from before service started
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);

        // [THEN] The pad shows up in the operational payload
        _Assert.IsTrue(
            ArrayContainsValue(PopFrontEndArray(POSSession, WaiterPadDataMethodTok, 'waiterPads'), 'id', WaiterPad."No."),
            'The pad opened during service should reach the view.');

        // [THEN] But the layout is not reloaded for it
        AssertNotQueued(LayoutRefreshMethodTok);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ViewUpdatedRepeatedly_Requested_NoLayoutRowsWritten()
    var
        Seating: Record "NPR NPRE Seating";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        FingerprintAfterSetup: Text;
        LayoutVersion: Text;
    begin
        // [SCENARIO] Repeated updates read only, so switching back into the view no longer opens a write transaction
        //
        // The old refresh materialised a layout row for any seating that lacked one, on every single call. That work
        // belongs to setup: leaving it on the repeated path means every return from a sale writes to the database.
        //
        // This is a structural pin rather than a behavioural one, and worth being honest about: with the version
        // matching, the update never enters the layout push at all, so the backfill is unreachable by construction
        // rather than by guard. What it catches is a later change that moves the backfill back onto the unconditional
        // path. The positive control that the backfill still runs where it should lives in the setup test above.
        //
        // [GIVEN] A view that has been set up, so any missing layout rows have already been created
        Initialize();
        StartPOSSession(POSSession, FrontEnd);
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        LayoutVersion := RunViewSetup(POSSession, FrontEnd);
        FingerprintAfterSetup := LocationLayoutFingerprint();

        // [WHEN] The view is updated twice over
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);
        PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');
        RunViewUpdate(POSSession, FrontEnd, LayoutVersion);
        PopFrontEndObject(POSSession, StatusRefreshMethodTok, 'seating');

        // [THEN] Not one layout row was added, removed or touched
        _Assert.AreEqual(
            FingerprintAfterSetup, LocationLayoutFingerprint(),
            'Updating the view should not write to the layout table.');
    end;

    #endregion

    #region Front-end payload capture

    local procedure DrainFrontEndQueue(var POSSession: Codeunit "NPR POS Session")
    begin
        // The response queue lives on a SingleInstance codeunit, so anything an earlier test or an earlier setup step
        // pushed is still sitting there. Each test measures only what its own call queued.
        POSSession.PopResponseQueue();
    end;

    local procedure PopFrontEndRequest(var POSSession: Codeunit "NPR POS Session"; MethodName: Text) Content: JsonObject
    begin
        // The pop empties the queue, so the whole batch is kept: one entry point can queue more than one request -
        // RefreshWaiterPadData follows its own push with a RefreshStatus - and returning only the first match would
        // throw the rest away, leaving the follow-up push free to be deleted with every test still green.
        _LastDrainedRequests := POSSession.PopResponseQueue();
        if not FindDrainedRequest(MethodName, Content) then
            _Assert.Fail(StrSubstNo('The front end was never asked to run %1.', MethodName));
    end;

    local procedure FindDrainedRequest(MethodName: Text; var Content: JsonObject): Boolean
    var
        ContentToken: JsonToken;
        MethodToken: JsonToken;
        RequestToken: JsonToken;
        RequestIndex: Integer;
    begin
        for RequestIndex := 0 to _LastDrainedRequests.Count() - 1 do begin
            _LastDrainedRequests.Get(RequestIndex, RequestToken);
            if RequestToken.AsObject().Get('Method', MethodToken) then
                if MethodToken.AsValue().AsText() = MethodName then begin
                    RequestToken.AsObject().Get('Content', ContentToken);
                    Content := ContentToken.AsObject();
                    exit(true);
                end;
        end;
        exit(false);
    end;

    local procedure AssertAlsoQueued(MethodName: Text)
    var
        Content: JsonObject;
    begin
        if not FindDrainedRequest(MethodName, Content) then
            _Assert.Fail(StrSubstNo('The same batch should also have asked the front end to run %1.', MethodName));
    end;

    local procedure DrainedRequest(MethodName: Text) Content: JsonObject
    begin
        // Reads the batch an earlier pop already drained, for a test that needs a second look at the same push. Popping
        // again would empty the queue and find nothing.
        if not FindDrainedRequest(MethodName, Content) then
            _Assert.Fail(StrSubstNo('The batch should have asked the front end to run %1.', MethodName));
    end;

    local procedure DrainedRequestArray(MethodName: Text; PropertyName: Text) Values: JsonArray
    var
        PropertyToken: JsonToken;
    begin
        if not DrainedRequest(MethodName).Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The %1 payload carried no %2 array.', MethodName, PropertyName));
        exit(PropertyToken.AsArray());
    end;

    local procedure AssertNotQueued(MethodName: Text)
    var
        Content: JsonObject;
    begin
        // Reads the batch an earlier pop in the same test already drained, so callers must pop something they do expect
        // first. An absence assertion against an empty batch passes for every reason, including the ones it is meant to
        // catch.
        if FindDrainedRequest(MethodName, Content) then
            _Assert.Fail(StrSubstNo('The batch should not have asked the front end to run %1.', MethodName));
    end;

    local procedure RunViewSetup(var POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management") LayoutVersion: Text
    begin
        exit(RunViewSetupFor(POSSession, FrontEnd, _Restaurant.Code));
    end;

    local procedure RunViewSetupFor(var POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]) LayoutVersion: Text
    var
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
    begin
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshRestaurantViewSetup(FrontEnd, RestaurantCode);
        exit(GetText(PopFrontEndRequest(POSSession, LayoutRefreshMethodTok), 'layoutVersion'));
    end;

    local procedure RunViewUpdate(var POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; KnownLayoutVersion: Text)
    begin
        RunViewUpdateFor(POSSession, FrontEnd, _Restaurant.Code, KnownLayoutVersion);
    end;

    local procedure RunViewUpdateFor(var POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; RestaurantCode: Code[20]; KnownLayoutVersion: Text)
    var
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
    begin
        DrainFrontEndQueue(POSSession);
        FrontendAssistant.RefreshRestaurantViewUpdate(FrontEnd, RestaurantCode, KnownLayoutVersion);
    end;

    local procedure CreateDecoration(var LocationLayout: Record "NPR NPRE Location Layout"; SeatingLocationCode: Code[10])
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        // A component with no seating behind it, the way the layout designer stores a wall or a plant.
        LocationLayout.Init();
        LocationLayout.Code :=
            CopyStr(
                LibraryUtility.GenerateRandomCode(LocationLayout.FieldNo(Code), Database::"NPR NPRE Location Layout"),
                1, MaxStrLen(LocationLayout.Code));
        LocationLayout.Type := 'wall';
        LocationLayout."Seating Location" := SeatingLocationCode;
        LocationLayout.Description := 'Decoration';
        LocationLayout.Insert();
    end;

    local procedure LocationLayoutFingerprint(): Text
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        LastModifiedAt: DateTime;
        FingerprintFormatTok: Label '%1/%2', Locked = true;
    begin
        // Row count as well as timestamp: a count alone misses an edit in place, and a timestamp alone misses a row
        // being added and another removed.
        // Unfiltered on purpose: a stray write anywhere in the table is as much a regression as one in this test's own
        // room, and the suite shares a restaurant.
        if LocationLayout.FindSet() then
            repeat
                if LocationLayout.SystemModifiedAt > LastModifiedAt then
                    LastModifiedAt := LocationLayout.SystemModifiedAt;
            until LocationLayout.Next() = 0;
        exit(StrSubstNo(FingerprintFormatTok, LocationLayout.Count(), Format(LastModifiedAt, 0, 9)));
    end;

    local procedure PopFrontEndArray(var POSSession: Codeunit "NPR POS Session"; MethodName: Text; PropertyName: Text) Values: JsonArray
    var
        Content: JsonObject;
        PropertyToken: JsonToken;
    begin
        Content := PopFrontEndRequest(POSSession, MethodName);
        if not Content.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The %1 payload carried no %2 array.', MethodName, PropertyName));
        exit(PropertyToken.AsArray());
    end;

    local procedure PopFrontEndObject(var POSSession: Codeunit "NPR POS Session"; MethodName: Text; PropertyName: Text) Value: JsonObject
    var
        Content: JsonObject;
        PropertyToken: JsonToken;
    begin
        Content := PopFrontEndRequest(POSSession, MethodName);
        if not Content.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The %1 payload carried no %2 object.', MethodName, PropertyName));
        exit(PropertyToken.AsObject());
    end;

    local procedure FindObjectByValue(Values: JsonArray; PropertyName: Text; PropertyValue: Text; var Found: JsonObject): Boolean
    var
        PropertyToken: JsonToken;
        ValueToken: JsonToken;
        ValueIndex: Integer;
    begin
        for ValueIndex := 0 to Values.Count() - 1 do begin
            Values.Get(ValueIndex, ValueToken);
            if ValueToken.AsObject().Get(PropertyName, PropertyToken) then
                if PropertyToken.AsValue().AsText() = PropertyValue then begin
                    Found := ValueToken.AsObject();
                    exit(true);
                end;
        end;
        exit(false);
    end;

    local procedure ArrayContainsValue(Values: JsonArray; PropertyName: Text; PropertyValue: Text): Boolean
    var
        Found: JsonObject;
    begin
        exit(FindObjectByValue(Values, PropertyName, PropertyValue, Found));
    end;

    local procedure GetText(Source: JsonObject; PropertyName: Text): Text
    var
        PropertyToken: JsonToken;
    begin
        // Failing rather than returning '': a missing key is a payload that lost a field, and reporting it as a wrong
        // value sends the reader looking at the value that was written instead of the key that was not.
        if not Source.Get(PropertyName, PropertyToken) then
            _Assert.Fail(StrSubstNo('The payload carried no %1.', PropertyName));
        exit(PropertyToken.AsValue().AsText());
    end;

    local procedure AssertStatusAndColour(Statuses: JsonObject; SeatingCode: Code[20]; ExpectedStatus: Code[10]; ExpectedHex: Text; SeatingDescription: Text)
    var
        SeatingToken: JsonToken;
        StatusEntry: JsonObject;
    begin
        if not Statuses.Get(SeatingCode, SeatingToken) then
            _Assert.Fail(StrSubstNo('The status payload carried no entry for the %1.', SeatingDescription));
        StatusEntry := SeatingToken.AsObject();
        _Assert.AreEqual(
            ExpectedStatus, GetText(StatusEntry, 'status'),
            StrSubstNo('The %1 should be reported in its own status.', SeatingDescription));
        _Assert.AreEqual(
            ExpectedHex, GetText(StatusEntry, 'color'),
            StrSubstNo('The %1 should be reported with the colour configured for its status.', SeatingDescription));
    end;

    #endregion

    local procedure SetSeatingStatusColour(StatusCode: Code[10]; RGBHexCode: Code[6])
    begin
        // A status only contributes a colour when it is flagged as available in the front end.
        SetFlowStatusColour("NPR NPRE Status Object"::Seating, StatusCode, RGBHexCode, 10, true);
    end;

    local procedure SetFlowStatusColour(StatusObject: Enum "NPR NPRE Status Object"; StatusCode: Code[10]; RGBHexCode: Code[6]; ColorPriority: Integer; AvailableInFrontEnd: Boolean)
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
        ColorDescription: Text[30];
    begin
        ColorDescription := CopyStr('TEST ' + RGBHexCode, 1, MaxStrLen(ColorDescription));
        if not ColorTable.Get(ColorDescription) then begin
            ColorTable.Init();
            ColorTable.Description := ColorDescription;
            ColorTable.Insert();
        end;
        ColorTable."RGB Color Code (Hex)" := RGBHexCode;
        ColorTable.Modify();

        // Every field the resolution rules read is written here rather than left as it was, because the flow statuses
        // are shared across the whole suite and a test that only set some of them would inherit the rest from whichever
        // test happened to run before it.
        FlowStatus.Get(StatusCode, StatusObject);
        FlowStatus."Available in Front-End" := AvailableInFrontEnd;
        FlowStatus.Color := ColorDescription;
        FlowStatus."Status Color Priority" := ColorPriority;
        FlowStatus.Modify();
    end;

    local procedure SetFlowStatusOrder(StatusObject: Enum "NPR NPRE Status Object"; StatusCode: Code[10]; FlowOrder: Integer)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        FlowStatus.Get(StatusCode, StatusObject);
        FlowStatus."Flow Order" := FlowOrder;
        FlowStatus.Modify();
    end;

    local procedure AllowRestaurantSwitch(Allowed: Boolean)
    var
        UserSetup: Record "User Setup";
    begin
        // The suite has no User Setup row of its own, so every other test runs on the pinned path where a single
        // restaurant is in scope. The switch-enabled path is a different shape and needs this to be reached at all.
        if not UserSetup.Get(UserId()) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR Allow Restaurant Switch" := Allowed;
        UserSetup."NPR Restaurant Switch Filter" := '';
        UserSetup.Modify();
    end;

    local procedure SetRestaurantSwitchFilter(SwitchFilter: Text)
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId());
        UserSetup."NPR Restaurant Switch Filter" := CopyStr(SwitchFilter, 1, MaxStrLen(UserSetup."NPR Restaurant Switch Filter"));
        UserSetup.Modify();
    end;

    local procedure SetWaiterPadServingStep(var WaiterPad: Record "NPR NPRE Waiter Pad"; ServingStepCode: Code[10])
    begin
        // Pads created by the library carry a blank serving step, which is why the resolver's meal-flow branch stays
        // dark unless a test sets one.
        WaiterPad.Find();
        WaiterPad."Serving Step Code" := ServingStepCode;
        WaiterPad.Modify();
    end;

    local procedure SetColourHexOnly(RGBHexCode: Code[6]; NewRGBHexCode: Code[6])
    var
        ColorTable: Record "NPR NPRE Color Table";
        ColorDescription: Text[30];
    begin
        // Repaints an existing colour without touching any flow status, which is the edit an operator makes on the
        // colour table page and the only thing that moves the colour half of the setup fingerprint on its own.
        ColorDescription := CopyStr('TEST ' + RGBHexCode, 1, MaxStrLen(ColorDescription));
        ColorTable.Get(ColorDescription);
        ColorTable."RGB Color Code (Hex)" := NewRGBHexCode;
        ColorTable.Modify();
    end;

    local procedure MoveComponent(var LocationLayout: Record "NPR NPRE Location Layout"; PositionJson: Text)
    var
        OutStr: OutStream;
    begin
        // A real drag writes the blob, not an ordinary field. Nothing else in the row changes, which is exactly the
        // case an ordinary-field gate on the modify subscriber would stop reporting.
        LocationLayout.Find();
        LocationLayout."Frontend Properties".CreateOutStream(OutStr);
        OutStr.Write(PositionJson);
        LocationLayout.Modify();
    end;

    local procedure SetSeatingStatus(var Seating: Record "NPR NPRE Seating"; StatusCode: Code[10])
    begin
        // Assigned rather than routed through "NPR NPRE Seating Mgt.".SetSeatingStatus, which would also recompute
        // Blocked and raise OnAfterChangeSeatingStatus. These tests want a named status on the table and nothing else;
        // it is not that the managed route would refuse them.
        Seating.Find();
        Seating.Status := StatusCode;
        Seating.Modify();
    end;

    local procedure SetWaiterPadStatus(var WaiterPad: Record "NPR NPRE Waiter Pad"; StatusCode: Code[10])
    begin
        WaiterPad.Find();
        WaiterPad.Status := StatusCode;
        WaiterPad.Modify();
    end;

    /// <summary>
    /// Compares a pushed colour against the table helper it was lifted from. Those helpers have no production callers
    /// left now that the resolver answers instead, so this assertion is the reason they are still here: deleting them
    /// as dead code would take the only independent check that the copy still agrees with the original.
    /// </summary>
    local procedure AssertSeatingColourMatchesHelper(Statuses: JsonObject; var Seating: Record "NPR NPRE Seating")
    var
        SeatingToken: JsonToken;
    begin
        if not Statuses.Get(Seating.Code, SeatingToken) then
            _Assert.Fail('The status payload carried no entry for the seating under test.');
        Seating.Find();
        _Assert.AreEqual(
            Seating.RGBColorCodeHex(false), GetText(SeatingToken.AsObject(), 'color'),
            'The pushed colour should be the one the seating record resolves for itself.');
    end;

    local procedure StartPOSSession(var POSSession: Codeunit "NPR POS Session"; var FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        _LibraryPOSMock.InitializePOSSession(POSSession, _POSUnit);
        POSSession.GetFrontEnd(FrontEnd, true);
    end;

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

        // Manual close keeps the pads these tests create from settling themselves before the payload is read.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // A fresh seating location per test, so one test's tables never show up in another's payload.
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);

        // User Setup is a real table and survives the test that wrote it, so the two switch-enabled tests would
        // otherwise leave every test after them on a different code path. Back to pinned unless a test asks otherwise.
        AllowRestaurantSwitch(false);
        Commit();
    end;
}
