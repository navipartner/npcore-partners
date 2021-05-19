table 6014660 "NPR POS Cross Reference"
{
    Caption = 'POS Cross Reference';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Cross References";
    LookupPageID = "NPR POS Cross References";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(20; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(21; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            DataClassification = CustomerContent;
        }
        field(22; "Record Value"; Text[100])
        {
            Caption = 'Record Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Reference No.", "Table Name")
        {
        }
    }
}

