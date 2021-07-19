tableextension 6014440 "NPR Item Reference" extends "Item Reference"
{
    fields
    {
        field(6014402; "NPR Label Barcode"; Boolean)
        {
            Caption = 'Label Barcode';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(LabelBarcode; "NPR Label Barcode") { }
    }
}