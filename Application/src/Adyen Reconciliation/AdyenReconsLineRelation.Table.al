table 6150982 "NPR Adyen Recons.Line Relation"
{
    Access = Internal;

    Caption = 'NP Pay Reconciliation Line Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(10; "GL Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
            Caption = 'G/L Entry No.';
        }
        field(20; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR Adyen Recon. Line"."Document No.";
            Caption = 'Document No.';
        }
        field(30; "Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR Adyen Recon. Line"."Line No.";
            Caption = 'Document Line No.';
        }
        field(40; "Amount Type"; Enum "NPR Adyen Recon. Amount Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Type';
        }
        field(50; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(60; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
            TableRelation = "NPR Adyen Recon. Line"."Posting Date";
        }
        field(70; "Posting Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Document No.';
            TableRelation = "NPR Adyen Recon. Line"."Posting No.";
        }
        field(80; Reversed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reversed';
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Document Line No.", "Amount Type", Reversed)
        {
        }
    }
}
