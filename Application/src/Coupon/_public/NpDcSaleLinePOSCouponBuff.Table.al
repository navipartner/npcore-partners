table 6151224 "NPR NpDc SaleLinePOSCouponBuff"
{
    Access = Public;
    DataClassification = CustomerContent;
    TableType = Temporary;

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
            MinValue = 0;
        }

        field(90; "Discount Amount Including VAT"; Decimal)
        {
            Caption = 'Discount Amount Including VAT';
            DataClassification = CustomerContent;
        }
        field(100; "Discount Amount Excluding VAT"; Decimal)
        {
            Caption = 'Discount Amount Excluding VAT';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.")
        {
            SumIndexFields = "Discount Amount";
        }
    }

}

