table 6151438 "Magento Shipment Mapping"
{
    // MAG1.01 /MHA /20150121  CASE 199932 Refactored object from Web Integration
    // MAG2.00 /MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03 /MHA /20170503  CASE 274713 Length of field 150 "Shipment Fee Account No." increased from 10 to 20
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Shipment Mapping';

    fields
    {
        field(5;"External Shipment Method Code";Text[50])
        {
            Caption = 'External Shipment Method Code';
        }
        field(100;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(110;"Shipping Agent Code";Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(120;"Shipping Agent Service Code";Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
        field(150;"Shipment Fee Account No.";Code[20])
        {
            Caption = 'Shipment Fee Account No.';
            Description = 'MAG2.03';
            TableRelation = "G/L Account";
        }
    }

    keys
    {
        key(Key1;"External Shipment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

