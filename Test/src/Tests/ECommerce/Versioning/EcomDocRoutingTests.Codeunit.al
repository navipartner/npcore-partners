codeunit 85586 "NPR Ecom Doc Routing Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _ApiVersionHeaderLbl: Label 'x-api-version', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenNoHeader_WhenGetById_ThenLabelMatchesTodayPinnedRequest()
    var
        HeaderlessHandler: Codeunit "NPR EcomApiHandler";
        PinnedHandler: Codeunit "NPR EcomApiHandler";
        HeaderlessLabel: Text;
        PinnedLabel: Text;
    begin
        // [Scenario] A get by id without x-api-version is labelled absent and routed like a request that names today.

        // [Given] One get by id request without the header and one that names today's date
        // [When] Each request runs through the handler
        HeaderlessLabel := RunGetById(HeaderlessHandler, '', false);
        PinnedLabel := RunGetById(PinnedHandler, Format(Today(), 0, 9), true);

        // [Then] The headerless label has state absent and both labels name the same route
        _Assert.AreEqual('absent', StateOf(HeaderlessLabel), 'A request without the header must be labelled absent; got: ' + HeaderlessLabel);
        _Assert.AreEqual('date', StateOf(PinnedLabel), 'A request that names today must be labelled date; got: ' + PinnedLabel);
        _Assert.AreEqual(RoutedToOf(PinnedLabel), RoutedToOf(HeaderlessLabel), 'A request without the header must be routed like one that names today.');
    end;

    [Test]
    procedure GivenEmptyHeader_WhenGetById_ThenLabelIsGetV1()
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] A get by id with an empty x-api-version is labelled empty and served by V1.

        // [Given] A get by id request whose version header is empty
        // [When] The request runs through the handler
        // [Then] The label is get|empty|GetV1
        _Assert.AreEqual('get|empty|GetV1', RunGetById(Handler, '', true), 'An empty version header must route get by id to V1.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenGetById_ThenLabelIsRejectedAndRunFails()
    var
        Handler: Codeunit "NPR EcomApiHandler";
        Request: Codeunit "NPR API Request";
    begin
        // [Scenario] A malformed x-api-version rejects get by id and fails the handler run.

        // [Given] A get by id request whose version header is not a date
        InitGetByIdRequest(Request, 'not-a-date', true);
        Handler.SetRequest(Enum::"NPR EcomApiFunctions"::GET_SALES_DOCUMENT, Request);

        // [When] The request runs through the handler
        // [Then] The run fails and the label is get|invalid|rejected
        _Assert.IsFalse(Handler.Run(), 'A version header that is not a date must fail the run.');
        _Assert.AreEqual('get|invalid|rejected', Handler.LastRoute(), 'A version header that is not a date must be labelled rejected.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenFind_ThenLabelIsRejectedAndAnswers400()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        // [Scenario] A malformed x-api-version makes find return 400 and records the rejected route.

        // [Given] The API permission and a committed document whose e-mail the find names
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The find runs through the API with an x-api-version that is not a date
        QueryParameters.Add('email', EcomSalesHeader."Sell-to Email");
        Response := _LibDocApi.Find(QueryParameters, 'not-a-date', true);

        // [Then] The answer is 400
        _Assert.AreEqual(400, _LibDocApi.StatusOf(Response), 'A find whose x-api-version is not a date must answer HTTP 400.');

        // [When] The same find runs through the handler
        // [Then] The run fails and the label is find|invalid|rejected
        _Assert.IsFalse(RunFindHandler(Handler, EcomSalesHeader."Sell-to Email", 'not-a-date', true), 'A find whose version header is not a date must fail the run.');
        _Assert.AreEqual('find|invalid|rejected', Handler.LastRoute(), 'A find whose version header is not a date must be labelled rejected.');
    end;

    [Test]
    procedure GivenV2Header_WhenCreate_ThenLabelIsCreateV2()
    var
        Handler: Codeunit "NPR EcomApiHandler";
        Request: Codeunit "NPR API Request";
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
    begin
        // [Scenario] A create under the V2 date is labelled date and served by the V2 create.

        // [Given] A create request that names the V2 date
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Headers.Add(_ApiVersionHeaderLbl, Format(Handler.V2From(), 0, 9));
        Request.Init("Http Method"::POST, '/ecommerce/documents', PathSegments, QueryParams, Headers, Body.AsToken());
        Handler.SetRequest(Enum::"NPR EcomApiFunctions"::CREATE_SALES_DOCUMENT, Request);

        // [When] The request runs through the handler
        if Handler.Run() then;

        // [Then] The label is create|date|CreateV2
        _Assert.AreEqual('create|date|CreateV2', Handler.LastRoute(), 'A create under the V2 date must route to the V2 create.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenCreate_ThenLabelIsRejectedAndRunFails()
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] A create whose x-api-version is not a date is labelled rejected and the run fails.

        // [Given] A create request whose version header is not a date
        // [When] The request runs through the handler
        // [Then] The run fails and the label is create|invalid|rejected
        _Assert.IsFalse(RunCreateHandler(Handler, 'not-a-date'), 'A version header that is not a date must fail the create run.');
        _Assert.AreEqual('create|invalid|rejected', Handler.LastRoute(), 'A create whose version header is not a date must be labelled rejected.');
    end;

    [Test]
    procedure GivenV3Header_WhenCreate_ThenV2AnswersAndStoresTheV2ProcessingDate()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
        Response: JsonObject;
        ResponseBody: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] Create has no V3: a create dated V3From() is served by the V2 create, answers only the id and
        //            stores the V2 processing date. The routing dates never decide the processing version.

        // [Given] The API permission and a create request dated V3From()
        _LibDocApi.GrantApiPermission();
        ExternalNo := _LibEcom.NextExternalNo('VERRTE');

        // [When] The request is routed through POST ecommerce/documents
        Response := _LibDocApi.PostDocument(ExternalNo, DateText(Handler.V3From()));

        // [Then] The answer is 200 with exactly the id of the stored document
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), 'A create dated V3From() must answer HTTP 200.');
        ResponseBody := _LibDocApi.BodyOf(Response);
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
        _Assert.AreEqual('id', _LibDocApi.KeysOf(ResponseBody), 'The create response must carry exactly the property id.');
        _Assert.AreEqual(LowerCase(Format(EcomSalesHeader.SystemId, 0, 4)), _LibDocApi.TextAt(ResponseBody, 'id'), 'The id must be the system id of the stored document.');

        // [Then] The document stores the requested date as sent and the V2 date as its processing date
        _Assert.AreEqual(Handler.V3From(), EcomSalesHeader."Requested API Version Date", 'The requested API version date must be stored as sent.');
        _Assert.AreEqual(20251019D, EcomSalesHeader."API Version Date", 'A create dated V3From() must be processed under the V2 date.');

        // [Then] The handler labels the request as served by the V2 create
        if RunCreateHandler(Handler, DateText(Handler.V3From())) then;
        _Assert.AreEqual('create|date|CreateV2', Handler.LastRoute(), 'A create dated V3From() must route to the V2 create.');
    end;

    [Test]
    procedure GivenDatesBeforeV3_WhenGetByIdRouted_ThenV1BeforeV2AndV2From()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] Get by id dated the day before V2From() gets V1, and dated V2From() or the day before V3From() gets V2.

        // [Given] The API permission and a document V1 can render
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read under each date
        // [Then] V1, V2 and V2 answer
        AssertGetByIdVersion(EcomSalesHeader, DateText(Handler.V2From() - 1), 'V1');
        AssertGetByIdVersion(EcomSalesHeader, DateText(Handler.V2From()), 'V2');
        AssertGetByIdVersion(EcomSalesHeader, DateText(Handler.V3From() - 1), 'V2');
    end;

    [Test]
    procedure GivenV3From_WhenGetByIdRouted_ThenV3Answers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] Get by id dated V3From() gets V3.

        // [Given] The API permission and a document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read under V3From()
        // [Then] V3 answers
        AssertGetByIdVersion(EcomSalesHeader, DateText(Handler.V3From()), 'V3');
    end;

    [Test]
    procedure GivenDayAfterV3From_WhenGetByIdRouted_ThenV3Answers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] Get by id dated after V3From() gets V3.

        // [Given] The API permission and a document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read under the day after V3From()
        // [Then] V3 answers
        AssertGetByIdVersion(EcomSalesHeader, DateText(Handler.V3From() + 1), 'V3');
    end;

    [Test]
    procedure GivenEmptyHeader_WhenGetByIdRouted_ThenV1Answers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] Get by id with an empty x-api-version gets V1.

        // [Given] The API permission and a document V1 can render
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read with an empty header
        // [Then] V1 answers
        AssertGetByIdVersion(EcomSalesHeader, '', 'V1');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenGetByIdRouted_Then400()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
    begin
        // [Scenario] Get by id with an x-api-version that is not a date answers 400.

        // [Given] The API permission and a document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read with an x-api-version that is not a date
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, 'not-a-date', true);

        // [Then] The answer is 400
        _Assert.AreEqual(400, _LibDocApi.StatusOf(Response), 'A get by id whose x-api-version is not a date must answer HTTP 400.');
    end;

    [Test]
    procedure GivenDatesBeforeV3_WhenFind_ThenLabelIsFindV2()
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] Find has no V1, so a date before V2From() gets the V2 find, as do V2From() and the day before V3From().

        // [Given] Find requests dated the day before V2From(), V2From() and the day before V3From()
        // [When] Each request runs through the handler
        // [Then] Each label is find|date|FindV2
        AssertFindLabel(DateText(Handler.V2From() - 1), 'find|date|FindV2');
        AssertFindLabel(DateText(Handler.V2From()), 'find|date|FindV2');
        AssertFindLabel(DateText(Handler.V3From() - 1), 'find|date|FindV2');
    end;

    [Test]
    procedure GivenEmptyHeader_WhenFind_ThenLabelIsFindV2()
    begin
        // [Scenario] A find with an empty x-api-version gets the V2 find.

        // [Given] A find request whose version header is empty
        // [When] The request runs through the handler
        // [Then] The label is find|empty|FindV2
        AssertFindLabel('', 'find|empty|FindV2');
    end;

    [Test]
    procedure GivenV3From_WhenFind_ThenLabelIsFindV3()
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] A find dated V3From() gets the V3 find.

        // [Given] A find request dated V3From()
        // [When] The request runs through the handler
        // [Then] The label is find|date|FindV3
        AssertFindLabel(DateText(Handler.V3From()), 'find|date|FindV3');
    end;

    [Test]
    procedure GivenDayAfterV3From_WhenFind_ThenLabelIsFindV3()
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] A find dated after V3From() gets the V3 find.

        // [Given] A find request dated the day after V3From()
        // [When] The request runs through the handler
        // [Then] The label is find|date|FindV3
        AssertFindLabel(DateText(Handler.V3From() + 1), 'find|date|FindV3');
    end;

    [Test]
    procedure GivenNoHeader_WhenFind_ThenLabelMatchesTodayPinnedRequest()
    var
        HeaderlessHandler: Codeunit "NPR EcomApiHandler";
        PinnedHandler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] A find without x-api-version is labelled absent and routed like a request that names today.

        // [Given] One find request without the header and one that names today's date
        // [When] Each request runs through the handler
        if RunFindHandler(HeaderlessHandler, NewEmail(), '', false) then;
        if RunFindHandler(PinnedHandler, NewEmail(), DateText(Today()), true) then;

        // [Then] The headerless label has state absent and both labels name the same route
        _Assert.AreEqual('absent', StateOf(HeaderlessHandler.LastRoute()), 'A find without the header must be labelled absent; got: ' + HeaderlessHandler.LastRoute());
        _Assert.AreEqual('date', StateOf(PinnedHandler.LastRoute()), 'A find that names today must be labelled date; got: ' + PinnedHandler.LastRoute());
        _Assert.AreEqual(RoutedToOf(PinnedHandler.LastRoute()), RoutedToOf(HeaderlessHandler.LastRoute()), 'A find without the header must be routed like one that names today.');
    end;

    [Test]
    procedure GivenMixedCaseHeaderName_WhenGetByIdOrFind_ThenLabelMatchesHeaderless()
    var
        HeaderlessGet: Codeunit "NPR EcomApiHandler";
        MixedCaseGet: Codeunit "NPR EcomApiHandler";
        HeaderlessFind: Codeunit "NPR EcomApiHandler";
        MixedCaseFind: Codeunit "NPR EcomApiHandler";
        Request: Codeunit "NPR API Request";
        MixedCaseHeaders: Dictionary of [Text, Text];
    begin
        // [Scenario] Only the lowercase header name is read: a header named X-Api-Version, dated before V2, is treated
        //            as no header at all.

        // [Given] Get by id and find requests without the header, and the same requests with X-Api-Version set to a date before V2
        MixedCaseHeaders.Add('X-Api-Version', DateText(HeaderlessGet.V2From() - 1));

        // [When] Each request runs through the handler
        RunGetById(HeaderlessGet, '', false);
        InitGetByIdRequestWithHeaders(Request, MixedCaseHeaders);
        MixedCaseGet.SetRequest(Enum::"NPR EcomApiFunctions"::GET_SALES_DOCUMENT, Request);
        if MixedCaseGet.Run() then;
        if RunFindHandler(HeaderlessFind, NewEmail(), '', false) then;
        if RunFindHandlerWithHeaders(MixedCaseFind, NewEmail(), MixedCaseHeaders) then;

        // [Then] The mixed-case header gives the same label as no header
        _Assert.AreEqual(HeaderlessGet.LastRoute(), MixedCaseGet.LastRoute(), 'A get by id with X-Api-Version must be labelled like one without the header.');
        _Assert.AreEqual(HeaderlessFind.LastRoute(), MixedCaseFind.LastRoute(), 'A find with X-Api-Version must be labelled like one without the header.');
    end;

    [Test]
    procedure GivenHandler_WhenVersionDatesAreReadAndRouted_ThenThePublishedDatesHold()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        // [Scenario] The handler publishes 2025-10-19 as the V2 date and 2026-10-29 as the V3 date, and get by id routes
        //            by those literal dates.

        // [Given] The API permission and a document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The version dates are read
        // [Then] They are the published dates
        _Assert.AreEqual(20251019D, Handler.V2From(), 'V2From() must be the published V2 date.');
        _Assert.AreEqual(20261029D, Handler.V3From(), 'V3From() must be the published V3 date.');

        // [When] The document is read dated 2026-10-28, 2026-10-29 and 2026-10-30
        // [Then] V2, V3 and V3 answer
        AssertGetByIdVersion(EcomSalesHeader, '2026-10-28', 'V2');
        AssertGetByIdVersion(EcomSalesHeader, '2026-10-29', 'V3');
        AssertGetByIdVersion(EcomSalesHeader, '2026-10-30', 'V3');
    end;

    [Test]
    procedure GivenPublishedDates_WhenRouted_ThenEachLabelFollowsTheVersionTable()
    var
        Handler: Codeunit "NPR EcomApiHandler";
        MixedCaseHeaders: Dictionary of [Text, Text];
        CreateFn: Enum "NPR EcomApiFunctions";
        GetFn: Enum "NPR EcomApiFunctions";
        FindFn: Enum "NPR EcomApiFunctions";
    begin
        // [Scenario] Route labels identify the header state and handler at each published version boundary.

        // [Given] Create, get by id and find requests under literal dates and the empty header classes
        CreateFn := Enum::"NPR EcomApiFunctions"::CREATE_SALES_DOCUMENT;
        GetFn := Enum::"NPR EcomApiFunctions"::GET_SALES_DOCUMENT;
        FindFn := Enum::"NPR EcomApiFunctions"::FIND_SALES_DOCUMENTS;

        // [When] Each request runs through the handler
        // [Then] Create is served by V1 before 2025-10-19 and for an empty value, and by V2 otherwise
        AssertRouteLabel(CreateFn, '2025-10-18', true, 'create|date|CreateV1');
        AssertRouteLabel(CreateFn, '2025-10-19', true, 'create|date|CreateV2');
        AssertRouteLabel(CreateFn, '2026-10-29', true, 'create|date|CreateV2');
        AssertRouteLabel(CreateFn, '', true, 'create|empty|CreateV1');
        AssertRouteLabel(CreateFn, ' ', true, 'create|empty|CreateV1');
        AssertRouteLabel(CreateFn, TabValue(), true, 'create|empty|CreateV1');
        AssertRouteLabel(CreateFn, '0001-01-01', true, 'create|empty|CreateV1');
        AssertRouteLabel(CreateFn, '', false, 'create|absent|CreateV2');
        MixedCaseHeaders.Add('X-Api-Version', '2025-10-18');
        if RunCreateHandlerWithHeaders(Handler, MixedCaseHeaders) then;
        _Assert.AreEqual('create|absent|CreateV2', Handler.LastRoute(), 'A create with X-Api-Version must be labelled like one without the header.');

        // [Then] Get by id is served by V1 before 2025-10-19 and for an empty value, by V2 up to 2026-10-28 and by V3 from 2026-10-29
        AssertRouteLabel(GetFn, '2025-10-18', true, 'get|date|GetV1');
        AssertRouteLabel(GetFn, '2025-10-19', true, 'get|date|GetV2');
        AssertRouteLabel(GetFn, '2026-10-28', true, 'get|date|GetV2');
        AssertRouteLabel(GetFn, '2026-10-29', true, 'get|date|GetV3');
        AssertRouteLabel(GetFn, '2026-10-30', true, 'get|date|GetV3');
        AssertRouteLabel(GetFn, ' ', true, 'get|empty|GetV1');
        AssertRouteLabel(GetFn, TabValue(), true, 'get|empty|GetV1');
        AssertRouteLabel(GetFn, '0001-01-01', true, 'get|empty|GetV1');

        // [Then] Find is served by V2 up to 2026-10-28 and for an empty value, and by V3 from 2026-10-29
        AssertRouteLabel(FindFn, '2025-10-18', true, 'find|date|FindV2');
        AssertRouteLabel(FindFn, '2026-10-28', true, 'find|date|FindV2');
        AssertRouteLabel(FindFn, '2026-10-29', true, 'find|date|FindV3');
        AssertRouteLabel(FindFn, '2026-10-30', true, 'find|date|FindV3');
        AssertRouteLabel(FindFn, ' ', true, 'find|empty|FindV2');
        AssertRouteLabel(FindFn, TabValue(), true, 'find|empty|FindV2');
        AssertRouteLabel(FindFn, '0001-01-01', true, 'find|empty|FindV2');
    end;

    local procedure RouteLabel(ApiFunction: Enum "NPR EcomApiFunctions"; ApiVersion: Text; SendHeader: Boolean): Text
    var
        Handler: Codeunit "NPR EcomApiHandler";
        Headers: Dictionary of [Text, Text];
    begin
        case ApiFunction of
            ApiFunction::CREATE_SALES_DOCUMENT:
                begin
                    if SendHeader then
                        Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
                    if RunCreateHandlerWithHeaders(Handler, Headers) then;
                    exit(Handler.LastRoute());
                end;
            ApiFunction::GET_SALES_DOCUMENT:
                exit(RunGetById(Handler, ApiVersion, SendHeader));
            ApiFunction::FIND_SALES_DOCUMENTS:
                begin
                    if RunFindHandler(Handler, NewEmail(), ApiVersion, SendHeader) then;
                    exit(Handler.LastRoute());
                end;
        end;
    end;

    local procedure AssertRouteLabel(ApiFunction: Enum "NPR EcomApiFunctions"; ApiVersion: Text; SendHeader: Boolean; ExpectedLabel: Text)
    begin
        _Assert.AreEqual(ExpectedLabel, RouteLabel(ApiFunction, ApiVersion, SendHeader), At(StrSubstNo('Label of %1, header sent %2', ApiFunction, SendHeader), '''' + ApiVersion + ''''));
    end;

    local procedure TabValue() Value: Text
    var
        Tab: Char;
    begin
        Tab := 9;
        Value := ' ';
        Value[1] := Tab;
    end;

    local procedure RunGetById(var Handler: Codeunit "NPR EcomApiHandler"; ApiVersion: Text; SendHeader: Boolean): Text
    var
        Request: Codeunit "NPR API Request";
    begin
        InitGetByIdRequest(Request, ApiVersion, SendHeader);
        Handler.SetRequest(Enum::"NPR EcomApiFunctions"::GET_SALES_DOCUMENT, Request);
        if Handler.Run() then;
        exit(Handler.LastRoute());
    end;

    // Use an unknown id to test routing without loading a document.
    local procedure InitGetByIdRequest(var Request: Codeunit "NPR API Request"; ApiVersion: Text; SendHeader: Boolean)
    var
        Headers: Dictionary of [Text, Text];
    begin
        if SendHeader then
            Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
        InitGetByIdRequestWithHeaders(Request, Headers);
    end;

    local procedure InitGetByIdRequestWithHeaders(var Request: Codeunit "NPR API Request"; Headers: Dictionary of [Text, Text])
    var
        EmptyBody: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        DocumentIdText: Text;
    begin
        DocumentIdText := LowerCase(Format(CreateGuid(), 0, 4));
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        PathSegments.Add(DocumentIdText);
        Request.Init("Http Method"::GET, '/ecommerce/documents/' + DocumentIdText, PathSegments, QueryParams, Headers, EmptyBody);
    end;

    local procedure RunFindHandler(var Handler: Codeunit "NPR EcomApiHandler"; Email: Text; ApiVersion: Text; SendHeader: Boolean): Boolean
    var
        Headers: Dictionary of [Text, Text];
    begin
        if SendHeader then
            Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
        exit(RunFindHandlerWithHeaders(Handler, Email, Headers));
    end;

    local procedure RunFindHandlerWithHeaders(var Handler: Codeunit "NPR EcomApiHandler"; Email: Text; Headers: Dictionary of [Text, Text]): Boolean
    var
        Request: Codeunit "NPR API Request";
        EmptyBody: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
    begin
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        QueryParams.Add('email', Email);
        Request.Init("Http Method"::GET, '/ecommerce/documents', PathSegments, QueryParams, Headers, EmptyBody);
        Handler.SetRequest(Enum::"NPR EcomApiFunctions"::FIND_SALES_DOCUMENTS, Request);
        exit(Handler.Run());
    end;

    // A create with an empty body through the handler; the label is set before the create code refuses the body.
    local procedure RunCreateHandler(var Handler: Codeunit "NPR EcomApiHandler"; ApiVersion: Text): Boolean
    var
        Headers: Dictionary of [Text, Text];
    begin
        Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
        exit(RunCreateHandlerWithHeaders(Handler, Headers));
    end;

    local procedure RunCreateHandlerWithHeaders(var Handler: Codeunit "NPR EcomApiHandler"; Headers: Dictionary of [Text, Text]): Boolean
    var
        Request: Codeunit "NPR API Request";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
    begin
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Request.Init("Http Method"::POST, '/ecommerce/documents', PathSegments, QueryParams, Headers, Body.AsToken());
        Handler.SetRequest(Enum::"NPR EcomApiFunctions"::CREATE_SALES_DOCUMENT, Request);
        exit(Handler.Run());
    end;

    local procedure AssertFindLabel(ApiVersion: Text; ExpectedLabel: Text)
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        if RunFindHandler(Handler, NewEmail(), ApiVersion, true) then;
        _Assert.AreEqual(ExpectedLabel, Handler.LastRoute(), At('Find label', ApiVersion));
    end;

    local procedure AssertGetByIdVersion(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text; ExpectedVersion: Text)
    begin
        _Assert.AreEqual(ExpectedVersion, _LibDocApi.VersionOf(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, ApiVersion)), At('The version that answers get by id', ApiVersion));
    end;

    local procedure DateText(Value: Date): Text
    begin
        exit(Format(Value, 0, 9));
    end;

    local procedure NewEmail(): Text
    begin
        exit('versioning.routing.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test');
    end;

    local procedure At(Message: Text; ApiVersion: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, ApiVersion));
    end;

    local procedure StateOf(RouteLabel: Text): Text
    begin
        exit(RouteLabel.Split('|').Get(2));
    end;

    local procedure RoutedToOf(RouteLabel: Text): Text
    begin
        exit(RouteLabel.Split('|').Get(3));
    end;
}
