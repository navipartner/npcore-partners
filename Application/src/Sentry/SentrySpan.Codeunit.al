codeunit 6150992 "NPR Sentry Span"
{
    Access = Internal;

    var
        //Dictionary schema:
        //spanId -> [parentSpanId, description, operation, startTimestampUtc, finishTimestampUtc]
        _spanState: Dictionary of [Text, List of [Text]]; //points back to root level "Sentry Transaction" dictionary
        _spanId: Text;
        _parentId: Text;
        _finished: Boolean;
        _started: Boolean;
        _startedTimestampUtc: Text;
        _description: Text;
        _operation: Text;

    procedure __Start(Description: Text; Operation: Text; ParentId: Text; var SpanState: Dictionary of [Text, List of [Text]]);
    begin
        if (_started) then
            exit;

        _startedTimestampUtc := Format(CurrentDateTime, 0, 9);
        _spanState := SpanState;
        _description := Description;
        _operation := Operation;
        _parentId := ParentId;
        _spanId := Format(CreateGuid(), 0, 3).ToLower();
        _started := true;
    end;

    procedure StartChildSpan(Description: Text; Operation: Text; var SentrySpanOut: Codeunit "NPR Sentry Span")
    begin
        SentrySpanOut.__Start(Description, Operation, _spanId, _spanState);
    end;

    procedure Finish()
    var
        values: List of [text];
    begin
        if (not _started) or (_finished) then
            exit;

        values.Add(_parentId);
        values.Add(_description);
        values.Add(_operation);
        values.Add(_startedTimestampUtc);
        values.Add(Format(CurrentDateTime, 0, 9));
        _spanState.Add(_spanId, values);

        _finished := true;
    end;

    procedure FinishWithError(ErrorMessage: Text; ErrorCallStack: Text)
    begin
        // TODO: Implement
        Finish();
    end;
}