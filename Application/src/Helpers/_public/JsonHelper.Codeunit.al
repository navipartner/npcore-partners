codeunit 6059994 "NPR Json Helper"
{
    Access = Public;

    procedure GetJText(Token: JsonToken; Path: Text; Required: Boolean): Text
    begin
        exit(GetJText(Token, Path, 0, Required, ''));
    end;

    procedure GetJText(Token: JsonToken; Path: Text; Required: Boolean; DefaultValue: Text): Text
    begin
        exit(GetJText(Token, Path, 0, Required, DefaultValue));
    end;

    procedure GetJText(Token: JsonToken; Path: Text; MaxLength: Integer; Required: Boolean): Text
    begin
        exit(GetJText(Token, Path, MaxLength, Required, ''));
    end;

    procedure GetJText(Token: JsonToken; Path: Text; MaxLength: Integer; Required: Boolean; DefaultValue: Text): Text
    var
        JValue: JsonValue;
        Value: Text;
    begin
        if GetJValue(Token, Path, JValue) then begin
            Value := JValue.AsText();
            if MaxLength > 0 then
                Value := CopyStr(Value, 1, MaxLength);
        end;
        if Value = '' then begin
            if Required then
                RequiredValueMissingError(Token, Path);
            exit(DefaultValue);
        end;
        exit(Value);
    end;

    procedure GetJCode(Token: JsonToken; Path: Text; Required: Boolean): Text
    begin
        exit(GetJCode(Token, Path, 0, Required));
    end;

    procedure GetJCode(Token: JsonToken; Path: Text; MaxLength: Integer; Required: Boolean) Value: Text
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then begin
            Value := JValue.AsCode();
            if MaxLength > 0 then
                Value := CopyStr(Value, 1, MaxLength);
            Value := UpperCase(Value);
            exit(Value);
        end;
        if Required then
            RequiredValueMissingError(Token, Path);
        exit('');
    end;

    procedure GetJDT(Token: JsonToken; Path: Text; Required: Boolean): DateTime
    begin
        exit(GetJDT(Token, Path, Required, 0DT));
    end;

    procedure GetJDT(Token: JsonToken; Path: Text; Required: Boolean; DefaultValue: DateTime): DateTime
    var
        JValue: JsonValue;
        Result: DateTime;
    begin
        if GetJValue(Token, Path, JValue) then begin
            if not JValueAsDateTime(JValue, Result) then
                Result := FormatDateTime(JValue.AsText());
            if Result = 0DT then
                Result := DefaultValue;
            exit(Result);
        end;
        if Required then
            RequiredValueMissingError(Token, Path);
        exit(DefaultValue);
    end;

    [TryFunction]
    local procedure JValueAsDateTime(JValue: JsonValue; var DateTimeOut: DateTime)
    begin
        DateTimeOut := JValue.AsDateTime();
    end;

    local procedure FormatDateTime(DatetimeAsText: Text): DateTime
    var
        TypeHelper: Codeunit "Type Helper";
        ResultDate: Date;
        ResultTime: Time;
        OffSet: Duration;
    begin
        if not Evaluate(ResultDate, CopyStr(DatetimeAsText, 1, 10), 9) then
            exit(0DT);
        if not Evaluate(ResultTime, CopyStr(DatetimeAsText, 12), 9) then
            ResultTime := 0T;
        TypeHelper.GetUserTimezoneOffset(OffSet);
        exit(CreateDateTime(ResultDate, ResultTime) + OffSet);
    end;

    procedure GetJDate(Token: JsonToken; Path: Text; Required: Boolean): Date
    var
        JValue: JsonValue;
        EvaluatedDate: Date;
    begin
        if GetJValue(Token, Path, JValue) then begin
            if Evaluate(EvaluatedDate, CopyStr(JValue.AsText(), 1, 10), 9) then
                exit(EvaluatedDate);
            exit(JValue.AsDate());
        end;
        if Required then
            RequiredValueMissingError(Token, Path);
        exit(0D);
    end;

    procedure GetJDecimal(Token: JsonToken; Path: Text; Required: Boolean): Decimal
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then
            exit(JValue.AsDecimal());
        if Required then
            RequiredValueMissingError(Token, Path);
        exit(0);
    end;

    procedure GetJInteger(Token: JsonToken; Path: Text; Required: Boolean): Integer
    begin
        exit(GetJInteger(Token, Path, Required, 0));
    end;

    procedure GetJInteger(Token: JsonToken; Path: Text; Required: Boolean; DefaultValue: Integer): Integer
    var
        JValue: JsonValue;
        Value: Integer;
        Found: Boolean;
    begin
        Found := GetJValue(Token, Path, JValue);
        if Found then
            Value := JValue.AsInteger();
        if Required and not (Found and (Value <> 0)) then
            RequiredValueMissingError(Token, Path);
        if Value = 0 then
            Value := DefaultValue;
        exit(Value);
    end;

    procedure GetJBigInteger(Token: JsonToken; Path: Text; Required: Boolean): BigInteger
    var
        JValue: JsonValue;
    begin
        if GetJValue(Token, Path, JValue) then
            exit(JValue.AsBigInteger());
        if Required then
            RequiredValueMissingError(Token, Path);
        exit(0);
    end;

    procedure GetJBoolean(Token: JsonToken; Path: Text; Required: Boolean): Boolean
    var
        JValue: JsonValue;
        Value: Boolean;
    begin
        if GetJValue(Token, Path, JValue) then begin
            if JValueToBoolean(JValue, Value) then
                exit(Value);
            case JValue.AsText() of
                '1':
                    exit(true);
                '0', '':
                    exit(false);
                else
                    if Evaluate(Value, JValue.AsText()) then
                        exit(Value);
            end;
        end;
        if Required then
            RequiredValueMissingError(Token, Path);
        exit(false);
    end;

    [TryFunction]
    local procedure JValueToBoolean(JValue: JsonValue; var ValueOut: Boolean)
    begin
        ValueOut := JValue.AsBoolean();
    end;

    local procedure GetJValue(Token: JsonToken; Path: Text; var JValue: JsonValue): Boolean
    var
        Token2: JsonToken;
    begin
        if not GetJsonToken(Token, Path, Token2) then
            exit(false);
        if Token2.IsArray() then
            If not Token2.AsArray().Get(0, Token2) then
                exit(false);
        if not Token2.IsValue() then
            exit(false);
        JValue := Token2.AsValue();
        if JValue.IsNull() or JValue.IsUndefined() then
            exit(false);
        exit(true);
    end;

    procedure GetJsonToken(Token: JsonToken; TokenKey: Text) TokenOut: JsonToken
    begin
        if not GetJsonToken(Token, TokenKey, TokenOut) then
            RequiredValueMissingError(Token, TokenKey);
    end;

    procedure GetJsonToken(Token: JsonToken; TokenKey: Text; var TokenOut: JsonToken): Boolean
    begin
        exit(Token.SelectToken(TokenKey, TokenOut));
    end;

    local procedure RequiredValueMissingError(Token: JsonToken; Path: Text)
    var
        ValueMissingErr: Label 'Required value missing: %1';
    begin
        Error(ValueMissingErr, GetAbsolutePath(Token, Path));
    end;

    local procedure GetAbsolutePath(Token: JsonToken; Path: Text) AbsolutePath: Text
    begin
        AbsolutePath := Token.Path();
        if (AbsolutePath <> '') and (Path <> '') then
            AbsolutePath += '/';
        AbsolutePath += Path;
        exit(AbsolutePath);
    end;

    procedure RecordToJson(TableNo: Integer; RecordPosition: Text): JsonObject
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableNo);
        RecRef.SetPosition(RecordPosition);
        RecRef.Find();
        exit(RecordToJson(RecRef));
    end;

    procedure RecordToJson(RecRelatedVariant: Variant): JsonObject
    var
        DataTypeManagement: Codeunit "Data Type Management";
        FldRef: FieldRef;
        RecRef: RecordRef;
        JField: JsonObject;
        JRecord: JsonObject;
        i: Integer;
        RecNotFoundErr: Label 'Database record could not be found for %1.', Comment = '%1 - record identifier';
    begin
        if not DataTypeManagement.GetRecordRef(RecRelatedVariant, RecRef) then
            Error(RecNotFoundErr, RecRelatedVariant);

        JRecord.Add('id', RecRef.Number());
        JRecord.Add('name', DelChr(RecRef.Name(), '=', ' /.-*+'));
        JRecord.Add('company', RecRef.CurrentCompany());
        JRecord.Add('position', RecRef.GetPosition(false));
        JRecord.Add('recordId', Format(RecRef.RecordId()));

        for i := 1 to RecRef.FieldCount do begin
            FldRef := RecRef.FieldIndex(i);
            JField.Add(Format(FldRef.Number(), 0, 9), FieldToJsonValue(FldRef));
        end;
        JRecord.Add('fields', JField);
        exit(JRecord);
    end;

    local procedure FieldToJsonValue(FldRef: FieldRef): JsonValue
    var
        FieldValue: JsonValue;
        IntValue: Integer;
        BigIntegerValue: BigInteger;
        DecimalValue: Decimal;
        DateTimeValue: DateTime;
        DateValue: Date;
        TimeValue: Time;
        DurationValue: Duration;
        GuidValue: Guid;
        BoolValue: Boolean;
    begin
        if (FldRef.Class() = FieldClass::FlowField) then
            FldRef.CalcField();

        if (FldRef.Type() <> FieldType::Boolean) and (not HasValue(FldRef)) then begin
            FieldValue.SetValueToNull();
            exit(FieldValue);
        end;

        case FldRef.Type() of
            FieldType::Boolean:
                begin
                    BoolValue := FldRef.Value();
                    FieldValue.SetValue(BoolValue);
                end;
            FieldType::Integer:
                begin
                    IntValue := FldRef.Value();
                    FieldValue.SetValue(IntValue);
                end;
            FieldType::Decimal:
                begin
                    DecimalValue := FldRef.Value();
                    FieldValue.SetValue(DecimalValue);
                end;
            FieldType::Date:
                begin
                    DateValue := FldRef.Value();
                    FieldValue.SetValue(DateValue);
                end;
            FieldType::Time:
                begin
                    TimeValue := FldRef.Value();
                    FieldValue.SetValue(TimeValue);
                end;
            FieldType::DateTime:
                begin
                    DateTimeValue := FldRef.Value();
                    FieldValue.SetValue(DateTimeValue);
                end;
            FieldType::Duration:
                begin
                    DurationValue := FldRef.Value();
                    FieldValue.SetValue(DurationValue);
                end;
            FieldType::BigInteger:
                begin
                    BigIntegerValue := FldRef.Value();
                    FieldValue.SetValue(BigIntegerValue);
                end;
            FieldType::Guid:
                begin
                    GuidValue := FldRef.Value();
                    FieldValue.SetValue(GuidValue);
                end;
            FieldType::Media,
            FieldType::MediaSet:
                begin
                    FieldValue.SetValue(GetBase64(FldRef));
                end;
            else
                FieldValue.SetValue(Format(FldRef.Value()));
        end;

        exit(FieldValue);
    end;

    local procedure HasValue(FldRef: FieldRef): Boolean
    var
        Int: Integer;
        Dec: Decimal;
        D: Date;
        T: Time;
    begin
        case FldRef.Type() of
            FieldType::Boolean:
                exit(FldRef.Value());
            FieldType::Option:
                exit(true);
            FieldType::Integer:
                begin
                    Int := FldRef.Value();
                    exit(Int <> 0);
                end;
            FieldType::Decimal:
                begin
                    Dec := FldRef.Value();
                    exit(Dec <> 0);
                end;
            FieldType::Date:
                begin
                    D := FldRef.Value();
                    exit(D <> 0D);
                end;
            FieldType::Time:
                begin
                    T := FldRef.Value();
                    exit(T <> 0T);
                end;
            FieldType::Blob:
                exit(false);
            else
                exit(Format(FldRef.Value()) <> '');
        end;
    end;

    local procedure GetBase64(FldRef: FieldRef): Text
    var
        Item: Record Item;
        TenantMedia: Record "Tenant Media";
        Base64: Codeunit "Base64 Convert";
        RecRef: RecordRef;
        InStream: InStream;
    begin
        RecRef := FldRef.Record();
        case true of
            (RecRef.Number() = Database::Item) and (FldRef.Number() = Item.FieldNo(Picture)):
                begin
                    Item.Get(RecRef.RecordId());
                    if (Item.Picture.Count() > 0) then
                        if TenantMedia.Get(Item.Picture.Item(1)) then begin
                            TenantMedia.CalcFields(Content);
                            if TenantMedia.Content.HasValue() then begin
                                TenantMedia.Content.CreateInStream(InStream, TextEncoding::Windows);
                                exit(Base64.ToBase64(InStream));
                            end;
                        end;
                    exit('<NOIMAGE>');
                end;
        end;
        exit('<Not Handled>');
    end;
}