table 6014546 "NPR Payment Method Denom"
{
    Access = Internal;
    Caption = 'POS Payment Method Denomination';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Payment Method Code"; Code[10])
        {
            Caption = 'POS Payment Method Code';
            TableRelation = "NPR POS Payment Method".Code;
            DataClassification = CustomerContent;
        }
        field(2; "Denomination Type"; Enum "NPR Denomination Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(3; "Denomination Variant ID"; Code[20])
        {
            Caption = 'Denomination Variant ID';
            DataClassification = CustomerContent;
            //Haven't added the field to primary key for now, as it would be a breaking change. Probably the field will never been used anyway.
        }
        field(10; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(20; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code", "Denomination Type", Denomination)
        {
        }
    }
}
