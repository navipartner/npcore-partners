table 6151434 "NPR Magento Contact Shpt.Meth."
{
    Access = Internal;
    Caption = 'Magento Contact Shipment Method';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Cont.Shpt.Methods";
    LookupPageID = "NPR Magento Cont.Shpt.Methods";

    fields
    {
        field(1; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
        field(5; "External Shipment Method Code"; Text[50])
        {
            Caption = 'External Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Shipment Mapping";
        }
        field(100; "Shipment Method Code"; Code[10])
        {
            CalcFormula = Lookup("NPR Magento Shipment Mapping"."Shipment Method Code" WHERE("External Shipment Method Code" = FIELD("External Shipment Method Code")));
            Caption = 'Shipment Method Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Shipping Agent Code"; Code[10])
        {
            CalcFormula = Lookup("NPR Magento Shipment Mapping"."Shipping Agent Code" WHERE("External Shipment Method Code" = FIELD("External Shipment Method Code")));
            Caption = 'Shipping Agent Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Shipping Agent Service Code"; Code[10])
        {
            CalcFormula = Lookup("NPR Magento Shipment Mapping"."Shipping Agent Service Code" WHERE("External Shipment Method Code" = FIELD("External Shipment Method Code")));
            Caption = 'Shipping Agent Service Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(150; "Shipment Fee Account No."; Code[20])
        {
            CalcFormula = Lookup("NPR Magento Shipment Mapping"."Shipment Fee No." WHERE("External Shipment Method Code" = FIELD("External Shipment Method Code")));
            Caption = 'Shipment Fee Account No.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Contact No.", "External Shipment Method Code")
        {
        }
    }
}
