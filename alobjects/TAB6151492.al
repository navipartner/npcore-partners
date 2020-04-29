table 6151492 "Raptor Data Buffer"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Data Buffer';
    DrillDownPageID = "Raptor Data Buffer Entries";
    LookupPageID = "Raptor Data Buffer Entries";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(3;"Item No.";Text[50])
        {
            Caption = 'Item No.';
        }
        field(4;"Item Description";Text[50])
        {
            Caption = 'Item Description';
        }
        field(5;"Variant Code";Text[50])
        {
            Caption = 'Variant Code';
        }
        field(6;"Date-Time Created";DateTime)
        {
            Caption = 'Date-Time Created';
        }
        field(7;Priority;Integer)
        {
            Caption = 'Priority';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

