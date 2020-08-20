table 6151605 "NpDc Ext. Coupon Reservation"
{
    // NPR5.51/MHA /20190724  CASE 343352 Object Created

    Caption = 'NpDc Ext. Coupon Reservation';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpDc Ext. Coupon Reservations";
    LookupPageID = "NpDc Ext. Coupon Reservations";

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
        field(10; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
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
            TableRelation = "NpDc Coupon Type";
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
        field(80; "Reference No."; Text[30])
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

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Inserted at" := CurrentDateTime;
    end;
}

