table 6059945 "NPR CashKeeper Setup"
{
    Caption = 'CashKeeper Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(10; "CashKeeper IP"; Text[20])
        {
            Caption = 'CashKeeper IP';
            DataClassification = CustomerContent;
        }
        field(11; "Debug Mode"; Boolean)
        {
            Caption = 'Debug Mode';
            DataClassification = CustomerContent;
        }
        field(12; "Payment Type"; Code[20])
        {
            Caption = 'Payment Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
    }

    keys
    {
        key(Key1; "Register No.")
        {
        }
    }

    fieldgroups
    {
    }
}

