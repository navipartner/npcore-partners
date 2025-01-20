#if not BC17
/// <summary>
/// The Codeunit allow to build JSON objects using in a logical flow by sequentially adding JSON objects, properties, arrays.
/// It also provides possiblity to use Fluent interface approach.
/// </summary>
codeunit 6184982 "NPR Json Builder"
{
    EventSubscriberInstance = Manual;
    Access = Public;

    var
        currCodeunit: Variant;
        hascurrCodeunit: Boolean;
        RootJsonToken: JsonToken;
        CurrentJsonToken: JsonToken;
        TokenStack: List of [JsonToken];
        IsRootSet: Boolean;
        MissingPropertyNameErr: Label 'Property name is required when adding to an object.';
        VariableIsNotRecordTypeErr: Label 'Variant variable is not a Record.', Comment = 'Do not translate Variant and Record words as those are data types.';

    #region JSON Handling
    /// <summary>
    /// This function must be call before any other to initialize the JSON builder Codeunit.
    /// </summary>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure Initialize(): Codeunit "NPR Json Builder"
    begin
        InitcurrCodeunit();
        Clear(RootJsonToken);
        Clear(CurrentJsonToken);
        Clear(TokenStack);
        IsRootSet := false;
        exit(currCodeunit);
    end;

    /// <summary>
    /// Start and empty JSON object. Useful e.g. when adding objects to a JSON arrays or when creating the only top-level object.
    /// The object must be finalized by calling EndObject() once all internal tokens were added.
    /// </summary>
    /// <example>StartObject().EndObject(); => { } </example>
    /// <example>StartObject().AddProperty('street', 'Elm Street').EndObject(); => { "street": "Elm Street" } </example>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure StartObject(): Codeunit "NPR Json Builder"
    begin
        exit(StartObject(''));
    end;

    /// <summary>
    /// Start and empty JSON object as a value of the property defined by PropertyName parameter. 
    /// This object must be wrapped up by another JSON object (it can't be the top-level object or an object directly added to an array).
    /// The object must be finalized by calling EndObject() once all internal tokens were added.
    /// </summary>
    /// <param name="PropertyName">Name of the key/property the JSON object will belong.</param>
    /// <example>StartObject('address').EndObject(); => "address": { } </example>
    /// <example>StartObject('address').AddProperty('street', 'Elm Street').EndObject(); => "address": { "street": "Elm Street" } </example>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure StartObject(PropertyName: Text): Codeunit "NPR Json Builder"
    var
        NewObject: JsonObject;
    begin
        InitcurrCodeunit();
        if not IsRootSet then begin
            RootJsonToken := NewObject.AsToken();
            CurrentJsonToken := RootJsonToken;
            IsRootSet := true;
        end else begin
            AddTokenToParent(PropertyName, NewObject.AsToken());
        end;
        TokenStack.Add(CurrentJsonToken);
        CurrentJsonToken := NewObject.AsToken();
        exit(currCodeunit);
    end;

    /// <summary>
    /// Close previously created JSON object and update the processing stack.
    /// </summary>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure EndObject(): Codeunit "NPR Json Builder"
    begin
        InitcurrCodeunit();
        if TokenStack.Count > 0 then begin
            CurrentJsonToken := TokenStack.Get(TokenStack.Count);
            TokenStack.RemoveAt(TokenStack.Count);
        end;
        exit(currCodeunit);
    end;

    /// <summary>
    /// Allows JSON Array to be generated in a dedicated function returning back the builder.
    /// The function works just as a bypass able to return the same instance of the Codeunit.
    /// </summary>
    /// <param name="JsonBuilder">Json Builder Codeunit</param>
    /// <example>builder.AddArray(GenerateSalesOrders(builder)).Build()</example>
    /// <returns>Json Builder Codeunit</returns>
    procedure AddArray(JsonBuilder: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    begin
        exit(JsonBuilder);
    end;

    /// <summary>
    /// Allows JSON Object to be generated in a dedicated function returning back the builder.
    /// The function works just as a bypass able to return the same instance of the Codeunit.
    /// </summary>
    /// <param name="JsonBuilder">Json Builder Codeunit</param>
    /// <example>builder.AddObject(GenerateSalesOrderStrucuture(builder)).Build()</example>
    /// <returns>Json Builder Codeunit</returns>
    procedure AddObject(JsonBuilder: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    begin
        exit(JsonBuilder);
    end;

    /// <summary>
    /// Create an empty JSON array. 
    /// </summary>
    /// <example>StartArray().EndArray(); => [ ] </example>
    /// <example>StartArray().AddValue('Elm Street, USA').AddValue('Downing Street, UK').EndArray(); => [ "Elm Street, USA", "Downing Street, UK" ] </example>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure StartArray(): Codeunit "NPR Json Builder"
    begin
        exit(StartArray(''))
    end;

    /// <summary>
    /// Create an empty JSON array. 
    /// JSON arrays can't be placed to the top-level of the JSON object, they must be included within another JSON object.
    /// </summary>
    /// <param name="PropertyName">Name of the key/property the JSON array will belong.</param>
    /// <example>StartArray('addresses').EndArray(); => "addresses": [ ] </example>
    /// <example>StartArray('addresses').AddValue('Elm Street, USA').AddValue('Downing Street, UK').EndArray(); => "addresses": [ "Elm Street, USA", "Downing Street, UK" ] </example>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure StartArray(PropertyName: Text): Codeunit "NPR Json Builder"
    var
        NewArray: JsonArray;
    begin
        InitcurrCodeunit();
        if not IsRootSet then begin
            RootJsonToken := NewArray.AsToken();
            CurrentJsonToken := RootJsonToken;
            IsRootSet := true;
        end else begin
            AddTokenToParent(PropertyName, NewArray.AsToken());
        end;
        TokenStack.Add(CurrentJsonToken);
        CurrentJsonToken := NewArray.AsToken();
        exit(currCodeunit);
    end;

    /// <summary>
    /// Close previously created JSON array and update the processing stack.
    /// </summary>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure EndArray(): Codeunit "NPR Json Builder"
    begin
        InitcurrCodeunit();
        if TokenStack.Count > 0 then begin
            CurrentJsonToken := TokenStack.Get(TokenStack.Count);
            TokenStack.RemoveAt(TokenStack.Count);
        end;
        exit(currCodeunit);
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Boolean): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Integer): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Decimal): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Text): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Date): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: Time): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    procedure AddProperty(PropertyName: Text; PropertyValue: DateTime): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    /// <summary>
    /// Add a property with a JSON value.
    /// </summary>
    /// <param name="PropertyName">Name of the key/property the JSON array will belong.</param>
    /// <param name="PropertyValue">JSON value to be assigned to the property.</param>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure AddProperty(PropertyName: Text; PropertyValue: JsonValue): Codeunit "NPR Json Builder"
    begin
        exit(AddPropertyInternal(PropertyName, PropertyValue));
    end;

    /// <summary>
    /// Add a property with a null value.
    /// </summary>
    /// <param name="PropertyName">Name of the key/property the JSON array will belong.</param>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure AddProperty(PropertyName: Text): Codeunit "NPR Json Builder"
    var
        JsonValue: JsonValue;
    begin
        JsonValue.SetValueToNull();
        exit(AddPropertyInternal(PropertyName, JsonValue));
    end;

    local procedure AddPropertyInternal(PropertyName: Text; PropertyValue: Variant): Codeunit "NPR Json Builder"
    var
        JValue: JsonValue;
        NewObject: JsonObject;
    begin
        InitcurrCodeunit();
        if not IsRootSet then begin
            RootJsonToken := NewObject.AsToken();
            CurrentJsonToken := RootJsonToken;
            IsRootSet := true;
            TokenStack.Add(CurrentJsonToken);
        end;
        JValue := CreateJsonValue(PropertyValue);
        AddTokenToParent(PropertyName, JValue.AsToken());
        exit(currCodeunit);
    end;

    procedure AddValue(Value: Boolean): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: Integer): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: Decimal): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: Text): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: Date): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: Time): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    procedure AddValue(Value: DateTime): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    /// <summary>
    /// Add a value with a JSON value.
    /// </summary>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure AddValue(Value: JsonValue): Codeunit "NPR Json Builder"
    begin
        exit(AddValueInternal(Value));
    end;

    /// <summary>
    /// Add a value with a null value.
    /// </summary>
    /// <returns>Json Builder Codeunit itself.</returns>
    procedure AddValue(): Codeunit "NPR Json Builder"
    var
        JsonValue: JsonValue;
    begin
        JsonValue.SetValueToNull();
        exit(AddValueInternal(JsonValue));
    end;

    local procedure AddValueInternal(Value: Variant): Codeunit "NPR Json Builder"
    var
        JValue: JsonValue;
    begin
        InitcurrCodeunit();
        JValue := CreateJsonValue(Value);
        AddTokenToParent('', JValue.AsToken());
        exit(currCodeunit);
    end;

    /// <summary>
    /// Generate output as a JsonObject.
    /// </summary>
    /// <returns>JsonObject</returns>
    procedure Build(): JsonObject
    var
        JsonObj: JsonObject;
    begin
        if not IsRootSet then
            StartObject('');

        JsonObj := RootJsonToken.AsObject();
        exit(JsonObj);
    end;

    /// <summary>
    /// Generate output as a JsonArray.
    /// </summary>
    /// <returns>JsonArray</returns>
    procedure BuildAsArray(): JsonArray
    begin
        if not IsRootSet then
            StartObject('');

        exit(RootJsonToken.AsArray());
    end;

    /// <summary>
    /// Generate output as a JsonToken.
    /// </summary>
    /// <returns>JsonToken</returns>
    procedure BuildAsJsonToken(): JsonToken
    begin
        if not IsRootSet then
            StartObject('');

        exit(RootJsonToken);
    end;

    local procedure AddTokenToParent(PropertyName: Text; NewToken: JsonToken)
    var
        ParentObject: JsonObject;
        ParentArray: JsonArray;
    begin
        case true of
            CurrentJsonToken.IsObject():
                begin
                    ParentObject := CurrentJsonToken.AsObject();
                    if PropertyName <> '' then
                        ParentObject.Add(PropertyName, NewToken)
                    else
                        Error(MissingPropertyNameErr);
                end;
            CurrentJsonToken.IsArray():
                begin
                    ParentArray := CurrentJsonToken.AsArray();
                    ParentArray.Add(NewToken);
                end;
        end;
    end;

    local procedure CreateJsonValue(Value: Variant): JsonValue
    var
        JValue: JsonValue;
        BooleanValue: Boolean;
        IntegerValue: Integer;
        DecimalValue: Decimal;
        TextValue: Text;
        DateValue: Date;
        TimeValue: Time;
        DateTimeValue: DateTime;
    begin
        case true of
            Value.IsBoolean:
                begin
                    BooleanValue := Value;
                    JValue.SetValue(BooleanValue);
                end;
            Value.IsInteger:
                begin
                    IntegerValue := Value;
                    JValue.SetValue(IntegerValue);
                end;
            Value.IsDecimal:
                begin
                    DecimalValue := Value;
                    JValue.SetValue(DecimalValue);
                end;
            Value.IsDate:
                begin
                    DateValue := Value;
                    JValue.SetValue(Format(DateValue, 0, 9));
                end;
            Value.IsTime:
                begin
                    TimeValue := Value;
                    JValue.SetValue(Format(TimeValue, 0, 9));
                end;
            Value.IsDateTime:
                begin
                    DateTimeValue := Value;
                    JValue.SetValue(Format(DateTimeValue, 0, 9));
                end;
            Value.IsCode, Value.IsText:
                begin
                    TextValue := Value;
                    JValue.SetValue(TextValue);
                end;
            Value.IsJsonValue:
                begin
                    JValue := Value;
                end;
            else begin
                TextValue := Format(Value);
                JValue.SetValue(TextValue);
            end;
        end;
        exit(JValue);
    end;
    # endregion

    #region Record handling
    procedure InitRecord(var Record: Variant; InitPrimaryKey: Boolean): Codeunit "NPR Json Builder"
    var
        recRef: RecordRef;
    begin
        InitcurrCodeunit();

        if (not Record.IsRecord) then begin
            Error(VariableIsNotRecordTypeErr);
        end;

        recRef.GetTable(Record);
        if (InitPrimaryKey) then begin
            Clear(Record);
        end else begin
            recRef.Init();
            Record := recRef;
        end;
        Record := recRef;

        exit(currCodeunit);
    end;

    #endregion

    #region Fluent Interface
    local procedure InitcurrCodeunit()
    var
        helper: Codeunit "NPR Json Builder";
        helperOutVar: Variant;
    begin
        if (hascurrCodeunit) then
            exit;

        BindSubscription(helper);
        InvokeCurrent(helperOutVar);
        UnbindSubscription(helper);
        currCodeunit := helperOutVar;
        hascurrCodeunit := true;
    end;

    [InternalEvent(true)]
    local procedure InvokeCurrent(var returnCodeunit: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Json Builder", 'InvokeCurrent', '', false, false)]
    local procedure OnInvokeCurrent(sender: Codeunit "NPR Json Builder"; var returnCodeunit: Variant)
    begin
        returnCodeunit := sender;
    end;
    #endregion
}
#endif