table 6014453 "NPR Pakke Foreign Shipm. Map."
{

    Caption = 'Pakke Foreign Shipment Mapping';
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
        field(4; "Base Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;
        }
        field(5; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Shipment Method Code", "Shipping Agent Code")
        {
        }
        key(Key2; "Country/Region Code", "Base Shipping Agent Code")
        {
        }
    }

    fieldgroups
    {
    }
}

