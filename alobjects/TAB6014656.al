table 6014656 "Tax Free GB Country"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB Country';
    LookupPageID = "Tax Free GB Countries";

    fields
    {
        field(1;"Country Code";Integer)
        {
            Caption = 'Country Code';
        }
        field(2;Name;Text[60])
        {
            Caption = 'Name';
        }
        field(3;"Passport Code";Integer)
        {
            Caption = 'Passport Code';
        }
        field(4;"Phone Prefix";Integer)
        {
            Caption = 'Phone Prefix';
        }
    }

    keys
    {
        key(Key1;"Country Code")
        {
        }
    }

    fieldgroups
    {
    }
}

