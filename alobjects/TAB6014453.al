table 6014453 "Pakke Foreign Shipment Mapping"
{
    // NPR5.51/BHR /20190719 CASE 362106 Pakkelabels foreign shipment method mapping

    Caption = 'Pakke Foreign Shipment Mapping';

    fields
    {
        field(1;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(2;"Shipping Agent Code";Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(3;"Country/Region Code";Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(4;"Base Shipping Agent Code";Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(5;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
    }

    keys
    {
        key(Key1;"Shipment Method Code","Shipping Agent Code")
        {
        }
        key(Key2;"Country/Region Code","Base Shipping Agent Code")
        {
        }
    }

    fieldgroups
    {
    }
}

