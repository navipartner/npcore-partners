table 6151605 "NPR NpDc Ext. Coupon Reserv."
{
    Caption = 'NpDc Ext. Coupon Reservation';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpDc Ext. Coupon Reserv.";
    LookupPageID = "NPR NpDc Ext. Coupon Reserv.";

    fields
    {
        field(1; "External Document No."; Code[50])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(15; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(50; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(55; "Coupon No."; Code[20])
        {
            Caption = 'Coupon No.';
            DataClassification = CustomerContent;
        }
        field(65; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(80; "Reference No."; Text[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(100; "Inserted at"; DateTime)
        {
            Caption = 'Inserted at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "External Document No.", "Line No.")
        {
        }
        key(Key2; "Document Type", "Document No.")
        {
        }
    }

    trigger OnInsert()
    begin
        "Inserted at" := CurrentDateTime;
    end;
}

