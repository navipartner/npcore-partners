table 6014496 "NPR Archive NpDc SL POS Coupon"
{
    Access = Internal;
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.

    Caption = 'Sale Line POS Coupon';
    DrillDownPageID = "NPR NpDc SaleLinePOS Coupons";
    LookupPageID = "NPR NpDc SaleLinePOS Coupons";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            NotBlank = true;
            TableRelation = "NPR POS Unit";
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
        field(30; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coupon,Discount';
            OptionMembers = Coupon,Discount;
            DataClassification = CustomerContent;
        }
        field(40; "Applies-to Sale Line No."; Integer)
        {
            Caption = 'Applies-to Sale Line No.';
            DataClassification = CustomerContent;
        }
        field(45; "Applies-to Coupon Line No."; Integer)
        {
            Caption = 'Applies-to Coupon Line No.';
            DataClassification = CustomerContent;
        }
        field(50; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NPR NpDc Coupon Type";
            DataClassification = CustomerContent;
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
        field(70; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.")
        {
            SumIndexFields = "Discount Amount";
        }
        key(Key2; Type, "Coupon No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        SkipCalcDiscount: Boolean;

    procedure GetSkipCalcDiscount(): Boolean
    begin
        //-NPR5.31 [262904]
        exit(SkipCalcDiscount);
        //+NPR5.31 [262904]
    end;

    procedure SetSkipCalcDiscount(NewSkipCalcDiscount: Boolean)
    begin
        //-NPR5.31 [262904]
        SkipCalcDiscount := NewSkipCalcDiscount;
        //+NPR5.31 [262904]
    end;
}

