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
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6151051; "NPR Retail Replenishment No."; Integer)
        {
            Caption = 'Retail Replenisment No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38.01';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Distrib. Table Map" used instead.';
        }
    }
}

