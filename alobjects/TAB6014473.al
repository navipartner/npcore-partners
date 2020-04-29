table 6014473 "Store Group"
{
    // NPR4.16/TJ/20151115 CASE 222281 Table Created

    Caption = 'Store Group';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Blank Location";Boolean)
        {
            Caption = 'Blank Location';
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

