tableextension 6014468 "NPR Vendor Bank Account" extends "Vendor Bank Account"
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
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }
}