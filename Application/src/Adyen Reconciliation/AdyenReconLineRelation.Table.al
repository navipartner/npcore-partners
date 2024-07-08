table 6150876 "NPR Adyen Recon. Line Relation"
{
    Access = Internal;

    Caption = 'Adyen Reconciliation Line Relation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "GL Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Entry"."Entry No.";
            Caption = 'G/L Entry No.';
        }
        field(10; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR Adyen Recon. Line"."Document No.";
            Caption = 'Document No.';
        }
        field(20; "Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR Adyen Recon. Line"."Line No.";
            Caption = 'Document Line No.';
        }
        field(30; "Amount Type"; Enum "NPR Adyen Recon. Amount Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Type';
        }
        field(40; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(50; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
            TableRelation = "NPR Adyen Recon. Line"."Posting Date";
        }
        field(60; "Posting Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Document No.';
            TableRelation = "NPR Adyen Recon. Line"."Posting No.";
        }
    }
    keys
    {
        key(Key1; "Document No.", "Document Line No.", "Amount Type")
        {
            Clustered = true;
        }
    }
}
