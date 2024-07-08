table 6014657 "NPR TaxFree GB BlockedCountry"
{
    Access = Internal;

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
}

