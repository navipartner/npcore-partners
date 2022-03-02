tableextension 6014444 "NPR Transfer Line" extends "Transfer Line"
{
    fields
    {
        field(6014403; "NPR Vendor Item No."; Text[50])
        {
            CalcFormula = Lookup(Item."Vendor Item No." WHERE("No." = FIELD("Item No.")));
            Caption = 'Vendor Item No.';
            Description = 'NPR7.100.000';
            FieldClass = FlowField;
        }
        field(6014410; "NPR Cross-Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
            TableRelation = "Item Reference"."Reference No.";
        }
    }
}

