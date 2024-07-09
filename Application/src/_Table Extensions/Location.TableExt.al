tableextension 6014418 "NPR Location" extends Location
{
    fields
    {
        field(6014400; "NPR No Whse. Entr. for POS"; Boolean)
        {
            Caption = 'POS: Do Not Create Whse. Entries';
            DataClassification = CustomerContent;
        }
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
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
        field(6014401; "NPR Retail Location"; Boolean)
        {
            Caption = 'Retail Location';
            DataClassification = CustomerContent;
        }
#if not (BC17 or BC18 or BC19 or BC20)
        field(6014402; "NPR Magento 2 Source"; Text[50])
        {
            Caption = 'Magento 2 Source';
            DataClassification = SystemMetadata;
        }
#endif
    }

    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
    }
}
