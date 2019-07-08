table 6060009 "GIM - Supported Data Format"
{
    Caption = 'GIM - Supported Data Format';

    fields
    {
        field(1;Extension;Code[10])
        {
            Caption = 'Extension';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;"Value Lookup Editable";Boolean)
        {
            Caption = 'Value Lookup Editable';
        }
    }

    keys
    {
        key(Key1;Extension)
        {
        }
    }

    fieldgroups
    {
    }
}

