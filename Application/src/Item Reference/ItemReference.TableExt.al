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
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by SystemRowVersion';
            ObsoleteTag = '21';

        }
    }

    keys
    {
        key(LabelBarcode; "NPR Label Barcode") { }
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by SystemRowVersion';
            ObsoleteTag = '21';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}