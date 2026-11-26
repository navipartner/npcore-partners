codeunit 85667 "NPR Mock Billing Api" implements "Http Client Handler"
{
    Access = Internal;

    var
        _StoredEventIds: List of [Guid];
        _RequestSizes: List of [Integer];
        _FailFromRequest: Integer;
        _FailUntilRequest: Integer;
        _RequestWithLostAnswer: Integer;

    procedure FailRequests(FromRequest: Integer; UntilRequest: Integer)
    begin
        _FailFromRequest := FromRequest;
        _FailUntilRequest := UntilRequest;
    end;

    procedure LoseAnswerOfRequest(RequestNo: Integer)
    begin
        _RequestWithLostAnswer := RequestNo;
    end;

    procedure RequestCount(): Integer
    begin
        exit(_RequestSizes.Count());
    end;

    procedure RequestSize(RequestNo: Integer): Integer
    begin
        exit(_RequestSizes.Get(RequestNo));
    end;

    procedure StoredCount(EventId: Guid) Count: Integer
    var
        StoredEventId: Guid;
    begin
        foreach StoredEventId in _StoredEventIds do
            if StoredEventId = EventId then
                Count += 1;
    end;

    procedure Send(CurrHttpClientInstance: HttpClient; HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message") Success: Boolean
    var
        Request: JsonObject;
        Events: JsonToken;
        BillingEvent: JsonToken;
        EventIdToken: JsonToken;
        Body: Text;
        EventId: Guid;
        RequestNo: Integer;
    begin
        HttpRequestMessage.GetHttpRequestMessage().Content.ReadAs(Body);
        Request.ReadFrom(Body);
        Request.Get('values', Events);
        _RequestSizes.Add(Events.AsArray().Count());
        RequestNo := _RequestSizes.Count();

        if (RequestNo >= _FailFromRequest) and (RequestNo <= _FailUntilRequest) then begin
            HttpResponseMessage.SetHttpStatusCode(500);
            exit(true);
        end;

        foreach BillingEvent in Events.AsArray() do begin
            BillingEvent.AsObject().Get('event_id', EventIdToken);
            Evaluate(EventId, EventIdToken.AsValue().AsText());
            _StoredEventIds.Add(EventId);
        end;
        if RequestNo = _RequestWithLostAnswer then
            exit(false);

        HttpResponseMessage.SetHttpStatusCode(202);
        exit(true);
    end;

    // The handler is session state of the billing client; clear it so later sends in the session do not end in the mock of the last test.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", OnAfterTestMethodRun, '', false, false)]
    local procedure ClearHttpClientHandlerAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
    begin
        EventBillingClient.ClearHttpClientHandler();
    end;
}
