table 6014601 "NPR POS Security Profile"
{
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
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

}