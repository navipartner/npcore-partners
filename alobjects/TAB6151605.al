table 6151605 "NpDc Ext. Coupon Reservation"
{
    // NPR5.51/MHA /20190724  CASE 343352 Object Created

    Caption = 'NpDc Ext. Coupon Reservation';
    DrillDownPageID = "NpDc Ext. Coupon Reservations";
    LookupPageID = "NpDc Ext. Coupon Reservations";

    fields
    {
        field(1;"External Document No.";Code[50])
        {
            Caption = 'External Document No.';
            NotBlank = true;
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(15;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=FIELD("Document Type"));
        }
        field(50;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";
        }
        field(55;"Coupon No.";Code[20])
        {
            Caption = 'Coupon No.';
        }
        field(65;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(80;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
        }
        field(100;"Inserted at";DateTime)
        {
            Caption = 'Inserted at';
        }
    }

    keys
    {
        key(Key1;"External Document No.","Line No.")
        {
        }
        key(Key2;"Document Type","Document No.")
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

