table 6151591 "NPR NpDc Coupon"
{
    Caption = 'Coupon';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Coupon Type", Description;
    DrillDownPageID = "NPR NpDc Coupons";
    LookupPageID = "NPR NpDc Coupons";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(5; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";

            trigger OnValidate()
            var
                CouponType: Record "NPR NpDc Coupon Type";
            begin
                CouponType.Get("Coupon Type");
                Description := CouponType.Description;
                "Starting Date" := CouponType."Starting Date";
                "Ending Date" := CouponType."Ending Date";
                "Customer No." := CouponType."Customer No.";
                "Discount Type" := CouponType."Discount Type";
                "Discount %" := CouponType."Discount %";
                "Max. Discount Amount" := CouponType."Max. Discount Amount";
                "Discount Amount" := CouponType."Discount Amount";
                "Max Use per Sale" := CouponType."Max Use per Sale";
                "Print Template Code" := CouponType."Print Template Code";
            end;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(15; "Reference No."; Text[30])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(17; "Discount Type"; Option)
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
        field(40; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(43; "Arch. No."; Code[20])
        {
            Caption = 'Archivation No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.37';
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
        field(65; "Print Template Code"; Code[20])
        {
            Caption = 'Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151591));
        }
        field(70; Open; Boolean)
        {
            CalcFormula = Max("NPR NpDc Coupon Entry".Open WHERE("Coupon No." = FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; "Remaining Quantity"; Decimal)
        {
            CalcFormula = Sum("NPR NpDc Coupon Entry"."Remaining Quantity" WHERE("Coupon No." = FIELD("No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(80; "In-use Quantity"; Integer)
        {
            CalcFormula = Count("NPR NpDc SaleLinePOS Coupon" WHERE(Type = CONST(Coupon),
                                                                   "Coupon No." = FIELD("No.")));
            Caption = 'In-use Quantity';
            Editable = false;
            FieldClass = FlowField;
        }
        field(85; "In-use Quantity (External)"; Integer)
        {
            CalcFormula = Count("NPR NpDc Ext. Coupon Reserv." WHERE("Coupon No." = FIELD("No.")));
            Caption = 'In-use Quantity (External)';
            Description = 'NPR5.51';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Issue Coupon Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Issue Coupon Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Issue Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; "Validate Coupon Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Validate Coupon Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Validate Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Apply Discount Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Apply Discount Module" WHERE(Code = FIELD("Coupon Type")));
            Caption = 'Apply Discount Module';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Coupon Type")
        {
        }
        key(Key3; "Reference No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Coupon Type", Description)
        {
        }
    }

    trigger OnDelete()
    var
        CouponEntry: Record "NPR NpDc Coupon Entry";
        SaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        CouponEntry.SetRange("Coupon No.", "No.");
        CouponEntry.DeleteAll;

        SaleLinePOSCoupon.SetRange("Coupon No.", "No.");
        if SaleLinePOSCoupon.FindFirst then
            SaleLinePOSCoupon.DeleteAll;

        NpDcExtCouponSalesLine.SetRange("Coupon No.", "No.");
        if NpDcExtCouponSalesLine.FindFirst then
            NpDcExtCouponSalesLine.DeleteAll;
    end;

    trigger OnInsert()
    var
        CouponSetup: Record "NPR NpDc Coupon Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TestField("Coupon Type");
        if "No." = '' then begin
            CouponSetup.Get;
            CouponSetup.TestField("Coupon No. Series");
            NoSeriesMgt.InitSeries(CouponSetup."Coupon No. Series", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        TestReferenceNo();
    end;

    trigger OnModify()
    begin
        TestField("Coupon Type");
        TestReferenceNo();
    end;

    var
        Text000: Label 'Reference No. %1 is already used!';

    local procedure InitReferenceNo()
    var
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        "Reference No." := CouponMgt.GenerateReferenceNo(Rec);
    end;

    local procedure TestReferenceNo()
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        if "Reference No." = '' then
            InitReferenceNo();

        TestField("Reference No.");

        Coupon.SetFilter("No.", '<>%1', "No.");
        Coupon.SetRange("Reference No.", "Reference No.");
        if Coupon.FindFirst then
            Error(Text000, "Reference No.");
    end;

    procedure CalcInUseQty() InUseQty: Integer
    begin
        CalcFields("In-use Quantity", "In-use Quantity (External)");
        exit("In-use Quantity" + "In-use Quantity (External)");
    end;
}

