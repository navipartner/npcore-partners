table 6151593 "NPR NpDc SaleLinePOS Coupon"
{
    Caption = 'Sale Line POS Coupon';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpDc SaleLinePOS Coupons";
    LookupPageID = "NPR NpDc SaleLinePOS Coupons";

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR POS Unit";
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
        field(30; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Coupon,Discount';
            OptionMembers = Coupon,Discount;
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
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";

            trigger OnValidate()
            var
                CouponType: Record "NPR NpDc Coupon Type";
            begin
                if Type = Type::Coupon then begin
                    if not CouponType.Get("Coupon Type") then
                        CouponType.Init();
                    "Application Sequence No." := CouponType."Application Sequence No.";
                end;
            end;
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
        field(80; "Application Sequence No."; Integer)
        {
            Caption = 'Application Sequence No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            MinValue = 0;
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
        key(Key3; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Application Sequence No.")
        {
        }
    }

    var
        SkipCalcDiscount: Boolean;

    procedure GetSkipCalcDiscount(): Boolean
    begin
        exit(SkipCalcDiscount);
    end;

    procedure SetSkipCalcDiscount(NewSkipCalcDiscount: Boolean)
    begin
        SkipCalcDiscount := NewSkipCalcDiscount;
    end;
}

