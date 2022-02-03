table 6014601 "NPR POS Security Profile"
{
    Access = Internal;
    Caption = 'NPR POS Security Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Security Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Password on Unblock Discount"; Text[4])
        {
            Caption = 'Administrator Password';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(30; "Unlock Password"; Code[20])
        {
            Caption = 'Unlock Password';
            DataClassification = CustomerContent;
        }
        field(40; "Lock Timeout"; Enum "NPR POS View LockTimeout")
        {
            Caption = 'Lock Timeout';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
