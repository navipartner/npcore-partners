codeunit 6150703 "NPR POS JSON Management"
{
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        Scope: Dictionary of [Guid, Text];
        Context: JsonObject;
        PropertyNotInObjectErr: Label 'Property "%1" not found while %2 in JSON object:\\%3.';
        SettingScopeToParametersError: Label 'setting scope to parameters for action "%1"';
        ReadingParametersErr: Label 'reading parameters for action "%1"';
        AttemptingToAssignNonJsonToJsonErr: Label 'Attempting to assign a non-JSON property to a JSON object while %1';
        JObject: JsonObject;
        ParserNotInitializedErr: Label 'JObject parser is not initialized, and an attempt was made to parse value "%1".';
        JObjectBefore: JsonObject;
        JRoot: JsonObject;
        Initialized: Boolean;
        UnsupportedPropertyTypeErr: Label 'Attempting to add property %1 of a non-serializable type to JSON object';

    /// <summary>
    /// Initializes the JSON object parser over the provided JSON object.
    /// </summary>
    /// <param name="JObjectIn">JSON object over which to initialize this POS JSON Management codeunit instance</param>
    /// <param name="FrontEndIn">Instance of POS Front End Management codeunit to handle any required front-end 
    /// requests placed from this codeunit</param>
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
            FrontEnd.ReportBugAndThrowError(StrSubstNo(ParserNotInitializedErr, Key));
    end;

    /// <summary>
    /// Returns current JSON object content serialized as JSON string.
    /// </summary>
    /// <returns>Current object serialized as JSON string</returns>
    procedure ToString(): Text
    var
        Root: Text;
    begin
        MakeSureJObjectParserIsInitialized('');
        JRoot.WriteTo(Root);
        exit(Root);
    end;

    local procedure GetJToken(var JToken: JsonToken; Property: Text): Boolean
    var
        JTokenTemp: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Property);

        if not JObject.Get(Property, JTokenTemp) then
            exit(false);

        JToken := JTokenTemp;

        exit(true);
    end;

    /// <summary>
    /// Attempts to get a JSON token indicated by the Property parameter from the current JSON object. If the specified
    /// property does not exist, then it fails with the error message composed using the OperationDescription parameter.
    /// The error message will indicate the property not found, operation being performed
    /// object being operated on. and full contents of the JSON
    /// </summary>
    /// <param name="JToken">Output parameter that will contain the JSON object</param>
    /// <param name="Property">Property to retrieve from the JSON object</param>
    /// <param name="OperationDescription">Describes the operation that requires this token. If the operation fails, then 
    /// this text is printed in the middle of the error message, so it has to be all lowercase and not contain full or
    /// multiple sentences.</param>
    /// <returns>If the token was successfully found, return value contains that token. Otherwise, the error was thrown.</returns>
    procedure GetJTokenOrFail(Property: Text; OperationDescription: Text) JToken: JsonToken
    var
        JTokenTemp: JsonToken;
        TextTemp: Text;
    begin
        MakeSureJObjectParserIsInitialized(Property);

        if not GetJToken(JTokenTemp, Property) then begin
            JObject.WriteTo(TextTemp);
            FrontEnd.ReportBugAndThrowError(StrSubstNo(PropertyNotInObjectErr, Property, OperationDescription, TextTemp));
        end;

        JToken := JTokenTemp;
    end;

    local procedure GetJTokenPath(var JToken: JsonToken; Property: Text; OperationDescription: Text)
    var
        JTokenTemp: JsonToken;
        TextTemp: Text;
    begin
        MakeSureJObjectParserIsInitialized(Property);

        if not JObject.SelectToken(Property, JTokenTemp) then begin
            JObject.WriteTo(TextTemp);
            FrontEnd.ReportBugAndThrowError(StrSubstNo(PropertyNotInObjectErr, Property, OperationDescription, TextTemp));
        end else
            JToken := JTokenTemp;
    end;

    /// <summary>
    /// Attempts to sets object scope to the specified property name. If this property does not exist, 
    /// or the property is not an object, this method returns false.
    /// </summary>
    /// <param name="Name">Name of property to which to set scope</param>
    /// <returns>True if scope was successfully set; false otherwise</returns>
    procedure SetScope(Name: Text): Boolean
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);

        if Name in ['', '{}', '/'] then begin
            JObject := JRoot;
        end else begin
            if not GetJToken(JToken, Name) then
                exit(false);

            if not JToken.IsObject() then
                exit(false);

            JObject := JToken.AsObject();
        end;

        exit(true);
    end;

    /// <summary>
    /// Sets object scope to the specified property name. If this property does not exist, or
    /// the property is not an object, this method throws a runtime error indicating at what
    /// operation it occurred.
    /// </summary>
    /// <param name="Name">Name of property to which to set scope</param>
    /// <param name="OperationDescription">Describes operation that's attempting to set scope</param>
    procedure SetScope(Name: Text; OperationDescription: Text)
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);

        if Name in ['', '{}', '/'] then begin
            JObject := JRoot;
        end else begin
            JToken := GetJTokenOrFail(Name, OperationDescription);

            if not JToken.IsObject() then
                FrontEnd.ReportBugAndThrowError(StrSubstNo(AttemptingToAssignNonJsonToJsonErr, OperationDescription));

            JObject := JToken.AsObject();
        end;
    end;

    /// <summary>
    /// Sets scope of the current object to root. This method cannot fail.
    /// </summary>
    procedure SetScopeRoot()
    begin
        SetScope('/');
    end;

    /// <summary>
    /// Sets scope of current object to 'parameters'. If there are no parameters in current object,
    /// throws a runtime explaining in which action the problem occurred.
    /// </summary>
    /// <param name="ActionName">Described operation that is attempting to set scope to parameters</param>
    procedure SetScopeParameters(ActionName: Text)
    var
        OperationDescription: Text;
    begin
        OperationDescription := StrSubstNo(SettingScopeToParametersError, ActionName);
        SetScopeRoot();
        SetScope('parameters', OperationDescription);
    end;

    /// <summary>
    /// Attempts to sets scope of current object to 'parameters'. Returns boolean indicating success.
    /// </summary>
    /// <returns>True if setting scope to parameters succeeded; false otherwise</returns>
    procedure SetScopeParameters(): Boolean
    begin
        SetScopeRoot();
        exit(SetScope('parameters'));
    end;

    /// <summary>
    /// Sets scope of current object to the property indicated through a JPath description. Fails if the
    /// path specified does not exist.
    /// </summary>
    /// <param name="Name">Path to set current scope to</param>
    /// <param name="OperationDescription">Description of operation that's attempting to set scope to path</param>
    procedure SetScopePath(Name: Text; OperationDescription: Text)
    var
        JToken: JsonToken;
    begin
        MakeSureJObjectParserIsInitialized(Name);
        if CopyStr(Name, 1, 2) = '$.' then
            JObject := JRoot;
        GetJTokenPath(JToken, Name, OperationDescription);

        if not JToken.IsObject() then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(AttemptingToAssignNonJsonToJsonErr, OperationDescription));
        JObject := JToken.AsObject();
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
        ScopeID := CreateGuid();
        JObject.WriteTo(JObjectText);
        Scope.Add(ScopeID, JObjectText);
    end;

    procedure RestoreScope(ScopeID: Guid): Boolean
    var
        JObjectText: Text;
    begin
        if not Scope.ContainsKey(ScopeID) then
            exit(false);

        Scope.Get(ScopeID, JObjectText);
        JObject.ReadFrom(JObjectText);
        exit(true);
    end;

    /// <summary>
    /// Retrieves a JSON object property from the current object. If the property does not exist, or if the
    /// object being retrieved is not a JSON object, it returns an empty JSON object. If this is not the behavior
    /// you want, then you should use GetJsonObjectOrFail method instead.
    /// </summary>
    /// <param name="Property">Property to retrieve as JSON object</param>
    /// <returns>Value of the retrieved property as JSON object, or empty JSON object if not found.</returns>
    procedure GetJsonObject(Property: Text) JObjectOut: JsonObject
    var
        JToken: JsonToken;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        if not JToken.IsObject() then
            exit;

        JObjectOut := JToken.AsObject();
    end;

    /// <summary>
    /// Attempts to read a JSON object property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as JSON object</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as JSON object.</returns>
    procedure GetJsonObjectOrFail(Property: Text; var JObjectOut: JsonObject; OperationDescription: Text): Boolean
    var
        JToken: JsonToken;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);

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

    /// <summary>
    /// Retrieves a string property from the current object. If the property does not exist, it
    /// returns an empty string. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as string</param>
    /// <returns>Value of the retrieved property as string, or empty string if not found.</returns>
    procedure GetString(Property: Text) Result: Text
    var
        JToken: JsonToken;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        Result := JsonTokenToString(JToken);
    end;

    /// <summary>
    /// Attempts to read a string property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as string</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as string.</returns>
    procedure GetStringOrFail(Property: Text; OperationDescription: Text) Result: Text
    var
        JToken: JsonToken;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);
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

    /// <summary>
    /// Retrieves a boolean property from the current object. If the property does not exist, it
    /// returns false. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as boolean</param>
    /// <returns>Value of the retrieved property as boolean, or false if not found.</returns>
    procedure GetBoolean(Property: Text) Bool: Boolean
    var
        String: Text;
    begin
        String := GetString(Property);
        Bool := JsonStringToBool(String);
    end;

    /// <summary>
    /// Attempts to read a boolean property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as boolean</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as boolean.</returns>
    procedure GetBooleanOrFail(Property: Text; OperationDescription: Text) Bool: Boolean
    var
        String: Text;
    begin
        String := GetStringOrFail(Property, OperationDescription);
        Bool := JsonStringToBool(String);
    end;

    /// <summary>
    /// Retrieves a decimal property from the current object. If the property does not exist, it
    /// returns 0. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as decimal</param>
    /// <returns>Value of the retrieved property as decimal, or 0 if not found.</returns>
    procedure GetDecimal(Property: Text) Dec: Decimal
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Dec := JValue.AsDecimal();
    end;

    /// <summary>
    /// Attempts to read a decimal property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as decimal</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as decimal.</returns>
    procedure GetDecimalOrFail(Property: Text; OperationDescription: Text) Dec: Decimal
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Dec := JValue.AsDecimal();
    end;

    /// <summary>
    /// Retrieves an integer property from the current object. If the property does not exist, it
    /// returns 0. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as integer</param>
    /// <returns>Value of the retrieved property as integer, or 0 if not found.</returns>
    procedure GetInteger(Property: Text) Int: Integer
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Int := JValue.AsInteger();
    end;

    /// <summary>
    /// Attempts to read an integer property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as integer</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as integer.</returns>
    procedure GetIntegerOrFail(Property: Text; OperationDescription: Text) Int: Integer
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Int := JValue.AsInteger();
    end;

    /// <summary>
    /// Retrieves an big integer property from the current object. If the property does not exist, it
    /// returns 0. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as big integer</param>
    /// <returns>Value of the retrieved property as big integer, or 0 if not found.</returns>
    procedure GetBigInteger(Property: Text) Int: BigInteger
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Int := JValue.AsBigInteger();
    end;

    /// <summary>
    /// Attempts to read an big integer property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as big integer</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as big integer.</returns>
    procedure GetBigIntegerOrFail(Property: Text; OperationDescription: Text) Int: BigInteger
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Int := JValue.AsBigInteger();
    end;

    /// <summary>
    /// Retrieves a date property from the current object. If the property does not exist, it
    /// returns 0D. If the property being accessed is an object, this method returns
    /// the entire object serialized as JSON text.
    /// </summary>
    /// <param name="Property">Property to retrieve as date</param>
    /// <returns>Value of the retrieved property as date, or 0 if not found.</returns>
    procedure GetDate(Property: Text) Date: Date
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not GetJToken(JToken, Property) then
            exit;

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Date := DT2DATE(JValue.AsDateTime());
    end;

    /// <summary>
    /// Attempts to read a date property from the current object. If the property does not exist, it
    /// throws a runtime error indicating the operation during which it happened.
    /// </summary>
    /// <param name="Property">Property to retrieve as date</param>
    /// <param name="OperationDescription">Describes the operation that is being performed. In case of
    /// failure, this is shown in the error message.</param>
    /// <returns>Value of the retrieved property as date.</returns>
    procedure GetDateOrFail(Property: Text; OperationDescription: Text) Date: Date
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        JToken := GetJTokenOrFail(Property, OperationDescription);

        if not (JToken.IsValue) then
            exit;

        JValue := JToken.AsValue();
        Date := JValue.AsDate();
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

    /// <summary>
    /// Reads a string parameter from the current object. If the indicated parameter cannot be found, it
    /// returns an empty string.
    /// This method never causes runtime errors.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <returns>Value of the parameter or empty string</returns>
    procedure GetStringParameter(ParameterName: Text) Parameter: Text
    begin
        StoreContext();
        if not SetScopeParameters() then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetString(ParameterName);

        RestoreContext();
    end;

    /// <summary>
    /// Attempts to retrieve a string parameter from the current object. If it cannot be found, fails with a
    /// default error indicating that it failed during reading of parameters.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <param name="ActionName">Action for which the parameter is being retrieved</param>
    /// <returns>Value of retrieved parameter if it exists.</returns>
    procedure GetStringParameterOrFail(ParameterName: Text; ActionName: Text) Parameter: Text
    var
        OperationDescription: Text;
    begin
        OperationDescription := StrSubstNo(ReadingParametersErr, ActionName);
        StoreContext();
        SetScopeParameters(OperationDescription);
        Parameter := GetStringOrFail(ParameterName, OperationDescription);
        RestoreContext();
    end;

    /// <summary>
    /// Reads a boolean parameter from the current object. If the indicated parameter cannot be found, it
    /// returns false.
    /// This method never causes runtime errors.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <returns>Value of the parameter or false</returns>
    procedure GetBooleanParameter(ParameterName: Text) Parameter: Boolean
    begin
        StoreContext();
        if not SetScopeParameters() then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetBoolean(ParameterName);
        RestoreContext();
    end;

    /// <summary>
    /// Attempts to retrieve a boolean parameter from the current object. If it cannot be found, fails with a
    /// default error indicating that it failed during reading of parameters.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <param name="ActionName">Action for which the parameter is being retrieved</param>
    /// <returns>Value of retrieved parameter if it exists.</returns>
    procedure GetBooleanParameterOrFail(ParameterName: Text; ActionName: Text) Parameter: Boolean
    var
        OperationDescription: Text;
    begin
        OperationDescription := StrSubstNo(ReadingParametersErr, ActionName);
        StoreContext();
        SetScopeParameters(OperationDescription);
        Parameter := GetBooleanOrFail(ParameterName, OperationDescription);
        RestoreContext();
    end;

    /// <summary>
    /// Reads a decimal parameter from the current object. If the indicated parameter cannot be found, it
    /// returns 0.
    /// This method never causes runtime errors.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <returns>Value of the parameter or 0</returns>
    procedure GetDecimalParameter(ParameterName: Text) Parameter: Decimal
    begin
        StoreContext();
        if not SetScopeParameters() then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetDecimal(ParameterName);
        RestoreContext();
    end;

    /// <summary>
    /// Attempts to retrieve a decimal parameter from the current object. If it cannot be found, fails with a
    /// default error indicating that it failed during reading of parameters.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <param name="ActionName">Action for which the parameter is being retrieved</param>
    /// <returns>Value of retrieved parameter if it exists.</returns>
    procedure GetDecimalParameterOrFail(ParameterName: Text; ActionName: Text) Parameter: Decimal
    var
        OperationDescription: Text;
    begin
        OperationDescription := StrSubstNo(ReadingParametersErr, ActionName);
        StoreContext();
        SetScopeParameters(OperationDescription);
        Parameter := GetDecimalOrFail(ParameterName, OperationDescription);
        RestoreContext();
    end;

    /// <summary>
    /// Reads an integer parameter from the current object. If the indicated parameter cannot be found, it
    /// returns 0.
    /// This method never causes runtime errors.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <returns>Value of the parameter or 0</returns>
    procedure GetIntegerParameter(ParameterName: Text) Parameter: Integer
    begin
        StoreContext();
        if not SetScopeParameters() then begin
            RestoreContext();
            exit;
        end;

        Parameter := GetInteger(ParameterName);
        RestoreContext();
    end;

    /// <summary>
    /// Attempts to retrieve an integer parameter from the current object. If it cannot be found, fails with a
    /// default error indicating that it failed during reading of parameters.
    /// </summary>
    /// <param name="ParameterName">Parameter to retrieve</param>
    /// <param name="ActionName">Action for which the parameter is being retrieved</param>
    /// <returns>Value of retrieved parameter if it exists.</returns>
    procedure GetIntegerParameterOrFail(ParameterName: Text; ActionName: Text) Parameter: Integer
    var
        OperationDescription: Text;
    begin
        OperationDescription := StrSubstNo(ReadingParametersErr, ActionName);
        StoreContext();
        SetScopeParameters(OperationDescription);
        Parameter := GetIntegerOrFail(ParameterName, OperationDescription);
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
