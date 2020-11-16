table 6014657 "NPR TaxFree GB BlockedCountry"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free GB Blocked Country';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Country Code"; Integer)
        {
            Caption = 'Shop Country Code';
            DataClassification = CustomerContent;
        }
        field(2; "Country Code"; Integer)
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shop Country Code", "Country Code")
        {
        }
    }

    fieldgroups
    {
    }
}

