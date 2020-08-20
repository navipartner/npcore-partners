table 6150626 "POS Entry Comment Line"
{
    // NPR5.36/AP/20170210 CASE 262628 Created Object.
    //                                 Use this to hold any comment to be stored, printed ect. from the POS Sale.
    //                                 Use field "Code" to distinguish source and usage (e.g. comments stored and printed for special purposes like Peyment Terminal Reciepts)

    Caption = 'POS Entry Comment Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(3; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "POS Entry";
        }
        field(4; "POS Entry Line No."; Integer)
        {
            Caption = 'POS Entry Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(11; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(12; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(20; "POS Sale ID"; Integer)
        {
            Caption = 'POS Sale ID';
            DataClassification = CustomerContent;
        }
        field(21; "POS Line No."; Integer)
        {
            Caption = 'POS Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table ID", "POS Entry No.", "POS Entry Line No.", "Code", "Line No.")
        {
        }
        key(Key3; "POS Sale ID", "POS Line No.", "Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

