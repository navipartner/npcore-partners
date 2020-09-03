table 6184499 "NPR Pepper Card Type Group"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Pepper Card Type Group";
    LookupPageID = "NPR Pepper Card Type Group";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
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

