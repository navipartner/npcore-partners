table 6150646 "POS Info Lookup"
{
    Caption = 'POS Info Lookup';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(3;"Primary Key";Text[250])
        {
            Caption = 'Primary Key';
        }
        field(10;"Field 1";Text[250])
        {
            Caption = 'Field 1';
        }
        field(11;"Field 2";Text[250])
        {
            Caption = 'Field 2';
        }
        field(12;"Field 3";Text[250])
        {
            Caption = 'Field 3';
        }
        field(13;"Field 4";Text[250])
        {
            Caption = 'Field 4';
        }
        field(14;"Field 5";Text[250])
        {
            Caption = 'Field 5';
        }
        field(15;"Field 6";Text[250])
        {
            Caption = 'Field 6';
        }
        field(20;RecID;RecordID)
        {
            Caption = 'RecID';
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

