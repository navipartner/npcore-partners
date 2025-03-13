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
        Json: Codeunit "NPR JSON Builder";
        FieldNo: Integer;
        FieldRef: FieldRef;
        Field: Record Field;
    begin
        if not Fields.ContainsKey(RecRef.SystemIdNo()) then begin
            Fields.Add(RecRef.SystemIdNo(), 'id');
        end;

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
            //If MS ever realises they are missing a RecordRef.SetAutoCalcFields() add it here instead of calculating flowfields inside the loop ...
        end;

        if not Fields.ContainsKey(0) then begin
            Fields.Add(0, 'rowVersion');
        end;

        Json.StartObject('');
        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;
        RecRef.GetBySystemId(id);

        foreach FieldNo in Fields.Keys() do begin
            FieldRef := RecRef.Field(FieldNo);
            AddFieldToJson(FieldRef, Json, Fields.Get(FieldNo));
        end;

        Json.EndObject();
        exit(Json.BuildAsJsonToken().AsObject());
    end;

    local procedure GetRecords(var RecRef: RecordRef; Fields: Dictionary of [Integer, Text]): JsonObject
    var
        JsonArray: Codeunit "NPR JSON Builder";
        Limit: Integer;
        FieldNo: Integer;
        i: Integer;
        FieldRef: FieldRef;
        MoreRecords: Boolean;
        PageKey: Text;
        Field: Record Field;
        JsonObject: JsonObject;
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
            if Sync then begin
                // Error if table is missing a key that starts with rowVersion for efficient data replication.
                SetKeyToRowVersion(RecRef);
            end;

            if _QueryParams.ContainsKey('lastRowVersion') then begin
                RecRef.Field(0).SetFilter('>%1', _QueryParams.Get('lastRowVersion'));
            end;
        end;

        if not Fields.ContainsKey(RecRef.SystemIdNo()) then begin
            Fields.Add(RecRef.SystemIdNo(), 'id');
        end;

        foreach FieldNo in Fields.Keys() do begin
            Field.Get(RecRef.Number(), FieldNo);
            if Field.Class = Field.Class::Normal then
                RecRef.AddLoadFields(FieldNo);
            //If MS ever realises they are missing a RecordRef.SetAutoCalcFields() add it here instead of calculating flowfields inside the loop ...
        end;

        if Sync and (not Fields.ContainsKey(0)) then begin
            Fields.Add(0, 'rowVersion');
        end;

        JsonArray.StartArray('data');
        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;

        if PageContinuation then begin
            DataFound := RecRef.Find('>');
        end else begin
            DataFound := RecRef.Find('-');
        end;

        if DataFound then begin
            repeat
                JsonArray.StartObject();
                foreach FieldNo in Fields.Keys() do begin
                    FieldRef := RecRef.Field(FieldNo);
                    AddFieldToJson(FieldRef, JsonArray, Fields.Get(FieldNo));
                end;
                JsonArray.EndObject();

                i += 1;
                if (i = Limit) then begin
                    //Prepare next pageKey
                    PageKey := GetPageKey(RecRef);
                end;
                MoreRecords := RecRef.Next() <> 0;
            until (not MoreRecords) or (i = Limit);
        end;
        JsonArray.EndArray();

        if not MoreRecords then
            PageKey := '';

        JsonObject.Add('morePages', MoreRecords);
        JsonObject.Add('nextPageKey', PageKey);
        JsonObject.Add('nextPageURL', GetNextPageUrl(PageKey));
        JsonObject.Add('data', JsonArray.BuildAsArray());

        exit(JsonObject);
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

    local procedure AddFieldToJson(var FieldRef: FieldRef; var Json: Codeunit "NPR Json Builder"; FieldName: Text)
    var
        StringValue: Text;
        BooleanValue: Boolean;
        DecimalValue: Decimal;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
        PrevLanguage: Integer;
    begin
        if FieldRef.Class = FieldCLass::FlowField then begin
            FieldRef.CalcField();
        end;

        if FieldRef.Number = 0 then begin
            Json.AddProperty(FieldName, Format(FieldRef.Value(), 0, 9));
            exit;
        end;

        case FieldRef.Type() of
            FieldRef.Type::Integer:
                begin
                    IntegerValue := FieldRef.Value();
                    Json.AddProperty(FieldName, IntegerValue);
                end;
            FieldRef.Type::Decimal:
                begin
                    DecimalValue := FieldRef.Value();
                    Json.AddProperty(FieldName, DecimalValue);
                end;
            FieldRef.Type::Boolean:
                begin
                    BooleanValue := FieldRef.Value();
                    Json.AddProperty(FieldName, BooleanValue);
                end;
            FieldRef.Type::Text,
            FieldRef.Type::Code:
                begin
                    StringValue := FieldRef.Value();
                    Json.AddProperty(FieldName, StringValue);
                end;
            FieldRef.Type::BigInteger:
                begin
                    BigIntegerValue := FieldRef.Value();
                    Json.AddProperty(FieldName, BigIntegerValue);
                end;
            FieldRef.Type::Guid:
                begin
                    Json.AddProperty(FieldName, Format(FieldRef.Value(), 0, 4).ToLower());
                end;
            FieldRef.Type::Option:
                begin
                    PrevLanguage := GlobalLanguage();
                    Json.AddProperty(FieldName, Format(FieldRef.Value));
                    GlobalLanguage(PrevLanguage);
                end;
            else begin
                //apparently MS forgot to add FieldRef.Type::Enum so we have to check manually here:
                if FieldRef.IsEnum() then begin
                    Json.AddProperty(FieldName, FieldRef.GetEnumValueName(FieldRef.Value));
                end else begin
                    Json.AddProperty(FieldName, Format(FieldRef.Value(), 0, 9));
                end;
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

    internal procedure GetNextPageUrl(NextPageKey: Text): Text
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
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        TableId: Integer;
#endif
    begin
        if (_Headers.ContainsKey('x-server-cache-id')) then begin
            Evaluate(RequestServerId, _Headers.Get('x-server-cache-id'));
            if (RequestServerId = ServiceInstanceId()) then
                exit;
        end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
        foreach TableId in TableIds do begin
            SelectLatestVersion(TableId);
        end;
#else
        SelectLatestVersion(); // Skip cache for all tables in the entire request processing
#endif
    end;

    #endregion
}
#endif