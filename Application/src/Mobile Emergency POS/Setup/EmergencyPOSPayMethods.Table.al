table 6151037 "NPR Emergency POS Pay Methods"
{
    DataClassification = CustomerContent;
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Emergency POS Setup Code"; Code[20])
        {
            Caption = 'Emergency POS Setup Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Emergency mPOS Setup";
        }
        field(2; "POS Payment Method Code"; Code[20])
        {
            Caption = 'POS Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
    }

    keys
    {
        key(key1; "Emergency POS Setup Code", "POS Payment Method Code")
        {
            Clustered = true;
        }
    }
}