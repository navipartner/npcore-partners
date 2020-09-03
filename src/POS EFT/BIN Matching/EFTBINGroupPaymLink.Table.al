table 6184512 "NPR EFT BIN Group Paym. Link"
{
    // NPR5.42/MMV /20180507 CASE 306689 Created table

    Caption = 'EFT BIN Group Payment Link';
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
            TableRelation = "NPR Payment Type POS";
        }
    }

    keys
    {
        key(Key1; "Group Code", "Location Code")
        {
        }
    }

    fieldgroups
    {
    }
}

