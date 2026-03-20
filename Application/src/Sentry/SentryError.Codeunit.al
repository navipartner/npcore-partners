#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248500 "NPR Sentry Error"
{
    Access = internal;

    var
        _id: Text;
        _parentSpanId: Text;
        _errorText: Text;
        _errorCallstack: Text;
        _timestampUtc: Text;
        _release: Text;
        _traceId: Text;

    procedure Create(parentSpanId: Text; errorText: Text; errorCallstack: Text; traceId: text; release: Text)
    begin
        _id := Format(CreateGuid(), 0, 3).ToLower();
        _parentSpanId := parentSpanId;
        _errorText := errorText;
        _errorCallstack := errorCallstack;
        _timestampUtc := Format(CurrentDateTime(), 0, 9);
        _release := release;
        _traceId := traceId;
    end;

    procedure ToJson(): JsonObject
    var
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
        EventJson: JsonObject;
        UserJson: JsonObject;
        ExceptionJson: JsonObject;
        ValuesArray: JsonArray;
        ExceptionValue: JsonObject;
        MechanismJson: JsonObject;
        StacktraceJson: JsonObject;
        FramesArray: JsonArray;
        FrameJson: JsonObject;
        ContextsJson: JsonObject;
        TraceJson: JsonObject;
        ErrorCallStack: List of [Text];
        ErrorFrame: Text;
        HasFrames: Boolean;
    begin
        EventJson.Add('event_id', _id);
        EventJson.Add('timestamp', _timestampUtc);
        EventJson.Add('platform', 'other');
        EventJson.Add('release', _release);
        EventJson.Add('environment', SentryMetadata.GetEnvironment());
        EventJson.Add('level', 'error');

        UserJson.Add('id', Format(UserSecurityId(), 0, 4).ToLower());
        UserJson.Add('username', UserId);
        EventJson.Add('user', UserJson);

        MechanismJson.Add('type', 'generic');
        MechanismJson.Add('handled', false);

        SentryErrorHandling.SplitErrorStacktrace(_errorCallstack, ErrorCallStack);
        HasFrames := false;
        foreach ErrorFrame in ErrorCallStack do begin
            if ErrorFrame.Trim() <> '' then begin
                Clear(FrameJson);
                FrameJson.Add('function', ErrorFrame);
                FramesArray.Add(FrameJson);
                HasFrames := true;
            end;
        end;
        if not HasFrames then begin
            FrameJson.Add('function', '<unknown>');
            FramesArray.Add(FrameJson);
        end;

        StacktraceJson.Add('frames', FramesArray);

        ExceptionValue.Add('type', GetExceptionType());
        ExceptionValue.Add('value', _errorText);
        ExceptionValue.Add('mechanism', MechanismJson);
        ExceptionValue.Add('stacktrace', StacktraceJson);

        ValuesArray.Add(ExceptionValue);
        ExceptionJson.Add('values', ValuesArray);
        EventJson.Add('exception', ExceptionJson);

        EventJson.Add('modules', SentryMetadata.WriteModulesJson());

        EventJson.Add('tags', SentryMetadata.WriteTagsForBackendEvent());

        TraceJson.Add('trace_id', _traceId);
        TraceJson.Add('span_id', _parentSpanId);
        ContextsJson.Add('trace', TraceJson);
        EventJson.Add('contexts', ContextsJson);

        exit(EventJson);
    end;

    procedure GetParentId(): Text
    begin
        exit(_parentSpanId);
    end;

    local procedure GetExceptionType(): Text
    begin
        // Extract a meaningful exception type from the error text
        // Try to identify common BC error patterns
        if _errorText.Contains('Arithmetic operation resulted in an overflow') then
            exit('OverflowException');
        if _errorText.Contains('DivideByZero') or _errorText.Contains('divided by zero') then
            exit('DivideByZeroException');
        if _errorText.Contains('deadlocked') then
            exit('DeadlockException');
        if _errorText.Contains('does not contain a property') or _errorText.Contains('was not found') then
            exit('KeyNotFoundException');
        if _errorText.Contains('is not allowed in write transactions') or _errorText.Contains('RunModal is not allowed') then
            exit('InvalidOperationException');
        if _errorText.Contains('Codeunit.Run is allowed in write transactions only if the return value is not used') then
            exit('InvalidOperationException');
        if _errorText.Contains('timed out') or _errorText.Contains('timeout') then
            exit('TimeoutException');
        if _errorText.Contains('A connection attempt failed') or _errorText.Contains('The request was aborted') then
            exit('HttpRequestException');
        if _errorText.Contains('You cannot perform a write') or _errorText.Contains('read-only') then
            exit('InvalidOperationException');
        if _errorText.Contains('has an invalid token') or _errorText.Contains('has an invalid qualified name character') or _errorText.Contains('Namespace prefix') then
            exit('XmlParseException');
        if _errorText.Contains('programming bug') then
            exit('ProgrammingBugException');

        // Default exception type for BC errors
        exit('BusinessCentralException');
    end;
}
#endif