#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185051 "NPR API Request"
{
    var
        _HttpMethod: Enum "Http Method";
        _Path: Text;
        _ModuleName: Text;
        _RelativePathSegments: List of [Text];
        _QueryParams: Dictionary of [Text, Text];
        _Headers: Dictionary of [Text, Text];
        _BodyJson: JsonToken;
        _MatchedRouteTemplate: Text;

    #region Initializer
    procedure Init(RequestHttpMethod: Enum "Http Method"; RequestPath: Text; RequestRelativePathSegments: List of [Text]; RequestQueryParams: Dictionary of [Text, Text];
        RequestHeaders: Dictionary of [Text, Text]; RequestBodyJson: JsonToken)
    begin
        _HttpMethod := RequestHttpMethod;
        _Path := RequestPath;
        _RelativePathSegments := RequestRelativePathSegments;
        _QueryParams := RequestQueryParams;
        _Headers := RequestHeaders;
        _BodyJson := RequestBodyJson;
        _ModuleName := _RelativePathSegments.Get(1);
        _MatchedRouteTemplate := '';
    end;
    #endregion

    #region Getters
    procedure HttpMethod(): Enum "Http Method"
    begin
        exit(_HttpMethod);
    end;

    procedure ModuleName(): Text
    begin
        exit(_ModuleName);
    end;

    procedure FullPath(): Text
    begin
        exit(_Path);
    end;

    procedure Paths(): List of [Text]
    begin
        exit(_RelativePathSegments);
    end;

    procedure QueryParams(): Dictionary of [Text, Text]
    begin
        exit(_QueryParams);
    end;

    procedure Headers(): Dictionary of [Text, Text]
    begin
        exit(_Headers);
    end;

    procedure BodyJson(): JsonToken
    begin
        exit(_BodyJson);
    end;

    procedure GetMatchedRouteTemplate(): Text
    begin
        exit(_MatchedRouteTemplate);
    end;

    procedure ApiVersion(): Date
    var
        _apiVersion: Date;
    begin
        if not _Headers.ContainsKey('x-api-version') then
            exit(Today());

        Evaluate(_apiVersion, _Headers.Get('x-api-version'), 9);
        exit(_apiVersion);
    end;

    procedure Match(Method: Text; _fullPath: Text): Boolean
    var
        _Paths: List of [Text];
        i: Integer;
    begin
        if (Format(_HttpMethod) <> Method) then
            exit(false);

        _Paths := _fullPath.Split('/');
        _Paths.Remove('');
        if (_Paths.Count() <> _RelativePathSegments.Count()) then
            exit(false);

        for i := 1 to _Paths.Count() do begin
            if (not _Paths.Get(i).StartsWith(':')) then begin
                if (_Paths.Get(i).ToLower() <> _RelativePathSegments.Get(i).ToLower()) then
                    exit(false);
            end;
        end;

        _MatchedRouteTemplate := _fullPath;
        exit(true);
    end;

    procedure GetData(TableId: Integer; Fields: dictionary of [Integer, Text]): JsonObject
    begin
        exit(GetData(TableId, Fields, MaxPageSize()));
    end;

    /// <summary>
    /// Reads a page of records from a table. Use this overload when the natural page size of the
    /// endpoint is smaller than the module maximum, for example because the records are very wide.
    /// A pageSize supplied by the caller still wins and is still capped at the module maximum.
    /// </summary>
    procedure GetData(TableId: Integer; Fields: dictionary of [Integer, Text]; DefaultPageSize: Integer): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(GetRecords(RecRef, Fields, DefaultPageSize, false));
    end;

    /// <summary>
    /// Reads a page in row version order with the delta load window applied, without the caller
    /// having to pass sync as a query parameter. Use this when an endpoint is incremental by
    /// definition rather than on request. The table must have a key that starts with
    /// SystemRowVersion; check HasRowVersionKey first so a missing index can be reported to the
    /// caller instead of raised as an error.
    /// </summary>
    procedure GetDataInRowVersionOrder(TableId: Integer; Fields: dictionary of [Integer, Text]; DefaultPageSize: Integer): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(GetRecords(RecRef, Fields, DefaultPageSize, true));
    end;

    procedure GetData(Record: Variant; Fields: dictionary of [Integer, Text]): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(GetRecords(RecRef, Fields, MaxPageSize(), false));
    end;

    procedure GetData(TableId: Integer; Fields: dictionary of [Integer, Text]; id: Text): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(GetRecord(RecRef, Fields, Id));
    end;

    procedure GetData(Record: Variant; Fields: dictionary of [Integer, Text]; id: Text): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(GetRecord(RecRef, Fields, Id));
    end;

    local procedure GetRecord(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]; id: Text): JsonObject
    var
        RecordJson: JsonObject;
        FieldNo: Integer;
        FieldRef: FieldRef;
        Field: Record Field;
    begin
        if not Fields.ContainsKey(RecRef.SystemIdNo()) then
            Fields.Add(RecRef.SystemIdNo(), 'id');

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
            if Field.Class = Field.Class::FlowField then
                RecRef.SetAutoCalcFields(FieldNo);
