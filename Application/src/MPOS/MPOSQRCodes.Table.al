table 6014673 "NPR MPOS QR Codes"
{
    Access = Internal;
    Caption = 'MPOS QR Code';
    DataClassification = CustomerContent;
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
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(11; Url; Text[250])
        {
            Caption = 'Url';
            DataClassification = CustomerContent;
        }
        field(13; Company; Text[30])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
            TableRelation = Company;
            ValidateTableRelation = false;
        }
        field(15; Tenant; Text[30])
        {
            Caption = 'Tenant';
            DataClassification = CustomerContent;
        }
        field(16; "E-mail"; Text[30])
        {
            Caption = 'E-mail';
            DataClassification = CustomerContent;
        }
        field(17; "Webservice Url"; Text[250])
        {
            Caption = 'Webservice Url';
            DataClassification = CustomerContent;
        }
        field(22; "QR Image"; Media)
        {
            Caption = 'QR code';
            DataClassification = CustomerContent;
        }


        field(23; "Scanner Type"; enum "NPR MPOS Scanner Type")
        {
            Caption = 'Scanner Type';
            DataClassification = CustomerContent;
        }
        field(24; "Adyen Environment"; Option)
        {
            Caption = 'Environment';
            DataClassification = CustomerContent;
            OptionMembers = "Live","Test";
            InitValue = Live;
        }
        field(25; "Payment Integration"; enum "NPR MPOS Payment Integration")
        {
            Caption = 'Payment Integration';
            DataClassification = CustomerContent;
        }
        field(26; "Terminal Url"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Terminal Url';
        }


    }

    keys
    {
        key(PK; "User ID", Company)
        {
        }
    }

    var
#if BC17
        BarcodeImageLibrary: Codeunit "NPR Barcode Image Library";
#endif
#if not BC17
        BarcodeProvider: Codeunit "NPR Barcode Font Provider Mgt.";
#endif
        TenantIdErrorMsg: Label 'TenantId is too long, Maximum Lenght for tenant is 30 characters. This is a programming bug, not a user error. Please contact system vendor.';

    procedure SetDefaults(var MPOSQRCode: Record "NPR MPOS QR Codes")
    begin
        MPOSQRCode.TestField("User ID");
        if not MPOSQRCode.Find() then
            MPOSQRCode.Insert(true);
        if MPOSQRCode.Url = '' then
            MPOSQRCode.Url := CopyStr(StringReplace(GetUrl(CLIENTTYPE::Windows)), 1, MaxStrLen(MPOSQRCode.Url));
        if MPOSQRCode.Tenant = '' then
            if StrLen(TenantId()) > MaxStrLen(MPOSQRCode.Tenant) then
                Error(TenantIdErrorMsg)
            else
#pragma warning disable AA0139
            MPOSQRCode.Tenant := TenantId();
#pragma warning restore
        if MPOSQRCode.Company = '' then begin
            if MPOSQRCode.Get(MPOSQRCode."User ID", CompanyName) then
                Error('%1: %2', RecordExistsErrorText, Rec.GetPosition(true));
            MPOSQRCode.Rename(MPOSQRCode."User ID", CompanyName);
        end;
        if MPOSQRCode."Webservice Url" = '' then
            MPOSQRCode."Webservice Url" := CopyStr(GetUrl(CLIENTTYPE::SOAP), 1, MaxStrLen(MPOSQRCode."Webservice Url"));
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
#if BC17
    procedure CreateQRCode(var MPOSQRCode: Record "NPR MPOS QR Codes")
    var
        TmpQR: Codeunit "Temp Blob";
        JsonString: Text;
        PaymentType: Text[10];
        InStr: InStream;
    begin
        MPOSQRCode.TestField("User ID");
        MPOSQRCode.TestField(Url);

        JsonString := '{ "A":"' + MPOSQRCode.Url +
                      '","B":"' + MPOSQRCode."User ID" +
                      '","C":"' + MPOSQRCode.Password +
                      '","D":"' + MPOSQRCode.Tenant +
                      '","F":"' + MPOSQRCode.Company +
                      '","G":"' + PaymentType +
                      '","H":"' + MPOSQRCode."Webservice Url" +
                      '","I":"' + 
                      '","J":"' + MPOSQRCode."Scanner Type".Names.Get(MPOSQRCode."Scanner Type".Ordinals.IndexOf(MPOSQRCode."Scanner Type".AsInteger())) +
                      '","K":"' + Format(MPOSQRCode."Adyen Environment") +
                      '","L":"' + MPOSQRCode."Payment Integration".Names.Get(MPOSQRCode."Payment Integration".Ordinals.IndexOf(MPOSQRCode."Payment Integration".AsInteger())) +
                      '","O":"' + MPOSQRCode."Terminal Url" +
                      '"}';

        GenerateBarcode(JsonString, TmpQR);
        TmpQR.CreateInStream(InStr);
        MPOSQRCode."QR Image".ImportStream(InStr, MPOSQRCode.FieldName("QR Image"));
        MPOSQRCode.Modify();
    end;

    procedure GenerateBarcode(BarCode: Text; var TempBlob: Codeunit "Temp Blob")
    var
        QRLbl: Label 'QR', Locked = true;
    begin
        BarcodeImageLibrary.SetSizeX(2);
        BarcodeImageLibrary.SetSizeY(2);
        BarcodeImageLibrary.SetBarcodeType(QRLbl);
        BarcodeImageLibrary.GenerateBarcode(BarCode, TempBlob);
    end;
#endif
#if not BC17
    procedure CreateQRCode(var MPOSQRCode: Record "NPR MPOS QR Codes")
    var
        TmpQR: Codeunit "Temp Blob";
        JsonString: Text;
        PaymentType: Text[10];
        JObject: JsonObject;
        InStr: InStream;
    begin
        MPOSQRCode.TestField("User ID");
        MPOSQRCode.TestField(Url);

        JObject.Add('A', MPOSQRCode.Url);
        JObject.Add('B', MPOSQRCode."User ID");
        JObject.Add('C', MPOSQRCode.Password);
        JObject.Add('D', MPOSQRCode.Tenant);
        JObject.Add('F', MPOSQRCode.Company);
        JObject.Add('G', PaymentType);
        JObject.Add('H', MPOSQRCode."Webservice Url");
        JObject.Add('I', '');
        JObject.Add('J', MPOSQRCode."Scanner Type".Names.Get(MPOSQRCode."Scanner Type".Ordinals.IndexOf(MPOSQRCode."Scanner Type".AsInteger())));
        JObject.Add('K', Format(MPOSQRCode."Adyen Environment"));
        JObject.Add('L', MPOSQRCode."Payment Integration".Names.Get(MPOSQRCode."Payment Integration".Ordinals.IndexOf(MPOSQRCode."Payment Integration".AsInteger())));
        JObject.Add('O', MPOSQRCode."Terminal Url");
        JObject.WriteTo(JsonString);
        GenerateBarcode(JsonString, TmpQR);

        TmpQR.CreateInStream(InStr);
        MPOSQRCode."QR Image".ImportStream(InStr, MPOSQRCode.FieldName("QR Image"));
        MPOSQRCode.Modify();
    end;

    procedure GenerateBarcode(BarCode: Text; var TempBlob: Codeunit "Temp Blob")
    var
        Base64Image: Text;
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
    begin
        Base64Image := BarcodeProvider.GenerateQRCodeAZ(BarCode, 'H', 'UTF8', true, true, 5);
        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(Base64Image, OutStr);
    end;
#endif
    var
        RecordExistsErrorText: Label 'Cannot set default values as record with same primary key already exists';

}

