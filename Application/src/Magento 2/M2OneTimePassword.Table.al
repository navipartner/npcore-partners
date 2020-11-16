table 6151151 "NPR M2 One Time Password"
{
    // NPR5.48/TSA /20181210 CASE 320425 Authenticate Web User with an One Time Password
    // NPR5.49/TSA /20190307 CASE 347894 Changed Password Length to 80 and changed caption

    Caption = 'One Time Password';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Password (Hash)"; Text[80])
        {
            Caption = 'Password (Hash)';
            DataClassification = CustomerContent;
        }
        field(6; "Password2 (Hash)"; Text[80])
        {
            Caption = 'Password2 (Md5)';
            DataClassification = CustomerContent;
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(11; "Valid Until"; DateTime)
        {
            Caption = 'Valid Until';
            DataClassification = CustomerContent;
        }
        field(12; "Used At"; DateTime)
        {
            Caption = 'Used At';
            DataClassification = CustomerContent;
        }
        field(20; "E-Mail"; Text[80])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Password (Hash)")
        {
        }
    }

    fieldgroups
    {
    }
}

