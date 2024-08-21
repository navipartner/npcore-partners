codeunit 6060164 "NPR Convert Helper"
{
    Access = Internal;
    procedure AddToJObject(JObject: JsonObject; "Key": Text; Value: Variant)
    var
        ValueInt: Integer;
        ValueBigInt: BigInteger;
        ValueOption: Option;
        ValueDec: Decimal;
        ValueBool: Boolean;
        ValueDate: Date;
        ValueDateTime: DateTime;
        ValueTime: Time;
        ValueDuration: Duration;
    begin
        case TRUE of
            Value.IsInteger:
                begin
                    ValueInt := Value;
                    JObject.Add(Key, ValueInt);
                end;
            Value.IsBigInteger:
                begin
                    ValueBigInt := Value;
                    JObject.Add(Key, ValueBigInt);
                end;
            Value.IsOption:
                begin
                    ValueOption := Value;
                    JObject.Add(Key, ValueOption);
                end;
            Value.IsDuration:
                begin
                    ValueDuration := Value;
                    JObject.Add(Key, ValueDuration);
                end;
            Value.IsDecimal:
                begin
                    ValueDec := Value;
                    JObject.Add(Key, ValueDec);
                end;
            Value.IsBoolean:
                begin
                    ValueBool := Value;
                    JObject.Add(Key, ValueBool);
                end;
            Value.IsDate:
                begin
                    ValueDate := Value;
                    JObject.Add(Key, ValueDate);
                end;
            Value.IsDateTime:
                begin
                    ValueDateTime := Value;
                    JObject.Add(Key, ValueDateTime);
                end;
            Value.IsTime:
                begin
                    ValueTime := Value;
                    JObject.Add(Key, ValueTime);
                end;
            else
                JObject.Add(Key, Format(Value));
        end;
    end;

    procedure FieldRefToVariant(FieldReference: FieldRef; var FieldValue: Variant; Encoding: TextEncoding)
    begin
        case UpperCase(Format(FieldReference.Type())) of
            'BLOB':
                FieldValue := BLOBToBase64String(FieldReference, Encoding);
            'DATE', 'TIME', 'DATEFORMULA', 'DURATION', 'RECORDID', 'DATETIME':
                FieldValue := Format(FieldReference.Value(), 0, 9);
            'TABLEFILTER':
                FieldValue := ''; //Not supported
            else
                FieldValue := FieldReference.Value();
        end;
    end;

    [TryFunction]
    procedure FieldRefToVariant(FieldReference: FieldRef; var FieldValue: Variant)
    begin
        FieldRefToVariant(FieldReference, FieldValue, TextEncoding::MSDos);
    end;


    [TryFunction]
    procedure JValueToFieldRef(JValue: JsonValue; FieldReference: FieldRef; Encoding: TextEncoding)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        ValueText: Text;
        ValueDateFormula: DateFormula;
        ValueDuration: Duration;
        ValueGUID: Guid;
        ValueRecordID: RecordID;
    begin
        case UpperCase(Format(FieldReference.Type)) of
            'CODE', 'TEXT':
                FieldReference.Value := JValue.AsText();
            'OPTION':
                FieldReference.Value := JValue.AsOption();
            'INTEGER', 'BIGINTEGER':
                FieldReference.Value := JValue.AsBigInteger();
            'DECIMAL':
                FieldReference.Value := JValue.AsDecimal();
            'BOOLEAN':
                FieldReference.Value := JValue.AsBoolean();
            'DATE':
                FieldReference.Value := JValue.AsDate();
            'DATETIME':
                FieldReference.Value := JValue.AsDateTime();
            'TIME':
                FieldReference.Value := JValue.AsTime();
            'BLOB':
                begin
                    ValueText := JValue.AsText();
                    TempBlob.CreateOutStream(OutStr, Encoding);
                    OutStr.WriteText(Base64Convert.FromBase64(ValueText, Encoding));
                    TempBlob.ToFieldRef(FieldReference);
                end;
            'DATEFORMULA':
                begin
                    Evaluate(ValueDateFormula, JValue.AsText(), 9);
                    FieldReference.Value := ValueDateFormula;
                end;
            'DURATION':
                begin
                    Evaluate(ValueDuration, JValue.AsText(), 9);
                    FieldReference.Value := ValueDuration;
                end;
            'GUID':
                begin
                    Evaluate(ValueGUID, JValue.AsText());
                    FieldReference.Value := ValueGUID;
                end;
            'RECORDID':
                begin
                    Evaluate(ValueRecordID, JValue.AsText(), 9);
                    FieldReference.Value := ValueRecordID;
                end;
            'TABLEFILTER':
                ; //Not supported
        end;
    end;

    [TryFunction]
    procedure JValueToFieldRef(JValue: JsonValue; FieldReference: FieldRef)
    begin
        JValueToFieldRef(JValue, FieldReference, TextEncoding::MSDos);
    end;

    local procedure BLOBToBase64String(FieldReference: FieldRef; Encoding: TextEncoding) FieldValue: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        StreamContent: Text;
    begin
        FieldValue := '';
        FieldReference.CalcField();
        TempBlob.FromFieldRef(FieldReference);
        if TempBlob.HasValue() then begin
            TempBlob.CreateInStream(InStr, Encoding);
            InStr.ReadText(StreamContent);
            FieldValue := Base64Convert.ToBase64(StreamContent, Encoding);
        end;
    end;

    procedure CreateDependencyJObject(var JObject: JsonObject; Type: Text; Name: Text; Version: Text)
    begin
        JObject.Add('Type', Type);
        JObject.Add('Name', Name);
        JObject.Add('Version', Version);
    end;

    internal procedure DecodeUnicodeEscapes(EscapedText: Text) UnescapedText: Text
    var
        Position: Integer;
        StartPosition: Integer;
        EndPosition: Integer;
        HexValue: Text;
        UnicodeValue: Integer;
        UnicodeChar: Text;
    begin
        UnescapedText := EscapedText;
        Position := StrPos(UnescapedText, '_x');
        while Position > 0 do begin
            StartPosition := Position;
            EndPosition := StartPosition + 6;

            if (StrLen(UnescapedText) >= EndPosition) and (CopyStr(UnescapedText, EndPosition, 1) = '_') then begin
                HexValue := CopyStr(UnescapedText, StartPosition + 2, 4);
                UnicodeValue := ConvertHexToInteger(HexValue);
                UnicodeChar := ConvertToChar(UnicodeValue);
                UnescapedText := CopyStr(UnescapedText, 1, StartPosition - 1) + UnicodeChar + CopyStr(UnescapedText, EndPosition + 1);
            end;

            Position := StrPos(UnescapedText, '_x');
        end;
    end;

    local procedure ConvertHexToInteger(HexStr: Text) Value: Integer
    var
        i: Integer;
        Digit: Integer;
    begin
        Value := 0;
        for i := 1 to StrLen(HexStr) do begin
            Digit := GetHexDigitValue(CopyStr(HexStr, i, 1));
            Value := Value * 16 + Digit;
        end;
    end;

    local procedure GetHexDigitValue(HexChar: Text[1]) HexDigitValue: Integer
    var
        AsciiValue: Integer;
        InvalidHexadecimalCharacterErrorLbl: Label 'Invalid hexadecimal character: %1';
    begin
        AsciiValue := StrPos('0123456789ABCDEF', UpperCase(HexChar));
        if AsciiValue = 0 then
            Error(InvalidHexadecimalCharacterErrorLbl, HexChar);
        HexDigitValue := AsciiValue - 1;
    end;

    local procedure ConvertToChar(UnicodeValue: Integer) CharText: Text
    var
        Char: Char;
    begin
        Char := UnicodeValue;
        CharText := Char;
    end;

}