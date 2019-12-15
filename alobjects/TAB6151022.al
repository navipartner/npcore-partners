table 6151022 "NpRv Ext. Voucher Sales Line"
{
    // NPR5.48/MHA /20180921  CASE 302179 Object created

    Caption = 'External Retail Voucher Sales Line';
    DrillDownPageID = "NpRv Ext. Voucher Sales Lines";
    LookupPageID = "NpRv Ext. Voucher Sales Lines";

    fields
    {
        field(1;"External Document No.";Code[50])
        {
            Caption = 'External Document No.';
            Editable = false;
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
        field(20;"Document Line No.";Integer)
        {
            Caption = 'Document Line No.';
        }
        field(35;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'New Voucher,Payment';
            OptionMembers = "New Voucher",Payment;
        }
        field(50;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            TableRelation = "NpRv Voucher Type";
        }
        field(55;"Voucher No.";Code[20])
        {
            Caption = 'Voucher No.';
            TableRelation = "NpRv Voucher";
        }
        field(60;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
        }
        field(65;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"External Document No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

