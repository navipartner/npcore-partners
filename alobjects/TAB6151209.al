table 6151209 "NpCs Open. Hour Set"
{
    // #362443/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Set';
    DrillDownPageID = "NpCs Open. Hour Sets";
    LookupPageID = "NpCs Open. Hour Sets";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
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

