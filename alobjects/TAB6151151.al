table 6151151 "M2 One Time Password"
{
    // NPR5.48/TSA /20181210 CASE 320425 Authenticate Web User with an One Time Password
    // NPR5.49/TSA /20190307 CASE 347894 Changed Password Length to 80 and changed caption

    Caption = 'One Time Password';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Password (Hash)";Text[80])
        {
            Caption = 'Password (Hash)';
        }
        field(6;"Password2 (Hash)";Text[80])
        {
            Caption = 'Password2 (Md5)';
        }
        field(10;"Created At";DateTime)
        {
            Caption = 'Created At';
        }
        field(11;"Valid Until";DateTime)
        {
            Caption = 'Valid Until';
        }
        field(12;"Used At";DateTime)
        {
            Caption = 'Used At';
        }
        field(20;"E-Mail";Text[80])
        {
            Caption = 'E-Mail';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Password (Hash)")
        {
        }
    }

    fieldgroups
    {
    }
}

