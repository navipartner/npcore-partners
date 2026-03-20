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
        _customTags: Dictionary of [Text, Text];
        _customData: Dictionary of [Text, Text];
        _source: Text;

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
        _source := 'url';
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

    procedure AddTag(TagKey: Text; TagValue: Text)
    begin
        if _customTags.ContainsKey(TagKey) then
            _customTags.Set(TagKey, TagValue)
        else
            _customTags.Add(TagKey, TagValue);
    end;

    procedure AddData(DataKey: Text; DataValue: Text)
    begin
        if _customData.ContainsKey(DataKey) then
            _customData.Set(DataKey, DataValue)
        else
            _customData.Add(DataKey, DataValue);
    end;

    procedure SetDescription(Name: Text)
    begin
        _description := Name;
    end;

    procedure SetOperation(Op: Text)
    begin
        _operation := Op;
    end;

    procedure SetSource(Source: Text)
    begin
        _source := Source;
    end;

    procedure Log(var Spans: List of [Codeunit "NPR Sentry Span"]; var Errors: List of [Codeunit "NPR Sentry Error"]; var FinalizeSpan: Codeunit "NPR Sentry Span")
    var
        Span: Codeunit "NPR Sentry Span";
        Error: Codeunit "NPR Sentry Error";
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        EventJson: JsonObject;
        UserJson: JsonObject;
        TransactionInfoJson: JsonObject;
        ContextsJson: JsonObject;
        TraceJson: JsonObject;
        TagsJson: JsonObject;
        DataJson: JsonObject;
        SpansArray: JsonArray;
        ErrorJson: JsonObject;
        EventDimensions: Dictionary of [Text, Text];
        ExceptionDimensions: Dictionary of [Text, Text];
        TagKey: Text;
        DataKey: Text;
        JsonText: Text;
    begin
        if Errors.Count > 0 then
            _status := _status::InternalError;

        EventJson.Add('event_id', Format(CreateGuid(), 0, 3).ToLower());
        EventJson.Add('start_timestamp', _startedTimestampUtc);
        EventJson.Add('timestamp', _finishedTimestampUtc);
        EventJson.Add('transaction', _description);

        TransactionInfoJson.Add('source', _source);
        EventJson.Add('transaction_info', TransactionInfoJson);

        EventJson.Add('platform', 'other');
        EventJson.Add('release', _appRelease);
        EventJson.Add('type', 'transaction');
        EventJson.Add('environment', SentryMetadata.GetEnvironment());
        EventJson.Add('level', 'info');

        UserJson.Add('id', Format(UserSecurityId(), 0, 4).ToLower());
        UserJson.Add('username', UserId);
        EventJson.Add('user', UserJson);

        TraceJson.Add('trace_id', _traceId);
        TraceJson.Add('span_id', _rootSpanId);
        TraceJson.Add('op', _operation);
        TraceJson.Add('status', Format(_status));
        if _externalSpanId <> '' then
            TraceJson.Add('parent_span_id', _externalSpanId);
        ContextsJson.Add('trace', TraceJson);
        EventJson.Add('contexts', ContextsJson);

        EventJson.Add('modules', SentryMetadata.WriteModulesJson());

        TagsJson := SentryMetadata.WriteTagsForBackendEvent();
        foreach TagKey in _customTags.Keys() do
            if TagsJson.Contains(TagKey) then
                TagsJson.Replace(TagKey, _customTags.Get(TagKey))
            else
                TagsJson.Add(TagKey, _customTags.Get(TagKey));
        EventJson.Add('tags', TagsJson);

        if _customData.Count > 0 then begin
            foreach DataKey in _customData.Keys() do
                DataJson.Add(DataKey, _customData.Get(DataKey));
            EventJson.Add('data', DataJson);
        end;


        foreach Span in Spans do
            SpansArray.Add(Span.ToJson(_traceId));

        // Finish the finalize span right before serializing spans so it captures all JSON assembly time above
        FinalizeSpan.Finish();
        SpansArray.Add(FinalizeSpan.ToJson(_traceId));
        EventJson.Add('spans', SpansArray);

        EventJson.WriteTo(JsonText);

        EventDimensions.Add('NPRSentryDsn', _dsn);
        AddJsonChunks(EventDimensions, JsonText);
        Session.LogMessage('NPRSentryTransaction', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, EventDimensions);

        foreach Error in Errors do begin
            ErrorJson := Error.ToJson();
            ErrorJson.WriteTo(JsonText);

            Clear(ExceptionDimensions);
            ExceptionDimensions.Add('NPRSentryDsn', _dsn);
            AddJsonChunks(ExceptionDimensions, JsonText);
            ExceptionDimensions.Add('NPRSentryTraceId', _traceId);
            ExceptionDimensions.Add('NPRSentrySpanId', Error.GetParentId());
            Session.LogMessage('NPRSentryException', 'sentryPayload', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, ExceptionDimensions);
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