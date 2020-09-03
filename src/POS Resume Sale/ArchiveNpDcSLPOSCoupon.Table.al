table 6014496 "NPR Archive NpDc SL POS Coupon"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization

    Caption = 'Sale Line POS Coupon';
    DrillDownPageID = "NPR NpDc SaleLinePOS Coupons";
    LookupPageID = "NPR NpDc SaleLinePOS Coupons";

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = "NPR Register";
        }
        field(5; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(10; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15; "Sale Date"; Date)
        {
            Caption = 'Sale Date';
        }
        field(20; "Sale Line No."; Integer)
        {
            Caption = 'Sale Line No.';
        }
        field(25; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coupon,Discount';
            OptionMembers = Coupon,Discount;
        }
        field(40; "Applies-to Sale Line No."; Integer)
        {
            Caption = 'Applies-to Sale Line No.';
        }
        field(45; "Applies-to Coupon Line No."; Integer)
        {
            Caption = 'Applies-to Coupon Line No.';
        }
        field(50; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(55; "Coupon No."; Code[20])
        {
            Caption = 'Coupon No.';
        }
        field(65; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(70; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
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

