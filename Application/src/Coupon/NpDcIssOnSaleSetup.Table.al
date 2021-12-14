table 6151601 "NPR NpDc Iss.OnSale Setup"
{
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
            InitValue = 1;
            MinValue = 1;

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
}

