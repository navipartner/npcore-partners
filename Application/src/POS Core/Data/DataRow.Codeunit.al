codeunit 6150895 "NPR Data Row" implements "NPR IJsonSerializable"
{
    var
        _constructed: Boolean;
        _json: JsonObject;
        _position: JsonToken;
        _fields: JsonObject;
        _negative: JsonToken;
        _class: JsonToken;
        _style: JsonToken;
        _deleted: JsonToken;

        LabelPosition: Label 'position', Locked = true;
        LabelNegative: Label 'negative', Locked = true;
        LabelClass: Label 'class', Locked = true;
        LabelStyle: Label 'style', Locked = true;
        LabelDeleted: Label 'deleted', Locked = true;
        LabelFields: Label 'fields', Locked = true;

        ErrorAccessViolation: Label 'Attempting to access an instance of "NPR Data Column" before calling its constructor.';

    local procedure MakeSureIsConstructed();
    begin
        if not _constructed then
            Error(ErrorAccessViolation);
    end;

    procedure Position(): Text;
    begin
        MakeSureIsConstructed();
        exit(_position.AsValue().AsText());
    end;

    procedure Position(FromJson: JsonObject): Text;
    var
        Token: JsonToken;
    begin
        // No need to MakeSureIsConstructed, this is a "static" method
        if (FromJson.Get(LabelPosition, Token)) then
            exit(Token.AsValue().AsText());
    end;

    procedure Negative(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_negative.AsValue().AsBoolean());
    end;

    procedure SetNegative(NewNegative: Boolean);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelNegative, NewNegative);
        _json.Get(LabelNegative, _negative);
    end;

    procedure Class(): Text;
    begin
        MakeSureIsConstructed();
        exit(_class.AsValue().AsText());
    end;

    procedure SetClass(NewClass: Text);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelClass, NewClass);
        _json.Get(LabelClass, _class);
    end;

    procedure Style(): Text;
    begin
        MakeSureIsConstructed();
        exit(_style.AsValue().AsText());
    end;

    procedure SetStyle(NewStyle: Text);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelStyle, NewStyle);
        _json.Get(LabelStyle, _style);
    end;

    procedure Deleted(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_deleted.AsValue().AsBoolean());
    end;

    procedure SetDeleted(NewDeleted: Boolean);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelDeleted, NewDeleted);
        _json.Get(LabelDeleted, _deleted);
    end;

    procedure Fields(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_fields);
    end;

    procedure Field(FieldName: Text) Result: JsonToken;
    begin
        MakeSureIsConstructed();
        _fields.Get(FieldName, Result);
    end;

    procedure ClearFields();
    begin
        MakeSureIsConstructed();
        Clear(_fields);
        _json.Replace(LabelFields, _fields);
    end;

    procedure Add(Property: Text; Value: Variant);
    var
        JsonMgt: Codeunit "NPR POS JSON Management";
    begin
        MakeSureIsConstructed();
        JsonMgt.AddVariantValueToJsonObject(_fields, Property, Value);
    end;

    procedure Add(Property: Text; Value: JsonToken);
    begin
        MakeSureIsConstructed();
        _fields.Add(Property, Value);
    end;

    procedure Equals(Obj: JsonObject): Boolean;
    var
        Row: Codeunit "NPR Data Row";
        FieldName: Text;
        TokenLeft: JsonToken;
        TokenRight: JsonToken;
        ValueLeft: Text;
        ValueRight: Text;
    begin
        MakeSureIsConstructed();
        Row.Constructor(Obj);

        if (Row.Position() <> Position()) then
            exit(false);

        if (Row.Fields().Keys.Count() <> _fields.Keys.Count) then
            exit(false);

        foreach FieldName in _fields.Keys do begin
            if not Row.Fields().Keys.Contains(FieldName) then
                exit(false);

            _fields.Get(FieldName, TokenLeft);
            Row.Fields().Get(FieldName, TokenRight);
            TokenLeft.WriteTo(ValueLeft);
            TokenRight.WriteTo(ValueRight);
            if ValueLeft <> ValueRight then
                exit(false);
        end;

        exit(true);
    end;

    procedure Constructor(Position: Text);
    begin
        Clear(_json);

        _json.Add(LabelPosition, Position);
        _json.Get(LabelPosition, _position);

        _json.Add(LabelNegative, false);
        _json.Get(LabelNegative, _negative);

        _json.Add(LabelClass, '');
        _json.Get(LabelClass, _class);

        _json.Add(LabelStyle, '');
        _json.Get(LabelStyle, _style);

        _json.Add(LabelDeleted, false);
        _json.Get(LabelDeleted, _deleted);

        _json.Add(LabelFields, _fields);

        _constructed := true;
    end;

    procedure Constructor(FromJson: JsonObject);
    var
        Token: JsonToken;
    begin
        _json := FromJson.Clone().AsObject();
        _json.Get(LabelPosition, _position);
        _json.Get(LabelNegative, _negative);
        _json.Get(LabelClass, _class);
        _json.Get(LabelStyle, _style);
        _json.Get(LabelDeleted, _deleted);
        _json.Get(LabelFields, Token);
        _fields := Token.AsObject();

        _constructed := true;
    end;

    procedure Clone() Json: JsonObject;
    begin
        MakeSureIsConstructed();
        Json := _json.Clone().AsObject();
    end;

    procedure GetJson(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_json);
    end;
}
