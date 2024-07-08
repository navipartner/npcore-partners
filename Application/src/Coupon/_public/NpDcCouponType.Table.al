table 6151590 "NPR NpDc Coupon Type"
{
    Caption = 'Coupon Type';
    DataClassification = CustomerContent;
    DataCaptionFields = "Code", Description;
    DrillDownPageId = "NPR NpDc Coupon Types";
    LookupPageId = "NPR NpDc Coupon Types";

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
        field(31; "Starting Date DateFormula"; DateFormula)
        {
            Caption = 'Starting Date Formula';
            DataClassification = CustomerContent;
        }
        field(35; "Ending Date"; DateTime)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(36; "Ending Date DateFormula"; DateFormula)
        {
            Caption = 'Ending Date  Formula';
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
            TableRelation = "NPR RP Template Header" where("Table ID" = const(6151591));
        }
        field(67; "Print on Issue"; Boolean)
        {
            Caption = 'Print on Issue';
            DataClassification = CustomerContent;
        }
        field(70; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(80; "Application Sequence No."; Integer)
        {
            Caption = 'Application Sequence No.';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(100; "Issue Coupon Module"; Code[20])
        {
            Caption = 'Issue Coupon Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code where(Type = const("Issue Coupon"));
        }
        field(110; "Validate Coupon Module"; Code[20])
        {
            Caption = 'Validate Coupon Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code where(Type = const("Validate Coupon"));
        }
        field(120; "Apply Discount Module"; Code[20])
        {
            Caption = 'Apply Discount Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Module".Code where(Type = const("Apply Discount"));
        }
        field(150; "POS Store Group"; Code[20])
        {
            Caption = 'POS Store Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store Group";
            trigger OnValidate()
            begin
                CheckPosStoreGroupLines();
            end;
        }
        field(160; "Match POS Store Group"; Boolean)
        {
            Caption = 'Match POS Store Group';
            DataClassification = CustomerContent;
        }

        field(170; "GS1 Account No."; Code[20])
        {
            Caption = 'GS1 Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting),
                                                 "Direct Posting" = const(true));
        }
        field(1000; "Coupon Qty. (Open)"; Integer)
        {
            CalcFormula = count("NPR NpDc Coupon" where("Coupon Type" = field(Code),
                                                     Open = const(true)));
            Caption = 'Coupon Qty. (Open)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1020; "Arch. Coupon Qty."; Integer)
        {
            CalcFormula = count("NPR NpDc Arch. Coupon" where("Coupon Type" = field(Code)));
            Caption = 'Arch. Coupon Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        field(6151480; "Print Object Type"; Enum "NPR Print Object Type")
        {
            Caption = 'Print Object Type';
            DataClassification = CustomerContent;
            InitValue = Template;
        }
        field(6151481; "Print Object ID"; Integer)
        {
            Caption = 'Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = if ("Print Object Type" = const(Codeunit)) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit)) else
            if ("Print Object Type" = const(Report)) AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            BlankZero = true;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }

        key(Key2; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key3; SystemRowVersion)
        {
        }
#ENDIF
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description)
        {

        }
        fieldgroup(Brick; "Code", "Description", "Discount Type", "Discount Amount", "Discount %")
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
        Coupon.DeleteAll();

        CouponEntry.SetRange("Coupon Type", Code);
        CouponEntry.DeleteAll();

        CouponItem.SetRange("Coupon Type", Code);
        CouponItem.DeleteAll();

        SaleLinePOSCoupon.SetRange("Coupon Type", Code);
        SaleLinePOSCoupon.DeleteAll();

        NpDcExtCouponSalesLine.SetRange("Coupon Type", Code);
        if NpDcExtCouponSalesLine.FindFirst() then
            NpDcExtCouponSalesLine.DeleteAll();
    end;

    trigger OnInsert()
    begin
        if "Max Use per Sale" < 1 then
            "Max Use per Sale" := 1;
    end;

    local procedure CheckPosStoreGroupLines()
    var
        POSStoreGroupLine: Record "NPR POS Store Group Line";
        EmptyLinesErr: Label 'POS Store Group Lines are empty. Please assign POS Stores to Lines before selecting POS Store Group.';
    begin
        if "POS Store Group" = '' then
            exit;
        POSStoreGroupLine.SetRange("No.", "POS Store Group");
        if POSStoreGroupLine.IsEmpty() then
            Error(EmptyLinesErr);
    end;

}

