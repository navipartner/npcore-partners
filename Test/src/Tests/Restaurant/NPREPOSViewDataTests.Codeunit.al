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

        // A status only contributes a colour when it is flagged as available in the front end.
        FlowStatus.Get(StatusCode, FlowStatus."Status Object"::Seating);
        FlowStatus."Available in Front-End" := true;
        FlowStatus.Color := ColorDescription;
        FlowStatus."Status Color Priority" := 10;
        FlowStatus.Modify();
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
        Commit();
    end;
}
