table 6150930 "NPR WalletAssetHeader"
{
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }

        field(2; TransactionId; Guid)
        {
            Caption = 'Transaction Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        Key(Key2; TransactionId)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

}