#endif
        end;

        if not Fields.ContainsKey(0) then
            Fields.Add(0, 'rowVersion');

        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;
        RecRef.GetBySystemId(id);

        foreach FieldNo in Fields.Keys() do begin
            FieldRef := RecRef.Field(FieldNo);
            AddFieldToJson(FieldRef, RecordJson, Fields.Get(FieldNo));
        end;

        exit(RecordJson);
    end;

    local procedure GetRecords(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]; DefaultPageSize: Integer; ForceRowVersionOrder: Boolean): JsonObject
    var
        DataArray: JsonArray;
        RecordJson: JsonObject;
        ResultJson: JsonObject;
        Limit: Integer;
        FieldNo: Integer;
        i: Integer;
        FieldRef: FieldRef;
        MoreRecords: Boolean;
        PageKey: Text;
        Field: Record Field;
        Sync: Boolean;
        PageContinuation: Boolean;
        DataFound: Boolean;
    begin
        if (DefaultPageSize < 1) or (DefaultPageSize > MaxPageSize()) then
            DefaultPageSize := MaxPageSize();

        Limit := DefaultPageSize;
        if _QueryParams.ContainsKey('pageSize') then
            Evaluate(Limit, _QueryParams.Get('pageSize'));

        if (Limit < 1) then
            Limit := DefaultPageSize;
        if (Limit > MaxPageSize()) then
            Limit := MaxPageSize();

        if _QueryParams.ContainsKey('pageKey') then begin
            ApplyPageKey(_QueryParams.Get('pageKey'), RecRef);
            PageContinuation := true;
        end;

        Sync := ForceRowVersionOrder;
        if not Sync then
            if _QueryParams.ContainsKey('sync') then
                Evaluate(Sync, _QueryParams.Get('sync'));

        if Sync then begin
            SetKeyToRowVersion(RecRef);
            ApplyRowVersionWindow(RecRef);
        end;

        if not Fields.ContainsKey(RecRef.SystemIdNo()) then
            Fields.Add(RecRef.SystemIdNo(), 'id');

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
            if Field.Class = Field.Class::FlowField then
                RecRef.SetAutoCalcFields(FieldNo);
