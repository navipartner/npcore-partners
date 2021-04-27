table 6014546 "NPR Payment Method Denom"
{

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
        field(10; Denomination; Decimal)
        {
            Caption = 'Denomination';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Payment Method Code", Denomination)
        {
        }
    }

    fieldgroups
    {
    }
}

