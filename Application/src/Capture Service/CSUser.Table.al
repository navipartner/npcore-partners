table 6151370 "NPR CS User"
{
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
        CryptographyMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        HashedValue := CryptographyMgt.GenerateHashAsBase64String(Input + Name, HashAlgorithmType::SHA512);
    end;
}

