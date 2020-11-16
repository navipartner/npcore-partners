table 6014656 "NPR Tax Free GB Country"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB Country';
    LookupPageID = "NPR Tax Free GB Countries";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Country Code"; Integer)
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[60])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; "Passport Code"; Integer)
        {
            Caption = 'Passport Code';
            DataClassification = CustomerContent;
        }
        field(4; "Phone Prefix"; Integer)
        {
            Caption = 'Phone Prefix';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Country Code")
        {
        }
    }

    fieldgroups
    {
    }
}

