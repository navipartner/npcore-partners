table 6151370 "NPR CS User"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.48/CLVA  /20181109  CASE 335606 Added field "View All Documents"

    Caption = 'CS User';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Code[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Password; Text[250])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                TestField(Password);
                Password := CalculatePassword(CopyStr(Password, 1, 30));
            end;
        }
        field(12; "View All Documents"; Boolean)
        {
            Caption = 'View All Documents';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField(Password);
    end;

    trigger OnModify()
    begin
        TestField(Password);
    end;

    trigger OnRename()
    begin
        Error(RenameIsNotAllowed);
    end;

    var
        RenameIsNotAllowed: Label 'You cannot rename the record.';

    procedure CalculatePassword(Input: Text[30]) HashedValue: Text[250]
    var
        Convert: DotNet NPRNetConvert;
        CryptoProvider: DotNet NPRNetSHA512Managed;
        Encoding: DotNet NPRNetEncoding;
    begin
        CryptoProvider := CryptoProvider.SHA512Managed;
        HashedValue := Convert.ToBase64String(CryptoProvider.ComputeHash(Encoding.Unicode.GetBytes(Input + Name)));
        CryptoProvider.Clear;
        CryptoProvider.Dispose;
    end;
}