#endif
        end;

        if Sync and (not Fields.ContainsKey(0)) then
            Fields.Add(0, 'rowVersion');

        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;

        if PageContinuation then
            DataFound := RecRef.Find('>')
        else
            DataFound := RecRef.Find('-');

        if DataFound then begin
            repeat
                Clear(RecordJson);
                foreach FieldNo in Fields.Keys() do begin
                    FieldRef := RecRef.Field(FieldNo);
                    AddFieldToJson(FieldRef, RecordJson, Fields.Get(FieldNo));
                end;
                DataArray.Add(RecordJson);

                i += 1;
                if (i = Limit) then
                    PageKey := GetPageKey(RecRef);
                MoreRecords := RecRef.Next() <> 0;
            until (not MoreRecords) or (i = Limit);
        end;

        if not MoreRecords then
            PageKey := '';

        ResultJson.Add('morePages', MoreRecords);
        ResultJson.Add('nextPageKey', PageKey);
        ResultJson.Add('nextPageURL', GetNextPageUrl(PageKey));
        ResultJson.Add('data', DataArray);

        exit(ResultJson);
    end;

    /// <summary>
    /// Narrows a sync read to the row versions that are settled, and applies the caller's
    /// lastRowVersion as the lower bound.
    ///
    /// A row version is handed out when a write starts but only becomes visible when it commits, so
    /// a writer that started later can commit earlier. Reading everything up to the highest visible
    /// version would step over the row that lost that race, and because the consumer then stores the
    /// higher version as its watermark it would never come back for it. Anything below the minimum
    /// active row version is committed and cannot appear later, so the page stops there.
    ///
    /// Example: rows 10 and 12 have committed and a still open transaction holds 11. Without the
    /// upper bound the consumer receives 10 and 12, stores 12, and row 11 is lost for good. With it
    /// the page stops at 10, and 11 and 12 arrive on the next call.
    /// </summary>
    local procedure ApplyRowVersionWindow(var RecRef: RecordRef)
    var
        SettledBelow: BigInteger;
        LowerBound: Text;
    begin
        SettledBelow := Database.MinimumActiveRowVersion();

        if not _QueryParams.Get('lastRowVersion', LowerBound) then
            LowerBound := '';

        if LowerBound = '' then
            RecRef.Field(0).SetFilter('<%1', Format(SettledBelow, 0, 9))
        else
            RecRef.Field(0).SetFilter('>%1&<%2', LowerBound, Format(SettledBelow, 0, 9));
    end;

    procedure SetKeyToRowVersion(var RecRef: RecordRef)
    var
        KeyIndex: Integer;
    begin
        KeyIndex := FindRowVersionKeyIndex(RecRef);
        if KeyIndex = 0 then
            Error('Cannot use sync mode on %1, missing index on rowVersion. This is a programming bug.', RecRef.Name);

        RecRef.CurrentKeyIndex(KeyIndex);
        RecRef.Ascending(true);
    end;

    /// <summary>
    /// Tells whether the table can be read in sync mode, i.e. whether it has a key that starts with
    /// SystemRowVersion. Call this before SetKeyToRowVersion when the table is not known up front,
    /// so a missing index can be reported to the caller instead of raised as an error.
    /// </summary>
    procedure HasRowVersionKey(var RecRef: RecordRef): Boolean
    begin
        exit(FindRowVersionKeyIndex(RecRef) <> 0);
    end;

    local procedure FindRowVersionKeyIndex(var RecRef: RecordRef): Integer
    var
        KeyRef: KeyRef;
        i: Integer;
    begin
        for i := 1 to RecRef.KeyCount() do begin
            KeyRef := RecRef.KeyIndex(i);
            if KeyRef.FieldIndex(1).Number = 0 then //FieldRef 0 is rowversion
                exit(i);
        end;
        exit(0);
    end;

    local procedure MaxPageSize(): Integer
    begin
        exit(20000);
    end;

    procedure GetPageKey(var RecRef: RecordRef): Text
    var
        JsonPageKey: JsonObject;
        JsonText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        Fields: JsonObject;
        KeyRef: KeyRef;
        TempRecRef: RecordRef;
        i: Integer;
        FieldRef: FieldRef;
    begin
        TempRecRef.Open(RecRef.Number, true);
        KeyRef := RecRef.KeyIndex(RecRef.CurrentKeyIndex);
        for i := 1 to KeyRef.FieldCount() do begin
            FieldRef := KeyRef.FieldIndex(i);
            Fields.Add(Format(FieldRef.Number), Format(FieldRef.Value, 0, 9));
        end;
        if TempRecRef.CurrentKeyIndex() <> RecRef.CurrentKeyIndex() then begin
            KeyRef := RecRef.KeyIndex(TempRecRef.CurrentKeyIndex);
            for i := 1 to KeyRef.FieldCount() do begin
                FieldRef := KeyRef.FieldIndex(i);
                if not Fields.Contains(Format(FieldRef.Number)) then
                    Fields.Add(Format(FieldRef.Number), Format(FieldRef.Value, 0, 9));
            end;
        end;

        JsonPageKey.Add('view', RecRef.GetView(false));
        JsonPageKey.Add('indexFields', Fields);
        JsonPageKey.WriteTo(JsonText);
        exit(ToUrlSafeBase64(Base64Convert.ToBase64(JsonText)));
    end;

    procedure ApplyPageKey(PageKeyBase64: Text; var RecRef: RecordRef)
    var
        Base64Convert: Codeunit "Base64 Convert";
        JsonPageKey: JsonObject;
        JsonToken: JsonToken;
        FieldNo: Text;
        FieldNoInteger: Integer;
        FieldValueToken: JsonToken;
        FieldRef: FieldRef;
    begin
        JsonPageKey.ReadFrom(Base64Convert.FromBase64(FromUrlSafeBase64(PageKeyBase64)));
        JsonPageKey.Get('view', JsonToken);
        RecRef.SetView(JsonToken.AsValue().AsText());
        JsonPageKey.Get('indexFields', JsonToken);
        foreach FieldNo in JsonToken.AsObject().Keys() do begin
            Evaluate(FieldNoInteger, FieldNo);
            JsonToken.AsObject().Get(FieldNo, FieldValueToken);
            FieldRef := RecRef.Field(FieldNoInteger);
            ReadValueFromJson(FieldRef, FieldValueToken.AsValue());
        end;
    end;

    local procedure ToUrlSafeBase64(Base64: Text): Text
    begin
        Base64 := Base64.Replace('+', '-');
        Base64 := Base64.Replace('/', '_');
        exit(Base64.TrimEnd('='));
    end;

    local procedure FromUrlSafeBase64(UrlSafeBase64: Text): Text
    var
        PaddingNeeded: Integer;
    begin
        UrlSafeBase64 := UrlSafeBase64.Replace('-', '+');
        UrlSafeBase64 := UrlSafeBase64.Replace('_', '/');
        UrlSafeBase64 := UrlSafeBase64.Replace(' ', '+');
        PaddingNeeded := (4 - (StrLen(UrlSafeBase64) mod 4)) mod 4;
        if PaddingNeeded > 0 then
            UrlSafeBase64 += PadStr('', PaddingNeeded, '=');
        exit(UrlSafeBase64);
    end;

    local procedure AddFieldToJson(var FieldRef: FieldRef; var JsonObj: JsonObject; FieldName: Text)
    var
        StringValue: Text;
        BooleanValue: Boolean;
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
        PrevLanguage: Integer;
    begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25
        if FieldRef.Class = FieldCLass::FlowField then
            FieldRef.CalcField();
