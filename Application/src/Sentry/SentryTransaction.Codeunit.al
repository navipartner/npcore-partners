codeunit 6150991 "NPR Sentry Transaction"
{
    Access = Internal;

    var
        _started: Boolean;
        _finished: Boolean;
        _startedTimestampUtc: Text;
        _name: Text;
        _operation: Text;
        _dsn: Text;
        _externalTraceId: Text;
        _externalSpanId: Text;
        _transactionId: Text;

        //Dictionary schema:
        //spanId -> [parentSpanId, description, operation, startTimestampUtc, finishTimestampUtc]
        _spanState: Dictionary of [Text, List of [Text]];

    procedure Start(Name: Text; Operation: Text; Dsn: Text; ExternalTraceId: Text; ExternalSpanId: Text)
    begin
        if (_started) or (_finished) then begin
            ClearAll();
        end;

        _name := Name;
        _operation := Operation;
        _transactionId := Format(CreateGuid(), 0, 3).ToLower();
        _externalTraceId := ExternalTraceId;
        _externalSpanId := ExternalSpanId;
        _dsn := Dsn;
        _startedTimestampUtc := Format(CurrentDateTime, 0, 9);
        _started := true;
    end;

    procedure Finish()
    var
        EventJson: Codeunit "Json Text Reader/Writer";
        SpanId: Text;
        SpanValues: List of [Text];
        SentryMetadata: Codeunit "NPR Sentry Metadata";
    begin
        if (not _started) or (_finished) then
            exit;

        _finished := true;

        EventJson.WriteStartObject('');
        EventJson.WriteStringProperty('id', _transactionId);
        EventJson.WriteStringProperty('name', _name);
        EventJson.WriteStringProperty('op', _operation);
        EventJson.WriteStringProperty('startTime', _startedTimestampUtc);
        EventJson.WriteStringProperty('endTime', Format(CurrentDateTime, 0, 9));
        EventJson.WriteStringProperty('traceId', _externalTraceId);
        EventJson.WriteStringProperty('parentId', _externalSpanId);
        EventJson.WriteStringProperty('dsn', _dsn);
        EventJson.WriteStartObject('metadata');
        SentryMetadata.WriteMetadataJson(EventJson);
        EventJson.WriteEndObject();

        EventJson.WriteStartArray('spans');
        foreach SpanId in _spanState.Keys() do begin
            EventJson.WriteStartObject('');
            EventJson.WriteStringProperty('id', SpanId);
            EventJson.WriteStringProperty('parentId', SpanValues.Get(1));
            EventJson.WriteStringProperty('desc', SpanValues.Get(2));
            EventJson.WriteStringProperty('op', SpanValues.Get(3));
            EventJson.WriteStringProperty('startTime', SpanValues.Get(4));
            EventJson.WriteStringProperty('endTime', SpanValues.Get(5));
            EventJson.WriteEndObject();
        end;
        EventJson.WriteEndArray();
        EventJson.WriteEndObject();

        //our app.json connectionstring forwards events to an azure function that parses this JSON and sends it to sentry.io
        Session.LogMessage('NPRSentryEvent', EventJson.GetJSonAsText(), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, '', '');
    end;

    procedure FinishWithError()
    begin
        // TODO: Implement
        Finish();
    end;

    procedure SetExternalTraceValues(TraceId: Text; SpanId: Text)
    begin
        _externalTraceId := TraceId;
        _externalSpanId := SpanId;
    end;

    procedure StartChildSpan(Description: Text; Operation: Text; var SpanOut: Codeunit "NPR Sentry Span")
    begin
        if (not _started) or (_finished) then
            exit;

        SpanOut.__Start(Description, Operation, _transactionId, _spanState);
    end;
}