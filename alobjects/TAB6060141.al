table 6060141 "MM Loyalty Points Setup"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System
    // MM1.22/TSA /20170731 CASE 285403 Added table relation and renamed field 30 to Coupon Type Code
    // MM1.28/TSA /20180426 CASE 307048 Added field to handle Dynamic Coupon Values
    // MM1.32/TSA /20180713 CASE 321176 Added some coupon lookup fields required for UI selection
    // MM1.37/TSA /20190227 CASE 343053 Expire points - added field "Consume Available Points"

    Caption = 'Loyalty Points Setup';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = "MM Loyalty Setup";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(20;"Points Threshold";Integer)
        {
            Caption = 'Points Threshold';
            InitValue = 1;
            MinValue = 1;
        }
        field(21;"Amount LCY";Decimal)
        {
            Caption = 'Amount LCY';

            trigger OnValidate()
            begin
                if ("Amount LCY" <> 0) then
                  Validate ("Point Rate", 0);
            end;
        }
        field(22;"Point Rate";Decimal)
        {
            Caption = 'Point Rate';
            DecimalPlaces = 2:5;
            MaxValue = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("Point Rate" <> 0) then
                  Validate ("Amount LCY", 0);
            end;
        }
        field(30;"Coupon Type Code";Code[10])
        {
            Caption = 'Coupon Type Code';
            TableRelation = "NpDc Coupon Type";
        }
        field(40;"Value Assignment";Option)
        {
            Caption = 'Value Assignment';
            OptionCaption = 'Coupon Setup,Loyalty Setup';
            OptionMembers = FROM_COUPON,FROM_LOYALTY;

            trigger OnValidate()
            begin
                case "Value Assignment" of
                  "Value Assignment"::FROM_COUPON : TestField ("Point Rate", 0);
                  "Value Assignment"::FROM_LOYALTY : TestField ("Amount LCY", 0);
                end;
            end;
        }
        field(50;"Minimum Coupon Amount";Decimal)
        {
            Caption = 'Minimum Coupon Amount';
            DecimalPlaces = 2:2;
            InitValue = 0.01;
            MinValue = 0.01;
        }
        field(60;"Consume Available Points";Boolean)
        {
            Caption = 'Consume Available Points';
        }
        field(1015;"Discount Type";Option)
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Discount Type" WHERE (Code=FIELD("Coupon Type Code")));
            Caption = 'Discount Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Discount Amount,Discount %';
            OptionMembers = "Discount Amount","Discount %";
        }
        field(1020;"Discount %";Decimal)
        {
            CalcFormula = Lookup("NpDc Coupon Type"."Discount %" WHERE (Code=FIELD("Coupon Type Code")));
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
            Editable = false;
            FieldClass = FlowField;
            MaxValue = 100;
            MinValue = 0;
        }
        field(1022;"Max. Discount Amount";Decimal)
        {
            BlankZero = true;
            CalcFormula = Lookup("NpDc Coupon Type"."Max. Discount Amount" WHERE (Code=FIELD("Coupon Type Code")));
            Caption = 'Max. Discount Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1025;"Discount Amount";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Lookup("NpDc Coupon Type"."Discount Amount" WHERE (Code=FIELD("Coupon Type Code")));
            Caption = 'Discount Amount';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code","Line No.")
        {
        }
        key(Key2;"Code","Points Threshold")
        {
        }
        key(Key3;"Code","Amount LCY")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        LoyaltyPointsSetup: Record "MM Loyalty Points Setup";
    begin

        if ("Line No." = 0) then begin
          "Line No." := 10000;
          LoyaltyPointsSetup.SetFilter (Code, '=%1', Code);
          if (LoyaltyPointsSetup.FindLast) then
            "Line No." += LoyaltyPointsSetup."Line No.";
        end;
    end;
}

