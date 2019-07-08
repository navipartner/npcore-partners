table 6151434 "Magento Contact Shpt. Method"
{
    // MAG1.05/MH/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 1

    Caption = 'Magento Contact Shipment Method';
    DrillDownPageID = "Magento Contact Shpt. Methods";
    LookupPageID = "Magento Contact Shpt. Methods";

    fields
    {
        field(1;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
        }
        field(5;"External Shipment Method Code";Text[50])
        {
            Caption = 'External Shipment Method Code';
            TableRelation = "Magento Shipment Mapping";
        }
        field(100;"Shipment Method Code";Code[10])
        {
            CalcFormula = Lookup("Magento Shipment Mapping"."Shipment Method Code" WHERE ("External Shipment Method Code"=FIELD("External Shipment Method Code")));
            Caption = 'Shipment Method Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Shipping Agent Code";Code[10])
        {
            CalcFormula = Lookup("Magento Shipment Mapping"."Shipping Agent Code" WHERE ("External Shipment Method Code"=FIELD("External Shipment Method Code")));
            Caption = 'Shipping Agent Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120;"Shipping Agent Service Code";Code[10])
        {
            CalcFormula = Lookup("Magento Shipment Mapping"."Shipping Agent Service Code" WHERE ("External Shipment Method Code"=FIELD("External Shipment Method Code")));
            Caption = 'Shipping Agent Service Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(150;"Shipment Fee Account No.";Code[10])
        {
            CalcFormula = Lookup("Magento Shipment Mapping"."Shipment Fee Account No." WHERE ("External Shipment Method Code"=FIELD("External Shipment Method Code")));
            Caption = 'Shipment Fee Account No.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Contact No.","External Shipment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

