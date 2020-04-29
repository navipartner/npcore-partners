table 6151597 "NpDc Arch. Coupon"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Object renamed from "NpDc Posted Coupon" to "NpDc Arch. Coupon"
    // NPR5.51/MHA /20190724  CASE 343352 Removed field 80 "In-use Quantity"

    Caption = 'Archived Coupon';
    DataCaptionFields = "No.","Coupon Type",Description;
    DrillDownPageID = "NpDc Arch. Coupons";
    LookupPageID = "NpDc Arch. Coupons";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(5;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(15;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
        }
        field(17;"Discount Type";Option)
        {
            Caption = 'Discount Type';
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(20;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(22;"Max. Discount Amount";Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Discount Amount';
        }
        field(25;"Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Discount Amount';
        }
        field(30;"Starting Date";DateTime)
        {
            Caption = 'Starting Date';
        }
        field(35;"Ending Date";DateTime)
        {
            Caption = 'Ending Date';
        }
        field(40;"No. Series";Code[10])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(50;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(53;"Max Use per Sale";Integer)
        {
            Caption = 'Max Use per Sale';
            InitValue = 1;
            MinValue = 1;
        }
        field(65;"Print Template Code";Code[20])
        {
            Caption = 'Print Template Code';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151591));
        }
        field(70;Open;Boolean)
        {
            CalcFormula = Max("NpDc Arch. Coupon Entry".Open WHERE ("Arch. Coupon No."=FIELD("No.")));
            Caption = 'Open';
            Editable = false;
            FieldClass = FlowField;
        }
        field(75;"Remaining Quantity";Decimal)
        {
            CalcFormula = Sum("NpDc Arch. Coupon Entry"."Remaining Quantity" WHERE ("Arch. Coupon No."=FIELD("No.")));
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Issue Coupon Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Issue Coupon Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Issue Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Validate Coupon Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Validate Coupon Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Validate Coupon Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(120;"Apply Discount Module";Code[20])
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Apply Discount Module" WHERE (Code=FIELD("Coupon Type")));
            Caption = 'Apply Discount Module';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Coupon Type")
        {
        }
        key(Key3;"Reference No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.","Coupon Type",Description)
        {
        }
    }
}