#endif

        if FieldRef.Number = 0 then begin
            JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 9));
            exit;
        end;

        // An enum backed field reports its type as Option, because the platform has no separate
        // Enum field type, so this has to be tested before the case arms below or it can never be
        // reached. The value name is the same in every language; the caption that Format would
        // return is translated, which makes it useless as a key for a consumer.
        if FieldRef.IsEnum() then begin
            JsonObj.Add(FieldName, FieldRef.GetEnumValueName(FieldRef.Value()));
            exit;
        end;

        case FieldRef.Type() of
            FieldRef.Type::Integer:
                begin
                    IntegerValue := FieldRef.Value();
                    JsonObj.Add(FieldName, IntegerValue);
                end;
            FieldRef.Type::Decimal:
                begin
                    DecimalValue := FieldRef.Value();
                    JsonObj.Add(FieldName, DecimalValue);
                end;
            FieldRef.Type::Boolean:
                begin
                    BooleanValue := FieldRef.Value();
                    JsonObj.Add(FieldName, BooleanValue);
                end;
            FieldRef.Type::Text,
            FieldRef.Type::Code:
                begin
                    StringValue := FieldRef.Value();
                    JsonObj.Add(FieldName, StringValue);
                end;
            FieldRef.Type::BigInteger:
                begin
                    BigIntegerValue := FieldRef.Value();
                    JsonObj.Add(FieldName, BigIntegerValue);
                end;
            FieldRef.Type::Guid:
                JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 4).ToLower());
            FieldRef.Type::Option:
                begin
                    PrevLanguage := GlobalLanguage();
                    JsonObj.Add(FieldName, Format(FieldRef.Value));
                    GlobalLanguage(PrevLanguage);
                end;
            else
                // Date, DateTime, Time, Duration, DateFormula and RecordID land here and are written
                // in the invariant format, so a consumer can parse them without knowing the locale.
                JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 9));
        end;
    end;

    local procedure ReadValueFromJson(var FieldRef: FieldRef; JsonValue: JsonValue)
    var
        BigIntegerValue: BigInteger;
        GuidValue: Guid;
    begin
        case FieldRef.Type() of
            FieldRef.Type::Integer:
                FieldRef.Value := JsonValue.AsInteger();
            FieldRef.Type::Decimal:
                FieldRef.Value := JsonValue.AsDecimal();
            FieldRef.Type::Boolean:
                FieldRef.Value := JsonValue.AsBoolean();
            FieldRef.Type::Text:
                FieldRef.Value := JsonValue.AsText();
            FieldRef.Type::Code:
                FieldRef.Value := JsonValue.AsCode();
            FieldRef.Type::BigInteger:
                begin
                    Evaluate(BigIntegerValue, JsonValue.AsText());
                    FieldRef.Value := BigIntegerValue;
                end;
            FieldRef.Type::Guid:
                begin
                    Evaluate(GuidValue, JsonValue.AsText());
                    FieldRef.Value := GuidValue;
                end;
            FieldRef.Type::Date:
                FieldRef.Value := JsonValue.AsDate();
            FieldRef.Type::DateTime:
                FieldRef.Value := JsonValue.AsDateTime();
            FieldRef.Type::Option:
                FieldRef.Value := JsonValue.AsOption();
            FieldRef.Type::Time:
                FieldRef.Value := JsonValue.AsTime();
            else
                Error('Unsupported field type, this is a programming bug.');
        end;
    end;

    procedure GetNextPageUrl(NextPageKey: Text): Text
    begin
        exit(GetNextPageUrl(NextPageKey, false));
    end;

    // Query values arrive decoded from the proxy; EncodeQueryValues re-encodes them so a '+' or '&' in a value survives the round trip.
    procedure GetNextPageUrl(NextPageKey: Text; EncodeQueryValues: Boolean): Text
    var
        Uri: Codeunit Uri;
        Url: Text;
        QueryParam: Text;
        QueryString: Text;
    begin
        if (NextPageKey = '') then
            exit('');

        Url := StrSubstNo('https://api.npretail.app%1', _Path);

        foreach QueryParam in _QueryParams.Keys() do begin
            if QueryParam <> 'pageKey' then begin
                if QueryString = '' then
                    QueryString += '?'
                else
                    QueryString += '&';

                if EncodeQueryValues then
                    QueryString += StrSubstNo('%1=%2', Uri.EscapeDataString(QueryParam), Uri.EscapeDataString(_QueryParams.Get(QueryParam)))
                else
                    QueryString += StrSubstNo('%1=%2', QueryParam, _QueryParams.Get(QueryParam));
            end
        end;
        if QueryString = '' then
            QueryString += StrSubstNo('?pageKey=%1', NextPageKey)
        else
            QueryString += StrSubstNo('&pageKey=%1', NextPageKey);

        Exit(Url + QueryString);
    end;

    /// <summary>
    /// Call this procedure at the top of your API request handler if you have business logic that 
    /// is sensitive to cache misses. It will make your caching approach pessimistic, 
    /// meaning unless the API consumer uses our header correctly, we will skip reading from cache.
    /// This is much better than just calling SelectLatestVersion() always, as it will still be possible
    /// for a well-behaving consumer to use the cache as much as possible while guaranteeing robustness
    /// in all cases.
    /// </summary>
    procedure SkipCacheIfNonStickyRequest(TableIds: List of [Integer])
    var
        Sentry: Codeunit "NPR Sentry";
        CacheHit: Boolean;
        ActualServerId: Integer;
        RequestServerId: Integer;
        AuthMode: Text;
        HeaderState: Text;
        HeaderValue: Text;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        TableId: Integer;
