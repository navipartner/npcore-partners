table 6151276 "NPR EFT BIN Group Payment Link"
{
    Access = Internal;
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
        field(4; "From Payment Type POS"; Code[10])
        {
            Caption = 'From Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
    }
    keys
    {
        key(Key1; "Group Code", "Location Code", "From Payment Type POS")
        {
            Clustered = true;
        }
    }
}