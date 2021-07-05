codeunit 6151571 "NPR AF Helper Functions"
{
    procedure GetValueAsText(JObject: JsonObject; PropertyName: Text) ReturnValue: Text
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsText();
    end;

    procedure GetValueAsInteger(JObject: JsonObject; PropertyName: Text) ReturnValue: Integer
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsInteger();
    end;

    procedure GetValueAsDecimal(JObject: JsonObject; PropertyName: Text) ReturnValue: Decimal
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsDecimal();
    end;

    procedure GetValueAsDate(JObject: JsonObject; PropertyName: Text) ReturnValue: Date
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsDate();
    end;

    procedure GetValueAsTime(JObject: JsonObject; PropertyName: Text) ReturnValue: Time
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsTime();
    end;

    procedure GetValueAsDateTime(JObject: JsonObject; PropertyName: Text) ReturnValue: DateTime
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsDateTime();
    end;

    procedure GetValueAsBoolean(JObject: JsonObject; PropertyName: Text) ReturnValue: Boolean
    var
        Jtoken: JsonToken;
    begin
        JObject.Get(PropertyName, Jtoken);
        ReturnValue := Jtoken.AsValue().AsBoolean();
    end;

    procedure GetBooleanAsText(BooleanState: Boolean): Text
    begin
        if (BooleanState) then
            exit('true')
        else
            exit('false');
    end;

    procedure GetDateTimeAsText(DateTimeNow: DateTime): Text
    begin
        exit(Format(DateTimeNow, 0, '<Year4>-<Month,2>-<Day,2> <Hours24>:<Minutes,2>:<Seconds,2>'));
    end;


    procedure RemoveLastIndexOf(TextToTrim: Text; CharToTrim: Text): Text
    var
        Index: Integer;
    begin
        if (TextToTrim = '') or (CharToTrim = '') then
            exit;

        Index := TextToTrim.LastIndexOf(CharToTrim);
        if Index > 0 then
            TextToTrim := TextToTrim.Remove(Index, StrLen(CharToTrim));

        exit(TextToTrim);
    end;

    [TryFunction]
    procedure TryParse(json: Text; var JToken: JsonToken)
    begin
        JToken.ReadFrom(json);
    end;

    procedure GetOptionStringValue(OptionInt: Integer; FieldNoInt: Integer; RecordVariant: Variant): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        OptionString: Text;

    begin
        if not RecordVariant.IsRecord then
            exit;

        RecRef.GetTable(RecordVariant);
        FldRef := RecRef.Field(FieldNoInt);
        OptionString := FldRef.OptionMembers;

        exit(SelectStr(OptionInt, OptionString));
    end;

    procedure GetMagentoItemImage(var Item: Record Item; var PictureFileName: Text) Base64String: Text
    var
        TempMagentoPicture: Record "NPR Magento Picture" temporary;
        MagentoPicture: Record "NPR Magento Picture";
        MagentoPictureLink: Record "NPR Magento Picture Link";
        Base64Convert: codeunit "Base64 Convert";
        // TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    // OutStr: OutStream;
    begin
        MagentoPictureLink.SetRange("Item No.", Item."No.");
        MagentoPictureLink.SetRange("Base Image", true);
        if not MagentoPictureLink.FindFirst() then
            exit(Base64String);

        if not MagentoPicture.Get(MagentoPicture.Type::Item, MagentoPictureLink."Picture Name") then
            exit(Base64String);

        if MagentoPicture.DownloadPicture(TempMagentoPicture) then begin
            // TempBlob.CreateOutStream(OutStr);
            // TempMagentoPicture.Image.ExportStream(OutStr);
            // TempBlob.CreateInStream(InStr);
            TempMagentoPicture.Picture.CreateInStream(InStr);
            Base64String := Base64Convert.ToBase64(InStr);

            PictureFileName := MagentoPicture.Name;

            exit(Base64String);

        end;

        exit(Base64String);
    end;


    procedure ConvertValueFromBase64(base64Value: Text) stringValue: Text
    var
        Base64Convert: codeunit "Base64 Convert";
    begin
        if base64Value = '' then
            exit('');

        stringValue := Base64Convert.FromBase64(base64Value, TextEncoding::UTF8);
        exit(stringValue);
    end;

    procedure ConvertValueToBase64(stringValue: Text) base64Value: Text
    var
        Base64Convert: codeunit "Base64 Convert";
    begin
        if base64Value = '' then
            exit('');

        stringValue := Base64Convert.ToBase64(base64Value, TextEncoding::UTF8);
        exit(stringValue);
    end;
}

