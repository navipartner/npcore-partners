table 6184512 "NPR EFT BIN Group Paym. Link"
{
    Caption = 'EFT Mapping Group Payment Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Group Code"; Code[10])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT BIN Group";
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(3; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
    }

    keys
    {
        key(Key1; "Group Code", "Location Code")
        {
        }
    }
}

