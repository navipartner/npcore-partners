table 6151597 "NPR NpDc Arch. Coupon"
{
    Caption = 'Archived Coupon';
    DataClassification = CustomerContent;
    DataCaptionFields = "No.", "Coupon Type", Description;
    DrillDownPageID = "NPR NpDc Arch. Coupons";
    LookupPageID = "NPR NpDc Arch. Coupons";

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
            CalcFormula = Max("NPR NpDc Arch.Coupon Entry".Open WHERE("Arch. Coupon No." = FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75; "Remaining Quantity"; Decimal)
        {
            CalcFormula = Sum("NPR NpDc Arch.Coupon Entry"."Remaining Quantity" WHERE("Arch. Coupon No." = FIELD("No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0 : 5;
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
}

