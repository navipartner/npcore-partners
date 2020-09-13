table 6014644 "NPR Tax Free Voucher Sale Link"
{
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Voucher Sale Link';
    LookupPageID = "NPR Tax Free Vouch. Sale Links";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher Entry No."; Integer)
        {
            Caption = 'Voucher Entry No.';
            TableRelation = "NPR Tax Free Voucher"."Entry No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TaxFreeVoucher: Record "NPR Tax Free Voucher";
            begin
                TaxFreeVoucher.Get("Voucher Entry No.");
                "Voucher External No." := TaxFreeVoucher."External Voucher No.";
            end;
        }
        field(2; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(3; "Sales Header Type"; Option)
        {
            Caption = 'Sales Header Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
            DataClassification = CustomerContent;
        }
        field(4; "Sales Header No."; Code[20])
        {
            Caption = 'Sales Header No.';
            DataClassification = CustomerContent;
        }
        field(20; "Voucher External No."; Text[50])
        {
            Caption = 'Voucher External No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Voucher Entry No.", "Sales Ticket No.", "Sales Header No.", "Sales Header Type")
        {
        }
        key(Key2; "Sales Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }
}

