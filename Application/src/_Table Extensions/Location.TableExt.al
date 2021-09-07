tableextension 6014418 "NPR Location" extends Location
{
    fields
    {
        field(6014473; "NPR Store Group Code"; Code[20])
        {
            Caption = 'Store Group Code';
            DataClassification = CustomerContent;
            Description = '#222281';
            TableRelation = "NPR Store Group";
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }
}