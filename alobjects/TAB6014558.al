table 6014558 "RP Data Join Buffer"
{
    // NPR5.32/MMV /20170411 CASE 241995 Retail Print 2.0

    Caption = 'Data Join Buffer';

    fields
    {
        field(1;"Unique Record No.";Integer)
        {
            Caption = 'Unique Record No.';
        }
        field(2;"Field No.";Integer)
        {
            Caption = 'Field No.';
        }
        field(4;"Data Item Name";Text[50])
        {
            Caption = 'Data Item Name';
        }
        field(5;"Join Level";Integer)
        {
            Caption = 'Join Level';
        }
        field(20;Value;Text[250])
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;"Unique Record No.","Data Item Name","Field No.")
        {
        }
    }

    fieldgroups
    {
    }
}

