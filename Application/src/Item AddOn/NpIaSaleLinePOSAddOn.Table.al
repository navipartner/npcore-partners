table 6151127 "NPR NpIa SaleLinePOS AddOn"
{
    Caption = 'Sale Line POS AddOn';
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
        field(25; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(30; "Applies-to Line No."; Integer)
        {
            Caption = 'Applies-to Line No.';
            DataClassification = CustomerContent;
        }
        field(32; "AddOn No."; Code[20])
        {
            Caption = 'AddOn No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(35; "AddOn Line No."; Integer)
        {
            Caption = 'AddOn Line No.';
            DataClassification = CustomerContent;
        }
        field(40; "Fixed Quantity"; Boolean)
        {
            Caption = 'Fixed Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(50; "Per Unit"; Boolean)
        {
            Caption = 'Per unit';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

