tableextension 6014440 "NPR Item Reference" extends "Item Reference"
{
    fields
    {
        field(6014402; "NPR Label Barcode"; Boolean)
        {
            Caption = 'Label Barcode';
            DataClassification = CustomerContent;
        }

        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(LabelBarcode; "NPR Label Barcode") { }
        key("NPR Key1"; "NPR Replication Counter") { }
    }
}