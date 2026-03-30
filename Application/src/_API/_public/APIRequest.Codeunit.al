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
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(GetRecords(RecRef, Fields));
    end;

    procedure GetData(Record: Variant; Fields: dictionary of [Integer, Text]): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        exit(GetRecords(RecRef, Fields));
    end;

    procedure GetData(TableId: Integer; Fields: dictionary of [Integer, Text]; id: Text): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableId);
        exit(GetData(RecRef, Fields, Id));
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

    local procedure GetRecords(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]): JsonObject
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
        if _QueryParams.ContainsKey('pageSize') then
            Evaluate(Limit, _QueryParams.Get('pageSize'));

        if (limit < 1) or (limit > 20000) then
            limit := 20000;

        if _QueryParams.ContainsKey('pageKey') then begin
            ApplyPageKey(_QueryParams.Get('pageKey'), RecRef);
            PageContinuation := true;
        end;

        if _QueryParams.ContainsKey('sync') then begin
            Evaluate(Sync, _QueryParams.Get('sync'));
            if Sync then
                SetKeyToRowVersion(RecRef);

            if _QueryParams.ContainsKey('lastRowVersion') then
                RecRef.Field(0).SetFilter('>%1', _QueryParams.Get('lastRowVersion'));
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

    procedure SetKeyToRowVersion(var RecRef: RecordRef)
    var
        KeyRef: keyRef;
        i: Integer;
    begin
        for i := 1 to RecRef.KeyCount() do begin
            KeyRef := RecRef.KeyIndex(i);
            if KeyRef.FieldIndex(1).Number = 0 then begin //FieldRef 0 is rowversion
                RecRef.CurrentKeyIndex(i);
                RecRef.Ascending(true);
                exit;
            end;
        end;

        Error('Cannot use sync mode on %1, missing index on rowVersion. This is a programming bug.', RecRef.Name);
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
        exit(Base64Convert.ToBase64(JsonText));
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
        JsonPageKey.ReadFrom(Base64Convert.FromBase64(PageKeyBase64));
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
            else begin
                if FieldRef.IsEnum() then
                    JsonObj.Add(FieldName, FieldRef.GetEnumValueName(FieldRef.Value))
                else
                    JsonObj.Add(FieldName, Format(FieldRef.Value(), 0, 9));
            end;
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
    var
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
        RequestServerId: Integer;
        Sentry: Codeunit "NPR Sentry";
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        TableId: Integer;
#endif
    begin
        if (_Headers.ContainsKey('x-server-cache-id')) then begin
            Evaluate(RequestServerId, _Headers.Get('x-server-cache-id'));
            if (RequestServerId = ServiceInstanceId()) then
                exit;
        end;

        If RequestServerId = 0 then
            RequestServerId := -1;

        Sentry.AddTransactionTag('bc.cache.headerServerId', Format(RequestServerId));
        Sentry.AddTransactionTag('bc.cache.actualServerId', Format(ServiceInstanceId()));
        Sentry.AddTransactionTag('bc.cache.miss', 'true');

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