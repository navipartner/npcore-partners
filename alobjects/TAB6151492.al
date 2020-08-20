table 6151492 "Raptor Data Buffer"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements

    Caption = 'Raptor Data Buffer';
    DataClassification = CustomerContent;
    DrillDownPageID = "Raptor Data Buffer Entries";
    LookupPageID = "Raptor Data Buffer Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Text[50])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(4; "Item Description"; Text[50])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(5; "Variant Code"; Text[50])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(6; "Date-Time Created"; DateTime)
        {
            Caption = 'Date-Time Created';
            DataClassification = CustomerContent;
        }
        field(7; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

