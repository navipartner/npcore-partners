table 6060007 "GIM - Supported Data Type"
{
    Caption = 'GIM - Supported Data Type';
    LookupPageID = "GIM - Supported Data Types";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[30])
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

