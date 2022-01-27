codeunit 6150892 "NPR Data Source" implements "NPR IJsonSerializable"
{
    var
        _json: JsonObject;
        _id: JsonToken;
        _tableNo: JsonToken;
        _columns: JsonArray;
        _totals: JsonArray;
        _content: JsonObject;
        _extensions: JsonArray;

        _constructed: Boolean;
        _perSession: Boolean;
        _retrievedInCurrentSession: Boolean;

        LabelId: Label 'id', Locked = true;
        LabelTableNo: Label 'tableNo', Locked = true;
        LabelColumns: Label 'columns', Locked = true;
        LabelTotals: Label 'totals', Locked = true;
        LabelContent: Label 'Content', Locked = true;
        LabelExtensions: Label '_extensions', Locked = true;
        LabelPerSession: Label '_perSession', Locked = true;

        ErrorAccessViolation: Label 'Attempting to access an instance of "NPR Data Source" before calling its constructor.';

    local procedure MakeSureIsConstructed();
    begin
        if not _constructed then
            Error(ErrorAccessViolation);
    end;

    procedure IsNull(): Boolean;
    begin
        exit(not _constructed);
    end;

    procedure Constructor()
    begin
        ClearAll();

        _json.Add(LabelId, '');
        _json.Get(LabelId, _id);

        _json.Add(LabelTableNo, 0);
        _json.Get(LabelTableNo, _tableNo);

        _json.Add(LabelColumns, _columns);
        _json.Add(LabelTotals, _totals);
        _json.Add(LabelContent, _content);

        _constructed := true;
    end;

    procedure Constructor(DataSource: JsonObject);
    var
        Token: JsonToken;
    begin
        _constructed := true;
        _json := DataSource.Clone().AsObject();

        _json.Get(LabelId, _id);
        _json.Get(LabelTableNo, _tableNo);
        _json.Get(LabelColumns, Token);
        _columns := Token.AsArray();
        _json.Get(LabelTotals, Token);
        _totals := Token.AsArray();
        _json.Get(LabelContent, Token);
        _content := Token.AsObject();

        if (_json.Get(LabelPerSession, Token)) then
            _perSession := Token.AsValue().AsBoolean()
        else
            Clear(_perSession);

        if (_content.Get(LabelExtensions, Token)) then
            _extensions := Token.AsArray()
        else
            Clear(_extensions);
    end;

    procedure PerSession(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_perSession);
    end;

    procedure SetPerSession(NewPerSession: Boolean);
    begin
        MakeSureIsConstructed();
        _perSession := NewPerSession;
    end;

    procedure RetrievedInCurrentSession(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_retrievedInCurrentSession);
    end;

    procedure SetRetrievedInCurrentSession(NewRetrievedInCurrentSession: Boolean);
    begin
        MakeSureIsConstructed();
        _retrievedInCurrentSession := NewRetrievedInCurrentSession;
    end;

    procedure Id(): Text;
    begin
        MakeSureIsConstructed();
        exit(_id.AsValue().AsText());
    end;

    procedure SetId(NewId: Text);
    begin
        MakeSureIsConstructed();

        _json.Replace(LabelId, NewId);
        _json.Get(LabelId, _id);
    end;

    procedure TableNo(): Integer;
    begin
        MakeSureIsConstructed();
        exit(_tableNo.Asvalue().AsInteger());
    end;

    procedure SetTableNo(NewTableNo: Integer);
    begin
        MakeSureIsConstructed();

        _json.Replace(LabelTableNo, NewTableNo);
        _json.Get(LabelTableNo, _tableNo);
    end;

    procedure Columns(): JsonArray;
    begin
        MakeSureIsConstructed();
        exit(_columns);
    end;

    procedure Totals(): JsonArray;
    begin
        MakeSureIsConstructed();
        exit(_totals);
    end;

    local procedure GetMaxOrdinal() MaxOrdinal: Integer;
    var
        Column: Codeunit "NPR Data Column";
        Token: JsonToken;
        Ordinal: Integer;
    begin
        if _columns.Count() = 0 then
            exit;

        foreach Token in _columns do begin
            Ordinal := Column.Ordinal(Token.AsObject());
            if Ordinal > MaxOrdinal then
                MaxOrdinal := Ordinal;
        end;
    end;

    procedure AddColumn(FieldNo: Text; Caption: Text; DataType: Enum "NPR Data Type"; Visible: Boolean; var ColumnOut: Codeunit "NPR Data Column");
    begin
        MakeSureIsConstructed();
        ColumnOut.Constructor(FieldNo, Caption, DataType, GetMaxOrdinal() + 1, Visible);
        _columns.Add(ColumnOut.GetJson());
    end;

    procedure AddColumn(FieldNo: Text; Caption: Text; DataType: Enum "NPR Data Type"; Visible: Boolean);
    var
        ColumnOutIgnore: Codeunit "NPR Data Column";
    begin
        AddColumn(FieldNo, Caption, DataType, Visible, ColumnOutIgnore);
    end;

    procedure Content(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_content);
    end;

    procedure GetExtensions(var ExtensionsOut: List of [Text]);
    var
        Token: JsonToken;
    begin
        MakeSureIsConstructed();

        Clear(ExtensionsOut);
        foreach Token in _extensions do
            ExtensionsOut.Add(Token.AsValue().AsText());
    end;

    procedure HasExtensions(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_content.Contains(LabelExtensions));
    end;

    procedure AddExtensions(Extensions: List of [Text]);
    var
        Extension: Text;
    begin
        MakeSureIsConstructed();

        if not _content.Contains(LabelExtensions) then
            _content.Add(LabelExtensions, _extensions);

        foreach Extension in Extensions do
            _extensions.Add(Extension);
    end;

    procedure GetJson(): JsonObject;
    var
        JsonCopy: JsonObject;
    begin
        JsonCopy := _json.Clone().AsObject();
        JsonCopy.Add(LabelPerSession, _perSession);

        MakeSureIsConstructed();
        exit(_json);
    end;
}
