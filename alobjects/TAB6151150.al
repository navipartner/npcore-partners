table 6151150 "M2 Account Setup"
{
    // NPR5.48/TSA /20181211 CASE 320425 Initial Version

    Caption = 'Account Setup';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;"Reset Password URL";Text[80])
        {
            Caption = 'Reset Password URL';
            InitValue = 'http://test.shop.navipartner.dk/changepassword?token=%1&b64email=%2';
        }
        field(20;"OTP Validity (Hours)";Integer)
        {
            Caption = 'Onetime Password Validity (Hours)';
            InitValue = 24;
        }
        field(30;"Contact Template Code";Code[10])
        {
            Caption = 'Contact Template Code';
        }
        field(40;"No. Series Ship-to Address";Code[10])
        {
            Caption = 'No. Series Ship-to Address';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

