table 6151204 "NPR NpCs Sale Line POS Ref."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Sale Line POS Reference';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Register";
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
            Editable = false;
            NotBlank = true;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(20; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Applies-to Line No."; Integer)
        {
            Caption = 'Applies-to Line No.';
            DataClassification = CustomerContent;
        }
        field(35; "Collect Document Entry No."; Integer)
        {
            Caption = 'Collect Document Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Document";
        }
        field(100; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(105; "Document Type"; Enum "NPR NpCs Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(110; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

