table 6151150 "NPR M2 Account Setup"
{
    Access = Internal;
    Caption = 'Account Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Reset Password URL"; Text[80])
        {
            Caption = 'Reset Password URL';
            DataClassification = CustomerContent;
            InitValue = 'http://test.shop.navipartner.dk/changepassword?token=%1&b64email=%2';
        }
        field(20; "OTP Validity (Hours)"; Integer)
        {
            Caption = 'Onetime Password Validity (Hours)';
            DataClassification = CustomerContent;
            InitValue = 24;
        }
        field(30; "Contact Template Code"; Code[10])
        {
            Caption = 'Contact Template Code';
            DataClassification = CustomerContent;
        }
        field(40; "No. Series Ship-to Address"; Code[20])
        {
            Caption = 'No. Series Ship-to Address';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
