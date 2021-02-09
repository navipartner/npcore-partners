table 6151438 "NPR Magento Shipment Mapping"
{
    Caption = 'Magento Shipment Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(5; "External Shipment Method Code"; Text[50])
        {
            Caption = 'External Shipment Method Code';
            DataClassification = CustomerContent;
        }
        field(100; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(110; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
        }
        field(120; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(140; "Shipment Fee Type"; Enum "NPR Mag. Shipment Fee Type")
        {
            Caption = 'Shipment Fee Type';
            DataClassification = CustomerContent;
        }
        field(150; "Shipment Fee No."; Code[20])
        {
            Caption = 'Shipment Fee No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Shipment Fee Type" = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Shipment Fee Type" = CONST(Item)) Item
            ELSE
            IF ("Shipment Fee Type" = CONST(Resource)) Resource
            ELSE
            IF ("Shipment Fee Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Shipment Fee Type" = CONST("Charge (Item)")) "Item Charge";
        }
    }

    keys
    {
        key(Key1; "External Shipment Method Code")
        {
        }
    }
}