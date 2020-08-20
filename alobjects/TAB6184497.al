table 6184497 "Pepper Card Type"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "Pepper Card Types";
    LookupPageID = "Pepper Card Types";

    fields
    {
        field(10; "Code"; Code[4])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "Payment Type POS";
        }
        field(40; "Card Type Group Code"; Code[10])
        {
            Caption = 'Card Type Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Pepper Card Type Group";
        }
        field(50; "Debit Card"; Boolean)
        {
            Caption = 'Debit Card';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

