table 6151204 "NpCs Sale Line POS Reference"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Sale Line POS Reference';

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(5;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(10;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(20;"Sale Line No.";Integer)
        {
            Caption = 'Sale Line No.';
        }
        field(30;"Applies-to Line No.";Integer)
        {
            Caption = 'Applies-to Line No.';
        }
        field(35;"Collect Document Entry No.";Integer)
        {
            Caption = 'Collect Document Entry No.';
            TableRelation = "NpCs Document";
        }
        field(100;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(105;"Document Type";Integer)
        {
            Caption = 'Document Type';
        }
        field(110;"Document Line No.";Integer)
        {
            Caption = 'Document Line No.';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Sale Date","Sale Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

