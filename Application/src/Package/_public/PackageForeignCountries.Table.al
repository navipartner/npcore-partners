table 6014688 "NPR Package Foreign Countries"
{
    Access = Public;

    Caption = 'Package Foreign Countries';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
            DataClassification = CustomerContent;
        }
        field(2; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(3; "Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shipment Method Code", "Shipping Agent Code", "Country/Region Code")
        {
        }

    }

    fieldgroups
    {
    }
}

