table 6150936 "NPR WalletAssetSetup"
{
    DataClassification = CustomerContent;
    Access = Internal;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }

        field(20; ReferencePattern; Code[30])
        {
            Caption = 'Wallet Reference Pattern';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}