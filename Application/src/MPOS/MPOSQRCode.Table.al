table 6059964 "NPR MPOS QR Code"
{
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
        field(12; "Client Type"; Option)
        {
            Caption = 'Client Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Standard,Transcendence';
            OptionMembers = Standard,Transcendence;
        }
        field(13; Company; Text[30])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
            TableRelation = Company;
            ValidateTableRelation = false;
        }
        field(14; "Payment Gateway"; Option)
        {
            Caption = 'Payment Gateway';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Nets,Adyen';
            OptionMembers = "None",Nets,Adyen;
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
        field(20; "QR code"; BLOB)
        {
            Caption = 'QR code';
            DataClassification = CustomerContent;
            SubType = Bitmap;
        }
        field(21; "Cash Register Id"; Code[10])
        {
            Caption = 'Cash Register Id';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "User ID", Company, "Cash Register Id")
        {
        }
    }

    var
        BarcodeImageLibrary: Codeunit "NPR Barcode Image Library";

    procedure SetDefaults(var MPOSQRCode: Record "NPR MPOS QR Code")
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

    procedure CreateQRCode(var MPOSQRCode: Record "NPR MPOS QR Code")
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
        QRLbl: Label 'QR', Locked = true;
    begin
        BarcodeImageLibrary.SetSizeX(2);
        BarcodeImageLibrary.SetSizeY(2);
        BarcodeImageLibrary.SetBarcodeType(QRLbl);
        BarcodeImageLibrary.GenerateBarcode(BarCode, TempBlob);
    end;
}

