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
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        field(6151500; "NPR Discontinued Barcode"; Boolean)
        {
            Caption = 'Discontinued Barcode';
            DataClassification = CustomerContent;
        }
        field(6151501; "NPR Discontinued Reason"; Option)
        {
            Caption = 'Discontinued Barcode Reason';
            DataClassification = CustomerContent;
            OptionMembers = " ","Sale","Manual","Inactive","Upgrade","Return";
        }
    }

    keys
    {
        key("NPR LabelBarcode"; "NPR Label Barcode") { }
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}
