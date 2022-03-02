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

    procedure FieldRefToVariant(FieldReference: FieldRef; var FieldValue: Variant)
    begin
        case UpperCase(Format(FieldReference.Type())) of
            'BLOB':
                FieldValue := BLOBToBase64String(FieldReference);
            'DATE', 'TIME', 'DATEFORMULA', 'DURATION', 'RECORDID', 'DATETIME':
                FieldValue := Format(FieldReference.Value(), 0, 9);
            'TABLEFILTER':
                FieldValue := ''; //Not supported
            else
                FieldValue := FieldReference.Value();
        end;
    end;

    [TryFunction]
    procedure JValueToFieldRef(JValue: JsonValue; FieldReference: FieldRef)
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
                    TempBlob.CreateOutStream(OutStr);
                    OutStr.WriteText(Base64Convert.FromBase64(ValueText));
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

    local procedure BLOBToBase64String(FieldReference: FieldRef) FieldValue: Text
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
            TempBlob.CreateInStream(InStr);
            InStr.ReadText(StreamContent);
            FieldValue := Base64Convert.ToBase64(StreamContent);
        end;
    end;

    procedure CreateDependencyJObject(var JObject: JsonObject; Type: Text; Name: Text; Version: Text)
    begin
        JObject.Add('Type', Type);
        JObject.Add('Name', Name);
        JObject.Add('Version', Version);
    end;

}