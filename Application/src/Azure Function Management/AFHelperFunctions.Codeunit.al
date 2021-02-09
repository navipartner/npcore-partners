codeunit 6151571 "NPR AF Helper Functions"
{
    trigger OnRun()
    begin
    end;

    var
        TXT001: Label 'Clear the customer tag and disable notifications?';

    procedure GetValueAsText(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Text
    begin
        ReturnValue := JObject.GetValue(PropertyName).ToString;
    end;

    procedure GetValueAsInteger(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Integer
    var
        DotNetInteger: DotNet NPRNetInt32;
    begin
        ReturnValue := DotNetInteger.Parse(JObject.GetValue(PropertyName).ToString);
    end;

    procedure GetValueAsDecimal(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Decimal
    var
        DotNetDecimal: DotNet NPRNetDecimal;
        CultureInfo: DotNet NPRNetCultureInfo;
    begin
        ReturnValue := DotNetDecimal.Parse(JObject.GetValue(PropertyName).ToString, CultureInfo.InvariantCulture);
    end;

    procedure GetValueAsDate(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Date
    var
        DotNetDateTime: DotNet NPRNetDateTime;
        CultureInfo: DotNet NPRNetCultureInfo;
        DtDataType: DotNet NPRNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DT2Date(DotNetDateTime);
    end;

    procedure GetValueAsTime(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Time
    var
        DotNetDateTime: DotNet NPRNetDateTime;
        CultureInfo: DotNet NPRNetCultureInfo;
        DtDataType: DotNet NPRNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DT2Time(DotNetDateTime);
    end;

    procedure GetValueAsDateTime(JObject: DotNet JObject; PropertyName: Text) ReturnValue: DateTime
    var
        DotNetDateTime: DotNet NPRNetDateTime;
        CultureInfo: DotNet NPRNetCultureInfo;
        DtDataType: DotNet NPRNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DotNetDateTime;
    end;

    procedure GetValueAsBoolean(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Boolean
    var
        DotNetBoolean: DotNet NPRNetBoolean;
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
        DotNetDateTime: DotNet NPRNetDateTime;
    begin
        DotNetDateTime := DateTimeNow;
        exit(DotNetDateTime.ToString('yyyy-MM-dd hh:mm:ss'));
    end;


    procedure RemoveLastIndexOf(TextToTrim: Text; CharToTrim: Text): Text
    var
        DotNetString: DotNet NPRNetString;
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
        OptionString: DotNet NPRNetString;
        Options: DotNet NPRNetArray;
        Separator: DotNet NPRNetString;
    begin
        if not RecordVariant.IsRecord then
            exit;

        RecRef.GetTable(RecordVariant);
        FldRef := RecRef.Field(FieldNoInt);
        OptionString := FldRef.OptionMembers;

        Separator := ',';
        Options := OptionString.Split(Separator.ToCharArray());
        exit(Options.GetValue(OptionInt));
    end;

    procedure GetMagentoItemImage(var Item: Record Item; var PictureFileName: Text) Base64String: Text
    var
        TmpMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
    begin
        MagentoPictureLink.SetRange("Item No.", Item."No.");
        MagentoPictureLink.SetRange("Base Image", true);
        if not MagentoPictureLink.FindFirst then
            exit(Base64String);

        if not MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
            exit(Base64String);

        if MagentoPicture.DownloadPicture(TmpMagentoPicture) then begin
            TmpMagentoPicture.Picture.CreateInStream(InStr);
            MemoryStream := InStr;
            BinaryReader := BinaryReader.BinaryReader(InStr);

            Base64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

            MemoryStream.Dispose;
            Clear(MemoryStream);

            PictureFileName := MagentoPicture.Name;

            exit(Base64String);

        end;

        exit(Base64String);
    end;


    procedure ConvertValueFromBase64(base64Value: Text) stringValue: Text
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        if base64Value = '' then
            exit('');

        stringValue := Encoding.UTF8.GetString(Convert.FromBase64String(base64Value));
        exit(stringValue);
    end;

    procedure ConvertValueToBase64(stringValue: Text) base64Value: Text
    var
        Convert: DotNet NPRNetConvert;
        Encoding: DotNet NPRNetEncoding;
    begin
        if stringValue = '' then
            exit('');

        base64Value := Convert.ToBase64String(Encoding.UTF8.GetBytes(stringValue));
        exit(base64Value);
    end;
}

