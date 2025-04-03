table 6151143 "NPR NpIa POSEntryLineBndlAsset"
{

    Access = Internal;
    fields
    {
        field(1; POSEntrySaleLineId; Guid)
        {
            Caption = 'POS Entry Sale Line No.';
            DataClassification = CustomerContent;
        }

        field(2; Bundle; Integer)
        {
            Caption = 'Bundle';
            DataClassification = CustomerContent;
        }
        field(3; AssetTableId; Integer)
        {
            Caption = 'Asset Table Id';
            DataClassification = CustomerContent;
        }
        field(4; AssetSystemId; Guid)
        {
            Caption = 'Asset System Id';
            DataClassification = CustomerContent;
        }

        field(10; AppliesToSaleLineId; Guid)
        {
            Caption = 'Applies-To Sale Line Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; POSEntrySaleLineId, Bundle, AssetTableId, AssetSystemId)
        {
            clustered = true;
        }

        key(Header; AppliesToSaleLineId, Bundle, AssetTableId, AssetSystemId)
        {
        }

        key(Asset; AssetTableId, AssetSystemId)
        {
        }
    }
}