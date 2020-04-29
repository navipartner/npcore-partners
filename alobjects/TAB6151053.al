table 6151053 "POS Payment View Log Entry"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created

    Caption = 'POS Payment View Log Entry';
    DrillDownPageID = "POS Payment View Log Entries";
    LookupPageID = "POS Payment View Log Entries";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"POS Unit";Code[10])
        {
            Caption = 'POS Unit';
            NotBlank = true;
            TableRelation = "POS Unit";
        }
        field(10;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(12;"POS Store";Code[10])
        {
            Caption = 'POS Store';
        }
        field(15;"Post Code Popup";Boolean)
        {
            Caption = 'Post Code Popup';
        }
        field(25;"Log Date";DateTime)
        {
            Caption = 'Log Date';
        }
        field(100;"POS Sales No.";Integer)
        {
            Caption = 'POS Sales No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"POS Unit","Sales Ticket No.")
        {
        }
        key(Key3;"POS Sales No.")
        {
        }
        key(Key4;"POS Store","POS Sales No.")
        {
        }
        key(Key5;"POS Unit","POS Sales No.")
        {
        }
    }

    fieldgroups
    {
    }
}

