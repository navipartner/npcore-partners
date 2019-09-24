codeunit 6151571 "AF Helper Functions"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Helper Functions
    // NPR5.38/CLVA/20170710 CASE 289636 Added GetMagentoItemImage, GetWebServiceUrl,
    // NPR5.43/CLVA/20180528 CASE 279861 Added ConvertValueFromBase64 and ConvertValueToBase64
    // NPR5.44/CLVA/20180710 CASE 279861 Added GUI check


    trigger OnRun()
    begin
    end;

    var
        TXT001: Label 'Clear the customer tag and disable notifications?';

    procedure GetValueAsText(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Text
    begin
        ReturnValue := JObject.GetValue(PropertyName).ToString;
    end;

    procedure GetValueAsInteger(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Integer
    var
        DotNetInteger: DotNet npNetInt32;
    begin
        ReturnValue := DotNetInteger.Parse(JObject.GetValue(PropertyName).ToString);
    end;

    procedure GetValueAsDecimal(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Decimal
    var
        DotNetDecimal: DotNet npNetDecimal;
        CultureInfo: DotNet npNetCultureInfo;
    begin
        ReturnValue := DotNetDecimal.Parse(JObject.GetValue(PropertyName).ToString,CultureInfo.InvariantCulture);
    end;

    procedure GetValueAsDate(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Date
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DtDataType: DotNet npNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DT2Date(DotNetDateTime);
    end;

    procedure GetValueAsTime(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Time
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DtDataType: DotNet npNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DT2Time(DotNetDateTime);
    end;

    procedure GetValueAsDateTime(JObject: DotNet JObject;PropertyName: Text) ReturnValue: DateTime
    var
        DotNetDateTime: DotNet npNetDateTime;
        CultureInfo: DotNet npNetCultureInfo;
        DtDataType: DotNet npNetType;
    begin
        DtDataType := GetDotNetType(DotNetDateTime);
        DotNetDateTime := JObject.GetValue(PropertyName).ToObject(DtDataType);
        ReturnValue := DotNetDateTime;
    end;

    procedure GetValueAsBoolean(JObject: DotNet JObject;PropertyName: Text) ReturnValue: Boolean
    var
        DotNetBoolean: DotNet npNetBoolean;
    begin
        ReturnValue := DotNetBoolean.Parse(JObject.GetValue(PropertyName).ToString);
    end;

    procedure GetBooleanAsText(BooleanState: Boolean): Text
    begin
        if(BooleanState) then
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

    procedure GetWebServiceUrl(var AFSetup: Record "AF Setup") SOAPUrl: Text
    var
        WebService: Record "Web Service";
    begin
        if AFSetup."Web Service Url" <> '' then
          exit(AFSetup."Web Service Url");

        if not WebService.Get(WebService."Object Type"::Codeunit,'azurefunction_service') then begin
          WebService.Init;
          WebService."Object Type" := WebService."Object Type"::Codeunit;
          WebService."Service Name" := 'azurefunction_service';
          WebService."Object ID" := 6151572;
          WebService.Published := true;
          WebService.Insert;
        end;

        AFSetup."Web Service Url" := GetUrl(CLIENTTYPE::SOAP,CompanyName,OBJECTTYPE::Codeunit,6151572);
        AFSetup.Modify(true);
        exit(AFSetup."Web Service Url");
    end;

    procedure RemoveLastIndexOf(TextToTrim: Text;CharToTrim: Text): Text
    var
        DotNetString: DotNet npNetString;
        Index: Integer;
    begin
        if (TextToTrim = '') or (CharToTrim = '') then
          exit;

        DotNetString := TextToTrim;
        Index := DotNetString.LastIndexOf(CharToTrim);
        if Index > 0 then
          TextToTrim := DotNetString.Remove(Index,StrLen(CharToTrim));

        exit(TextToTrim);
    end;

    [TryFunction]
    procedure TryParse(json: Text;var JToken: DotNet JToken)
    begin
        JToken := JToken.Parse(json);
    end;

    procedure GetOptionStringValue(OptionInt: Integer;FieldNoInt: Integer;RecordVariant: Variant): Text
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

    procedure GetMagentoItemImage(var Item: Record Item;var PictureFileName: Text) Base64String: Text
    var
        TmpMagentoPicture: Record "Magento Picture" temporary;
        MagentoPicture: Record "Magento Picture";
        MagentoPictureLink: Record "Magento Picture Link";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin
        MagentoPictureLink.SetRange("Item No.",Item."No.");
        MagentoPictureLink.SetRange("Base Image",true);
        if not MagentoPictureLink.FindFirst then
          exit(Base64String);

        if not MagentoPicture.Get(MagentoPicture.Type::Item,MagentoPictureLink."Picture Name") then
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

    procedure ClearCustomerTag(var AFSetup: Record "AF Setup")
    begin
        //-NPR5.44 [279861]
        if GuiAllowed then
        //+NPR5.44 [279861]
          if not Confirm(TXT001,true) then
            exit;

        AFSetup."Customer Tag" := '';
        AFSetup.Modify(false);
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

