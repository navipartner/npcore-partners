codeunit 6150703 "NPR POS JSON Management"
{
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        Scope: Dictionary of [Guid, Text];
        Context: JsonObject;
        Text001: Label 'Property "%1" does not exist in JSON object.\\%2.';
        JObject: JsonObject;
        Text003: Label 'JObject parser is not initialized, and an attempt was made to parse value "%1".';
        JObjectBefore: JsonObject;
        JRoot: JsonObject;
        Initialized: Boolean;
        TextErrorUnsupportedOptionType: Label 'Attempting to add property %1 of non-serializable type %2 to JSON object';

    procedure InitializeJObjectParser(JObjectIn: JsonObject; FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        JObject := JObjectIn;
        JRoot := JObject;
        FrontEndIn := FrontEnd;
        Initialized := true;
    end;

    local procedure MakeSureJObjectParserIsInitialized("Key": Text)
    begin
        if not Initialized then
            FrontEnd.ReportBug(StrSubstNo(Text003, Key));
    end;

    procedure ToString(): Text
    var
        Root: Text;
    begin
        //-NPR5.38 [255773]
        MakeSureJObjectParserIsInitialized('');
        JRoot.WriteTo(Root);
        exit(Root);
        //+NPR5.38 [255773]
    end;

    procedure GetJToken(var JToken: JsonToken; Property: Text; WithError: Boolean): Boolean
    var
        JTokenTemp: JsonToken;
        TextTemp: Text;
    begin
        MakeSureJObjectParserIsInitialized(Property);

        //-NPR5.39 [255773]
        //JToken := JObject.Item(Property);
        //IF ISNULL(JToken) AND WithError THEN
        //  FrontEnd.ReportBug(STRSUBSTNO(Text001,Property,JObject.ToString()));
        if not JObject.Get(Property, JTokenTemp) then begin
            if WithError then begin
                JObject.WriteTo(TextTemp);
                FrontEnd.ReportBug(StrSubstNo(Text001, Property, TextTemp));
            end;
            exit(false);
        end else
            JToken := JTokenTemp;

        exit(true);
        //+NPR5.39 [255773]
    end;

    procedure GetJTokenPath(var JToken: JsonToken; Property: Text; WithError: Boolean): Boolean
    var
        JTokenTemp: JsonToken;
        TextTemp: Text;
    begin
        //-NPR5.39 [255773]
        MakeSureJObjectParserIsInitialized(Property);

        if not JObject.SelectToken(Property, JTokenTemp) then begin
            if WithError then begin
                JObject.WriteTo(TextTemp);
                FrontEnd.ReportBug(StrSubstNo(Text001, Property, TextTemp));
            end;
            exit(false);
        end else
            JToken := JTokenTemp;

        exit(true);
        //-NPR5.39 [255773]
    end;

    local procedure ObjectToVariant("Object": DotNet NPRNetObject; var Variant: Variant)
    begin
        Variant := Object;
    end;

    procedure SetScope(Name: Text; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);

        if Name in ['', '{}', '/'] then begin
            JObject := JRoot;
        end else begin
            if not GetJToken(JToken, Name, WithError) then
                exit(false);

            JObject := JToken.AsObject();
        end;

        exit(true);
    end;

    procedure SetScopeRoot(WithError: Boolean): Boolean
    begin
        exit(SetScope('/', WithError));
    end;

    procedure SetScopeParameters(WithError: Boolean): Boolean
    begin
        exit(SetScopeRoot(WithError) and SetScope('parameters', WithError));
    end;

    procedure SetScopePath(Name: Text; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);
        if CopyStr(Name, 1, 2) = '$.' then
            JObject := JRoot;
        if not GetJTokenPath(JToken, Name, WithError) then
            exit(false);

        IF JToken.IsObject() then begin
            JObject := JToken.AsObject();
            exit(true);
        end;
        exit(false);
    end;

    local procedure StoreContext()
    begin
        JObjectBefore := JObject;
    end;

    local procedure RestoreContext()
    begin
        JObject := JObjectBefore;
    end;

    procedure StoreScope() ScopeID: Guid
    var
        JObjectText: Text;
    begin
        //-NPR5.39 [255773]
        ScopeID := CreateGuid;
        JObject.WriteTo(JObjectText);
        Scope.Add(ScopeID, JObjectText);
        //+NPR5.39 [255773]
    end;

    procedure RestoreScope(ScopeID: Guid): Boolean
    var
        JObjectText: Text;
    begin
        //-NPR5.39 [255773]
        if not Scope.ContainsKey(ScopeID) then
            exit(false);

        Scope.Get(ScopeID, JObjectText);
        JObject.ReadFrom(JObjectText);
        exit(true);
        //+NPR5.39 [255773]
    end;

    procedure GetJsonObject(Property: Text; var JObjectOut: JsonObject; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        if not GetJToken(JToken, Property, WithError) then
            exit(false);

        if not JToken.IsObject() then
            exit(false);

        JObjectOut := JToken.AsObject();
        exit(true);
    end;

    procedure GetString(Property: Text; WithError: Boolean) Result: Text
    var
        JToken: JsonToken;
        JValue: JsonValue;
        JObj: JsonObject;
    begin
        GetJToken(JToken, Property, WithError);
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
    end;

    procedure GetBoolean(Property: Text; WithError: Boolean) Bool: Boolean
    var
        String: Text;
    begin
        String := GetString(Property, WithError);
        case true of
            String = '1':
                exit(true);
            String in ['0', '']:
                exit(false);
            else
                Evaluate(Bool, String);
        end;
    end;

    procedure GetDecimal(Property: Text; WithError: Boolean) Dec: Decimal
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property, WithError) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Dec := JValue.AsDecimal();
    end;

    procedure GetInteger(Property: Text; WithError: Boolean) Int: Integer
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property, WithError) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Int := JValue.AsInteger();
    end;

    procedure GetDate(Property: Text; WithError: Boolean) Date: Date
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property, WithError) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Date := JValue.AsDate();
    end;

    procedure GetBackEndId(Context: JsonObject; POSSession: Codeunit "NPR POS Session") BackEndId: Guid
    begin
        Evaluate(BackEndId, GetString('backEndId', true));
    end;

    procedure GetJObject(var JObjectOut: JsonObject)
    begin
        MakeSureJObjectParserIsInitialized('');
        JObjectOut := JObject;
    end;

    procedure HasProperty(Property: Text): Boolean
    begin
        exit(JObject.Contains(Property));
    end;

    procedure GetStringParameter(ParameterName: Text; WithError: Boolean) Parameter: Text
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetString(ParameterName, WithError);

        RestoreContext();
    end;

    procedure GetBooleanParameter(ParameterName: Text; WithError: Boolean) Parameter: Boolean
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetBoolean(ParameterName, WithError);

        RestoreContext();
    end;

    procedure GetDecimalParameter(ParameterName: Text; WithError: Boolean) Parameter: Decimal
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetDecimal(ParameterName, WithError);

        RestoreContext();
    end;

    procedure GetIntegerParameter(ParameterName: Text; WithError: Boolean) Parameter: Integer
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetInteger(ParameterName, WithError);

        RestoreContext();
    end;

    procedure GetDateParameter(ParameterName: Text; WithError: Boolean) Parameter: Date
    begin
        StoreContext();
        if not SetScopeParameters(WithError) then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetDate(ParameterName, WithError);

        RestoreContext();
    end;

    procedure SetContext("Key": Text; Value: Variant)
    begin
        if Context.Contains(Key) then
            Context.Remove(Key);

        AddVariantValueToJsonObject(Context, Key, Value);
    end;

    procedure GetContextObject(): JsonObject
    begin
        exit(Context);
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
                Error(TextErrorUnsupportedOptionType, PropertyName, GetDotNetType(PropertyValue));
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
