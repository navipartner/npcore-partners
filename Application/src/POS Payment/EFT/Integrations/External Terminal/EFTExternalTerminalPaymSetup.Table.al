table 6184520 "NPR EFT Ext. Term. Paym. Setup"
{
    Caption = 'EFT External Terminal Payment Setup';
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
        field(2; "Enable Card Digits Popup"; Boolean)
        {
            Caption = 'Enable Card Digits Popup';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(3; "Enable Cardholder Popup"; Boolean)
        {
            Caption = 'Enable Cardholder Popup';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(4; "Enable Approval Code Popup"; Boolean)
        {
            Caption = 'Enable Bank Approval Code Popup';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Payment Type POS")
        {
        }
    }

    fieldgroups
    {
    }
}

