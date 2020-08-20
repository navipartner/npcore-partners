table 6151220 "PrintNode Setup"
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created

    Caption = 'PrintNode Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "API Key"; Text[50])
        {
            Caption = 'API Key';
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

