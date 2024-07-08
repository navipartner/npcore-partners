table 6059964 "NPR MPOS QR Code"
{
    Access = Internal;
    Caption = 'MPOS QR Code';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ObsoleteReason = 'Replaced with table NPR MPOS QR Codes';
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
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
            ObsoleteTag = 'NPR23.0';
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
            ObsoleteTag = 'NPR23.0';
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

}

