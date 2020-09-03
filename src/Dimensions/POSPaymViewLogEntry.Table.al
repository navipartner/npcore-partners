table 6151053 "NPR POS Paym. View Log Entry"
{
    // NPR5.51/MHA /20190723  CASE 351688 Object created

    Caption = 'POS Payment View Log Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Paym. View Log Entries";
    LookupPageID = "NPR POS Paym. View Log Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "POS Unit"; Code[10])
        {
            Caption = 'POS Unit';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
        }
        field(10; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(12; "POS Store"; Code[10])
        {
            Caption = 'POS Store';
            DataClassification = CustomerContent;
        }
        field(15; "Post Code Popup"; Boolean)
        {
            Caption = 'Post Code Popup';
            DataClassification = CustomerContent;
        }
        field(25; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            DataClassification = CustomerContent;
        }
        field(100; "POS Sales No."; Integer)
        {
            Caption = 'POS Sales No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "POS Unit", "Sales Ticket No.")
        {
        }
        key(Key3; "POS Sales No.")
        {
        }
        key(Key4; "POS Store", "POS Sales No.")
        {
        }
        key(Key5; "POS Unit", "POS Sales No.")
        {
        }
    }

    fieldgroups
    {
    }
}

