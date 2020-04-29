table 6150626 "POS Entry Comment Line"
{
    // NPR5.36/AP/20170210 CASE 262628 Created Object.
    //                                 Use this to hold any comment to be stored, printed ect. from the POS Sale.
    //                                 Use field "Code" to distinguish source and usage (e.g. comments stored and printed for special purposes like Peyment Terminal Reciepts)

    Caption = 'POS Entry Comment Line';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(3;"POS Entry No.";Integer)
        {
            Caption = 'POS Entry No.';
            TableRelation = "POS Entry";
        }
        field(4;"POS Entry Line No.";Integer)
        {
            Caption = 'POS Entry Line No.';
        }
        field(10;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(11;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(12;Comment;Text[250])
        {
            Caption = 'Comment';
        }
        field(20;"POS Sale ID";Integer)
        {
            Caption = 'POS Sale ID';
        }
        field(21;"POS Line No.";Integer)
        {
            Caption = 'POS Line No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Table ID","POS Entry No.","POS Entry Line No.","Code","Line No.")
        {
        }
        key(Key3;"POS Sale ID","POS Line No.","Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

