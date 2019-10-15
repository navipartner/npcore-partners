codeunit 6151492 "Raptor Helper Functions"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created


    trigger OnRun()
    begin
    end;

    procedure GetValueAsText(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Text
    begin
        ReturnValue := JObject.GetValue(PropertyName).ToString;
    end;

    procedure GetValueAsInteger(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Integer
    var
        DotNetInteger: DotNet npNetInt32;
    begin
        ReturnValue := DotNetInteger.Parse(JObject.GetValue(PropertyName).ToString);
    end;

    procedure GetValueAsDecimal(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Decimal
    var
        DotNetDecimal: DotNet npNetDecimal;
        CultureInfo: DotNet npNetCultureInfo;
    begin
        ReturnValue := DotNetDecimal.Parse(JObject.GetValue(PropertyName).ToString, CultureInfo.InvariantCulture);
    end;

    procedure GetValueAsDate(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Date
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DotNetType: DotNet npNetType;
    begin
        DotNetType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DotNetType);
        ReturnValue := DT2Date(DotNetDateTime);
    end;

    procedure GetValueAsTime(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Time
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DotNetType: DotNet npNetType;
    begin
        DotNetType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DotNetType);
        ReturnValue := DT2Time(DotNetDateTime);
    end;

    procedure GetValueAsDateTime(JObject: DotNet JObject; PropertyName: Text) ReturnValue: DateTime
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DotNetType: DotNet npNetType;
    begin
        DotNetType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DotNetType);
        ReturnValue := DotNetDateTime;
    end;

    procedure GetValueAsBoolean(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Boolean
    var
        DotNetBoolean: DotNet npNetBoolean;
    begin
        ReturnValue := DotNetBoolean.Parse(JObject.GetValue(PropertyName).ToString);
    end;

    procedure GetBooleanAsText(BooleanState: Boolean): Text
    begin
        if (BooleanState) then
            exit('true')
        else
            exit('false');
    end;

    procedure GetDateTimeAsText(DateTimeNow: DateTime): Text
    var
        DotNetDateTime: DotNet npNetDateTime;
    begin
        DotNetDateTime := DateTimeNow;
        exit(DotNetDateTime.ToString('yyyy-MM-dd hh:mm:ss'));
    end;

    procedure RemoveLastIndexOf(TextToTrim: Text; CharToTrim: Text): Text
    var
        DotNetString: DotNet npNetString;
        Index: Integer;
    begin
        if (TextToTrim = '') or (CharToTrim = '') then
            exit;

        DotNetString := TextToTrim;
        Index := DotNetString.LastIndexOf(CharToTrim);
        if Index > 0 then
            TextToTrim := DotNetString.Remove(Index, StrLen(CharToTrim));

        exit(TextToTrim);
    end;

    [TryFunction]
    procedure TryParse(json: Text; var JToken: DotNet JToken)
    begin
        JToken := JToken.Parse(json);
    end;

    procedure GetOptionStringValue(OptionInt: Integer; FieldNoInt: Integer; RecordVariant: Variant): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionString: DotNet npNetString;
        Options: DotNet npNetArray;
        Separator: DotNet npNetString;
    begin
        if not RecordVariant.IsRecord then
            exit;

        RecRef.GetTable(RecordVariant);
        FldRef := RecRef.Field(FieldNoInt);
        OptionString := FldRef.OptionString;

        Separator := ',';
        Options := OptionString.Split(Separator.ToCharArray());
        exit(Options.GetValue(OptionInt));
    end;

    procedure ConvertValueFromBase64(base64Value: Text) stringValue: Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        if base64Value = '' then
            exit('');

        stringValue := Encoding.UTF8.GetString(Convert.FromBase64String(base64Value));
        exit(stringValue);
    end;

    procedure ConvertValueToBase64(stringValue: Text) base64Value: Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        if stringValue = '' then
            exit('');

        base64Value := Convert.ToBase64String(Encoding.UTF8.GetBytes(stringValue));
        exit(base64Value);
    end;
}

