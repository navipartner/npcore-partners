table 6151601 "NPR NpDc Iss.OnSale Setup"
{
    // NPR5.36/MHA /20170831  CASE 286812 Object created - Discount Coupon Issue Module

    Caption = 'Issue On-Sale Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Coupon Type"; Code[20])
        {
            Caption = 'Coupon Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpDc Coupon Type";
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Sales Amount,Item Sales Qty.,Lot';
            OptionMembers = "Item Sales Amount","Item Sales Qty.",Lot;
        }
        field(20; "Item Sales Amount"; Decimal)
        {
            Caption = 'Item Sales Amount';
            DataClassification = CustomerContent;
        }
        field(25; "Item Sales Qty."; Decimal)
        {
            Caption = 'Item Sales Qty.';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50; "Max. Allowed Issues per Sale"; Decimal)
        {
            BlankZero = true;
            Caption = 'Max. Allowed Issues per Sale';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;
        }
    }

    keys
    {
        key(Key1; "Coupon Type")
        {
        }
    }

    fieldgroups
    {
    }
}

