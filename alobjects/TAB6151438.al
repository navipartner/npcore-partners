table 6151438 "Magento Shipment Mapping"
{
    // MAG1.01/MHA /20150121  CASE 199932 Refactored object from Web Integration
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.03/MHA /20170503  CASE 274713 Length of field 150 "Shipment Fee Account No." increased from 10 to 20
    // MAG2.17/JDH /20181112  CASE 334163 Added Caption to Object
    // MAG2.22/MHA /20190610  CASE 357763 Added field 140 "Shipment Fee Type" and changed table relation of field 150

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
        field(140;"Shipment Fee Type";Option)
        {
            Caption = 'Shipment Fee Type';
            Description = 'MAG2.22';
            OptionCaption = 'G/L Account,Item,Resource,Fixed Asset,Charge (Item)';
            OptionMembers = "G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(150;"Shipment Fee No.";Code[20])
        {
            Caption = 'Shipment Fee No.';
            Description = 'MAG2.03,MAG2.22';
            TableRelation = IF ("Shipment Fee Type"=CONST("G/L Account")) "G/L Account" WHERE ("Direct Posting"=CONST(true),
                                                                                               "Account Type"=CONST(Posting),
                                                                                               Blocked=CONST(false))
                                                                                               ELSE IF ("Shipment Fee Type"=CONST(Item)) Item
                                                                                               ELSE IF ("Shipment Fee Type"=CONST(Resource)) Resource
                                                                                               ELSE IF ("Shipment Fee Type"=CONST("Fixed Asset")) "Fixed Asset"
                                                                                               ELSE IF ("Shipment Fee Type"=CONST("Charge (Item)")) "Item Charge";
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

