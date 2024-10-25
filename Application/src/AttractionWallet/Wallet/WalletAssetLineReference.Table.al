table 6150932 "NPR WalletAssetLineReference"
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

        field(15; WalletEntryNo; Integer)
        {
            Caption = 'Wallet Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR AttractionWallet";
        }

        field(20; WalletAssetLineEntryNo; Integer)
        {
            Caption = 'Wallet Asset Line Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR WalletAssetLine"."EntryNo";
        }

        field(30; ExpirationDate; DateTime)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }

        field(40; SupersededBy; Integer)
        {
            Caption = 'Superseded By';
            DataClassification = CustomerContent;
            TableRelation = "NPR WalletAssetLineReference"."EntryNo";
        }

        field(200; AssetType; Enum "NPR WalletLineType")
        {
            Caption = 'Asset Type';
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR WalletAssetLine".Type WHERE(EntryNo = Field(WalletAssetLineEntryNo)));
            Editable = false;
        }
        field(201; AssetReference; Text[100])
        {
            Caption = 'Asset Reference';
            FieldClass = FlowField;
            CalcFormula = Lookup("NPR WalletAssetLine".LineTypeReference WHERE(EntryNo = Field(WalletAssetLineEntryNo)));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; WalletEntryNo, SupersededBy)
        {
            Clustered = false;
        }

        key(Key4; WalletAssetLineEntryNo, SupersededBy, WalletEntryNo)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

}