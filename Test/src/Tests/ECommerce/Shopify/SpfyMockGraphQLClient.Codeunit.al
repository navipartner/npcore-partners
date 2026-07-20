#if not BC17
codeunit 85259 "NPR Spfy Mock GraphQL Client" implements "NPR Spfy IGraphQL Client"
{
    // Reusable, endpoint-agnostic test double for "NPR Spfy IGraphQL Client".
    // Configure canned responses keyed by substring(s) of the outgoing request body, inject it into
    // any Shopify GraphQL caller that exposes the interface, then inspect what was sent. Every request
    // is recorded so tests can assert how many calls were made and what each one contained, and a rule
    // can simulate a transport failure (returns false with GetLastErrorText() set, like the real client).

    var
        _Match1: List of [Text];
        _Match2: List of [Text];
        _Body: List of [Text];
        _Fail: List of [Boolean];
        _RecordedRequests: List of [Text];

    /// <summary>Adds a canned response returned when the request body contains RequestMatch.</summary>
    procedure AddResponse(RequestMatch: Text; ResponseBody: Text)
    begin
        AddResponse(RequestMatch, '', ResponseBody, false);
    end;

    /// <summary>Adds a canned response returned when the request body contains both RequestMatch1 and RequestMatch2 (use '' to skip a matcher).</summary>
    procedure AddResponse(RequestMatch1: Text; RequestMatch2: Text; ResponseBody: Text)
    begin
        AddResponse(RequestMatch1, RequestMatch2, ResponseBody, false);
    end;

    /// <summary>Adds a rule that simulates an HTTP/transport failure (ExecuteRequest returns false) for matching requests.</summary>
    procedure AddFailure(RequestMatch: Text)
    begin
        AddResponse(RequestMatch, '', '', true);
    end;

    procedure AddResponse(RequestMatch1: Text; RequestMatch2: Text; ResponseBody: Text; Fail: Boolean)
    begin
        _Match1.Add(RequestMatch1);
        _Match2.Add(RequestMatch2);
        _Body.Add(ResponseBody);
        _Fail.Add(Fail);
    end;

    procedure ExecuteRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken): Boolean
    var
        InStr: InStream;
        RequestJson: JsonObject;
        RequestText: Text;
        i: Integer;
        NoRequestBodyErr: Label 'Mock GraphQL client received a request with no body attached.', Locked = true;
        NoCannedResponseErr: Label 'Mock GraphQL client has no canned response matching request: %1', Comment = '%1 = request body', Locked = true;
    begin
        if not NcTask."Data Output".HasValue() then
            Error(NoRequestBodyErr);

        NcTask."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
        RequestJson.ReadFrom(InStr);
        RequestJson.WriteTo(RequestText);
        _RecordedRequests.Add(RequestText);

        for i := 1 to _Match1.Count() do
            if IsMatch(RequestText, _Match1.Get(i), _Match2.Get(i)) then begin
                if _Fail.Get(i) then begin
                    // Mirror the real client's contract: return false with the reason available via GetLastErrorText().
                    if SetSimulatedError() then;
                    exit(false);
                end;
                ShopifyResponse.ReadFrom(_Body.Get(i));
                exit(true);
            end;

        Error(NoCannedResponseErr, RequestText);
    end;

    [TryFunction]
    local procedure SetSimulatedError()
    var
        SimulatedFailureErr: Label 'Mock GraphQL client simulated transport failure.', Locked = true;
    begin
        Error(SimulatedFailureErr);
    end;

    local procedure IsMatch(RequestText: Text; RequestMatch1: Text; RequestMatch2: Text): Boolean
    begin
        exit(((RequestMatch1 = '') or RequestText.Contains(RequestMatch1)) and
             ((RequestMatch2 = '') or RequestText.Contains(RequestMatch2)));
    end;

    /// <summary>Total number of requests the client received.</summary>
    procedure RequestCount(): Integer
    begin
        exit(_RecordedRequests.Count());
    end;

    /// <summary>Number of recorded requests whose body contains Pattern.</summary>
    procedure CountRequestsContaining(Pattern: Text) MatchCount: Integer
    var
        Request: Text;
    begin
        foreach Request in _RecordedRequests do
            if Request.Contains(Pattern) then
                MatchCount += 1;
    end;

    /// <summary>First recorded request whose body contains Pattern, or '' if none.</summary>
    procedure GetRequestContaining(Pattern: Text): Text
    var
        Request: Text;
    begin
        foreach Request in _RecordedRequests do
            if Request.Contains(Pattern) then
                exit(Request);
        exit('');
    end;
}
#endif
