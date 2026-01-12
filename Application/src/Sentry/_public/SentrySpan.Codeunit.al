codeunit 6248498 "NPR Sentry Span"
{
    Access = Public;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        _id: Text;
        _parentId: Text;
        _description: Text;
        _operation: Text;
        _startedTimestampUtc: Text;
        _finishedTimestampUtc: Text;
        _SentryScope: Codeunit "NPR Sentry Scope"; //Single instance
        _metadata: Dictionary of [Text, Text];
        _status: Enum "NPR Sentry Span Status";
#endif

    procedure Finish()
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _finishedTimestampUtc := Format(CurrentDateTime, 0, 9);
        _SentryScope.SetActiveSpanId(_parentId);
#endif
    end;

    procedure Finish(Status: Enum "NPR Sentry Span Status")
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _status := Status;
        Finish();
#endif
    end;

    procedure SetStatus(Status: Enum "NPR Sentry Span Status")
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _status := Status;
#endif
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure SetStatusFromHttpCode(HttpStatusCode: Integer)
    begin
        case true of
            (HttpStatusCode >= 200) and (HttpStatusCode < 300):
                _status := _status::Ok;
            HttpStatusCode = 400:
                _status := _status::InvalidArgument;
            HttpStatusCode = 401:
                _status := _status::Unauthenticated;
            HttpStatusCode = 403:
                _status := _status::PermissionDenied;
            HttpStatusCode = 404:
                _status := _status::NotFound;
            HttpStatusCode = 409:
                _status := _status::AlreadyExists;
            HttpStatusCode = 429:
                _status := _status::ResourceExhausted;
            HttpStatusCode = 499:
                _status := _status::Cancelled;
            HttpStatusCode = 501:
                _status := _status::Unimplemented;
            HttpStatusCode = 503:
                _status := _status::Unavailable;
            HttpStatusCode = 504:
                _status := _status::DeadlineExceeded;
            (HttpStatusCode >= 500) and (HttpStatusCode < 600):
                _status := _status::InternalError;
            else
                _status := _status::Unknown;
        end;
    end;

    internal procedure SetStatusFromResult(Result: Boolean)
    begin
        if Result then
            _status := _status::Ok
        else
            _status := _status::InternalError;
    end;

    internal procedure Create(parentId: Text; description: Text; operation: Text)
    var
        Guid: Text;
    begin
        Guid := Format(CreateGuid(), 0, 3).ToLower();

        _parentId := parentId;
        _description := Description;
        _operation := Operation;
        _id := Guid.Substring(1, 8) + Guid.Substring(25, 8); // we use uuidv4 to generate a 16 digit hex random string
        _startedTimestampUtc := Format(CurrentDateTime, 0, 9);

        _SentryScope.SetActiveSpanId(_id);
    end;

    internal procedure SetMetadata(var Client: HttpClient; var Request: HttpRequestMessage; var Response: HttpResponseMessage; Success: Boolean)
    begin
        _metadata.Add('method', Request.Method);
        _metadata.Add('url', Request.GetRequestUri());
        _metadata.Add('status_code', Format(Response.HttpStatusCode));
        _metadata.Add('clientTimeout', Format(Client.Timeout()));

        if Success then
            SetStatusFromHttpCode(Response.HttpStatusCode)
        else
            _status := _status::InternalError;
    end;

    internal procedure SetMetadata(Operation: Text; var RecRef: RecordRef; RowsRead: BigInteger; Result: Boolean)
    var
        PrevLanguage: Integer;
    begin
        PrevLanguage := GlobalLanguage();
        GlobalLanguage(1033);

        _metadata.Add('db.system', 'businesscentral');
        _metadata.Add('db.operation', StrSubstNo('%1 %2', Operation, RecRef.ReadIsolation));
        _metadata.Add('db.sql.table', RecRef.Name);
        _metadata.Add('db.statement', StrSubstNo('%1 %2 %3', Operation, RecRef.ReadIsolation, RecRef.GetView(true)));
        _metadata.Add('db.rows_read', Format(RowsRead));
        _metadata.Add('db.result', Format(Result, 0, 9));

        SetStatusFromResult(Result);

        GlobalLanguage(PrevLanguage);
    end;

    internal procedure ToJson(Json: Codeunit "NPR Json Builder"; traceId: Text): Codeunit "NPR Json Builder"
    var
        SentryMetadata: Codeunit "NPR Sentry Metadata";
        metadataKey: Text;
    begin
        Json
            .StartObject('')
                .AddProperty('span_id', _Id)
                .AddProperty('parent_span_id', _parentId)
                .AddProperty('description', _description)
                .AddProperty('op', _operation)
                .AddProperty('start_timestamp', _startedTimestampUtc)
                .AddProperty('timestamp', _finishedTimestampUtc)
                .AddProperty('trace_id', traceId)
                .AddProperty('status', Format(_status));

        if _metadata.Count > 0 then begin
            Json.StartObject('data');
            foreach metadataKey in _metadata.Keys() do
                Json.AddProperty(metadataKey, _metadata.Get(metadataKey));
            Json.EndObject();
        end;

        Json.StartObject('tags');
        SentryMetadata.WriteTagsForBackendEvent(Json);
        Json.EndObject();

        Json.EndObject();
        exit(Json);
    end;

    internal procedure GetId(): Text
    begin
        exit(_id);
    end;
#endif
}
