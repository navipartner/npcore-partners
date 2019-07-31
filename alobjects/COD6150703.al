codeunit 6150703 "POS JSON Management"
{
    var
        FrontEnd: Codeunit "POS Front End Management";
        Scope: Dictionary of [Guid, Text];
        Context: DotNet npNetDictionary_Of_T_U;
        Text001: Label 'Property "%1" does not exist in JSON object.\\%2.';
        JObject: JsonObject;
        Text003: Label 'JObject parser is not initialized, and an attempt was made to parse value "%1".';
        JObjectBefore: JsonObject;
        JRoot: JsonObject;
        Initialized: Boolean;

    procedure InitializeJObjectParser(JObjectIn: JsonObject; FrontEndIn: Codeunit "POS Front End Management")
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

    local procedure ObjectToVariant("Object": DotNet npNetObject; var Variant: Variant)
    begin
        Variant := Object;
    end;

    procedure SetScope(Name: Text; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);
        if Name in ['', '{}', '/'] then
            JObject := JRoot
        else
            if not GetJToken(JToken, Name, WithError) then
                exit(false);

        IF JToken.IsObject() then begin
            JObject := JToken.AsObject();
            exit(true);
        end;
        exit(false);
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

    procedure GetString(Property: Text; WithError: Boolean): Text
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        GetJToken(JToken, Property, WithError);
        if (not JToken.IsValue) then
            exit;

        if (not JValue.IsNull()) and (not JValue.IsUndefined()) then
            exit(JValue.AsText());
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

    procedure GetBackEndId(Context: JsonObject; POSSession: Codeunit "POS Session") BackEndId: Guid
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
        MakeSureContextExists();
        if Context.ContainsKey(Key) then
            Context.Remove(Key);

        //-NPR5.37 [289442]
        case true of
            Value.IsDate:
                Context.Add(Key, Format(Value, 0, 9));
            else
                Context.Add(Key, Value);
        end;

        //Context.Add(Key,Value);
        //+NPR5.37 [289442]
    end;

    procedure GetContextObject(var ContextOut: DotNet npNetDictionary_Of_T_U)
    begin
        MakeSureContextExists();
        ContextOut := Context;
    end;

    local procedure MakeSureContextExists()
    begin
        if IsNull(Context) then
            Context := Context.Dictionary();
    end;
}