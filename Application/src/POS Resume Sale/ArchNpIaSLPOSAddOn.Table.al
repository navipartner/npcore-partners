table 6014494 "NPR Arch. NpIa SL POS AddOn"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization

    Caption = 'Sale Line POS AddOn';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = "NPR Register";
            DataClassification = CustomerContent;
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
            DataClassification = CustomerContent;
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
            Description = 'NPR5.48';
            TableRelation = "NPR NpIa Item AddOn";
            DataClassification = CustomerContent;
        }
        field(35; "AddOn Line No."; Integer)
        {
            Caption = 'AddOn Line No.';
            DataClassification = CustomerContent;
        }
        field(40; "Fixed Quantity"; Boolean)
        {
            Caption = 'Fixed Quantity';
            Description = 'NPR5.52';
            DataClassification = CustomerContent;
        }
        field(50; "Per Unit"; Boolean)
        {
            Caption = 'Per unit';
            Description = 'NPR5.52';
            DataClassification = CustomerContent;
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

