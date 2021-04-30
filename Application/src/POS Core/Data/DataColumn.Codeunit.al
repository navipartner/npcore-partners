codeunit 6150894 "NPR Data Column" implements "NPR IJsonSerializable"
{
    var
        _constructed: Boolean;
        _json: JsonObject;
        _fieldId: JsonToken;
        _dataType: JsonToken;
        _format: JsonToken;
        _ordinal: JsonToken;
        _caption: JsonToken;
        _visible: JsonToken;
        _formula: JsonToken;
        _isSubtotal: JsonToken;
        _width: JsonToken;
        _isCheckbox: JsonToken;

        LabelFieldId: Label 'fieldId', Locked = true;
        LabelDataType: Label 'dataType', Locked = true;
        LabelFormat: Label 'format', Locked = true;
        LabelOrdinal: Label 'ordinal', Locked = true;
        LabelCaption: Label 'caption', Locked = true;
        LabelVisible: Label 'visible', Locked = true;
        LabelFormula: Label 'formula', Locked = true;
        LabelIsSubtotal: Label 'isSubtotal', Locked = true;
        LabelWidth: Label 'width', Locked = true;
        LabelIsCheckbox: Label 'isCheckbox', Locked = true;

        ErrorAccessViolation: Label 'Attempting to access an instance of "NPR Data Column" before calling its constructor.';

    local procedure MakeSureIsConstructed();
    begin
        if not _constructed then
            Error(ErrorAccessViolation);
    end;

    procedure FieldId(): Text;
    begin
        MakeSureIsConstructed();
        exit(_fieldId.AsValue().AsText());
    end;

    procedure FieldId(FromJsonObject: JsonObject): Text;
    var
        Token: JsonToken;
    begin
        // Do not call MakeSureIsConstructed from here! This is a "static" method
        FromJsonObject.Get(LabelFieldId, Token);
        exit(Token.AsValue().AsText());
    end;

    procedure DataType(): Enum "NPR Data Type";
    var
        DataTypeEnum: Enum "NPR Data Type";
    begin
        MakeSureIsConstructed();
        DataTypeEnum := "NPR Data Type".FromInteger(_dataType.AsValue().AsInteger());
        exit(DataTypeEnum);
    end;

    procedure Format(): Text;
    begin
        MakeSureIsConstructed();
        exit(_format.AsValue().AsText());
    end;

    procedure Ordinal(): Integer;
    begin
        MakeSureIsConstructed();
        exit(_ordinal.AsValue().AsInteger());
    end;

    procedure Ordinal(FromJsonObject: JsonObject): Integer;
    var
        Token: JsonToken;
    begin
        // Do not call MakeSureIsConstructed from here! This is a "static" method
        FromJsonObject.Get(LabelOrdinal, Token);
        exit(Token.AsValue().AsInteger());
    end;

    procedure Caption(): Text;
    begin
        MakeSureIsConstructed();
        exit(_caption.AsValue().AsText());
    end;

    procedure Visible(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_visible.AsValue().AsBoolean());
    end;

    procedure Formula(): Text;
    begin
        MakeSureIsConstructed();
        exit(_formula.AsValue().AsText());
    end;

    procedure IsSubtotal(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_isSubtotal.AsValue().AsBoolean());
    end;

    procedure Width(): Integer;
    begin
        MakeSureIsConstructed();
        exit(_width.AsValue().AsInteger());
    end;

    procedure SetWidth(NewWidth: Integer);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelWidth, NewWidth);
        _json.Get(LabelWidth, _width);
    end;

    procedure IsCheckbox(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_isCheckbox.AsValue().AsBoolean());
    end;

    local procedure Initialize();
    begin
        Clear(_constructed);
        Clear(_json);
        Clear(_fieldId);
        Clear(_dataType);
        Clear(_format);
        Clear(_ordinal);
        Clear(_caption);
        Clear(_visible);
        Clear(_formula);
        Clear(_isSubtotal);
        Clear(_width);
        Clear(_isCheckbox);
    end;

    procedure Constructor(
        FieldId: Text;
        Caption: Text;
        DataType: Enum "NPR Data Type";
        Ordinal: Integer;
        Visible: Boolean
    );
    begin
        Initialize();

        _json.Add(LabelFieldId, FieldId);
        _json.Get(LabelFieldId, _fieldId);

        _json.Add(LabelDataType, DataType.AsInteger());
        _json.Get(LabelDataType, _dataType);

        _json.Add(LabelFormat, '');
        _json.Get(LabelFormat, _format);

        _json.Add(LabelOrdinal, Ordinal);
        _json.Get(LabelOrdinal, _ordinal);

        _json.Add(LabelCaption, Caption);
        _json.Get(LabelCaption, _caption);

        _json.Add(LabelVisible, Visible);
        _json.Get(LabelVisible, _visible);

        _json.Add(LabelFormula, '');
        _json.Get(LabelFormula, _formula);

        _json.Add(LabelIsSubtotal, false);
        _json.Get(LabelIsSubtotal, _isSubtotal);

        _json.Add(LabelWidth, 0);
        _json.Get(LabelWidth, _width);

        _json.Add(LabelIsCheckbox, false);
        _json.Get(LabelIsCheckbox, _isCheckbox);

        _constructed := true;
    end;

    procedure Constructor(FromToken: JsonToken);
    var
        DataTypeEnum: Enum "NPR Data Type";
    begin
        Initialize();

        _json := FromToken.Clone().AsObject();

        if not _json.Get(LabelFieldId, _fieldId) then begin
            _json.Add(LabelFieldId, '');
            _json.Get(LabelFieldId, _fieldId);
        end;

        if not _json.Get(LabelDataType, _dataType) then begin
            _json.Add(LabelDataType, DataTypeEnum::Undefined.AsInteger());
            _json.Get(LabelDataType, _dataType);
        end;

        if not _json.Get(LabelFormat, _format) then begin
            _json.Add(LabelFormat, '');
            _json.Get(LabelFormat, _format);
        end;

        if not _json.Get(LabelOrdinal, _ordinal) then begin
            _json.Add(LabelOrdinal, 0);
            _json.Get(LabelOrdinal, _ordinal);
        end;

        if not _json.Get(LabelCaption, _caption) then begin
            _json.Add(LabelCaption, '');
            _json.Get(LabelCaption, _caption);
        end;

        if not _json.Get(LabelVisible, _visible) then begin
            _json.Add(LabelVisible, false);
            _json.Get(LabelVisible, _visible);
        end;

        if not _json.Get(LabelFormula, _formula) then begin
            _json.Add(LabelFormula, '');
            _json.Get(LabelFormula, _formula);
        end;

        if not _json.Get(LabelIsSubtotal, _isSubtotal) then begin
            _json.Add(LabelIsSubtotal, false);
            _json.Get(LabelIsSubtotal, _isSubtotal);
        end;

        if not _json.Get(LabelWidth, _width) then begin
            _json.Add(LabelWidth, 0);
            _json.Get(LabelWidth, _width);
        end;

        if not _json.Get(LabelIsCheckbox, _isCheckbox) then begin
            _json.Add(LabelIsCheckbox, false);
            _json.Get(LabelIsCheckbox, _isCheckbox);
        end;

        _constructed := true;
    end;

    procedure GetJson(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_json);
    end;

    procedure CompareTo(Other: Codeunit "NPR Data Column"): Integer;
    begin
        MakeSureIsConstructed();
        exit(Ordinal - Other.Ordinal);
    end;
}
