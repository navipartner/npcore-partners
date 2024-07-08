table 6060141 "NPR MM Loyalty Point Setup"
{
    Access = Internal;

    Caption = 'Loyalty Points Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Points Threshold"; Integer)
        {
            Caption = 'Points Threshold';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 1;
        }
        field(21; "Amount LCY"; Decimal)
        {
            Caption = 'Amount LCY';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Amount LCY" <> 0) then
                    Validate("Point Rate", 0);
            end;
        }
        field(22; "Point Rate"; Decimal)
        {
            Caption = 'Point Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
            MaxValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Point Rate" <> 0) then
                    Validate("Amount LCY", 0);
            end;
        }
        field(30; "Coupon Type Code"; Code[10])
        {
            Caption = 'Coupon Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(40; "Value Assignment"; Option)
        {
            Caption = 'Value Assignment';
            DataClassification = CustomerContent;
            OptionCaption = 'Coupon Setup,Loyalty Setup';
            OptionMembers = FROM_COUPON,FROM_LOYALTY;

            trigger OnValidate()
            begin
                case "Value Assignment" of
                    "Value Assignment"::FROM_COUPON:
                        TestField("Point Rate", 0);
                    "Value Assignment"::FROM_LOYALTY:
                        TestField("Amount LCY", 0);
                end;
            end;
        }
        field(50; "Minimum Coupon Amount"; Decimal)
        {
            Caption = 'Minimum Coupon Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
            InitValue = 0.01;
            MinValue = 0.01;
        }
        field(60; "Consume Available Points"; Boolean)
        {
            Caption = 'Consume Available Points';
            DataClassification = CustomerContent;
        }
        field(70; "Notification Code"; Code[10])
        {
            Caption = 'Notification Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Notific. Setup" Where(type = Const(COUPON));
        }
        field(1015; "Discount Type"; Option)
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Discount Type" WHERE(Code = FIELD("Coupon Type Code")));
            Caption = 'Discount Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(1020; "Discount %"; Decimal)
        {
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Discount %" WHERE(Code = FIELD("Coupon Type Code")));
            Caption = 'Discount %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 100;
            MinValue = 0;
        }
        field(1022; "Max. Discount Amount"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Max. Discount Amount" WHERE(Code = FIELD("Coupon Type Code")));
            Caption = 'Max. Discount Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025; "Discount Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Lookup("NPR NpDc Coupon Type"."Discount Amount" WHERE(Code = FIELD("Coupon Type Code")));
            Caption = 'Discount Amount';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code", "Line No.")
        {
        }
        key(Key2; "Code", "Points Threshold")
        {
        }
        key(Key3; "Code", "Amount LCY")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        LoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup";
    begin

        if ("Line No." = 0) then begin
            "Line No." := 10000;
            LoyaltyPointsSetup.SetFilter(Code, '=%1', Code);
            if (LoyaltyPointsSetup.FindLast()) then
                "Line No." += LoyaltyPointsSetup."Line No.";
        end;
    end;
}

