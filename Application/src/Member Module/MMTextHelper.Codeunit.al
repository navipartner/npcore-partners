codeunit 6151388 "NPR MM Text Helper"
{
    Access = Internal;
#pragma warning disable AA0139
    internal procedure AsText10(KeyName: Text; JObject: JsonObject) TextValue: Text[10]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;

    internal procedure AsText20(KeyName: Text; JObject: JsonObject) TextValue: Text[20]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;

    internal procedure AsText30(KeyName: Text; JObject: JsonObject) TextValue: Text[30]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;

    internal procedure AsText50(KeyName: Text; JObject: JsonObject) TextValue: Text[50]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;

    internal procedure AsText80(KeyName: Text; JObject: JsonObject) TextValue: Text[80]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;

    internal procedure AsText100(KeyName: Text; JObject: JsonObject) TextValue: Text[100]
    begin
        exit(AsText(KeyName, JObject, MaxStrLen(TextValue)));
    end;
#pragma warning restore AA0139
    internal procedure AsText(KeyName: Text; JObject: JsonObject; Length: Integer): Text
    var
        JToken: JsonToken;
    begin
        if (not (JObject.Get(KeyName, JToken))) then
            exit('');
        exit(CopyStr(JToken.AsValue().AsText(), 1, Length));
    end;
}