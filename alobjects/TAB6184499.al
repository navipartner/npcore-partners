table 6184499 "Pepper Card Type Group"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Group';
    DrillDownPageID = "Pepper Card Type Group";
    LookupPageID = "Pepper Card Type Group";

    fields
    {
        field(10;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
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

