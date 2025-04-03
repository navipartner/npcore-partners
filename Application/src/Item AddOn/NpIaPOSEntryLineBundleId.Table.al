table 6151142 "NPR NpIa POSEntryLineBundleId"
{
    Access = Internal;
    Caption = 'Item AddOn POS Entry Sale Line Bundle Id';
    DataClassification = CustomerContent;

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

        field(10; ReferenceNumber; Text[50])
        {
            Caption = 'Bundle Reference Number';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; POSEntrySaleLineId, Bundle)
        {
            Clustered = true;
        }
        key(ReferenceNumber; ReferenceNumber)
        {
        }
    }



}