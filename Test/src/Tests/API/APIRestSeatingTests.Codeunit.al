#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85239 "NPR APIRest Seating Tests"
{
    // [FEATURE] GET /restaurant/:restaurantId/seating and GET /restaurant/:restaurantId/seating/:seatingId

    Subtype = Test;

    var
        _OtherRestaurant: Record "NPR NPRE Restaurant";
        _Restaurant: Record "NPR NPRE Restaurant";
        _RestaurantNoLocations: Record "NPR NPRE Restaurant";
        _OtherLocationSeating: Record "NPR NPRE Seating";
        _Seating1: Record "NPR NPRE Seating";
        _Seating2: Record "NPR NPRE Seating";
        _Seating3: Record "NPR NPRE Seating";
        _OtherSeatingLocation: Record "NPR NPRE Seating Location";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_ForRestaurant_ReturnsOnlyOwnSeatings()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        AllOwn: Boolean;
        FoundOther: Boolean;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        i: Integer;
        DataArray: JsonArray;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        SeatingObj: JsonObject;
        JToken: JsonToken;
        Code: Text;
    begin
        // [SCENARIO] GET /restaurant/{id}/seating returns only seatings of locations belonging to the restaurant
        Initialize();

        QueryParams.Add('pageSize', '100');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /restaurant/{id}/seating should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Contains('morePages'), 'Envelope should contain morePages');
        Assert.IsTrue(ResponseBody.Contains('nextPageKey'), 'Envelope should contain nextPageKey');
        Assert.IsTrue(ResponseBody.Contains('nextPageURL'), 'Envelope should contain nextPageURL');
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Envelope should contain data array');

        DataArray := JToken.AsArray();
        Assert.IsTrue(DataArray.Count() >= 3, 'Should contain at least the three primary-location seatings');

        AllOwn := true;
        for i := 0 to DataArray.Count() - 1 do begin
            DataArray.Get(i, JToken);
            SeatingObj := JToken.AsObject();
            SeatingObj.Get('locationCode', JToken);
            if JToken.AsValue().AsText() <> _SeatingLocation.Code then
                AllOwn := false;
            SeatingObj.Get('code', JToken);
            Code := JToken.AsValue().AsText();
            if Code = _OtherLocationSeating.Code then
                FoundOther := true;
        end;

        Assert.IsTrue(AllOwn, 'All returned seatings must belong to a location of the path restaurant');
        Assert.IsFalse(FoundOther, 'Other-restaurant seating must not appear');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_FilterByLocationId_ReturnsOnlyMatching()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        AllMatch: Boolean;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        i: Integer;
        DataArray: JsonArray;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        SeatingObj: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] GET /restaurant/{id}/seating?locationId={guid} returns only seatings belonging to that location
        Initialize();

        QueryParams.Add('locationId', FormatGuid(_SeatingLocation.SystemId));
        QueryParams.Add('pageSize', '100');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /restaurant/{id}/seating?locationId should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('data', JToken);
        DataArray := JToken.AsArray();
        Assert.IsTrue(DataArray.Count() >= 3, 'Filtered list should contain all primary-location seatings');

        AllMatch := true;
        for i := 0 to DataArray.Count() - 1 do begin
            DataArray.Get(i, JToken);
            SeatingObj := JToken.AsObject();
            SeatingObj.Get('locationCode', JToken);
            if JToken.AsValue().AsText() <> _SeatingLocation.Code then
                AllMatch := false;
        end;
        Assert.IsTrue(AllMatch, 'All returned seatings must belong to the filtered location');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_LocationFromOtherRestaurant_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] Passing a locationId that belongs to a different restaurant returns 404
        Initialize();

        QueryParams.Add('locationId', FormatGuid(_OtherSeatingLocation.SystemId));
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cross-restaurant locationId filter should not succeed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_UnknownRestaurantId_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] Unknown restaurantId returns not found
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(CreateGuid()) + '/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Unknown restaurantId should not succeed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_MalformedRestaurantId_ReturnsBadRequest()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] Malformed restaurantId in path returns 400
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/not-a-guid/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Malformed restaurantId should not succeed');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Should return 400 for malformed Guid');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_UnknownLocationId_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] Unknown locationId returns not found
        Initialize();

        QueryParams.Add('locationId', FormatGuid(CreateGuid()));
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Unknown locationId should not succeed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_MalformedLocationId_ReturnsBadRequest()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] Malformed locationId query param returns 400
        Initialize();

        QueryParams.Add('locationId', 'not-a-guid');
        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Malformed locationId should not succeed');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Should return 400 for malformed Guid');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_RestaurantWithNoLocations_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] Restaurant without any seating locations returns 404
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_RestaurantNoLocations.SystemId) + '/seating', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /restaurant/{restaurant-with-no-locations}/seating should return not found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeatings_Pagination_WalksAllPages()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        MorePages: Boolean;
        SeenCodes: Dictionary of [Text, Boolean];
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        i: Integer;
        SafetyCounter: Integer;
        DataArray: JsonArray;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        PageKey: Text;
    begin
        // [SCENARIO] Pagination with pageSize=1 walks all 3 seatings without duplicates
        Initialize();

        repeat
            Clear(QueryParams);
            QueryParams.Add('locationId', FormatGuid(_SeatingLocation.SystemId));
            QueryParams.Add('pageSize', '1');
            if PageKey <> '' then
                QueryParams.Add('pageKey', PageKey);

            Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating', Body, QueryParams, Headers);
            Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Each page should succeed');

            ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
            ResponseBody.Get('data', JToken);
            DataArray := JToken.AsArray();

            for i := 0 to DataArray.Count() - 1 do begin
                DataArray.Get(i, JToken);
                JToken.AsObject().Get('code', JToken);
                SeenCodes.Set(JToken.AsValue().AsText(), true);
            end;

            ResponseBody.Get('morePages', JToken);
            MorePages := JToken.AsValue().AsBoolean();
            ResponseBody.Get('nextPageKey', JToken);
            PageKey := JToken.AsValue().AsText();

            SafetyCounter += 1;
            Assert.IsTrue(SafetyCounter <= 10, 'Pagination should terminate within a reasonable number of pages');
        until not MorePages;

        Assert.IsTrue(SeenCodes.ContainsKey(_Seating1.Code), 'Pagination should visit seating 1');
        Assert.IsTrue(SeenCodes.ContainsKey(_Seating2.Code), 'Pagination should visit seating 2');
        Assert.IsTrue(SeenCodes.ContainsKey(_Seating3.Code), 'Pagination should visit seating 3');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeating_BySystemId_ReturnsSeating()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] GET /restaurant/{id}/seating/{id} returns the matching seating with expected fields
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating/' + FormatGuid(_Seating1.SystemId), Body, QueryParams, Headers);

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /restaurant/{id}/seating/{id} should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('id', JToken);
        Assert.AreEqual(FormatGuid(_Seating1.SystemId), JToken.AsValue().AsText(), 'id should match SystemId');

        ResponseBody.Get('code', JToken);
        Assert.AreEqual(_Seating1.Code, JToken.AsValue().AsText(), 'code should match');

        ResponseBody.Get('locationCode', JToken);
        Assert.AreEqual(_SeatingLocation.Code, JToken.AsValue().AsText(), 'locationCode should match seating location');

        ResponseBody.Get('locationId', JToken);
        Assert.AreEqual(FormatGuid(_SeatingLocation.SystemId), JToken.AsValue().AsText(), 'locationId should resolve to location SystemId');

        ResponseBody.Get('capacity', JToken);
        Assert.AreEqual(4, JToken.AsValue().AsInteger(), 'capacity should be 4 (set by test library)');

        Assert.IsTrue(ResponseBody.Contains('seatingNo'), 'Response should contain seatingNo');
        Assert.IsTrue(ResponseBody.Contains('description'), 'Response should contain description');
        Assert.IsTrue(ResponseBody.Contains('fixedCapacity'), 'Response should contain fixedCapacity');
        Assert.IsTrue(ResponseBody.Contains('minPartySize'), 'Response should contain minPartySize');
        Assert.IsTrue(ResponseBody.Contains('maxPartySize'), 'Response should contain maxPartySize');
        Assert.IsTrue(ResponseBody.Contains('status'), 'Response should contain status');
        Assert.IsTrue(ResponseBody.Contains('blocked'), 'Response should contain blocked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeating_WrongRestaurant_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] Looking up a seating under a restaurant it does not belong to returns 404
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_OtherRestaurant.SystemId) + '/seating/' + FormatGuid(_Seating1.SystemId), Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cross-restaurant seating lookup should not succeed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeating_UnknownSeatingId_ReturnsNotFound()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
    begin
        // [SCENARIO] GET /restaurant/{id}/seating/{unknown-guid} returns not found
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Unknown seatingId should not succeed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSeating_MalformedSeatingId_ReturnsBadRequest()
    var
        Assert: Codeunit Assert;
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] GET /restaurant/{id}/seating/{not-a-guid} returns 400
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('GET', '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/seating/not-a-guid', Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Malformed seatingId should not succeed');
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'Should return 400 for malformed Guid');
    end;

    local procedure Initialize()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);

        LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        LibraryRestaurant.CreateSeating(_Seating1, _SeatingLocation.Code);
        LibraryRestaurant.CreateSeating(_Seating2, _SeatingLocation.Code);
        LibraryRestaurant.CreateSeating(_Seating3, _SeatingLocation.Code);

        LibraryRestaurant.CreateRestaurant(_OtherRestaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(_OtherSeatingLocation, _OtherRestaurant.Code);
        LibraryRestaurant.CreateSeating(_OtherLocationSeating, _OtherSeatingLocation.Code);

        LibraryRestaurant.CreateRestaurant(_RestaurantNoLocations, ServFlowProfile.Code);

        _Initialized := true;
        Commit();
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
