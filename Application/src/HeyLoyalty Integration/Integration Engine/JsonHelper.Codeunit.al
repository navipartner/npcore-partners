codeunit 6059994 "NPR Json Helper"
{
    Access = Internal;

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

    procedure GetJDT(Token: JsonToken; Path: Text; Required: Boolean) Result: DateTime
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
    local procedure JValueToBoolean(JValue: JsonValue; ValueOut: Boolean)
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
}