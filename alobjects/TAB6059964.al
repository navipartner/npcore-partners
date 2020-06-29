table 6059964 "MPOS QR Code"
{
    // NPR5.33/NPKNAV/20170630  CASE 277791 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/NPKNAV/20171003  CASE 280444-01 Transport NPR5.36 - 3 October 2017
    // NPR5.42/CLVA/20180302 CASE 304559 Added Company and "Cash Register Id" to the primary key

    Caption = 'MPOS QR Code';
    DataPerCompany = false;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(10; Password; Text[30])
        {
            Caption = 'Password';
            ExtendedDatatype = Masked;
        }
        field(11; Url; Text[250])
        {
            Caption = 'Url';
        }
        field(12; "Client Type"; Option)
        {
            Caption = 'Client Type';
            OptionCaption = 'Standard,Transcendence';
            OptionMembers = Standard,Transcendence;
        }
        field(13; Company; Text[30])
        {
            Caption = 'Company';
            TableRelation = Company;
            ValidateTableRelation = false;
        }
        field(14; "Payment Gateway"; Option)
        {
            Caption = 'Payment Gateway';
            OptionCaption = 'None,Nets,Adyen';
            OptionMembers = "None",Nets,Adyen;
        }
        field(15; Tenant; Text[30])
        {
            Caption = 'Tenant';
        }
        field(16; "E-mail"; Text[30])
        {
            Caption = 'E-mail';
        }
        field(17; "Webservice Url"; Text[250])
        {
            Caption = 'Webservice Url';
        }
        field(20; "QR code"; BLOB)
        {
            Caption = 'QR code';
            SubType = Bitmap;
        }
        field(21; "Cash Register Id"; Code[10])
        {
            Caption = 'Cash Register Id';
            TableRelation = Register."Register No.";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "User ID", Company, "Cash Register Id")
        {
        }
    }

    fieldgroups
    {
    }

    var
        BarCodeType: DotNet npNetBarCodeType;
        BarCodeSettings: DotNet npNetBarcodeSettings;
        BarCodeGenerator: DotNet npNetBarCodeGenerator;
        Image: DotNet npNetImage;
        ImageFormat: DotNet npNetImageFormat;

    procedure SetDefaults(var MPOSQRCode: Record "MPOS QR Code")
    begin
        MPOSQRCode.TestField("User ID");

        if MPOSQRCode.Url = '' then
            MPOSQRCode.Url := StringReplace(GetUrl(CLIENTTYPE::Windows));
        if MPOSQRCode.Tenant = '' then
            MPOSQRCode.Tenant := TenantId;
        if MPOSQRCode.Company = '' then
            MPOSQRCode.Company := CompanyName;
        if MPOSQRCode."Webservice Url" = '' then
            MPOSQRCode."Webservice Url" := GetUrl(CLIENTTYPE::SOAP);
        MPOSQRCode.Modify(true);
    end;

    local procedure StringReplace(String: Text): Text
    var
        Pos: Integer;
        Old: Text;
        New: Text;
    begin
        Old := 'dynamicsnav://';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old));
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        Old := '//';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old));
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        Old := ':';
        Pos := StrPos(String, Old);
        while Pos <> 0 do begin
            String := DelStr(String, Pos, StrLen(Old) + 4);
            String := InsStr(String, New, Pos);
            Pos := StrPos(String, Old);
        end;

        exit(String);
    end;

    procedure CreateQRCode(var MPOSQRCode: Record "MPOS QR Code")
    var
        TmpQR: Codeunit "Temp Blob";
        JsonString: Text;
        ClientType: Text[1];
        PaymentType: Text[10];
        RecRef: RecordRef;
    begin
        MPOSQRCode.TestField("User ID");
        MPOSQRCode.TestField(Url);

        case MPOSQRCode."Client Type" of
            "Client Type"::Standard:
                ClientType := 'S';
            "Client Type"::Transcendence:
                ClientType := 'T';
        end;

        case MPOSQRCode."Payment Gateway" of
            "Payment Gateway"::Adyen:
                PaymentType := 'Adyen';
            "Payment Gateway"::Nets:
                PaymentType := 'Nets';
            "Payment Gateway"::None:
                PaymentType := '';
        end;

        JsonString := '{ "A":"' + MPOSQRCode.Url +
                      '","B":"' + MPOSQRCode."User ID" +
                      '","C":"' + MPOSQRCode.Password +
                      '","D":"' + MPOSQRCode.Tenant +
                      '","E":"' + ClientType +
                      '","F":"' + MPOSQRCode.Company +
                      '","G":"' + PaymentType +
                      '","H":"' + MPOSQRCode."Webservice Url" +
                      '","I":"' + MPOSQRCode."Cash Register Id" +
                      '"}';

        GenerateBarcode(JsonString, TmpQR);

        RecRef.GetTable(MPOSQRCode);
        TmpQR.ToRecordRef(RecRef, MPOSQRCode.FieldNo("QR code"));
        RecRef.SetTable(MPOSQRCode);

        MPOSQRCode.Modify();
    end;

    procedure GenerateBarcode(BarCode: Text; var TempBlob: Codeunit "Temp Blob")
    var
        MemoryStream: DotNet npNetMemoryStream;
        OutStream: OutStream;
    begin
        BarCodeSettings := BarCodeSettings.BarcodeSettings();
        BarCodeSettings.Data := BarCode;

        BarCodeSettings.X := 2;
        BarCodeSettings.Y := 2;
        BarCodeSettings.ShowText := true;
        BarCodeSettings.UseAntiAlias := true;
        BarCodeSettings.Type := BarCodeType.QRCode;

        BarCodeGenerator := BarCodeGenerator.BarCodeGenerator(BarCodeSettings);
        BarCodeSettings.ApplyKey('3YOZI-9N0S5-RD239-JN9R0-WCGL8');
        Image := BarCodeGenerator.GenerateImage();
        MemoryStream := MemoryStream.MemoryStream;
        Image.Save(MemoryStream, ImageFormat.Png);
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, MemoryStream);
    end;
}

