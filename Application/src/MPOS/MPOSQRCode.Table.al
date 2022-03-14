﻿table 6059964 "NPR MPOS QR Code"
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
        field(12; "Client Type"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not used ';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(21; "Cash Register Id"; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(22; "QR Image"; Media)
        {
            Caption = 'QR code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "User ID", Company, "Cash Register Id")
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
    procedure SetDefaults(var MPOSQRCode: Record "NPR MPOS QR Code")
    begin
        MPOSQRCode.TestField("User ID");
        if not MPOSQRCode.Find() then
            MPOSQRCode.Insert(true);
        if MPOSQRCode.Url = '' then
            MPOSQRCode.Url := StringReplace(GetUrl(CLIENTTYPE::Windows));
        if MPOSQRCode.Tenant = '' then
            MPOSQRCode.Tenant := TenantId();
        if MPOSQRCode.Company = '' then begin
            if MPOSQRCode.Get(MPOSQRCode."User ID", CompanyName, MPOSQRCode."Cash Register Id") then
                Error('%1: %2', RecordExistsErrorText, Rec.GetPosition(true));
            MPOSQRCode.Rename(MPOSQRCode."User ID", CompanyName, MPOSQRCode."Cash Register Id");
        end;
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
#if BC17
    procedure CreateQRCode(var MPOSQRCode: Record "NPR MPOS QR Code")
    var
        TmpQR: Codeunit "Temp Blob";
        JsonString: Text;
        PaymentType: Text[10];
        InStr: InStream;
    begin
        MPOSQRCode.TestField("User ID");
        MPOSQRCode.TestField(Url);

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
                      '","F":"' + MPOSQRCode.Company +
                      '","G":"' + PaymentType +
                      '","H":"' + MPOSQRCode."Webservice Url" +
                      '","I":"' + MPOSQRCode."Cash Register Id" +
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
    procedure CreateQRCode(var MPOSQRCode: Record "NPR MPOS QR Code")
    var
        TmpQR: Codeunit "Temp Blob";
        JsonString: Text;
        PaymentType: Text[10];
        JObject: JsonObject;
        InStr: InStream;
    begin
        MPOSQRCode.TestField("User ID");
        MPOSQRCode.TestField(Url);

        case MPOSQRCode."Payment Gateway" of
            "Payment Gateway"::Adyen:
                PaymentType := 'Adyen';
            "Payment Gateway"::Nets:
                PaymentType := 'Nets';
            "Payment Gateway"::None:
                PaymentType := '';
        end;

        JObject.Add('A', MPOSQRCode.Url);
        JObject.Add('B', MPOSQRCode."User ID");
        JObject.Add('C', MPOSQRCode.Password);
        JObject.Add('D', MPOSQRCode.Tenant);
        JObject.Add('F', MPOSQRCode.Company);
        JObject.Add('G', PaymentType);
        JObject.Add('H', MPOSQRCode."Webservice Url");
        JObject.Add('I', MPOSQRCode."Cash Register Id");
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

