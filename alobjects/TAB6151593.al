table 6151593 "NpDc Sale Line POS Coupon"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.36/MHA /20170831  CASE 288641 Added functions GetSkipCalcDiscount() and SetSkipCalcDiscount()

    Caption = 'Sale Line POS Coupon';
    DrillDownPageID = "NpDc Sale Line POS Coupons";
    LookupPageID = "NpDc Sale Line POS Coupons";

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
        field(25;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(30;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Coupon,Discount';
            OptionMembers = Coupon,Discount;
        }
        field(40;"Applies-to Sale Line No.";Integer)
        {
            Caption = 'Applies-to Sale Line No.';
        }
        field(45;"Applies-to Coupon Line No.";Integer)
        {
            Caption = 'Applies-to Coupon Line No.';
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
        field(70;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Sale Date","Sale Line No.","Line No.")
        {
            SumIndexFields = "Discount Amount";
        }
        key(Key2;Type,"Coupon No.")
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

