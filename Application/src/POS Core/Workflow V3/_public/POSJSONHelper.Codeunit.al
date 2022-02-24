codeunit 6014574 "NPR POS JSON Helper"
{
    var
        _Scope: Dictionary of [Guid, Text];
        _Context: JsonObject;
        _JObject: JsonObject;
        _JObjectBefore: JsonObject;
        _JRoot: JsonObject;
        _Initialized: Boolean;

    procedure InitializeJObjectParser(JObjectIn: JsonObject)
    begin
        _JObject := JObjectIn;
        _JRoot := _JObject;
        _Initialized := true;
    end;

    local procedure MakeSureJObjectParserIsInitialized("Key": Text)
    var
        ParserNotInitializedErr: Label 'JObject parser is not initialized, and an attempt was made to parse value "%1".';
    begin
        if not _Initialized then
            Error(ParserNotInitializedErr, Key);
    end;

    procedure ToString(): Text
    var
        Root: Text;
    begin
        MakeSureJObjectParserIsInitialized('');
        _JRoot.WriteTo(Root);
        exit(Root);
    end;

    local procedure GetJToken(var JToken: JsonToken; Property: Text): Boolean
    var
    begin
        MakeSureJObjectParserIsInitialized(Property);

        if not _JObject.Get(Property, JToken) then
            exit(false);

        exit(true);
    end;

    procedure GetJToken(Property: Text) JToken: JsonToken
    begin
        MakeSureJObjectParserIsInitialized(Property);
        _JObject.Get(Property, JToken);
    end;

    local procedure GetJTokenPath(var JToken: JsonToken; Property: Text)
    begin
        MakeSureJObjectParserIsInitialized(Property);
        _JObject.SelectToken(Property, JToken);
    end;

    procedure TrySetScope(Name: Text): Boolean
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);

        if Name in ['', '{}', '/'] then begin
            _JObject := _JRoot;
        end else begin
            if not GetJToken(JToken, Name) then
                exit(false);

            if not JToken.IsObject() then
                exit(false);

            _JObject := JToken.AsObject();
        end;

        exit(true);
    end;

    procedure SetScope(Name: Text)
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);

        if Name in ['', '{}', '/'] then begin
            _JObject := _JRoot;
        end else begin
            JToken := GetJToken(Name);
            _JObject := JToken.AsObject();
        end;
    end;

    procedure SetScopeRoot()
    begin
        TrySetScope('/');
    end;

    procedure SetScopeParameters()
    begin
        SetScopeRoot();
        SetScope('parameters');
    end;

    procedure TrySetScopeParameters(): Boolean
    begin
        SetScopeRoot();
        exit(TrySetScope('parameters'));
    end;

    procedure SetScopePath(Name: Text)
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);
        if CopyStr(Name, 1, 2) = '$.' then
            _JObject := _JRoot;
        GetJTokenPath(JToken, Name);
        _JObject := JToken.AsObject();
    end;

    local procedure StoreContext()
    begin
        _JObjectBefore := _JObject;
    end;

    local procedure RestoreContext()
    begin
        _JObject := _JObjectBefore;
    end;

    procedure StoreScope() ScopeID: Guid
    var
        JObjectText: Text;
    begin
        ScopeID := CreateGuid();
        _JObject.WriteTo(JObjectText);
        _Scope.Add(ScopeID, JObjectText);
    end;

    procedure RestoreScope(ScopeID: Guid): Boolean
    var
        JObjectText: Text;
    begin
        if not _Scope.ContainsKey(ScopeID) then
            exit(false);

        _Scope.Get(ScopeID, JObjectText);
        _JObject.ReadFrom(JObjectText);
        exit(true);
    end;

    procedure GetJsonObject(Property: Text) JObjectOut: JsonObject
    var
        JToken: JsonToken;
    begin
        JToken := GetJToken(Property);
        JObjectOut := JToken.AsObject();
    end;

    procedure GetJsonObject(Property: Text; var JObjectOut: JsonObject): Boolean
    var
        JToken: JsonToken;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        if not JToken.IsObject() then
            exit(false);

        JObjectOut := JToken.AsObject();
        exit(true);
    end;

    local procedure JsonTokenToString(JToken: JsonToken) Result: Text
    var
        JValue: JsonValue;
        JObj: JsonObject;
    begin
        case true of
            JToken.IsObject():
                begin
                    JObj := JToken.AsObject();
                    JObj.WriteTo(Result);
                    exit;
                end;
            JToken.IsValue():
                begin
                    JValue := JToken.AsValue();

                    if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
                        exit(JValue.AsText());
                end;
        end;
        JObj := JToken.AsObject();//trigger builtin error
    end;

    local procedure JsonTokenToString(JToken: JsonToken; var ResultOut: Text): Boolean
    var
        JValue: JsonValue;
        JObj: JsonObject;
    begin
        case true of
            JToken.IsObject():
                begin
                    JObj := JToken.AsObject();
                    JObj.WriteTo(ResultOut);
                    exit(true);
                end;
            JToken.IsValue():
                begin
                    JValue := JToken.AsValue();

                    if (not JValue.IsNull()) and (not JValue.IsUndefined()) then begin
                        ResultOut := JValue.AsText();
                        exit(true);
                    end;
                end;
        end;
        exit(false);
    end;

    procedure GetString(Property: Text; var ResultOut: text): Boolean
    var
        JToken: JsonToken;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        exit(JsonTokenToString(JToken, ResultOut));
    end;

    procedure GetString(Property: Text) Result: Text
    var
        JToken: JsonToken;
    begin
        JToken := GetJToken(Property);
        Result := JsonTokenToString(JToken);
    end;

    local procedure JsonStringToBool(String: Text) Bool: Boolean
    begin
        case true of
            String = '1':
                exit(true);
            String in ['0', '']:
                exit(false);
            else
                Evaluate(Bool, String);
        end;
    end;

    local procedure JsonStringToBool(String: Text; var ValueOut: Boolean): Boolean
    begin
        case true of
            String = '1':
                begin
                    ValueOut := true;
                    exit(true);
                end;
            String in ['0', '']:
                begin
                    ValueOut := false;
                    exit(true);
                end;
            else begin
                    exit(Evaluate(ValueOut, String));
                end;
        end;
    end;

    procedure GetBoolean(Property: Text; var ValueOut: Boolean) Bool: Boolean
    var
        String: Text;
    begin
        String := GetString(Property);
        Bool := JsonStringToBool(String, ValueOut);
    end;

    procedure GetBoolean(Property: Text) Value: Boolean
    begin
        exit(JsonStringToBool(GetString(Property)));
    end;

    procedure GetDecimal(Property: Text; var ResultOut: Decimal): Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        if not (JToken.IsValue) then
            exit(false);

        JValue := JToken.AsValue();
        if (JValue.IsNull) or (JValue.IsUndefined) then
            exit(false);

        ResultOut := JValue.AsDecimal();
        exit(true);
    end;

    procedure GetDecimal(Property: Text): Decimal
    begin
        exit(GetJToken(Property).AsValue().AsDecimal());
    end;

    procedure GetInteger(Property: Text; var ResultOut: Integer): Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        if not (JToken.IsValue) then
            exit(false);

        JValue := JToken.AsValue();
        if (JValue.IsNull) or (JValue.IsUndefined) then
            exit(false);

        ResultOut := JValue.AsInteger();
        exit(true);
    end;

    procedure GetInteger(Property: Text): Integer
    begin
        exit(GetJToken(Property).AsValue().AsInteger());
    end;

    procedure GetBigInteger(Property: Text; var ResultOut: BigInteger): Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        if not (JToken.IsValue) then
            exit(false);

        JValue := JToken.AsValue();
        if (JValue.IsNull) or (JValue.IsUndefined) then
            exit(false);

        ResultOut := JValue.AsBigInteger();
        exit(true);
    end;

    procedure GetBigInteger(Property: Text): BigInteger
    begin
        exit(GetJToken(Property).AsValue().AsBigInteger());
    end;

    procedure GetDate(Property: Text; var ResultOut: Date): Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit(false);

        if not (JToken.IsValue) then
            exit(false);

        JValue := JToken.AsValue();
        if (JValue.IsNull) or (JValue.IsUndefined) then
            exit(false);

        ResultOut := DT2DATE(JValue.AsDateTime());
        exit(true);
    end;

    procedure GetDate(Property: Text) Date: Date
    begin
        exit(GetJToken(Property).AsValue().AsDate());
    end;

    procedure GetJObject(var JObjectOut: JsonObject)
    begin
        MakeSureJObjectParserIsInitialized('');
        JObjectOut := _JObject;
    end;

    procedure HasProperty(Property: Text): Boolean
    begin
        exit(_JObject.Contains(Property));
    end;

    procedure GetStringParameter(ParameterName: Text; var ResultOut: Text): Boolean
    begin
        StoreContext();
        if not TrySetScopeParameters() then begin
            RestoreContext();
            exit(false);
        end;

        if not GetString(ParameterName, ResultOut) then
            exit(false);

        RestoreContext();
        exit(true);
    end;

    procedure GetStringParameter(ParameterName: Text) Parameter: Text
    begin
        StoreContext();
        SetScopeParameters();
        Parameter := GetString(ParameterName);
        RestoreContext();
    end;

    procedure GetBooleanParameter(ParameterName: Text; var ResultOut: Boolean): Boolean
    begin
        StoreContext();
        if not TrySetScopeParameters() then begin
            RestoreContext();
            exit(false);
        end;

        if not GetBoolean(ParameterName, ResultOut) then
            exit(false);

        RestoreContext();
        exit(true);
    end;

    procedure GetBooleanParameter(ParameterName: Text) Parameter: Boolean
    begin
        StoreContext();
        SetScopeParameters();
        Parameter := GetBoolean(ParameterName);
        RestoreContext();
    end;

    procedure GetDecimalParameter(ParameterName: Text; var ResultOut: Decimal): Boolean
    begin
        StoreContext();
        if not TrySetScopeParameters() then begin
            RestoreContext();
            exit(false);
        end;

        if not GetDecimal(ParameterName, ResultOut) then
            exit(false);

        RestoreContext();
        exit(true);
    end;

    procedure GetDecimalParameter(ParameterName: Text) Parameter: Decimal
    begin
        StoreContext();
        SetScopeParameters();
        Parameter := GetDecimal(ParameterName);
        RestoreContext();
    end;

    procedure GetIntegerParameter(ParameterName: Text; var ResultOut: Integer): Boolean
    begin
        StoreContext();
        if not TrySetScopeParameters() then begin
            RestoreContext();
            exit(false);
        end;

        if not GetInteger(ParameterName, ResultOut) then
            exit(false);

        RestoreContext();
        exit(true);
    end;

    procedure GetIntegerParameter(ParameterName: Text) Parameter: Integer
    begin
        StoreContext();
        SetScopeParameters();
        Parameter := GetInteger(ParameterName);
        RestoreContext();
    end;

    procedure SetContext("Key": Text; Value: Variant)
    begin
        if _Context.Contains(Key) then
            _Context.Remove(Key);

        AddVariantValueToJsonObject(_Context, Key, Value);
    end;

    procedure GetContextObject(): JsonObject
    begin
        exit(_Context);
    end;

    procedure AddVariantValueToJsonObject(Target: JsonObject; PropertyName: Text; PropertyValue: Variant)
    var
        ValueAsText: Text;
        ValueAsDate: Date;
        ValueAsDateTime: DateTime;
        ValueAsBoolean: Boolean;
        ValueAsDecimal: Decimal;
        ValueAsInteger: Integer;
        ValueAsByte: Byte;
        ValueAsChar: Char;
        ValueAsBigInteger: BigInteger;
        ValueAsGuid: Guid;
        ValueAsJsonToken: JsonToken;
        UnsupportedPropertyTypeErr: Label 'Attempting to add property %1 of a non-serializable type to JSON object';
    begin
        case true of
            PropertyValue.IsJsonArray() or PropertyValue.IsJsonObject() or PropertyValue.IsJsonToken() or propertyValue.IsJsonValue():
                begin
                    ValueAsJsonToken := PropertyValue;
                    Target.Add(PropertyName, ValueAsJsonToken);
                end;
            PropertyValue.IsByte():
                begin
                    ValueAsByte := PropertyValue;
                    Target.Add(PropertyName, ValueAsByte);
                end;
            PropertyValue.IsChar():
                begin
                    ValueAsChar := PropertyValue;
                    Target.Add(PropertyName, ValueAsChar);
                end;
            PropertyValue.IsGuid():
                begin
                    ValueAsGuid := PropertyValue;
                    Target.Add(PropertyName, ValueAsGuid);
                end;
            PropertyValue.IsDate():
                begin
                    ValueAsDate := PropertyValue;
                    Target.Add(PropertyName, Format(ValueAsDate, 0, 9));
                end;
            PropertyValue.IsDateTime():
                begin
                    ValueAsDateTime := PropertyValue;
                    Target.Add(PropertyName, ValueAsDateTime);
                end;
            PropertyValue.IsBigInteger():
                begin
                    ValueAsBigInteger := PropertyValue;
                    Target.Add(PropertyName, ValueAsBigInteger);
                end;
            PropertyValue.IsText() or PropertyValue.IsCode() or PropertyValue.IsTextConstant():
                begin
                    ValueAsText := PropertyValue;
                    Target.Add(PropertyName, ValueAsText);
                end;
            PropertyValue.IsBoolean():
                begin
                    ValueAsBoolean := PropertyValue;
                    Target.Add(PropertyName, ValueAsBoolean);
                end;
            PropertyValue.IsDecimal():
                begin
                    ValueAsDecimal := PropertyValue;
                    Target.Add(PropertyName, ValueAsDecimal);
                end;
            PropertyValue.IsInteger() or PropertyValue.IsOption():
                begin
                    ValueAsInteger := PropertyValue;
                    Target.Add(PropertyName, ValueAsInteger);
                end;
            else
                Error(UnsupportedPropertyTypeErr, PropertyName);
        end;
    end;

    procedure GetTokenFromPath(FromObject: JsonObject; Path: Text) Result: JsonToken;
    var
        PathParts: List of [Text];
        PathPart: Text;
        Token: JsonToken;
    begin
        PathParts := Path.Split('.');
        Token := FromObject.AsToken();
        foreach PathPart in PathParts do begin
            FromObject := Token.AsObject();
            FromObject.Get(PathPart, Token);
        end;

        Result := Token;
    end;
}
