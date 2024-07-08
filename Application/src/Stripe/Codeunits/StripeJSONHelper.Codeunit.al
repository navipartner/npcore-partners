codeunit 6059808 "NPR Stripe JSON Helper"
{
    Access = Internal;

    var
        MainJsonObject: JsonObject;
        JsonTokenNotFoundErr: Label 'Could not find JsonToken %1', Comment = '%1 - Json key';
        JsonTokenIsNotValueErr: Label 'The Json object is malformed. Could not find Json value %1', Comment = '%1 - Json key';

    internal procedure GetJsonObjecFromJsonArray(JsonArray: JsonArray; ObjectNo: Integer): JsonObject;
    var
        JsonToken: JsonToken;
    begin
        JsonArray.Get(ObjectNo, JsonToken);
        exit(JsonToken.AsObject());
    end;

    internal procedure GetJsonObjectID(JsonObject: JsonObject): Integer;
    begin
        exit(GetPropertyName(JsonObject, 'id').AsValue().AsInteger());
    end;

    internal procedure GetJsonPropertyValueAsObject(JsonObject: JsonObject; PropertyName: Text): JsonObject;
    begin
        exit(GetPropertyName(JsonObject, PropertyName).AsObject());
    end;

    internal procedure GetJsonPropertyValueAsArray(JsonObject: JsonObject; PropertyName: Text): JsonArray;
    begin
        exit(GetPropertyName(JsonObject, PropertyName).AsArray());
    end;

    internal procedure GetJsonPropertyValueAsText(JsonObject: JsonObject; PropertyName: Text): Text;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(JsonVal.AsText())
        else
            exit('');
    end;

    internal procedure GetJsonPropertyValueAsInteger(JsonObject: JsonObject; PropertyName: Text): Integer;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(JsonVal.AsInteger())
        else
            exit(0);
    end;

    internal procedure GetJsonPropertyValueAsListOfInteger(JsonObject: JsonObject; PropertyName: Text; var IntList: List of [Integer]);
    var
        i: Integer;
        JsonArr: JsonArray;
        JsonTkn: JsonToken;
    begin
        Clear(IntList);
        JsonArr := GetJsonPropertyValueAsArray(JsonObject, PropertyName);
        for i := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(i, JsonTkn);
            IntList.Add(JsonTkn.AsValue().AsInteger());
        end;
    end;

    internal procedure GetJsonObjPropertiesAsDictionary(JsonObject: JsonObject; JsonObjName: Text; var JsonProperties: Dictionary of [Text, Decimal]);
    var
        PropertyValueAsDecimal: Decimal;
        JsonObj: JsonObject;
        JsonObjKey: Text;
    begin
        Clear(JsonProperties);
        JsonObj := GetJsonPropertyValueAsObject(JsonObject, JsonObjName);
        foreach JsonObjKey in JsonObj.Keys() do begin
            PropertyValueAsDecimal := GetJsonPropertyValueAsDecimal(JsonObj, JsonObjKey);
            JsonProperties.Add(JsonObjKey, PropertyValueAsDecimal);
        end;
    end;

    internal procedure GetJsonPropertyValueAsListOfText(JsonObject: JsonObject; PropertyName: Text; var TextList: List of [Text]);
    var
        i: Integer;
        JsonArr: JsonArray;
        JsonTkn: JsonToken;
    begin
        Clear(TextList);
        JsonArr := GetJsonPropertyValueAsArray(JsonObject, PropertyName);
        for i := 0 to JsonArr.Count() - 1 do begin
            JsonArr.Get(i, JsonTkn);
            TextList.Add(JsonTkn.AsValue().AsText());
        end;
    end;

    internal procedure GetJsonPropertyValueAsDecimal(JsonObject: JsonObject; PropertyName: Text): Decimal;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(JsonVal.AsDecimal())
        else
            exit(0);
    end;

    internal procedure GetJsonPropertyValueAsDateTime(JsonObject: JsonObject; PropertyName: Text): DateTime;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(JsonVal.AsDateTime())
        else
            exit(0DT);
    end;

    internal procedure GetJsonPropertyValueAsDate(JsonObject: JsonObject; PropertyName: Text): Date;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(DT2Date(JsonVal.AsDateTime()))
        else
            exit(0D);
    end;

    internal procedure GetJsonPropertyValueAsBoolean(JsonObject: JsonObject; PropertyName: Text): Boolean;
    var
        JsonVal: JsonValue;
    begin
        JsonVal := GetJsonValue(JsonObject, PropertyName);
        if HasValue(JsonVal) then
            exit(JsonVal.AsBoolean())
        else
            exit(false);
    end;


    local procedure GetPropertyName(var JsonObject: JsonObject; PropertyName: Text) JsonToken: JsonToken;
    var
        TokenDoesNotExistErr: Label 'Could not find a token with key %1', Comment = '%1 - Json key';
    begin
        if not JsonObject.Get(PropertyName, JsonToken) then
            Error(TokenDoesNotExistErr, PropertyName);
    end;

    local procedure GetJsonValue(var JsonObject: JsonObject; PropertyName: Text): JsonValue
    begin
        exit(GetPropertyName(JsonObject, PropertyName).AsValue());
    end;

    internal procedure GetJsonValue(Property: Text): JsonValue
    var
        JToken: JsonToken;
    begin
        if not MainJsonObject.Get(Property, JToken) then
            Error(JsonTokenNotFoundErr, Property);

        if not JToken.IsValue() then
            Error(JsonTokenIsNotValueErr, Property);

        exit(JToken.AsValue());
    end;

    internal procedure HasValues(JsonObj: JsonObject): Boolean
    var
        JsonTkn: JsonToken;
    begin
        foreach JsonTkn in JsonObj.Values() do
            if HasValue(JsonTkn.AsValue()) then
                exit(true);

        exit(false);
    end;

    local procedure HasValue(JsonVal: JsonValue): Boolean
    begin
        if JsonVal.IsNull() or JsonVal.IsUndefined() then
            exit(false);

        exit(JsonVal.AsText() <> '');
    end;

    internal procedure SelectJsonValue(Path: Text): JsonValue
    var
        JToken: JsonToken;
    begin
        if not MainJsonObject.SelectToken(Path, JToken) then
            Error(JsonTokenNotFoundErr, Path);

        if not JToken.IsValue() then
            Error(JsonTokenIsNotValueErr, Path);

        exit(JToken.AsValue());
    end;

    internal procedure IsNullValue(Property: Text) Result: Boolean
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        if not MainJsonObject.Get(Property, JToken) then
            exit;

        JValue := JToken.AsValue();
        Result := JValue.IsNull() or JValue.IsUndefined();
    end;

    internal procedure ReadFromText(Data: Text)
    begin
        Clear(MainJsonObject);
        MainJsonObject.ReadFrom(Data);
    end;

    internal procedure SetJsonObject(var NewJsonObject: JsonObject)
    begin
        MainJsonObject := NewJsonObject;
    end;
}