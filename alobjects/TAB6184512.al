table 6184512 "EFT BIN Group Payment Link"
{
    // NPR5.42/MMV /20180507 CASE 306689 Created table

    Caption = 'EFT BIN Group Payment Link';

    fields
    {
        field(1;"Group Code";Code[10])
        {
            Caption = 'Group Code';
            TableRelation = "EFT BIN Group";
        }
        field(2;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS";
        }
    }

    keys
    {
        key(Key1;"Group Code","Location Code")
        {
        }
    }

    fieldgroups
    {
    }
}

