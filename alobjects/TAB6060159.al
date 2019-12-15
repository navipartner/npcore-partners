table 6060159 "Event Attribute Entry"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/TJ  /20170530 CASE 277946 New fields Filter and Filter Name

    Caption = 'Event Attribute Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Template Name";Code[20])
        {
            Caption = 'Template Name';
        }
        field(20;"Job No.";Code[20])
        {
            Caption = 'Job No.';
        }
        field(30;"Row Line No.";Integer)
        {
            Caption = 'Row Line No.';
        }
        field(40;"Column Line No.";Integer)
        {
            Caption = 'Column Line No.';
        }
        field(50;"Value Text";Text[250])
        {
            Caption = 'Value Text';
        }
        field(60;"Value Decimal";Decimal)
        {
            Caption = 'Value Decimal';
        }
        field(70;"Filter";Boolean)
        {
            Caption = 'Filter';
            Description = 'NPR5.33';
        }
        field(80;"Filter Name";Code[20])
        {
            Caption = 'Filter Name';
            Description = 'NPR5.33';
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

