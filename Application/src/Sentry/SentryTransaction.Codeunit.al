#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248499 "NPR Sentry Transaction"
{
    Access = Internal;

    var
        _rootSpanId: Text;
        _started: Boolean;
        _finished: Boolean;
        _startedTimestampUtc: Text;
        _finishedTimestampUtc: Text;
        _description: Text;
        _operation: Text;
        _dsn: Text;
        _appRelease: Text;
        _traceId: Text;
        _externalSpanId: Text;
        _sampled: Boolean;
        _status: Enum "NPR Sentry Span Status";

    procedure Create(description: Text; operation: Text; dsn: Text; appRelease: Text; externalTraceId: text; externalSpanId: text; sampled: Boolean)
    begin
        Create(description, operation, dsn, appRelease, externalTraceId, externalSpanId, sampled, CurrentDateTime());
    end;

    procedure Create(description: Text; operation: Text; dsn: Text; appRelease: Text; externalTraceId: text; externalSpanId: text; sampled: Boolean; StartTime: DateTime)
    var
        Guid: Text;
    begin
        Guid := Format(CreateGuid(), 0, 3).ToLower();

        _rootSpanId := Guid.Substring(1, 8) + Guid.Substring(25, 8); // we use uuidv4 to generate a 16 digit hex random string
        _started := true;
        _startedTimestampUtc := Format(StartTime, 0, 9);
        clear(_finished);
        clear(_finishedTimestampUtc);
        _description := description;
        _operation := operation;
        _dsn := dsn;
        _appRelease := appRelease;
        if (externalTraceId <> '') then begin
            _traceId := externalTraceId;
            _externalSpanId := externalSpanId;
        end else begin
            _traceId := Format(CreateGuid(), 0, 3).ToLower();
        end;
        _sampled := sampled;

    end;

    procedure Finish()
    begin
        if _finished then
            exit;

        _finished := true;
        _finishedTimestampUtc := Format(CurrentDateTime, 0, 9);
    end;

    procedure GetRootSpanId(): Text
    begin
        exit(_rootSpanId);
    end;

    procedure GetTraceId(): Text
    begin
        exit(_traceId);
    end;

    procedure GetSampled(): Boolean
    begin
        exit(_sampled);
    end;

    procedure GetRelease(): Text
    begin
        exit(_appRelease);
    end;

    procedure IsActive(): Boolean
    begin
        exit(_started and not _finished);
    end;

    procedure SetStatus(Status: Enum "NPR Sentry Span Status")
    begin
        _status := Status;
    end;

    procedure Log(var Spans: List of [Codeunit "NPR Sentry Span"]; var Errors: List of [Codeunit "NPR Sentry Error"])
    var
        Json: Codeunit "NPR Json Builder";
        Span: Codeunit "NPR Sentry Span";
        Error: Codeunit "NPR Sentry Error";
        EventDimensions: Dictionary of [Text, Text];
        ExceptionDimensions: Dictionary of [Text, Text];
        SentryMetadata: Codeunit "NPR Sentry Metadata";
    begin
        if Errors.Count > 0 then
            _status := _status::InternalError;

        Json
            .StartObject('')
                .AddProperty('event_id', Format(CreateGuid(), 0, 3).ToLower())
                .AddProperty('start_timestamp', _startedTimestampUtc)
                .AddProperty('timestamp', _finishedTimestampUtc)
                .AddProperty('transaction', _description)
                .StartObject('transaction_info')
                    .AddProperty('source', 'custom')
                .EndObject()
                .AddProperty('platform', 'other')
                .AddProperty('release', _appRelease)
                .AddProperty('type', 'transaction')
                .AddProperty('environment', SentryMetadata.GetEnvironment())
                .AddProperty('level', 'info')
                .StartObject('user')
                    .AddProperty('id', Format(UserSecurityId(), 0, 4).ToLower())
                    .AddProperty('username', UserId)
                .EndObject()
                .StartObject('contexts')
                    .StartObject('trace')
                        .AddProperty('trace_id', _traceId)
                        .AddProperty('span_id', _rootSpanId)
                        .AddProperty('op', _operation)
                        .AddProperty('status', Format(_status));

        if _externalSpanId <> '' then begin
            Json.AddProperty('parent_span_id', _externalSpanId);
        end;

        Json
            .EndObject() // trace
            .EndObject(); // contexts

        SentryMetadata.WriteModulesJson(Json);

        Json.StartObject('tags');
        SentryMetadata.WriteTagsForBackendEvent(Json);
        Json.EndObject();

        Json.StartArray('spans');
        foreach Span in Spans do begin
            Span.ToJson(Json, _traceId);
        end;
        Json.EndArray();
        Json.EndObject();

        eventDimensions.Add('NPRSentryDsn', _dsn);
        AddJsonChunks(eventDimensions, Json.BuildAsText());
        // Our app.json connectionstring forwards events to a cloudflare worker that parses this JSON and sends it to navipartner-eu.sentry.io.        
        Session.LogMessage('NPRSentryTransaction', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, eventDimensions);
        Clear(Json);

        foreach Error in Errors do begin
            Json := Error.ToJson();

            exceptionDimensions.Add('NPRSentryDsn', _dsn);
            AddJsonChunks(exceptionDimensions, Json.BuildAsText());
            exceptionDimensions.Add('NPRSentryTraceId', _traceId);
            exceptionDimensions.Add('NPRSentrySpanId', Error.GetParentId());
            Session.LogMessage('NPRSentryException', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, exceptionDimensions);
            Clear(Json);
            Clear(exceptionDimensions);
        end;
    end;

    local procedure AddJsonChunks(var Dimensions: Dictionary of [Text, Text]; JsonText: Text)
    var
        ChunkSize: Integer;
        Position: Integer;
        ChunkIndex: Integer;
        Chunk: Text;
        DimensionKey: Text;
    begin
        ChunkSize := 7500;
        Position := 1;
        ChunkIndex := 0;

        while Position <= StrLen(JsonText) do begin
            Chunk := CopyStr(JsonText, Position, ChunkSize);

            if ChunkIndex = 0 then
                DimensionKey := 'NPRSentryJson'
            else
                DimensionKey := StrSubstNo('NPRSentryJson_%1', ChunkIndex);

            Dimensions.Add(DimensionKey, Chunk);
            Position += ChunkSize;
            ChunkIndex += 1;
        end;

        Dimensions.Add('NPRSentryJsonChunks', Format(ChunkIndex));
    end;
}
#endif