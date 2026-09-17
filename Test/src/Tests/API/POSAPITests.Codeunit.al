#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85157 "NPR POS API Tests"
{
    // [FEATURE] POS API end-to-end tests

    Subtype = Test;

    var
        _Initialized: Boolean;
        _RestaurantInitialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _Item2: Record Item;
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _EFTPaymentMethod: Record "NPR POS Payment Method";
        _Salesperson: Record "Salesperson/Purchaser";
        _Seating: Record "NPR NPRE Seating";
        _ItemAddon: Record "NPR NpIa Item AddOn";
        _AddonItem: Record Item;
        _AddonInitialized: Boolean;
        _Menu: Record "NPR NPRE Menu";
        _MenuInitialized: Boolean;
        _VisaPaymentMethod: Record "NPR POS Payment Method";
        _MastercardPaymentMethod: Record "NPR POS Payment Method";
        _EFTMappingInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_AddLine_PayCash_Complete_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Text;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        // [SCENARIO] Happy path - Create sale, add item line, pay with cash, complete sale
        Initialize();

        // [GIVEN] A new sale ID
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        // [WHEN] Create a new sale
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Sale created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('saleId', JToken), 'Response should contain saleId');
        Assert.AreEqual(FormatGuid(SaleId), JToken.AsValue().AsText(), 'SaleId should match');

        // [WHEN] Add a sale line with item
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add a cash payment line for the full amount
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] Payment line created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Complete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Sale completed successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');

        // [THEN] POS Entry is created
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        ReceiptNo := JToken.AsValue().AsText();
        POSEntry.SetRange("Document No.", ReceiptNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should be created');
        Assert.AreEqual(_POSUnit."No.", POSEntry."POS Unit No.", 'POS Entry should have correct POS Unit');
        Assert.AreEqual(_Item."Unit Price", POSEntry."Amount Incl. Tax & Round", 'POS Entry should have the fully paid total');

        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_WithEntraAppTimeZone_SetsSaleAndEntryDateTimesInLocalTime()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryTimeZone: Codeunit "NPR Library - Time Zone";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Text;
        POSSale: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSBinEntry: Record "NPR POS Bin Entry";
        CreateStartedAt: DateTime;
        CreateEndedAt: DateTime;
        CompleteStartedAt: DateTime;
        CompleteEndedAt: DateTime;
        SaleDate: Date;
        SaleStartTime: Time;
    begin
        // [SCENARIO] POS API sale timestamps use the calling Entra application's time zone for legacy Date/Time fields.
        Initialize();

        // [GIVEN] The Entra application authenticating the request has an explicit time zone different from UTC.
        LibraryTimeZone.SetSessionEntraAppTimeZone();

        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        // [WHEN] Create a new sale through the POS API.
        Body.Add('posUnit', _POSUnit."No.");
        CreateStartedAt := CurrentDateTime();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        CreateEndedAt := CurrentDateTime();

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
        Assert.IsTrue(POSSale.GetBySystemId(SaleId), 'POS Sale should exist');
        SaleDate := POSSale.Date;
        SaleStartTime := POSSale."Start Time";

        // [WHEN] Add a sale line, pay in full, and complete the sale.
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        Clear(Body);
        CompleteStartedAt := CurrentDateTime();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        CompleteEndedAt := CurrentDateTime();

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        ReceiptNo := JToken.AsValue().AsText();
        POSEntry.SetRange("Document No.", ReceiptNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should be created');
        POSBinEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSBinEntry.SetRange(Type, POSBinEntry.Type::INPAYMENT);
        Assert.IsTrue(POSBinEntry.FindFirst(), 'POS Bin Entry for the payment line should be created');

        LibraryTimeZone.ClearSessionEntraAppTimeZone();

        // [THEN] The POS Sale, POS Entry and POS Bin Entry stamps all sit on the Entra application's local timeline.
        LibraryTimeZone.AssertDateTimePartsInTimeZoneRange(SaleDate, SaleStartTime, CreateStartedAt, CreateEndedAt, 'POS Sale start timestamp');
        Assert.AreEqual(SaleDate, POSEntry."Entry Date", 'POS Entry date should match the local POS Sale date');
        Assert.AreEqual(SaleStartTime, POSEntry."Starting Time", 'POS Entry starting time should match the local POS Sale start time');
        LibraryTimeZone.AssertTimeInTimeZoneRange(POSEntry."Ending Time", CompleteStartedAt, CompleteEndedAt, 'POS Entry ending timestamp');
        LibraryTimeZone.AssertDateTimePartsInTimeZoneRange(POSBinEntry."Transaction Date", POSBinEntry."Transaction Time", CompleteStartedAt, CompleteEndedAt, 'POS Bin Entry transaction timestamp');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLocalDateTime_ConfiguredRowNonWebservice_ReturnsSessionTime()
    var
        LibraryTimeZone: Codeunit "NPR Library - Time Zone";
        TimeZoneMgt: Codeunit "NPR Time Zone Mgt.";
        Assert: Codeunit Assert;
        SourceDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
    begin
        // [SCENARIO] A configured Entra application does not affect non-webservice sessions.
        LibraryTimeZone.SetEntraAppTimeZone();
        SourceDateTime := CreateDateTime(20260818D, 123456.789T);

        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        LibraryTimeZone.ClearSessionEntraAppTimeZone();

        Assert.AreEqual(DT2Date(SourceDateTime), LocalDate, 'Non-webservice session date should remain session-local.');
        Assert.AreEqual(DT2Time(SourceDateTime), LocalTime, 'Non-webservice session time should remain session-local.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLocalDateTime_BlankTimeZone_ReturnsSessionTime()
    var
        LibraryTimeZone: Codeunit "NPR Library - Time Zone";
        TimeZoneMgt: Codeunit "NPR Time Zone Mgt.";
        Assert: Codeunit Assert;
        SourceDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
    begin
        // [SCENARIO] A blank Entra application time zone preserves the existing session-local behavior.
        LibraryTimeZone.SetSessionEntraAppTimeZone('');
        SourceDateTime := CreateDateTime(20260818D, 123456.789T);

        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        LibraryTimeZone.ClearSessionEntraAppTimeZone();

        Assert.AreEqual(DT2Date(SourceDateTime), LocalDate, 'Blank time zone date should remain session-local.');
        Assert.AreEqual(DT2Time(SourceDateTime), LocalTime, 'Blank time zone time should remain session-local.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetLocalDateTime_ConfiguredTimeZone_PreservesMilliseconds()
    var
        LibraryTimeZone: Codeunit "NPR Library - Time Zone";
        TimeZoneMgt: Codeunit "NPR Time Zone Mgt.";
        Assert: Codeunit Assert;
        SourceDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
        ZeroMilliseconds: Integer;
        OneDigitMilliseconds: Integer;
        TwoDigitMilliseconds: Integer;
        FullMilliseconds: Integer;
    begin
        // [SCENARIO] Time-zone conversion preserves zero, trimmed and full millisecond precision.
        LibraryTimeZone.SetSessionEntraAppTimeZone();

        SourceDateTime := CreateDateTime(20260818D, 123456T);
        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        ZeroMilliseconds := LocalTime.Millisecond();

        SourceDateTime := CreateDateTime(20260818D, 123456.500T);
        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        OneDigitMilliseconds := LocalTime.Millisecond();

        SourceDateTime := CreateDateTime(20260818D, 123456.780T);
        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        TwoDigitMilliseconds := LocalTime.Millisecond();

        SourceDateTime := CreateDateTime(20260818D, 123456.789T);
        TimeZoneMgt.GetLocalDateTime(SourceDateTime, LocalDate, LocalTime);
        FullMilliseconds := LocalTime.Millisecond();

        LibraryTimeZone.ClearSessionEntraAppTimeZone();

        Assert.AreEqual(0, ZeroMilliseconds, 'Converted local time should preserve zero milliseconds.');
        Assert.AreEqual(500, OneDigitMilliseconds, 'Converted local time should preserve one significant millisecond digit.');
        Assert.AreEqual(780, TwoDigitMilliseconds, 'Converted local time should preserve two significant millisecond digits.');
        Assert.AreEqual(789, FullMilliseconds, 'Converted local time should preserve milliseconds.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListEntries_WithLinesParameter_ControlsReturnedLines()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Text;
        EntriesArray: JsonArray;
        EntryToken: JsonToken;
        EntryObject: JsonObject;
        SalesLines: JsonArray;
        PaymentLines: JsonArray;
    begin
        // [SCENARIO] List POS entries returns lines only when withLines=true is requested
        Initialize();

        // [GIVEN] A completed sale that created a POS entry
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        ReceiptNo := JToken.AsValue().AsText();

        // [WHEN] List entries without withLines
        Clear(QueryParams);
        QueryParams.Add('documentNo', ReceiptNo);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry', Body, QueryParams, Headers);

        // [THEN] The entry is returned without line arrays
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'List entries without withLines should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Response should contain data');
        EntriesArray := JToken.AsArray();
        Assert.AreEqual(1, EntriesArray.Count(), 'Document filter should return exactly one entry');
        EntriesArray.Get(0, EntryToken);
        EntryObject := EntryToken.AsObject();
        Assert.IsFalse(EntryObject.Get('salesLines', JToken), 'salesLines should be omitted by default');
        Assert.IsFalse(EntryObject.Get('paymentLines', JToken), 'paymentLines should be omitted by default');
        Assert.IsFalse(EntryObject.Get('taxLines', JToken), 'taxLines should be omitted by default');

        // [WHEN] List entries with withLines=true
        Clear(QueryParams);
        QueryParams.Add('documentNo', ReceiptNo);
        QueryParams.Add('withLines', 'true');
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry', Body, QueryParams, Headers);

        // [THEN] The entry includes serialized lines
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'List entries with withLines should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Response should contain data');
        EntriesArray := JToken.AsArray();
        Assert.AreEqual(1, EntriesArray.Count(), 'Document filter should still return exactly one entry');
        EntriesArray.Get(0, EntryToken);
        EntryObject := EntryToken.AsObject();
        Assert.IsTrue(EntryObject.Get('salesLines', JToken), 'salesLines should be returned when withLines=true');
        SalesLines := JToken.AsArray();
        Assert.AreEqual(1, SalesLines.Count(), 'Completed sale should expose one sales line');
        Assert.IsTrue(EntryObject.Get('paymentLines', JToken), 'paymentLines should be returned when withLines=true');
        PaymentLines := JToken.AsArray();
        Assert.AreEqual(1, PaymentLines.Count(), 'Completed sale should expose one payment line');
        Assert.IsTrue(EntryObject.Get('taxLines', JToken), 'taxLines should be returned when withLines=true');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleSearchAliases_ReturnAllSalesAsArrays()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        SearchPOSUnit: Record "NPR POS Unit";
        Response: JsonObject;
        Body: JsonObject;
        ResponseBody: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Endpoints: List of [Text];
        Endpoint: Text;
    begin
        // [SCENARIO] The two POS sale search routes are array-returning aliases
        Initialize();

        NPRLibraryPOSMasterData.CreatePOSUnit(SearchPOSUnit, _POSStore.Code, _POSStore."POS Posting Profile");
        InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-A', 'CORE1089-USER-A');
        InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-Z', 'CORE1089-USER-Z');
        Commit();

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Clear(QueryParams);
            QueryParams.Add('posunit', SearchPOSUnit."No.");

            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);

            Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), Endpoint + ' should succeed');
            ResponseBody := LibraryNPRetailAPI.GetResponseBodyAsArray(Response);
            Assert.AreEqual(2, ResponseBody.Count(), Endpoint + ' should return every matching sale as an array');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleSearchAliases_UserFiltersReturnMatchingSaleArrays()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        SearchPOSUnit: Record "NPR POS Unit";
        Response: JsonObject;
        ResponseBody: JsonArray;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Endpoints: List of [Text];
        Endpoint: Text;
        ExplicitUserSaleId: Guid;
        CurrentUserSaleId: Guid;
        CurrentUserId: Code[50];
    begin
        // [SCENARIO] Both aliases apply explicit-user and current-user filters
        Initialize();

        CurrentUserId := CopyStr(UserId, 1, MaxStrLen(CurrentUserId));
        NPRLibraryPOSMasterData.CreatePOSUnit(SearchPOSUnit, _POSStore.Code, _POSStore."POS Posting Profile");
        ExplicitUserSaleId := InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-A', 'CORE1089-EXPLICIT');
        CurrentUserSaleId := InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-B', CurrentUserId);
        InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-Z', 'CORE1089-OTHER');
        Commit();

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Clear(QueryParams);
            QueryParams.Add('posunit', SearchPOSUnit."No.");
            QueryParams.Add('userId', 'CORE1089-EXPLICIT');
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            AssertSingleSaleArray(Response, ExplicitUserSaleId, Endpoint + ' explicit-user filter');

            QueryParams.Remove('userId');
            QueryParams.Add('filterToCurrentUserId', 'true');
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            AssertSingleSaleArray(Response, CurrentUserSaleId, Endpoint + ' current-user filter');

            QueryParams.Set('filterToCurrentUserId', 'TRUE');
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            AssertSingleSaleArray(Response, CurrentUserSaleId, Endpoint + ' uppercase current-user filter');

            QueryParams.Set('filterToCurrentUserId', 'false');
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), Endpoint + ' false filter should succeed');
            ResponseBody := LibraryNPRetailAPI.GetResponseBodyAsArray(Response);
            Assert.AreEqual(3, ResponseBody.Count(), Endpoint + ' false filter should preserve the unfiltered array');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SearchSale_BothUserFilters_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Endpoints: List of [Text];
        Endpoint: Text;
    begin
        Initialize();
        QueryParams.Add('posunit', _POSUnit."No.");
        QueryParams.Add('userId', 'CORE1089-EXPLICIT');
        QueryParams.Add('filterToCurrentUserId', 'true');

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            Assert.IsTrue(Response.Get('statusCode', JToken), Endpoint + ' response should contain statusCode');
            Assert.AreEqual(400, JToken.AsValue().AsInteger(), Endpoint + ' should return Bad Request');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SearchSale_InvalidCurrentUserFilter_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Endpoints: List of [Text];
        Endpoint: Text;
    begin
        Initialize();
        QueryParams.Add('posunit', _POSUnit."No.");
        QueryParams.Add('filterToCurrentUserId', 'not-a-boolean');

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            Assert.IsTrue(Response.Get('statusCode', JToken), Endpoint + ' response should contain statusCode');
            Assert.AreEqual(400, JToken.AsValue().AsInteger(), Endpoint + ' should return Bad Request');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SearchSale_UserIdTooLong_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Endpoints: List of [Text];
        Endpoint: Text;
    begin
        Initialize();
        QueryParams.Add('posunit', _POSUnit."No.");
        QueryParams.Add('userId', PadStr('', 51, 'X'));

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            Assert.IsTrue(Response.Get('statusCode', JToken), Endpoint + ' response should contain statusCode');
            Assert.AreEqual(400, JToken.AsValue().AsInteger(), Endpoint + ' should return Bad Request');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SearchSale_UserIdWithNoMatch_ReturnsNotFound()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        SearchPOSUnit: Record "NPR POS Unit";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Endpoints: List of [Text];
        Endpoint: Text;
    begin
        Initialize();
        NPRLibraryPOSMasterData.CreatePOSUnit(SearchPOSUnit, _POSStore.Code, _POSStore."POS Posting Profile");
        InsertPOSSaleForUser(SearchPOSUnit."No.", 'CORE1089-A', 'CORE1089-EXISTING');
        Commit();
        QueryParams.Add('posunit', SearchPOSUnit."No.");
        QueryParams.Add('userId', 'CORE1089-NO-MATCH');

        Endpoints.Add('/pos/sale/search');
        Endpoints.Add('/pos/sale');
        foreach Endpoint in Endpoints do begin
            Response := LibraryNPRetailAPI.CallApi('GET', Endpoint, Body, QueryParams, Headers);
            Assert.IsTrue(Response.Get('statusCode', JToken), Endpoint + ' response should contain statusCode');
            Assert.AreEqual(404, JToken.AsValue().AsInteger(), Endpoint + ' should return Not Found');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_NoPOSUnitInUserSetup_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        UserSetup: Record "User Setup";
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Create sale returns 400 when the API user's User Setup has no POS Unit assigned
        Initialize();

        // [GIVEN] API user's User Setup has no POS Unit
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := '';
        UserSetup.Modify();
        Commit();

        // [WHEN] Create a sale
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] 400 Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_EchoesVATBusinessPostingGroupAndCustomerNo()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        AltVATBusGroup: Record "VAT Business Posting Group";
        AltVATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] POST /pos/sale with body.vatBusinessPostingGroup and body.customerNo echoes both back in the response,
        //             confirming the server applied the overrides (regression — response used to echo stale session defaults).
        Initialize();

        LibraryERM.CreateVATBusinessPostingGroup(AltVATBusGroup);
        LibraryERM.CreateVATPostingSetup(AltVATPostingSetup, AltVATBusGroup.Code, _Item."VAT Prod. Posting Group");
        AltVATPostingSetup."VAT %" := 0;
        AltVATPostingSetup."VAT Calculation Type" := AltVATPostingSetup."VAT Calculation Type"::"Normal VAT";
        AltVATPostingSetup."VAT Identifier" := 'ZERO';
        AltVATPostingSetup."Sales VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup."Purchase VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup.Modify();
        LibrarySales.CreateCustomer(Customer);
        Commit();

        SaleId := CreateGuid();
        Body.Add('vatBusinessPostingGroup', AltVATBusGroup.Code);
        Body.Add('customerNo', Customer."No.");

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('vatBusinessPostingGroup', JToken), 'Response should contain vatBusinessPostingGroup');
        Assert.AreEqual(AltVATBusGroup.Code, JToken.AsValue().AsText(), 'Response should echo the requested vatBusinessPostingGroup');
        Assert.IsTrue(ResponseBody.Get('customerNo', JToken), 'Response should contain customerNo');
        Assert.AreEqual(Customer."No.", JToken.AsValue().AsText(), 'Response should echo the requested customerNo');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSale_ChangesVATAndGenOnHeaderAndLines()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        NewVATPostingSetup: Record "VAT Posting Setup";
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        POSSaleRec: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        IdToken: JsonToken;
        RefreshedLines: JsonArray;
        LineToken: JsonToken;
        FoundLine: Boolean;
    begin
        // [SCENARIO] PATCH /pos/sale with vat+gen business posting groups updates BOTH the header AND existing sale lines.
        //            Regression: PATCH used to validate only the header VAT field (leaving lines stale) and ignored gen entirely.
        Initialize();

        // [GIVEN] A sale with one item line
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] A new VAT Bus. Posting Group (with a VAT Posting Setup for the item's VAT Prod group) and a new Gen Bus. Posting Group
        LibraryERM.CreateVATPostingSetupWithAccounts(NewVATPostingSetup, NewVATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(NewVATPostingSetup."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
        Commit();

        // [WHEN] PATCH the sale with both groups
        Clear(Body);
        Body.Add('vatBusinessPostingGroup', NewVATPostingSetup."VAT Bus. Posting Group");
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Patch sale should succeed');

        // [THEN] The PATCH delta response reports the patched line as refreshed (proves line-level delta capture, not just DB state)
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('refreshedSaleLines', JToken), 'PATCH response should contain refreshedSaleLines');
        RefreshedLines := JToken.AsArray();
        foreach LineToken in RefreshedLines do
            if LineToken.AsObject().Get('id', IdToken) then
                if IdToken.AsValue().AsText() = FormatGuid(SaleLineId) then
                    FoundLine := true;
        Assert.IsTrue(FoundLine, 'refreshedSaleLines should contain the patched item line');

        // [THEN] The header carries both new groups
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", POSSaleRec."VAT Bus. Posting Group", 'Header VAT Bus. Posting Group should be updated');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should be updated');

        // [THEN] The exact item line (fetched by its SystemId = SaleLineId) ALSO carries both new groups — this is what was broken before the fix
        Assert.IsTrue(SaleLinePOS.GetBySystemId(SaleLineId), 'Item sale line should exist');
        Assert.AreEqual(SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type", 'Fetched line should be the item line');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", SaleLinePOS."VAT Bus. Posting Group", 'Line VAT Bus. Posting Group should be updated');
        Assert.AreEqual(NewGenBusPostingGroup.Code, SaleLinePOS."Gen. Bus. Posting Group", 'Line Gen. Bus. Posting Group should be updated');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_AppliesGenBusinessPostingGroup()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        POSSaleRec: Record "NPR POS Sale";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] POST /pos/sale with body.genBusinessPostingGroup applies it to the sale header and echoes it back.
        //            Regression: the API used to ignore genBusinessPostingGroup entirely.
        Initialize();

        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        Commit();

        SaleId := CreateGuid();
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [THEN] Response echoes the gen group
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('genBusinessPostingGroup', JToken), 'Response should contain genBusinessPostingGroup');
        Assert.AreEqual(NewGenBusPostingGroup.Code, JToken.AsValue().AsText(), 'Response should echo the requested genBusinessPostingGroup');

        // [THEN] Header record carries the gen group
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should be set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSale_WithCustomerAndGroups_PreservesCustomerAndAppliesGroups()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        NewVATPostingSetup: Record "VAT Posting Setup";
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        Customer: Record Customer;
        POSSaleRec: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] PATCH /pos/sale with customerNo AND explicit posting groups in the SAME body must keep the new customer
        //            on the header AND apply the explicit groups. Regression: delegating the group change to the VAT helper
        //            (which reads/writes the POS Sale codeunit's cached record) wrote stale pre-customer header state back,
        //            reverting the just-applied Customer No.
        Initialize();

        // [GIVEN] A sale with one item line, created without a customer
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] A customer (whose VAT group has a setup for the item, so the customer-validate cascade can re-VAT the line)
        //         plus explicit VAT and Gen groups to send alongside the customer
        LibraryERM.CreateVATPostingSetupWithAccounts(NewVATPostingSetup, NewVATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(NewVATPostingSetup."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
        LibrarySales.CreateCustomer(Customer);
        Customer."VAT Bus. Posting Group" := NewVATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        Commit();

        // [WHEN] PATCH with customerNo AND both posting groups together
        Clear(Body);
        Body.Add('customerNo', Customer."No.");
        Body.Add('vatBusinessPostingGroup', NewVATPostingSetup."VAT Bus. Posting Group");
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Patch sale should succeed');

        // [THEN] The header keeps the new customer (regression guard) AND carries the explicit groups
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(Customer."No.", POSSaleRec."Customer No.", 'Header Customer No. must survive the combined customer+groups patch');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", POSSaleRec."VAT Bus. Posting Group", 'Header VAT Bus. Posting Group should be the explicit group');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should override the customer default');

        // [THEN] The existing line also carries the explicit groups
        Assert.IsTrue(SaleLinePOS.GetBySystemId(SaleLineId), 'Item sale line should exist');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", SaleLinePOS."VAT Bus. Posting Group", 'Line VAT Bus. Posting Group should be the explicit group');
        Assert.AreEqual(NewGenBusPostingGroup.Code, SaleLinePOS."Gen. Bus. Posting Group", 'Line Gen. Bus. Posting Group should override the customer default');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSale_NonExistent_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Get non-existent sale returns Not Found
        Initialize();

        // [GIVEN] A random sale ID that doesn't exist
        SaleId := CreateGuid();

        // [WHEN] Get the non-existent sale
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Should return Not Found
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Should return 404 Not Found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_WithoutPayment_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Complete sale without payment returns Bad Request
        Initialize();

        // [GIVEN] A sale with a line but no payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Try to complete without payment
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Should return Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request when payment is missing');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_Underpayment_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Complete sale with payment 1 less than needed returns Bad Request
        Initialize();

        // [GIVEN] A sale with a line
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] Payment of 1 less than full amount
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price" - 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Try to complete with underpayment
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Should return Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request when underpaid by 1');
        AssertBillingEventNotRegistered(SaleId);
        AssertBillingEventNotRegistered(SaleLineId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_BalancedExchangeWithoutPayment_RegistersBillingEvents()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        ReturnSaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        Initialize();

        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        ReturnSaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create positive sale line should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', -1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(ReturnSaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create return sale line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Balanced exchange should complete without payment');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('entryNo', JToken), 'Response should contain entryNo');
        Assert.IsTrue(POSEntry.Get(JToken.AsValue().AsInteger()), 'POS Entry should be created');
        Assert.AreEqual(0, POSEntry."Amount Incl. Tax & Round", 'Balanced exchange should have zero rounded total');

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntryPaymentLine.IsEmpty(), 'Balanced exchange should not require a POS Entry payment line');

        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the first API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_EFTPayment_StoresMetadata()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        EFTReceiptArray: JsonArray;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
    begin
        // [SCENARIO] EFT payment stores metadata in EFT Transaction Request and receipt lines in EFT Receipt
        Initialize();

        // [GIVEN] A new sale with item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add EFT payment with metadata
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', 'PSP-REF-12345');
        Body.Add('parToken', 'PAR-TOKEN-ABCDEF');
        Body.Add('success', true);
        EFTReceiptArray.Add('CARD PAYMENT');
        EFTReceiptArray.Add('Amount: 100.00');
        EFTReceiptArray.Add('Auth Code: 123456');
        Body.Add('eftReceipt', EFTReceiptArray);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');

        // [WHEN] Complete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');

        // [THEN] EFT Transaction Request is created with correct metadata
        EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
        EFTTransactionRequest.SetRange("Card Number", '************1234');
        Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'EFT Transaction Request should be created');
        Assert.AreEqual('PSP-REF-12345', EFTTransactionRequest."PSP Reference", 'PSP Reference should match');
        Assert.AreEqual('PAR-TOKEN-ABCDEF', EFTTransactionRequest."Payment Account Reference", 'PAR Token should match');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'Transaction should be marked as successful');

        // [THEN] EFT Receipt lines are created
        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.AreEqual(3, EFTReceipt.Count(), 'Should have 3 EFT receipt lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLineOperations_AddUpdateDelete_PricesCorrect()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId1: Guid;
        SaleLineId2: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        TotalAmount: Decimal;
    begin
        // [SCENARIO] Sale line operations (add, update quantity, delete) calculate prices correctly
        Initialize();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId1 := CreateGuid();
        SaleLineId2 := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add first line with quantity 2
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 2);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create first sale line should succeed');

        // [WHEN] Add second line
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item2."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId2), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create second sale line should succeed');

        // [THEN] Get sale and verify total (2*100 + 1*50 = 250)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(250, TotalAmount, 'Total should be 250 (2*100 + 1*50)');

        // [WHEN] Update first line to increase quantity to 3
        Clear(QueryParams);
        Clear(Body);
        Body.Add('quantity', 3);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Update sale line should succeed');

        // [THEN] Get sale and verify total (3*100 + 1*50 = 350)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(350, TotalAmount, 'Total should be 350 (3*100 + 1*50)');

        // [WHEN] Delete second line
        Clear(QueryParams);
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId2), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Delete sale line should succeed');

        // [THEN] Get sale and verify total (3*100 = 300)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(300, TotalAmount, 'Total should be 300 (3*100)');

        // [WHEN] Update first line to decrease quantity to 1
        Clear(QueryParams);
        Clear(Body);
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Update sale line should succeed');

        // [THEN] Get sale and verify total (1*100 = 100)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(100, TotalAmount, 'Total should be 100 (1*100)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Failure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemWithEmptyVATBusPG: Record Item;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Item with empty "VAT Bus. Posting Gr. (Price)" and Prices Including VAT=true cannot be sold
        // Items with Price Includes VAT=true must have VAT Bus. Posting Gr. (Price) filled
        Initialize();

        // [GIVEN] An item with Prices Including VAT=true but empty VAT Bus. Posting Gr. (Price)
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ItemWithEmptyVATBusPG, _POSUnit, _POSStore);
        ItemWithEmptyVATBusPG."Unit Price" := 100;
        ItemWithEmptyVATBusPG."Price Includes VAT" := true;
        ItemWithEmptyVATBusPG."VAT Bus. Posting Gr. (Price)" := '';
        ItemWithEmptyVATBusPG.Modify();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add a sale line with item that has empty VAT Bus. Posting Gr. (Price)
        // [THEN] Error is thrown because VAT Bus. Posting Gr. (Price) is required when Price Includes VAT=true
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ItemWithEmptyVATBusPG."No.");
        Body.Add('quantity', 1);
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.ExpectedError('VAT Bus. Posting Gr. (Price) must have a value');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceAlways_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Always uses addon's defined price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Always and Unit Price = 15
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 15);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon via separate endpoint
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        // [THEN] Verify addon has correct price (15, not 25 from item)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(15, AddonUnitPrice, 'Addon should use defined price (15), not item price (25)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line in sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and non-zero price uses addon's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 10
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 10);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created with price 10
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(10, AddonUnitPrice, 'Addon should use defined price (10)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and zero price uses item's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 0
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 0);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should use item price (25) since addon price is 0
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(25, AddonUnitPrice, 'Addon should use item price (25) when addon price is 0');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Failure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ParentItemWithEmptyVAT: Record Item;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Parent item with empty VAT Bus. Posting Gr. (Price) and Prices Including VAT=true cannot be sold
        // Items with Price Includes VAT=true must have VAT Bus. Posting Gr. (Price) filled
        Initialize();

        // [GIVEN] A parent item with empty VAT Bus. Posting Gr. (Price) and Prices Including VAT=true
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ParentItemWithEmptyVAT, _POSUnit, _POSStore);
        ParentItemWithEmptyVAT."Unit Price" := 100;
        ParentItemWithEmptyVAT."Price Includes VAT" := true;
        ParentItemWithEmptyVAT."VAT Bus. Posting Gr. (Price)" := '';
        ParentItemWithEmptyVAT.Modify();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent item with empty VAT Bus. Posting Gr. (Price)
        // [THEN] Error is thrown because VAT Bus. Posting Gr. (Price) is required when Price Includes VAT=true
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ParentItemWithEmptyVAT."No.");
        Body.Add('quantity', 1);
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.ExpectedError('VAT Bus. Posting Gr. (Price) must have a value');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddonsArray_MultipleAddons_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        AddonsArray: JsonArray;
        Addon1: JsonObject;
        Addon2: JsonObject;
        ItemAddOnLine1: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLine2: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId1: Guid;
        AddonLineId2: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        AddonCount: Integer;
    begin
        // [SCENARIO] Multiple addons can be inserted in same request as parent line
        InitializeAddon();

        // [GIVEN] Two addon lines with different prices
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine1, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine1."Use Unit Price"::Always, 15);
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine2, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine2."Use Unit Price"::Always, 10);

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId1 := CreateGuid();
        AddonLineId2 := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent line with addons array
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);

        Addon1.Add('lineId', FormatGuid(AddonLineId1));
        Addon1.Add('addonNo', _ItemAddon."No.");
        Addon1.Add('addonLineNo', Format(ItemAddOnLine1."Line No."));
        Addon1.Add('quantity', 1);
        AddonsArray.Add(Addon1);

        Addon2.Add('lineId', FormatGuid(AddonLineId2));
        Addon2.Add('addonNo', _ItemAddon."No.");
        Addon2.Add('addonLineNo', Format(ItemAddOnLine2."Line No."));
        Addon2.Add('quantity', 2);
        AddonsArray.Add(Addon2);

        Body.Add('addons', AddonsArray);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line with addons should be created
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line with addons array should succeed');

        // [THEN] Verify 3 lines total (1 parent + 2 addons)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        Assert.AreEqual(3, SaleLinesArray.Count(), 'Should have 3 sale lines (1 parent + 2 addons)');

        // Count addon lines
        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then
                AddonCount += 1;
        end;
        Assert.AreEqual(2, AddonCount, 'Should have 2 addon lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_ItemStatus_ReturnsInJSON()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        MenuContent: JsonObject;
        CategoriesArray: JsonArray;
        CategoryToken: JsonToken;
        CategoryObj: JsonObject;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        StatusText: Text;
    begin
        // [SCENARIO] Menu item status enum value is returned in JSON response
        InitializeMenu();

        // [GIVEN] Menu has a category with an item set to Inactive Visible
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'STATUS');
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'STATUS', _Item."No.");
        MenuItem.Status := MenuItem.Status::"Inactive Visible";
        MenuItem.Modify();

        // [WHEN] Get menu
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);

        // [THEN] Menu should be returned successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] Find the item in the STATUS category and verify status
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should have menuContent');
        MenuContent := JToken.AsObject();
        Assert.IsTrue(MenuContent.Get('categories', JToken), 'menuContent should have categories');
        CategoriesArray := JToken.AsArray();

        // Find our STATUS category
        CategoriesArray.Get(CategoriesArray.Count() - 1, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should have items');
        ItemsArray := JToken.AsArray();
        ItemsArray.Get(0, ItemToken);
        ItemObj := ItemToken.AsObject();

        // [THEN] Item should have status = "Inactive Visible"
        Assert.IsTrue(ItemObj.Get('status', JToken), 'Item should have status property');
        StatusText := JToken.AsValue().AsText();
        Assert.AreEqual('Inactive Visible', StatusText, 'Item status should be Inactive Visible');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_LastUpdated_UpdatedOnChildChange()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Menu: Record "NPR NPRE Menu";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        LastUpdatedText: Text;
        LastUpdatedBeforeCategoryInsert: DateTime;
        LastUpdatedAfterCategoryInsert: DateTime;
    begin
        // [SCENARIO] Menu's lastUpdated is refreshed when child records are inserted and appears in API responses
        InitializeMenu();

        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        // [GIVEN] Capture current lastUpdated before changes
        Menu.Get(Restaurant.Code, _Menu.Code);
        LastUpdatedBeforeCategoryInsert := Menu."Last Updated";

        // [WHEN] A menu category is created (triggers subscriber)
        Sleep(100);
        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'UPDATED');
        Commit();

        // [THEN] Menu's Last Updated should be refreshed
        Menu.Get(Restaurant.Code, _Menu.Code);
        Assert.AreNotEqual(0DT, Menu."Last Updated", 'Last Updated should be set after category insert');
        Assert.IsTrue(Menu."Last Updated" >= LastUpdatedBeforeCategoryInsert,
            'Last Updated should be refreshed after category insert');
        LastUpdatedAfterCategoryInsert := Menu."Last Updated";

        // [WHEN] A menu item is created under the category
        Sleep(100);
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'UPDATED', _Item."No.");
        Commit();

        // [THEN] Last Updated should be refreshed again
        Menu.Get(Restaurant.Code, _Menu.Code);
        Assert.IsTrue(Menu."Last Updated" >= LastUpdatedAfterCategoryInsert,
            'Last Updated should be refreshed after item insert');

        // [THEN] lastUpdated appears in get menu response
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('lastUpdated', JToken), 'Menu should have lastUpdated');
        LastUpdatedText := JToken.AsValue().AsText();
        Assert.AreNotEqual('', LastUpdatedText, 'lastUpdated should not be empty in get menu response');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_WithItemsAndAddons_ReturnsStructure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        MenuContent: JsonObject;
        CategoriesArray: JsonArray;
        CategoryToken: JsonToken;
        CategoryObj: JsonObject;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        AddonItemsArray: JsonArray;
    begin
        // [SCENARIO] Menu endpoint returns items with their addons
        InitializeMenu();

        // [GIVEN] Menu has a category with an item that has addons
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'MAIN');
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'MAIN', _Item."No.");

        // Ensure addon line exists
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 20);

        // [WHEN] Get menu
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);

        // [THEN] Menu should be returned with structure
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] Should have menuContent with categories
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should have menuContent');
        MenuContent := JToken.AsObject();

        Assert.IsTrue(MenuContent.Get('categories', JToken), 'menuContent should have categories');
        CategoriesArray := JToken.AsArray();
        Assert.IsTrue(CategoriesArray.Count() > 0, 'Should have at least one category');

        // [THEN] Category should have items
        CategoriesArray.Get(0, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should have items');
        ItemsArray := JToken.AsArray();
        Assert.IsTrue(ItemsArray.Count() > 0, 'Should have at least one item');

        // [THEN] Item should have addonItems array
        ItemsArray.Get(0, ItemToken);
        ItemObj := ItemToken.AsObject();
        Assert.IsTrue(ItemObj.Get('addonItems', JToken), 'Item should have addonItems');
        AddonItemsArray := JToken.AsArray();
        Assert.IsTrue(AddonItemsArray.Count() > 0, 'Should have at least one addon');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_FlowStatusCopying_SendsToKitchen()
    var
        Assert: Codeunit Assert;
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        CustomerDetails: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Flow statuses should be copied from item routing profile to waiter pad line
        // and allow sending to kitchen
        InitializeRestaurant();

        // [GIVEN] A POS Sale with an item line
        POSSale.Init();
        POSSale."Register No." := _POSUnit."No.";
        POSSale."Sales Ticket No." := 'TEST001';
        POSSale."POS Store Code" := _POSStore.Code;
        POSSale.Date := Today;
        POSSale.Insert(true);

        POSSaleLine.Init();
        POSSaleLine."Register No." := POSSale."Register No.";
        POSSaleLine."Sales Ticket No." := POSSale."Sales Ticket No.";
        POSSaleLine."Line No." := 10000;
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::Item;
        POSSaleLine."No." := _Item."No.";
        POSSaleLine.Description := _Item.Description;
        POSSaleLine.Quantity := 1;
        POSSaleLine."Quantity (Base)" := 1;
        POSSaleLine."Unit Price" := _Item."Unit Price";
        POSSaleLine."Amount Including VAT" := _Item."Unit Price";
        POSSaleLine.Insert(true);

        // [GIVEN] A waiter pad linked to the seating
        WaiterPadMgt.CreateNewWaiterPad(_Seating.Code, 1, '', CustomerDetails, WaiterPad);
        POSSale."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        POSSale."NPRE Pre-Set Seating Code" := _Seating.Code;
        POSSale.Modify();

        // [WHEN] Sale lines are moved to waiter pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);
        Commit();

        // [THEN] Waiter pad line should be created with flow statuses
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        Assert.IsTrue(WaiterPadLine.FindFirst(), 'Waiter pad line should be created');

        AssignedFlowStatus.SetRange("Table No.", DATABASE::"NPR NPRE Waiter Pad Line");
        AssignedFlowStatus.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        Assert.AreEqual(3, AssignedFlowStatus.Count(), 'Waiter pad line should have 3 flow statuses');

        // [THEN] Kitchen order can be sent without error
        RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_DeletePOSBilledLine_ReducesWaiterPadLineQtyToBilled()
    var
        Assert: Codeunit Assert;
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLineToDelete: Record "NPR POS Sale Line";
        OrphanLineNo: Integer;
    begin
        // [SCENARIO] A partly billed waiter pad line, loaded to POS and then deleted on the POS,
        // must have its quantity reduced to the billed quantity when the sale is saved back.
        InitializeRestaurant();

        // [GIVEN] A waiter-pad-linked POS sale with two item lines, the first of them partly billed
        SetupWaiterPadLinkedSale(POSSale, WaiterPad, WaiterPadLine, POSSaleLineToDelete);
        OrphanLineNo := WaiterPadLine."Line No.";
        WaiterPadLine."Billed Quantity" := 1;
        WaiterPadLine.Modify();

        // [WHEN] The POS line is deleted and the sale is saved back to the waiter pad
        POSSaleLineToDelete.Delete(true);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);

        // [THEN] The orphaned waiter pad line quantity is reduced to the billed quantity
        WaiterPadLine.Get(WaiterPad."No.", OrphanLineNo);
        Assert.AreEqual(1, WaiterPadLine.Quantity, 'Deleting the POS line should reduce the orphaned waiter pad line qty to its billed quantity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_DeleteKitchenSentPOSLine_ZeroesWaiterPadLineQty()
    var
        Assert: Codeunit Assert;
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLineToDelete: Record "NPR POS Sale Line";
        OrphanLineNo: Integer;
    begin
        // [SCENARIO] A waiter pad line already sent to the kitchen, loaded to POS and then deleted on the
        // POS, must have its quantity zeroed when the sale is saved back (so the kitchen request is cancelled).
        InitializeRestaurant();

        // [GIVEN] A waiter-pad-linked POS sale with two item lines (the restaurant setup auto-sends lines to the kitchen)
        SetupWaiterPadLinkedSale(POSSale, WaiterPad, WaiterPadLine, POSSaleLineToDelete);
        OrphanLineNo := WaiterPadLine."Line No.";

        // [WHEN] The POS line is deleted and the sale is saved back to the waiter pad
        POSSaleLineToDelete.Delete(true);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);

        // [THEN] The orphaned waiter pad line quantity is zeroed (nothing billed)
        WaiterPadLine.Get(WaiterPad."No.", OrphanLineNo);
        Assert.AreEqual(0, WaiterPadLine.Quantity, 'Deleting the kitchen-sent POS line should zero the orphaned waiter pad line qty');
    end;

    local procedure SetupWaiterPadLinkedSale(var POSSale: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineToOrphan: Record "NPR NPRE Waiter Pad Line"; var POSSaleLineToDelete: Record "NPR POS Sale Line")
    var
        POSSaleLineToKeep: Record "NPR POS Sale Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CustomerDetails: Dictionary of [Text, Text];
    begin
        // Creates a POS sale tied to a waiter pad with two item lines and moves it to the pad once,
        // so both waiter pad lines carry the "Sale Retail ID"/"Sale Line Retail ID" links a real
        // load-to-POS would set. Returns the waiter pad line linked to POSSaleLineToDelete; a second
        // line is kept so the sale is non-empty when it is later saved back.
        POSSale.Init();
        POSSale."Register No." := _POSUnit."No.";
        // Unique ticket per call so the two tests sharing this helper don't collide on committed data
        // when the whole codeunit runs in a single test-isolation session (MoveSaleFromPOSToWaiterPad commits).
        POSSale."Sales Ticket No." := CopyStr('WP' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(POSSale."Sales Ticket No."));
        POSSale."POS Store Code" := _POSStore.Code;
        POSSale.Date := Today;
        POSSale.Insert(true);

        InsertPOSItemSaleLine(POSSale, POSSaleLineToDelete, 10000, 3);
        InsertPOSItemSaleLine(POSSale, POSSaleLineToKeep, 20000, 1);

        WaiterPadMgt.CreateNewWaiterPad(_Seating.Code, 1, '', CustomerDetails, WaiterPad);
        POSSale."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        POSSale."NPRE Pre-Set Seating Code" := _Seating.Code;
        POSSale.Modify();

        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);
        Commit();

        WaiterPadLineToOrphan.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLineToOrphan.SetRange("Sale Line Retail ID", POSSaleLineToDelete.SystemId);
        WaiterPadLineToOrphan.FindFirst();
    end;

    local procedure InsertPOSItemSaleLine(POSSale: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; LineNo: Integer; Qty: Decimal)
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := POSSale."Register No.";
        SaleLinePOS."Sales Ticket No." := POSSale."Sales Ticket No.";
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := _Item."No.";
        SaleLinePOS.Description := _Item.Description;
        SaleLinePOS.Quantity := Qty;
        SaleLinePOS."Quantity (Base)" := Qty;
        SaleLinePOS."Unit Price" := _Item."Unit Price";
        SaleLinePOS."Amount Including VAT" := _Item."Unit Price" * Qty;
        SaleLinePOS.Insert(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_WithKitchenRequest_TransfersCustomerDetails()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        RestaurantWebhookTestSub: Codeunit "NPR Restaurant Webhook TestSub";
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        CustomerDetails: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        // [SCENARIO] Complete sale with kitchenRequest transfers customer details to kitchen order
        InitializeRestaurant();

        // Debug assertions to verify restaurant setup
        VerifyRestaurantSetupForKitchenOrders();

        // [GIVEN] A new sale with item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [GIVEN] Webhook subscriber is bound
        RestaurantWebhookTestSub.Reset();
        BindSubscription(RestaurantWebhookTestSub);

        // [WHEN] Complete with kitchenRequest containing customer details
        Clear(Body);
        CustomerDetails.Add('name', 'John Doe');
        CustomerDetails.Add('phoneNo', '+1234567890');
        CustomerDetails.Add('email', 'john@example.com');
        KitchenRequest.Add('seatingCode', _Seating.Code);
        KitchenRequest.Add('noOfGuests', 2);
        KitchenRequest.Add('customerDetails', CustomerDetails);
        Body.Add('kitchenRequest', KitchenRequest);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale with kitchen request should succeed');

        // [THEN] Response contains kitchenOrderNo
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('entryNo', JToken), 'Response should contain entryNo');
        POSEntry.Get(JToken.AsValue().AsInteger());
        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::HOSPITALITY_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::HOSPITALITY_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");

        Assert.IsTrue(ResponseBody.Get('kitchenOrderNo', JToken), 'Response should contain kitchenOrderNo');
        KitchenOrderNoText := JToken.AsValue().AsText();
        Evaluate(KitchenOrderNo, KitchenOrderNoText);
        Assert.AreNotEqual(0, KitchenOrderNo, 'Kitchen order number should not be 0');

        // [THEN] Waiter pad has customer details
        WaiterPad.SetCurrentKey(SystemCreatedAt);
        WaiterPad.Ascending(false);
        WaiterPad.SetRange("Customer Phone No.", '+1234567890');
        Assert.IsTrue(WaiterPad.FindFirst(), 'Waiter pad should be created');
        Assert.AreEqual('John Doe', WaiterPad.Description, 'Waiter pad description should have customer name');
        Assert.AreEqual('+1234567890', WaiterPad."Customer Phone No.", 'Waiter pad should have phone number');
        Assert.AreEqual('john@example.com', WaiterPad."Customer E-Mail", 'Waiter pad should have email');
        Assert.AreEqual(2, WaiterPad."Number of Guests", 'Waiter pad should have correct number of guests');

        // [WHEN] Kitchen order is finished (marked as served)
        LibraryRestaurant.FinishKitchenOrder(KitchenOrderNo);

        // [THEN] Webhook should have been invoked
        Assert.IsTrue(RestaurantWebhookTestSub.WasWebhookInvoked(), 'Webhook should be invoked when kitchen order is ready for serving');
        Assert.AreEqual(KitchenOrderNo, RestaurantWebhookTestSub.GetLastKitchenOrderId(), 'Webhook should receive correct kitchen order ID');

        UnbindSubscription(RestaurantWebhookTestSub);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_KitchenRequest_MissingSeatingCode_ReturnsError()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Complete sale with kitchenRequest missing seatingCode returns error
        InitializeRestaurant();

        // [GIVEN] A sale with item and payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Complete with kitchenRequest but without seatingCode
        Clear(Body);
        KitchenRequest.Add('noOfGuests', 2);
        // Note: seatingCode is intentionally omitted
        Body.Add('kitchenRequest', KitchenRequest);

        // [THEN] Should throw error due to missing seatingCode
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.ExpectedError('Missing required field: seatingCode');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_DuplicateId_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Creating a sale with an already-used ID should fail
        Initialize();

        // [GIVEN] A sale is created with a specific ID
        SaleId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'First create sale should succeed');

        // [WHEN] Try to create another sale with the same ID
        Clear(Body);

        // [THEN] Should fail with duplicate ID error
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.ExpectedError('System ID');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_NonUnattendedUnit_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        NonUnattendedUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        UserSetup: Record "User Setup";
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Creating a sale when the API user's User Setup points at a non-UNATTENDED POS unit should fail
        Initialize();

        // [GIVEN] A non-UNATTENDED (MPOS) POS Unit assigned to the API user in User Setup
        POSPostingProfile.FindFirst();
        NPRLibraryPOSMasterData.CreatePOSUnit(NonUnattendedUnit, _POSStore.Code, POSPostingProfile.Code);
        NonUnattendedUnit."POS Type" := NonUnattendedUnit."POS Type"::MPOS;
        NonUnattendedUnit.Status := NonUnattendedUnit.Status::OPEN;
        NonUnattendedUnit.Modify();
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := NonUnattendedUnit."No.";
        UserSetup.Modify();
        Commit();

        // [WHEN] Create a sale (unit resolved from User Setup)
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting so later test methods are unaffected
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] 400, because the User Setup POS Unit is not UNATTENDED
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Non-UNATTENDED unit should return 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddonLine_NegativeQuantity_ForIngredientRemoval_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        AddonsArray: JsonArray;
        AddonObj: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundNegativeAddon: Boolean;
        AddonQuantity: Decimal;
    begin
        // [SCENARIO] Negative quantity on addon is allowed for ingredient removal (e.g., "no onions")
        InitializeAddon();

        // [GIVEN] An addon line configured for ingredient removal
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 0); // Zero price for removal

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent item with an addon that has negative quantity (ingredient removal)
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);

        AddonObj.Add('lineId', FormatGuid(AddonLineId));
        AddonObj.Add('addonNo', _ItemAddon."No.");
        AddonObj.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        AddonObj.Add('quantity', -1); // Negative quantity for removal
        AddonsArray.Add(AddonObj);
        Body.Add('addons', AddonsArray);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Should succeed - negative quantity is valid for ingredient removal
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line with negative addon should succeed');

        // [THEN] Verify the addon has negative quantity
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                SaleLineObj.Get('quantity', JToken);
                AddonQuantity := JToken.AsValue().AsDecimal();
                if AddonQuantity < 0 then
                    FoundNegativeAddon := true;
            end;
        end;
        Assert.IsTrue(FoundNegativeAddon, 'Should have addon with negative quantity for ingredient removal');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteSale_WithSaleLines_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Cancelling a sale with sale lines should succeed
        Initialize();

        // [GIVEN] A sale with item lines
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 2);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Delete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Should succeed
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Delete sale with sale lines should succeed');

        // [THEN] Sale should no longer exist
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Sale should not be found after deletion');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteSale_WithEFTPayment_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Cancelling a sale with an EFT (approved) payment line should fail
        Initialize();

        // [GIVEN] A sale with an item and an approved EFT payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] An EFT payment is added (simulating approved card payment)
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', 'PSP-REF-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');

        // [WHEN] Try to delete the sale
        Clear(Body);

        // [THEN] Should fail - cannot cancel sale with approved EFT payment
        asserterror Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.ExpectedError('Cannot delete externally approved electronic funds transfer');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EFTPayment_BINMapping_MapsToCorrectPaymentMethod()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        // [SCENARIO] EFT payment with a VISA BIN maps to the VISA payment method via BIN range matching
        InitializeEFTMapping();

        // [GIVEN] A sale with an item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add EFT payment with a masked VISA card number (BIN 411111 falls in 400000-499999)
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '411111******1234');
        Body.Add('pspReference', 'PSP-BIN-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment should succeed');

        // [THEN] EFT Transaction Request should be remapped from generic EFT to VISA payment method
        EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
        EFTTransactionRequest.SetRange("Card Number", '411111******1234');
        Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'EFT Transaction Request should exist');
        Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."Original POS Payment Type Code",
            'Original payment type should be the generic EFT method');
        Assert.AreEqual(_VisaPaymentMethod.Code, EFTTransactionRequest."POS Payment Type Code",
            'Payment type should be remapped to VISA');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CleanupJob_UnpaidSales_AreDeleted()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        POSSale: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] Cleanup job deletes unpaid abandoned sales from UNATTENDED POS units
        Initialize();

        // [GIVEN] A sale with an item line but no payment (abandoned)
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');
        Commit();

        // [GIVEN] WorkDate is set 2 days ahead so the sale falls before the cutoff
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+2D>', OriginalWorkDate));

        // [WHEN] Run cleanup job
        RunCleanupJob();

        // [THEN] Sale should be deleted
        Assert.IsFalse(POSSale.GetBySystemId(SaleId), 'POS Sale should be deleted by cleanup job');

        // [THEN] Sale should NOT be parked (no EFT payment)
        POSSavedSaleEntry.SetRange(SystemId, SaleId);
        Assert.IsTrue(POSSavedSaleEntry.IsEmpty(), 'Sale without EFT should not be parked');

        // Restore WorkDate
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CleanupJob_PaidEFTSales_AreParked()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        POSSale: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] Cleanup job parks abandoned sales that have EFT payments instead of deleting them
        Initialize();

        // [GIVEN] A sale with an item and an approved EFT payment (abandoned after payment)
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************5678');
        Body.Add('pspReference', 'PSP-CLEANUP-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');
        Commit();

        // [GIVEN] WorkDate is set 2 days ahead so the sale falls before the cutoff
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+2D>', OriginalWorkDate));

        // [WHEN] Run cleanup job
        RunCleanupJob();

        // [THEN] Sale should be removed from active POS Sales
        Assert.IsFalse(POSSale.GetBySystemId(SaleId), 'POS Sale should no longer exist as active sale');

        // [THEN] Sale should be parked in POS Saved Sale Entry (the SystemId is preserved by CreateSavedSaleEntry)
        Assert.IsTrue(POSSavedSaleEntry.GetBySystemId(SaleId), 'Sale with EFT should be parked in Saved Sale Entry');

        // [THEN] Saved sale should have lines
        POSSavedSaleLine.SetRange("Quote Entry No.", POSSavedSaleEntry."Entry No.");
        Assert.IsTrue(POSSavedSaleLine.Count() >= 2, 'Parked sale should have at least 2 lines (item + payment)');

        // Restore WorkDate
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_AuthorizedAttemptHasFinancialResultAndLinks()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        GLSetup: Record "General Ledger Setup";
        OriginalLCYCode: Code[10];
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] An authorized external payment records financial results and sale linkage.
        // [GIVEN] An unattended sale and a successful LCY EFT payload.
        CreateSaleForExternalEFT(POSSale);
        _EFTPaymentMethod.TestField("Currency Code", '');
        _EFTPaymentMethod.TestField("Fixed Rate", 0);
        _EFTPaymentMethod.TestField("Use Stand. Exc. Rate for Bal.", false);
        GLSetup.Get();
        OriginalLCYCode := GLSetup."LCY Code";
        GLSetup."LCY Code" := 'DKK';
        GLSetup.Modify();
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('description', 'External card payment');
        Body.Add('success', true);
        // [WHEN] The external system submits the payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        GLSetup."LCY Code" := OriginalLCYCode;
        GLSetup.Modify();
        // [THEN] The request is finalized in LCY and links to the approved payment line.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Authorized attempt should be accepted');
        EFTTransactionRequest.SetRange("Register No.", POSSale."Register No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'Authorized attempt should be recorded');
        Assert.AreEqual(100, EFTTransactionRequest."Result Amount", 'Authorized amount must be available to reconciliation');
        Assert.AreEqual(100, EFTTransactionRequest."Amount Input", 'Input should retain the requested amount');
        Assert.AreEqual(100, EFTTransactionRequest."Amount Output", 'Output should contain the authorized amount');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'The external authorization should be retained');
        Assert.IsTrue(EFTTransactionRequest."Financial Impact", 'A nonzero authorized payment should have financial impact');
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'The supplied authorization result is known');
        Assert.IsTrue(EFTTransactionRequest."Result Processed", 'The external result should be fully processed');
        Assert.AreEqual(EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type", 'The attempt should be a payment');
        Assert.AreEqual('POS_API', EFTTransactionRequest."Integration Type", 'External attempts should retain their integration type');
        Assert.AreEqual('DKK', EFTTransactionRequest."Currency Code", 'The current payload uses local currency');
        Assert.AreEqual(POSSale.SystemId, EFTTransactionRequest."Sales ID", 'The attempt should identify its sale');
        Assert.AreEqual(UserId(), EFTTransactionRequest."User ID", 'The attempt should identify the API user');
        Assert.IsTrue(EFTTransactionRequest."Self Service", 'The unattended POS unit should be identified');
        Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."Original POS Payment Type Code", 'The requested payment method should be retained');
        Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."POS Payment Type Code", 'An unmapped payment should retain its method');
        Assert.AreEqual('External card payment', EFTTransactionRequest."POS Description", 'The supplied description should be retained');
        Assert.AreNotEqual(0DT, EFTTransactionRequest.Started, 'The recording time should be populated');
        Assert.IsTrue(EFTTransactionRequest.Finished >= EFTTransactionRequest.Started, 'The attempt should be finished');

        Assert.IsTrue(PaymentLine.GetBySystemId(PaymentLineId), 'The approved line should use the caller-provided ID');
        Assert.IsTrue(PaymentLine."EFT Approved", 'The payment line should retain authorization');
        Assert.AreEqual(100, PaymentLine."Amount Including VAT", 'The approved payment should contribute to the sale');
        Assert.AreEqual(PaymentLine.SystemId, EFTTransactionRequest."Sales Line ID", 'Reconciliation should be able to resolve the payment line');
        Assert.AreEqual(PaymentLine."Line No.", EFTTransactionRequest."Sales Line No.", 'The request should retain the actual payment line number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_FailedAttemptIsAuditOnly()
    begin
        // [SCENARIO] A reported failure is retained without paying the sale.
        // [GIVEN] An external attempt with success set to false.
        // [WHEN] The external attempt is submitted to the API.
        // [THEN] Its outcome is validated without creating a payment line.
        AssertExternalEFTAttemptIsAuditOnly();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_OmittedSuccessIsAuditOnly()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        ReceiptLines: JsonArray;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Legacy EFT callers may omit success, which defaults to an unsuccessful audit-only attempt.
        // [GIVEN] A sale and an EFT payload with receipts but no success property.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        ReceiptLines.Add('External outcome');
        Body.Add('eftReceipt', ReceiptLines);

        // [WHEN] The external system submits the attempt without an outcome.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] The API records the attempt and receipt without paying the sale or consuming the payment-line ID.
        Response.Get('statusCode', JToken);
        Assert.AreEqual(201, JToken.AsValue().AsInteger(), 'An omitted outcome should be accepted for backwards compatibility');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('totalPaymentAmount', JToken);
        Assert.AreEqual(0, JToken.AsValue().AsDecimal(), 'An omitted outcome must not pay the sale');
        ResponseBody.Get('refreshedPaymentLines', JToken);
        Assert.AreEqual(0, JToken.AsArray().Count(), 'No payment line should be returned');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'An omitted outcome must not consume the caller payment-line ID');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        Assert.AreEqual(404, JToken.AsValue().AsInteger(), 'There should be no payment line to retrieve');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.AreEqual(1, EFTTransactionRequest.Count(), 'One audit record should be retained');
        EFTTransactionRequest.FindFirst();
        Assert.IsFalse(EFTTransactionRequest.Successful, 'An omitted outcome must default to false');
        Assert.AreEqual(100, EFTTransactionRequest."Amount Input", 'The attempted amount should be retained');
        Assert.AreEqual(0, EFTTransactionRequest."Amount Output", 'An omitted outcome has no authorized output');
        Assert.AreEqual(0, EFTTransactionRequest."Result Amount", 'An omitted outcome has no financial result');
        Assert.IsFalse(EFTTransactionRequest."Financial Impact", 'An omitted outcome must not have financial impact');
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'An omitted outcome should be recorded as the default false outcome');
        Assert.IsTrue(EFTTransactionRequest."Result Processed", 'The audit outcome should be fully recorded');
        Assert.IsTrue(IsNullGuid(EFTTransactionRequest."Sales Line ID"), 'An audit-only attempt must not link to a payment line');
        Assert.AreEqual(0, EFTTransactionRequest."Sales Line No.", 'An audit-only attempt must not have a payment-line number');
        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.AreEqual(1, EFTReceipt.Count(), 'The supplied receipt should be retained');
        EFTReceipt.FindFirst();
        Assert.AreEqual('External outcome', EFTReceipt.Text, 'The receipt should retain the supplied text');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_NullSuccessReturnsBadRequest()
    begin
        // [SCENARIO] JSON null is not an EFT outcome.
        // [GIVEN] An EFT payload with success set to null.
        // [WHEN] The payload is submitted to the payment-line API.
        // [THEN] A structured 400 is returned without recording the attempt.
        AssertExternalEFTRejectsInvalidSuccess('null');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_StringSuccessReturnsBadRequest()
    begin
        // [SCENARIO] A string spelling true is not a JSON boolean.
        // [GIVEN] An EFT payload with a string-valued outcome.
        // [WHEN] The external attempt is submitted.
        // [THEN] The API returns a structured 400 without recording it.
        AssertExternalEFTRejectsInvalidSuccess('"true"');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_NumberSuccessReturnsBadRequest()
    begin
        // [SCENARIO] A numeric outcome is not a JSON boolean.
        // [GIVEN] An EFT payload with success set to 1.
        // [WHEN] The external attempt is submitted.
        // [THEN] The API returns a structured 400 without recording it.
        AssertExternalEFTRejectsInvalidSuccess('1');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_ObjectSuccessReturnsBadRequest()
    begin
        // [SCENARIO] An object cannot stand in for an EFT outcome.
        // [GIVEN] An EFT payload with an object-valued success property.
        // [WHEN] The external attempt is submitted.
        // [THEN] The API returns a structured 400 without recording it.
        AssertExternalEFTRejectsInvalidSuccess('{}');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_ArraySuccessReturnsBadRequest()
    begin
        // [SCENARIO] An array cannot stand in for an EFT outcome.
        // [GIVEN] An EFT payload with an array-valued success property.
        // [WHEN] The external attempt is submitted.
        // [THEN] The API returns a structured 400 without recording it.
        AssertExternalEFTRejectsInvalidSuccess('[]');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RejectsOverlongPSPReference()
    begin
        // [SCENARIO] An overlong pspReference is rejected rather than stored under a different value.
        // [GIVEN] An external attempt with pspReference one character over its storage limit.
        // [WHEN] The caller submits either an authorized or failed attempt.
        // [THEN] Both outcomes fail without recording an attempt, receipt or payment.
        AssertExternalPaymentRejectsLongIdentifier('pspReference', 17, 'EFT', true);
        AssertExternalPaymentRejectsLongIdentifier('pspReference', 17, 'EFT', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RejectsOverlongPARToken()
    begin
        // [SCENARIO] An overlong parToken is rejected rather than stored under a different value.
        // [GIVEN] An external attempt with parToken one character over its storage limit.
        // [WHEN] The caller submits either an authorized or failed attempt.
        // [THEN] Both outcomes fail without recording an attempt, receipt or payment.
        AssertExternalPaymentRejectsLongIdentifier('parToken', 101, 'EFT', true);
        AssertExternalPaymentRejectsLongIdentifier('parToken', 101, 'EFT', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RejectsOverlongCardApplicationId()
    begin
        // [SCENARIO] An overlong cardApplicationId is rejected rather than stored under a different value.
        // [GIVEN] An external attempt with cardApplicationId one character over its storage limit.
        // [WHEN] The caller submits either an authorized or failed attempt.
        // [THEN] Both outcomes fail without recording an attempt, receipt or payment.
        AssertExternalPaymentRejectsLongIdentifier('cardApplicationId', 33, 'EFT', true);
        AssertExternalPaymentRejectsLongIdentifier('cardApplicationId', 33, 'EFT', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RejectsOverlongMaskedCardNo()
    begin
        // [SCENARIO] An overlong maskedCardNo is rejected rather than stored under a different value.
        // [GIVEN] An external attempt with maskedCardNo one character over its storage limit.
        // [WHEN] The caller submits either an authorized or failed attempt.
        // [THEN] Both outcomes fail without recording an attempt, receipt or payment.
        AssertExternalPaymentRejectsLongIdentifier('maskedCardNo', 31, 'EFT', true);
        AssertExternalPaymentRejectsLongIdentifier('maskedCardNo', 31, 'EFT', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RejectsOverlongPaymentMethodCode()
    begin
        // [SCENARIO] An overlong paymentMethodCode is rejected rather than stored under a different value.
        // [GIVEN] An external attempt with paymentMethodCode one character over its storage limit.
        // [WHEN] The caller submits either an authorized or failed attempt.
        // [THEN] Both outcomes fail without recording an attempt, receipt or payment.
        AssertExternalPaymentRejectsLongIdentifier('paymentMethodCode', 11, 'EFT', true);
        AssertExternalPaymentRejectsLongIdentifier('paymentMethodCode', 11, 'EFT', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_CashRejectsOverlongPaymentMethodCode()
    begin
        // [SCENARIO] Cash also rejects an overlong method code rather than selecting its prefix.
        // [GIVEN] A cash method and a code one character over the ten-character limit.
        // [WHEN] The caller submits that code.
        // [THEN] No payment is recorded against the truncated prefix.
        AssertExternalPaymentRejectsLongIdentifier('paymentMethodCode', 11, 'Cash', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_MaximumLengthIdentifiersArePreserved()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentLineId: Guid;
        CardNo: Text;
        PAR: Text;
        CardApplicationId: Text;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Identifiers at their supported limits are stored without losing characters.
        // [GIVEN] A ten-character EFT method and references at every documented length limit.
        CreateSaleForExternalEFT(POSSale);
        POSPaymentMethod := _EFTPaymentMethod;
        POSPaymentMethod.Code := 'EFTMAXCODE';
        POSPaymentMethod.Insert(true);
        PaymentLineId := CreateGuid();
        CardNo := PadStr('', 30, '*');
        PAR := PadStr('PAR-', 100, 'X');
        CardApplicationId := PadStr('AID-', 32, 'X');
        Body.Add('paymentMethodCode', POSPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', true);
        Body.Add('maskedCardNo', CardNo);
        Body.Add('pspReference', '1234567890123456');
        Body.Add('parToken', PAR);
        Body.Add('cardApplicationId', CardApplicationId);

        // [WHEN] The caller submits the authorized payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] Every request and payment-line reference retains the complete supplied value.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Identifiers at the limits must be accepted');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.FindFirst();
        Assert.AreEqual('EFTMAXCODE', EFTTransactionRequest."POS Payment Type Code", 'The full method code must be retained');
        Assert.AreEqual(CardNo, EFTTransactionRequest."Card Number", 'The complete masked card must be retained');
        Assert.AreEqual('1234567890123456', EFTTransactionRequest."PSP Reference", 'The complete PSP reference must be retained');
        Assert.AreEqual('1234567890123456', EFTTransactionRequest."External Transaction ID", 'The external transaction must retain the same PSP');
        Assert.AreEqual('1234567890123456', EFTTransactionRequest."Reference Number Output", 'The output reference must retain the same PSP');
        Assert.AreEqual('', EFTTransactionRequest."External Payment Token", 'An account reference must not be stored as a reusable payment token');
        Assert.AreEqual(PAR, EFTTransactionRequest."Payment Account Reference", 'The complete PAR must reach the account reference');
        Assert.AreEqual(CardApplicationId, EFTTransactionRequest."Card Application ID", 'The complete AID must be retained');
        PaymentLine.GetBySystemId(PaymentLineId);
        Assert.AreEqual('EFTMAXCODE', PaymentLine."No.", 'The payment must use the full method code');
        Assert.AreEqual('1234567890123456', PaymentLine.Reference, 'The payment must retain the complete PSP');
        Assert.AreEqual(CardNo, PaymentLine."EFT Card Number", 'The payment must retain the complete masked card');
        Assert.AreEqual(PAR, PaymentLine."EFT Payment Account Reference", 'The payment must retain the complete PAR');
        Assert.AreEqual(CardApplicationId, PaymentLine."EFT Card Application ID", 'The payment must retain the complete AID');
    end;

    local procedure AssertExternalPaymentRejectsLongIdentifier(PropertyName: Text; ValueLength: Integer; PaymentType: Text; Success: Boolean)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptLines: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        CreateSaleForExternalEFT(POSSale);
        if PaymentType = 'Cash' then
            POSPaymentMethod := _CashPaymentMethod
        else
            POSPaymentMethod := _EFTPaymentMethod;
        if PropertyName = 'paymentMethodCode' then begin
            POSPaymentMethod.Code := 'XXXXXXXXXX';
            POSPaymentMethod.Insert(true);
        end;
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', POSPaymentMethod.Code);
        Body.Add('paymentType', PaymentType);
        Body.Add('amount', 100);
        if PaymentType = 'EFT' then
            Body.Add('success', Success);
        if Body.Contains(PropertyName) then
            Body.Replace(PropertyName, PadStr('', ValueLength, 'X'))
        else
            Body.Add(PropertyName, PadStr('', ValueLength, 'X'));
        ReceiptLines.Add('External attempt');
        Body.Add('eftReceipt', ReceiptLines);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        if PropertyName = 'paymentMethodCode' then
            POSPaymentMethod.Delete(true);

        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'An overlong identifier must return a structured bad request');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('code', JToken);
        Assert.AreEqual('generic_error', JToken.AsValue().AsText(), 'The rejection should use the API error envelope');
        ResponseBody.Get('message', JToken);
        Assert.AreEqual(StrSubstNo('%1 must not exceed %2 characters.', PropertyName, ValueLength - 1), JToken.AsValue().AsText(), 'The rejection should identify the invalid property and its limit');
        Assert.IsTrue(POSSale.GetBySystemId(POSSale.SystemId), 'The arranged sale must survive the rejected identifier');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'An overlong identifier must not leave an EFT request');
        EFTReceipt.SetRange("Register No.", POSSale."Register No.");
        EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.IsTrue(EFTReceipt.IsEmpty(), 'An overlong identifier must not leave receipts');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'An overlong identifier must not create a payment line');
    end;

    local procedure AssertExternalEFTRejectsInvalidSuccess(SuccessJson: Text)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        ReceiptLines: JsonArray;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [GIVEN] A sale and an EFT attempt whose success property is not a boolean.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        JToken.ReadFrom(SuccessJson);
        Body.Add('success', JToken);
        ReceiptLines.Add('External outcome');
        Body.Add('eftReceipt', ReceiptLines);

        // [WHEN] The attempt is submitted.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] The caller receives the JSON validation error with no side effects.
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'EFT success must be a JSON boolean');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('code', JToken);
        Assert.AreEqual('generic_error', JToken.AsValue().AsText(), 'Validation should use the API error envelope');
        ResponseBody.Get('message', JToken);
        Assert.AreEqual('Invalid field: success. Expected a boolean.', JToken.AsValue().AsText(), 'The error should identify the invalid outcome');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'An invalid outcome must not create an EFT request');
        EFTReceipt.SetRange("Register No.", POSSale."Register No.");
        EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.IsTrue(EFTReceipt.IsEmpty(), 'An invalid outcome must not create receipts');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'An invalid outcome must not create a payment line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_NegativeAmountIsRejectedWithoutWrites()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptLines: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] The API rejects external refunds without recording financial data.
        // [GIVEN] A sale and a negative EFT amount.
        CreateSaleForExternalEFT(POSSale);
        Commit();
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', -100);
        Body.Add('success', true);
        Body.Add('pspReference', 'REFUND-PSP');
        ReceiptLines.Add('External refund');
        Body.Add('eftReceipt', ReceiptLines);

        // [WHEN] The external system submits the refund.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        // [THEN] A structured 400 rejects the refund without changing the sale or payment records.
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'A negative EFT amount must return a bad request');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('code', JToken);
        Assert.AreEqual('generic_error', JToken.AsValue().AsText(), 'The refund rejection must use the API error envelope');
        ResponseBody.Get('message', JToken);
        Assert.AreEqual('refunds not implemented', JToken.AsValue().AsText(), 'The rejection must explain that refunds are not implemented');
        Assert.IsTrue(POSSale.GetBySystemId(POSSale.SystemId), 'The arranged sale should survive the rejected request');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'A rejected refund must not leave an EFT request');
        EFTReceipt.SetRange("Register No.", POSSale."Register No.");
        EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.IsTrue(EFTReceipt.IsEmpty(), 'A rejected refund must not leave a receipt');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'A rejected refund must not leave a payment line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_MappedCardMetadataSurvivesCompletion()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        PostedPaymentLine: Record "NPR POS Entry Payment Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentLineId: Guid;
        PAR: Text;
        OriginalDescription: Text[50];
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Mapped external card metadata remains linked after posting.
        // [GIVEN] An LCY EFT mapping and an authorized payment with a 100-character account reference.
        InitializeEFTMapping();
        CreateSaleForExternalEFT(POSSale);
        _VisaPaymentMethod.TestField("Currency Code", '');
        _VisaPaymentMethod.TestField("Fixed Rate", 0);
        _VisaPaymentMethod.TestField("Use Stand. Exc. Rate for Bal.", false);
        OriginalDescription := _VisaPaymentMethod.Description;
        _VisaPaymentMethod.Description := 'Visa external card payment';
        _VisaPaymentMethod.Modify();
        PaymentLineId := CreateGuid();
        PAR := PadStr('PAR-', 100, 'X');
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('description', 'QR payment');
        Body.Add('success', true);
        Body.Add('maskedCardNo', '411111******1234');
        Body.Add('pspReference', 'MERCHANT.PSP-42');
        Body.Add('parToken', PAR);
        Body.Add('cardApplicationId', 'A0000000031010');
        // [WHEN] The external system submits the payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        _VisaPaymentMethod.Description := OriginalDescription;
        _VisaPaymentMethod.Modify();

        // [THEN] The request and active line retain the mapped method and complete card references.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The mapped external payment should be accepted');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.FindFirst();
        Assert.AreEqual(PAR, EFTTransactionRequest."Payment Account Reference", 'The full PAR should be stored in its account reference field');
        Assert.AreEqual('', EFTTransactionRequest."External Payment Token", 'An account reference must not be stored as a reusable payment token');
        Assert.AreEqual('MERCHANT.PSP-42', EFTTransactionRequest."PSP Reference", 'The supplied PSP reference must not be split as a terminal ID');
        Assert.AreEqual('MERCHANT.PSP-42', EFTTransactionRequest."External Transaction ID", 'The external transaction should identify the supplied PSP reference');
        Assert.AreEqual('MERCHANT.PSP-42', EFTTransactionRequest."Reference Number Output", 'The output reference should identify the external attempt');
        Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."Original POS Payment Type Code", 'The original payment method should be retained');
        Assert.AreEqual(_VisaPaymentMethod.Code, EFTTransactionRequest."POS Payment Type Code", 'The card should select the mapped method');
        Assert.AreEqual('Visa external card payme', EFTTransactionRequest."Card Name", 'The mapped description should fit the card name field');

        PaymentLine.GetBySystemId(PaymentLineId);
        Assert.AreEqual('MERCHANT.PSP-42', PaymentLine.Reference, 'The active payment line should carry the external reference');
        Assert.AreEqual('QR payment', PaymentLine.Description, 'The supplied POS description should survive mapping');
        Assert.AreEqual('411111******1234', PaymentLine."EFT Card Number", 'The active line should retain the masked card');
        Assert.AreEqual('Visa external card payme', PaymentLine."EFT Card Name", 'The active line should retain the mapped card name');
        Assert.AreEqual('A0000000031010', PaymentLine."EFT Card Application ID", 'The active line should retain the AID');
        Assert.AreEqual(PAR, PaymentLine."EFT Payment Account Reference", 'The active line should retain the full PAR');
        // [WHEN] The authorized sale is completed.
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The authorized sale should complete');
        // [THEN] Posting preserves the payment ID and card metadata.
        Assert.IsTrue(PostedPaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID"), 'Reconciliation should resolve the posted line through the stored ID');
        Assert.AreEqual(PaymentLineId, PostedPaymentLine.SystemId, 'Posting should preserve the caller payment ID');
        Assert.IsTrue(PostedPaymentLine.EFT, 'The posted payment should remain approved EFT');
        Assert.AreEqual(100, PostedPaymentLine."Amount (LCY)", 'The posted amount should equal the authorized result');
        Assert.AreEqual('411111******1234', PostedPaymentLine."EFT Card Number", 'Posting should preserve the masked card');
        Assert.AreEqual('Visa external card payme', PostedPaymentLine."EFT Card Name", 'Posting should preserve the mapped card name');
        Assert.AreEqual('A0000000031010', PostedPaymentLine."EFT Card Application ID", 'Posting should preserve the AID');
        Assert.AreEqual(PAR, PostedPaymentLine."EFT Payment Account Reference", 'Posting should preserve the full PAR');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RequestAndReceiptsUseSessionTimeZone()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryTimeZone: Codeunit "NPR Library - Time Zone";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        BeforeRequest: DateTime;
        AfterRequest: DateTime;
        Body: JsonObject;
        Response: JsonObject;
        ReceiptLines: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] The attempt and its receipts share the API session's local timestamp.
        // [GIVEN] A declined attempt with two receipt lines and a configured API time zone.
        CreateSaleForExternalEFT(POSSale);
        LibraryTimeZone.SetSessionEntraAppTimeZone();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', false);
        ReceiptLines.Add('Payment declined');
        ReceiptLines.Add('Please try again');
        Body.Add('eftReceipt', ReceiptLines);
        BeforeRequest := CurrentDateTime;
        // [WHEN] The external system submits the payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        AfterRequest := CurrentDateTime;
        LibraryTimeZone.ClearSessionEntraAppTimeZone();

        // [THEN] The request and receipts share the API session's local transaction date and time.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The failed attempt should be recorded');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.FindFirst();
        Assert.AreNotEqual(0D, EFTTransactionRequest."Transaction Date", 'Even a failed attempt should have a transaction date');
        Assert.IsTrue((EFTTransactionRequest.Started >= BeforeRequest) and (EFTTransactionRequest.Started <= AfterRequest), 'The recording timestamp should fall within the API call');
        Assert.AreEqual(EFTTransactionRequest.Started, EFTTransactionRequest.Finished, 'An externally processed attempt should use one recording timestamp');
        LibraryTimeZone.AssertDateTimePartsInTimeZoneRange(EFTTransactionRequest."Transaction Date", EFTTransactionRequest."Transaction Time", BeforeRequest, AfterRequest, 'External EFT recording time');
        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.AreEqual(2, EFTReceipt.Count(), 'Both receipt lines should be recorded');
        EFTReceipt.FindSet();
        repeat
            Assert.AreEqual(EFTTransactionRequest."Transaction Date", EFTReceipt.Date, 'Receipt reprinting must find the same local transaction date');
            Assert.AreEqual(EFTTransactionRequest."Transaction Time", EFTReceipt."Transaction Time", 'Receipt lines should use the same local transaction time');
        until EFTReceipt.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_CashFixedRateUsesNormalPOSConversion()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        PostedPaymentLine: Record "NPR POS Entry Payment Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Cash retains the normal POS fixed-rate conversion without an EFT outcome.
        // [GIVEN] A 100 LCY sale and a cash method worth 2 LCY per foreign currency unit.
        CreateSaleForExternalEFT(POSSale);
        GLSetup.Get();
        repeat
            LibraryERM.CreateCurrency(Currency);
        until Currency.Code <> GLSetup."LCY Code";
        Currency.InitRoundingPrecision();
        Currency.Modify();
        LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        POSPaymentMethod."Currency Code" := Currency.Code;
        POSPaymentMethod."Fixed Rate" := 200;
        POSPaymentMethod."Use Stand. Exc. Rate for Bal." := false;
        POSPaymentMethod.Modify();
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', POSPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', 100);

        // [WHEN] The caller records a cash payment without the EFT-only success property.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] Normal POS insertion records 50 foreign units as 100 LCY and creates no EFT request.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cash should retain its existing contract');
        PaymentLine.GetBySystemId(PaymentLineId);
        Assert.AreEqual(100, PaymentLine."Amount Including VAT", 'The cash payment should cover the 100 LCY sale');
        Assert.AreEqual(50, PaymentLine."Currency Amount", 'The fixed rate should convert 100 LCY to 50 foreign units');
        Assert.IsFalse(PaymentLine."EFT Approved", 'A cash payment is not an EFT authorization');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'Cash must not create an EFT request');

        // [WHEN] The cash-paid sale is completed.
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Posting preserves both currency amounts and the cash method's currency.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The cash-paid sale should complete');
        PostedPaymentLine.GetBySystemId(PaymentLineId);
        Assert.AreEqual(100, PostedPaymentLine."Amount (LCY)", 'Posting must preserve the local cash amount');
        Assert.AreEqual(50, PostedPaymentLine.Amount, 'Posting must preserve the fixed-rate foreign amount');
        Assert.AreEqual(Currency.Code, PostedPaymentLine."Currency Code", 'Posting must preserve the cash method currency');
        Assert.IsFalse(PostedPaymentLine.EFT, 'The posted payment must remain cash');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_ZeroAuthorizationCreatesApprovedLine()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] A zero authorization creates a linked approved line without financial impact.
        // [GIVEN] A sale and an explicitly successful zero-amount EFT attempt.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 0);
        Body.Add('success', true);
        // [WHEN] The external system submits the payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        // [THEN] An approved zero-value line links to a successful, nonfinancial request.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'A zero authorization should be accepted');
        Assert.IsTrue(PaymentLine.GetBySystemId(PaymentLineId), 'A zero authorization should still create the caller payment line');
        Assert.IsTrue(PaymentLine."EFT Approved", 'The zero payment line should remain approved');
        Assert.AreEqual(0, PaymentLine."Amount Including VAT", 'The approved line should have zero amount');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.FindFirst();
        Assert.IsTrue(EFTTransactionRequest.Successful, 'The zero attempt should retain its successful outcome');
        Assert.IsFalse(EFTTransactionRequest."Financial Impact", 'A zero authorization has no financial impact');
        Assert.AreEqual(0, EFTTransactionRequest."Result Amount", 'A zero authorization has a zero result');
        Assert.AreEqual(PaymentLineId, EFTTransactionRequest."Sales Line ID", 'The zero request should link to its payment line');
        Assert.AreEqual(PaymentLine."Line No.", EFTTransactionRequest."Sales Line No.", 'The zero request should retain its payment line number');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_RefundGuardDoesNotChangeCash()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Negative cash amounts remain accepted without an EFT outcome.
        // [GIVEN] A cash payload with a negative amount and no success property.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', -10);
        // [WHEN] The external system submits the payment.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        // [THEN] The negative cash payment retains the existing cash behavior.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Negative cash handling should be unchanged');
        PaymentLine.GetBySystemId(PaymentLineId);
        Assert.AreEqual(-10, PaymentLine."Amount Including VAT", 'The cash line should retain its negative amount');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'Cash should not create an EFT request');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_FailedAttemptCanBeRetriedWithSameLineId()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        FailedRequestEntryNo: Integer;
        ReceiptEntryNo: Integer;
        ReceiptLines: JsonArray;
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] A failed attempt does not consume the ID needed by a later authorization.
        // [GIVEN] A recorded failed attempt and a reusable caller payment-line ID.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', false);
        Body.Add('pspReference', 'RETRIED-PSP');
        ReceiptLines.Add('DECLINED');
        Body.Add('eftReceipt', ReceiptLines);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The failed attempt should be logged');
        // [WHEN] The provider reports an authorization using the same ID.
        Body.Replace('success', true);
        Clear(ReceiptLines);
        ReceiptLines.Add('APPROVED');
        ReceiptLines.Add('AUTH: 123456');
        Body.Replace('eftReceipt', ReceiptLines);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        // [THEN] Only the authorization pays the sale, and each attempt retains its own receipts.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The authorization should be accepted with the same caller ID');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('totalPaymentAmount', JToken);
        Assert.AreEqual(100, JToken.AsValue().AsDecimal(), 'Only the successful attempt should pay the sale');
        Assert.IsTrue(PaymentLine.GetBySystemId(PaymentLineId), 'The retry should create the caller payment line');
        Assert.IsTrue(PaymentLine."EFT Approved", 'The retry should be approved');
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.SetRange("PSP Reference", 'RETRIED-PSP');
        Assert.AreEqual(2, EFTTransactionRequest.Count(), 'Both outcomes should remain in the audit trail');
        EFTTransactionRequest.SetRange(Successful, false);
        EFTTransactionRequest.FindFirst();
        FailedRequestEntryNo := EFTTransactionRequest."Entry No.";
        Assert.IsFalse(EFTTransactionRequest."Financial Impact", 'The earlier failed attempt must remain nonfinancial');
        Assert.IsTrue(IsNullGuid(EFTTransactionRequest."Sales Line ID"), 'The earlier failed attempt must remain unlinked');
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.FindFirst();
        Assert.AreEqual(PaymentLineId, EFTTransactionRequest."Sales Line ID", 'Only the authorization should link to the payment line');
        EFTReceipt.SetRange("Register No.", POSSale."Register No.");
        EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.AreEqual(3, EFTReceipt.Count(), 'Both attempts must retain their receipts');
        EFTReceipt.FindSet();
        repeat
            ReceiptEntryNo += 1;
            Assert.AreEqual(ReceiptEntryNo, EFTReceipt."Entry No.", 'Receipt entry numbers must remain distinct and sequential across attempts');
            if ReceiptEntryNo = 1 then begin
                Assert.AreEqual(FailedRequestEntryNo, EFTReceipt."EFT Trans. Request Entry No.", 'The declined receipt must retain its original request link');
                Assert.AreEqual('DECLINED', EFTReceipt.Text, 'The declined receipt must not be overwritten');
            end else begin
                Assert.AreEqual(EFTTransactionRequest."Entry No.", EFTReceipt."EFT Trans. Request Entry No.", 'The approved receipt must link to the successful request');
                if ReceiptEntryNo = 2 then
                    Assert.AreEqual('APPROVED', EFTReceipt.Text, 'The approval must be appended after the declined receipt')
                else
                    Assert.AreEqual('AUTH: 123456', EFTReceipt.Text, 'All approved receipt lines must be retained');
            end;
        until EFTReceipt.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_DoubleSuccessWithSameIdDoesNotDuplicatePayment()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        PaymentLineId: Guid;
        RequestId: Guid;
        RequestEntryNo: Integer;
        PaymentLineNo: Integer;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        ReceiptLines: JsonArray;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Retrying an authorized payment with the same ID cannot pay the sale twice.
        // [GIVEN] A persisted authorized EFT payment and its two receipt lines.
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', true);
        Body.Add('pspReference', 'DOUBLE-SUCCESS');
        ReceiptLines.Add('APPROVED');
        ReceiptLines.Add('AUTH: 123456');
        Body.Add('eftReceipt', ReceiptLines);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The first authorization should be recorded');
        PaymentLine.GetBySystemId(PaymentLineId);
        PaymentLineNo := PaymentLine."Line No.";
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        EFTTransactionRequest.FindFirst();
        RequestId := EFTTransactionRequest.SystemId;
        RequestEntryNo := EFTTransactionRequest."Entry No.";
        Commit();

        // [WHEN] The exact successful payload is submitted again with the same ID.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] Only the original financial request, approved line and receipts remain.
        Assert.AreEqual(1, EFTTransactionRequest.Count(), 'A duplicate success must not create another EFT request');
        EFTTransactionRequest.FindFirst();
        Assert.AreEqual(RequestId, EFTTransactionRequest.SystemId, 'The original request must remain unchanged');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'The original outcome must remain successful');
        Assert.IsTrue(EFTTransactionRequest."Financial Impact", 'The original payment must remain financial');
        Assert.AreEqual(100, EFTTransactionRequest."Result Amount", 'The original authorized amount must be preserved');
        Assert.AreEqual(PaymentLineId, EFTTransactionRequest."Sales Line ID", 'The request must retain its payment-line ID');
        Assert.AreEqual(PaymentLineNo, EFTTransactionRequest."Sales Line No.", 'The request must retain its payment-line number');
        PaymentLine.SetRange("Register No.", POSSale."Register No.");
        PaymentLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        PaymentLine.SetRange("Line Type", PaymentLine."Line Type"::"POS Payment");
        Assert.AreEqual(1, PaymentLine.Count(), 'Only one payment line may exist for the authorization');
        PaymentLine.FindFirst();
        Assert.AreEqual(PaymentLineId, PaymentLine.SystemId, 'The approved line must retain the caller ID');
        Assert.IsTrue(PaymentLine."EFT Approved", 'The remaining line must stay approved');
        EFTReceipt.SetRange("Register No.", POSSale."Register No.");
        EFTReceipt.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        Assert.AreEqual(2, EFTReceipt.Count(), 'The replay must not duplicate receipts');
        EFTReceipt.FindSet();
        repeat
            Assert.AreEqual(RequestEntryNo, EFTReceipt."EFT Trans. Request Entry No.", 'Receipts must stay linked to the original request');
        until EFTReceipt.Next() = 0;
        Response.Get('statusCode', JToken);
        Assert.AreEqual(400, JToken.AsValue().AsInteger(), 'An already-used payment ID should be rejected');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('code', JToken);
        Assert.AreEqual('generic_error', JToken.AsValue().AsText(), 'The duplicate rejection must use the API error envelope');
        ResponseBody.Get('message', JToken);
        Assert.IsTrue(StrPos(JToken.AsValue().AsText(), Format(PaymentLineId)) > 0, 'The duplicate rejection must identify the already-used ID');

        // [WHEN] The sale is retrieved after the rejected replay.
        Clear(Body);
        QueryParams.Add('withLines', 'true');
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(POSSale.SystemId), Body, QueryParams, Headers);

        // [THEN] Its total still contains exactly one payment.
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The paid sale should still be retrievable');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('totalPaymentAmount', JToken);
        Assert.AreEqual(100, JToken.AsValue().AsDecimal(), 'A duplicate success must not increase the sale payment total');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_FailedAttemptDoesNotParkAbandonedSale()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SaleId: Guid;
        OriginalWorkDate: Date;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Cleanup deletes an abandoned sale that has only a failed EFT attempt.
        // [GIVEN] An abandoned sale with a recorded failure and no approved payment.
        CreateSaleForExternalEFT(POSSale);
        SaleId := POSSale.SystemId;
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', false);
        Body.Add('pspReference', 'ABANDONED-PSP');
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The failed attempt should be recorded');
        Commit();
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+2D>', POSSale.Date));
        // [WHEN] The cleanup job processes the expired sale.
        RunCleanupJob();
        WorkDate(OriginalWorkDate);
        // [THEN] The failed attempt remains in the audit log but does not cause the sale to be parked.
        Assert.IsFalse(POSSale.GetBySystemId(SaleId), 'Cleanup should remove the unpaid abandoned sale');
        Assert.IsFalse(POSSavedSaleEntry.GetBySystemId(SaleId), 'A failed PSP attempt should not cause the sale to be parked');
        EFTTransactionRequest.SetRange("Sales ID", SaleId);
        Assert.AreEqual(1, EFTTransactionRequest.Count(), 'Cleanup should retain the failed audit record');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_FailedAttemptRejectsMissingMethod()
    begin
        // [SCENARIO] An unknown payment method is rejected even on a failed attempt.
        // [GIVEN] A failed EFT payload naming a nonexistent payment method.
        // [WHEN] The external attempt is submitted to the API.
        // [THEN] Its outcome is validated without creating a payment line.
        AssertExternalEFTRejectsInvalidMethod(false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExternalEFT_FailedAttemptRejectsBlockedMappedMethod()
    begin
        // [SCENARIO] A blocked mapped method is rejected even on a failed attempt.
        // [GIVEN] A failed EFT payload whose card maps to a blocked payment method.
        // [WHEN] The external attempt is submitted to the API.
        // [THEN] Its outcome is validated without creating a payment line.
        AssertExternalEFTRejectsInvalidMethod(true);
    end;

    local procedure AssertExternalEFTRejectsInvalidMethod(BlockedMappedMethod: Boolean)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryEFT: Codeunit "NPR Library - EFT";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTBINGroup: Record "NPR EFT BIN Group";
        PaymentLineId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        if BlockedMappedMethod then begin
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::EFT, '', false);
            POSPaymentMethod."Block POS Payment" := true;
            POSPaymentMethod.Modify();
            LibraryEFT.CreateBINGroup(EFTBINGroup, CopyStr(FormatGuid(CreateGuid()), 1, 10), 'Blocked external card', 4);
            LibraryEFT.CreateBINRange(EFTBINGroup.Code, 610002, 610002);
            LibraryEFT.CreateBINGroupPaymentLink(EFTBINGroup.Code, POSPaymentMethod.Code);
            Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
            Body.Add('maskedCardNo', '610002******1234');
        end else begin
            POSPaymentMethod.Code := CopyStr(FormatGuid(CreateGuid()), 1, 10);
            Body.Add('paymentMethodCode', POSPaymentMethod.Code);
        end;
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', false);
        Commit();
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        if BlockedMappedMethod then
            Assert.ExpectedError(POSPaymentMethod.FieldCaption("Block POS Payment"))
        else
            Assert.ExpectedError(POSPaymentMethod.Code);
        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.IsTrue(EFTTransactionRequest.IsEmpty(), 'An invalid payment method must not leave an EFT audit record');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'An invalid payment method must not create a payment line');
    end;

    local procedure AssertExternalEFTAttemptIsAuditOnly()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSale: Record "NPR POS Sale";
        PaymentLine: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
        PaymentLineId: Guid;
        PAR: Text;
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        ReceiptLines: JsonArray;
        JToken: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        CreateSaleForExternalEFT(POSSale);
        PaymentLineId := CreateGuid();
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', 100);
        Body.Add('success', false);
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', 'FAILED-PSP');
        PAR := PadStr('FAILED-PAR-', 100, 'X');
        Body.Add('parToken', PAR);
        Body.Add('cardApplicationId', 'A0000000031010');
        ReceiptLines.Add('Payment declined');
        Body.Add('eftReceipt', ReceiptLines);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        Response.Get('statusCode', JToken);
        Assert.AreEqual(201, JToken.AsValue().AsInteger(), 'A failed attempt should be accepted for logging');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('totalPaymentAmount', JToken);
        Assert.AreEqual(0, JToken.AsValue().AsDecimal(), 'A failed attempt must not pay the sale');
        ResponseBody.Get('refreshedPaymentLines', JToken);
        Assert.AreEqual(0, JToken.AsArray().Count(), 'No payment line should be returned');
        Assert.IsFalse(PaymentLine.GetBySystemId(PaymentLineId), 'A failed attempt must not consume the caller payment line ID');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(POSSale.SystemId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        Assert.AreEqual(404, JToken.AsValue().AsInteger(), 'There should be no payment line to retrieve');

        EFTTransactionRequest.SetRange("Sales ID", POSSale.SystemId);
        Assert.AreEqual(1, EFTTransactionRequest.Count(), 'One audit record should be retained');
        EFTTransactionRequest.FindFirst();
        Assert.AreEqual(100, EFTTransactionRequest."Amount Input", 'The attempted amount should be retained');
        Assert.AreEqual(0, EFTTransactionRequest."Amount Output", 'A failed attempt has no authorized output');
        Assert.AreEqual(0, EFTTransactionRequest."Result Amount", 'A failed attempt has no financial result');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'The attempt should remain unsuccessful');
        Assert.IsFalse(EFTTransactionRequest."Financial Impact", 'A failed attempt must not have financial impact');
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'The external outcome is known');
        Assert.IsTrue(EFTTransactionRequest."Result Processed", 'The failed outcome should be fully recorded');
        Assert.IsTrue(IsNullGuid(EFTTransactionRequest."Sales Line ID"), 'A failed attempt must not link to a payment line');
        Assert.AreEqual(0, EFTTransactionRequest."Sales Line No.", 'A failed attempt must not have a payment line number');
        Assert.AreEqual('FAILED-PSP', EFTTransactionRequest."PSP Reference", 'A PSP reference does not imply authorization');
        Assert.AreEqual('************1234', EFTTransactionRequest."Card Number", 'Failed card metadata should be retained');
        Assert.AreEqual('', EFTTransactionRequest."External Payment Token", 'An account reference must not be stored as a reusable payment token');
        Assert.AreEqual(PAR, EFTTransactionRequest."Payment Account Reference", 'The complete failed account reference should be retained');
        Assert.AreEqual('A0000000031010', EFTTransactionRequest."Card Application ID", 'The supplied AID should be retained');
        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.AreEqual(1, EFTReceipt.Count(), 'The failed receipt should be retained');
        EFTReceipt.FindFirst();
        Assert.AreEqual('Payment declined', EFTReceipt.Text, 'The receipt should retain the external outcome');
    end;

    local procedure CreateSaleForExternalEFT(var POSSale: Record "NPR POS Sale")
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        SaleId: Guid;
        Body: JsonObject;
        Response: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Initialize();
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Sale should be created for the external attempt');
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The sale should contain an item');
        POSSale.GetBySystemId(SaleId);
    end;

    local procedure RunCleanupJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        CleanupDeadPOSSales: Codeunit "NPR JQ Cleanup Dead POS Sales";
    begin
        JobQueueEntry.Init();
        CleanupDeadPOSSales.Run(JobQueueEntry);
    end;

    local procedure CreateCleanupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Cleanup Dead POS Sales";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibrarySales: Codeunit "Library - Sales";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);

        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
        _Item."Unit Price" := 100;
        _Item.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item2, _POSUnit, _POSStore);
        _Item2."Unit Price" := 50;
        _Item2.Modify();

        _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
        _CashPaymentMethod.FindFirst();

        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_EFTPaymentMethod, _EFTPaymentMethod."Processing Type"::EFT, '', false);

        LibrarySales.CreateSalesperson(_Salesperson);

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure InitializeRestaurant()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        Initialize();

        if _RestaurantInitialized then
            exit;

        LibraryRestaurant.SetupRestaurantForKitchenOrders(_POSUnit, _Seating);
        LibraryRestaurant.SetupItemForKitchenOrders(_Item);

        _RestaurantInitialized := true;
        Commit();
    end;

    local procedure InitializeAddon()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        Initialize();

        if _AddonInitialized then
            exit;

        // Create addon item
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_AddonItem, _POSUnit, _POSStore);
        _AddonItem."Unit Price" := 25;
        _AddonItem.Modify();

        // Create item addon and link to main item
        LibraryRestaurant.CreateItemAddon(_ItemAddon);
        LibraryRestaurant.LinkItemToAddon(_Item, _ItemAddon."No.");

        _AddonInitialized := true;
        Commit();
    end;

    local procedure VerifyRestaurantSetupForKitchenOrders()
    var
        Assert: Codeunit Assert;
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        // Verify Restaurant Setup
        RestaurantSetup.Get();
        Assert.AreEqual(
            RestaurantSetup."Serving Step Discovery Method"::"Item Routing Profiles",
            RestaurantSetup."Serving Step Discovery Method",
            StrSubstNo('Restaurant Setup should use Item Routing Profiles discovery method, but has %1', RestaurantSetup."Serving Step Discovery Method"));
        Assert.IsTrue(RestaurantSetup."KDS Active", 'Restaurant Setup KDS Active should be true');

        // Verify Item has routing profile
        Item.Get(_Item."No.");
        Assert.AreNotEqual('', Item."NPR NPRE Item Routing Profile",
            StrSubstNo('Item %1 should have a routing profile assigned', Item."No."));

        // Verify routing profile exists
        Assert.IsTrue(ItemRoutingProfile.Get(Item."NPR NPRE Item Routing Profile"),
            StrSubstNo('Item Routing Profile %1 should exist', Item."NPR NPRE Item Routing Profile"));

        // Verify flow statuses are assigned to the routing profile
        AssignedFlowStatus.SetRange("Table No.", DATABASE::"NPR NPRE Item Routing Profile");
        AssignedFlowStatus.SetRange("Record ID", ItemRoutingProfile.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        Assert.IsFalse(AssignedFlowStatus.IsEmpty(),
            StrSubstNo('Item Routing Profile %1 should have flow statuses assigned', ItemRoutingProfile.Code));

        // Verify meal flow statuses exist
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        Assert.IsFalse(FlowStatus.IsEmpty(), 'Meal flow statuses should exist in the database');

        // Verify seating links to a restaurant with KDS active
        SeatingLocation.Get(_Seating."Seating Location");
        Restaurant.Get(SeatingLocation."Restaurant Code");
        Assert.AreEqual(Restaurant."KDS Active"::Yes, Restaurant."KDS Active",
            StrSubstNo('Restaurant %1 should have KDS Active = Yes', Restaurant.Code));
    end;

    local procedure InitializeMenu()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
    begin
        InitializeRestaurant();
        InitializeAddon();

        if _MenuInitialized then
            exit;

        // Get the restaurant from the POS unit's profile
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        // Create menu and category
        LibraryRestaurant.CreateMenu(_Menu, Restaurant.Code);

        // Setup user's POS unit for menu pricing
        LibraryRestaurant.SetupUserPOSUnit(_POSUnit."No.");

        _MenuInitialized := true;
        Commit();
    end;

    local procedure InitializeEFTMapping()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryEFT: Codeunit "NPR Library - EFT";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        Initialize();

        if _EFTMappingInitialized then
            exit;

        EFTBINGroupPaymentLink.DeleteAll();
        EFTBINRange.DeleteAll();
        EFTBINGroup.DeleteAll();

        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_VisaPaymentMethod, _VisaPaymentMethod."Processing Type"::EFT, '', false);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_MastercardPaymentMethod, _MastercardPaymentMethod."Processing Type"::EFT, '', false);

        LibraryEFT.CreateBINGroup(EFTBINGroup, 'VISA', 'Visa', 1);
        LibraryEFT.CreateBINRange('VISA', 400000, 499999);
        LibraryEFT.CreateBINGroupPaymentLink('VISA', _VisaPaymentMethod.Code);

        LibraryEFT.CreateBINGroup(EFTBINGroup, 'MC', 'Mastercard', 2);
        LibraryEFT.CreateBINRange('MC', 510000, 559999);
        LibraryEFT.CreateBINGroupPaymentLink('MC', _MastercardPaymentMethod.Code);

        _EFTMappingInitialized := true;
        Commit();
    end;

    local procedure AssertBillingEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        Assert.IsTrue(
            BillingQueueEntry.FindFirst(),
            StrSubstNo('Billing event %1 with ID %2 should be registered.', EventType, Format(EventId, 0, 4)));
        Assert.AreEqual(EventType.AsInteger(), BillingQueueEntry."Feature ID", 'Billing event type should match');
        Assert.AreEqual(ExpectedQuantity, BillingQueueEntry.Quantity, 'Billing event quantity should match');
    end;

    local procedure AssertAmountBillingEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MetadataJson: JsonObject;
        CurrencyToken: JsonToken;
    begin
        AssertBillingEvent(EventId, EventType, ExpectedQuantity);

        BillingQueueEntry.SetRange("Event ID", EventId);
        BillingQueueEntry.FindFirst();
        Assert.IsTrue(MetadataJson.ReadFrom(BillingQueueEntry.GetMetadata()), 'Billing event metadata should be valid JSON');
        Assert.IsTrue(MetadataJson.Get('currency', CurrencyToken), 'Amount billing event metadata should contain currency');

        GeneralLedgerSetup.Get();
        Assert.AreEqual(GeneralLedgerSetup."LCY Code", CurrencyToken.AsValue().AsText(), 'Amount billing event currency should match LCY');
    end;

    local procedure AssertBillingEventNotRegistered(EventId: Guid)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        Assert.IsTrue(
            BillingQueueEntry.IsEmpty(),
            StrSubstNo('Billing event with ID %1 should not be registered.', Format(EventId, 0, 4)));
    end;

    local procedure AssertSingleSaleArray(Response: JsonObject; ExpectedSaleId: Guid; AssertionContext: Text)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        ResponseBody: JsonArray;
        SaleToken: JsonToken;
        SaleObject: JsonObject;
        SaleIdToken: JsonToken;
    begin
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), AssertionContext + ' should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBodyAsArray(Response);
        Assert.AreEqual(1, ResponseBody.Count(), AssertionContext + ' should return one sale');
        Assert.IsTrue(ResponseBody.Get(0, SaleToken), AssertionContext + ' should contain a sale');
        SaleObject := SaleToken.AsObject();
        Assert.IsTrue(SaleObject.Get('saleId', SaleIdToken), AssertionContext + ' should contain saleId');
        Assert.AreEqual(FormatGuid(ExpectedSaleId), SaleIdToken.AsValue().AsText(), AssertionContext + ' should return the expected sale');
    end;

    local procedure InsertPOSSaleForUser(POSUnitNo: Code[10]; SalesTicketNo: Code[20]; SaleUserId: Code[50]) SaleId: Guid
    var
        POSSale: Record "NPR POS Sale";
    begin
        POSSale.Init();
        POSSale."Register No." := POSUnitNo;
        POSSale."Sales Ticket No." := SalesTicketNo;
        POSSale."POS Store Code" := _POSStore.Code;
        POSSale.Date := Today;
        POSSale.Insert(true);
        POSSale."User ID" := SaleUserId;
        POSSale.Modify();
        exit(POSSale.SystemId);
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
