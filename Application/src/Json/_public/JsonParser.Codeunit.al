#if not BC17
codeunit 6150648 "NPR Json Parser"
{
    EventSubscriberInstance = Manual;

    var
        JsonToken: JsonToken;
        CurrentObject: JsonObject;
        CurrentArray: JsonArray;
        TokenStack: List of [JsonToken];
        HasCurrCodeunit: Boolean;
        CurrCodeunit: Variant;
        ObjectPropertyNotFoundErr: Label 'Property %1 not found or is not an object', Comment = '%1 is a property name';
        ArrayPropertyNotFoundErr: Label 'Property %1 not found or is not an array', Comment = '%1 is a property name';
        CanNotExistObjectErr: Label 'Cannot exit object: No object to exit from';
        CanNotExistArrayErr: Label 'Cannot exit array: No array to exit from';

    procedure Parse(JsonText: Text): Codeunit "NPR JSON Parser"
    var
        JsonObj: JsonObject;
    begin
        InitcurrCodeunit();
        JsonObj.ReadFrom(JsonText);
        JsonToken := JsonObj.AsToken();
        CurrentObject := JsonToken.AsObject();
        exit(CurrCodeunit);
    end;

    procedure Load(JsonObj: JsonObject): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        JsonToken := JsonObj.AsToken();
        CurrentObject := JsonToken.AsObject();
        exit(CurrCodeunit);
    end;

    procedure EnterObject(PropertyName: Text): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        if not TryEnterObject(PropertyName) then
            Error(ObjectPropertyNotFoundErr, PropertyName);
        exit(CurrCodeunit);
    end;

    procedure TryEnterObject(PropertyName: Text): Boolean
    var
        ChildToken: JsonToken;
    begin
        if not CurrentObject.Get(PropertyName, ChildToken) then
            exit(false);
        if not ChildToken.IsObject then
            exit(false);

        TokenStack.Add(JsonToken);
        JsonToken := ChildToken;
        CurrentObject := JsonToken.AsObject();
        exit(true);
    end;

    procedure ExitObject(): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        if TokenStack.Count = 0 then
            Error(CanNotExistObjectErr);

        JsonToken := TokenStack.Get(TokenStack.Count);
        TokenStack.RemoveAt(TokenStack.Count);
        if JsonToken.IsObject then
            CurrentObject := JsonToken.AsObject()
        else if JsonToken.IsArray then
            CurrentArray := JsonToken.AsArray();
        exit(CurrCodeunit);
    end;

    procedure EnterArray(PropertyName: Text): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        if not TryEnterArray(PropertyName) then
            Error(ArrayPropertyNotFoundErr, PropertyName);
        exit(CurrCodeunit);
    end;

    procedure TryEnterArray(PropertyName: Text): Boolean
    var
        ChildToken: JsonToken;
    begin
        if not CurrentObject.Get(PropertyName, ChildToken) then
            exit(false);
        if not ChildToken.IsArray then
            exit(false);

        TokenStack.Add(JsonToken);
        JsonToken := ChildToken;
        CurrentArray := JsonToken.AsArray();
        exit(true);
    end;

    procedure ExitArray(): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        if TokenStack.Count = 0 then
            Error(CanNotExistArrayErr);

        JsonToken := TokenStack.Get(TokenStack.Count);
        TokenStack.RemoveAt(TokenStack.Count);
        if JsonToken.IsObject then
            CurrentObject := JsonToken.AsObject()
        else if JsonToken.IsArray then
            CurrentArray := JsonToken.AsArray();
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: List of [Text]; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: List of [Text]): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: List of [Text]): Boolean
    var
        valueJsonToken: JsonToken;
        ArrayElement: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if valueJsonToken.IsArray then begin
            foreach ArrayElement in valueJsonToken.AsArray() do
                Value.Add(ArrayElement.AsValue().AsText());
            exit(true);
        end;

        exit(false);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Dictionary of [Text, Text]; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Dictionary of [Text, Text]): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Dictionary of [Text, Text]): Boolean
    var
        valueJsonToken: JsonToken;
        propertyJsonToken: JsonToken;
        jsonObject: JsonObject;
        propertyNames: List of [Text];
        subPropertyName: Text;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsObject then
            exit(false);

        jsonObject := valueJsonToken.AsObject();
        propertyNames := jsonObject.Keys;
        foreach subPropertyName in propertyNames do begin
            if jsonObject.Get(subPropertyName, propertyJsonToken) and propertyJsonToken.IsValue then begin
                Value.Add(subPropertyName, propertyJsonToken.AsValue().AsText());
            end;
        end;

        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Text; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Text): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Text): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        case true of
            valueJsonToken.IsValue:
                Value := valueJsonToken.AsValue().AsText();
            valueJsonToken.IsObject:
                valueJsonToken.AsObject().WriteTo(Value);
            valueJsonToken.IsArray:
                valueJsonToken.WriteTo(Value);
            else
                exit(false);
        end;
        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Integer; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Integer): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Integer): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        Value := valueJsonToken.AsValue().AsInteger();
        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: BigInteger; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: BigInteger): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: BigInteger): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        Value := valueJsonToken.AsValue().AsInteger();
        exit(true);
    end;

    procedure GetValues(var ValueList: List of [JsonValue]): Codeunit "NPR JSON Parser"
    var
        ArrayElement: JsonToken;
    begin
        InitcurrCodeunit();
        Clear(ValueList);
        foreach ArrayElement in CurrentArray do
            ValueList.Add(ArrayElement.AsValue());
        exit(CurrCodeunit);
    end;

    procedure GetValues(var ObjectList: List of [JsonObject]): Codeunit "NPR JSON Parser"
    var
        ArrayElement: JsonToken;
    begin
        InitcurrCodeunit();
        Clear(ObjectList);
        foreach ArrayElement in CurrentArray do
            ObjectList.Add(ArrayElement.AsObject());
        exit(CurrCodeunit);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Boolean): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure GetProperty(PropertyName: Text; var Value: Boolean; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Boolean): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        Value := valueJsonToken.AsValue().AsBoolean();
        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Decimal): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure GetProperty(PropertyName: Text; var Value: Decimal; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Decimal): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        Value := valueJsonToken.AsValue().AsDecimal();
        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Guid): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure GetProperty(PropertyName: Text; var Value: Guid; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Guid): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        exit(Evaluate(Value, valueJsonToken.AsValue().AsText()));
    end;

    procedure GetProperty(PropertyName: Text; var Value: DateTime): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure GetProperty(PropertyName: Text; var Value: DateTime; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: DateTime): Boolean
    var
        valueJsonToken: JsonToken;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        Value := valueJsonToken.AsValue().AsDateTime();
        exit(true);
    end;

    procedure GetProperty(PropertyName: Text; var Value: Date): Codeunit "NPR JSON Parser"
    var
        hasProperty: Boolean;
    begin
        exit(GetProperty(PropertyName, Value, hasProperty));
    end;

    procedure GetProperty(PropertyName: Text; var Value: Date; var HasProperty: Boolean): Codeunit "NPR JSON Parser"
    begin
        InitcurrCodeunit();
        HasProperty := TryGetProperty(PropertyName, Value);
        exit(CurrCodeunit);
    end;

    procedure TryGetProperty(PropertyName: Text; var Value: Date): Boolean
    var
        valueJsonToken: JsonToken;
        textValue: Text;
    begin
        Clear(Value);
        if not CurrentObject.Get(PropertyName, valueJsonToken) then
            exit(false);

        if not valueJsonToken.IsValue then
            exit(false);

        textValue := valueJsonToken.AsValue().AsText();
        // JSON dates are ISO-8601: parse with format 9 (XML), locale-independent. Default Evaluate is region-dependent.
        if Evaluate(Value, textValue, 9) then
            exit(true);

        // Fallback: a JSON datetime ("2026-01-01T00:00:00.000Z"). Take the calendar date as written - going
        // through DT2Date would shift it by the session's UTC offset. Format 9 (XML) keeps Evaluate locale-independent.
        if textValue.Contains('T') then
            exit(Evaluate(Value, CopyStr(textValue, 1, StrPos(textValue, 'T') - 1), 9));

        exit(false);
    end;

    #region Fluent Interface
    local procedure InitcurrCodeunit()
    var
        helper: Codeunit "NPR JSON Parser";
        helperOutVar: Variant;
    begin
        if (HasCurrCodeunit) then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR JSON Parser", 'InvokeCurrent', '', false, false)]
    local procedure OnInvokeCurrent(sender: Codeunit "NPR JSON Parser"; var returnCodeunit: Variant)
    begin
        returnCodeunit := sender;
    end;
    #endregion
}
#endif