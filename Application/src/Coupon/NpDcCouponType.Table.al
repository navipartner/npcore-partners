table 6151590 "NPR NpDc Coupon Type"
{
    Caption = 'Coupon Type';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "NPR NpDc Coupon Types";
    LookupPageID = "NPR NpDc Coupon Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Reference No. Pattern"; Code[20])
        {
            Caption = 'Reference No. Pattern';
            DataClassification = CustomerContent;
        }
        field(15; "Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(20; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(22; "Max. Discount Amount"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Starting Date"; DateTime)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(45; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(50; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(53; "Max Use per Sale"; Integer)
        {
            Caption = 'Max Use per Sale';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 1;
        }
        field(55; "Multi-Use Coupon"; Boolean)
        {
            Caption = 'Multi-Use Coupon';
            DataClassification = CustomerContent;
        }
        field(60; "Multi-Use Qty."; Decimal)
        {
            Caption = 'Multi-Use Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151591));
        }
        field(67; "Print on Issue"; Boolean)
        {
            Caption = 'Print on Issue';
            DataClassification = CustomerContent;
            Description = 'NPR5.42';
        }
        field(70; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Description = 'NPR5.39';
        }
        field(80; "Application Sequence No."; Integer)
        {
            Caption = 'Application Sequence No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            MinValue = 0;
        }
        field(100; "Issue Coupon Module"; Code[20])
        {
            Caption = 'Issue Coupon Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code WHERE(Type = CONST("Issue Coupon"));
        }
        field(110; "Validate Coupon Module"; Code[20])
        {
            Caption = 'Validate Coupon Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code WHERE(Type = CONST("Validate Coupon"));
        }
        field(120; "Apply Discount Module"; Code[20])
        {
            Caption = 'Apply Discount Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code WHERE(Type = CONST("Apply Discount"));
        }
        field(1000; "Coupon Qty. (Open)"; Integer)
        {
            CalcFormula = Count("NPR NpDc Coupon" WHERE("Coupon Type" = FIELD(Code),
                                                     Open = CONST(true)));
            Caption = 'Coupon Qty. (Open)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Arch. Coupon Qty."; Integer)
        {
            CalcFormula = Count("NPR NpDc Arch. Coupon" WHERE("Coupon Type" = FIELD(Code)));
            Caption = 'Arch. Coupon Qty.';
            Description = 'NPR5.37';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    trigger OnDelete()
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        CouponItem: Record "NPR NpDc Extra Coupon Item";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        Coupon.SetRange("Coupon Type", Code);
        Coupon.DeleteAll;

        CouponEntry.SetRange("Coupon Type", Code);
        CouponEntry.DeleteAll;

        CouponItem.SetRange("Coupon Type", Code);
        CouponItem.DeleteAll;

        SaleLinePOSCoupon.SetRange("Coupon Type", Code);
        SaleLinePOSCoupon.DeleteAll;

        NpDcExtCouponSalesLine.SetRange("Coupon Type", Code);
        if NpDcExtCouponSalesLine.FindFirst then
            NpDcExtCouponSalesLine.DeleteAll;
    end;

    trigger OnInsert()
    begin
        if "Max Use per Sale" < 1 then
            "Max Use per Sale" := 1;
    end;
}

