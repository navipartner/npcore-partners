table 6060163 "Event Attribute Temp. Filter"
{
    // NPR5.33/TJ  /20170601 CASE 277946 New object created

    Caption = 'Event Attribute Temp. Filter';

    fields
    {
        field(1;"Template Name";Code[20])
        {
            Caption = 'Template Name';
        }
        field(2;"Filter Name";Code[20])
        {
            Caption = 'Filter Name';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Template Name","Filter Name")
        {
        }
    }

    fieldgroups
    {
    }
}

