table 6151433 "NPR Magento Contact Pmt.Meth."
{
    // MAG1.05/MH/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field 1

    Caption = 'Magento Contact Payment Method';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Cont.Pmt.Methods";
    LookupPageID = "NPR Magento Cont.Pmt.Methods";

    fields
    {
        field(1; "Contact No."; Code[20])
        {
            Caption = 'Contact No.';
            DataClassification = CustomerContent;
            TableRelation = Contact;
        }
        field(5; "External Payment Method Code"; Text[50])
        {
            Caption = 'External Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Mapping"."External Payment Method Code" WHERE("External Payment Type" = FILTER(= ''));
        }
        field(100; "Payment Method Code"; Code[10])
        {
            CalcFormula = Lookup ("NPR Magento Payment Mapping"."Payment Method Code" WHERE("External Payment Method Code" = FIELD("External Payment Method Code"),
                                                                                        "External Payment Type" = FILTER(= '')));
            Caption = 'Payment Method Code';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Contact No.", "External Payment Method Code")
        {
        }
    }

    fieldgroups
    {
    }
}

