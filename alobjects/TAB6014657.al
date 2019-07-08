table 6014657 "Tax Free GB Blocked Country"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB Blocked Country';

    fields
    {
        field(1;"Shop Country Code";Integer)
        {
            Caption = 'Shop Country Code';
        }
        field(2;"Country Code";Integer)
        {
            Caption = 'Country Code';
        }
    }

    keys
    {
        key(Key1;"Shop Country Code","Country Code")
        {
        }
    }

    fieldgroups
    {
    }
}

