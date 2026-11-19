codeunit 85601 "NPR POS API Routing Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _ApiVersionHeaderLbl: Label 'x-api-version', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenNoHeader_WhenCreate_ThenLabelMatchesTodayPinnedRequest()
    var
        HeaderlessHandler: Codeunit "NPR API POS Handler";
        PinnedHandler: Codeunit "NPR API POS Handler";
        HeaderlessLabel: Text;
        PinnedLabel: Text;
    begin
        // [Scenario] A create sale line without x-api-version is labelled absent and routed like a request that names today.

        // [Given] One create request without the header and one that names today's date
        // [When] Each request runs through the handler
        HeaderlessLabel := RunRoute(HeaderlessHandler, "Http Method"::POST, CreatePath(), '', false);
        PinnedLabel := RunRoute(PinnedHandler, "Http Method"::POST, CreatePath(), Format(Today(), 0, 9), true);

        // [Then] The headerless label has state absent and both labels name the same version
        _Assert.AreEqual('absent', StateOf(HeaderlessLabel), 'A request without the header must be labelled absent; got: ' + HeaderlessLabel);
        _Assert.AreEqual('date', StateOf(PinnedLabel), 'A request that names today must be labelled date; got: ' + PinnedLabel);
        _Assert.AreEqual(RoutedToOf(PinnedLabel), RoutedToOf(HeaderlessLabel), 'A request without the header must be routed like one that names today.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenCreate_ThenLabelIsRejectedAndRunFails()
    var
        Handler: Codeunit "NPR API POS Handler";
        Request: Codeunit "NPR API Request";
    begin
        // [Scenario] A malformed x-api-version rejects create sale line and fails the handler run.

        // [Given] A create request whose version header is not a date
        InitRequest(Request, "Http Method"::POST, CreatePath(), VersionHeaders('not-a-date'));

        // [When] The request runs through the handler
        asserterror Handler.Handle(Request);

        // [Then] The run fails and the label is create|invalid|rejected
        _Assert.AreEqual('create|invalid|rejected', Handler.LastRoute(), 'A version header that is not a date must be labelled rejected.');
    end;

    [Test]
    procedure GivenMixedCaseHeaderName_WhenCreate_ThenLabelMatchesHeaderless()
    var
        HeaderlessHandler: Codeunit "NPR API POS Handler";
        MixedCaseHandler: Codeunit "NPR API POS Handler";
        Request: Codeunit "NPR API Request";
        MixedCaseHeaders: Dictionary of [Text, Text];
    begin
        // [Scenario] Only the lowercase header name is read: a header named X-Api-Version, dated before V2, is treated
        //            as no header at all.

        // [Given] A create request without the header, and the same request with X-Api-Version set to a date before V2
        MixedCaseHeaders.Add('X-Api-Version', DateText(HeaderlessHandler.V2From() - 1));

        // [When] Each request runs through the handler
        RunRoute(HeaderlessHandler, "Http Method"::POST, CreatePath(), '', false);
        InitRequest(Request, "Http Method"::POST, CreatePath(), MixedCaseHeaders);
        MixedCaseHandler.Handle(Request);

        // [Then] The mixed-case header gives the same label as no header
        _Assert.AreEqual(HeaderlessHandler.LastRoute(), MixedCaseHandler.LastRoute(), 'A create sale line with X-Api-Version must be labelled like one without the header.');
    end;

    [Test]
    procedure GivenHandler_WhenVersionDateIsRead_ThenThePublishedDateHolds()
    var
        Handler: Codeunit "NPR API POS Handler";
    begin
        // [Scenario] The handler publishes 2026-11-23 as the V2 date.

        // [Given] The POS API handler
        // [When] The version date is read
        // [Then] It is the published date
        _Assert.AreEqual(20261123D, Handler.V2From(), 'V2From() must be the published V2 date.');
    end;

    [Test]
    procedure GivenPublishedDates_WhenRouted_ThenEachLabelFollowsTheVersionTable()
    begin
        // [Scenario] Create sale line and create addon are served by V1 before 2026-11-23 and for an empty value, and by V2 from 2026-11-23.

        // [Given] Create sale line and create addon requests under literal dates and the empty header classes
        // [When] Each request runs through the handler
        // [Then] Create sale line follows the version table, including the empty header classes
        AssertRouteLabel("Http Method"::POST, CreatePath(), '2026-11-22', 'create|date|V1');
        AssertRouteLabel("Http Method"::POST, CreatePath(), '2026-11-23', 'create|date|V2');
        AssertRouteLabel("Http Method"::POST, CreatePath(), '2026-11-24', 'create|date|V2');
        AssertRouteLabel("Http Method"::POST, CreatePath(), '', 'create|empty|V1');
        AssertRouteLabel("Http Method"::POST, CreatePath(), ' ', 'create|empty|V1');
        AssertRouteLabel("Http Method"::POST, CreatePath(), TabValue(), 'create|empty|V1');
        AssertRouteLabel("Http Method"::POST, CreatePath(), '0001-01-01', 'create|empty|V1');

        // [Then] Create addon switches to V2 on the same date
        AssertRouteLabel("Http Method"::POST, AddonPath(), '2026-11-22', 'addon|date|V1');
        AssertRouteLabel("Http Method"::POST, AddonPath(), '2026-11-23', 'addon|date|V2');
    end;

    local procedure AssertRouteLabel(Method: Enum "Http Method"; SaleLinePath: Text; ApiVersion: Text; ExpectedLabel: Text)
    var
        Handler: Codeunit "NPR API POS Handler";
    begin
        _Assert.AreEqual(ExpectedLabel, RunRoute(Handler, Method, SaleLinePath, ApiVersion, true), At(StrSubstNo('Label of %1 %2', Method, SaleLinePath), '''' + ApiVersion + ''''));
    end;

    local procedure RunRoute(var Handler: Codeunit "NPR API POS Handler"; Method: Enum "Http Method"; SaleLinePath: Text; ApiVersion: Text; SendHeader: Boolean): Text
    var
        Request: Codeunit "NPR API Request";
        Headers: Dictionary of [Text, Text];
    begin
        if SendHeader then
            Headers := VersionHeaders(ApiVersion);
        InitRequest(Request, Method, SaleLinePath, Headers);
        Handler.Handle(Request);
        exit(Handler.LastRoute());
    end;

    local procedure InitRequest(var Request: Codeunit "NPR API Request"; Method: Enum "Http Method"; SaleLinePath: Text; Headers: Dictionary of [Text, Text])
    var
        EmptyBody: JsonToken;
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        Path: Text;
    begin
        Path := '/pos/sale/' + NewId() + SaleLinePath;
        PathSegments := Path.Split('/');
        PathSegments.Remove('');
        Request.Init(Method, Path, PathSegments, QueryParams, Headers, EmptyBody);
    end;

    local procedure VersionHeaders(ApiVersion: Text) Headers: Dictionary of [Text, Text]
    begin
        Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
    end;

    local procedure CreatePath(): Text
    begin
        exit('/saleline/' + NewId());
    end;

    local procedure AddonPath(): Text
    begin
        exit('/saleline/' + NewId() + '/addon');
    end;

    local procedure NewId(): Text
    begin
        exit(LowerCase(Format(CreateGuid(), 0, 4)));
    end;

    local procedure TabValue() Value: Text
    var
        Tab: Char;
    begin
        Tab := 9;
        Value := ' ';
        Value[1] := Tab;
    end;

    local procedure DateText(Value: Date): Text
    begin
        exit(Format(Value, 0, 9));
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
