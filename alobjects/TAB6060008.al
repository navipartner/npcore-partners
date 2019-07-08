table 6060008 "GIM - Data Type Property"
{
    Caption = 'GIM - Data Type Property';
    LookupPageID = "GIM - Data Type Properties";

    fields
    {
        field(1;"Data Type";Code[20])
        {
            Caption = 'Data Type';
        }
        field(2;Property;Text[30])
        {
            Caption = 'Property';
        }
        field(10;Description;Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Data Type",Property)
        {
        }
    }

    fieldgroups
    {
    }
}

