tableextension 6014457 "NPR Unit Of Measure" extends "Unit of Measure"
{
    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "NPR Replication Counter")
        {
        }
    }
}