#endif
    begin
        ActualServerId := ServiceInstanceId();

        HeaderState := 'absent';
        RequestServerId := -1; // Existing Sentry filters rely on -1 meaning absent or invalid.
        if _Headers.Get('x-server-cache-id', HeaderValue) then begin
            HeaderState := 'invalid';
            if HeaderValue <> '' then
                if Evaluate(RequestServerId, HeaderValue) then
                    if RequestServerId > 0 then begin
                        if RequestServerId = ActualServerId then begin
                            HeaderState := 'match';
                            CacheHit := true;
                        end else
                            HeaderState := 'mismatch';
                    end else
                        RequestServerId := -1;
        end;

        // Telemetry hint only: NP API-key auth overwrites x-np-app-id;
        // native requests may retain a client-supplied value.
        AuthMode := 'native';
        if _Headers.ContainsKey('x-np-app-id') then
            AuthMode := 'np-api-key';

        Sentry.AddTransactionTag('bc.cache.authMode', AuthMode);
        Sentry.AddTransactionTag('bc.cache.headerState', HeaderState);
        Sentry.AddTransactionTag('bc.cache.actualServerId', Format(ActualServerId));
        Sentry.AddTransactionTag('bc.cache.headerServerId', Format(RequestServerId));
        Sentry.AddTransactionTag('bc.cache.miss', Format((not CacheHit), 0, 9));

        if CacheHit then
            exit;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        foreach TableId in TableIds do begin
            SelectLatestVersion(TableId);
        end;
#else
        SelectLatestVersion();
#endif
    end;

    #endregion
}
#endif