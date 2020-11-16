table 6151595 "NPR NpDc Extra Coupon Item"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    Caption = 'Extra Coupon Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
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
        field(100; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(105; "Unit Price"; Decimal)
        {
            CalcFormula = Lookup (Item."Unit Price" WHERE("No." = FIELD("Item No.")));
            Caption = 'Unit Price';
            Editable = false;
            FieldClass = FlowField;
        }
        field(115; "Profit %"; Decimal)
        {
            CalcFormula = Lookup (Item."Profit %" WHERE("No." = FIELD("Item No.")));
            Caption = 'Profit %';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Coupon Type", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

